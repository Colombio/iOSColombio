//
//  NewsDemandContainerViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 29/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "ContainerViewController.h"
#import "NewsDemandDetailsViewController.h"

@interface NewsDemandContainerViewController : ContainerViewController<NewsDemandDetailsDelegate>
{
    NewsDemandDetailsViewController *detailsVC;
}

@property (strong, nonatomic) NSArray *newsDemandArray;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil focusOnControllerIndex:(NSInteger)index withDataArray:(NSArray*)dataArray;
@end
