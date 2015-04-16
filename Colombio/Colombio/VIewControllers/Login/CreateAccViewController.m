/////////////////////////////////////////////////////////////
//
//  CreateAccountViewController.m
//  Armin Vrevic
//
//  Created by Colombio on 7/3/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  View controller for user registering
//
///////////////////////////////////////////////////////////////

#import "CreateAccViewController.h"
#import "LoginViewController.h"
#import "Messages.h"
#import "Validation.h"
#import "CountriesViewController.h"
#import "Localized.h"
#import "AppDelegate.h"

@interface CreateAccViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_TermsWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_PrivacyWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_AndWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_AlreadyHaveAccWidth;

@property (weak, nonatomic) IBOutlet UIButton *btnTerms;
@property (weak, nonatomic) IBOutlet UIButton *btnPrivacy;
@property (weak, nonatomic) IBOutlet UILabel *lblAnd;
@property (weak, nonatomic) IBOutlet UILabel *lblAlreadyHaveAcc;

@end

@implementation CreateAccViewController

@synthesize scrollBox;
@synthesize txtConfirmPass;
@synthesize txtEmail;
@synthesize txtPassword;
@synthesize txtUsername;
@synthesize btnCreate;
@synthesize imgBackground;
@synthesize headerViewHolder;



- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add the custom header
    HeaderView *headerView = [HeaderView initHeader:@"COLOMBIO" nextHidden:YES previousHidden:NO activeVC:self headerFrame:headerViewHolder.frame];
    [headerView.btnBack setBackgroundImage:[UIImage imageNamed:@"backwhite_normal"] forState:UIControlStateNormal];
    [headerView.btnBack setBackgroundImage:[UIImage imageNamed:@"backwhite_pressed"] forState:UIControlStateHighlighted];
    [headerViewHolder addSubview:headerView];
    
    //For keyboard hiding on tap
    [self.scrollBox setDelegate:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    //Aditional setup of text fields
    [self setupTextFields];
    [self setLabelsPositions];
    
    //Adding custom event on keyboard hide
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Adding the custom loading view
    loadingView = [[Loading alloc] init];
}

- (void)setLabelsPositions{
    CGFloat maxTermsWidth = _CS_TermsWidth.constant;
    CGFloat maxPrivacyWidth = _CS_PrivacyWidth.constant;
    CGFloat maxAndWidth = _CS_AndWidth.constant;
    
    CGSize size = [_btnTerms.titleLabel.text sizeWithFont:_btnTerms.titleLabel.font constrainedToSize:CGSizeMake(maxTermsWidth, 20) lineBreakMode:NSLineBreakByWordWrapping];
    _CS_TermsWidth.constant = size.width;
    
    size = [_lblAnd.text sizeWithFont:_lblAnd.font constrainedToSize:CGSizeMake(maxAndWidth, 20) lineBreakMode:NSLineBreakByWordWrapping];
    _CS_AndWidth.constant = size.width;
    
    size = [_btnPrivacy.titleLabel.text sizeWithFont:_btnPrivacy.titleLabel.font constrainedToSize:CGSizeMake(maxPrivacyWidth, 20) lineBreakMode:NSLineBreakByWordWrapping];
    
    _btnTerms.titleLabel.numberOfLines = 1;
    _btnTerms.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    _lblAnd.numberOfLines = 1;
    _lblAnd.adjustsFontSizeToFitWidth = YES;
    
    _btnPrivacy.titleLabel.numberOfLines = 1;
    _btnPrivacy.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    size = [_lblAlreadyHaveAcc.text sizeWithFont:_lblAlreadyHaveAcc.font constrainedToSize:CGSizeMake(_lblAlreadyHaveAcc.bounds.size.width, 20) lineBreakMode:NSLineBreakByWordWrapping];
    _CS_AlreadyHaveAccWidth.constant = size.width;

    
    
}

#pragma mark TextFields

