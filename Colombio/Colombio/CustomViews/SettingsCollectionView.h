/////////////////////////////////////////////////////////////
//
//  SettingsCollectionView.h
//  Armin Vrevic
//
//  Created by Colombio on 12/01/15.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom settings that collection views on multiple view
//  controllers use.
//
///////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "CountriesCell.h"

@protocol SettingsCollectionViewDelegate
@optional

- (void)didSelectCell:(NSIndexPath*)indexPath;
- (UICollectionViewCell *)setupCellLook:(NSIndexPath*)indexPath;

@end

@interface SettingsCollectionView : NSObject<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) id<SettingsCollectionViewDelegate>settingsCollectionViewDelegate;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSInteger numberOfCells;

- (void)addCollectionView:(UIViewController *)VC;

@end
