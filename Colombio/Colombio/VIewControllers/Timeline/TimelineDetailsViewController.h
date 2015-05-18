//
//  TimelineDetailsViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 12/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineDetailsViewController : UIViewController


- (instancetype)init __attribute__((unavailable("use initWithTimelineDetails:")));
- (instancetype)initWithTimelineDetails:(NSArray*)timelineArray;

@end
