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
{
    Loading *spinner;
    AppDelegate *appdelegate;
    NSDictionary *dictPayPalData;
    ColombioServiceCommunicator *csc;
}
@property(weak, nonatomic) IBOutlet CustomHeaderView *customHeader;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
@property(weak, nonatomic) IBOutlet UITextField *txtName2;
@property(weak, nonatomic) IBOutlet UITextField *txtLastName2;
@property(weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    _txtPhoneNumber.inputAccessoryView = [self keyboardToolbarFor:_txtPhoneNumber action:@selector(resignFirstResponder)];
    
    appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self loadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    _customHeader.headerTitle = [Localized string:@"my_profile"];
    //_customHeader.backButtonText = @"";
    _customHeader.nextButtonText = [Localized string:@"header_save"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Setup Fields
- (void)loadData{
    csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate = self;
    spinner = [[Loading alloc] init];
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    [csc fetchUserProfile];
}

- (void)setFields{
    NSString *sql = @"SELECT * FROM user";
    NSDictionary *tDict = [appdelegate.db getRowForSQL:sql];
    
    [self setRating:(int)round([tDict[@"rating"] floatValue])];
    _lblBalanceAmount.text =  [NSString stringWithFormat:@"%.2f", [tDict[@"balance"] floatValue]];
    _lblPendingAmount.text =  [NSString stringWithFormat:@"%.2f", [tDict[@"pending_cashout"] floatValue]];
    _txtPayPalEmail.text = tDict[@"paypal_email"];
    _txtName1.text = tDict[@"first_name"];
    _txtLastName1.text = tDict[@"last_name"];
    //_txtStreet.text = tDict[@""];
    _txtCity.text = ((NSString*)tDict[@"city"]).length>1?tDict[@"city"]:@"";
    _txtZIP.text = ((NSString*)tDict[@"zip"]).length>1?tDict[@"zip"]:@"";
    //_txtCountry.text = tDict[@""];
    
    _txtName2.text = tDict[@"first_name"];
    _txtLastName2.text = tDict[@"last_name"];
    _txtPhoneNumber.text = tDict[@"phone_number"];
    
    [_swAnonymous setOn:[tDict[@"anonymous"] boolValue]];
    [_swConnetPayPal setOn:[tDict[@"paypal"] boolValue]];
    [self setAnonymousSwitch];
    [self setPayPalSwitch];
}

- (void)setAnonymousSwitch{
    if (_swAnonymous.isOn) {
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
}

- (void)setPayPalSwitch{
    if (_swConnetPayPal.isOn) {
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

- (void)setRating:(int)rating{
    NSArray *starsArray = [[NSArray alloc] initWithObjects:_imgStar1, _imgStar2, _imgStar3, _imgStar4, _imgStar5, nil];
    for (int i = 0; i<rating; i++) {
        ((UIImageView*)starsArray[i]).image = [UIImage imageNamed:@"zijezda_on.png"];
    }
    for (int i=4; i>= rating; i--) {
        ((UIImageView*)starsArray[i]).image = [UIImage imageNamed:@"zvijezda_off.png"];
    }
}

#pragma mark SwitchAction
- (IBAction)switchValueChange:(UISwitch*)sender{
    if (sender==_swAnonymous) {
        [self setAnonymousSwitch];
    }else if(sender==_swConnetPayPal){
        [self setPayPalSwitch];
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark Button Action
- (IBAction)btnCashoutSelected:(id)sender{
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    if ([self validatePayPalData]) {
        dictPayPalData = @{@"first_name":_txtName1.text,
                           @"last_name":_txtLastName1.text,
                           @"street":_txtStreet.text,
                           @"city":_txtCity.text,
                           @"zip":_txtZIP.text,
                           @"country":_txtCountry.text};
        [csc payoutRequest:dictPayPalData];
        
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[Localized string:@"error_fill_fields"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark CSC Delegate
- (void)didFetchUserDetails:(NSDictionary *)result{
    [spinner removeCustomSpinner];
    [self setFields];
}

- (void)fetchingFailedWithError:(NSError *)error{
    [spinner removeCustomSpinner];
    [self setFields];
}

- (void)didSendUserDataForPayPal:(NSDictionary *)result{
    [spinner removeCustomSpinner];
}

- (void)didFailSendingUserDataForPayPal:(NSError *)error{
    [spinner removeCustomSpinner];
}
#pragma mark TextField

- (UIToolbar *)keyboardToolbarFor:(UITextField *)textField action:(SEL)action {
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.backgroundColor = [UIColor lightGrayColor];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textField action:action];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];
    return keyboardDoneButtonView;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Keyboard

- (void)keyboardUp:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    UIEdgeInsets contentInset = _scrollView.contentInset;
    contentInset.bottom = keyboardRect.size.height;
    _scrollView.contentInset = contentInset;
}

- (void)keyboardDown:(NSNotification*)notification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark Validation
- (BOOL)validatePayPalData{
    BOOL result=YES;
    if (_txtName1.text.length==0) {
        result=NO;
        _txtName1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtName1.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    }
    if (_txtLastName1.text.length==0) {
        result=NO;
        _txtName1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtLastName1.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    }
    if (_txtStreet.text.length==0) {
        result=NO;
        _txtStreet.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtStreet.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    }
    if (_txtCountry.text.length==0) {
        result=NO;
        _txtCountry.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtCountry.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    }
    if (_txtCity.text.length==0) {
        result=NO;
        _txtCity.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtCity.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    }
    if (_txtZIP.text.length==0) {
        result=NO;
        _txtZIP.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtZIP.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    }
    if (_txtPayPalEmail.text.length==0) {
        result=NO;
        _txtPayPalEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtPayPalEmail.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    }
    return result;
}

#pragma mark Navigation

@end
