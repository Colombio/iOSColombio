//
//  Media.h
//  Colombio
//
//  Created by Colombio on 7/8/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate, UITextFieldDelegate>{
    UICollectionView *_collectionView;
    NSMutableArray *arSelectedRows;
    NSMutableArray *arSelectedMedia;
    NSMutableArray *mediji;
    
    UIImageView *infobar;
    UIImageView *arrow;
    UIImageView *strelica;
    NSTimer *timer;
    UILabel *lbl;
    bool started;
    UICollectionReusableView *reusableView;
    NSTimer *reloadTimer;
    bool reloadFirst;
    UILabel *infoLabel;
    unsigned int offset;
    NSString *searchText;
    unsigned int counter;
    bool hidden;
    
    UIButton *btnSearch;
    UITextField *txtSearch;
    UIImageView *searchGradient;
    UIImageView *searchArrow;
    UILabel *infoName;
    UILabel *infoDescription;
    
    UIImageView *infoPanel;
    UIImageView *infoArrow;
    UILabel *infoPanelDescription;
    
    bool searchHidden;
    bool picked;
    UIButton *next;
    NSTimer *timer2;
    UIButton *btnInfo;
    float lastPosition;
    UIButton *strelicaGumb;
    UIImageView *greyHeader;
    NSTimer *timerSearch;
    UIActivityIndicatorView *loading;
    UIView *loadingView;
    NSMutableArray *arMediaImages;
    
    bool exitingView;
    
    _YourInfo *reporterInfo;
}

@property (strong, nonatomic) UILabel *infoDescription;
@property (strong, nonatomic) UILabel *infoName;
@property (nonatomic) CGFloat lastContentOffset;
@property (strong,nonatomic) UIButton *btnSearch;
@property (strong,nonatomic) UITextField *txtSearch;
@property (strong,nonatomic) UIImageView *searchGradient;
@property (strong,nonatomic) UIImageView *searchArrow;
@property (strong,nonatomic) UILabel *infoLabel;
@property (strong,nonatomic) UICollectionReusableView *reusableView;
@property (nonatomic,assign) bool started;
@property (strong,nonatomic) UILabel *lbl;
@property (strong,nonatomic) UIImageView *arrow;
@property (strong,nonatomic) UIImageView *strelica;
@property (strong,nonatomic) UIImageView *infoPanel;
@property (strong,nonatomic) UIImageView *infoArrow;
@property (strong,nonatomic) UILabel *infoPanelDescription;
@property (strong,nonatomic) UIImageView *infobar;
@property (strong,nonatomic) NSArray  *mediji;
@property (strong,nonatomic) NSMutableArray *arSelectedRows;
@property (strong,nonatomic) NSMutableArray *arSelectedMedia;
@property (strong,nonatomic) Home *homeViewController;
@property (strong,nonatomic) Settings *settingsViewController;
@property (strong,nonatomic) TimeLine *timeLineViewController;
@property (strong,nonatomic) NSArray *polje;
@property (strong,nonatomic) _YourInfo *reporterInfo;
@property (nonatomic,assign) bool isSettings;

@end
