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


enum UploadType{
    PHOTO_VIDEO = 1,
    NEWS=2,
    STORY_TIP=3,
    COMMUNITY_NEWS=4,
    ANNOUNCED_EVENT=5
};
@interface HomeViewController ()<ColombioServiceCommunicatorDelegate>

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
    ColombioServiceCommunicator *colombioSC = [ColombioServiceCommunicator sharedManager];
    colombioSC.delegate=self;
    //[colombioSC fetchMedia];
    [colombioSC fetchNewsDemands];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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

}


#pragma mark Test

- (IBAction)btnLogOff:(id)sender{
    NSString *result = [ColombioServiceCommunicator getSignedRequest];
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_user_managment/mau_logout/", BASE_URL] httpBody:[NSString stringWithFormat:@"signed_req=%@",result]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
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
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",count]];
    }else{
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
    }
}


@end
