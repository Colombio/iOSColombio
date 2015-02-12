/////////////////////////////////////////////////////////////
//
//  SettingsCollectionView.m
//  Armin Vrevic
//
//  Created by Colombio on 12/01/15.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom settings that collection views on multiple view
//  controllers use.
//
///////////////////////////////////////////////////////////////

#import "SettingsCollectionView.h"

@implementation SettingsCollectionView

@synthesize collectionView;
@synthesize numberOfCells;

/**
 *  Method that adds collection view to selected view controller
 *
 *  @param VC "View controller that will use these settings"
 *
 */
- (void)addCollectionView:(UIViewController *)VC{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize=CGSizeMake(100,0);
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, VC.view.frame.size.width, VC.view.frame.size.height-10) collectionViewLayout:layout];
    collectionView.bounces=NO;
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView registerClass:[CountriesCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [VC.view addSubview:collectionView];
    [collectionView reloadData];
    [VC.view sendSubviewToBack:collectionView];
}

/**
 *  Adding cells to collection view. It delegates
 *  the event to view controller that uses these settings
 *
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.settingsCollectionViewDelegate setupCellLook:indexPath];
}

/**
 *  Event that occurs on selecting one cells. It delegates
 *  the event to view controller that uses these settings
 *
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.settingsCollectionViewDelegate didSelectCell:indexPath];
}

/**
 *  Total number of cells
 *
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return numberOfCells;
}

/**
 *  One cell size
 *
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(300, 44);
}

/**
 *  Space between cells
 *
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

/**
 *  Space between cells
 *
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1.5;
}

/**
 *  Padding
 *
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
