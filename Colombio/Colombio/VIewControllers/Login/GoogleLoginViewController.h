/////////////////////////////////////////////////////////////
//
//  GoogleLoginViewController.h
//  Armin Vrevic
//
//  Created by Colombio on 7/7/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that calls google login api
//  and registers user if google login is successful
//
///////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "CustomHeaderView.h"
#import "Tools.h"
#import "HeaderView.h"
#import "Loading.h"
#import "ColombioServiceCommunicator.h"


@interface GoogleLoginViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, CustomHeaderViewDelegate>{
    IBOutlet UIWebView *webView;
    NSMutableData *receivedData;
    NSTimer *timer;
    IBOutlet CustomHeaderView *customHeaderView;
    Loading *loadingView;
}

@property (nonatomic, strong) IBOutlet NSString *isLogin;
@property (weak, nonatomic) IBOutlet UIView *headerViewHolder;
@property (strong,nonatomic) IBOutlet  CustomHeaderView *customHeaderView;
@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end
