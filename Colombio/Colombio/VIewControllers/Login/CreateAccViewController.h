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

@interface CreateAccViewController : UIViewController<UITableViewDelegate, UIScrollViewDelegate, HeaderViewDelegate, ColombioServiceCommunicatorDelegate>{
    IBOutlet UIScrollView *scrollBox;
    IBOutlet CLTextField *txtUsername;
    IBOutlet CLTextField *txtEmail;
    IBOutlet CLTextField *txtPassword;
    IBOutlet CLTextField *txtConfirmPass;
    NSTimer *timer;
    IBOutlet UIButton *btnCreate;
    IBOutlet UIImageView *imgBackground;
    bool keyboardActive;
}

@property (weak, nonatomic) IBOutlet UIView *headerViewHolder;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet UIButton *btnCreate;
@property (strong,nonatomic) IBOutlet CLTextField *txtUsername;
@property (strong,nonatomic) IBOutlet CLTextField *txtEmail;
@property (strong,nonatomic) IBOutlet CLTextField *txtPassword;
@property (strong,nonatomic) IBOutlet CLTextField *txtConfirmPass;
@property (strong,nonatomic) IBOutlet UIScrollView *scrollBox;

- (IBAction)setLogIn:(id)sender;
- (IBAction)goAwayKeyboard:(id)sender;
- (IBAction)setUsername:(id)sender;
- (IBAction)setEmail:(id)sender;
- (IBAction)setPassword:(id)sender;
- (IBAction)setConfirmPass:(id)sender;
- (IBAction)setButton:(id)sender;
- (IBAction)btnBackClicked:(id)sender;

@end
