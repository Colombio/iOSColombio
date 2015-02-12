/////////////////////////////////////////////////////////////
//
//  MediaViewController.m
//  Armin Vrevic
//
//  Created by Colombio on 7/8/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that implements media listing from a web service
//  or from the media stored locally.
//
//  It first checks for timestamp on the web, if the data
//  is not present locally it fetches all the media, and
//  presents it in a collection view, then for performance
//  optimizing, it loads picture one by one from web service.
//
//  If the data is cached on the device, it loads data from
//  inner device memory
//
///////////////////////////////////////////////////////////////

#import "MediaViewController.h"

@interface MediaViewController ()

@end

@implementation MediaViewController

@synthesize arSelectedRows;
@synthesize mediji;
@synthesize arSelectedMedia;
@synthesize polje;
@synthesize arMediaImages;
@synthesize settingsCollectionView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    //Add custom header
    customHeaderView.customHeaderDelegate = self;
    customHeaderView.backButtonText = @"SELECT COUNTRY";
    customHeaderView.nextButtonText = @"YOUR INFO";
    loadingView = [[Loading alloc]init];
    imagesLoaded = [[NSMutableArray alloc]init];
    //This is provided here so that array can be reinitialized
    //if it is empty,
    //if it is not empty, user probably navigated forward,
    //and then back to this view
    if(arSelectedMedia.count==0){
        arSelectedMedia = [[NSMutableArray alloc]init];
    }
    [self loadMedia];
}

#pragma mark Navigation

- (void)btnBackClicked{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnNextClicked{
    [self presentViewController:[[TabBarViewController alloc] init] animated:NO completion:nil];
}

#pragma mark WebServiceCommunication

/**
 *  Method that loads the media into collection view
 *  It first loads the timestamp from the local
 *  directory, if the timestamp matches the one on the
 *  web server, the cached data is valid.
 *  If not, it sends new async http to the server
 *
 */
- (void)loadMedia{
    [loadingView startCustomSpinner:self.view spinMessage:@""];
    NSString *filePathMediji = [Tools getFilePaths:@"medijiDohvaceni.out"];
    NSString *filePathTimeStamp = [Tools getFilePaths:@"timestamp_media.out"];
    //Reading media last timestamp
    NSString *lastTimestamp =[NSString stringWithContentsOfFile:filePathTimeStamp encoding:NSUTF8StringEncoding error:nil];
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_config/get_media/", BASE_URL] httpBody:[NSString stringWithFormat:@"sync_time=%@",lastTimestamp]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //If data is fetched successfuly
            if(error==nil&&data!=nil){
                [self prepareMedia:data response:response strTimestamp:filePathTimeStamp strFilePathMedia:filePathMediji];
                //Initialize collection view
                settingsCollectionView = [[SettingsCollectionView alloc] init];
                settingsCollectionView.settingsCollectionViewDelegate = self;
                settingsCollectionView.numberOfCells = [mediji count];
                [settingsCollectionView addCollectionView:self];
            }
            //If connection is not good, return user to login
            else{
                [Messages showErrorMsg:@"error_web_request"];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
            //Create timer to fluently remove spinner
            timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(toggleSpinnerOff) userInfo:nil repeats:NO];
        });
    }];
}

/**
 *  Method that checks if the media cached is valid
 *  and if it is not valid it caches it
 *  
 *  After that it loads it into variable and presents it in
 *  collection view
 *
 *  @param data "Data fetched from server"
 *  @param response ""
 *  @param filePathTimeStamp "File path for -> Timestamp that caches the data"
 *  @param filePathMedia "Timestamp for caching the data"
 *
 */
- (void)prepareMedia:(NSData *)data response:(NSURLResponse*)response strTimestamp:(NSString *)filePathTimeStamp strFilePathMedia:(NSString*)filePathMedia{
    Boolean isDataChanged=true;
    NSDictionary *dataWsResponse=nil;
    dataWsResponse =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *keys =[dataWsResponse allKeys];
    for(NSString *key in keys){
        //Media is not changed
        if(!strcmp("s", key.UTF8String)){
            isDataChanged=false;
            break;
        }
    }
    //Media is changed
    if(isDataChanged){
        //Save last timestamp to file
        NSString *changeTimestamp=[dataWsResponse objectForKey:@"change_timestamp"];
        [changeTimestamp writeToFile:filePathTimeStamp atomically:YES encoding:NSUTF8StringEncoding error:nil];
        //Save countries to file
        [dataWsResponse writeToFile:filePathMedia atomically:YES];
    }
    //Read states from file
    NSDictionary *mediaFromFile=[NSDictionary dictionaryWithContentsOfFile:filePathMedia];
    //Fill the media with data
    mediji =[mediaFromFile objectForKey:@"data"];
    arMediaImages = mediji;
    if(isDataChanged==true){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadImages];
        });
    }
}

/**
 *  Async images loading one by one to improve performance
 *
 */
