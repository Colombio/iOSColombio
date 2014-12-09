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

@synthesize userPass;
@synthesize userWrong;
@synthesize emailPass;
@synthesize emailWrong;
@synthesize passPass;
@synthesize passWrong;
@synthesize passConfirmPass;
@synthesize passConfirmWrong;
@synthesize scrollBox;
@synthesize txtConfirmPass;
@synthesize txtEmail;
@synthesize txtPassword;
@synthesize txtUsername;
@synthesize imgConfirm;
@synthesize imgEmail;
@synthesize imgPassword;
@synthesize imgUsername;
@synthesize btnCreate;
@synthesize pozadina;
@synthesize scrollView;
@synthesize scrollableHeader;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen]bounds];

    [self.scrollBox setDelegate:self];
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollBox addGestureRecognizer:singleTap];
    
    //Uzimanje backgrounda za 4 inch ekran
    if(screenBounds.size.height == 568.0f){
        NSString *filename = @"back.png";
        filename=[filename stringByReplacingOccurrencesOfString:@".png" withString:@"-568h.png"];
    }
    else{
    }
    
    txtPassword.secureTextEntry = YES;
    txtConfirmPass.secureTextEntry = YES;
    userPass.hidden = YES;
    userWrong.hidden = YES;
    emailPass.hidden = YES;
    emailWrong.hidden = YES;
    passWrong.hidden = YES;
    passPass.hidden = YES;
    passConfirmWrong.hidden = YES;
    passConfirmPass.hidden =YES;
    scrollableHeader = [[ScrollableHeader alloc] init];
    [scrollableHeader addHeader:self.view self:self headerScroll:scrollView viewScroll:scrollBox];
}

- (void)viewDidLayoutSubviews{
    scrollView.contentSize = CGSizeMake(scrollBox.frame.size.width*3, scrollView.frame.size.height);
    
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    
    if(screenBounds.size.height != 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,20) animated:NO];
    }
    scrollView.bounces=NO;
    [scrollView setDelegate:scrollableHeader];
}

- (void)toggleCreateOff{
    [btnCreate setTitle:@"Create account" forState:UIControlStateNormal];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if(self.scrollBox.contentOffset.y<0){
        [self.scrollBox setScrollEnabled:NO];
        [self.scrollBox setContentOffset:CGPointMake(0, 0)];
        [self.scrollBox setScrollEnabled:YES];
        return;
    }
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        if(keyboardActive==YES){
            if(self.scrollBox.contentOffset.y>140){
                [self.scrollBox setScrollEnabled:NO];
                [self.scrollBox setContentOffset:CGPointMake(0, 140)];
                [self.scrollBox setScrollEnabled:YES];
            }
        }
        else{
            if(self.scrollBox.contentOffset.y>0){
                [self.scrollBox setContentOffset:CGPointMake(0, 0)];
            }
        }
        return;
    }
    else{
        if(keyboardActive==NO){
            if(self.scrollBox.contentOffset.y>20){
                [self.scrollBox setScrollEnabled:NO];
                [self.scrollBox setContentOffset:CGPointMake(0, 20)];
                [self.scrollBox setScrollEnabled:YES];
                return;
            }
        }
        else{
            if(self.scrollBox.contentOffset.y>230){
                [self.scrollBox setScrollEnabled:NO];
                [self.scrollBox setContentOffset:CGPointMake(0, 230)];
                [self.scrollBox setScrollEnabled:YES];
                return;
            }
        }
    }
}

- (void)toggleCreateOn{
    [btnCreate setTitle:@"Please wait..." forState:UIControlStateNormal];
}

- (void)disableKeyboardActivity{
    keyboardActive=NO;
}

