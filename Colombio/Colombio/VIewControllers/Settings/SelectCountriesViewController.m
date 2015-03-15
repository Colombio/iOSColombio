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
@end

@implementation SelectCountriesViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.title = [Localized string:@"select_country"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblView.alwaysBounceVertical = NO;
    _selectedCountries = [[NSMutableArray alloc] init];
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
    return _countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectCountryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[SelectCountryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.lblCountry.text = _countries[indexPath.row][@"c_name"];
    cell.imgFlag.image = [UIImage imageNamed:_countries[indexPath.row][@"c_name"]];
    if ([_countries[indexPath.row][@"status"] boolValue]) {
        cell.imgSelected.hidden = NO;
        cell.imgFlag.alpha = 1;
        cell.lblCountry.alpha = 1;
    }else{
        cell.imgSelected.hidden = YES;
        cell.imgFlag.alpha = 0.3;
        cell.lblCountry.alpha = 0.3;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectCountryCell *cell = (SelectCountryCell*)[tableView cellForRowAtIndexPath:indexPath];
    BOOL status = FALSE;
    if (cell.imgSelected.hidden) {
        cell.imgSelected.hidden = NO;
        _countries[indexPath.row][@"status"] = @1;
        cell.imgFlag.alpha = 1;
        cell.lblCountry.alpha = 1;
        [_selectedCountries addObject:_countries[indexPath.row][@"c_id"]];
        status = YES;
    }else{
        cell.imgSelected.hidden = YES;
        _countries[indexPath.row][@"status"] = @0;
        cell.imgFlag.alpha = 0.3;
        cell.lblCountry.alpha = 0.3;
        [_selectedCountries removeObject:_countries[indexPath.row][@"c_id"]];
        status = NO;
    }
    
    NSMutableDictionary *tDict = [[NSMutableDictionary alloc] init];
    tDict[@"status"] = @(status);
    tDict[@"c_id"] = @([_countries[indexPath.row][@"c_id"] integerValue]);
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM selected_countries WHERE c_id = '%d'", [_countries[indexPath.row][@"c_id"] intValue]];
    if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
        [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"SELECTED_COUNTRIES"];
    }else{
        [appdelegate.db updateDictionary:tDict forTable:@"SELECTED_COUNTRIES" where:[NSString stringWithFormat:@" c_id='%d'", [_countries[indexPath.row][@"c_id"] intValue]]];
    }
    
}
#pragma mark Load Countries
- (void)loadCountries{
    [spinner startCustomSpinner:self.view spinMessage:@""];
    NSString *lastTimestamp = ([[NSUserDefaults standardUserDefaults] stringForKey:COUNTRIES_TIMESTAMP]!=nil?[[NSUserDefaults standardUserDefaults] stringForKey:COUNTRIES_TIMESTAMP]:@"0");
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_config/get_sys_countries/", BASE_URL] httpBody:[NSString stringWithFormat:@"sync_time=%@",lastTimestamp]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
    
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //If data from server is successfuly fetched
            if(error==nil&&data!=nil){
                [self prepareCountries:data];
            }
            //If connection is not valid
            else{
                [Messages showErrorMsg:@"error_web_request"];
            }
            //timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(toggleSpinnerOff) userInfo:nil repeats:NO];
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
        appdelegate = [[UIApplication sharedApplication] delegate];
        [appdelegate.db clearTable:@"COUNTRIES_LIST"];
        
        NSString *changeTimestamp=[dataWsResponse objectForKey:@"change_timestamp"];
        [[NSUserDefaults standardUserDefaults] setObject:changeTimestamp forKey:COUNTRIES_TIMESTAMP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        for(NSDictionary *tDict in dataWsResponse[@"data"]){
            [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"COUNTRIES_LIST"];
        }
    }
    NSString *sql = @"SELECT cl.c_id as c_id, abbr, c_name, lang_id, ifnull(sc.status, 0) as status FROM countries_list cl LEFT OUTER JOIN selected_countries sc on sc.c_id = cl.c_id";
    _countries = [appdelegate.db getAllForSQL:sql];
    _countryId = [self getCountryId];
    for (NSDictionary *country in _countries){
        if ([country[@"status"] boolValue]) {
            [_selectedCountries addObject:country[@"c_id"]];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(_countryId) forKey:COUNTRY_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_tblView reloadData];
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
@end
