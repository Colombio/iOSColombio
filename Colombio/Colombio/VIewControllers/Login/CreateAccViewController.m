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
    
    HeaderView *headerView = [[HeaderView alloc]initWithFrame:headerViewHolder.frame];
    headerView.backgroundColor =[UIColor colorWithWhite:0 alpha:0];
    headerView.delegate=self;
    headerView.title=@"COLOMBIO";
    headerView.btnNext.hidden=YES;
    [headerViewHolder addSubview:headerView];
    
    [self.scrollBox setDelegate:self];
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollBox addGestureRecognizer:singleTap];
    
    [txtUsername setPlaceholderText:@"enter_username"];
    [txtEmail setPlaceholderText:@"enter_email"];
    [txtPassword setPlaceholderText:@"enter_password"];
    [txtConfirmPass setPlaceholderText:@"enter_confirm_password"];
    
    txtPassword.txtField.secureTextEntry=YES;
    txtConfirmPass.txtField.secureTextEntry=YES;
}

- (void)viewDidLayoutSubviews{
    scrollBox.contentSize = CGSizeMake(scrollBox.frame.size.width,scrollBox.frame.size.height+55);
    
}

- (void)backButtonTapped{
    NSLog(@"test");
}

- (void)toggleCreateOff{
    [btnCreate setTitle:@"Create account" forState:UIControlStateNormal];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

- (void)toggleCreateOn{
    [btnCreate setTitle:@"Please wait..." forState:UIControlStateNormal];
}

- (void)disableKeyboardActivity{
    keyboardActive=NO;
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
    bool wrongUser=NO;
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

/*
//Ako se klikne na create account
- (IBAction)setButton:(id)sender{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(disableKeyboardActivity) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleCreateOn) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkRegister) userInfo:nil repeats:NO];
}

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

//Login button click
- (IBAction)setLogIn:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LoginViewController *log = (LoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"test122"];
    [self presentViewController:log animated:YES completion:nil];
    return;
}
 
 */

//Kada se makne fokus sa text fielda, scrolla se view
- (IBAction)goAwayKeyboard:(id)sender{
    UITextField *gumb = (UITextField *)sender;
    if(gumb.tag==1){
        [txtUsername becomeFirstResponder];
    }
    else if(gumb.tag==2){
        [txtPassword becomeFirstResponder];
    }
    else if(gumb.tag==3){
        [txtConfirmPass becomeFirstResponder];
    }
    else
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(disableKeyboardActivity) userInfo:nil repeats:NO];
        [sender resignFirstResponder];
        [scrollBox setContentOffset:CGPointMake(0,0) animated:YES];
    }
}

//Ako se napravi tap na pozadinu, mice se tipkovnica i scrolla se view
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(disableKeyboardActivity) userInfo:nil repeats:NO];
    [self.view endEditing:YES];
    [scrollBox setContentOffset:CGPointMake(0,0) animated:YES];
}

- (void)btnBackClicked:(id)sender{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
