//
//  ContainerViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 13/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//
//  This class is used as superclass for swipe like navigation. Each subclass has to be implemented specifically (check already implemented - UploadContainerViewController)

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *viewControllersArray;
@property (strong, nonatomic) NSString *nextButtonTitle;//sets textual NEXT button
@property (strong, nonatomic) UIImage *imgNextBtnNormal;//sets NEXT button image if text length = 0
@property (strong, nonatomic) UIImage *imgNextBtnPressed;//sets NEXT button image if text length = 0
@property (strong, nonatomic) UIButton *btnBack;
@property (assign, nonatomic) BOOL isSingleTitle;
@property (strong, nonatomic) NSString *lastNextBtnText;
@property (assign, nonatomic) BOOL progressBarAnimation;
@property (assign, nonatomic) BOOL flexibleHeader;
@property (assign, nonatomic) BOOL staticHeader;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) NSInteger currentPageIndex;

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andControllers:(NSArray*)controllers;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil focusOnControllerIndex:(NSInteger)index withSingleTitle:(BOOL)singleTitle;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil focusOnControllerIndex:(NSInteger)index withSingleTitle:(BOOL)singleTitle andProgressBarAnimation:(BOOL)progress;
@end
