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

#import "ForgotPassword.h"
#import "CreateAcc.h"
#import "LoginViewController.h"
#import "Messages.h"
#import "Validation.h"

@interface ForgotPassword ()

@end

@implementation ForgotPassword

@synthesize emailPass;
@synthesize emailWrong;
@synthesize txtEmail;
@synthesize scrollBox;
@synthesize inputImg;
@synthesize btnSend;
@synthesize pozadina;
@synthesize scrollView;
@synthesize scrollableHeader;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    emailPass.hidden=YES;
    emailWrong.hidden=YES;
    scrollableHeader = [[ScrollableHeader alloc] init];
    [scrollableHeader addHeader:self.view self:self headerScroll:scrollView viewScroll:scrollBox];
}

- (void)viewDidLayoutSubviews{
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*3, scrollView.frame.size.height);
    scrollView.bounces=NO;
    [scrollView setDelegate:scrollableHeader];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)emailUntapped{
    [scrollBox setContentOffset:CGPointMake(0,0) animated:YES];
    [txtEmail resignFirstResponder];
}

//Kada se klikne na forgot password, pozove se ova metoda
- (void)sendPassword{
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(emailUntapped) userInfo:nil repeats:NO];
    //Ako je krivi format e-maila
    if(![Validation validateEmail:[txtEmail text]]) {
        // user entered invalid email address
        UIColor *color = [UIColor redColor];
        txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter a valid email address" attributes:@{NSForegroundColorAttributeName:color}];
        txtEmail.text=@"";
        emailWrong.hidden=NO;
        emailPass.hidden=YES;
        inputImg.hidden=YES;
    }
    //Ako je ok format e-maila, onda se mora provjeriti duplikat na web servisu
    else{        
        //Slanje podataka za prijavu i dohvacanje odgovora
        NSString *url_str = [NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_pass_recovery?user_email=%@",txtEmail.text];
        NSURL * url = [NSURL URLWithString:url_str];
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[[NSString stringWithFormat:@"user_email=%@",txtEmail.text]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        NSURLResponse *response = nil;
        NSError *err;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        
        //Dogodila se pogreska prilikom dohvacanja zahtjeva
        if(err){
            [Messages showErrorMsg:@"Pogreska prilikom slanja zahtjeva"];
        }
        //Uspjesno je poslan zahtjev
        else{
            Boolean pogreska=false;
            NSDictionary *odgovor=nil;
            odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSArray *keys =[odgovor allKeys];
            for(NSString *key in keys){
                //Provjera za ispravnost prijave
                if(!strcmp("s", key.UTF8String)){
                    NSString *error = [odgovor objectForKey:@"s"];
                    if(!(strcmp("0",error.UTF8String))){
                        NSString *errMessage= [odgovor objectForKey:@"msg"];
                        NSString *displayErr;
                        if(!strcmp("no_match", errMessage.UTF8String)){
                            displayErr=@"Email does not exist";
                        }
                        else if(!strcmp("user_banned", errMessage.UTF8String)){
                            displayErr=@"User with this email is banned";
                        }
                        UIColor *color = [UIColor redColor];
                        txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:displayErr attributes:@{NSForegroundColorAttributeName:color}];
                        txtEmail.text=@"";
                        pogreska=true;
                    }
                    break;
                }
            }
            if(!pogreska){
                [Messages showNormalMsg:[NSString stringWithFormat:@"Lozinka je uspješno poslana na email %@",txtEmail.text]];
                emailWrong.hidden=YES;
                emailPass.hidden=NO;
                inputImg.hidden=YES;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                LoginViewController *log = (LoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"test122"];
                [self presentViewController:log animated:YES completion:nil];
            }
        }
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleSendOff) userInfo:nil repeats:NO];
}

-(void)toggleSendOn{
    [btnSend setTitle:@"Please wait..." forState:UIControlStateNormal];
}

-(void)toggleSendOff{
    [btnSend setTitle:@"Send password" forState:UIControlStateNormal];
}

//Akcija koja se poziva kada se klikne gumb
- (IBAction)setSend:(id)sender {
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleSendOn) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(sendPassword) userInfo:nil repeats:NO];
}

//Ako se klikne na login gumb
- (IBAction)setLogInside:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LoginViewController *log = (LoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"test122"];
    [self presentViewController:log animated:YES completion:nil];
}

//Ako se klikne na sign in gumb
- (IBAction)setSignIn:(id)sender {
    CreateAcc *createAcc = [[CreateAcc alloc]init];
    [self presentViewController:createAcc animated:YES completion:nil];
}

- (IBAction)goAwayKeyboard:(id)sender {
    [sender resignFirstResponder];
    [scrollBox setContentOffset:CGPointMake(0,0) animated:YES];
}

//Fokus na email txt box
- (IBAction)setEmail:(id)sender {
    inputImg.hidden=YES;
    emailWrong.hidden=YES;
    emailPass.hidden=YES;
    [txtEmail setPlaceholder:@"Email"];
    [scrollBox setContentOffset:CGPointMake(0,120) animated:YES];
}

@end
