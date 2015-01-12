//
//  Home.m
//  Colombio
//
//  Created by Colombio on 6/20/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Kontroler za prikaz i odabir medija za korisnika

#import "MediaViewController.h"
#import "MediaCell.h"
#import "ReporterInfo.h"
#import "_LoginViewController.h"
#import "Messages.h"
#import "CountriesViewController.h"

@interface MediaViewController ()

@end

@implementation MediaViewController

@synthesize arSelectedRows;
@synthesize mediji;
@synthesize infobar;
@synthesize arrow;
@synthesize reusableView;
@synthesize arSelectedMedia;
@synthesize started;
@synthesize lbl;
@synthesize infoLabel;
@synthesize strelica;
@synthesize lastContentOffset;
@synthesize btnSearch;
@synthesize txtSearch;
@synthesize searchGradient;
@synthesize searchArrow;
@synthesize infoDescription;
@synthesize infoName;
@synthesize infoPanelDescription;
@synthesize infoArrow;
@synthesize infoPanel;
@synthesize reporterInfo;

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//Pocetno ucitavanje pogleda, dohvacanje medija
- (void)viewDidLoad
{
    started=NO;
    hidden=YES;
    counter=0;
    reloadFirst=NO;
    offset=1;
    timerSearch=nil;
    searchHidden=YES;
    
    /////////////////
    infoPanel =[[UIImageView alloc] initWithFrame:CGRectMake(0, 96, 320, 185)];
    infoPanel.image=[UIImage imageNamed:@"mediainfobg.png"];
    [infoPanel setHidden:YES];
    
    infoPanelDescription = [[UILabel alloc] initWithFrame:CGRectMake(25,18,258,150)];
    infoPanelDescription.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:17.0f];
    infoPanelDescription.numberOfLines=8;
    infoPanelDescription.text = @"By choosing media you add selected media to your favourites. Favorite media will be pre-selected when sending news. You will get Alerts and News from favourite media in your Timeline. You can always unselect your favourites or add anoter in app Settings.";
    
    NSString *descriptionStr = @"Add selected media to your favorites. Favorite media will be pre-selected when sending news and they may send you Alerts or notifications.";
    
    infoPanelDescription.text=descriptionStr;
    [infoPanel addSubview:infoPanelDescription];
    
    infoArrow = [[UIImageView alloc] initWithFrame:CGRectMake(270, 93, 40, 15)];
    infoArrow.image=[UIImage imageNamed:@"mediainfoarrow.png"];
    [infoArrow setHidden:YES];
    /////////////////
    
    infobar =[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 120)];
    infobar.image=[UIImage imageNamed:@"mediainfobg.png"];
    [infobar setHidden:YES];
    
    infoName = [[UILabel alloc] initWithFrame:CGRectMake(20,20,260,26)];
    infoName.font = [UIFont  fontWithName:@"HelveticaNeue-Bold" size:19.0f];
    
    [infobar addSubview:infoName];
    
    infoDescription = [[UILabel alloc] initWithFrame:CGRectMake(20,45,260,105)];
    infoDescription.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:15.0f];
    infoDescription.numberOfLines=5;
    
    [infobar addSubview:infoDescription];
    
    arrow = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 15, 20)];
    arrow.image=[UIImage imageNamed:@"mediainfoarrow.png"];
    [arrow setHidden:YES];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    [self.view setBackgroundColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1]];
    
    UIImageView *tab = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    tab.image = [UIImage imageNamed:@"choosemediabg.png"];
    
    strelica = [[UIImageView alloc]initWithFrame:CGRectMake(138, 54, 44, 10)];
    strelica.image = [UIImage imageNamed:@"bgpointer.png"];
    strelicaGumb = [[UIButton alloc]initWithFrame:CGRectMake(0, 64, 320, 48)];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognized:)];
    panRecognizer.minimumNumberOfTouches=1;
    [strelicaGumb addGestureRecognizer:panRecognizer];
    
    next = [[UIButton alloc]initWithFrame:CGRectMake(250, 0, 70, 70)];
    [next.titleLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-Bold" size:19.0f]];
    [next setTitle:@"Next" forState:UIControlStateNormal];
    [next setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.6] forState:UIControlStateHighlighted];
    [next setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.4] forState:UIControlStateNormal];
    
    
    UIButton *labela = [[UIButton alloc]initWithFrame:CGRectMake(79, 0, 150, 70)];
    [labela.titleLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-Bold" size:19.0f]];
    [labela setTitle:@"Select media" forState:UIControlStateNormal];
    
    [next addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *previous = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 60, 64)];
    [previous setImage: [UIImage imageNamed:@"back_normal.png"] forState:UIControlStateNormal];
    [previous setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [[previous imageView]setContentMode:UIViewContentModeCenter];
    [previous setAdjustsImageWhenHighlighted:NO];
    previous.imageEdgeInsets = UIEdgeInsetsMake(-7, 20, -10, -10);
    [previous addTarget:self action:@selector(previousClick:) forControlEvents:UIControlEventTouchUpInside];
    
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 34, 160, 106)];
    infoLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.text = @"Loading data";
    infoLabel.tag=1500;
    [infoLabel setHidden:YES];
    
    ////////////////////////Search bar
    searchGradient = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    searchGradient.image = [UIImage imageNamed:@"choosemediabg.png"];
    
    searchArrow = [[UIImageView alloc]initWithFrame:CGRectMake(138, 98, 44, 10)];
    searchArrow.image = [UIImage imageNamed:@"bgpointer.png"];
    
    btnSearch = [[UIButton alloc]initWithFrame:CGRectMake(12, 34, 15, 15)];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"searchicon.png"] forState:UIControlStateNormal];
    [btnSearch.titleLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-Light" size:19.0f]];
    
    txtSearch = [[UITextField alloc]initWithFrame:CGRectMake(40, 30, 250, 28)];
    txtSearch.placeholder=@"Search";
    txtSearch.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:18.0f];
    [txtSearch setTextColor:[UIColor whiteColor]];
    txtSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [txtSearch setDelegate:self];
    txtSearch.returnKeyType = UIReturnKeyDone;
    
    [btnSearch addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [searchArrow setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBegin) name:UITextFieldTextDidChangeNotification object:txtSearch];
    ///////////////////////
    
    if(arSelectedMedia.count==0){
        arSelectedMedia = [[NSMutableArray alloc]init];
    }
    else{
        [next setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1] forState:UIControlStateNormal];
        picked=YES;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(loadMedia) userInfo:nil repeats:NO];
    
    
    greyHeader = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, 320, 48)];
    greyHeader.backgroundColor=[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1];
    
    
    btnInfo = [[UIButton alloc]initWithFrame:CGRectMake(263, 66, 62, 43)];
    [btnInfo setImage:[UIImage imageNamed:@"infoicon.png"] forState:UIControlStateNormal];
    [btnInfo setImage:[UIImage imageNamed:@"infoicon_pressed.png"] forState:UIControlStateHighlighted];
    [btnInfo addTarget:self action:@selector(information:) forControlEvents:UIControlEventTouchUpInside];
    [[btnInfo imageView]setContentMode:UIViewContentModeCenter];
    [btnInfo setAdjustsImageWhenHighlighted:NO];
    btnInfo.imageEdgeInsets = UIEdgeInsetsMake(-30, -40, -30, -30);
    
    //Programabilno kreiranje collection viewa
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize=CGSizeMake(0,0);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-10) collectionViewLayout:layout];
    
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView registerClass:[MediaCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
    [_collectionView setBackgroundColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1]];
    //Long press
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5;
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan=YES;
    [_collectionView addGestureRecognizer:lpgr];
    
    [self.view addSubview:_collectionView];
    reloadFirst=YES;
    
    [self.view addSubview:greyHeader];
    [self.view addSubview:infoLabel];
    [_collectionView addSubview:infobar];
    [_collectionView addSubview:arrow];
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(refreshLabel) userInfo:nil repeats:NO];
    
    
    lbl = [[UILabel alloc]initWithFrame:CGRectMake(120, 2, 300, 170)];
    lbl.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Loading data";
    lbl.tag=1500;
    
    [self.view addSubview:infoPanel];
    [self.view addSubview:infoArrow];
    
    [self.view addSubview:searchGradient];
    [self.view addSubview:searchArrow];
    [self.view addSubview:btnSearch];
    [self.view addSubview:txtSearch];
    
    [self.view addSubview:lbl];
    [self.view addSubview:tab];
    [self.view addSubview:previous];
    [self.view addSubview:labela];
    [self.view addSubview:next];
    
    [self.view addSubview:strelica];
    [self.view addSubview:strelicaGumb];
    [self.view addSubview:btnInfo];
    
    loading = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, self.view.frame.size.height/2-10, 70, 70)];
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    loadingView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:loadingView];
    
    loadingView.alpha=0.4;
    [self.view addSubview:loading];
    [self.view setUserInteractionEnabled:NO];
    [loading startAnimating];
    
    [super viewDidLoad];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)searchHide{
    [txtSearch resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        [txtSearch setEnabled:NO];
        searchHidden=YES;
        CGRect frame = _collectionView.frame;
        frame.origin.y=100;
        _collectionView.frame=frame;
        
        frame=strelica.frame;
        frame.origin.y=54;
        strelica.frame=frame;
        
        frame=strelicaGumb.frame;
        frame.origin.y=54;
        strelicaGumb.frame=frame;
        
        frame=searchGradient.frame;
        frame.origin.y=20;
        searchGradient.frame=frame;
        
        frame=txtSearch.frame;
        frame.origin.y=30;
        txtSearch.frame=frame;
        
        frame=btnSearch.frame;
        frame.origin.y=34;
        btnSearch.frame=frame;
        
        frame=greyHeader.frame;
        frame.origin.y=64;
        greyHeader.frame=frame;
        
        frame=btnInfo.frame;
        frame.origin.y=66;
        btnInfo.frame=frame;
        
        frame=lbl.frame;
        frame.origin.y=2;
        lbl.frame=frame;
        
        frame = infoPanel.frame;
        frame.origin.y=92;
        infoPanel.frame=frame;
        
        frame = infoArrow.frame;
        frame.origin.y=93;
        infoArrow.frame=frame;
        
        timerSearch=nil;
        
        offset=1;
        txtSearch.text=@"";
        [self searchBegin];
    }];
}

