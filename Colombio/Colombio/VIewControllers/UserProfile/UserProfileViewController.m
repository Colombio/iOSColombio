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
#import "Messages.h"
#import "CashoutViewController.h"


@interface UserProfileViewController ()<UITextFieldDelegate, ColombioServiceCommunicatorDelegate, CustomHeaderViewDelegate>
{
    Loading *spinner;
    AppDelegate *appdelegate;
    NSDictionary *dictPayPalData;
    ColombioServiceCommunicator *csc;
    float pendingCashoutAmount;
    float balanceAmount;
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
    _txtZIP.inputAccessoryView = [self keyboardToolbarFor:_txtZIP action:@selector(resignFirstResponder)];
    
    appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    _lblPendingKey.hidden=YES;
    _lblPendingAmount.hidden=YES;
    _CS_balanceHolderHeight.constant=40.0;
    _customHeader.headerTitle = [Localized string:@"my_profile"];
    _customHeader.backButtonText = @"";
    _customHeader.nextButtonText = [Localized string:@"header_save"];
    [self loadData];
    
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
    balanceAmount = [tDict[@"balance"] floatValue];
    _lblBalanceAmount.text =  [NSString stringWithFormat:@"%.2f€", [tDict[@"balance"] floatValue]];
    pendingCashoutAmount = [tDict[@"pending_cashout"] floatValue];
    _lblPendingAmount.text =  [NSString stringWithFormat:@"%.2f€", [tDict[@"pending_cashout"] floatValue]];
    _txtPayPalEmail.text = tDict[@"paypal_email"];
    _txtName1.text = tDict[@"first_name"];
    _txtLastName1.text = tDict[@"last_name"];
    //_txtStreet.text = tDict[@""];
    _txtCity.text = ((NSString*)tDict[@"city"]).length>1?tDict[@"city"]:@"";
    _txtZIP.text = ((NSString*)tDict[@"zip"]).length>1?tDict[@"zip"]:@"";
    //_txtCountry.text = tDict[@""];
    
