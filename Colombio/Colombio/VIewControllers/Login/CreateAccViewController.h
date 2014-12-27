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
    IBOutlet UIScrollView *scrollBox;
    IBOutlet CustomField *txtUsername;
    IBOutlet CustomField *txtEmail;
    IBOutlet CustomField *txtPassword;
    IBOutlet CustomField *txtConfirmPass;
    NSTimer *timer;
    IBOutlet UIButton *btnCreate;
    IBOutlet UIImageView *pozadina;
    IBOutlet UIScrollView *scrollView;
    bool keyboardActive;
}

@property (weak, nonatomic) IBOutlet UIView *headerViewHolder;
@property (strong, nonatomic) IBOutlet UIImageView *pozadina;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *btnCreate;

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

- (IBAction)btnBackClicked:(id)sender;

@end
