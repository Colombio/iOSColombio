//
//  UploadContainerViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 19/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UploadContainerViewController.h"
#import "DummyViewController.h"

@interface UploadContainerViewController ()

@end

@implementation UploadContainerViewController
//@synthesize viewControllersArray=_viewControllersArray;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CreateNewsViewController *vc1 = [[CreateNewsViewController alloc] init];
        vc1.delegate = self;
        DummyViewController *vc2 = [[DummyViewController alloc] init];
        DummyViewController *vc3 = [[DummyViewController alloc] init];
        NSArray *array = [[NSArray alloc] initWithObjects:vc1, vc2, vc3, nil];
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

#pragma mark Custom Delegates
- (void)navigateToVC:(PhotoLibraryViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}
@end
