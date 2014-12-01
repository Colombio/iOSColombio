//
//  ColombioServiceCommunicator.m
//  colombio
//
//  Created by Vlatko Šprem on 31/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "ColombioServiceCommunicator.h"
//#import "Settings.h"
#import "CryptoClass.h"
#import "AppDelegate.h"
#import "Tools.h"
#import "Messages.h"

@implementation _ColombioServiceCommunicator

+ (id)sharedManager {
    static _ColombioServiceCommunicator *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSString*)getSignedRequest{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //citanje posljednjeg timestampa za drzave
    NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"korisnik.out"];
    NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
    NSString *token = [NSString stringWithContentsOfFile:filePathToken encoding:NSUTF8StringEncoding error:nil];
    NSString *userId = [NSString stringWithContentsOfFile:filePathUser encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *provjera = @{@"usr" : userId,@"token" : token};
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:provjera options:0 error:&err];
    NSString *result= [CryptoClass base64Encoding:data];
    return result;
}

//TODO fetching news demands
/*
#pragma mark NewsDemands
- (void)fetchNewsDemands{
    NSString *url_str;
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    if (appdelegate.locationManager) {
        NSString *lat = [NSString stringWithFormat:@"%f",appdelegate.locationManager.location.coordinate.latitude];
        NSString *lng = [NSString stringWithFormat:@"%f",appdelegate.locationManager.location.coordinate.longitude];
        url_str = [NSString stringWithFormat:@"http://appforrest.com/colombio/api_content/get_news_demands?signed_req=%@&lat=%@&lng=%@&sync_time=%@",[self getSignedRequest], lat, lng, ([[NSUserDefaults standardUserDefaults] stringForKey:SYNC_TIME_NEWS_DEMAND]!=nil?[[NSUserDefaults standardUserDefaults] stringForKey:SYNC_TIME_NEWS_DEMAND]:@"0")];
    }else{
        url_str = [NSString stringWithFormat:@"http://appforrest.com/colombio/api_content/get_news_demands?signed_req=%@&sync_time=%@",[self getSignedRequest], ([[NSUserDefaults standardUserDefaults] stringForKey:SYNC_TIME_NEWS_DEMAND]!=nil?[[NSUserDefaults standardUserDefaults] stringForKey:SYNC_TIME_NEWS_DEMAND]:@"0")];
    }
    NSURL * url = [NSURL URLWithString:url_str];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error==nil){
            AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
            NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            [[NSUserDefaults standardUserDefaults] setObject:result[@"change_timestamp"] forKey:SYNC_TIME_NEWS_DEMAND];
            [[NSUserDefaults standardUserDefaults] synchronize];
            for(NSDictionary *tDict in result[@"data"]){
                NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
                tDBDict[@"NEWSDEMAND_ID"]=@([tDict[@"req_id"] intValue]);
                tDBDict[@"TITLE"]=tDict[@"title"];
                tDBDict[@"COST"]=tDict[@"cost"];
                tDBDict[@"DESCRIPTION"]=tDict[@"description"];
                tDBDict[@"END_TIMESTAMP"]=[_Tools getDateFromAPIString:tDict[@"end_timestamp"]];
                tDBDict[@"START_TIMESTAMP"]=[_Tools getDateFromAPIString:tDict[@"start_timestamp"]];
                tDBDict[@"LAT"]=@([tDict[@"lat"] floatValue]);
                tDBDict[@"LONG"]=@([tDict[@"lng"] floatValue]);
                tDBDict[@"MEDIA_ID"]=@([tDict[@"media_id"] intValue]);
                tDBDict[@"RADIUS"]=@([tDict[@"radius"] intValue]);
                tDBDict[@"STATUS"]=@([tDict[@"status"] intValue]);
                NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM newsdemandlist WHERE newsdemand_id = '%d'", [tDBDict[@"NEWSDEMAND_ID"] intValue]];
                if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                    tDBDict[@"ISREAD"]=@0;
                    [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"NEWSDEMANDLIST"];
                }else{
                    [appdelegate.db updateDictionary:tDBDict forTable:@"NEWSDEMANDLIST" where:[NSString stringWithFormat:@" NEWSDEMAND_ID='%d'", [tDict[@"NEWSDEMAND_ID"] intValue]]];
                }
            }
            [self.delegate didFetchNewsDemands:result];
        }
        //Ako nije dobra konekcija
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate fetchingFailedWithError:error];
                //[_Messages showErrorMsg:@"This app requires internet connection. Please make sure that you are connected to the internet."];
                            });
            return;
        }
    }];
}
*/

@end
