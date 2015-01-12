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

- (void)didSelectCell;
- (void)setupCellLook;

@end

@interface SettingsCollectionView : NSObject<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet id<SettingsCollectionViewDelegate>settingsCollectionViewDelegate;
@property (strong, nonatomic) UICollectionView *collectionView;

@end
