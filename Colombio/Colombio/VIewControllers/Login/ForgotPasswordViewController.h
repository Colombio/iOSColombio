//
//  ForgotPassword.h
//  Colombio
//
//  Created by Colombio on 7/3/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

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
}

@property (weak, nonatomic) IBOutlet UIView *headerViewHolder;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (strong,nonatomic) IBOutlet CLTextField *txtEmail;;
@property (strong,nonatomic) IBOutlet UIScrollView *scrollBox;

- (IBAction)setLogInside:(id)sender;
- (IBAction)setSignIn:(id)sender;
- (IBAction)goAwayKeyboard:(id)sender;
- (IBAction)setEmail:(id)sender;
- (IBAction)setSend:(id)sender;

@end