- (void)searchShow{
    [UIView animateWithDuration:0.4 animations:^{
        [txtSearch setEnabled:YES];
        searchHidden=NO;
        CGRect frame = _collectionView.frame;
        frame.origin.y=144;
        _collectionView.frame=frame;
        
        frame=strelica.frame;
        frame.origin.y=98;
        strelica.frame=frame;
        frame.origin.y=64;
        frame=strelicaGumb.frame;
        frame.origin.y=98;
        strelicaGumb.frame=frame;
        
        frame=searchGradient.frame;
        frame.origin.y=64;
        searchGradient.frame=frame;
        
        frame=txtSearch.frame;
        frame.origin.y=74;
        txtSearch.frame=frame;
        
        frame=btnSearch.frame;
        frame.origin.y=78;
        btnSearch.frame=frame;
        
        frame=greyHeader.frame;
        frame.origin.y=108;
        greyHeader.frame=frame;
        
        frame=btnInfo.frame;
        frame.origin.y=110;
        btnInfo.frame=frame;
        
        frame=lbl.frame;
        frame.origin.y=46;
        lbl.frame=frame;
        
        frame = infoPanel.frame;
        frame.origin.y=136;
        infoPanel.frame=frame;
        
        frame = infoArrow.frame;
        frame.origin.y=137;
        infoArrow.frame=frame;
        
        timerSearch=nil;
    }];
}

