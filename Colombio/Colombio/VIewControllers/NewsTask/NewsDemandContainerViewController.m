//
//  NewsDemandContainerViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 29/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "NewsDemandContainerViewController.h"
#import "NewsDemandObject.h"
#import "UploadContainerViewController.h"

@interface NewsDemandContainerViewController ()

@end

@implementation NewsDemandContainerViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil focusOnControllerIndex:(NSInteger)index withDataArray:(NSArray*)dataArray{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil focusOnControllerIndex:index withSingleTitle:YES];
    if (self) {
        NSMutableArray *tArray = [[NSMutableArray alloc] init];
        for (NewsDemandObject *object in dataArray) {
            detailsVC = [[NewsDemandDetailsViewController alloc] initWithNibName:@"NewsDemandDetailsViewController" bundle:nil withNewsDemand:object];
            [tArray  addObject:detailsVC];
        }
        super.viewControllersArray =tArray;
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

#pragma mark NewsDemandDetailsDelegate
- (void)newsDemandIsSelected:(NewsDemandObject*)newsDemandData{
    UploadContainerViewController *uploadVC = [[UploadContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil forNewsDemandData:newsDemandData isNewsDemand:YES];
    [self.navigationController pushViewController:uploadVC animated:YES];
}

@end
