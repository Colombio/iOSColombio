//
//  ScrollableHeader.m
//  Colombio
//
//  Created by Colombio on 30/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "ScrollableHeader.h"

@implementation ScrollableHeader

@synthesize activeView;
@synthesize activeVC;
@synthesize lastPage;
@synthesize pageControl;
@synthesize pageControlBeingUsed;
@synthesize pageImages;
@synthesize pageViews;
@synthesize _scrollBox;
@synthesize _scrollView;
@synthesize viewWidth;

- (void)addHeader:(UIView *)view self:(UIViewController *)viewController headerScroll:(UIScrollView *)scrollView viewScroll:(UIScrollView *)scrollBox{
    
    activeView = view;
    activeVC = viewController;
    _scrollView =scrollView;
    _scrollBox = scrollBox;
    
    lastPage=0;
    pageControlBeingUsed = NO;
    int xPosition=0;
    NSArray *colors;
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    viewWidth = screenBounds.size.width;
    
    //TODO iphone 6
    if(screenBounds.size.height == 568.0f){
        colors = [NSArray arrayWithObjects:
                  @"swipelogin1_iphone5@2x.png",
                  @"swipelogin2_iphone5@2x.png",
                  @"swipelogin3_iphone5@2x.png", nil];
    }
    else{
        colors = [NSArray arrayWithObjects:
                  @"loginswipe1.png",
                  @"loginswipe2.png",
                  @"loginswipe3.png", nil];
    }
    
    for (int i = 0; i < colors.count; i++) {
        CGRect frame;
        frame.origin.x = xPosition;
        xPosition+=viewWidth;
        float imageSize;
        float headerOffset=0;
        frame.origin.y = 0;
        
        //TODO iphone 6
        if(screenBounds.size.height == 568.0f){
            frame.size.height = 267;
            imageSize=267;
        }
        else{
            frame.size.height = 267;
            imageSize=187;
            headerOffset=80;
        }
        frame.size.width=viewWidth;
        
        UIGraphicsBeginImageContextWithOptions(activeView.frame.size, NO, 0.f);
        UIImage *targetImage = [UIImage imageNamed:[colors objectAtIndex:i]];
        [targetImage drawInRect:CGRectMake(0.f, headerOffset, activeView.frame.size.width, imageSize)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        subview.backgroundColor = [UIColor colorWithPatternImage:resultImage];
        [_scrollView addSubview:subview];
    }
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * colors.count, self._scrollView.frame.size.height);
    
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((activeView.frame.size.width/2) - (pageControl.frame.size.width/2), 226, pageControl.frame.size.width, 36)];
    
    [pageControl setNumberOfPages:3];
    [_scrollBox addSubview:pageControl];
    [_scrollView setDelegate:self];
}

// Switch the indicator when more than 50% of the previous/next page is visible
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!pageControlBeingUsed) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;
        lastPage=pageControl.currentPage;
        pageControlBeingUsed = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    pageControlBeingUsed = NO;
}

@end
