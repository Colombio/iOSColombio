//
//  CreateNewsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 09/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "CreateNewsViewController.h"

@interface CreateNewsViewController ()

@end

@implementation CreateNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.tabBarItem.selectedImage  = [UIImage imageNamed:@"home_normal"];
    //[self.navigationController.tabBarController.tabBar setNeedsDisplay];
    ((UITabBarItem*)[self.tabBarController.tabBar.items objectAtIndex:2]).selectedImage =  [[UIImage imageNamed:@"home_normal" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // Do any additional setup after loading the view from its nib.
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

@end
