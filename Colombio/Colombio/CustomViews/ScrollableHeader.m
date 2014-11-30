//
//  ScrollableHeader.m
//  Colombio
//
//  Created by Colombio on 30/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "ScrollableHeader.h"

@implementation ScrollableHeader

- (void)addTabBar:(UIView *)view self:(UIViewController *)viewController activeView:(int)activeView{
    
    selfView = view;
    NSString *imageDemand = @"newsdemand_normal.png";
    NSString *imageHome = @"home_normal.png";
    NSString *imageTimeline = @"timeline_normal.png";
    NSString *imageMyProfile = @"myprofile_normal.png";
    NSString *imageSettings = @"settings_normal.png";
    
    switch (activeView) {
        case 1:
            imageDemand = @"newsdemand_active.png";
            break;
        case 2:
            imageTimeline = @"timeline_active.png";
            break;
        case 3:
            imageHome = @"home_active.png";
            break;
        case 4:
            imageMyProfile = @"myprofile_active.png";
            break;
        case 5:
            imageSettings = @"settings_active.png";
            break;
    }
    
    vc=viewController;
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    CGFloat screenHeight = screenBounds.size.height;
    CGFloat screenWidth = screenBounds.size.width;
    
    newsDemand = [[UIButton alloc]initWithFrame:CGRectMake(0+6, screenHeight-45, 44, 44)];
    [newsDemand setBackgroundImage:[UIImage imageNamed:imageDemand] forState:UIControlStateNormal];
    [newsDemand setBackgroundImage:[UIImage imageNamed:@"newsdemand_pressed.png"] forState:UIControlStateHighlighted];
    
    UIButton *timeLine = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/5+6, screenHeight-45, 44, 44)];
    [timeLine setBackgroundImage:[UIImage imageNamed:imageTimeline] forState:UIControlStateNormal];
    [timeLine setBackgroundImage:[UIImage imageNamed:@"timeline_pressed.png"] forState:UIControlStateHighlighted];
    
    UIButton *home = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2.5f+12, screenHeight-45, 44, 44)];
    [home setBackgroundImage:[UIImage imageNamed:imageHome] forState:UIControlStateNormal];
    [home setBackgroundImage:[UIImage imageNamed:@"home_pressed.png"] forState:UIControlStateHighlighted];
    
    UIButton *myProfile = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/1.66f+12, screenHeight-45, 44, 44)];
    [myProfile setBackgroundImage:[UIImage imageNamed:imageMyProfile] forState:UIControlStateNormal];
    [myProfile setBackgroundImage:[UIImage imageNamed:@"myprofile_pressed.png"] forState:UIControlStateHighlighted];
    
    UIButton *settings = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/1.25f+12, screenHeight-45, 44, 44)];
    [settings setBackgroundImage:[UIImage imageNamed:imageSettings] forState:UIControlStateNormal];
    [settings setBackgroundImage:[UIImage imageNamed:@"settings_pressed.png"] forState:UIControlStateHighlighted];
    
    UIImageView *tab = [[UIImageView alloc]initWithFrame:CGRectMake(0, screenHeight-55, screenWidth, 85)];
    tab.image = [UIImage imageNamed:@"tabbar.png"];
    
    [home addTarget:self action:@selector(homeClick:) forControlEvents:UIControlEventTouchUpInside];
    [newsDemand addTarget:self action:@selector(newsDemandClick:) forControlEvents:UIControlEventTouchUpInside];
    [myProfile addTarget:self action:@selector(myProfileClick:) forControlEvents:UIControlEventTouchUpInside];
    [timeLine addTarget:self action:@selector(timeLineClick:) forControlEvents:UIControlEventTouchUpInside];
    [settings addTarget:self action:@selector(settingsClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:tab];
    [view addSubview:newsDemand];
    [view addSubview:myProfile];
    [view addSubview:home];
    [view addSubview:timeLine];
    [view addSubview:settings];
    [self setNewsDemandBadge:view];
}

@end