- (void)panRecognized:(UIPanGestureRecognizer *)rec{
    CGPoint vel = [rec velocityInView:self.view];
    if(vel.y<0){
        //up
        if(timerSearch!=nil){
            return;
        }
        timerSearch = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(searchHide) userInfo:nil repeats:NO];
    }
    else{
        //down
        if(timerSearch!=nil){
            return;
        }
        timerSearch = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(searchShow) userInfo:nil repeats:NO];
    }
}

- (IBAction)information:(id)sender {
    if(infoPanel.hidden==YES){
        [btnInfo setImage:[UIImage imageNamed:@"infoicon_active.png"] forState:UIControlStateNormal];
        [self hideShowInfobars:NO];
        [self hideShowInfobarsMedia:YES];
    }
    else{
        [self hideShowInfobars:YES];
        [self hideShowInfobarsMedia:YES];
    }
}

#pragma mark Search

- (void)searchBegin{
    if(txtSearch.text.length==0){
        offset=1;
    }
    else{
        offset=0;
    }
    [self hideShowInfobars:YES];
    [self hideShowInfobarsMedia:YES];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePathMediji =[documentsDirectory stringByAppendingPathComponent:@"medijiDohvaceni.out"];
    
    NSDictionary *procitano=[NSDictionary dictionaryWithContentsOfFile:filePathMediji];
    NSArray *allMedia=[procitano objectForKey:@"data"];
    
    self.mediji = [[NSMutableArray alloc]init];
    for(NSDictionary *m in allMedia){
        if(txtSearch.text.length==0){
            [mediji addObject:m];
            continue;
        }
        NSString *imeMedija = [m objectForKey:@"name"];
        if([imeMedija rangeOfString:txtSearch.text].location == NSNotFound){
            
        }
        else{
            [mediji addObject:m];
        }
    }
    if(mediji.count==0){
        CGRect frame= lbl.frame;
        lbl.text= @"No result.";
        frame.origin.x=135;
        lbl.frame=frame;
        lbl.textColor = [UIColor redColor];
        if(timer){
            [timer invalidate];
            timer=nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(reload) userInfo:nil repeats:NO];
        
        offset=1;
        for(NSDictionary *m in allMedia){
            [mediji addObject:m];
        }
        
    }
    [_collectionView reloadData];
}

