//
//  UserInfoUploadViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 28/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UserInfoUploadViewController.h"

@interface UserInfoUploadViewController ()

@property (assign, nonatomic) BOOL isNewsDemand;
@end

@implementation UserInfoUploadViewController

- (instancetype)initWithDemand:(BOOL)isNewsDemand{
    self = [super init];
    if (self) {
        _isNewsDemand=isNewsDemand;
        self.title = [Localized string:@"send_news"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    _txtPhoneNum.inputAccessoryView = [self keyboardToolbarFor:_txtPhoneNum action:@selector(resignFirstResponder)];
    _txtContactMe.inputAccessoryView = [self keyboardToolbarFor:_txtContactMe action:@selector(resignFirstResponder)];
    _txtPrice.inputAccessoryView = [self keyboardToolbarFor:_txtPrice action:@selector(resignFirstResponder)];
    
    _be_credited=YES;
    if (_isNewsDemand) {
        _btnTogglePrice.hidden=YES;
        _lblPrice.text = [NSString stringWithFormat:[Localized string:@"media_price_offer"],_cost];
        _lblDisclamer.text = [Localized string:@"media_may_or_not"];
    }else{
        _btnTogglePrice.hidden=NO;
        _lblPrice.text = [Localized string:@"i_want_sell"];
        _lblDisclamer.text = [Localized string:@"media_only_one"];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark setup;
- (void)setBeCrediteImage{
    if (!_be_credited) {
        _imgSigned.image = [UIImage imageNamed:@"selected"];
        _be_credited=YES;
    }else{
        _be_credited=NO;
        _imgSigned.image=nil;
    }
}

#pragma mark Button Action
- (void)btnAction:(VSSwitchButton*)sender{
    if (sender==_btnTogglePrice) {
        [self.view layoutIfNeeded];
        if(sender.isON){
            _CS_NameYourPriceHeight.constant +=30;
            _CS_PriceHolderHeight.constant +=30;
             _lblDisclamer.text = [Localized string:@"media_only_one"];
        }else{
            _CS_NameYourPriceHeight.constant -=30;
            _CS_PriceHolderHeight.constant -=30;
             _lblDisclamer.text = [Localized string:@"media_may_or_not"];
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                        }];
        [UIView transitionWithView:_lblDisclamer
                          duration:0.5
                           options:UIViewAnimationOptionAllowAnimatedContent
                        animations:NULL
                        completion:NULL];
    }else if (sender==_btnToggleAnonymous){
        if(sender.isON){
            _CS_NameHeight.constant +=30;
            _CS_PhoneNumHeight.constant +=30;
            _CS_AnonynmousHolderHeight.constant +=60;
        }else{
            _CS_NameHeight.constant -=30;
            _CS_PhoneNumHeight.constant -=30;
            _CS_AnonynmousHolderHeight.constant -=60;
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }else if (sender==_btnToggleContactMe){
        if(sender.isON){
            _CS_ContactMePhoneHeight.constant +=30;
            _CS_ContactMeHeight.constant +=30;
        }else{
            _CS_ContactMePhoneHeight.constant -=30;
            _CS_ContactMeHeight.constant -=30;
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

- (void)btnBeCredited:(id)sender{
    [self setBeCrediteImage];
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
@end
