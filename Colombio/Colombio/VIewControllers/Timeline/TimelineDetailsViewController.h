//
//  TimelineDetailsViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 12/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimelineDetailsDelegate <NSObject>

-(void)timelineDetailsProcessing;
-(void)timelineDetailsDidFinishProcessing;

@end

@interface TimelineDetailsViewController : UIViewController

@property (strong,nonatomic) id<TimelineDetailsDelegate>delegate;

- (instancetype)init __attribute__((unavailable("use initWithTimelineDetails:")));
- (instancetype)initWithTimelineDetails:(NSDictionary*)timelineArray;

@end
