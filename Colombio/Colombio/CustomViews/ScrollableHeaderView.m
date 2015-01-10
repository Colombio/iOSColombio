//
//  scrollableHeaderView.m
//  Colombio
//
//  Created by Vlatko Šprem on 29/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "ScrollableHeaderView.h"
#import "ScrollableHeaderContentView.h"

@implementation ScrollableHeaderView


- (void)awakeFromNib{
    [self setupScroller];
}

- (void)setupScroller{
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if (screenBounds.size.height<568.0f) {
        _scrollBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 187)];
    }else{
        _scrollBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 275)];
    }
    
    _scrollBox.delegate = self;
    int xPosition=0;
    NSArray *views;
   
    viewWidth = screenBounds.size.width;
    
    //TODO iphone 6
    /*if(screenBounds.size.height == 568.0f){
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
    }*/
    
    /*for (int i = 0; i < views.count; i++) {
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
            frame.size.height = 187;
            imageSize=187;
        }
        frame.size.width=viewWidth;
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.f);
        UIImage *targetImage = [UIImage imageNamed:[colors objectAtIndex:i]];
        [targetImage drawInRect:CGRectMake(0.f, headerOffset, self.frame.size.width, imageSize)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        subview.backgroundColor = [UIColor colorWithPatternImage:resultImage];
        [_scrollBox addSubview:subview];
    }*/
    
    ScrollableHeaderContentView *view1 = [[ScrollableHeaderContentView alloc] initWithFrame:CGRectMake(0, 0, _scrollBox.frame.size.width, _scrollBox.frame.size.height)];
    view1.lblTitle.text = @"COLOMBIO";
    view1.lblDescription.text = [Localized string:@"header1_desc"];
    
    ScrollableHeaderContentView *view2 = [[ScrollableHeaderContentView alloc] initWithFrame:CGRectMake(0, 0, _scrollBox.frame.size.width, _scrollBox.frame.size.height)];
    view2.lblTitle.text = [Localized string:@"header2_title"];
    view2.lblDescription.text = [Localized string:@"header2_desc"];
    
    ScrollableHeaderContentView *view3 = [[ScrollableHeaderContentView alloc] initWithFrame:CGRectMake(0, 0, _scrollBox.frame.size.width, _scrollBox.frame.size.height)];
    view3.lblTitle.text = [Localized string:@"header3_title"];
    view3.lblDescription.text = [Localized string:@"header3_desc"];
    
    views = [NSArray arrayWithObjects: view1, view2, view3,nil];
    
    for (int i = 0; i < views.count; i++) {
        CGRect frame;
        frame.origin.x = xPosition;
        xPosition+=viewWidth;
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        [subview addSubview:views[i]];
        [_scrollBox addSubview:subview];
    }
    
    _scrollBox.contentSize = CGSizeMake(self.frame.size.width * views.count, _scrollBox.frame.size.height);
    _scrollBox.pagingEnabled = YES;
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((self.frame.size.width/2) - (_pageControl.frame.size.width/2), 20, _pageControl.frame.size.width, 36)];
    _pageControl.numberOfPages = 3;
    _scrollBox.showsHorizontalScrollIndicator=NO;
    
    [self addSubview:_scrollBox];
    [self addSubview:_pageControl];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark scrollView Delegate
// Switch the indicator when more than 50% of the previous/next page is visible
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!pageControlBeingUsed) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _pageControl.currentPage = page;
        lastPage=_pageControl.currentPage;
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
