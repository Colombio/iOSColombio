//
//  SimpleCountrySelectViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 25/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SimpleCountrySelectViewController.h"
#import "CustomHeaderView.h"
#import "SelectCountryCell.h"
#import "ColombioServiceCommunicator.h"
#import "Loading.h"
#import "Messages.h"
#import "AppDelegate.h"

@interface SimpleCountrySelectViewController ()<CustomHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate, ColombioServiceCommunicatorDelegate>
{
    Loading *spinner;
}
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeader;

@property (strong, nonatomic) NSMutableArray *selectedCountries;
@property (strong, nonatomic) NSArray *countries;
@property (assign, nonatomic) NSInteger countryId;
@property (strong, nonatomic) NSArray *filteredCountries;

@end

@implementation SimpleCountrySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblView.alwaysBounceVertical = NO;
    
    _selectedCountries = [[NSMutableArray alloc] init];
    
    spinner = [[Loading alloc] init];
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate=self;
    [csc fetchCountries];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    _customHeader.headerTitle = [[Localized string:@"select_country"] uppercaseString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Header Action
- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView Delegate
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
        [_selectedCountries addObject:_filteredCountries[indexPath.row][@"c_id"]];
        status = YES;
    }else{
        cell.imgSelected.hidden = YES;
        _filteredCountries[indexPath.row][@"status"] = @0;
        [_selectedCountries removeObject:_filteredCountries[indexPath.row][@"c_id"]];
        status = NO;
    }
    
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
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

#pragma mark Load countries
- (void)didFetchCountries{
    NSString *sql = @"SELECT cl.c_id as c_id, abbr, c_name, lang_id, ifnull(sc.status, 0) as status FROM countries_list cl LEFT OUTER JOIN selected_countries sc on sc.c_id = cl.c_id";
    _countries = [((AppDelegate*)[UIApplication sharedApplication].delegate).db getAllForSQL:sql];
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

- (void)fetchingFailedWithError:(NSError *)error{
    [spinner removeCustomSpinner];
}

- (NSInteger)getCountryId{
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    for (NSDictionary *dict in _countries){
        if ([[dict[@"abbr"] uppercaseString] isEqualToString:countryCode]) {
            return [dict[@"c_id"] integerValue];
        }
    }
    
    return 0;
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
