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

@interface Countries : UIViewController
<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>{
    
    NSTimer *timer;
    UICollectionView *_collectionView;
    UICollectionReusableView *reusableView;
    
    bool isStatePicked;
    bool isFirstViewShown;
    bool isCollectionViewHeaderDisplayed;
}

@property (strong,nonatomic) UILabel *infoBarDescription;
//@property (strong,nonatomic) _YourInfo *reporterInfo;
@property (strong, nonatomic) UIImageView *imgInfoPlaceholder;
@property (strong, nonatomic) UIImageView *imgArrowInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblStates;
@property (strong,nonatomic) NSMutableArray *arOptions;
@property (strong,nonatomic) NSMutableArray *arSelectedRows;
@property (strong,nonatomic) NSMutableArray *arSelectedMedia;
@property (strong,nonatomic) UICollectionReusableView *reusableView;
@property (nonatomic,assign) bool isSettings;

- (IBAction)nextClick:(id)sender;

@end
