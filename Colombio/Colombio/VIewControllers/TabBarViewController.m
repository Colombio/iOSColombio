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
        DummyViewController *newsDemandVC = [[DummyViewController alloc] initWithNibName:@"DummyViewController" bundle:nil];
        UINavigationController *newsDemandNavController = [[UINavigationController alloc] initWithRootViewController:newsDemandVC];
        newsDemandVC.dummyText = @"NEWS DEMAND";
        newsDemandNavController.navigationBar.hidden=YES;
        
        newsDemandVC.tabBarItem.image = [UIImage imageNamed:@"newsdemand_normal"];
        newsDemandVC.tabBarItem.selectedImage = [UIImage imageNamed:@"newsdemand_active"];
        [controllers addObject:newsDemandNavController];
        
        //TimeLine
        DummyViewController *timeLineVC = [[DummyViewController alloc] init];
        UINavigationController *timeLineNavController = [[UINavigationController alloc] initWithRootViewController:timeLineVC];
        timeLineVC.dummyText = @"TIMELINE";
        timeLineNavController.navigationBar.hidden=YES;
        
        timeLineNavController.tabBarItem.image = [UIImage imageNamed:@"timeline_normal"];
        timeLineNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"timeline_active"];
        [controllers addObject:timeLineNavController];
        
        //Home
        HomeViewController *homeVC = [[HomeViewController alloc] init];
        UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:homeVC];
        homeNavController.navigationBar.hidden=YES;
        
        homeNavController.tabBarItem.image = [UIImage imageNamed:@"home_normal"];
        //homeNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"home_active"];
        [controllers addObject:homeNavController];
        
        //MyProfile
        DummyViewController *myProfileVC = [[DummyViewController alloc] init];
        UINavigationController *myProfileNavController = [[UINavigationController alloc] initWithRootViewController:myProfileVC];
        myProfileVC.dummyText = @"MY PROFILE";
        myProfileNavController.navigationBar.hidden=YES;
        
        myProfileNavController.tabBarItem.image = [UIImage imageNamed:@"myprofile_normal"];
        myProfileNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"myprofile_active"];
        [controllers addObject:myProfileNavController];
        
        //Settings
        DummyViewController *settingsVC = [[DummyViewController alloc] init];
        UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
        settingsVC.dummyText= @"SETTINGS";
        settingsNavController.navigationBar.hidden=YES;
        
        settingsNavController.tabBarItem.image = [UIImage imageNamed:@"settings_normal"];
        settingsNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"settings_active"];
        [controllers addObject:settingsNavController];
        
        self.viewControllers = controllers;
        self.customizableViewControllers = controllers;
        [self setSelectedIndex:2];
        
        
        
        
        
    }
    return self;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [(UINavigationController*)self.viewControllers[2] popToRootViewControllerAnimated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
