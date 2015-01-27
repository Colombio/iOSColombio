//
//  MediaListViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 25/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "MediaListViewController.h"

@interface MediaListViewController ()

@end

@implementation MediaListViewController


- (instancetype)init{
    self = [super init];
    if (self) {
        self.title = [Localized string:@"select_media"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(_arSelectedMedia.count==0){
        _arSelectedMedia = [[NSMutableArray alloc]init];
    }
    [self loadMedia];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                //TODO sloziti setup u init
                _settingsCollectionView = [[SettingsCollectionView alloc] init];
                _settingsCollectionView.settingsCollectionViewDelegate = self;
                _settingsCollectionView.numberOfCells = [_media count];
                [_settingsCollectionView addCollectionView:self];
            }
            //Ako nije dobra konekcija
            else{
                
                //TODO - SLOŽITI ZA SUBCLASS
                [Messages showErrorMsg:@"error_web_request"];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
            //timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(toggleSpinnerOff) userInfo:nil repeats:NO];
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
        NSString *changeTimestamp= [NSString stringWithFormat:@"%@",[dataWsResponse objectForKey:@"change_timestamp"]];
        [changeTimestamp writeToFile:filePathTimeStamp atomically:YES encoding:NSUTF8StringEncoding error:nil];
        //Spremanje drzava u datoteku
        [dataWsResponse writeToFile:filePathMedia atomically:YES];
    }
    //Citanje drzava iz datoteke
    NSDictionary *mediaFromFile=[NSDictionary dictionaryWithContentsOfFile:filePathMedia];
    //punjenje medija podacima
    _media =[mediaFromFile objectForKey:@"data"];
    _arMediaImages = _media;
    if(isDataChanged==true){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadImages];
        });
    }
}

- (void)loadImages{
    NSDate *methodStart = [NSDate date];
    int i=0;
    for(NSDictionary *m in _arMediaImages){
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
            [_settingsCollectionView.collectionView reloadItemsAtIndexPaths:indexPaths];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_settingsCollectionView.collectionView reloadData];
    });
}

#pragma mark CollectionView

//Postavke kako ce celije izgledati
- (UICollectionViewCell *)setupCellLook:(NSIndexPath*)indexPath{
    CountriesCell *cell = (CountriesCell *)[_settingsCollectionView.collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    long cellPosition = (indexPath.row)+(indexPath.section*3);
    NSDictionary*m = [_media objectAtIndex:cellPosition];
    NSString *strMediaName=[m objectForKey:@"name"];
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    if([imagesLoaded containsObject:[NSString stringWithFormat:@"%ld",cellPosition]])
        cell.imgCountryFlag.image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@",documentsDirectoryPath,strMediaName,@"png"]];
    cell.lblCountryName.text = strMediaName;
    
    //Ako je odabran medij, prikazi je da je odabran u viewu
    if([_arSelectedMedia containsObject:[[_media objectAtIndex:cellPosition] objectForKey:@"id"]]){
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

/*- (void)didSelectCell:(NSIndexPath*)indexPath{
    long cellPosition = (indexPath.row)+(indexPath.section*3);
    
    if([_arSelectedMedia containsObject:[[_media objectAtIndex:cellPosition] objectForKey:@"id"]]){
        NSString *strMediaPosition = [[_media objectAtIndex:cellPosition]objectForKey:@"id"];
        [_arSelectedMedia removeObject:strMediaPosition];
    }
    //Ako odabrani medij nije selektiran, dodaj ga u polje selektiranih i refreshaj pogled
    else{
        NSString *strMediaPosition = [[_media objectAtIndex:cellPosition]objectForKey:@"id"];
        [_arSelectedMedia addObject:strMediaPosition];
    }
    [self reloadCollectionView];
    //timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
}*/

- (void)reloadCollectionView {
    [_settingsCollectionView.collectionView reloadData];
}
@end
