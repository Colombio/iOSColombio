//
//  UserInfoViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 09/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UITextField+XibAttributes.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (instancetype)init{
    self = [super init];
    if (self){
        self.title = [Localized string:@"your_info"];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    _txtName.tintColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_TXT_FIELD];
    _txtSurname.tintColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_TXT_FIELD];
    _txtPayPalEmail.tintColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_TXT_FIELD];
    /*_btnToggleAnonymous.isON = YES;
    _btnTogglePayPal.isON = NO;
    [self setLabelsWidth];*/
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLabelsWidth{
    CGSize size = [_lblAnonymous.text sizeWithFont:_lblAnonymous.font constrainedToSize:CGSizeMake(_viewAnonymousHolder.frame.size.width-_swToggleAnonymoys.frame.size.width-40, MAXFLOAT)
        lineBreakMode:NSLineBreakByWordWrapping];
    _CS_lblAnonymousWidth.constant = size.width+15;
    
    size = [_lblConnectPayPal.text sizeWithFont:_lblConnectPayPal.font constrainedToSize:CGSizeMake(_viewAnonymousHolder.frame.size.width-_swTogglePayPal.frame.size.width-40, MAXFLOAT)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    _CS_lblConnectPayPalWidth.constant = size.width+15;
}

/*- (void)btnAction:(VSSwitchButton *)sender{
    if (sender==_btnToggleAnonymous) {
        if(!sender.isON){
            _CS_NameHeight.constant +=30;
            _CS_SurnameHeight.constant +=30;
            _CS_AnonynmousHolderHeight.constant +=60;
            //[_btnAnonymousInfo setBackgroundImage:[UIImage imageNamed:@"infoicon"] forState:UIControlStateNormal];
            _lblAnonymous.text = [Localized string:@"sending_news_as"];
            _btnAnonymousInfo.hidden=YES;
        }else{
            _CS_NameHeight.constant -=30;
            _CS_SurnameHeight.constant -=30;
            _CS_AnonynmousHolderHeight.constant -=60;
            //[_btnAnonymousInfo setBackgroundImage:[UIImage imageNamed:@"infoicon_active"] forState:UIControlStateNormal];
            _btnAnonymousInfo.hidden=NO;
            _lblAnonymous.text = [Localized string:@"anonymous_sending"];
        }
        [self setLabelsWidth];
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                             
                         }];
    }else if (sender == _btnTogglePayPal) {
        if (sender.isON) {
            _CS_PayPalEmailHeight.constant +=30;
            _CS_PayPalViewHeight.constant +=30;
            //[_btnPayPalInfo setBackgroundImage:[UIImage imageNamed:@"infoicon_active"] forState:UIControlStateNormal];
            _btnPayPalInfo.hidden=YES;
        }else{
            _CS_PayPalEmailHeight.constant -=30;
            _CS_PayPalViewHeight.constant -=30;
            //[_btnPayPalInfo setBackgroundImage:[UIImage imageNamed:@"infoicon"] forState:UIControlStateNormal];
            _btnPayPalInfo.hidden=NO;
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}*/

- (void)btnAction:(UISwitch *)sender{
    if (sender==_swToggleAnonymoys) {
        if(!sender.isOn){
            _CS_NameHeight.constant +=30;
            _CS_SurnameHeight.constant +=30;
            _CS_AnonynmousHolderHeight.constant +=60;
            //[_btnAnonymousInfo setBackgroundImage:[UIImage imageNamed:@"infoicon"] forState:UIControlStateNormal];
            _lblAnonymous.text = [Localized string:@"sending_news_as"];
            _btnAnonymousInfo.hidden=YES;
        }else{
            _CS_NameHeight.constant -=30;
            _CS_SurnameHeight.constant -=30;
            _CS_AnonynmousHolderHeight.constant -=60;
            //[_btnAnonymousInfo setBackgroundImage:[UIImage imageNamed:@"infoicon_active"] forState:UIControlStateNormal];
            _btnAnonymousInfo.hidden=NO;
            _lblAnonymous.text = [Localized string:@"anonymous_sending"];
            if (_txtName.isFirstResponder) {
                [_txtName resignFirstResponder];
            }
            if (_txtSurname.isFirstResponder) {
                [_txtSurname resignFirstResponder];
            }
        }
        [self setLabelsWidth];
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                             
                         }];
    }else if (sender == _swTogglePayPal) {
        if (sender.isOn) {
            _CS_PayPalEmailHeight.constant +=30;
            _CS_PayPalViewHeight.constant +=30;
            //[_btnPayPalInfo setBackgroundImage:[UIImage imageNamed:@"infoicon_active"] forState:UIControlStateNormal];
            //_btnPayPalInfo.hidden=YES;
        }else{
            _CS_PayPalEmailHeight.constant -=30;
            _CS_PayPalViewHeight.constant -=30;
            //[_btnPayPalInfo setBackgroundImage:[UIImage imageNamed:@"infoicon"] forState:UIControlStateNormal];
            //_btnPayPalInfo.hidden=NO;
            if (_txtPayPalEmail.isFirstResponder) {
                [_txtPayPalEmail resignFirstResponder];
            }
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

- (void)btnInfo:(UIButton *)sender{
    if (sender==_btnAnonymousInfo) {
        [_btnAnonymousInfo setImage:[UIImage imageNamed:@"infoicon_active"] forState:UIControlStateNormal];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[Localized string:@"anonymous_info"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    }else if(sender==_btnPayPalInfo){
        [_btnPayPalInfo setImage:[UIImage imageNamed:@"infoicon_active"] forState:UIControlStateNormal];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[Localized string:@"connect_paypal_info"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [_btnPayPalInfo setImage:[UIImage imageNamed:@"infoicon"] forState:UIControlStateNormal];
    [_btnAnonymousInfo setImage:[UIImage imageNamed:@"infoicon"] forState:UIControlStateNormal];
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

#pragma mark TextField

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField==_txtName) {
        textField.placeholder = [Localized string:@"name"];
    }else if(textField == _txtSurname){
        textField.placeholder = [Localized string:@"surname"];
    }else if(textField == _txtPayPalEmail){
        textField.placeholder = [Localized string:@"paypal_email"];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.placeholder=nil;
}

#pragma mark Validation

- (BOOL)validateFields{
    BOOL dataOK = YES;
    if (!_swToggleAnonymoys.isOn) {
        if (_txtName.text.length==0) {
            _txtName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtName.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            dataOK=NO;
        }
        if (_txtSurname.text.length==0) {
            _txtSurname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtSurname.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            dataOK=NO;
        }
    }
    
    if (_swTogglePayPal.isOn) {
        if (_txtPayPalEmail.text.length==0) {
            _txtPayPalEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtPayPalEmail.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            dataOK=NO;
        }
    }
    
    return dataOK;
}

@end
