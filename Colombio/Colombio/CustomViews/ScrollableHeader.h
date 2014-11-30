//
//  ScrollableHeader.h
//  Colombio
//
//  Created by Colombio on 30/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScrollableHeader : NSObject<UIScrollViewDelegate>

- (void)addHeader:(UIView *)view self:(UIViewController *)viewController headerScroll:(UIScrollView *)scrollView viewScroll:(UIScrollView *)scrollBox;
- (IBAction)changePage:(id)sender;

//Lokalno se sprema aktivni viewController kako bi mogao handlati navigaciju
@property (strong,nonatomic) UIView *activeView;
//Lokalno se sprema proslijedeni view kako bi se mogli dodavati elementi na view
@property (strong,nonatomic) UIViewController *activeVC;
//Scroll view od samog headera
@property (strong,nonatomic) UIScrollView *_scrollView;
//Scroll view od cijelog viewa
@property (strong,nonatomic) UIScrollView *_scrollBox;
@property (nonatomic,assign) BOOL pageControlBeingUsed;
@property (nonatomic,assign) NSInteger lastPage;
@property (nonatomic,strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic,strong) NSArray *pageImages;
@property (nonatomic,strong) NSMutableArray *pageViews;
@property (nonatomic,assign) int viewWidth;

@end
