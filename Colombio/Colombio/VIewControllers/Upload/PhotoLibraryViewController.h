//
//  PhotoLibraryViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 16/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHeaderView.h"

@interface PhotoLibraryViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,CustomHeaderViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIViewController *caller;

- (instancetype)initWithSelectedAssets:(NSMutableArray*)selectedAssets;
@end
