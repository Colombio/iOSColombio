//
//  AppDelegate.m
//  Colombio
//
//  Created by Colombio on 6/14/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//test

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "LoginViewController.h"
#import "StartViewController.h"
#import "Messages.h"
#import "ColombioServiceCommunicator.h"
#import "HomeViewController.h"
#import "CreateAccViewController.h"
#import "TabBarViewController.h"
#import "ForgotPasswordViewController.h"
#import "CountriesViewController.h"
#import "MediaViewController.h"
#import "LoginSettingsViewController.h"

@implementation AppDelegate
@synthesize db, locationManager, mediaImages;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self applicationDocumentsDirectory];
    [self getLocation];
    self.db = [[Database alloc] init];
    [db UpgradeDB];
    mediaImages = [[NSCache alloc] init];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:COUNTRY_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"SKIP_START"]){
        [self checkToken];
    }else{
        self.window.rootViewController = [[StartViewController alloc] init];
    }
    //LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)getLocation{
    locationManager = [[CLLocationManager alloc]init];
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.session close];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}

- (NSURL *)applicationDocumentsDirectory
{
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)checkToken{
    @try {
        NSString *result = [ColombioServiceCommunicator getSignedRequest];
        if(result.length>0){
            //URL sa signed req
            NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_check_status?signed_req=%@",BASE_URL,result];
            NSURL * url = [NSURL URLWithString:url_str];
            NSError *err=nil;
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
            NSURLResponse *urlResponse = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&err];
            NSDictionary *response=nil;
            
            //Ako su uspjesno dohvaceni podaci sa servera
            if(err==nil){
                response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSString *test= [response objectForKey:@"s"];
                if(!strcmp("1", test.UTF8String)){
                    NSString *firstLogin = [response objectForKey:@"first_login"];
                    //Ako korisnik nije popunio pocetne postavke prikazi popis drzava
                    if(!strcmp("1", firstLogin.UTF8String)){
                        
                        LoginSettingsViewController *containerVC = [[LoginSettingsViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
                        self.window.rootViewController = containerVC;
                        return;
                    }
                    //Ako je korisnik vec popunio pocetne podatke prikazi home
                    else{
                        /*
                         Testing purposes
                         **/
                        self.window.rootViewController = [[TabBarViewController alloc] init];
                        return;
                    }
                }else{
                    self.window.rootViewController = [[LoginViewController alloc] init];
                    return;
                }
            }
            //Nije uspješna komunikacija sa serverom
            else{
                [Messages showErrorMsg:@"Pogreška prilikom slanja zahtjeva11"];
                self.window.rootViewController = [[LoginViewController alloc] init];
                return;
            }
        }else{
            self.window.rootViewController = [[LoginViewController alloc] init];
            return;
        }
    }
    //Token ne postoji ili se dogodila greska prilikom pristupa
    @catch(NSException *ex){
        
    }
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


@end
