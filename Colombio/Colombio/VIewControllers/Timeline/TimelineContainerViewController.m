//
//  TimelineContainerViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 24/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimelineContainerViewController.h"

@interface TimelineContainerViewController ()<TimelineDetailsDelegate>

@end

@implementation TimelineContainerViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil focusOnControllerIndex:(NSInteger)index withDataArray:(NSArray*)dataArray{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil focusOnControllerIndex:index withSingleTitle:YES];
    if (self) {
        NSMutableArray *tArray = [[NSMutableArray alloc] init];
        for (NSDictionary *tDict in dataArray) {
            detailsVC = [[TimelineDetailsViewController alloc] initWithTimelineDetails:tDict];
            detailsVC.delegate = self;
            [tArray  addObject:detailsVC];
        }
        super.viewControllersArray =tArray;
    }
    return self;
}

- (void)timelineDetailsDidFinishProcessing{
    self.view.userInteractionEnabled=YES;
}

- (void)timelineDetailsProcessing{
    self.view.userInteractionEnabled=NO;
}
- (void)viewDidLoad {
    super.flexibleHeader=NO;
    super.staticHeader=YES;
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)btnBack:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
