/////////////////////////////////////////////////////////////
//
//  ScrollableHeader.h
//  Armin Vrevic
//
//  Created by Colombio on 30/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom View that acts as a horizontal scrollable header
//  that has custom pictures on it with page control
//
///////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@interface ScrollableHeader : NSObject<UIScrollViewDelegate>

- (void)addHeader:(UIView *)view self:(UIViewController *)viewController headerScroll:(UIScrollView *)scrollView viewScroll:(UIScrollView *)scrollBox;

//Save view reference to enable element adding on view
@property (strong,nonatomic) UIView *activeView;
//Save active view controller reference to enable navigation handling
@property (strong,nonatomic) UIViewController *activeVC;
//Scrollable Header scroll view
@property (strong,nonatomic) UIScrollView *_scrollView;
//Whole view scroll view
@property (strong,nonatomic) UIScrollView *_scrollBox;
@property (nonatomic,assign) BOOL pageControlBeingUsed;
@property (nonatomic,assign) NSInteger lastPage;
@property (nonatomic,strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic,strong) NSArray *pageImages;
@property (nonatomic,strong) NSMutableArray *pageViews;
@property (nonatomic,assign) int viewWidth;

@end
