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

@property (strong, nonatomic) NSString *price;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *viewPriceHolder;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblDisclamer;
@property (weak, nonatomic) IBOutlet VSSwitchButton *btnTogglePrice;
@property (weak, nonatomic) IBOutlet UISwitch *swTogglePrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PriceHolderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_NameYourPriceHeight;
@property (weak, nonatomic) IBOutlet UIView *viewH1;

@property (weak, nonatomic) IBOutlet UIView *viewAnonymousHolder;
@property (weak, nonatomic) IBOutlet UILabel *lblAnonymoys;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
//@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNum;
@property (weak, nonatomic) IBOutlet UITextField *txtSurname;
@property (weak, nonatomic) IBOutlet VSSwitchButton *btnToggleAnonymous;
@property (weak, nonatomic) IBOutlet UISwitch *swToggleAnonymous;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_AnonynmousHolderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_NameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PhoneNumHeight;

@property (assign, nonatomic) BOOL be_credited;
@property (weak, nonatomic) IBOutlet UISwitch *swToggleBeSigned;

@property (weak, nonatomic) IBOutlet UIView *viewContactMe;
@property (weak, nonatomic) IBOutlet UILabel *lblContactMe;
@property (weak, nonatomic) IBOutlet VSSwitchButton *btnToggleContactMe;
@property (weak, nonatomic) IBOutlet UISwitch *swToggleContactMe;
@property (weak, nonatomic) IBOutlet UITextField *txtContactMe;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_ContactMeHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_ContactMePhoneHeight;

- (instancetype)initWithDemand:(BOOL)isNewsDemand withPrice:(NSString*)price;
- (IBAction)btnAction:(UISwitch*)sender;
- (BOOL)validateFields;

@end
