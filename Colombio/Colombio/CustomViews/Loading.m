/////////////////////////////////////////////////////////////
//
//  Loading.m
//  Armin Vrevic
//
//  Created by Colombio on 01/01/15.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom view that provides methods for presenting loading
//  screen.
//
///////////////////////////////////////////////////////////////

#import "Loading.h"

@implementation Loading

@synthesize actLoading;
//is view dimmed
@synthesize viewDimmed;

/**
 *  Starts native ios spinner
 *
 *  1. Add dimmed view to parent view
 *  2. Add spinner to dimmed view
 *  3. Start spinning the spinner
 *
 *  @param view "View on which the loading screen will go to"
 *
 */
- (void)startNativeSpinner:(UIView *)view{
    viewParent = view;
    viewDimmed = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewParent.frame.size.width, viewParent.frame.size.height)];
    actLoading = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, viewParent.frame.size.height/2-35, 70, 70)];
    viewDimmed.backgroundColor = [UIColor clearColor];
    actLoading.alpha=0.0;
    //smoothen the dimmed view presenting animation
    [UIView animateWithDuration:0.8 animations:^(void) {
        [viewParent addSubview:viewDimmed];
        viewDimmed.alpha=0.6;
        actLoading.alpha=1;
        viewDimmed.backgroundColor = [UIColor blackColor];
        [viewParent addSubview:actLoading];
        [viewParent setUserInteractionEnabled:NO];
        [actLoading startAnimating];
        isLoading=YES;
    }];
}

/**
 *  Stop native ios spinner
 *
 *  1. Animate spinner stopping and dimmed view removing
 *  2. Remove dimmed view and spinner from parent view
 *
 */
- (void)stopNativeSpinner{
    [UIView animateWithDuration:0.8 animations:^(void) {
        [actLoading stopAnimating];
        viewDimmed.alpha=0.0;
        actLoading.alpha=0.0;
        [viewParent setUserInteractionEnabled:YES];
        isLoading=NO;
    } completion:^(BOOL finished) {
        [actLoading removeFromSuperview];
        [viewDimmed removeFromSuperview];
    }];
}

/**
 *  Starts custom made spinner
 *
 *  1. Add dimmed view to parent view
 *  2. Configure custom spinner
 *  3. Add spinner to dimmed view
 *  4. Start spinning the spinner
 *
 *  @param view "View on which the loading screen will go to"
 *  @param strMessage "Message that will be presented after spin complete"
 *
 */
- (void)startCustomSpinner:(UIView *)view spinMessage:(NSString*)strMessage{
    viewParent=view;
    viewDimmed = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewParent.frame.size.width, viewParent.frame.size.height)];
    imgSpinner = [[UIImageView alloc]initWithFrame:CGRectMake(viewParent.frame.size.width/2-30, viewParent.frame.size.height-200, 60, 60)];
    viewDimmed.backgroundColor = [UIColor clearColor];
    imgSpinner.alpha=0;
    imgStatus = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 20, 20)];
    imgStatus.alpha=0;
    [imgSpinner addSubview:imgStatus];
    lblInfo = [[UILabel alloc]initWithFrame:CGRectMake(-50, 40, 200, 80)];
    lblInfo.text = [Localized string:strMessage];
    lblInfo.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
    lblInfo.textColor = [UIColor whiteColor];
    lblInfo.alpha=0;
    [imgSpinner addSubview:lblInfo];
    
    [UIView animateWithDuration:0.8 animations:^(void) {
        [viewParent addSubview:viewDimmed];
        viewDimmed.alpha=0.6;
        imgSpinner.alpha=1;
        viewDimmed.backgroundColor = [UIColor blackColor];
        imgSpinner.image = [UIImage imageNamed:@"loading"];
        [viewParent addSubview:imgSpinner];
        [self spinLoading];
        [viewParent setUserInteractionEnabled:NO];
        isLoading=YES;
    }];
}

/**
 *  Stop custom made spinner
 *
 */
- (void)stopCustomSpinner{
    [imgSpinner.layer removeAllAnimations ];
}

/**
 *  Remove dimmed view and custom spinner from parent view
 *  With animation for smooth transition
 *
 */
- (void)removeCustomSpinner{
    [UIView animateWithDuration:0.8  animations:^(void) {
        [imgSpinner.layer removeAllAnimations];
        imgSpinner.alpha=0.0;
        viewDimmed.alpha=0.0;
        lblInfo.alpha=0.0;
        [viewParent setUserInteractionEnabled:YES];
        isLoading=NO;
    } completion:^(BOOL finished) {
        [viewDimmed removeFromSuperview];
        [imgSpinner removeFromSuperview];
        [lblInfo removeFromSuperview];
    }];
}

/**
 *  Start animating the custom spin circle in a circular rotation
 *
 */
- (void)spinLoading{
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration=2.0;
    fullRotation.repeatCount=INT32_MAX;
    [imgSpinner.layer addAnimation:fullRotation forKey:@"360"];
}

/**
 *  Show success check mark in the middle of the spinner
 *
 */
- (void)customSpinnerSuccess{
    imgStatus.image = TXT_FIELD_PASS_IMG;
    [UIView animateWithDuration:2 animations:^{
        imgStatus.alpha=1;
        lblInfo.alpha=1;
    }];
}

/**
 *  Show fail check mark in the middle of the spinner
 *
 */
- (void)customSpinnerFail{
    imgStatus.image = TXT_FIELD_FAIL_IMG;
    [UIView animateWithDuration:2 animations:^{
        imgStatus.alpha=1;
    }];
}

@end