    _txtName2.text = tDict[@"first_name"];
    _txtLastName2.text = tDict[@"last_name"];
    _txtPhoneNumber.text = ([(NSString*)tDict[@"phone_number"] isEqualToString:@"0"]?@"":tDict[@"phone_number"]);
    
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
        _lblSendAnonymousKey.text = [Localized string:@"anonymous_sending"];
    }else{
        _CS_viewAnomymousHolderHeight.constant = 131.0;
        _CS_AHeight1.constant = 30.0;
        _CS_AHeight2.constant = 30.0;
        _CS_AHeight3.constant = 30.0;
        _lblSendAnonymousKey.text = [Localized string:@"sending_news_as"];
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
    if (balanceAmount>0.0) {
        if (!_swConnetPayPal.isOn) {
            [_swConnetPayPal setOn:YES];
            [self setPayPalSwitch];
        }
        
        if ([self validatePayPalData]) {
            dictPayPalData = @{@"paypal_email":_txtPayPalEmail.text,
                               @"first_name":_txtName1.text,
                               @"last_name":_txtLastName1.text,
                               @"street":_txtStreet.text,
                               @"city":_txtCity.text,
                               @"zip":_txtZIP.text,
                               @"country":_txtCountry.text};
            /*CashoutViewController *cashoutVC = [[CashoutViewController alloc] initWithData:dictPayPalData];
             [self.navigationController pushViewController:cashoutVC animated:YES];*/
            [spinner startCustomSpinner2:self.view spinMessage:@""];
            
            [csc payoutRequest:dictPayPalData];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[Localized string:@"error_fill_fields"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
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
    if (!strcmp("1",((NSString*)[result objectForKey:@"s"]).UTF8String)) {
        if(!strcmp("0",((NSString*)[result objectForKey:@"transaction"]).UTF8String)) {
            if (pendingCashoutAmount>0) {
                _lblPendingAmount.hidden=NO;
                [UIView transitionWithView:_lblPendingAmount
                                  duration:0.8
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:NULL
                                completion:NULL];
                
                _lblPendingKey.hidden=NO;
                [UIView transitionWithView:_lblPendingKey
                                  duration:0.8
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:NULL
                                completion:NULL];
                
                _CS_balanceHolderHeight.constant=70.0;
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     [self.view layoutIfNeeded];
                                 }];
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:result[@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else{
            CashoutViewController *cashoutVC = [[CashoutViewController alloc] initWithData:dictPayPalData];
            [self.navigationController pushViewController:cashoutVC animated:YES];
        }
    }else{
        [Messages showErrorMsg:@"error_web_request"];
    }
    
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
        _txtLastName1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtLastName1.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
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

- (BOOL)validateData{
    BOOL result = YES;
    if (_swConnetPayPal.isOn) {
        if (_txtPayPalEmail.text.length==0) {
            result=NO;
            _txtPayPalEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtPayPalEmail.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        }
    }
    if (!_swAnonymous.isOn) {
        if (_txtName2.text.length==0) {
            result=NO;
            _txtName2.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtName2.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        }
        if (_txtLastName2.text.length==0) {
            result=NO;
            _txtLastName2.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtLastName2.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        }
    }
    return result;
}

#pragma mark Navigation
- (void)btnBackClicked{
    [self.tabBarController setSelectedIndex:2];
}

- (void)btnNextClicked{
    if ([self validateData]) {
        [spinner startCustomSpinner2:self.view spinMessage:@""];
        [self updateUserData];
        
        NSString *signedRequest = [ColombioServiceCommunicator getSignedRequest];
        
        NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_update_profile/", BASE_URL];
        NSDictionary *userInfo = [self getUserInfo];
        
        NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&user_email=%@&paypal_email=%@&user_pass=%@&user_pass_confirm=%@&first_name=%@&last_name=%@&phone_number=%@&anonymous=%d&country_id=%ld&first_login=0&current_id=%@&installationID=%@",
                              signedRequest,
                              userInfo[@"user_email"],
                              userInfo[@"paypal_email"],
                              (userInfo[@"user_pass"]?userInfo[@"user_pass"]:@""),
                              (userInfo[@"user_pass_confirm"]?userInfo[@"user_pass_confirm"]:@""),
                              (((NSString*)userInfo[@"first_name"]).length>0?userInfo[@"first_name"]:@""),
                              (((NSString*)userInfo[@"last_name"]).length>0?userInfo[@"last_name"]:@""),
                              (userInfo[@"phone_number"]?userInfo[@"phone_number"]:@""),
                              [userInfo[@"anonymous"] intValue],
                              (long)[[NSUserDefaults standardUserDefaults] integerForKey:COUNTRY_ID],
                              userInfo[@"user_id"],
                              ([[NSUserDefaults standardUserDefaults] objectForKey:PARSE_INSTALLATIONID]!=nil?[[NSUserDefaults standardUserDefaults] objectForKey:PARSE_INSTALLATIONID]:@"")];
        [csc sendAsyncHttp:url_str httpBody:httpBody cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
        [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            NSDictionary *dicResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(error==nil&&data!=nil){
                if(!strcmp("1",((NSString*)[dicResponse objectForKey:@"s"]).UTF8String)){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [spinner removeCustomSpinner];
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [spinner removeCustomSpinner];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:dicResponse[@"errors"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    });
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner removeCustomSpinner];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:dicResponse[@"errors"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
                
            }
        }];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[Localized string:@"error_fill_fields"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

}

#pragma mark DB
- (void)updateUserData{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"anonymous"] = @(_swAnonymous.isOn);
    dict[@"first_name"] = _txtName2.text;
    dict[@"last_name"] = _txtLastName2.text;
    dict[@"paypal_email"] = _txtPayPalEmail.text;
    dict[@"paypal"] = _swConnetPayPal.isOn?@1:@0;
    dict[@"phone_number"] = _txtPhoneNumber.text;
    
    [appdelegate.db updateDictionary:dict forTable:@"USER" where:NULL];
    
}

- (NSDictionary*)getUserInfo{
    return (NSDictionary*)[appdelegate.db getRowForSQL:@"SELECT * from USER"];
}

@end