//Search button click
- (IBAction)search:(id)sender{
    txtSearch.text=@"";
    [self searchBegin];
}

//Hide search bar
- (void)hideSearch{
    if(btnSearch.hidden==NO){
        searchHidden=YES;
    }
    else{
        searchHidden=NO;
        [strelica setHidden:NO];
    }
    timer2=nil;
}

- (void)hideDelayed{
    
}

#pragma mark scrollView

//Show or hide search bar
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [txtSearch resignFirstResponder];
    if(scrollView.contentOffset.y<0){
        [scrollView setScrollEnabled:NO];
        [scrollView setContentOffset:CGPointMake(0,0)];
        [scrollView setScrollEnabled:YES];
        return;
    }
    if(scrollView.contentOffset.y>((mediji.count+3-9)*111)/3){
        [scrollView setScrollEnabled:NO];
        [scrollView setContentOffset:CGPointMake(0, ((mediji.count+3-9)*111)/3)];
        [scrollView setScrollEnabled:YES];
        return;
    }
    
    if(infoDescription.hidden==YES){
        if(scrollView.contentOffset.y>(((mediji.count+3-9)*111)/3)-25){
            return;
        }
    }
    else{
        
    }
    if(searchHidden==NO){
        if(infobar.hidden==YES){
            if(scrollView.contentOffset.y>((mediji.count+3-9)*111)/3-130){
                [scrollView setScrollEnabled:NO];
                [scrollView setContentOffset:CGPointMake(0, ((mediji.count+3-9)*111)/3-130)];
                [scrollView setScrollEnabled:YES];
                return;
            }
        }
        else{
            if(scrollView.contentOffset.y>((mediji.count+3-9)*111)/3-15){
                [scrollView setScrollEnabled:NO];
                [scrollView setContentOffset:CGPointMake(0, ((mediji.count+3-9)*111)/3-15)];
                [scrollView setScrollEnabled:YES];
                return;
            }
        }
    }
    else{
        if(infobar.hidden==YES){
            if(scrollView.contentOffset.y>((mediji.count+3-9)*111)/3-70){
                [scrollView setScrollEnabled:NO];
                [scrollView setContentOffset:CGPointMake(0, ((mediji.count+3-9)*111)/3-70)];
                [scrollView setScrollEnabled:YES];
                return;
            }
        }
        else{
            if(scrollView.contentOffset.y>((mediji.count+3-9)*111)/3-15){
                [scrollView setScrollEnabled:NO];
                [scrollView setContentOffset:CGPointMake(0, ((mediji.count+3-9)*111)/3-15)];
                [scrollView setScrollEnabled:YES];
                return;
            }
        }
    }
}

#pragma mark LoadingData

