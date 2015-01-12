//
//  Loading.h
//  Colombio
//
//  Created by Colombio on 01/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

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
