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

#import "DummyViewController.h"

@interface TabBarViewController ()

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
- (instancetype)init{
    self = [super init];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    if (self) {
        self.tabBarController.delegate=self;
        //NewsDemand
        NewsDemandViewController *newsDemandVC = [[NewsDemandViewController alloc] initWithNibName:@"NewsDemandViewController" bundle:nil];
        UINavigationController *newsDemandNavController = [[UINavigationController alloc] initWithRootViewController:newsDemandVC];
        newsDemandNavController.navigationBar.hidden=YES;
        
        newsDemandVC.tabBarItem.image = [[UIImage imageNamed:@"newsdemand_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        newsDemandVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"newsdemand_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [controllers addObject:newsDemandNavController];
        
        //TimeLine
        TimelineViewController *timeLineVC = [[TimelineViewController alloc] init];
        UINavigationController *timeLineNavController = [[UINavigationController alloc] initWithRootViewController:timeLineVC];
        timeLineNavController.navigationBar.hidden=YES;
        
        timeLineNavController.tabBarItem.image = [[UIImage imageNamed:@"timeline_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        timeLineNavController.tabBarItem.selectedImage = [[UIImage imageNamed:@"timeline_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [controllers addObject:timeLineNavController];
        
        //Home
        HomeViewController *homeVC = [[HomeViewController alloc] init];
        UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:homeVC];
        homeNavController.navigationBar.hidden=YES;
        
        homeNavController.tabBarItem.image = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        homeNavController.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [controllers addObject:homeNavController];
        
        //MyProfile
        DummyViewController *myProfileVC = [[DummyViewController alloc] init];
        UINavigationController *myProfileNavController = [[UINavigationController alloc] initWithRootViewController:myProfileVC];
        myProfileVC.dummyText = @"MY PROFILE";
        myProfileNavController.navigationBar.hidden=YES;
        
        myProfileNavController.tabBarItem.image = [[UIImage imageNamed:@"myprofile_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        myProfileNavController.tabBarItem.selectedImage = [[UIImage imageNamed:@"myprofile_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [controllers addObject:myProfileNavController];
        
        //Settings
        DummyViewController *settingsVC = [[DummyViewController alloc] init];
        UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
        settingsVC.dummyText= @"SETTINGS";
        settingsNavController.navigationBar.hidden=YES;
        
        settingsNavController.tabBarItem.image = [[UIImage imageNamed:@"settings_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        settingsNavController.tabBarItem.selectedImage = [[UIImage imageNamed:@"settings_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [controllers addObject:settingsNavController];
        
        self.viewControllers = controllers;
        self.customizableViewControllers = controllers;
        [self setSelectedIndex:2];
        
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
