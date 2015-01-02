//
//  CreateAcc.h
//  Colombio
//
//  Created by Colombio on 7/3/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomField.h"
#import "ScrollableHeader.h"
#import "HeaderView.h"
#import "ColombioServiceCommunicator.h"
#import "CLTextField.h"
#import "Loading.h"

@interface CreateAccViewController : UIViewController<UITableViewDelegate, UIScrollViewDelegate, HeaderViewDelegate, ColombioServiceCommunicatorDelegate, UITextFieldDelegate, NSURLConnectionDelegate>{
    IBOutlet UIScrollView *scrollBox;
    IBOutlet CLTextField *txtUsername;
    IBOutlet CLTextField *txtEmail;
    IBOutlet CLTextField *txtPassword;
    IBOutlet CLTextField *txtConfirmPass;
    NSTimer *timer;
    IBOutlet UIButton *btnCreate;
    IBOutlet UIImageView *imgBackground;
    Loading *loadingView;
    NSString *strEmail;
    NSString *strUsername;
    NSString *strConfirmPass;
    NSString *strPassword;
}

@property (weak, nonatomic) IBOutlet UIView *headerViewHolder;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet UIButton *btnCreate;
@property (strong,nonatomic) IBOutlet CLTextField *txtUsername;
@property (strong,nonatomic) IBOutlet CLTextField *txtEmail;
@property (strong,nonatomic) IBOutlet CLTextField *txtPassword;
@property (strong,nonatomic) IBOutlet CLTextField *txtConfirmPass;
@property (strong,nonatomic) IBOutlet UIScrollView *scrollBox;

- (IBAction)goAwayKeyboard:(id)sender;
- (IBAction)btnCreateAccClicked:(id)sender;
- (IBAction)btnBackClicked:(id)sender;

@end
