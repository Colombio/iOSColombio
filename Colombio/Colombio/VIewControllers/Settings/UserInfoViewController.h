//
//  UserInfoViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 09/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSSwitchButton.h"

@interface UserInfoViewController : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *viewAnonymousHolder;
@property (weak, nonatomic) IBOutlet UILabel *lblAnonymous;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtSurname;
@property (weak, nonatomic) IBOutlet VSSwitchButton *btnToggleAnonymous;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_AnonynmousHolderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_NameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_SurnameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblAnonymousWidth;
@property (weak, nonatomic) IBOutlet UIButton *btnAnonymousInfo;

@property (weak, nonatomic) IBOutlet VSSwitchButton *btnTogglePayPal;
@property (weak, nonatomic) IBOutlet UIButton *btnPayPalInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblConnectPayPal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblConnectPayPalWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PayPalViewHeight;
@property (weak, nonatomic) IBOutlet UITextField *txtPayPalEmail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PayPalEmailHeight;

- (IBAction)btnAction:(VSSwitchButton*)sender;
- (IBAction)btnInfo:(UIButton*)sender;
- (BOOL)validateFields;
@end