//LoadingMedia
- (void)loadMedia{
    NSDate *methodStart = [NSDate date];
    //pocetna konfiguracija za datoteke
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePathMediji =[documentsDirectory stringByAppendingPathComponent:@"medijiDohvaceni.out"];
    NSString *filePathTimeStamp = [documentsDirectory stringByAppendingPathComponent:@"timestamp_media.out"];
    
    //citanje posljednjeg timestampa za drzave
    NSString *lastTimestamp =[NSString stringWithContentsOfFile:filePathTimeStamp encoding:NSUTF8StringEncoding error:nil];
    
    //sinkrono dohvacanje podataka sa servera
    NSString *url_str = [NSString stringWithFormat:@"http://appforrest.com/colombio/api_config/get_media?sync_time=%@",lastTimestamp];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            Boolean mijenjano=true;
            NSMutableDictionary *odgovor=nil;
            
            //Ako su uspjesno dohvaceni podaci sa servera
            if(err==nil){
                odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[odgovor allKeys];
                for(NSString *key in keys){
                    //Nije mijenjan popis medija
                    if(!strcmp("s", key.UTF8String)){
                        mijenjano=false;
                        break;
                    }
                }
            }
            
            //Ako nije dobra konekcija
            else{
                [_Messages showErrorMsg:@"This app requires internet connection. Please make sure that you are connected to the internet."];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                _LoginViewController *log = (_LoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"test122"];
                [self presentViewController:log animated:YES completion:nil];
                
            }
            //Ako je mijenjan popis medija
            if(mijenjano){
                //Spremanje zadnjeg timestampa u datoteku
                NSString *changeTimestamp=[odgovor objectForKey:@"change_timestamp"];
                [changeTimestamp writeToFile:filePathTimeStamp atomically:YES encoding:NSUTF8StringEncoding error:
                 nil];
                
                [odgovor writeToFile:filePathMediji atomically:YES];
            }
            
            //Ucitavanje medija iz datoteke
            NSDictionary *procitano=[NSDictionary dictionaryWithContentsOfFile:filePathMediji];
            self.mediji=[procitano objectForKey:@"data"];
            arMediaImages = mediji;
            
            loadingView.alpha=0.4;
            [loading removeFromSuperview];
            [loadingView removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
            
            [_collectionView reloadData];
            timer=nil;
            
            NSDate *methodFinish = [NSDate date];
            NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
            NSLog(@"Time2: =%f ",executionTime);
            if(mijenjano==true){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self loadImages];
                });
            }
        });
    }];
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
        
        UIImage *imageFromURL = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link]]];
        
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
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+offset inSection:0];
        i++;
        NSArray *indexPaths = [[NSMutableArray alloc]initWithObjects:indexPath, nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadItemsAtIndexPaths:indexPaths];
        });
    }
    if(exitingView==YES){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionView reloadData];
    });
}

#pragma mark CollectionView

//Long press na jednu od celija
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [infoPanel setHidden:YES];
    [infoArrow setHidden:YES];
    [txtSearch resignFirstResponder];
    CGPoint p = [gestureRecognizer locationInView:_collectionView];
    
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:p];
    
    if(indexPath == nil){
        return;
    }
    long pozicija = (indexPath.row)+(indexPath.section*3);
    //Ako je kliknuto na +add media
    if(pozicija==0){
        return;
    }
    //Ako su prikazane celije za add media by country i by media
    else if(offset==3){
        if(pozicija==0){
            return;
        }
        else if(pozicija==1){
            return;
        }
        else if(pozicija==2){
            return;
        }
    }
    //Collection view ima viska elemenata kako bi uvijek mogao biti scrollabilan
    if(pozicija>=(mediji.count+offset)){
        return;
    }
    
    //Dodavanje infobara za odabranu celiju(prikaz)
    MediaCell *odabranaCelija = (MediaCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    infoDescription.text = [[mediji objectAtIndex:pozicija-offset]objectForKey:@"description"];
    
    infoName.text=[[mediji objectAtIndex:pozicija-offset]objectForKey:@"name"];
    
    CGRect frame = infobar.frame;
    frame.origin.x = 0;
    frame.origin.y = odabranaCelija.frame.origin.y+110;
    frame.size.width = 320;
    frame.size.height = 166;
    
    infobar.frame = frame;
    
    frame.origin.y = odabranaCelija.frame.origin.y+107;
    frame.size.height=15;
    frame.size.width=40;
    if(indexPath.row%3==0){
        frame.origin.x = 40;
    }
    else if(indexPath.row%3==1){
        frame.origin.x = 140;
    }
    else if(indexPath.row%3==2){
        frame.origin.x = 240;
    }
    arrow.frame=frame;
    
    [self hideShowInfobars:YES];
    [self hideShowInfobarsMedia:NO];
}

