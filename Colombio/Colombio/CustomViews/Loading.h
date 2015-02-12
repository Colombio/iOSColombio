/////////////////////////////////////////////////////////////
//
//  Loading.h
//  Armin Vrevic
//
//  Created by Colombio on 01/01/15.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom view that provides methods for presenting loading
//  screen.
//
///////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@interface Loading : NSObject{
    UIActivityIndicatorView *actLoading;
    UIView *viewDimmed;
    BOOL isLoading;
    UIView *viewParent;
    UIImageView *imgSpinner;
    UIImageView *imgStatus;
    UILabel *lblInfo;
}

@property (strong,nonatomic) UIActivityIndicatorView *actLoading;
@property (strong,nonatomic) UIView *viewDimmed;
- (void)startNativeSpinner:(UIView *)view;
- (void)stopNativeSpinner;
- (void)startCustomSpinner:(UIView *)view spinMessage:(NSString*)strMessage;
- (void)stopCustomSpinner;
- (void)customSpinnerSuccess;
- (void)customSpinnerFail;
- (void)removeCustomSpinner;

@end
