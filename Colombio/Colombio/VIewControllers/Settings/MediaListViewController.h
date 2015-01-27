//
//  MediaListViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 25/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Messages.h"
#import "CountriesCell.h"
#import "CustomHeaderView.h"
#import "Loading.h"
#import "ColombioServiceCommunicator.h"
#import "Tools.h"
#import "SettingsCollectionView.h"

@interface MediaListViewController : UIViewController<UIGestureRecognizerDelegate,CustomHeaderViewDelegate,ColombioServiceCommunicatorDelegate, SettingsCollectionViewDelegate>
{
    Loading *loadingView;
    NSMutableArray *imagesLoaded;
}
@property (strong,nonatomic) NSMutableArray *arSelectedMedia;
@property (strong,nonatomic) NSArray  *arMediaImages;
@property (strong, nonatomic) SettingsCollectionView *settingsCollectionView;
@property (strong,nonatomic) NSArray  *media;

@end
