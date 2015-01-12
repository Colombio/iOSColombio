//
//  SettingsCollectionView.m
//  Colombio
//
//  Created by Colombio on 12/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SettingsCollectionView.h"

@implementation SettingsCollectionView

@synthesize collectionView;

- (void)addCollectionView:(UIViewController *)VC{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize=CGSizeMake(100,0);
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 66, VC.view.frame.size.width, VC.view.frame.size.height-10) collectionViewLayout:layout];
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    [collectionView setDataSource:VC];
    [collectionView setDelegate:VC];
    [collectionView registerClass:[CountriesCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [VC.view addSubview:collectionView];
    [collectionView reloadData];
    [VC.view sendSubviewToBack:collectionView];
}

//Velicina jedne celije
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(300, 44);
}

//Razmak izmedu celija
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

//Razmak izmedu celija
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1.5;
}

//Padding od rubova
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
