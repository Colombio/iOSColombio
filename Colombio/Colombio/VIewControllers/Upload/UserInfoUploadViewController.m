//
//  UserInfoUploadViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 28/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UserInfoUploadViewController.h"
#import "AppDelegate.h"

@interface UserInfoUploadViewController ()

@property (assign, nonatomic) BOOL isNewsDemand;
@property (assign, nonatomic) BOOL picExists;
@property (strong, nonatomic) NSString *newsTaskPrice;
@end

@implementation UserInfoUploadViewController

- (instancetype)initWithDemand:(BOOL)isNewsDemand withPrice:(NSString*)price{
    self = [super init];
    if (self) {
        _isNewsDemand=isNewsDemand;
        _newsTaskPrice = price;
        self.title = [Localized string:@"send_news"];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pictureExists:) name:@"DoestThePictureExist" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setDBData];
    //_txtPhoneNum.inputAccessoryView = [self keyboardToolbarFor:_txtPhoneNum action:@selector(resignFirstResponder)];
    _txtContactMe.inputAccessoryView = [self keyboardToolbarFor:_txtContactMe action:@selector(resignFirstResponder)];
    _txtPrice.inputAccessoryView = [self keyboardToolbarFor:_txtPrice action:@selector(resignFirstResponder)];
    
    _be_credited=NO;
    if (_isNewsDemand) {
        _swTogglePrice.hidden=YES;
        _lblPrice.text = [NSString stringWithFormat:[Localized string:@"media_price_offer"],_newsTaskPrice];
        _lblDisclamer.text = [Localized string:@"media_may_or_not"];
    }else{
        //_txtPrice.placeholder = [NSString stringWithFormat:[Localized string:@"name_price"], maxPrice];
        _lblPrice.text = [Localized string:@"i_want_sell"];
        _lblDisclamer.text = [Localized string:@"media_only_one"];
    }
    [self setFieldValues];
    [self switchLogic];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    if(!_isNewsDemand){
        if (_picExists) {
            _CS_PriceHolderHeight.constant = 65.0;
            _viewH1.hidden=NO;
            _viewPriceHolder.hidden=NO;
        }else{
            _CS_PriceHolderHeight.constant = 0.0;
            _viewH1.hidden=YES;
            _viewPriceHolder.hidden=YES;
        }
    }
}

- (void)setTextFields{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdelegate.db getRowForSQL:@"SELECT first_name, last_name, phone_number FROM user"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchLogic{
    if (_swToggleAnonymous.isOn) {
        _swToggleBeSigned.enabled=NO;
        _swToggleContactMe.enabled=NO;
    }else{
        _swToggleBeSigned.enabled=YES;
        _swToggleContactMe.enabled=YES;
    }
    
    if (_swToggleBeSigned.isOn || _swToggleContactMe.isOn) {
        _swToggleAnonymous.enabled=NO;
    }else{
        _swToggleAnonymous.enabled=YES;
    }
    
}

#pragma mark setup;

- (void)setFieldValues{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary *tDict = [appdelegate.db getRowForSQL:@"Select * from user"];
    
    if (tDict) {
        _txtName.text = tDict[@"first_name"];
        _txtSurname.text = tDict[@"last_name"];
        _txtContactMe.text = tDict[@"phone_number"];
        [_swToggleAnonymous setOn:[tDict[@"anonymous"] boolValue]];
        if (!_swToggleAnonymous.isOn) {
            _CS_NameHeight.constant +=30;
            _CS_PhoneNumHeight.constant +=30;
            _CS_AnonynmousHolderHeight.constant +=60;
            [self.view layoutIfNeeded];
        }
    }
}

#pragma mark Button Action
- (void)btnAction:(UISwitch*)sender{
    if (sender==_swTogglePrice) {
        [self.view layoutIfNeeded];
        if(sender.isOn){
            //_CS_NameYourPriceHeight.constant +=30;
            _CS_PriceHolderHeight.constant +=30;
            _lblDisclamer.hidden=NO;
        }else{
            //_CS_NameYourPriceHeight.constant -=30;
            _CS_PriceHolderHeight.constant -=30;
            _lblDisclamer.hidden=YES;
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
        /*[UIView transitionWithView:_lblDisclamer
                          duration:0.5
                           options:UIViewAnimationOptionAllowAnimatedContent
                        animations:NULL
                        completion:NULL];*/
    }else if (sender==_swToggleAnonymous){
        if(!sender.isOn){
            _CS_NameHeight.constant +=30;
            _CS_PhoneNumHeight.constant +=30;
            _CS_AnonynmousHolderHeight.constant +=60;
        }else{
            _CS_NameHeight.constant -=30;
            _CS_PhoneNumHeight.constant -=30;
            _CS_AnonynmousHolderHeight.constant -=60;
            if (_txtName.isFirstResponder) {
                [_txtName resignFirstResponder];
            }
            if (_txtSurname.isFirstResponder) {
                [_txtSurname resignFirstResponder];
            }
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }else if (sender==_swToggleContactMe){
        if(sender.isOn){
            _CS_ContactMePhoneHeight.constant +=30;
            _CS_ContactMeHeight.constant +=30;
        }else{
            _CS_ContactMePhoneHeight.constant -=30;
            _CS_ContactMeHeight.constant -=30;
            if (_txtContactMe.isFirstResponder) {
                [_txtContactMe resignFirstResponder];
            }
            
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }else if (sender==_swToggleBeSigned){
        _be_credited = _swToggleBeSigned.isOn;
    }
    [self switchLogic];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField==_txtPrice) {
        _price = [_txtPrice.text substringFromIndex:_txtPrice.text.length-1];
    }
    return YES;
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

- (BOOL)validateFields{
    BOOL dataOK = YES;
    /*if (_btnTogglePrice.isON) {
        if (_txtPrice.text.length==0 || [_txtPrice.text isEqualToString:@"."]) {
            _txtPrice.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtPrice.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            dataOK=NO;
        }
    }*/
    if (_swToggleAnonymous.isOn) {
        if (_txtName.text.length==0) {
            _txtName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtName.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            dataOK=NO;
        }
        if (_txtSurname.text.length==0) {
            _txtSurname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtSurname.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            dataOK=NO;
        }
        /*if (_txtPhoneNum.text.length==0) {
         _txtPhoneNum.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtPhoneNum.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
         dataOK=NO;
         }*/
    }
    if (_swToggleContactMe.isOn) {
        if (_txtContactMe.text.length==0) {
            _txtContactMe.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_txtContactMe.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            dataOK=NO;
        }
    }
    return dataOK;
}

#pragma mark GetDB Data

- (void)setDBData{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *sql = @"select * from user";
    
    NSMutableDictionary *dict = [appdelegate.db getRowForSQL:sql];
    if (((NSString*)dict[@"first_name"]).length>0) {
        _txtName.text = dict[@"first_name"];
    }
    if (((NSString*)dict[@"last_name"]).length>0) {
        _txtSurname.text = dict[@"last_name"];
    }
    if (((NSString*)dict[@"phone_number"]).length>0) {
        _txtContactMe.text = dict[@"phone_number"];
    }
}

#pragma mark CustomObserver

- (void)pictureExists:(NSNotification*)notification{
    _picExists = [notification.userInfo[@"picexistance"] boolValue];
}
@end
