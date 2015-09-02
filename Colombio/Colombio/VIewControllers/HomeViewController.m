//
//  HomeViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 07/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "HomeViewController.h"
#import "CreateNewsViewController.h"
#import "UploadContainerViewController.h"
#import "ContainerViewController.h"
#import "Messages.h"
#import "DummyViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ColombioServiceCommunicator.h"
#import "Tools.h"
#import "SimpleMediaSelectViewController.h"
#import "NewsDemandServiceCommunicator.h"
#import "TimelineServiceCommunicator.h"
#import "TutorialView.h"


enum UploadType{
    PHOTO_VIDEO = 1,
    NEWS=2,
    STORY_TIP=3,
    COMMUNITY_NEWS=4,
    ANNOUNCED_EVENT=5
};
@interface HomeViewController ()<ColombioServiceCommunicatorDelegate, NewsDemandServiceCommunicatorDelegate, TimelineServiceCommunicatorDelegate, TutorialViewDelegate>
{
    TutorialView *tutorialView;
}
@end

@implementation HomeViewController

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SHOW_TUTORIAL] boolValue] && [[[NSUserDefaults standardUserDefaults] objectForKey:TUTORIAL2] boolValue]) {
        tutorialView = [[TutorialView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andTutorialSet:2];
        tutorialView.imgTutorial.image = [UIImage imageNamed:@"tut2"];
        self.tabBarController.tabBar.userInteractionEnabled=NO;
        tutorialView.delegate = self;
        [self.view addSubview:tutorialView];
    }
    
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NewsDemandServiceCommunicator *newsSC = [NewsDemandServiceCommunicator sharedManager];
    newsSC.delegate=self;
    [newsSC fetchNewsDemands];
    
    TimelineServiceCommunicator *timeSC = [TimelineServiceCommunicator sharedManager];
    timeSC.timelineDelegate = self;
    [timeSC fetchTimeLine];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Button Action
- (void)btnPhotoClicked:(id)sender{
    
    UploadContainerViewController *containerVC = [[UploadContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil isNewsDemand:NO forType:PHOTO_VIDEO];
    [self.navigationController pushViewController:containerVC animated:YES];
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)btnSendClicked:(id)sender{
    //[self.navigationController pushViewController:[[CreateNewsViewController alloc] init] animated:YES];
    
    UploadContainerViewController *containerVC = [[UploadContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil isNewsDemand:NO forType:NEWS];
    [self.navigationController pushViewController:containerVC animated:YES];
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)btnAlertClicked:(id)sender{
    UploadContainerViewController *containerVC = [[UploadContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil isNewsDemand:NO forType:STORY_TIP];
    [self.navigationController pushViewController:containerVC animated:YES];
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)btnCommunityClicked:(id)sender{
    UploadContainerViewController *containerVC = [[UploadContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil isNewsDemand:NO forType:COMMUNITY_NEWS];
    [self.navigationController pushViewController:containerVC animated:YES];
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)btnAnnounceClicked:(id)sender{
    UploadContainerViewController *containerVC = [[UploadContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil isNewsDemand:NO forType:ANNOUNCED_EVENT];
    [self.navigationController pushViewController:containerVC animated:YES];
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)btnCallClicked:(id)sender{
    SimpleMediaSelectViewController *simpleMediaVC = [[SimpleMediaSelectViewController alloc] initForCallMedia:YES];
    [self.navigationController pushViewController:simpleMediaVC animated:YES];
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


#pragma mark Test

- (IBAction)btnLogOff:(id)sender{
    NSString *result = [ColombioServiceCommunicator getSignedRequest];
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_user_managment/mau_logout/", BASE_URL] httpBody:[NSString stringWithFormat:@"signed_req=%@",result]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    
        if(error){
            [Messages showErrorMsg:@"error_web_request"];
        }
        
        //Request is successfuly sent
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [appdelegate.db clearTable:@"USER"];
                [appdelegate.db clearTable:@"USER_CASHOUT"];
                //[appdelegate.db clearTable:@"NEWSDEMANDLIST"];
                [appdelegate.db clearTable:@"UPLOAD_DATA"];
                //[appdelegate.db clearTable:@"MEDIA_LIST"];
                //[appdelegate.db clearTable:@"SELECTED_MEDIA"];
                //[appdelegate.db clearTable:@"COUNTRIES_LIST"];
                //[appdelegate.db clearTable:@"SELECTED_COUNTRIES"];
                appdelegate.window.rootViewController = [[LoginViewController alloc] init];
                [appdelegate.window makeKeyAndVisible];
            });
            
        }
    }];
    
}

#pragma mark CSC delegate
- (void)didFetchMedia{
    dispatch_async(dispatch_get_main_queue(), ^{
        ColombioServiceCommunicator *colombioSC = [ColombioServiceCommunicator sharedManager];
        colombioSC.delegate=self;
        [colombioSC fetchNewsDemands];
    });
    
}

- (void)didFetchNewsDemands:(NSDictionary *)result{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNewsDemandBadge];
    });
    
}
- (void)setNewsDemandBadge{
    NSInteger count = [Tools getNumberOfNewDemands];
    if (count>0) {
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld",(long)count]];
    }else{
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
    }
}

- (void)didFetchTimeline{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setTimelineBadge];
    });
}

- (void)setTimelineBadge{
    if ([Tools checkForNewNotification]) {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"!"];
    }else{
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
    }
}

#pragma mark TutorialView
- (void)tutorialTapped{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:SHOW_TUTORIAL] boolValue] || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"TUTORIAL2"] boolValue]){
        self.tabBarController.tabBar.userInteractionEnabled=YES;
    }
}
@end
