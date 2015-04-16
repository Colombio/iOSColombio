//
//  StartViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 22/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "StartViewController.h"
#import "CreateAccViewController.h"
#import "LoginViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnStartTapped:(id)sender{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SKIP_START"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self presentViewController:[[LoginViewController alloc] init] animated:YES completion:nil];
}

@end
