//
//  Home.m
//  Colombio
//
//  Created by Colombio on 6/20/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Kontroler za prikaz i odabir medija za korisnika

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

//Pocetno ucitavanje pogleda, dohvacanje medija
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    customHeaderView.customHeaderDelegate = self;
    customHeaderView.backButtonText = @"SELECT COUNTRY";
    customHeaderView.nextButtonText = @"YOUR INFO";
    loadingView = [[Loading alloc]init];
    imagesLoaded = [[NSMutableArray alloc]init];
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

- (void)loadMedia{
    [loadingView startCustomSpinner:self.view spinMessage:@""];
    NSString *filePathMediji = [Tools getFilePaths:@"medijiDohvaceni.out"];
    NSString *filePathTimeStamp = [Tools getFilePaths:@"timestamp_media.out"];
    //citanje posljednjeg timestampa za medije
    NSString *lastTimestamp =[NSString stringWithContentsOfFile:filePathTimeStamp encoding:NSUTF8StringEncoding error:nil];
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_config/get_media/", BASE_URL] httpBody:[NSString stringWithFormat:@"sync_time=%@",lastTimestamp]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Ako su uspjesno dohvaceni podaci sa servera
            if(error==nil&&data!=nil){
                [self prepareMedia:data response:response strTimestamp:filePathTimeStamp strFilePathMedia:filePathMediji];
                
                settingsCollectionView = [[SettingsCollectionView alloc] init];
                settingsCollectionView.settingsCollectionViewDelegate = self;
                settingsCollectionView.numberOfCells = [mediji count];
                [settingsCollectionView addCollectionView:self];
            }
            //Ako nije dobra konekcija
            else{
                [Messages showErrorMsg:@"error_web_request"];
                //TODO Vratiti korisnika na login???
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
            timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(toggleSpinnerOff) userInfo:nil repeats:NO];
        });
    }];
}

- (void)prepareMedia:(NSData *)data response:(NSURLResponse*)response strTimestamp:(NSString *)filePathTimeStamp strFilePathMedia:(NSString*)filePathMedia{
    Boolean isDataChanged=true;
    NSDictionary *dataWsResponse=nil;
    dataWsResponse =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *keys =[dataWsResponse allKeys];
    for(NSString *key in keys){
        //Nije mijenjan popis medija
        if(!strcmp("s", key.UTF8String)){
            isDataChanged=false;
            break;
        }
    }
    //Ako je mijenjan popis medija
    if(isDataChanged){
        //Spremanje zadnjeg timestampa u datoteku
        NSString *changeTimestamp=[dataWsResponse objectForKey:@"change_timestamp"];
        [changeTimestamp writeToFile:filePathTimeStamp atomically:YES encoding:NSUTF8StringEncoding error:nil];
        //Spremanje drzava u datoteku
        [dataWsResponse writeToFile:filePathMedia atomically:YES];
    }
    //Citanje drzava iz datoteke
    NSDictionary *mediaFromFile=[NSDictionary dictionaryWithContentsOfFile:filePathMedia];
    //punjenje medija podacima
    mediji =[mediaFromFile objectForKey:@"data"];
    arMediaImages = mediji;
    if(isDataChanged==true){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadImages];
        });
    }
}

- (void)loadImages{
    NSDate *methodStart = [NSDate date];
    int i=0;
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
    if(exitingView==YES){
        return;
    }
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

//Postavke kako ce celije izgledati
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