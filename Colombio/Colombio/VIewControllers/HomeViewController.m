//
//  HomeViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 07/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "HomeViewController.h"
#import "CreateNewsViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark Button Action
- (void)btnPhotoClicked:(id)sender{

}

- (void)btnSendClicked:(id)sender{
    [self.navigationController pushViewController:[[CreateNewsViewController alloc] init] animated:YES];
}

- (void)btnAlertClicked:(id)sender{

}

- (void)btnCommunityClicked:(id)sender{

}

- (void)btnAnnounceClicked:(id)sender{

}

- (void)btnCallClicked:(id)sender{

}


@end
