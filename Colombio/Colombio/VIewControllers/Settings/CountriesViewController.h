/////////////////////////////////////////////////////////////
//
//  Countries.h
//  Armin Vrevic
//
//  Created by Colombio on 8/8/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that implements countries listing from a web service
//  or from the countries stored locally.
//
//  It first checks for timestamp on the web, if the data
//  is not present locally it fetches all the countries, and
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
#import "MediaViewController.h"

@interface CountriesViewController : UIViewController
<UIGestureRecognizerDelegate,CustomHeaderViewDelegate,ColombioServiceCommunicatorDelegate, SettingsCollectionViewDelegate>{
    NSTimer *timer;
    IBOutlet CustomHeaderView *customHeaderView;
    Loading *loadingView;
}

@property (strong, nonatomic) SettingsCollectionView *settingsCollectionView;
@property (strong,nonatomic) UILabel *infoBarDescription;
@property (strong, nonatomic) UIImageView *imgInfoPlaceholder;
@property (strong, nonatomic) UIImageView *imgArrowInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblStates;
@property (strong,nonatomic) NSMutableArray *arOptions;
@property (strong,nonatomic) NSMutableArray *arSelectedRows;
@property (strong,nonatomic) NSMutableArray *arSelectedMedia;
@property (strong,nonatomic) IBOutlet  CustomHeaderView *customHeaderView;
@property (nonatomic,assign) bool isSettings;

@end
