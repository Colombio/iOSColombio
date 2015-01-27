//
//  UploadContainerViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 19/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UploadContainerViewController.h"


@interface UploadContainerViewController ()

@property (assign, nonatomic) BOOL isNewsDemand;
@end



@implementation UploadContainerViewController
//@synthesize viewControllersArray=_viewControllersArray;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isNewsDemand:(BOOL)isNewsDemand{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isNewsDemand = isNewsDemand;
        contentVC = [[CreateNewsViewController alloc] init];
        contentVC.delegate = self;
        dummyVC = [[DummyViewController alloc] init];
        NSArray *array;
        if (!isNewsDemand) {
            mediaVC = [[NewsMediaViewController alloc] init];
            array = [[NSArray alloc] initWithObjects:contentVC, mediaVC, dummyVC, nil];
        }else{
            array = [[NSArray alloc] initWithObjects:contentVC, dummyVC, nil];
        }
        super.viewControllersArray = array;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectedImageAction:(NSMutableArray *)selectedImagesArray{
    contentVC.selectedImagesArray = selectedImagesArray;
    [contentVC loadImages];
}

#pragma mark Custom Delegates
- (void)navigateToVC:(PhotoLibraryViewController *)viewController{
    viewController.caller = self;
    [self presentViewController:viewController animated:YES completion:nil];
}
@end