- (void)loadImages{
    NSDate *methodStart = [NSDate date];
    int i=0;
    //for every image
    for(NSDictionary *m in arMediaImages){
        if(exitingView==YES){
            return;
        }
        NSString *urlSlike=[m objectForKey:@"name"];
        NSString *link=[m objectForKey:@"media_icon"];
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        
        NSDate *methodFinish2 = [NSDate date];
        NSTimeInterval executionTime2 = [methodFinish2 timeIntervalSinceDate:methodStart];
        NSLog(@"---------------DOWNLOADING STARTED---------------");
        NSLog(@"Time: =%f ",executionTime2);
        NSURL *imageUrl = [NSURL URLWithString:link];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *imageFromURL =[UIImage imageWithData:imageData];
        
        NSLog(@"---------------DOWNLOADING FINISHED---------------");
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"Time: =%f ",executionTime);
        
        NSLog(@"---------------IMAGE SAVED LOCALLY---------------");
        [UIImagePNGRepresentation(imageFromURL) writeToFile:[documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",urlSlike,@"png"]] options:NSAtomicWrite error:nil];
        
        NSDate *methodFinish3 = [NSDate date];
        NSTimeInterval executionTime3 = [methodFinish3 timeIntervalSinceDate:methodStart];
        NSLog(@"Time: =%f ",executionTime3);
        NSLog(@">");
        NSLog(@">");
        NSLog(@"**************************************************");
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        i++;
        NSArray *indexPaths = [[NSMutableArray alloc]initWithObjects:indexPath, nil];
        long cellPosition = (indexPath.row)+(indexPath.section*3);
        [imagesLoaded addObject:[NSString stringWithFormat:@"%ld",cellPosition]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [settingsCollectionView.collectionView reloadItemsAtIndexPaths:indexPaths];
        });
    }
    //if the user has exited the VC, stop loading images
    if(exitingView==YES){
        return;
    }
    //Reload data in collection view after loading the image
    dispatch_async(dispatch_get_main_queue(), ^{
        [settingsCollectionView.collectionView reloadData];
    });
}

- (void)toggleSpinnerOff{
    [loadingView removeCustomSpinner];
}

- (void)reloadCollectionView {
    [settingsCollectionView.collectionView reloadData];
}

#pragma mark CollectionView

/**
 *  Settings that define how will cells look
 *
 */
- (UICollectionViewCell *)setupCellLook:(NSIndexPath*)indexPath{
    CountriesCell *cell = (CountriesCell *)[settingsCollectionView.collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    long cellPosition = (indexPath.row)+(indexPath.section*3);
    NSDictionary*m = [mediji objectAtIndex:cellPosition];
    NSString *strMediaName=[m objectForKey:@"name"];
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    if([imagesLoaded containsObject:[NSString stringWithFormat:@"%ld",cellPosition]])
    cell.imgCountryFlag.image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@",documentsDirectoryPath,strMediaName,@"png"]];
    cell.lblCountryName.text = strMediaName;
    
    //Ako je odabran medij, prikazi je da je odabran u viewu
    if([arSelectedMedia containsObject:[[mediji objectAtIndex:cellPosition] objectForKey:@"id"]]){
        [cell.imgSelected setHidden:NO];
        cell.imgCountryFlag.alpha = 1;
        cell.lblCountryName.alpha = 1;
    }
    //Ako nije odabran medij, oznaci da nije odabran
    else{
        @try {
            if([imagesLoaded containsObject:[NSString stringWithFormat:@"%ld",cellPosition]])
            cell.imgCountryFlag.image =[Tools convertImageToGrayScale:cell.imgCountryFlag.image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@",documentsDirectoryPath,strMediaName,@"png"]]];
        }
        @catch (NSException *exception) {
            
        }
        cell.imgCountryFlag.alpha = 0.3;
        [cell.imgSelected setHidden:YES];
        cell.lblCountryName.alpha = 0.3;
    }
    return cell;
}

- (void)didSelectCell:(NSIndexPath*)indexPath{
    long cellPosition = (indexPath.row)+(indexPath.section*3);
    
    if([arSelectedMedia containsObject:[[mediji objectAtIndex:cellPosition] objectForKey:@"id"]]){
        NSString *strMediaPosition = [[mediji objectAtIndex:cellPosition]objectForKey:@"id"];
        [arSelectedMedia removeObject:strMediaPosition];
    }
    //Ako odabrani medij nije selektiran, dodaj ga u polje selektiranih i refreshaj pogled
    else{
        NSString *strMediaPosition = [[mediji objectAtIndex:cellPosition]objectForKey:@"id"];
        [arSelectedMedia addObject:strMediaPosition];
    }

    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
}

/*
 infoDescription.text = [[mediji objectAtIndex:pozicija-offset]objectForKey:@"description"];
 
 infoName.text=[[mediji objectAtIndex:pozicija-offset]objectForKey:@"name"];
 
 - (void)nextView{
 exitingView=YES;
 UIView *fromView = self.view;
 ReporterInfo *yourInfo = [[ReporterInfo alloc]init];
 yourInfo.arSelectedRows=self.arSelectedRows;
 yourInfo.arSelectedMedia = self.arSelectedMedia;
 yourInfo.reporterInfo=self.reporterInfo;
 UIView *toView = yourInfo.view;
 
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
 [self presentViewController:yourInfo animated:NO completion:nil];
 }
 }
 ];
 }
 
 - (void)previousView{
 exitingView=YES;
 UIView *fromView = self.view;
 CountriesViewController *states = [[CountriesViewController alloc]init];
 states.arSelectedRows = self.arSelectedRows;
 states.arSelectedMedia = self.arSelectedMedia;
 states.reporterInfo=self.reporterInfo;
 UIView *toView = states.view;
 
 CGRect viewSize = fromView.frame;
 
 [fromView.superview addSubview:toView];
 
 toView.frame = CGRectMake(-320, viewSize.origin.y, 320, viewSize.size.height);
 
 [UIView animateWithDuration:0.4 animations:
 ^{
 fromView.frame = CGRectMake(320, viewSize.origin.y, 320, viewSize.size.height);
 toView.frame = CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
 }
 completion:^(BOOL finished)
 {
 if(finished){
 [self presentViewController:states animated:NO completion:nil];
 }
 }
 ];
 }
 */

@end