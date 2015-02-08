//
//  GoogleLogin.h
//  Colombio
//
//  Created by Colombio on 7/4/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

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
