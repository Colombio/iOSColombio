//
//  ContainerViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 13/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *viewControllersArray;
@property (strong, nonatomic) NSString *nextButtonTitle;//sets textual NEXT button
@property (strong, nonatomic) UIImage *imgNextBtnNormal;//sets NEXT button image if text length = 0
@property (strong, nonatomic) UIImage *imgNextBtnPressed;//sets NEXT button image if text length = 0

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andControllers:(NSArray*)controllers;
@end
