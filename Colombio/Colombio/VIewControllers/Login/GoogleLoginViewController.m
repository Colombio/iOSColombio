
/////////////////////////////////////////////////////////////
//
//  GoogleLoginViewController.m
//  Armin Vrevic
//
//  Created by Colombio on 7/7/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that calls google login api
//  and registers user if google login is successful
//
///////////////////////////////////////////////////////////////

#import "GoogleLoginViewController.h"
#import "LoginViewController.h"
#import "Messages.h"
#import "Validation.h"
#import "CountriesViewController.h"
#import "CountriesViewController.h"
#import "CryptoClass.h"
#import "LoginSettingsViewController.h"
#import "AppDelegate.h"
#import "TabBarViewController.h"

/*NSString *client_id = @"204283595708-tq7fc1bb9m8ej487o1l06p7qg788na1v.apps.googleusercontent.com";
NSString *secret = @"wOmBTVoqyJ6SU7CbE0oZdws5";
NSString *callbakc =  @"http://localhost";
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";*/

NSString *client_id = @"255598565784-tfet98s0f6bfop747h0bsiurmenqqh4r.apps.googleusercontent.com";
NSString *secret = @"mFSbvLT6qd0sdZiqQUBj5Gct";
NSString *callbakc =  @"http://localhost";
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";


@interface GoogleLoginViewController ()
{
    ColombioServiceCommunicator *csc;
}
@end

@implementation GoogleLoginViewController

@synthesize webView,isLogin,customHeaderView,headerViewHolder;

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate = self;
    
    loadingView = [[Loading alloc] init];
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
    if ([[[request URL] host] isEqualToString:@"localhost"]) {
        //[self dismiss];
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
            [Messages showErrorMsg:@"error_web_request"];
            [self dismiss];
        }
        self.webView.scrollView.bounces=NO;
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
    NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"user.out"];
    NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
    
    //Sending login data and accepting answer
    NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_social_login?type=gg&token=%@", BASE_URL,token];
    
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(data==nil&&err){
            [Messages showErrorMsg:@"error_web_request"];
            [self dismiss];
        }
        //Request sent successfuly
        else{
            Boolean pogreska=false;
            NSDictionary *response= [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSArray *keys =[response allKeys];
            for(NSString *key in keys){
                //Check if login is valid
                if(!strcmp("s", key.UTF8String)){
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[Localized string:@"google_token_error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    pogreska=true;
                    break;
                }
            }
            //If login successful, save user id and token in file and
            //redirect user to another view
            if(!pogreska){
                NSString *token = [response objectForKey:@"token"];
                NSDictionary *user =[response objectForKey:@"usr"];
                NSString *userId=[user objectForKey:@"user_id"];
                [userId writeToFile:filePathUser atomically:YES encoding:NSUTF8StringEncoding error:nil];
                [token writeToFile:filePathToken atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                //spremanje u bazu
                [csc fetchUserProfile];
                
            }
        }
    }];
}

/*-(void)checkFirstLogin{
    NSLog(@"chekin4");
    @try {
        NSString *result = [ColombioServiceCommunicator getSignedRequest];
        if(result.length>0){
            dispatch_async(dispatch_get_main_queue(), ^{
                //URL with signed req(check web service documentation)
                NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_check_status?signed_req=%@",BASE_URL,result];
                
                NSURL * url = [NSURL URLWithString:url_str];
                NSError *err=nil;
                NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
                [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    //If data from the server is successfuly fetched
                    if(err==nil){
                        if(data==nil){
                            [Messages showErrorMsg:@"error_web_request"];
                            [self dismiss];
                            return ;
                        }
                        NSDictionary *response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        NSString *test= [response objectForKey:@"s"];
                        if(!strcmp("1", test.UTF8String)){
                            NSString *firstLogin = [response objectForKey:@"first_login"];
                            //If user did not fill settings data, show countries
                            if(!strcmp("1", firstLogin.UTF8String)){
                                NSLog(@"success");
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    LoginSettingsViewController *containerVC = [[LoginSettingsViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
                                    [self presentViewController:containerVC animated:YES completion:nil];
                                    return;
                                });
                            }
                            //If user already filled the settngs data show home view
                            else{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self presentViewController:[[TabBarViewController alloc] init] animated:YES completion:nil];
                                    return;
                                });
                            }
                        }
                    }
                    //If communication with the server is successful
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [Messages showErrorMsg:@"error_web_request"];
                            [self dismiss];
                        });
                    }
                }];
            });
        }
    }
    //Token does not exist, or error occured during login
    @catch(NSException *ex){
        
    }
}*/

- (void)didFetchUserDetails:(NSDictionary *)result{
    [csc checkUserStatus];
}

- (void)didCheckUserStatus:(NSDictionary *)result{
    NSString *test= [result objectForKey:@"s"];
    if(!strcmp("1", test.UTF8String)){
        NSString *firstLogin = [result objectForKey:@"first_login"];
        //If user did not fill settings data, show countries
        if(!strcmp("1", firstLogin.UTF8String)){
            NSLog(@"success");
            dispatch_async(dispatch_get_main_queue(), ^{
                LoginSettingsViewController *containerVC = [[LoginSettingsViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
                [self presentViewController:containerVC animated:YES completion:nil];
                return;
            });
        }
        //If user already filled the settngs data show home view
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:[[TabBarViewController alloc] init] animated:YES completion:nil];
                return;
            });
        }
    }
}

- (void)backButtonTapped{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
