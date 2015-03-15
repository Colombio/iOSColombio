/////////////////////////////////////////////////////////////
//
//  Countries.m
//  Armin Vrevic
//
//  Created by Colombio on 8/8/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that implements countries listing from a web service
//  or from the countries stored locally.
//
//  It first checks for timestamp on the web, if the data
//  is not present locally it fetches all the countries, and
//  presents it in a collection view, then for performance
//  optimizing, it loads picture one by one from web service.
//
//  If the data is cached on the device, it loads data from
//  inner device memory
//
///////////////////////////////////////////////////////////////

#import "CountriesViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CountriesViewController ()

@end

@implementation CountriesViewController

@synthesize arOptions;
@synthesize arSelectedRows;
@synthesize lblStates;
@synthesize arSelectedMedia;
@synthesize imgArrowInfo;
@synthesize imgInfoPlaceholder;
@synthesize infoBarDescription;
@synthesize isSettings;
@synthesize customHeaderView;
@synthesize settingsCollectionView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [Localized string:@"select_country"];
    self.wantsFullScreenLayout = YES;
    //Setting up custom header
    customHeaderView.customHeaderDelegate = self;
    customHeaderView.backButtonText = @"SELECT COUNTRY";
    customHeaderView.nextButtonText = @"YOUR INFO";
    loadingView = [[Loading alloc]init];
    [self loadStates];
}

#pragma mark Navigation

- (void)btnBackClicked{
    
}

- (void)btnNextClicked{
    MediaViewController *media = [[MediaViewController alloc]init];
    [self presentViewController:media animated:YES completion:nil];
}

#pragma mark WebServiceCommunication

/**
 *  Method that loads the countries from the web service
 *  It provides caching mechanism for countries data
 *
 */
