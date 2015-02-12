/////////////////////////////////////////////////////////////
//
//  ForgotPasswordViewController.h
//  Armin Vrevic
//
//  Created by Colombio on 7/3/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Forgot password workflow class, user inputs email,
//  email is validated and sent to server
//  Response is validated, and presented to user
//
///////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "ScrollableHeader.h"
#import "HeaderView.h"
#import "ColombioServiceCommunicator.h"
#import "CLTextField.h"
#import "Loading.h"

@interface ForgotPasswordViewController : UIViewController<UITableViewDelegate, UIScrollViewDelegate, HeaderViewDelegate, ColombioServiceCommunicatorDelegate, UITextFieldDelegate, NSURLConnectionDelegate>{
    IBOutlet UIScrollView *scrollBox;
    IBOutlet CLTextField *txtEmail;
    NSTimer *timer;
    IBOutlet UIButton *btnSend;
    IBOutlet UIImageView *imgBackground;
    Loading *loadingView;
    NSString *strEmail;
}

@property (weak, nonatomic) IBOutlet UIView *headerViewHolder;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (strong,nonatomic) IBOutlet CLTextField *txtEmail;;
@property (strong,nonatomic) IBOutlet UIScrollView *scrollBox;

- (IBAction)goAwayKeyboard:(id)sender;
- (IBAction)btnForgotPassClicked:(id)sender;
- (IBAction)btnBackClicked:(id)sender;

@end
