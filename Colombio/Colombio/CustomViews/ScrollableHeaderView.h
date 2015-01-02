//
//  scrollableHeaderView.h
//  Colombio
//
//  Created by Vlatko Šprem on 29/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollableHeaderView : UIView <UIScrollViewDelegate>
{
    int viewWidth, lastPage;
    BOOL pageControlBeingUsed;
}
@property (nonatomic, strong) UIScrollView *scrollBox;
@property (nonatomic, strong) UIPageControl *pageControl;

@end
