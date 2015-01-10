//
//  ForgotPassword.m
//  Colombio
//
//  Created by Colombio on 7/3/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Kontroler za zaboravljenu lozinku
//
//  TODO Provjeriti duplikat na web servisu i ispraviti UI sukladno tome,
//  Chekirati za error messagese

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Dodavanje headera
    [headerViewHolder addSubview:[HeaderView initHeader:@"COLOMBIO" nextHidden:YES previousHidden:NO activeVC:self headerFrame:headerViewHolder.frame]];
    
    //Ako se tapne bilo gdje drugdje na scrollbox, makne se tipkovnica
    [self.scrollBox setDelegate:self];
    
    //Kada se klikne na scrollview da se makne tipkovnica
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAwayKeyboard:)];
    [scrollBox addGestureRecognizer:singleTap];
    
    //Dodatno podešavanje tekstualnih okvira
    txtEmail.txtField.delegate = self;
    [txtEmail setPlaceholderText:@"enter_email"];
    txtEmail.txtField.returnKeyType = UIReturnKeyGo;
    
    loadingView = [[Loading alloc] init];
}

#pragma mark KeyboardEvents

//Kada se klikne next/done na tipkovnici
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtEmail.txtField becomeFirstResponder];
    [self btnForgotPassClicked:nil];
    return NO;
}

//Kada se pocne editirati neki text field, resetira se natrag originalni placeholder i makne se error img
- (void)textFieldDidBeginEditing:(UITextField *)textField{            [txtEmail setPlaceholderText:txtEmail.placeholderText];
}

//Ako se napravi tap na pozadinu, mice se tipkovnica i scrolla se view
- (void)goAwayKeyboard:(UITapGestureRecognizer *)gesture{
    [self.view endEditing:YES];
}

#pragma mark Navigation

//Header back delegate
- (void)backButtonTapped{
    [self.view endEditing:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

//IB button back
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

- (IBAction)btnForgotPassClicked:(id)sender{
    [self.view endEditing:YES];
    [loadingView startCustomSpinner:self.view spinMessage:@""];
    [UIView animateWithDuration:0.8 animations:^{
        [btnSend setTitle:[Localized string:@"wait"] forState:UIControlStateNormal];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(sendPassword) userInfo:nil repeats:NO];
}

- (void)sendPassword{
    strEmail =txtEmail.txtField.text;
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    
    [csc sendAsyncHttp:@"https://appforrest.com/colombio/api_user_managment/mau_normal_register/" httpBody:[NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_pass_recovery?user_email=%@",strEmail]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
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
            }
            
            //Uspjesno je poslan zahtjev, provjeri odgovor
            else{
                NSDictionary *dataWsResponse=nil;
                dataWsResponse =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[dataWsResponse allKeys];
                //Provjeravanje pogresnih odgovora
                for(NSString *key in keys){
                    //Provjera za ispravnost prijave
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
                
                //Ako su svi podaci ispravno upisani
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