//Dodavanje headera u collection view
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //Kako se ne bi dvaput dodavao header, odnosno pri svakom refreshanju collection viewa
    if(started==NO){
        if(kind==UICollectionElementKindSectionHeader){
            reusableView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            if(reusableView==nil){
                reusableView=[[UICollectionReusableView alloc]initWithFrame:CGRectMake(0,-150,25,44)];
            }
            
            started=YES;
            return reusableView;
        }
    }
    if(reloadFirst==YES){
        CGRect frame = lbl.frame;
        frame.origin.x=40;
        lbl.frame=frame;
        lbl.text = @"Long tap on media for more info, drag to search.";
    }
    return reusableView;
}

- (IBAction)nottest:(id)sender{
    lbl.text= @"Selected media saved";
    lbl.textColor = [UIColor blackColor];
}

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

- (void)hideShowInfobarsMedia:(BOOL)action{
    [UIView transitionWithView:infobar duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [UIView transitionWithView:arrow duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [infobar setHidden:action];
    [arrow setHidden:action];
}

- (void)hideShowInfobars:(BOOL)action{
    [UIView transitionWithView:infoPanel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [UIView transitionWithView:infoArrow duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    if(action==YES){
        [btnInfo setImage:[UIImage imageNamed:@"infoicon.png"] forState:UIControlStateNormal];
    }
    else{
        [btnInfo setImage:[UIImage imageNamed:@"infoicon_active.png"] forState:UIControlStateNormal];
    }
    [infoPanel setHidden:action];
    [infoArrow setHidden:action];
}

- (IBAction)previousClick:(id)sender {
    [self previousView];
}

- (IBAction)nextClick:(id)sender {
    if(picked==NO){
        return;
    }
    if(arSelectedMedia.count==0){
        return;
    }
    if(self.isSettings==YES){
        
        return;
    }
    [self nextView];
}

- (void)reload {
    CGRect frame=lbl.frame;
    frame.origin.x=28;
    lbl.frame=frame;
    lbl.textColor = [UIColor blackColor];
    lbl.text = @"Long tap on media for more info, drag to search.";
    timer=nil;
}

//Refreshaj glavnu labelu pogleda
- (void)refreshLabel{
    CGRect frame = lbl.frame;
    frame.origin.x=28;
    lbl.frame=frame;
    lbl.text = @"Long tap on media for more info, drag to search.";
}

- (void)countDown {
    [_collectionView reloadData];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(reload) userInfo:nil repeats:NO];
}

//Pocetno dodavanje celija u collection view
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCell *cell = (MediaCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    //Pozicija iz collection viewa(redak i stupac) konvertirana u indeks 0,1,2,3....
    long pozicija = (indexPath.row)+(indexPath.section*3);
    
    //Skrivanje odredenih detalja iz collection viewa, zbog refreshanja celija i krivog prikazivanja
    //odredenih celija
    [cell.red1 setHidden:YES];
    [cell.red2 setHidden:YES];
    [cell.select setHidden:YES];
    [cell.notSelected setHidden:YES];
    [cell.img setHidden:YES];
    [cell.img2 setHidden:YES];
    
    //Ako se prikazuju one celije koje se nalaze nakon celija sa stvarnim podacima
    //Ove celije sluze samo da bi collection view bio scrollabilan
    if(pozicija>=(mediji.count+offset)){
        cell.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1];
        return cell;
    }
    
    //Ako je samo potrebno prikazati +add media bez by country i by media
    if(offset==1){
        if(pozicija==0){
            cell.tag=-1;
            cell.img2.image = [UIImage imageNamed:@"addmedia_normal.png"];
            [cell.img2 setHidden:NO];
            return cell;
        }
    }
    
    //Ako je potrebno prikazati + add media i add by country i by media
    else if(offset==3){
        //+Add media celija
        if(pozicija==0){
            cell.tag=-1;
            cell.img2.image = [UIImage imageNamed:@"addmedia_active.png"];
            [cell.img2 setHidden:NO];
            return cell;
        }
        //By country celija
        if(pozicija==1){
            cell.tag=-2;
            cell.img2.image = [UIImage imageNamed:@"Icon.png"];
            [cell.red1 setHidden:NO];
            [cell.red2 setHidden:NO];
            cell.red2.text=@"country";
            [cell.red2 removeFromSuperview];
            cell.red2 = [[UILabel alloc] initWithFrame:CGRectMake(19,50,70,20)];
            cell.red2.text= @"country";
            cell.red2.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:19.0f];
            [cell addSubview:cell.red2];
            return cell;
        }
        //By media celija
        if(pozicija==2){
            cell.tag=-3;
            cell.img2.image = [UIImage imageNamed:@"Icon.png"];
            [cell.red1 setHidden:NO];
            [cell.red2 setHidden:NO];
            cell.red2.text=@"media";
            [cell.red2 removeFromSuperview];
            cell.red2 = [[UILabel alloc] initWithFrame:CGRectMake(22,50,70,20)];
            cell.red2.text= @"media";
            cell.red2.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:19.0f];
            [cell addSubview:cell.red2];
            return cell;
        }
    }
    NSDictionary*m = [mediji objectAtIndex:pozicija-offset];
    NSString *urlSlike=[m objectForKey:@"name"];
    cell.tag=pozicija;
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    cell.img.image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@",documentsDirectoryPath,urlSlike,@"png"]];
    [cell.img setHidden:NO];
    //Provjeravanje da li je medij vec selektiran, jer se refreshanjem celija gube podaci
    if([arSelectedMedia containsObject:[[mediji objectAtIndex:pozicija-offset] objectForKey:@"id"]]){
        [cell.notSelected setHidden:YES];
        [cell.select setHidden:NO];
    }
    else{
        [cell.notSelected setHidden:NO];
        [cell.select setHidden:YES];
    }
    return cell;
}

