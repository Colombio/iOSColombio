/////////////////////////////////////////////////////////////
//
//  ForgotPasswordViewController.m
//  Armin Vrevic
//
//  Created by Colombio on 7/3/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Forgot password workflow class, user inputs email,
//  email is validated and sent to server
//  Response is validated, and presented to user
//
///////////////////////////////////////////////////////////////

#import "ForgotPasswordViewController.h"
#import "CreateAccViewController.h"
#import "LoginViewController.h"
#import "Messages.h"
#import "Validation.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

@synthesize headerViewHolder;
@synthesize scrollBox;
@synthesize imgBackground;
@synthesize txtEmail;
@synthesize btnSend;

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Adding custom header
    [headerViewHolder addSubview:[HeaderView initHeader:@"COLOMBIO" nextHidden:YES previousHidden:NO activeVC:self headerFrame:headerViewHolder.frame]];
    
    //If tapped anywhere on the scrollbox, keyboard is hidden
    [self.scrollBox setDelegate:self];
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAwayKeyboard:)];
    [scrollBox addGestureRecognizer:singleTap];
    
    //Extra setup of text fields
    txtEmail.txtField.delegate = self;
    [txtEmail setPlaceholderText:@"enter_email"];
    txtEmail.txtField.returnKeyType = UIReturnKeyGo;
    
    //Add custom loading spiner
    loadingView = [[Loading alloc] init];
}

#pragma mark KeyboardEvents

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtEmail.txtField becomeFirstResponder];
    [self btnForgotPassClicked:nil];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{            [txtEmail setPlaceholderText:txtEmail.placeholderText];
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

#pragma mark ForgotPassword

-(void)toggleSendOn{
    [btnSend setTitle:[Localized string:@"wait"] forState:UIControlStateNormal];
}

-(void)toggleSendOff{
    [btnSend setTitle:[Localized string:@"forgot_password"] forState:UIControlStateNormal];
    [loadingView removeCustomSpinner];
}

/**
 *
 *  When user clicks on forgot password, send the password to
 *  web service and validate response
 */
- (IBAction)btnForgotPassClicked:(id)sender{
    [self.view endEditing:YES];
    [loadingView startCustomSpinner:self.view spinMessage:@""];
    [UIView animateWithDuration:0.8 animations:^{
        [btnSend setTitle:[Localized string:@"wait"] forState:UIControlStateNormal];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(sendPassword) userInfo:nil repeats:NO];
}

/**
 *  Method that sends password to server
 *
 */
- (void)sendPassword{
    strEmail =txtEmail.txtField.text;
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    
    [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_user_managment/mau_normal_register/", BASE_URL] httpBody:[NSString stringWithFormat:@"%@/api_user_managment/mau_pass_recovery?user_email=%@",BASE_URL,strEmail]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            Boolean isWrongInput = false;
            
            bool wrongEmail=NO;
            
            if(strEmail.length<1){
                wrongEmail=YES;
                strEmail=@"b";
            }
            
            if(error){
                [Messages showErrorMsg:@"error_web_request"];
                [loadingView stopCustomSpinner];
                [loadingView customSpinnerFail];
            }
            
            //Request sent successfuly, check response
            else{
                NSDictionary *dataWsResponse=nil;
                dataWsResponse =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[dataWsResponse allKeys];
                //Check wrong answers
                for(NSString *key in keys){
                    //Check for errors in validation
                    if(!strcmp("s", key.UTF8String)){
                        NSString *error = [dataWsResponse objectForKey:@"s"];
                        if(!(strcmp("0",error.UTF8String))){
                            NSString *errMessage= [dataWsResponse objectForKey:@"msg"];
                            wrongEmail=YES;
                            isWrongInput=true;
                            if(!strcmp("no_match", errMessage.UTF8String)){
                                [txtEmail setErrorText:@"email_null"];
                            }
                            else if(!strcmp("user_banned", errMessage.UTF8String)){
                                [txtEmail setErrorText:@"email_banned"];
                            }
                        }
                        break;
                    }
                }
                
                if(![Validation validateEmail:[txtEmail.txtField text]]&&wrongEmail==YES) {
                    isWrongInput=true;
                    [txtEmail setErrorText:@"error_email_format"];
                }
                
                //All data is entered in a valid format
                [loadingView stopCustomSpinner];
                if(!isWrongInput){
                    [txtEmail setOkInput];
                    [loadingView customSpinnerSuccess];
                    timer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(forgotPasswordSuccessful) userInfo:nil repeats:NO];
                }
                else{
                    [loadingView customSpinnerFail];
                }
            }
            timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(toggleSendOff) userInfo:nil repeats:NO];
        });
        
    }];
}

- (void)forgotPasswordSuccessful{
    //TODO show message
}

@end
