//
//  CreateAcc.m
//  Colombio
//
//  Created by Colombio on 7/3/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Kontroler za kreiranje korisnickog racuna
//
//  TODO ispraviti odredene dijelove zbog web servisa

#import "CreateAccViewController.h"
#import "LoginViewController.h"
#import "Messages.h"
#import "Validation.h"
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
    [self setupTextFields];
    
    //Dodavanje eventa kada se sakrije tipkovnica
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    loadingView = [[Loading alloc] init];
}

#pragma mark TextFields

- (void)setupTextFields{
    //Postavljanje delegata
    txtUsername.txtField.delegate = self;
    txtEmail.txtField.delegate = self;
    txtPassword.txtField.delegate = self;
    txtConfirmPass.txtField.delegate = self;
    
    //Dodavanje identifikatora
    txtUsername.txtField.tag=1;
    txtEmail.txtField.tag=2;
    txtPassword.txtField.tag=3;
    txtConfirmPass.txtField.tag=4;
    
    //Upisivanje placeholdera
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

//Kad se sakrije tipkovnica makne se skrolabilnost viewa
-(void)onKeyboardHide:(NSNotification *)notification
{
    scrollBox.contentSize = CGSizeMake(scrollBox.frame.size.width,scrollBox.frame.size.height);
}

//Kada se klikne next/done na tipkovnici
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

//Kada se pocne editirati neki text field, resetira se natrag originalni placeholder i makne se error img
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

#pragma mark CreateAccount

- (void)toggleCreateOff{
    [btnCreate setTitle:[Localized string:@"create_account"] forState:UIControlStateNormal];
    [loadingView removeCustomSpinner];
}

- (void)checkRegister{
    strEmail =txtEmail.txtField.text;
    strUsername = txtUsername.txtField.text;
    strConfirmPass = txtConfirmPass.txtField.text;
    strPassword =txtPassword.txtField.text;
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    [csc sendAsyncHttp:@"https://appforrest.com/colombio/api_user_managment/mau_normal_register/" httpBody:[NSString stringWithFormat:@"user_name=%@&user_email=%@&user_pass=%@&cpassword=%@",strUsername,strEmail,strPassword, strConfirmPass]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *empty = @"";
            Boolean isWrongInput = false;
            
            bool wrongEmail=NO;
            bool wrongUser=NO;
            
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
            
            //NSString *nsJson = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //Dogodila se pogreska prilikom dohvacanja zahtjeva
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
                    if(!strcmp("errors", key.UTF8String)){
                        NSArray *arrayWsErrors = [dataWsResponse objectForKey:@"errors"];
                        for(NSString *greska in arrayWsErrors){
                            //Duplikat usernamea
                            if(!strcmp("username_exists", greska.UTF8String)&&wrongUser==NO){
                                [txtUsername setErrorText:@"error_username_exists"];
                                isWrongInput=true;
                                wrongUser=YES;
                            }
                            //Snaga lozinke nije ok
                            if(!strcmp("pass_str_fail", greska.UTF8String)){
                                [txtPassword setErrorText:@"error_password"];
                                isWrongInput=true;
                            }
                            //Duplikat emaila
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
                //Duljina lozinke je kriva
                if(txtPassword.txtField.text.length<8){
                    isWrongInput=true;
                    [txtPassword setErrorText:@"error_password"];
                }
                //Lozinka je prazna ili lozinke ne matchaju
                if(!strcmp([txtConfirmPass.txtField text].UTF8String,empty.UTF8String) || strcmp([txtConfirmPass.txtField text].UTF8String,[txtPassword.txtField text].UTF8String)){
                    isWrongInput=true;
                    [txtConfirmPass setErrorText:@"error_confirm_password"];
                }
                //Potvrda lozinke je prazna
                if(!strcmp([txtUsername.txtField text].UTF8String,empty.UTF8String)&&wrongUser==YES){
                    isWrongInput=true;
                    [txtUsername setErrorText:@"error_username_format"];
                }
                
                //Ako su svi podaci ispravno upisani
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
    //TODO GOTO Countries
}

//Ako se klikne na create account
- (IBAction)btnCreateAccClicked:(id)sender{
    [self.view endEditing:YES];
    [loadingView startCustomSpinner:self.view spinMessage:@"logged"];
    [UIView animateWithDuration:0.8 animations:^{
        [btnCreate setTitle:[Localized string:@"wait"] forState:UIControlStateNormal];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkRegister) userInfo:nil repeats:NO];
}

@end
