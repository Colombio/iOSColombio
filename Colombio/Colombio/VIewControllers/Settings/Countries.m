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

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFirstViewShown=YES;
    self.wantsFullScreenLayout = YES;
    //[self loadStates];
}

#pragma mark WebServiceCommunication
/*
- (void)loadStates{
    //pocetna konfiguracija za datoteke
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePathDrzave =[documentsDirectory stringByAppendingPathComponent:@"drzave.out"];
    NSString *filePathTimeStamp = [documentsDirectory stringByAppendingPathComponent:@"timestamp_countries.out"];
    
    //citanje posljednjeg timestampa za drzave
    NSString *lastTimestamp =[NSString stringWithContentsOfFile:filePathTimeStamp encoding:NSUTF8StringEncoding error:nil];
    
    //sinkrono dohvacanje podataka sa servera
    NSString *url_str = [NSString stringWithFormat:@"http://appforrest.com/colombio/api_config/get_sys_countries?sync_time=%@",lastTimestamp];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    NSDate *methodStart = [NSDate date];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            Boolean mijenjano=true;
            NSDictionary *odgovor=nil;
            //Ako su uspjesno dohvaceni podaci sa servera
            if(err==nil&&data!=nil){
                odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[odgovor allKeys];
                for(NSString *key in keys){
                    
                    //Nije mijenjan popis drzava
                    if(!strcmp("s", key.UTF8String)){
                        mijenjano=false;
                        break;
                    }
                }
            }
            
            //Ako nije dobra konekcija
            else{
                [_Messages showErrorMsg:@"This app requires internet connection. Please make sure that you are connected to the internet."];
                return;
            }
            NSLog(@"*ere");
            //Ako je mijenjan popis drzava
            if(mijenjano){
                NSLog(@"changed");
                //Spremanje zadnjeg timestampa u datoteku
                NSString *changeTimestamp=[odgovor objectForKey:@"change_timestamp"];
                [changeTimestamp writeToFile:filePathTimeStamp atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                //Spremanje drzava u datoteku
                [odgovor writeToFile:filePathDrzave atomically:YES];
            }
            
            //Citanje drzava iz datoteke
            NSDictionary *procitano=[NSDictionary dictionaryWithContentsOfFile:filePathDrzave];
            
            //punjenje drzava podacima
            arOptions = [[NSMutableArray alloc] init];
            NSArray *drzave=[procitano objectForKey:@"data" ];
            for(NSDictionary *k in drzave){
                NSString *value = [k objectForKey:@"c_name"];
                [arOptions addObject:value];
            }
            [arOptions sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            if(arSelectedRows.count==0){
                arSelectedRows = [[NSMutableArray alloc] init];
            }
            else{
                isStatePicked=YES;
                [btnNext setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1.0] forState:UIControlStateNormal];
            }
            
            
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            layout.headerReferenceSize=CGSizeMake(100,36);
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-10) collectionViewLayout:layout];
            
            [_collectionView setDataSource:self];
            [_collectionView setDelegate:self];
            [_collectionView registerClass:[CountriesCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
            [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
            
            [_collectionView setBackgroundColor:[UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1]];
            
            [self.view addSubview:_collectionView];
            [_collectionView addSubview:imgInfoPlaceholder];
            [_collectionView addSubview:imgArrowInfo];
            [_collectionView reloadData];
            
            timer=nil;
            [self.view setUserInteractionEnabled:YES];
        });
    }];
}

//Dodavanje headera u collection view
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if(isCollectionViewHeaderDisplayed==NO){
        if(kind==UICollectionElementKindSectionHeader){
            reusableView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            if(reusableView==nil){
                reusableView=[[UICollectionReusableView alloc]initWithFrame:CGRectMake(0,-150,25,44)];
            }
            
            lblStates = [[UILabel alloc]initWithFrame:CGRectMake(120, -64, 300, 170)];
            lblStates.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
            lblStates.backgroundColor = [UIColor clearColor];
            lblStates.text = @"Loading data";
            lblStates.tag=1500;
            [reusableView addSubview:lblStates];
            collectionViewHeaderDisplayed=YES;
            return reusableView;
        }
    }
    return reusableView;
}

//Ukupan broj celija
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arOptions count];
}

- (void)reload {
    timer=nil;
}

- (void)countDown {
    [_collectionView reloadData];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(reload) userInfo:nil repeats:NO];
}

//Pocetno dodavanje celija u collection view
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    _CountriesCell *cell = (_CountriesCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    long pozicija = (indexPath.row)+(indexPath.section*3);
    
    NSString*countryName = [arOptions objectAtIndex:pozicija];
    
    cell.countryName.text = countryName;
    
    if([arSelectedRows containsObject:countryName]){
        [cell.notSelected setHidden:YES];
        [cell.select setHidden:NO];
    }
    else{
        [cell.notSelected setHidden:NO];
        [cell.select setHidden:YES];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self hideShowInfobars:YES];
    long pozicija = (indexPath.row)+(indexPath.section*3);
    
    NSString*countryName = [arOptions objectAtIndex:pozicija];
    
    if([arSelectedRows containsObject:countryName]){
        [arSelectedRows removeObject:countryName];
        if(timer){
            [timer invalidate];
            timer=nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(countDown) userInfo:nil repeats:NO];
    }
    else{
        [arSelectedRows addObject:countryName];
        if(timer){
            [timer invalidate];
            timer=nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(countDown) userInfo:nil repeats:NO];
    }
    if(arSelectedRows.count==0){
        [btnNext setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.4] forState:UIControlStateNormal];
        statePicked=NO;
    }
    else{
        [btnNext setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1.0] forState:UIControlStateNormal];
        statePicked=YES;
    }
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
