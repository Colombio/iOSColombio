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
{
    CLLocationManager *locationManager;
}


@property (strong, nonatomic) id<ColombioServiceCommunicatorDelegate> delegate;

+(id)sharedManager;
//- (void)fetchNewsDemands;
@end

