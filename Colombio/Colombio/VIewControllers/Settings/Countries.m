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
/*
@synthesize arOptions;
@synthesize arSelectedRows;
@synthesize lblStates;
@synthesize arSelectedMedia;
@synthesize reusableView;
@synthesize imgArrowInfo;
@synthesize imgInfoPlaceholder;
@synthesize infoBarDescription;
@synthesize reporterInfo;
@synthesize isSettings;

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addHeader];
    
    firstViewShown=YES;
    self.wantsFullScreenLayout = YES;
    [self loadStates];
}

- (void)addHeader{
    
    UIImageView *tab = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    tab.image = [UIImage imageNamed:@"choosemediabg.png"];
    
    imgInfoPlaceholder =[[UIImageView alloc] initWithFrame:CGRectMake(0, 36, 320, 111)];
    imgInfoPlaceholder.image=[UIImage imageNamed:@"mediainfobg.png"];
    [imgInfoPlaceholder setHidden:YES];
    
    infoBarDescription = [[UILabel alloc] initWithFrame:CGRectMake(20,18,260,75)];
    infoBarDescription.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:17.0f];
    infoBarDescription.numberOfLines=5;
    infoBarDescription.text = @"Choose country to get the list of all available media.";
    [imgInfoPlaceholder addSubview:infoBarDescription];
    
    imgArrowInfo = [[UIImageView alloc] initWithFrame:CGRectMake(239, 29, 40, 15)];
    imgArrowInfo.image=[UIImage imageNamed:@"mediainfoarrow.png"];
    [imgArrowInfo setHidden:YES];
    
    btnNext = [[UIButton alloc]initWithFrame:CGRectMake(250, 0, 70, 70)];
    [btnNext.titleLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-Bold" size:19.0f]];
    [btnNext setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.6] forState:UIControlStateHighlighted];
    [btnNext setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.4] forState:UIControlStateNormal];
    
    [btnNext setTitle:@"Done" forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *labela = [[UIButton alloc]initWithFrame:CGRectMake(79, 0, 150, 70)];
    [labela.titleLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-Bold" size:19.0f]];
    [labela setTitle:@"Select country" forState:UIControlStateNormal];
    UIImageView *strelica = [[UIImageView alloc]initWithFrame:CGRectMake(138, 54, 44, 10)];
    strelica.image = [UIImage imageNamed:@"bgpointer.png"];
    
    [self.view addSubview:tab];
    [self.view addSubview:strelica];
    [self.view addSubview:labela];
    [self.view addSubview:btnNext];
    
    loading = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, self.view.frame.size.height/2-50, 70, 70)];
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    loadingView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:loadingView];
    
    loadingView.alpha=0.4;
    [self.view addSubview:loading];
    [self.view setUserInteractionEnabled:NO];
    [loading startAnimating];
}

#pragma mark WebServiceCommunication

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
                statePicked=YES;
                [btnNext setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1.0] forState:UIControlStateNormal];
            }
            
            
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            layout.headerReferenceSize=CGSizeMake(100,36);
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-10) collectionViewLayout:layout];
            
            [_collectionView setDataSource:self];
            [_collectionView setDelegate:self];
            [_collectionView registerClass:[_CountriesCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
            [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
            
            [_collectionView setBackgroundColor:[UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1]];
            
            [self.view addSubview:_collectionView];
            
            btnInfo = [[UIButton alloc]initWithFrame:CGRectMake(232, 0, 62, 43)];
            [btnInfo setImage:[UIImage imageNamed:@"infoicon.png"] forState:UIControlStateNormal];
            [btnInfo setImage:[UIImage imageNamed:@"infoicon_pressed.png"] forState:UIControlStateHighlighted];
            [btnInfo addTarget:self action:@selector(information:) forControlEvents:UIControlEventTouchUpInside];
            [[btnInfo imageView]setContentMode:UIViewContentModeCenter];
            [btnInfo setAdjustsImageWhenHighlighted:NO];
            btnInfo.imageEdgeInsets = UIEdgeInsetsMake(-30, -40, -30, -30);
            
            [_collectionView addSubview:btnInfo];
            [_collectionView addSubview:imgInfoPlaceholder];
            [_collectionView addSubview:imgArrowInfo];
            
            firstReloaded=YES;
            [self reloadHeaderText];
            timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(reloadHeaderText) userInfo:nil repeats:NO];
            [_collectionView reloadData];
            //NSLog([NSString stringWithFormat:@"%i", arOptions.count]);
            timer=nil;
            loadingView.alpha=0.4;
            [loading removeFromSuperview];
            [loadingView removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
        });
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"Time: =%f ",executionTime);
    }];
}

//Hide or show information about the view
- (void)hideShowInfobars:(BOOL)action{
    [UIView transitionWithView:imgInfoPlaceholder duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [UIView transitionWithView:imgArrowInfo duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [imgInfoPlaceholder setHidden:action];
    [imgArrowInfo setHidden:action];
    
    if(imgInfoPlaceholder.hidden==NO){
        [btnInfo setImage:[UIImage imageNamed:@"infoicon_active.png"] forState:UIControlStateNormal];
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self    action:@selector(closeInfoBar:)];
        tapped.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapped];
    }
    else{
        [btnInfo setImage:[UIImage imageNamed:@"infoicon.png"] forState:UIControlStateNormal];
    }
}

- (void)closeInfoBar:(UITapGestureRecognizer *)tapGestureRecognizer{
    [UIView transitionWithView:imgInfoPlaceholder duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [self hideShowInfobars:YES];
    [self.view removeGestureRecognizer:tapGestureRecognizer];
}

- (void)reloadHeaderText{
    CGRect frame = lblStates.frame;
    frame.origin.x=62;
    lblStates.frame=frame;
    lblStates.text = @"Choose one or more countries.";
}

//Dodavanje headera u collection view
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionViewHeaderDisplayed==NO){
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
    if(firstReloaded==YES){
        CGRect frame = lblStates.frame;
        frame.origin.x=62;
        lblStates.frame=frame;
        lblStates.text = @"Choose one or more countries.";
    }
    return reusableView;
}

- (void)viewDidLayoutSubviews{
    if(firstViewShown==YES){
        CGRect frame = lblStates.frame;
        frame.origin.x=120;
        lblStates.frame=frame;
        lblStates.text=@"Loading data";
        firstViewShown=NO;
    }
    else{
        CGRect frame = lblStates.frame;
        frame.origin.x=62;
        lblStates.text=@"Choose one or more countries.";
        lblStates.frame=frame;
    }
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

- (void)test{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (IBAction)information:(id)sender {
    if(imgInfoPlaceholder.hidden==YES){
        [btnInfo setImage:[UIImage imageNamed:@"infoicon_active.png"] forState:UIControlStateNormal];
        [self hideShowInfobars:NO];
    }
    else{
        [btnInfo setImage:[UIImage imageNamed:@"infoicon.png"] forState:UIControlStateNormal];
        [self hideShowInfobars:YES];
    }
}
*/
@end
