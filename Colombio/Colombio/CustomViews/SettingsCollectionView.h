//
//  SettingsCollectionView.h
//  Colombio
//
//  Created by Colombio on 12/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

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
