//
//  TabBarViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 08/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TabBarViewController.h"
#import "HomeViewController.h"
#import "Tools.h"
#import "NewsDemandViewController.h"
#import "TimelineViewController.h"
#import "SettingsViewController.h"
#import "UserProfileViewController.h"

#import "DummyViewController.h"

@interface TabBarViewController ()

@property (strong, nonatomic) NSDictionary *userInfo;
@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (instancetype)initWithUserInfo:(NSDictionary*)userInfo{
    self = [super init];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    if (self) {
        self.tabBarController.delegate=self;
        //NewsDemand
        //NewsDemandViewController *newsDemandVC = [[NewsDemandViewController alloc] initWithNibName:@"NewsDemandViewController" bundle:nil];
        NewsDemandViewController *newsDemandVC;
        if (userInfo[@"payload"][@"did"])
        {
            newsDemandVC = [[NewsDemandViewController alloc] initWithNotification:userInfo];
            
        }else
        {
            newsDemandVC = [[NewsDemandViewController alloc] initWithNotification:nil];
        }
        
        UINavigationController *newsDemandNavController = [[UINavigationController alloc] initWithRootViewController:newsDemandVC];
        newsDemandNavController.navigationBar.hidden=YES;
        
        newsDemandVC.tabBarItem.image = [[UIImage imageNamed:@"newsdemand_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        newsDemandVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"newsdemandtransp_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        newsDemandVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        newsDemandVC.title=nil;
        [controllers addObject:newsDemandNavController];
        
        //TimeLine
        TimelineViewController *timeLineVC;
        if (userInfo[@"payload"][@"nid"])
        {
            timeLineVC = [[TimelineViewController alloc] initWithNotification:userInfo];
            
        }else
        {
            timeLineVC = [[TimelineViewController alloc] initWithNotification:nil];
        }
    
        UINavigationController *timeLineNavController = [[UINavigationController alloc] initWithRootViewController:timeLineVC];
        timeLineNavController.navigationBar.hidden=YES;
        
        timeLineNavController.tabBarItem.image = [[UIImage imageNamed:@"timeline_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        timeLineNavController.tabBarItem.selectedImage = [[UIImage imageNamed:@"timeline_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        timeLineNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        timeLineNavController.title=nil;
        [controllers addObject:timeLineNavController];
        
        //Home
        HomeViewController *homeVC = [[HomeViewController alloc] init];
        UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:homeVC];
        homeNavController.navigationBar.hidden=YES;
        
        homeNavController.tabBarItem.image = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        homeNavController.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        homeNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        homeNavController.title=nil;
        [controllers addObject:homeNavController];
        
        //MyProfile
        UserProfileViewController *myProfileVC = [[UserProfileViewController alloc] init];
        UINavigationController *myProfileNavController = [[UINavigationController alloc] initWithRootViewController:myProfileVC];
        myProfileNavController.navigationBar.hidden=YES;
        
        myProfileNavController.tabBarItem.image = [[UIImage imageNamed:@"myprofile_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        myProfileNavController.tabBarItem.selectedImage = [[UIImage imageNamed:@"myprofile_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        myProfileNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        myProfileNavController.title=nil;
        [controllers addObject:myProfileNavController];
        
        //Settings
        SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
        UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
        settingsNavController.navigationBar.hidden=YES;
        
        settingsNavController.tabBarItem.image = [[UIImage imageNamed:@"settings_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        settingsNavController.tabBarItem.selectedImage = [[UIImage imageNamed:@"settings_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        settingsNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        settingsNavController.title=nil;
        [controllers addObject:settingsNavController];
        
        self.viewControllers = controllers;
        self.customizableViewControllers = controllers;
        if (userInfo) {
            if (userInfo[@"payload"][@"did"])
            {
                [self setSelectedIndex:0];
            }else{
                [self setSelectedIndex:1];
            }
            
        }else{
            [self setSelectedIndex:2];
        }
        
        
        [[UITabBar appearance] setTintColor:[UIColor blackColor]];
        [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
    }
    return self;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [(UINavigationController*)self.viewControllers[2] popToRootViewControllerAnimated:NO];
    if (self.selectedIndex==2) {
        ((UITabBarItem*)[self.tabBar.items objectAtIndex:2]).selectedImage =  [[UIImage imageNamed:@"home_active" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }}

@end
