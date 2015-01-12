//
//  Countries.h
//  colombio
//
//  Created by Colombio on 8/8/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

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
//@property (strong,nonatomic) _YourInfo *reporterInfo;
@property (strong, nonatomic) UIImageView *imgInfoPlaceholder;
@property (strong, nonatomic) UIImageView *imgArrowInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblStates;
@property (strong,nonatomic) NSMutableArray *arOptions;
@property (strong,nonatomic) NSMutableArray *arSelectedRows;
@property (strong,nonatomic) NSMutableArray *arSelectedMedia;
@property (strong,nonatomic) IBOutlet  CustomHeaderView *customHeaderView;
@property (nonatomic,assign) bool isSettings;

@end
