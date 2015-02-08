//
//  GoogleLogin.m
//  Colombio
//
//  Created by Colombio on 7/4/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Kontroler za implementaciju google logina

#import "GoogleLoginViewController.h"
#import "LoginViewController.h"
#import "Messages.h"
#import "Validation.h"
#import "CountriesViewController.h"
#import "CountriesViewController.h"
#import "CryptoClass.h"

NSString *client_id = @"204283595708-tq7fc1bb9m8ej487o1l06p7qg788na1v.apps.googleusercontent.com";
NSString *secret = @"wOmBTVoqyJ6SU7CbE0oZdws5";
NSString *callbakc =  @"http://localhost";
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";

@interface GoogleLoginViewController ()

@end

@implementation GoogleLoginViewController

@synthesize webView,isLogin,customHeaderView,headerViewHolder;

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loadingView = [[Loading alloc] init];
    //[loadingView startCustomSpinner:self.view spinMessage:@""];
    [headerViewHolder addSubview:[HeaderView initHeader:@"COLOMBIO" nextHidden:YES previousHidden:NO activeVC:self headerFrame:headerViewHolder.frame]];
    // Do any additional setup after loading the view from its nib.
    NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&redirect_uri=%@&scope=%@&data-requestvisibleactions=%@",client_id,callbakc,scope,visibleactions];
    webView.delegate=self;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [webView.scrollView setDelegate:self];
    webView.scrollView.bounces=NO;
    loadingView = [[Loading alloc] init];
}

- (void)btnCloseClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [loadingView stopCustomSpinner];
}

- (void)dismiss{
    [loadingView stopCustomSpinner];
    [loadingView customSpinnerFail];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //    [indicator startAnimating];
    if ([[[request URL] host] isEqualToString:@"localhost"]) {
        [self dismiss];
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        if (verifier) {
            NSString *data = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code", verifier,client_id,secret,callbakc];
            NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/token"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            NSString *isProxy=[NSString stringWithFormat:@"%i",theConnection.isProxy];
            
            receivedData = [[NSMutableData alloc] init];
        } else {
            //TODO FAIL
        }
        webView.scrollView.bounces=NO;
        return NO;
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [loadingView stopCustomSpinner];
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [Messages showErrorMsg:@"error_web_request"];
        [self dismiss];
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *odgovor=nil;
    odgovor =[NSJSONSerialization JSONObjectWithData:receivedData options:0 error:NULL];
    NSString *token = [odgovor objectForKey:@"access_token"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"korisnik.out"];
    NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
    
    //Slanje podataka za prijavu i dohvacanje odgovora
    NSString *url_str = [NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_social_login?type=gg&token=%@",token];
    
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(data==nil&&err){
            [Messages showErrorMsg:@"error_web_request"];
            [self dismiss];
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
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Krivi podaci za prijavu" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    pogreska=true;
                    break;
                }
            }
            //Ako je uspjesna prijava, spremi user id i token u datoteke
            // i preusmjeri korisnika na drugi view
            if(!pogreska){
                NSString *token = [odgovor objectForKey:@"token"];
                NSDictionary *korisnik =[odgovor objectForKey:@"usr"];
                NSString *userId=[korisnik objectForKey:@"user_id"];
                [userId writeToFile:filePathUser atomically:YES encoding:NSUTF8StringEncoding error:nil];
                [token writeToFile:filePathToken atomically:YES encoding:NSUTF8StringEncoding error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(checkFirstLogin) userInfo:nil repeats:NO];
                });
            }
        }
    }];
}

-(void)checkFirstLogin{
    NSLog(@"chekin4");
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!data&&err!=nil){
                [Messages showErrorMsg:@"error_web_request"];
                [self dismiss];
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
                [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    //Ako su uspjesno dohvaceni podaci sa servera
                    if(err==nil){
                        if(data==nil){
                            [Messages showErrorMsg:@"error_web_request"];
                            [self dismiss];
                            return ;
                        }
                        NSDictionary *odgovor=nil;
                        odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        NSString *test= [odgovor objectForKey:@"s"];
                        if(!strcmp("1", test.UTF8String)){
                            NSString *firstLogin = [odgovor objectForKey:@"first_login"];
                            //Ako korisnik nije popunio pocetne postavke prikazi popis drzava
                            if(!strcmp("0", firstLogin.UTF8String)){
                                NSLog(@"success");
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    CountriesViewController *countries = [[CountriesViewController alloc]init];
                                    [self presentViewController:countries animated:YES completion:nil];
                                    return;
                                });
                            }
                            //Ako je korisnik vec popunio pocetne podatke prikazi home
                            else{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //TODO PRESENT SUCCESS
                                    return;
                                });
                            }
                        }
                    }
                    //Nije uspješna komunikacija sa serverom
                    else{
                        [Messages showErrorMsg:@"error_web_request"];
                        [self dismiss];
                    }
                }];
            }
        });
    }
    //Token ne postoji ili se dogodila greska prilikom pristupa
    @catch(NSException *ex){
        
    }
}

@end
