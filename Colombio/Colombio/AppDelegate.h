//
//  AppDelegate.h
//  Colombio
//
//  Created by Colombio on 6/14/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Database.h"
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ColombioServiceCommunicator.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, ColombioServiceCommunicatorDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) Database *db;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSCache *mediaImages;

@property (strong, nonatomic) NSDictionary *dicMediaTypes;
@property (strong, nonatomic) NSDictionary *dicTimelineButt;

@property (assign, nonatomic) BOOL appIsActive;



+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end