- (void)setupTextFields{
    //Setting up text field delegates
    txtUsername.txtField.delegate = self;
    txtEmail.txtField.delegate = self;
    txtPassword.txtField.delegate = self;
    txtConfirmPass.txtField.delegate = self;
    
    //Adding the id-s so particular textfields
    //can be identified by id
    txtUsername.txtField.tag=1;
    txtEmail.txtField.tag=2;
    txtPassword.txtField.tag=3;
    txtConfirmPass.txtField.tag=4;
    
    //Adding placeholder
    [txtUsername setPlaceholderText:@"enter_username"];
    [txtEmail setPlaceholderText:@"enter_email"];
    [txtPassword setPlaceholderText:@"enter_password"];
    [txtConfirmPass setPlaceholderText:@"enter_confirm_password"];
    
    //Password text
    txtPassword.txtField.secureTextEntry=YES;
    txtConfirmPass.txtField.secureTextEntry=YES;
    
    //Return key
    txtConfirmPass.txtField.returnKeyType = UIReturnKeyGo;
}

#pragma mark KeyboardEvents

/**
 *
 * If keyboard is hidden, prevent scroll view from scrolling
 *
 */
-(void)onKeyboardHide:(NSNotification *)notification
{
    scrollBox.contentSize = CGSizeMake(scrollBox.frame.size.width,scrollBox.frame.size.height);
}

/**
 *
 * If next/done clicked
 *
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case 1:
            [txtEmail.txtField becomeFirstResponder];
            break;
        case 2:
            [txtPassword.txtField becomeFirstResponder];
            break;
        case 3:
            [txtConfirmPass.txtField becomeFirstResponder];
            break;
        case 4:
            [txtConfirmPass.txtField resignFirstResponder];
            [self btnCreateAccClicked:nil];
            break;
    }
    return NO;
}

/**
 *  When text field starts editing, reset placeholder and remove error text
 *
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //scrollBox.contentSize = CGSizeMake(scrollBox.frame.size.width,self.view.frame.size.height+210);
    switch (textField.tag) {
        case 1:
            [txtUsername setPlaceholderText:txtUsername.placeholderText];
            break;
        case 2:
            [txtEmail setPlaceholderText:txtEmail.placeholderText];
            break;
        case 3:
            [txtPassword setPlaceholderText:txtPassword.placeholderText];
            break;
        case 4:
            [txtConfirmPass setPlaceholderText:txtConfirmPass.placeholderText];
            break;
    }
}

#pragma mark Keyboard

- (void)keyboardUp:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    UIEdgeInsets contentInset = scrollBox.contentInset;
    contentInset.bottom = keyboardRect.size.height;
    scrollBox.contentInset = contentInset;
}

- (void)keyboardDown:(NSNotification*)notification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollBox.contentInset = contentInsets;
    scrollBox.scrollIndicatorInsets = contentInsets;
}

- (void)goAwayKeyboard:(UITapGestureRecognizer *)gesture{
    [self.view endEditing:YES];
}

#pragma mark Navigation

- (void)backButtonTapped{
    [self.view endEditing:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnBackClicked:(id)sender{
    [self backButtonTapped];
}

#pragma mark CreateAccount

- (void)toggleCreateOff{
    [btnCreate setTitle:[Localized string:@"create_account"] forState:UIControlStateNormal];
    [loadingView removeCustomSpinner];
}

/**
 *
 *  Check input data and try to register user
 *
 */
