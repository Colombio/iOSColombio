//
//  UserProfileViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 26/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UserProfileViewController.h"
#import "CustomHeaderView.h"
#import "Loading.h"
#import "AppDelegate.h"
#import "ColombioServiceCommunicator.h"


@interface UserProfileViewController ()<UITextFieldDelegate, ColombioServiceCommunicatorDelegate, CustomHeaderViewDelegate>

@property(weak, nonatomic) IBOutlet CustomHeaderView *customHeader;

@property(weak, nonatomic) IBOutlet UILabel *lblMyRatingKey;
@property(weak, nonatomic) IBOutlet UIImageView *imgStar1;
@property(weak, nonatomic) IBOutlet UIImageView *imgStar2;
@property(weak, nonatomic) IBOutlet UIImageView *imgStar3;
@property(weak, nonatomic) IBOutlet UIImageView *imgStar4;
@property(weak, nonatomic) IBOutlet UIImageView *imgStar5;
@property(weak, nonatomic) IBOutlet UILabel *lblMyBalanceKey;
@property(weak, nonatomic) IBOutlet UILabel *lblBalanceAmount;
@property(weak, nonatomic) IBOutlet UIButton *btnCashout;
@property(weak, nonatomic) IBOutlet UILabel *lblPendingKey;
@property(weak, nonatomic) IBOutlet UILabel *lblPendingAmount;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_balanceHolderHeight;

@property(weak, nonatomic) IBOutlet UIView *viewPayPalHolder;
@property(weak, nonatomic) IBOutlet UILabel *lblConnectPayPalKey;
@property(weak, nonatomic) IBOutlet UISwitch *swConnetPayPal;
@property(weak, nonatomic) IBOutlet UITextField *txtPayPalEmail;
@property(weak, nonatomic) IBOutlet UITextField *txtName1;
@property(weak, nonatomic) IBOutlet UITextField *txtLastName1;
@property(weak, nonatomic) IBOutlet UITextField *txtStreet;
@property(weak, nonatomic) IBOutlet UITextField *txtCity;
@property(weak, nonatomic) IBOutlet UITextField *txtCountry;
@property(weak, nonatomic) IBOutlet UITextField *txtZIP;
@property(weak, nonatomic) IBOutlet UILabel *txtInfo;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_viewPayPalHolderHeight;

@property(weak, nonatomic) IBOutlet UIView *viewAnomymousHolder;
@property(weak, nonatomic) IBOutlet UILabel *lblSendAnonymousKey;
@property(weak, nonatomic) IBOutlet UISwitch *swAnonymous;
@property(weak, nonatomic) IBOutlet UITextField *lblName2;
@property(weak, nonatomic) IBOutlet UITextField *lblLastName2;
@property(weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_viewAnomymousHolderHeight;

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PPHeight1;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PPHeight2;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PPHeight3;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PPHeight4;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PPHeight5;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PPHeight6;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PPHeight7;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PPHeight8;

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_AHeight1;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_AHeight2;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *CS_AHeight3;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Setup Fields
- (void)loadData{
    
}

#pragma mark SwitchAction
- (IBAction)switchValueChange:(UISwitch*)sender{
    if (sender==_swAnonymous) {
        if (sender.isOn) {
            _CS_viewAnomymousHolderHeight.constant = 35.0;
            _CS_AHeight1.constant = 0.0;
            _CS_AHeight2.constant = 0.0;
            _CS_AHeight3.constant = 0.0;
        }else{
            _CS_viewAnomymousHolderHeight.constant = 131.0;
            _CS_AHeight1.constant = 30.0;
            _CS_AHeight2.constant = 30.0;
            _CS_AHeight3.constant = 30.0;
        }
    }else if(sender==_swConnetPayPal){
        if (sender.isOn) {
            _CS_viewPayPalHolderHeight.constant = 299.0;
            _CS_PPHeight1.constant=30.0;
            _CS_PPHeight2.constant=30.0;
            _CS_PPHeight3.constant=30.0;
            _CS_PPHeight4.constant=30.0;
            _CS_PPHeight5.constant=30.0;
            _CS_PPHeight6.constant=30.0;
            _CS_PPHeight7.constant=30.0;
            _CS_PPHeight8.constant=35.0;
        }else{
            _CS_viewPayPalHolderHeight.constant = 35.0;
            _CS_PPHeight1.constant=0.0;
            _CS_PPHeight2.constant=0.0;
            _CS_PPHeight3.constant=0.0;
            _CS_PPHeight4.constant=0.0;
            _CS_PPHeight5.constant=0.0;
            _CS_PPHeight6.constant=0.0;
            _CS_PPHeight7.constant=0.0;
            _CS_PPHeight8.constant=0.0;
        }
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

@end
