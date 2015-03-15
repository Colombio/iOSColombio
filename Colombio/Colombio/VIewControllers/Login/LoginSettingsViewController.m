//
//  LoginSettingsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 06/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "LoginSettingsViewController.h"
#import "ColombioServiceCommunicator.h"
#import "AppDelegate.h"
#import "TabBarViewController.h"

@interface LoginSettingsViewController ()

@end

@implementation LoginSettingsViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        countriesVC = [[SelectCountriesViewController alloc] init];
        mediaVC = [[SelectMediaViewController alloc] init];
        userInfoVC = [[UserInfoViewController alloc] init];
        NSArray *array = [[NSArray alloc] initWithObjects:countriesVC, mediaVC, userInfoVC, nil];
        
        super.imgNextBtnNormal = [UIImage imageNamed:@"send_normal"];
        super.imgNextBtnPressed = [UIImage imageNamed:@"send_pressed"];
        super.viewControllersArray = array;
        
        
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    super.btnBack.hidden=YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigateNext{
    if ([self validateData]) {
        [self updateUserData];
        
        NSString *signedRequest = [ColombioServiceCommunicator getSignedRequest];
        ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
        
        NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_update_profile/", BASE_URL];
        NSDictionary *userInfo = [self getUserInfo];
        
        NSString *httpBody = [NSString stringWithFormat:@"user_email=%@&paypal_email=%@&user_pass=%@&user_pass_confirm=%@&first_name=%@&last_name=%@&phone_number=%@&anonymous=%d&country_id=%ld&first_login=0&current_id=%@",
                              userInfo[@"user_email"],
                              userInfo[@"paypal_email"],
                              (userInfo[@"user_pass"]?userInfo[@"user_pass"]:@""),
                              (userInfo[@"user_pass_confirm"]?userInfo[@"user_pass_confirm"]:@""),
                              (((NSString*)userInfo[@"first_name"]).length>0?userInfo[@"first_name"]:@""),
                              (((NSString*)userInfo[@"last_name"]).length>0?userInfo[@"last_name"]:@""),
                              (userInfo[@"phone_number"]?userInfo[@"phone_number"]:@""),
                              [userInfo[@"anonymous"] intValue],
                              (long)[[NSUserDefaults standardUserDefaults] integerForKey:COUNTRY_ID],
                              userInfo[@"user_id"]];
        [csc sendAsyncHttp:url_str httpBody:httpBody cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
        [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if(error==nil&&data!=nil){
                    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    if(!strcmp("1",((NSString*)[response objectForKey:@"s"]).UTF8String)){
                        [self uploadFavMedia];
                    }
                }
                else{
                    
                }
        }];
        
    }
}

- (void)uploadFavMedia{
    NSString *signedRequest = [ColombioServiceCommunicator getSignedRequest];
    ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/update_fav_media/", BASE_URL];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mediaVC.selectedMedia options:NSJSONWritingPrettyPrinted error:&error];
    NSString *selectedMedia = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&media=%@",signedRequest, selectedMedia];
    [csc sendAsyncHttp:url_str httpBody:httpBody cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error==nil&&data!=nil){
            NSDictionary *response=nil;
            response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(!strcmp("1",((NSString*)[response objectForKey:@"s"]).UTF8String)){
                [self presentViewController:[[TabBarViewController alloc]  init] animated:YES completion:nil];
            }
        }
        else{
            
        }
    }];
}

- (NSDictionary*)getUserInfo{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return (NSDictionary*)[appDelegate.db getRowForSQL:@"SELECT * from USER"];
}

#pragma mark Validation

- (BOOL)validateData{
    return YES;
}

- (void)updateUserData{
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"anonymous"] = @(userInfoVC.btnToggleAnonymous.isON);
    dict[@"first_name"] = userInfoVC.txtName.text;
    dict[@"last_name"] = userInfoVC.txtSurname.text;
    dict[@"paypal_email"] = userInfoVC.txtPayPalEmail.text;
    [appdelegate.db updateDictionary:dict forTable:@"USER" where:NULL];
    
}
@end
