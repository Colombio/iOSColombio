/////////////////////////////////////////////////////////////
//
//  MediaViewController.h
//  Armin Vrevic
//
//  Created by Colombio on 7/8/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that implements media listing from a web service
//  or from the media stored locally.
//
//  It first checks for timestamp on the web, if the data
//  is not present locally it fetches all the media, and
//  presents it in a collection view, then for performance
//  optimizing, it loads picture one by one from web service.
//
//  If the data is cached on the device, it loads data from
//  inner device memory
//
///////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "Messages.h"
#import "Localized.h"
#import "CountriesCell.h"
#import "CustomHeaderView.h"
#import "Tools.h"
#import "Loading.h"
#import "ColombioServiceCommunicator.h"
#import "SettingsCollectionView.h"
#import "LoginViewController.h"
#import "CountriesViewController.h"
#import "TabBarViewController.h"

@interface MediaViewController : UIViewController<UIGestureRecognizerDelegate,CustomHeaderViewDelegate,ColombioServiceCommunicatorDelegate, SettingsCollectionViewDelegate>{
    NSTimer *timer;
    IBOutlet CustomHeaderView *customHeaderView;
    Loading *loadingView;
    BOOL exitingView;
    NSMutableArray *imagesLoaded;
}

@property (strong, nonatomic) SettingsCollectionView *settingsCollectionView;
@property (strong,nonatomic) NSArray  *mediji;
@property (strong,nonatomic) NSArray  *arMediaImages;
@property (strong,nonatomic) NSMutableArray *arSelectedRows;
@property (strong,nonatomic) NSMutableArray *arSelectedMedia;
@property (strong,nonatomic) NSArray *polje;

@end
