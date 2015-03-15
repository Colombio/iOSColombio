//
//  LoginViewController.m
//  colombio
//
//  Created by Vlatko Šprem on 16/08/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Messages.h"
#import "CryptoClass.h"
#import "Validation.h"
#import "CreateAccViewController.h"
#import "ForgotPasswordViewController.h"
#import "TabBarViewController.h"
#import "CountriesViewController.h"
#import "GoogleLoginViewController.h"

#import "LoginSettingsViewController.h"
/*
#import "Countries.h"
#import "GoogleLogin.h"
#import "Home.h"
*/

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtEmail;
@synthesize txtPassword;
@synthesize scrollBox;
@synthesize imgInputEmail;
@synthesize imgInputPassword;
@synthesize imgPassEmail;
@synthesize imgFailEmail;
@synthesize imgFailPassword;
@synthesize imgPassPassword;
@synthesize btnLogin;

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Skrivanje slicica da li su pogresni inputi
    loginHidden=YES;
    imgPassEmail.hidden = YES;
    imgFailEmail.hidden = YES;
    imgPassPassword.hidden = YES;
    imgFailPassword.hidden = YES;
    NSLog(@"load");
    //Skrivanje inputa
    
    txtEmail.txtField.delegate=self;
    
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height < 568.0f){
        
        _CS_scrollableHeaderHeight.constant=187;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    loadingView = [[Loading alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    //Dodavanje sličica za swipe
    scrollBox.scrollEnabled=YES;
   
    timer=nil;
    //[scrollBox setDelegate:self];
    
}


#pragma mark Button Action

- (void)btnEmailSelected:(id)sender{
    if (loginHidden) {
        [self showEmailLogin];
    }else{
        [self hideEmailLogin];
    }
    
    
}

- (void)hideEmailLogin{
    loginHidden=YES;
    _viewEmailHolder.backgroundColor = [UIColor clearColor];
    _viewLoginHolder.hidden=YES;
    _CS_buttonDistanceFromTop.constant += _viewLoginHolder.frame.size.height+10;
    _CS_buttonDistanceFromBottom.constant -= _viewLoginHolder.frame.size.height+10;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)showEmailLogin{
    loginHidden=NO;
    _viewEmailHolder.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [self.view layoutIfNeeded];
    _CS_buttonDistanceFromTop.constant -= _viewLoginHolder.frame.size.height+10;
    _CS_buttonDistanceFromBottom.constant += _viewLoginHolder.frame.size.height+10;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                         
                     }];
    [UIView transitionWithView:_viewLoginHolder
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    _viewLoginHolder.hidden=NO;
}



#pragma mark TextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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

- (void)toggleLoginOff{
    [btnLogin setTitle:[Localized string:@"login_login"] forState:UIControlStateNormal];
    [loadingView removeCustomSpinner];
}

#pragma mark Email Login

- (void)btnLoginClicked:(id)sender{
    [self.view endEditing:YES];
    [loadingView startCustomSpinner:self.view spinMessage:@""];
    [UIView animateWithDuration:0.8 animations:^{
        [btnLogin setTitle:[Localized string:@"wait"] forState:UIControlStateNormal];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkLoginNormal) userInfo:nil repeats:NO];
}
-(void)checkLoginNormal{
    //Provjera da li su email i lozinka prazni
    Boolean wrong = false;
    if(![Validation validateEmail:txtEmail.txtField.text]){
        wrong=true;
        txtEmail.errorText = @"login_enter_email";
    }
    
    //Lozinka je prazna
    if(txtPassword.txtField.text.length<8){
        wrong=true;
        txtPassword.errorText = @"login_enter_password";
    }
    
    //pocetna konfiguracija za datoteke
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"user.out"];
    NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
    
    //Slanje podataka za prijavu i dohvacanje odgovora
    NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_login/", BASE_URL];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[[NSString stringWithFormat:@"login_string=%@&login_pass=%@",txtEmail.txtField.text,txtPassword.txtField.text]dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    //Dogodila se pogreska prilikom dohvacanja zahtjeva
    if(err){
        [Messages showErrorMsg:@"error_web_request"];
        [loadingView stopCustomSpinner];
        [loadingView customSpinnerFail];
    }
    //Uspjesno je poslan zahtjev
    else{
        Boolean err=false;
        NSDictionary *response=nil;
        response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSArray *keys =[response allKeys];
        
        for(NSString *key in keys){
            //Provjera za ispravnost prijave
            if(!strcmp("s", key.UTF8String)){
                txtEmail.errorText = @"login_enter_email";
                txtPassword.errorText = @"login_enter_password";
                err=true;
                break;
            }
        }
        //Ako je uspjesna prijava, spremi user id i token u datoteke
        // i preusmjeri korisnika na drugi view
        if(!err){
            NSString *token = [response objectForKey:@"token"];
            NSDictionary *user =[response objectForKey:@"usr"];
            NSString *userId=[user objectForKey:@"user_id"];
            [userId writeToFile:filePathUser atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [token writeToFile:filePathToken atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            //spremanje u bazu
            NSMutableDictionary *dbDict = [[NSMutableDictionary alloc] init];
            AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
            [appdelegate.db clearTable:@"USER"];
            [appdelegate.db clearTable:@"USER_CASHOUT"];
            dbDict[@"user_id"] = response[@"usr"][@"user_id"];
            dbDict[@"username"] = response[@"usr"][@"username"];
            dbDict[@"user_email"] = response[@"usr"][@"user_email"];
            dbDict[@"token"] = response[@"token"];
            dbDict[@"sign"] = response[@"sign"];
            [appdelegate.db insertDictionaryWithoutColumnCheck:dbDict forTable:@"USER"];
            
            [loadingView stopCustomSpinner];
            [loadingView removeCustomSpinner];
            LoginSettingsViewController *containerVC = [[LoginSettingsViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
            [self presentViewController:containerVC animated:YES completion:nil];
            return;
            
        }
        else {
            [loadingView stopCustomSpinner];
            [loadingView customSpinnerFail];
        }
        [self toggleLoginOff];
    }
}


#pragma mark Facebook Login
- (void)btnFBSelected:(id)sender{
    [txtEmail.txtField resignFirstResponder];
    [txtPassword.txtField resignFirstResponder];
    if (!loginHidden) {
        [self hideEmailLogin];
    }
    [self checkLoginFacebook];
}

-(void)checkLoginFacebook{
    if([FBSession activeSession].state == FBSessionStateOpen  || [FBSession activeSession].state==FBSessionStateOpenTokenExtended){
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
    else{
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email"] allowLoginUI:YES completionHandler:^(FBSession *session,FBSessionState status,NSError *error) {
            NSString *token =[[[FBSession activeSession]accessTokenData]accessToken];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"user.out"];
            NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
            
            //Slanje podataka za prijavu i dohvacanje odgovora
            NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_social_login?type=fb&token=%@",BASE_URL,token];
            NSURL * url = [NSURL URLWithString:url_str];
            NSError *err=nil;
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
            NSURLResponse *URLresponse = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&URLresponse error:&err];
            //Dogodila se pogreska prilikom dohvacanja zahtjeva
            if(err){
                [Messages showErrorMsg:@"error_web_request"];
                [loadingView stopCustomSpinner];
                [loadingView customSpinnerFail];
            }
            
            //Uspjesno je poslan zahtjev
            else{
                Boolean error=false;
                NSDictionary *response=nil;
                response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[response allKeys];
                for(NSString *key in keys){
                    //Provjera za ispravnost prijave
                    if(!strcmp("s", key.UTF8String)){
                        error=true;
                        break;
                    }
                }
                
                //Ako je uspjesna prijava, spremi user id i token u datoteke
                // i preusmjeri korisnika na drugi view
                if(!error){
                    NSString *token = [response objectForKey:@"token"];
                    NSDictionary *user =[response objectForKey:@"usr"];
                    NSString *userId=[user objectForKey:@"user_id"];
                    [userId writeToFile:filePathUser atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    [token writeToFile:filePathToken atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    
                    NSMutableDictionary *dbDict = [[NSMutableDictionary alloc] init];
                    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
                    [appdelegate.db clearTable:@"USER"];
                    [appdelegate.db clearTable:@"USER_CASHOUT"];
                    dbDict[@"user_id"] = response[@"usr"][@"user_id"];
                    dbDict[@"username"] = response[@"usr"][@"username"];
                    dbDict[@"user_email"] = response[@"usr"][@"user_email"];
                    dbDict[@"token"] = response[@"token"];
                    dbDict[@"sign"] = response[@"sign"];
                    [appdelegate.db insertDictionaryWithoutColumnCheck:dbDict forTable:@"USER"];
                    
                    LoginSettingsViewController *containerVC = [[LoginSettingsViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
                    [self presentViewController:containerVC animated:YES completion:nil];
                    
                }
            }
        }];
    }
}

#pragma mark Google
- (void)btnGoogleSelected:(id)sender{
    GoogleLoginViewController *gg = [[GoogleLoginViewController alloc]init];
    [self presentViewController:gg animated:YES completion:nil];
    
    
}

/*
//Provjeravanje da li je pohranjeni token još uvijek aktivan na serveru
- (void)provjeriToken{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"korisnik.out"];
        NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
        NSString *token = [NSString stringWithContentsOfFile:filePathToken encoding:NSUTF8StringEncoding error:nil];
        NSString *userId = [NSString stringWithContentsOfFile:filePathUser encoding:NSUTF8StringEncoding error:nil];
        
        NSDictionary *provjera = @{@"usr" : userId,@"token" : token};
        NSError *err;
        NSData *data = [NSJSONSerialization dataWithJSONObject:provjera options:0 error:&err];
        
        if(!data){
            [Messages showErrorMsg:@"Pogreška prilikom slanja zahtjeva!"];
            return;
        }
        else{
            //Napravi base64 encoding
            NSMutableString *result= [CryptoClass base64Encoding:data];
            
            //URL sa signed req
            NSString *url_str = [NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_check_status?signed_req=%@",result];
            NSURL * url = [NSURL URLWithString:url_str];
            NSError *err=nil;
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            NSDictionary *odgovor=nil;
            
            //Ako su uspjesno dohvaceni podaci sa servera
            if(err==nil){
                odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSString *test= [odgovor objectForKey:@"s"];
                if(!strcmp("1", test.UTF8String)){
                    NSString *firstLogin = [odgovor objectForKey:@"first_login"];
                    //Ako korisnik nije popunio pocetne postavke prikazi popis drzava
                    if(!strcmp("1", firstLogin.UTF8String)){
                        Countries *states = [[Countries alloc]init];
                        [self presentViewController:states animated:YES completion:nil];
                        return;
                    }
                    //Ako je korisnik vec popunio pocetne podatke prikazi home
                    else{
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                        Home *home = (Home*)[storyboard instantiateViewControllerWithIdentifier:@"home"];
                        [self presentViewController:home animated:YES completion:nil];
                        return;
                    }
                }
            }
            //Nije uspješna komunikacija sa serverom
            else{
                [Messages showErrorMsg:@"Pogreška prilikom slanja zahtjeva11"];
            }
        }
    }
    //Token ne postoji ili se dogodila greska prilikom pristupa
    @catch(NSException *ex){
        
    }
}

 
//Google login gumb
- (IBAction)setGoogle:(id)sender{
    [txtPassword resignFirstResponder];
    [txtEmail resignFirstResponder];
    GoogleLogin *gg = [[GoogleLogin alloc]init];
    [self presentViewController:gg animated:YES completion:nil];
}
*/

//Ako je pritisnuo korisnik na background, makni tipkovnicu
//odnosno scrollaj view
- (IBAction)goAwayKeyboard:(id)sender{
    UITextField *gumb = (UITextField *)sender;
    if(gumb.tag==1){
        [txtPassword becomeFirstResponder];
    }
    else
    {
        [sender resignFirstResponder];
        
        CGRect screenBounds = [[UIScreen mainScreen]bounds];
        if(screenBounds.size.height == 568.0f){
            [scrollBox setContentOffset:CGPointMake(0,135) animated:YES];
            return;
        }
        [scrollBox setContentOffset:CGPointMake(0,0) animated:YES];
    }
}

//Da se makne keyboard
- (IBAction)tapBackground:(id)sender{
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
}

/*
//Provjera ako se korisnik odlucio na normalni login


//Login gumb
- (IBAction)setLogin:(id)sender {
    if(timer!=nil){
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleLoginOn) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkLoginNormal) userInfo:nil repeats:NO];
}
*/
//Kreiranje racuna
- (IBAction)setSign:(id)sender {
    CreateAccViewController *createAccount = [[CreateAccViewController alloc]init];
    [self presentViewController:createAccount animated:YES completion:nil];
}
//Zaboravljena lozinka
- (IBAction)setForgot:(id)sender {
    ForgotPasswordViewController *forgotPassword = [[ForgotPasswordViewController alloc]init];
    [self presentViewController:forgotPassword animated:YES completion:nil];
}
/*
//Kada korisnik stisne na email, scrollaj view
- (IBAction)setEmail:(id)sender{
    imgInputEmail.hidden=YES;
    [txtEmail setPlaceholder:@"Email"];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,215) animated:YES];
    }
    else{
        [scrollBox setContentOffset:CGPointMake(0,300) animated:YES];
    }
    imgFailEmail.hidden=YES;
}

//Kada korisnik stisne na loyinku, scrollaj view
- (IBAction)setPassword:(id)sender{
    imgInputPassword.hidden=YES;
    imgFailPassword.hidden=YES;
    [txtPassword setPlaceholder:@"Password"];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,215) animated:YES];
    }
    else{
        [scrollBox setContentOffset:CGPointMake(0,300) animated:YES];
    }
}

//Facebook login
- (IBAction)setFacebook:(id)sender {
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    if(timer!=nil){
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleLoginOn) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkLoginFacebook) userInfo:nil repeats:NO];
}

//Ako se klikne na facebook button



*/
@end
