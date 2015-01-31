//
//  UserInfoUploadViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 28/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSSwitchButton.h"

@interface UserInfoUploadViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) NSString *cost;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *viewPriceHolder;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblDisclamer;
@property (weak, nonatomic) IBOutlet VSSwitchButton *btnTogglePrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PriceHolderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_NameYourPriceHeight;

@property (weak, nonatomic) IBOutlet UIView *viewAnonymousHolder;
@property (weak, nonatomic) IBOutlet UILabel *lblAnonymoys;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNum;
@property (weak, nonatomic) IBOutlet VSSwitchButton *btnToggleAnonymous;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_AnonynmousHolderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_NameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PhoneNumHeight;

@property (weak, nonatomic) IBOutlet UIButton *btnBeSigned;
@property (weak, nonatomic) IBOutlet UIImageView *imgSigned;
@property (assign, nonatomic) BOOL be_credited;

@property (weak, nonatomic) IBOutlet UIView *viewContactMe;
@property (weak, nonatomic) IBOutlet UILabel *lblContactMe;
@property (weak, nonatomic) IBOutlet VSSwitchButton *btnToggleContactMe;
@property (weak, nonatomic) IBOutlet UITextField *txtContactMe;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_ContactMeHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_ContactMePhoneHeight;

- (instancetype)initWithDemand:(BOOL)isNewsDemand;
- (IBAction)btnAction:(VSSwitchButton*)sender;
- (IBAction)btnBeCredited:(id)sender;

@end
