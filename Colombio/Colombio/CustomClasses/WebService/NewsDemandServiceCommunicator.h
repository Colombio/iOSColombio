//
//  NewsDemandServiceCommunicator.h
//  Colombio
//
//  Created by Vlatko Šprem on 08/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewsDemandServiceCommunicatorDelegate
@optional
- (void)didFetchNewsDemands:(NSDictionary*)result;
- (void)fetchingNewsDemandsFailedWithError:(NSError*)error;
@end

@interface NewsDemandServiceCommunicator : NSObject

@property (strong, nonatomic) id<NewsDemandServiceCommunicatorDelegate> delegate;

+ (NSString*)getSignedRequest; //conveniance static method for getting data with signed request
+ (id)sharedManager;//singleton call
- (void)fetchNewsDemands;
@end