- (void)checkRegister{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(disableKeyboardActivity) userInfo:nil repeats:NO];
    /*
     userWrong.hidden=YES;
     userPass.hidden=NO;
     
     passWrong.hidden=YES;
     passPass.hidden=NO;
     
     emailWrong.hidden=YES;
     
     passConfirmPass.hidden=NO;
     passConfirmWrong.hidden=YES;
     */
    
    emailWrong.hidden=YES;
    emailPass.hidden=NO;
    imgEmail.hidden=YES;
    
    NSString *empty = @"";
    Boolean wrong = false;
    
    
    //Slanje podataka za prijavu i dohvacanje odgovora
    NSString *url_str = [NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_normal_register/"];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //md5 TODO
    //NSString *md5Prepare = [NSString stringWithFormat:@"%@registracija%@",txtEmail.text,txtPassword.text];
    //NSString *hash = [self md5:(md5Prepare)];
    
    //TODO Provjeriti sa web servisom, nesto ne radi kod slanja podataka, odnosno
    //response je krivi
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
                        userPass.hidden=YES;
                        imgPassword.hidden=YES;
                        imgUsername.hidden=YES;
                        userWrong.hidden=NO;
                        wrongUser=NO;
                    }
                    //Snaga lozinke nije ok
                    if(strcmp("pass_str_fail", greska.UTF8String)){
                        UIColor *color = [UIColor redColor];
                        txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"8 characters, 1 caps, 1 number" attributes:@{NSForegroundColorAttributeName:color}];
                        txtPassword.text=@"";
                        wrong=true;
                        passWrong.hidden=NO;
                        passPass.hidden=YES;
                        imgPassword.hidden=YES;
                    }
                    //Duplikat emaila
                    if(strcmp("email_exists", greska.UTF8String)&& ![txtEmail.text isEqualToString:@"b"]&&wrongEmail==NO){
                        wrongEmail=NO;
                        UIColor *color = [UIColor redColor];
                        txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email already exists" attributes:@{NSForegroundColorAttributeName:color}];
                        txtEmail.text=@"";
                        wrong=true;
                        emailPass.hidden=YES;
                        imgEmail.hidden=YES;
                        emailWrong.hidden=NO;
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
            emailWrong.hidden=NO;
            emailPass.hidden=YES;
            imgEmail.hidden=YES;
        }
        //Duljina lozinke je kriva
        if(txtPassword.text.length<8){
            wrong=true;
            UIColor *color = [UIColor redColor];
            txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"8 characters, 1 caps, 1 number" attributes:@{NSForegroundColorAttributeName:color}];
            txtPassword.text=@"";
            passWrong.hidden=NO;
            passPass.hidden=YES;
            imgPassword.hidden=YES;
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
            passConfirmWrong.hidden=NO;
            imgConfirm.hidden=YES;
            passConfirmPass.hidden=YES;
        }
        //Potvrda lozinke je prazna
        if(!strcmp([txtUsername text].UTF8String,empty.UTF8String)&&wrongUser==YES){
            wrong=true;
            UIColor *color = [UIColor redColor];
            txtUsername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter your username" attributes:@{NSForegroundColorAttributeName:color}];
            txtUsername.text=@"";
            userWrong.hidden=NO;
            userPass.hidden=YES;
            imgUsername.hidden=YES;
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

//Ako se klikne na create account
- (IBAction)setButton:(id)sender{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(disableKeyboardActivity) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleCreateOn) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkRegister) userInfo:nil repeats:NO];
}

//Fokus na confirm pass
- (IBAction)setConfirmPass:(id)sender{
    keyboardActive=YES;
    imgConfirm.hidden=YES;
    passConfirmPass.hidden=YES;
    passConfirmWrong.hidden=YES;
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
    imgPassword.hidden=YES;
    passPass.hidden=YES;
    passWrong.hidden=YES;
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
    imgEmail.hidden=YES;
    emailPass.hidden=YES;
    emailWrong.hidden=YES;
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
    imgUsername.hidden=YES;
    userPass.hidden=YES;
    userWrong.hidden=YES;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Ako se napravi tap na pozadinu, mice se tipkovnica i scrolla se view
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(disableKeyboardActivity) userInfo:nil repeats:NO];
    [txtConfirmPass resignFirstResponder];
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtUsername resignFirstResponder];
    [scrollBox setContentOffset:CGPointMake(0,0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)btnBackClicked:(id)sender{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
