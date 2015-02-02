//
//  UploadNewsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 02/02/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UploadNewsViewController.h"

@interface UploadNewsViewController ()

@property (weak, nonatomic) IBOutlet UITextView *txtDidYouKnow;
@property (weak, nonatomic) IBOutlet UIImageView *imgLoading;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadPercengate;
@property (weak, nonatomic) IBOutlet UILabel *lblUploading;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadCount;

@end

@implementation UploadNewsViewController

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

@end
