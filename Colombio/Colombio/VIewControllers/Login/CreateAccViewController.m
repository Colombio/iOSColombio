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

//Metoda koja vraca true ili false ovisno o tome je li tipkovnica aktivna
- (BOOL)isKeyboardActive{
    if([txtUsername.txtField isFirstResponder]||[txtEmail.txtField isFirstResponder]||[txtPassword.txtField isFirstResponder]||[txtConfirmPass.txtField isFirstResponder]){
        return YES;
    }
    return NO;
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

//Kada se pojavi tipkovnica, omoguci se skrolabilnost kako bi se mogao pregledati cijeli view
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    scrollBox.contentSize = CGSizeMake(scrollBox.frame.size.width,self.view.frame.size.height+210);
}

//Ako se napravi tap na pozadinu, mice se tipkovnica i scrolla se view
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
    [btnCreate setTitle:@"Create account" forState:UIControlStateNormal];
    [loadingView removeCustomSpinner];
}

/*
- (void)checkRegister{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(disableKeyboardActivity) userInfo:nil repeats:NO];
    
    NSString *empty = @"";
    Boolean wrong = false;
    
    //Slanje podataka za prijavu i dohvacanje odgovora
    NSString *url_str = [NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_normal_register/"];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *email =txtEmail.text;
    NSString *username = txtUsername.text;
    NSString *confirmPass = txtConfirmPass.text;
    NSString *pass =txtPassword.text;
    
    bool wrongEmail=NO;
    bool wrongUs er=NO;
    if(email.length<1){
        wrongEmail=YES;
        email=@"b";
    }
    if(username.length<1){
        wrongUser=YES;
        username=@"b";
    }
    if(confirmPass.length<1){
        confirmPass=@"b";
    }
    if(pass.length<1){
        pass=@"b";
    }
    
    [request setHTTPBody:[[NSString stringWithFormat:@"user_name=%@&user_email=%@&user_pass=%@&cpassword=%@",username,email,pass, confirmPass]dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    //NSString *nsJson = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //Dogodila se pogreska prilikom dohvacanja zahtjeva
    if(err){
        [Messages showErrorMsg:@"Pogreška prilikom slanja zahtjeva"];
    }
    
    //Uspjesno je poslan zahtjev, provjeri odgovor
    else{
        Boolean pogreska=false;
        NSDictionary *odgovor=nil;
        odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSArray *keys =[odgovor allKeys];
        //Provjeravanje pogresnih odgovora
        for(NSString *key in keys){
            //Provjera za ispravnost prijave
            if(!strcmp("errors", key.UTF8String)){
                NSArray *errors = [odgovor objectForKey:@"errors"];
                for(NSString *greska in errors){
                    //Duplikat usernamea
                    if(strcmp("username_exists", greska.UTF8String)&&wrongUser==NO){
                        UIColor *color = [UIColor redColor];
                        txtUsername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username already exists" attributes:@{NSForegroundColorAttributeName:color}];
                        txtUsername.text=@"";
                        wrong=true;
                        wrongUser=NO;
                    }
                    //Snaga lozinke nije ok
                    if(strcmp("pass_str_fail", greska.UTF8String)){
                        UIColor *color = [UIColor redColor];
                        txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"8 characters, 1 caps, 1 number" attributes:@{NSForegroundColorAttributeName:color}];
                        txtPassword.text=@"";
                        wrong=true;
                    }
                    //Duplikat emaila
                    if(strcmp("email_exists", greska.UTF8String)&& ![txtEmail.text isEqualToString:@"b"]&&wrongEmail==NO){
                        wrongEmail=NO;
                        UIColor *color = [UIColor redColor];
                        txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email already exists" attributes:@{NSForegroundColorAttributeName:color}];
                        txtEmail.text=@"";
                        wrong=true;
                    }
                }
                pogreska=true;
                break;
            }
        }
        if(![Validation validateEmail:[txtEmail text]]&&wrongEmail==YES) {
            wrong=true;
            UIColor *color = [UIColor redColor];
            txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Wrong email format" attributes:@{NSForegroundColorAttributeName:color}];
            txtEmail.text=@"";
        }
        //Duljina lozinke je kriva
        if(txtPassword.text.length<8){
            wrong=true;
            UIColor *color = [UIColor redColor];
            txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"8 characters, 1 caps, 1 number" attributes:@{NSForegroundColorAttributeName:color}];
            txtPassword.text=@"";
        }
        //Lozinka je prazna ili lozinke ne matchaju
        if(!strcmp([txtConfirmPass text].UTF8String,empty.UTF8String) || strcmp([txtConfirmPass text].UTF8String,[txtPassword text].UTF8String)){
            wrong=true;
            UIColor *color = [UIColor redColor];
            NSString *errText=@"Confirm your password";
            if(strcmp([txtConfirmPass text].UTF8String,[txtPassword text].UTF8String)){
                errText=@"Both passwords must match";
            }
            txtConfirmPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:errText attributes:@{NSForegroundColorAttributeName:color}];
            txtConfirmPass.text=@"";
        }
        //Potvrda lozinke je prazna
        if(!strcmp([txtUsername text].UTF8String,empty.UTF8String)&&wrongUser==YES){
            wrong=true;
            UIColor *color = [UIColor redColor];
            txtUsername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter your username" attributes:@{NSForegroundColorAttributeName:color}];
            txtUsername.text=@"";
        }

        //Ako su svi podaci ispravno upisani
        if(!wrong){
            [Messages showNormalMsg:@"Uspjesna registracija"];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            LoginViewController *log = (LoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"test122"];
            [self presentViewController:log animated:YES completion:nil];
        }
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleCreateOff) userInfo:nil repeats:NO];
}
*/

//Ako se klikne na create account
- (IBAction)btnCreateAccClicked:(id)sender{
    [self.view endEditing:YES];
    [loadingView startCustomSpinner:self.view];
    [UIView animateWithDuration:0.8 animations:^{
        [btnCreate setTitle:@"Please wait..." forState:UIControlStateNormal];
    }];
    
    /*
    [loadingView stopCustomSpinner];
    [loadingView customSpinnerFail];
    */
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(toggleCreateOff) userInfo:nil repeats:NO];
    
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkRegister) userInfo:nil repeats:NO];
}

/*
//Fokus na confirm pass
- (IBAction)setConfirmPass:(id)sender{
    keyboardActive=YES;
    [txtConfirmPass setPlaceholder:@"Confirm password"];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,140) animated:YES];
    }
    else{
        [scrollBox setContentOffset:CGPointMake(0,221) animated:YES];
    }
}

//Fokus na pass
- (IBAction)setPassword:(id)sender{
    keyboardActive=YES;
    [txtPassword setPlaceholder:@"Password"];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,140) animated:YES];
    }
    else{
        [scrollBox setContentOffset:CGPointMake(0,221) animated:YES];
    }
}

//Fokus na email
- (IBAction)setEmail:(id)sender{
    keyboardActive=YES;
    [txtEmail setPlaceholder:@"Email"];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,140) animated:YES];
    }
    else{
        [scrollBox setContentOffset:CGPointMake(0,133) animated:YES];
    }
}

//Fokus na username
- (IBAction)setUsername:(id)sender{
    keyboardActive=YES;
    [txtUsername setPlaceholder:@"Username"];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,140) animated:YES];
    }
    else{
        [scrollBox setContentOffset:CGPointMake(0,177) animated:YES];
    }
}
*/

@end