- (void)checkRegister{
    strEmail =txtEmail.txtField.text;
    strUsername = txtUsername.txtField.text;
    strConfirmPass = txtConfirmPass.txtField.text;
    strPassword =txtPassword.txtField.text;
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_user_managment/mau_normal_register/", BASE_URL] httpBody:[NSString stringWithFormat:@"user_name=%@&user_email=%@&user_pass=%@&cpassword=%@",strUsername,strEmail,strPassword, strConfirmPass]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            Boolean isWrongInput = false;
            
            bool wrongEmail=NO;
            bool wrongUser=NO;
            
            //Dummy data if wrong input
            if(strEmail.length<1){
                wrongEmail=YES;
                strEmail=@"b";
            }
            if(strUsername.length<1){
                wrongUser=YES;
                strUsername=@"b";
            }
            if(strConfirmPass.length<1)
                strConfirmPass=@"b";
            if(strPassword.length<1)
                strPassword=@"b";
            
            //Error occured during http request
            if(error){
                [Messages showErrorMsg:@"error_web_request"];
                [loadingView stopCustomSpinner];
                [loadingView customSpinnerFail];
            }
            
            //Request is successfuly sent
            else{
                NSDictionary *dataWsResponse=nil;
                dataWsResponse =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[dataWsResponse allKeys];
                //Check for wrong answers
                for(NSString *key in keys){
                    //Validate login
                    if(!strcmp("errors", key.UTF8String)){
                        NSArray *arrayWsErrors = [dataWsResponse objectForKey:@"errors"];
                        for(NSString *greska in arrayWsErrors){
                            //Duplikat usernamea
                            if(!strcmp("username_exists", greska.UTF8String)&&wrongUser==NO){
                                [txtUsername setErrorText:@"error_username_exists"];
                                isWrongInput=true;
                                wrongUser=YES;
                            }
                            //Password strength is wrong
                            if(!strcmp("pass_str_fail", greska.UTF8String)){
                                [txtPassword setErrorText:@"error_password"];
                                isWrongInput=true;
                            }
                            //Email duplicate
                            if(!strcmp("email_exists", greska.UTF8String)&& ![txtEmail.txtField.text isEqualToString:@"b"]&&wrongEmail==NO){
                                wrongEmail=YES;
                                [txtEmail setErrorText:@"error_email_exists"];
                                isWrongInput=true;
                            }
                        }
                        break;
                    }
                }
                //If all data is successfuly entered
                [loadingView stopCustomSpinner];
                if(!isWrongInput){
                    [loadingView customSpinnerSuccess];
                    [self createAccSuccessful];
                }
                else{
                    [loadingView customSpinnerFail];
                }
            }
            timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(toggleCreateOff) userInfo:nil repeats:NO];
        });
        
    }];
}

- (void)createAccSuccessful{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnCreateAccClicked:(id)sender{
    if ([self validateFields]) {
        [self.view endEditing:YES];
        [loadingView startCustomSpinner:self.view spinMessage:@"logged"];
        [UIView animateWithDuration:0.8 animations:^{
            [btnCreate setTitle:[Localized string:@"wait"] forState:UIControlStateNormal];
        }];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkRegister) userInfo:nil repeats:NO];
    }
}

#pragma mark Validation
- (BOOL)validateFields{
    BOOL fieldsOK = YES;
    if(![Validation validateEmail:[txtEmail.txtField text]]) {
        fieldsOK=NO;
        [txtEmail setErrorText:@"error_email_format"];
    }
    //Password length is wrong
    if(txtPassword.txtField.text.length<8){
        fieldsOK=NO;
        [txtPassword setErrorText:@"error_password"];
    }
    //Password is empty or it doesnt match
    if(!strcmp([txtConfirmPass.txtField text].UTF8String,@"".UTF8String) || strcmp([txtConfirmPass.txtField text].UTF8String,[txtPassword.txtField text].UTF8String)){
        
        [txtConfirmPass setErrorText:@"error_confirm_password"];
    }
    //Password confirm is empty
    if(!strcmp([txtUsername.txtField text].UTF8String,@"".UTF8String)){
        fieldsOK=NO;
        [txtUsername setErrorText:@"error_username_format"];
    }
    
    return fieldsOK;
    
}

#pragma mark Button Action

- (IBAction)btnTermsClicked:(id)sender{

}

- (IBAction)btnPrivacyClicked:(id)sender{

}

@end
