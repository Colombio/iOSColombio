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

@interface CreateAccViewController : UIViewController<UITableViewDelegate, UIScrollViewDelegate>{
    IBOutlet UIImageView *userPass;
    IBOutlet UIImageView *userWrong;
    IBOutlet UIImageView *emailPass;
    IBOutlet UIImageView *emailWrong;
    IBOutlet UIImageView *passPass;
    IBOutlet UIImageView *passWrong;
    IBOutlet UIImageView *passConfirmPass;
    IBOutlet UIImageView *passConfirmWrong;
    IBOutlet UIScrollView *scrollBox;
    IBOutlet CustomField *txtUsername;
    IBOutlet CustomField *txtEmail;
    IBOutlet CustomField *txtPassword;
    IBOutlet CustomField *txtConfirmPass;
    IBOutlet UIImageView *imgEmail;
    IBOutlet UIImageView *imgUsername;
    IBOutlet UIImageView *imgPassword;
    IBOutlet UIImageView *imgConfirm;
    NSTimer *timer;
    IBOutlet UIButton *btnCreate;
    IBOutlet UIImageView *pozadina;
    IBOutlet UIScrollView *scrollView;
    bool keyboardActive;
}

@property(strong,nonatomic) ScrollableHeader *scrollableHeader;
@property (strong, nonatomic) IBOutlet UIImageView *pozadina;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *btnCreate;
@property(strong,nonatomic) IBOutlet UIImageView *imgEmail;
@property(strong,nonatomic) IBOutlet UIImageView *imgUsername;
@property(strong,nonatomic) IBOutlet UIImageView *imgPassword;
@property(strong,nonatomic) IBOutlet UIImageView *imgConfirm;

- (IBAction)setLogIn:(id)sender;
- (IBAction)goAwayKeyboard:(id)sender;
- (IBAction)setUsername:(id)sender;
- (IBAction)setEmail:(id)sender;
- (IBAction)setPassword:(id)sender;
- (IBAction)setConfirmPass:(id)sender;
- (IBAction)setButton:(id)sender;

@property (strong,nonatomic) IBOutlet UITextField *txtUsername;
@property (strong,nonatomic) IBOutlet UITextField *txtEmail;
@property (strong,nonatomic) IBOutlet UITextField *txtPassword;
@property (strong,nonatomic) IBOutlet UITextField *txtConfirmPass;
@property (strong,nonatomic) IBOutlet UIScrollView *scrollBox;
@property (strong,nonatomic) IBOutlet UIImageView *userPass;
@property (strong,nonatomic) IBOutlet UIImageView *userWrong;
@property (strong,nonatomic) IBOutlet UIImageView *emailPass;
@property (strong,nonatomic) IBOutlet UIImageView *emailWrong;
@property (strong,nonatomic) IBOutlet UIImageView *passPass;
@property (strong,nonatomic) IBOutlet UIImageView *passWrong;
@property (strong,nonatomic) IBOutlet UIImageView *passConfirmPass;
@property (strong,nonatomic) IBOutlet UIImageView *passConfirmWrong;

- (IBAction)btnBackClicked:(id)sender;

@end
