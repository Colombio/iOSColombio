//
//  SelectCountriesViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 08/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SelectCountriesViewController.h"
#import "ColombioServiceCommunicator.h"
#import "SelectCountryCell.h"
#import "Loading.h"
#import "Tools.h"
#import "Messages.h"
#import "AppDelegate.h"

@interface SelectCountriesViewController ()
{
    Loading *spinner;
    AppDelegate *appdelegate;
}
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) NSArray *countries;
@property (assign, nonatomic) NSInteger countryId;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (strong, nonatomic) NSArray *filteredCountries;
@end

@implementation SelectCountriesViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.title = [[Localized string:@"select_country"] uppercaseString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblView.alwaysBounceVertical = NO;
    _selectedCountries = [[NSMutableArray alloc] init];
    spinner = [[Loading alloc] init];
    [self loadCountries];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _filteredCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectCountryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[SelectCountryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.lblCountry.text = _filteredCountries[indexPath.row][@"c_name"];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.colomb.io/img/country_icons/%@.png", [_filteredCountries[indexPath.row][@"abbr"] uppercaseString]]];
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
        if (image!=nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imgFlag.image = image;
                cell.imgFlag.contentMode = UIViewContentModeScaleAspectFill;
                cell.imgFlag.clipsToBounds=YES;
            });
        }
    });
    if ([_selectedCountries containsObject:_filteredCountries[indexPath.row][@"c_id"]]) {
        cell.imgSelected.hidden = NO;
    }else{
        cell.imgSelected.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectCountryCell *cell = (SelectCountryCell*)[tableView cellForRowAtIndexPath:indexPath];
    BOOL status = FALSE;
    if (cell.imgSelected.hidden) {
        cell.imgSelected.hidden = NO;
        _filteredCountries[indexPath.row][@"status"] = @1;
        cell.imgFlag.alpha = 1;
        cell.lblCountry.alpha = 1;
        [_selectedCountries addObject:_filteredCountries[indexPath.row][@"c_id"]];
        status = YES;
    }else{
        cell.imgSelected.hidden = YES;
        _filteredCountries[indexPath.row][@"status"] = @0;
        cell.imgFlag.alpha = 0.3;
        cell.lblCountry.alpha = 0.3;
        [_selectedCountries removeObject:_filteredCountries[indexPath.row][@"c_id"]];
        status = NO;
    }
    
    NSMutableDictionary *tDict = [[NSMutableDictionary alloc] init];
    tDict[@"status"] = @(status);
    tDict[@"c_id"] = @([_filteredCountries[indexPath.row][@"c_id"] integerValue]);
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM selected_countries WHERE c_id = '%d'", [_filteredCountries[indexPath.row][@"c_id"] intValue]];
    if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
        [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"SELECTED_COUNTRIES"];
    }else{
        [appdelegate.db updateDictionary:tDict forTable:@"SELECTED_COUNTRIES" where:[NSString stringWithFormat:@" c_id='%d'", [_filteredCountries[indexPath.row][@"c_id"] intValue]]];
    }
    
}
#pragma mark Load Countries
- (void)loadCountries{
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    NSInteger lastTimestamp = ([[NSUserDefaults standardUserDefaults] integerForKey:COUNTRIES_TIMESTAMP]?[[NSUserDefaults standardUserDefaults] integerForKey:COUNTRIES_TIMESTAMP]:0);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api_config/get_sys_countries?sync_time=%d", BASE_URL, lastTimestamp]];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //If data from server is successfuly fetched
            if(error==nil&&data!=nil){
                [self prepareCountries:data];
            }
            //If connection is not valid
            else{
                [Messages showErrorMsg:@"error_web_request"];
                [spinner removeCustomSpinner];
            }
        });
    }];
}

/**
 *  Method that checks if the countries cached data is valid
 *  and if it is not valid it caches it
 *
 *  After that it loads it into variable and presents it in
 *  collection view
 *
 *  @param data "Data fetched from server"
 *  @param response ""
 *  @param filePathTimeStamp "File path for -> Timestamp that caches the data"
 *  @param filePathStates "Timestamp for caching the data"
 *
 */
- (void)prepareCountries:(NSData *)data{
    Boolean isDataChanged=true;
    NSDictionary *dataWsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *keys =[dataWsResponse allKeys];
    for(NSString *key in keys){
        //If countries list is changed
        if(!strcmp("s", key.UTF8String)){
            isDataChanged=false;
            break;
        }
    }
    if(isDataChanged){
        [appdelegate.db clearTable:@"COUNTRIES_LIST"];
        
        NSString *changeTimestamp=[dataWsResponse objectForKey:@"change_timestamp"];
        [[NSUserDefaults standardUserDefaults] setObject:changeTimestamp forKey:COUNTRIES_TIMESTAMP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        for(NSDictionary *tDict in dataWsResponse[@"data"]){
            NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM countries_list WHERE c_id = '%d'", [tDict[@"c_id"] intValue]];
            if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"COUNTRIES_LIST"];
            }else{
                [appdelegate.db updateDictionary:tDict forTable:@"COUNTRIES_LIST" where:[NSString stringWithFormat:@" c_id='%d'", [tDict[@"c_id"] intValue]]];
            }
        }
    }
    NSString *sql = @"SELECT cl.c_id as c_id, abbr, c_name, lang_id, ifnull(sc.status, 0) as status FROM countries_list cl LEFT OUTER JOIN selected_countries sc on sc.c_id = cl.c_id";
    _countries = [appdelegate.db getAllForSQL:sql];
    _countryId = [self getCountryId];
    _filteredCountries = [[NSArray alloc] initWithArray:_countries];
    for (NSDictionary *country in _countries){
        if ([country[@"status"] boolValue]) {
            [_selectedCountries addObject:country[@"c_id"]];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(_countryId) forKey:COUNTRY_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tblView reloadData];
        [spinner removeCustomSpinner];
    });
}

- (NSInteger)getCountryId{
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    for (NSDictionary *dict in _countries){
        if ([dict[@"abbr"] isEqualToString:countryCode]) {
            return [dict[@"c_id"] integerValue];
        }
    }
    
    return 0;
}

#pragma mark Validation

- (BOOL)validateCountries{
    if (_selectedCountries.count>0) {
        return YES;
    }
    return NO;
}

#pragma mark TextField
-(IBAction)textFieldDidChange:(UITextField *)textField{
    
    if (textField.text.length>0) {
        [self filterCountries:textField.text];
    }else{
        _filteredCountries = [[NSMutableArray alloc] initWithArray:_countries];
    }
    [_tblView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Filter Media
- (void)filterCountries:(NSString*)searchCondition{
    _filteredCountries=[[NSArray alloc] init];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"c_name beginswith[c] %@", searchCondition];
    _filteredCountries = [_countries filteredArrayUsingPredicate:resultPredicate];
}
@end
