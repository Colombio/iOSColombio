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

@interface LoginViewController : BackgroundViewController<UIScrollViewDelegate>
{
    NSTimer *timer;
}

@property(strong,nonatomic) ScrollableHeader *scrollableHeader;
@property(nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property(strong,nonatomic) IBOutlet UIScrollView *scrollBox;
@property(strong,nonatomic) IBOutlet CustomField *txtEmail;
@property(strong,nonatomic) IBOutlet CustomField *txtPassword;
@property(strong,nonatomic) IBOutlet UIImageView *imgPassEmail;
@property(strong,nonatomic) IBOutlet UIImageView *imgFailEmail;
@property(strong,nonatomic) IBOutlet UIImageView *imgInputEmail;
@property(strong,nonatomic) IBOutlet UIImageView *imgPassPassword;
@property(strong,nonatomic) IBOutlet UIImageView *imgFailPassword;
@property(strong,nonatomic) IBOutlet UIImageView *imgInputPassword;
@property(strong,nonatomic) IBOutlet UIButton *btnLogin;


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
