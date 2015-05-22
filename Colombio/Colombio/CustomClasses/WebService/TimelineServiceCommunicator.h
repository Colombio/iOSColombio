//
//  TimelineServiceCommunicator.h
//  Colombio
//
//  Created by Vlatko Šprem on 20/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimelineServiceCommunicatorDelegate
@optional

- (void)didFetchTimeline;
- (void)fetchingFailedWithError:(NSError*)error;

@end

@interface TimelineServiceCommunicator : NSObject

@property (strong, nonatomic) id<TimelineServiceCommunicatorDelegate> timelineDelegate;

+ (NSString*)getSignedRequest; //conveniance static method for getting data with signed request
+ (id)sharedManager;//singleton call
- (void)fetchTimeLine;

@end
