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
#import "Messages.h"
#import "Loading.h"

@interface LoginSettingsViewController ()
{
    Loading *spinner;
}
@end

@implementation LoginSettingsViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        super.isSingleTitle=YES;
        super.progressBarAnimation=YES;
        countriesVC = [[SelectCountriesViewController alloc] init];
        mediaVC = [[SelectMediaViewController alloc] initForNewsUpload:NO];
        userInfoVC = [[UserInfoViewController alloc] init];
        NSArray *array = [[NSArray alloc] initWithObjects:countriesVC, mediaVC, userInfoVC, nil];
        
        super.imgNextBtnNormal = [UIImage imageNamed:@"save_normal"];
        super.imgNextBtnPressed = [UIImage imageNamed:@"save_pressed"];
        super.viewControllersArray = array;
        super.lastNextBtnText = [Localized string:@"header_save"];
        
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    super.btnBack.hidden=YES;
    spinner = [[Loading alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigateNext{
    if ([self validateData]) {
        [spinner startCustomSpinner2:self.view spinMessage:@""];
        [self updateUserData];
        
        NSString *signedRequest = [ColombioServiceCommunicator getSignedRequest];
        ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
        
        NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_update_profile/", BASE_URL];
        NSDictionary *userInfo = [self getUserInfo];
        
        NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&user_email=%@&paypal_email=%@&user_pass=%@&user_pass_confirm=%@&first_name=%@&last_name=%@&phone_number=%@&anonymous=%d&country_id=%ld&first_login=0&current_id=%@&installationID=%@",
                              signedRequest,
                              userInfo[@"user_email"],
                              userInfo[@"paypal_email"],
                              (userInfo[@"user_pass"]?userInfo[@"user_pass"]:@""),
                              (userInfo[@"user_pass_confirm"]?userInfo[@"user_pass_confirm"]:@""),
                              (((NSString*)userInfo[@"first_name"]).length>0?userInfo[@"first_name"]:@""),
                              (((NSString*)userInfo[@"last_name"]).length>0?userInfo[@"last_name"]:@""),
                              (userInfo[@"phone_number"]?userInfo[@"phone_number"]:@""),
                              [userInfo[@"anonymous"] intValue],
                              (long)[[NSUserDefaults standardUserDefaults] integerForKey:COUNTRY_ID],
                              userInfo[@"user_id"],
                              ([[NSUserDefaults standardUserDefaults] objectForKey:PARSE_INSTALLATIONID]!=nil?[[NSUserDefaults standardUserDefaults] objectForKey:PARSE_INSTALLATIONID]:@"")];
        [csc sendAsyncHttp:url_str httpBody:httpBody cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
        [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                NSDictionary *dicResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                if(error==nil&&data!=nil){
                    if(!strcmp("1",((NSString*)[dicResponse objectForKey:@"s"]).UTF8String)){
                        [self uploadFavMedia];
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [spinner removeCustomSpinner];
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:dicResponse[@"errors"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        });
                    }
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [spinner removeCustomSpinner];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:dicResponse[@"errors"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    });

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
    selectedMedia = [selectedMedia stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&media=%@",signedRequest, selectedMedia];
    [csc sendAsyncHttp:url_str httpBody:httpBody cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error==nil&&data!=nil){
            NSDictionary *response=nil;
            response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(response!=nil && !strcmp("1",((NSString*)[response objectForKey:@"s"]).UTF8String)){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner removeCustomSpinner];
                    [self presentViewController:[[TabBarViewController alloc]  init] animated:YES completion:nil];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner removeCustomSpinner];
                    [self presentViewController:[[TabBarViewController alloc]  init] animated:YES completion:nil];
                });
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeCustomSpinner];
                [self presentViewController:[[TabBarViewController alloc]  init] animated:YES completion:nil];
            });
        }
    }];
}

- (NSDictionary*)getUserInfo{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return (NSDictionary*)[appDelegate.db getRowForSQL:@"SELECT * from USER"];
}

#pragma mark Validation

- (BOOL)validateData{
    BOOL dataOK = YES;
    
    if (![countriesVC validateCountries]) {
        dataOK=NO;
        [self showErrorMessage:@"error_choose_one_country"];
        return NO;
    }
    
    if (![mediaVC validateMedia]) {
        dataOK=NO;
        [self showErrorMessage:@"error_choose_one_media"];
        return NO;
    }
    
    if (![userInfoVC validateFields]) {
        dataOK=NO;
        [self showErrorMessage:@"error_fill_fields"];
        return NO;
    }
    return YES;
}

- (void)showErrorMessage:(NSString*)errorString{
    [Messages showNormalMsg:errorString];
}

- (void)updateUserData{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"anonymous"] = @(userInfoVC.swToggleAnonymoys.isOn);
    dict[@"first_name"] = !userInfoVC.swToggleAnonymoys.isOn?userInfoVC.txtName.text:@"";
    dict[@"last_name"] = !userInfoVC.swToggleAnonymoys.isOn?userInfoVC.txtSurname.text:@"";
    dict[@"paypal_email"] = userInfoVC.txtPayPalEmail.text;
    dict[@"paypal"] = userInfoVC.swTogglePayPal.isOn?@1:@0;
    [appdelegate.db updateDictionary:dict forTable:@"USER" where:NULL];
    
}

@end
