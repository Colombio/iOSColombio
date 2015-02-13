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

@interface CreateAccViewController ()

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
    [headerViewHolder addSubview:[HeaderView initHeader:@"COLOMBIO" nextHidden:YES previousHidden:NO activeVC:self headerFrame:headerViewHolder.frame]];
    
    //For keyboard hiding on tap
    [self.scrollBox setDelegate:self];
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAwayKeyboard:)];
    [scrollBox addGestureRecognizer:singleTap];
    
    //Aditional setup of text fields
    [self setupTextFields];
    
    //Adding custom event on keyboard hide
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Adding the custom loading view
    loadingView = [[Loading alloc] init];
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
    scrollBox.contentSize = CGSizeMake(scrollBox.frame.size.width,self.view.frame.size.height+210);
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
            NSString *empty = @"";
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
                if(![Validation validateEmail:[txtEmail.txtField text]]&&wrongEmail==YES) {
                    isWrongInput=true;
                    [txtEmail setErrorText:@"error_email_format"];
                }
                //Password length is wrong
                if(txtPassword.txtField.text.length<8){
                    isWrongInput=true;
                    [txtPassword setErrorText:@"error_password"];
                }
                //Password is empty or it doesnt match
                if(!strcmp([txtConfirmPass.txtField text].UTF8String,empty.UTF8String) || strcmp([txtConfirmPass.txtField text].UTF8String,[txtPassword.txtField text].UTF8String)){
                    isWrongInput=true;
                    [txtConfirmPass setErrorText:@"error_confirm_password"];
                }
                //Password confirm is empty
                if(!strcmp([txtUsername.txtField text].UTF8String,empty.UTF8String)&&wrongUser==YES){
                    isWrongInput=true;
                    [txtUsername setErrorText:@"error_username_format"];
                }
                
                //If all data is successfuly entered
                [loadingView stopCustomSpinner];
                if(!isWrongInput){
                    [loadingView customSpinnerSuccess];
                    timer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(createAccSuccessful) userInfo:nil repeats:NO];
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
    CountriesViewController *countries = [[CountriesViewController alloc]init];
    [self presentViewController:countries animated:YES completion:nil];
}

- (IBAction)btnCreateAccClicked:(id)sender{
    [self.view endEditing:YES];
    [loadingView startCustomSpinner:self.view spinMessage:@"logged"];
    [UIView animateWithDuration:0.8 animations:^{
        [btnCreate setTitle:[Localized string:@"wait"] forState:UIControlStateNormal];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkRegister) userInfo:nil repeats:NO];
}

@end
