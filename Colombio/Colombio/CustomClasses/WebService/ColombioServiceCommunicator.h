//
//  ColombioServiceCommunicator.h
//  Colombio
//
//  Created by Vlatko Šprem on 09/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

// This class is used for API calls along with some convenience methods, like getSignedRequest.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ColombioServiceCommunicatorDelegate
@optional
- (void)didFetchNewsDemands:(NSDictionary*)result;
- (void)didFetchTags:(NSDictionary*)result;
- (void)fetchingFailedWithError:(NSError*)error;
- (void)didFetchUserDetails:(NSDictionary*)result;
- (void)didCheckUserStatus:(NSDictionary*)result;
- (void)didFetchMedia;
- (void)didFetchTimeline;
- (void)didFetchTimeLineCounterOffers:(NSDictionary*)result;
- (void)didFetchTimeLineCommunication:(NSDictionary*)result;
- (void)didFetchFavoriteMedia:(NSArray*)favMediaId;
- (void)didFetchMediaNumber:(NSString*)mediaPhoneNumber;
- (void)didFetchCountries;
- (void)didSendUserPreferences;
- (void)didFetchInfoTexts;
- (void)didSendUserDataForPayPal:(NSDictionary*)result;
- (void)didFailSendingUserDataForPayPal:(NSError*)error;

@end

@interface ColombioServiceCommunicator : NSObject

@property (strong, nonatomic) id<ColombioServiceCommunicatorDelegate> delegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableURLRequest *request;

+ (NSString*)getSignedRequest; //conveniance static method for getting data with signed request
+ (id)sharedManager;//singleton call
- (void)fetchUserProfile;
- (void)checkUserStatus;
- (void)fetchTags;
-(void)sendAsyncHttp:(NSString *)strUrl httpBody:(NSString *)strBody cache:(NSUInteger)cachePolicy timeoutInterval:(double)timeout;
- (void)fetchNewsDemands;
- (void)fetchMedia;
- (void)fetchTimeLine;
- (void)fetchTimeLineCounterOffers:(NSInteger)news_id;
- (void)fetchTimeLineCommunication:(NSInteger)news_id;
- (void)fetchFavoriteMedia;
- (void)fetchMediaPhoneNumber:(NSInteger)mediaId;
- (void)fetchCountries;
- (void)updateUserPreferences:(NSDictionary*)userDict;
- (void)fetchInfoTexts;
- (void)payoutRequest:(NSDictionary*)dictUserData;

@end

