//
//  Media.h
//  Colombio
//
//  Created by Colombio on 7/8/14.
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