- (void)loadStates{
    [loadingView startCustomSpinner:self.view spinMessage:@""];
    NSString *filePathStates = [Tools getFilePaths:@"drzave.out"];
    NSString *lastTimestamp = ([[NSUserDefaults standardUserDefaults] stringForKey:COUNTRIES_TIMESTAMP]!=nil?[[NSUserDefaults standardUserDefaults] stringForKey:COUNTRIES_TIMESTAMP]:@"0");// [Tools getFilePaths:@"timestamp_countries.out"];
    
    
    
    
    //Read the last timestamp for countries
    //NSString *lastTimestamp =[NSString stringWithContentsOfFile:filePathTimeStamp encoding:NSUTF8StringEncoding error:nil];
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_config/get_sys_countries/", BASE_URL] httpBody:[NSString stringWithFormat:@"sync_time=%@",lastTimestamp]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //If data from server is successfuly fetched
            if(error==nil&&data!=nil){
                //Prepare collection view
                settingsCollectionView = [[SettingsCollectionView alloc] init];
                settingsCollectionView.settingsCollectionViewDelegate = self;
                [settingsCollectionView addCollectionView:self];
                [self prepareCountries:data response:response strFilePathStates:filePathStates];
                settingsCollectionView.numberOfCells = [arOptions count];
                [self reloadCollectionView];
            }
            //If connection is not valid
            else{
                [Messages showErrorMsg:@"error_web_request"];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
            timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(toggleSpinnerOff) userInfo:nil repeats:NO];
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
- (void)prepareCountries:(NSData *)data response:(NSURLResponse*)response strFilePathStates:(NSString*)filePathStates{
    Boolean isDataChanged=true;
    NSDictionary *dataWsResponse=nil;
    dataWsResponse =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *keys =[dataWsResponse allKeys];
    for(NSString *key in keys){
        //If countries list is changed
        if(!strcmp("s", key.UTF8String)){
            isDataChanged=false;
            break;
        }
    }
    //If cached data is changed
    if(isDataChanged){
        //Save the last timestamp in a file
        NSString *changeTimestamp=[dataWsResponse objectForKey:@"change_timestamp"];
        [[NSUserDefaults standardUserDefaults] setObject:changeTimestamp forKey:COUNTRIES_TIMESTAMP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //Save countries in a file
        [dataWsResponse writeToFile:filePathStates atomically:YES];
    }
    //Load states from file
    NSDictionary *countriesFromFile=[NSDictionary dictionaryWithContentsOfFile:filePathStates];
    //Load countries with data
    arOptions = [[NSMutableArray alloc] init];
    NSArray *arCountries=[countriesFromFile objectForKey:@"data" ];
    for(NSDictionary *k in arCountries){
        NSString *value = [k objectForKey:@"c_name"];
        [arOptions addObject:value];
    }
    [arOptions sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if(arSelectedRows.count==0){
        arSelectedRows = [[NSMutableArray alloc] init];
    }
}

#pragma mark CollectionView

/**
 *  Settings that define how will cells look
 *
 */
- (UICollectionViewCell *)setupCellLook:(NSIndexPath*)indexPath{
    CountriesCell *cell = (CountriesCell *)[settingsCollectionView.collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    long cellPosition = (indexPath.row)+(indexPath.section*3);
    NSString*countryName = [arOptions objectAtIndex:cellPosition];
    cell.lblCountryName.text = countryName;
    cell.imgCountryFlag.image = [UIImage imageNamed:countryName];
    //Ako je odabrana drzava, prikazi je da je odabrana u viewu
    if([arSelectedRows containsObject:countryName]){
        [cell.imgSelected setHidden:NO];
        cell.imgCountryFlag.alpha = 1;
        cell.lblCountryName.alpha = 1;
    }
    //Ako nije odabrana drzava, oznaci da nije odabrana
    else{
        cell.imgCountryFlag.image =[Tools convertImageToGrayScale: [UIImage imageNamed:countryName]];
        cell.imgCountryFlag.alpha = 0.3;
        [cell.imgSelected setHidden:YES];
        cell.lblCountryName.alpha = 0.3;
    }
    return cell;
}

/**
 *  After selecting country, add country index to array if
 *  it is not selected. If it is selected, remove it from array
 *
 */
- (void)didSelectCell:(NSIndexPath*)indexPath{
    long cellPosition = (indexPath.row)+(indexPath.section*3);
    NSString*countryName = [arOptions objectAtIndex:cellPosition];
    if([arSelectedRows containsObject:countryName]){
        [arSelectedRows removeObject:countryName];
    }
    else{
        [arSelectedRows addObject:countryName];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
}

- (void)toggleSpinnerOff{
    [loadingView removeCustomSpinner];
}

- (void)reloadCollectionView {
    [settingsCollectionView.collectionView reloadData];
}
/*
 - (void)switchNextView{
 UIView *currentView = self.view;
 UIView *theWindow = [currentView superview];
 Media *chooseMedia = [[Media alloc]init];
 chooseMedia.arSelectedMedia = self.arSelectedMedia;
 chooseMedia.arSelectedRows = self.arSelectedRows;
 chooseMedia.reporterInfo=self.reporterInfo;
 UIView *newView = chooseMedia.view;
 [currentView removeFromSuperview];
 [theWindow addSubview:newView];
 
 CATransition *animation = [CATransition animation];
 [animation setDuration:0.5];
 [animation setType:kCATransitionMoveIn];
 [animation setSubtype:kCATransitionFromLeft];
 [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
 [[theWindow layer] addAnimation:animation forKey:@"SwitchToView2"];
 }
 
 - (void)nextView{
 UIView *fromView = self.view;
 Media *chooseMedia = [[Media alloc]init];
 chooseMedia.arSelectedMedia = self.arSelectedMedia;
 chooseMedia.arSelectedRows = self.arSelectedRows;
 chooseMedia.reporterInfo=self.reporterInfo;
 UIView *toView = chooseMedia.view;
 
 CGRect viewSize = fromView.frame;
 
 [fromView.superview addSubview:toView];
 
 toView.frame = CGRectMake(320, viewSize.origin.y, 320, viewSize.size.height);
 
 [UIView animateWithDuration:0.4 animations:
 ^{
 fromView.frame = CGRectMake(-320, viewSize.origin.y, 320, viewSize.size.height);
 toView.frame = CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
 }
 completion:^(BOOL finished)
 {
 if(finished){
 [self presentViewController:chooseMedia animated:NO completion:nil];
 }
 }
 ];
 }
 
 //Next -> prebacivanje na choose media.
 - (IBAction)nextClick:(id)sender {
 if(statePicked==NO){
 return;
 }
 if(isSettings){
 
 return;
 }
 [self nextView];
 }
 */

@end
