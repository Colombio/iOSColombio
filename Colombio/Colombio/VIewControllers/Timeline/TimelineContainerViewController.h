//
//  TimelineContainerViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 24/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "ContainerViewController.h"
#import "TimelineDetailsViewController.h"

@interface TimelineContainerViewController : ContainerViewController
{
    TimelineDetailsViewController *detailsVC;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil focusOnControllerIndex:(NSInteger)index withDataArray:(NSArray*)dataArray;

@end
