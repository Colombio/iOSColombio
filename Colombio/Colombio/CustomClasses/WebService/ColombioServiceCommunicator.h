//
//  ColombioServiceCommunicator.h
//  Colombio
//
//  Created by Vlatko Šprem on 09/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ColombioServiceCommunicatorDelegate
@optional
- (void)didFetchNewsDemands:(NSDictionary*)result;
- (void)fetchingFailedWithError:(NSError*)error;

@end

@interface ColombioServiceCommunicator : NSObject

@property (strong, nonatomic) id<ColombioServiceCommunicatorDelegate> delegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableURLRequest *request;

+(id)sharedManager;
-(void)sendAsyncHttp:(NSString *)strUrl httpBody:(NSString *)strBody cache:(NSUInteger)cachePolicy timeoutInterval:(double)timeout;
//- (void)fetchNewsDemands;

@end

