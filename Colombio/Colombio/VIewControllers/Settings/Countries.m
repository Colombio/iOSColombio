//
//  Countries.m
//  colombio
//
//  Created by Colombio on 8/8/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
// TODO - settings
// 1) provjeriti ako se radi o settings
// 2) loadati fav countrie medu ostalim
// 3) Kada se klikne na done, updateati fav countrie, prikazati loading i vratiti na settings

#import "Countries.h"
#import <QuartzCore/QuartzCore.h>

@interface Countries ()

@end

@implementation Countries

@synthesize arOptions;
@synthesize arSelectedRows;
@synthesize lblStates;
@synthesize arSelectedMedia;
@synthesize reusableView;
@synthesize imgArrowInfo;
@synthesize imgInfoPlaceholder;
@synthesize infoBarDescription;
@synthesize isSettings;
@synthesize customHeaderView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"countries");
    isFirstViewShown=YES;
    self.wantsFullScreenLayout = YES;
    customHeaderView.customHeaderDelegate = self;
    customHeaderView.backButtonText = @"SELECT COUNTRY";
    customHeaderView.nextButtonText = @"YOUR INFO";
    loadingView = [[Loading alloc]init];
    [self loadStates];
}

- (void)btnBackClicked{
    
}

- (void)btnNextClicked{
    
}

#pragma mark WebServiceCommunication

- (void)loadStates{
    [loadingView startCustomSpinner:self.view spinMessage:@""];
    NSString *filePathStates = [Tools getFilePaths:@"drzave.out"];
    NSString *filePathTimeStamp = [Tools getFilePaths:@"timestamp_countries.out"];
    //citanje posljednjeg timestampa za drzave
    NSString *lastTimestamp =[NSString stringWithContentsOfFile:filePathTimeStamp encoding:NSUTF8StringEncoding error:nil];
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:@"http://appforrest.com/colombio/api_config/get_sys_countries/" httpBody:[NSString stringWithFormat:@"sync_time=%@",lastTimestamp]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Ako su uspjesno dohvaceni podaci sa servera
            if(error==nil&&data!=nil){
                [self prepareCountries:data response:response strTimestamp:filePathTimeStamp strFilePathStates:filePathStates];
                
                [self addCollectionView:self];
            }
            //Ako nije dobra konekcija
            else{
                [Messages showErrorMsg:@"error_web_request"];
                //TODO Vratiti korisnika na login???
            }
            timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(toggleSpinnerOff) userInfo:nil repeats:NO];
        });
    }];
}

- (void)addCollectionView:(UIViewController *)VC{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize=CGSizeMake(100,0);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height-10) collectionViewLayout:layout];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setDataSource:VC];
    [_collectionView setDelegate:VC];
    [_collectionView registerClass:[CountriesCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:_collectionView];
    [_collectionView reloadData];
    [self.view sendSubviewToBack:_collectionView];
}

- (void)prepareCountries:(NSData *)data response:(NSURLResponse*)response strTimestamp:(NSString *)filePathTimeStamp strFilePathStates:(NSString*)filePathStates{
    Boolean isDataChanged=true;
    NSDictionary *dataWsResponse=nil;
    dataWsResponse =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *keys =[dataWsResponse allKeys];
    for(NSString *key in keys){
        //Nije mijenjan popis drzava
        if(!strcmp("s", key.UTF8String)){
            isDataChanged=false;
            break;
        }
    }
    //Ako je mijenjan popis drzava
    if(isDataChanged){
        //Spremanje zadnjeg timestampa u datoteku
        NSString *changeTimestamp=[dataWsResponse objectForKey:@"change_timestamp"];
        [changeTimestamp writeToFile:filePathTimeStamp atomically:YES encoding:NSUTF8StringEncoding error:nil];
        //Spremanje drzava u datoteku
        [dataWsResponse writeToFile:filePathStates atomically:YES];
    }
    //Citanje drzava iz datoteke
    NSDictionary *countriesFromFile=[NSDictionary dictionaryWithContentsOfFile:filePathStates];
    //punjenje drzava podacima
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

- (void)toggleSpinnerOff{
   [loadingView removeCustomSpinner];
    timer=nil;
}

//Ukupan broj celija
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arOptions count];
}

- (void)reloadCollectionView {
    [_collectionView reloadData];
    timer=nil;
}

//Pocetno dodavanje celija u collection view
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CountriesCell *cell = (CountriesCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    long pozicija = (indexPath.row)+(indexPath.section*3);
    
    NSString*countryName = [arOptions objectAtIndex:pozicija];
    
    cell.lblCountryName.text = countryName;
    cell.imgCountryFlag.image = [UIImage imageNamed:countryName];
    
    if([arSelectedRows containsObject:countryName]){
        [cell.imgSelected setHidden:NO];
        cell.imgCountryFlag.alpha = 1;
        cell.lblCountryName.alpha = 1;
    }
    else{
        cell.imgCountryFlag.image =[Tools convertImageToGrayScale: [UIImage imageNamed:countryName]];
        cell.imgCountryFlag.alpha = 0.3;
        [cell.imgSelected setHidden:YES];
        cell.lblCountryName.alpha = 0.3;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    long cellPosition = (indexPath.row)+(indexPath.section*3);
    
    if(timer){
        return;
    }
    NSString*countryName = [arOptions objectAtIndex:cellPosition];
    
    if([arSelectedRows containsObject:countryName]){
        [arSelectedRows removeObject:countryName];
    }
    else{
        [arSelectedRows addObject:countryName];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
}

//Velicina jedne celije
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(300, 44);
}

//Razmak izmedu celija
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

//Razmak izmedu celija
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1.5;
}

//Padding od rubova
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
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