//Odabrana je neka celija
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self hideShowInfobars:YES];
    [self hideShowInfobarsMedia:YES];
    
    long pozicija = (indexPath.row)+(indexPath.section*3);
    //Provjeravanje da li nije slucajno korisnik odabrao neke od
    //Prve tri celije koje sluze samo za filtriranje, a koje nisu stvarne
    //celije s medijima
    [txtSearch resignFirstResponder];
    if(offset==1&&pozicija==0){
        offset=3;
        [_collectionView reloadData];
        return;
    }
    else if(offset==3){
        if(pozicija==0){
            offset=1;
            [_collectionView reloadData];
            return;
        }
        else if(pozicija==1){
            return;
        }
        else if(pozicija==2){
            return;
        }
    }
    if(pozicija>=(mediji.count+offset)){
        return;
    }
    [txtSearch resignFirstResponder];
    
    //Ako je odabrani medij selektiran, izbrisi ga iz polja selektiranih i refreshaj pogled
    if([arSelectedMedia containsObject:[[mediji objectAtIndex:pozicija-offset] objectForKey:@"id"]]){
        NSString *poz = [[mediji objectAtIndex:pozicija-offset]objectForKey:@"id"];
        [arSelectedMedia removeObject:poz];
        CGRect frame= lbl.frame;
        lbl.text= @"Selected media removed";
        lbl.textColor = [UIColor blackColor];
        frame.origin.x=98;
        lbl.frame=frame;
        if(timer){
            [timer invalidate];
            timer=nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(countDown) userInfo:nil repeats:NO];
    }
    //Ako odabrani medij nije selektiran, dodaj ga u polje selektiranih i refreshaj pogled
    else{
        NSString *poz = [[mediji objectAtIndex:pozicija-offset]objectForKey:@"id"];
        [arSelectedMedia addObject:poz];
        CGRect frame= lbl.frame;
        lbl.text= @"Selected media saved";
        lbl.textColor = [UIColor blackColor];
        frame.origin.x=108;
        lbl.frame=frame;
        if(timer){
            [timer invalidate];
            timer=nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(countDown) userInfo:nil repeats:NO];
    }
    if(arSelectedMedia.count!=0){
        [next setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1] forState:UIControlStateNormal];
        picked=YES;
    }
    else{
        [next setTitleColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.4] forState:UIControlStateNormal];
        picked=NO;
    }
    NSArray *indexPaths = [[NSMutableArray alloc]initWithObjects:indexPath, nil];
    [_collectionView reloadItemsAtIndexPaths:indexPaths];
}

#pragma mark CollectionViewProperties

//Velicina jedne celije
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(99, 99);
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

//Ukupan broj celija, + 10 zato da ima viska prostora na dnu kako bi mogao biti scrollabilan view
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [mediji count]+offset+4;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end