//
//  ForgotPassword.h
//  Colombio
//
//  Created by Colombio on 7/3/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollableHeader.h"

@interface ForgotPasswordViewController : UIViewController<UIScrollViewDelegate,UITabBarDelegate>{
    
    IBOutlet UIImageView *emailPass;
    IBOutlet UIImageView *emailWrong;
    IBOutlet UITextField *txtEmail;
    IBOutlet UIScrollView *scrollBox;
    IBOutlet UIImageView *inputImg;
    NSTimer *timer;
    IBOutlet UIButton *btnSend;
    IBOutlet UIImageView *pozadina;
}

@property(strong,nonatomic) ScrollableHeader *scrollableHeader;
@property (strong, nonatomic) IBOutlet UIImageView *pozadina;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
- (IBAction)setLogInside:(id)sender;
- (IBAction)setSignIn:(id)sender;
- (IBAction)goAwayKeyboard:(id)sender;
- (IBAction)setEmail:(id)sender;

@property (strong,nonatomic) UIScrollView *scrollBox;
@property (strong,nonatomic) IBOutlet UIImageView *inputImg;
@property (strong,nonatomic) IBOutlet UITextField *txtEmail;
@property (strong,nonatomic) IBOutlet UIImageView *emailPass;
@property (strong,nonatomic) IBOutlet UIImageView *emailWrong;

- (IBAction)setSend:(id)sender;

@end
