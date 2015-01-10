//
//  Loading.m
//  Colombio
//
//  Created by Colombio on 01/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "Loading.h"

@implementation Loading

- (void)startNativeSpinner:(UIView *)view{
    viewParent = view;
    viewDimmed = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewParent.frame.size.width, viewParent.frame.size.height)];
    actLoading = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, viewParent.frame.size.height/2-35, 70, 70)];
    viewDimmed.backgroundColor = [UIColor clearColor];
    actLoading.alpha=0.0;
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

- (void)startCustomSpinner:(UIView *)view spinMessage:(NSString*)strMessage{
    viewParent=view;
    viewDimmed = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewParent.frame.size.width, viewParent.frame.size.height)];
    imgSpinner = [[UIImageView alloc]initWithFrame:CGRectMake(viewParent.frame.size.width/2-30, viewParent.frame.size.height-150, 60, 60)];
    viewDimmed.backgroundColor = [UIColor clearColor];
    imgSpinner.alpha=0;
    imgStatus = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 30, 30)];
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

- (void)stopCustomSpinner{
    [imgSpinner.layer removeAllAnimations ];
}

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

- (void)spinLoading{
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration=2.0;
    fullRotation.repeatCount=INT32_MAX;
    [imgSpinner.layer addAnimation:fullRotation forKey:@"360"];
}

- (void)customSpinnerSuccess{
    imgStatus.image = TXT_FIELD_PASS_IMG;
    [UIView animateWithDuration:2 animations:^{
        imgStatus.alpha=1;
        lblInfo.alpha=1;
    }];
}

- (void)customSpinnerFail{
    imgStatus.image = TXT_FIELD_FAIL_IMG;
    [UIView animateWithDuration:2 animations:^{
        imgStatus.alpha=1;
    }];
}

@end
