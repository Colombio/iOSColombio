//
//  UIView+InlineFunctions.h
//  Colombio
//
//  Created by Vlatko Šprem on 09/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>


# pragma mark - CGRect Inline Functions

CG_INLINE CGRect CGRectInsetTop(CGRect rect, CGFloat dy)
{
    rect.origin.y += dy; rect.size.height -= dy; return rect;
}

CG_INLINE CGRect CGRectInsetLeft(CGRect rect, CGFloat dx)
{
    rect.origin.x += dx; rect.size.width -= dx; return rect;
}


#pragma mark - UIView Inline Functions

UIKIT_STATIC_INLINE void UIViewSetFrameOrigin(UIView *view, CGPoint origin)
{
    view.frame = CGRectMake(origin.x, origin.y, view.frame.size.width, view.frame.size.height);
}

UIKIT_STATIC_INLINE void UIViewSetFrameSize(UIView *view, CGSize size)
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.width, size.height);
}

UIKIT_STATIC_INLINE void UIViewSetFrameX(UIView *view, CGFloat x)
{
    view.frame = CGRectMake(x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}

UIKIT_STATIC_INLINE void UIViewSetFrameY(UIView *view, CGFloat y)
{
    view.frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
}

UIKIT_STATIC_INLINE void UIViewSetFrameWidth(UIView *view, CGFloat width)
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height);
}

UIKIT_STATIC_INLINE void UIViewSetFrameHeight(UIView *view, CGFloat height)
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height);
}

UIKIT_STATIC_INLINE UIViewAnimationOptions UIViewAnimationOptionsFromCurve(UIViewAnimationCurve curve)
{
    switch ( curve )
    {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            
        default:
            return (UIViewAnimationOptions)curve;
    }
}

UIKIT_STATIC_INLINE void UIViewFadeOutAndHide(UIView *view)
{
    [UIView
     animateWithDuration:0.2 animations:^
     {
         view.alpha = 0;
     }
     completion:^(BOOL finished)
     {
         view.hidden = YES;
     }
     ];
}

UIKIT_STATIC_INLINE void UIViewUnhideAndFadeIn(UIView *view)
{
    view.hidden = NO;
    
    [UIView
     animateWithDuration:0.2
     animations:^
     {
         view.alpha = 1;
     }
     ];
}

