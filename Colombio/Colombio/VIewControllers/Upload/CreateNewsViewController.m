//
//  CreateNewsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 09/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "CreateNewsViewController.h"
#import "CustomHeaderView.h"

@interface CreateNewsViewController ()

@property (weak,nonatomic) IBOutlet CustomHeaderView *customHeader;
@property (weak,nonatomic) IBOutlet UIView *viewHolder;
@property (weak,nonatomic) IBOutlet UITextView *txtTitle;
@property (weak,nonatomic) IBOutlet UITextView *txtDescription;
@property (weak,nonatomic) IBOutlet UIView *viewImageHolder;
@property (weak,nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak,nonatomic) IBOutlet UIView *viewTagsHolder;

@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_imageHolderHeight;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_tagdHolderHeight;
@end

@implementation CreateNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.tabBarItem.selectedImage  = [[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
