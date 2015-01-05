//
//  LoginViewController.h
//  colombio
//
//  Created by Vlatko Šprem on 16/08/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomField.h"
#import "ScrollableHeader.h"
#import "BackgroundViewController.h"
#import "ScrollableHeaderView.h"
#import "CLTextField.h"

@interface LoginViewController : BackgroundViewController<UIScrollViewDelegate, UITextFieldDelegate>
{
    NSTimer *timer;
    BOOL loginHidden;
}



@property(strong,nonatomic) IBOutlet UIScrollView *scrollBox;
@property(weak, nonatomic) IBOutlet UIView *contentHolder;
@property (weak, nonatomic) IBOutlet ScrollableHeaderView *scrollableHeader;
@property(weak, nonatomic) IBOutlet UIView *viewButtonsHolder;
@property(weak, nonatomic) IBOutlet UIView *viewFBHolder;
@property(weak, nonatomic) IBOutlet UIView *viewGoogleHolder;
@property(weak, nonatomic) IBOutlet UIView *viewEmailHolder;
@property(weak, nonatomic) IBOutlet UIButton *btnFB;
@property(weak, nonatomic) IBOutlet UIButton *btnGoogle;
@property(weak, nonatomic) IBOutlet UIButton *btnEmail;

@property(weak, nonatomic) IBOutlet UIView *viewLoginHolder;

@property(strong,nonatomic) IBOutlet CLTextField *txtEmail;
@property(strong,nonatomic) IBOutlet CLTextField *txtPassword;

@property(strong,nonatomic) IBOutlet UIImageView *imgPassEmail;
@property(strong,nonatomic) IBOutlet UIImageView *imgFailEmail;
@property(strong,nonatomic) IBOutlet UIImageView *imgInputEmail;
@property(strong,nonatomic) IBOutlet UIImageView *imgPassPassword;
@property(strong,nonatomic) IBOutlet UIImageView *imgFailPassword;
@property(strong,nonatomic) IBOutlet UIImageView *imgInputPassword;
@property(strong,nonatomic) IBOutlet UIButton *btnLogin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_buttonDistanceFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_buttonDistanceFromBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_scrollableHeaderHeight;


- (IBAction)btnFBSelected:(id)sender;
- (IBAction)btnGoogleSelected:(id)sender;
- (IBAction)btnEmailSelected:(id)sender;

- (IBAction)setSign:(id)sender;
- (IBAction)setForgot:(id)sender;
- (IBAction)setEmail:(id)sender;
- (IBAction)setLogin:(id)sender;
- (IBAction)setPassword:(id)sender;
- (IBAction)setFacebook:(id)sender;
- (IBAction)setGoogle:(id)sender;
- (IBAction)goAwayKeyboard:(id)sender;
- (IBAction)tapBackground:(id)sender;

@end
