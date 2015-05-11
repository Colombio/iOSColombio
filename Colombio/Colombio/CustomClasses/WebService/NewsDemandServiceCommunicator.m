//
//  NewsDemandServiceCommunicator.m
//  Colombio
//
//  Created by Vlatko Šprem on 08/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "NewsDemandServiceCommunicator.h"
#import "Messages.h"
#import "CryptoClass.h"
#import "AppDelegate.h"
#import "Tools.h"



@implementation NewsDemandServiceCommunicator

+ (id)sharedManager {
    static NewsDemandServiceCommunicator *sharedMyManager = nil;
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

+ (NSString*)getSignedRequest{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //citanje posljednjeg timestampa za drzave
    NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"user.out"];
    NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
    NSString *token = [NSString stringWithContentsOfFile:filePathToken encoding:NSUTF8StringEncoding error:nil];
    NSString *userId = [NSString stringWithContentsOfFile:filePathUser encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *provjera = @{@"usr" : (userId?userId:[NSNull null]),@"token" : (token?token:[NSNull null])};
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:provjera options:0 error:&err];
    if(!data){
        [Messages showErrorMsg:@"error_web_request"];
        return @"";
    }
    else{
        NSString *result= [CryptoClass base64Encoding:data];
        
        
        
        return result;
    }
}

- (void)fetchNewsDemands{
    NSString *url_str;
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.locationManager) {
        NSString *lat = [NSString stringWithFormat:@"%f",appdelegate.locationManager.location.coordinate.latitude];
        NSString *lng = [NSString stringWithFormat:@"%f",appdelegate.locationManager.location.coordinate.longitude];
        url_str = [NSString stringWithFormat:@"%@/api_content/get_news_demands?signed_req=%@&lat=%@&lng=%@&sync_time=%@",BASE_URL,[[self class] getSignedRequest], lat, lng, ([[NSUserDefaults standardUserDefaults] stringForKey:NEWSDEMAND_TIMESTAMP]!=nil?[[NSUserDefaults standardUserDefaults] stringForKey:NEWSDEMAND_TIMESTAMP]:@"0")];
    }else{
        url_str = [NSString stringWithFormat:@"%@/api_content/get_news_demands?signed_req=%@&sync_time=%@",BASE_URL, [[self class] getSignedRequest], ([[NSUserDefaults standardUserDefaults] stringForKey:NEWSDEMAND_TIMESTAMP]!=nil?[[NSUserDefaults standardUserDefaults] stringForKey:NEWSDEMAND_TIMESTAMP]:@"0")];
    }
    NSURL * url = [NSURL URLWithString:url_str];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error==nil && data!=nil){
            AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            [[NSUserDefaults standardUserDefaults] setObject:result[@"change_timestamp"] forKey:NEWSDEMAND_TIMESTAMP];
            [[NSUserDefaults standardUserDefaults] synchronize];
            for(NSDictionary *tDict in result[@"data"]){
                NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
                tDBDict[@"req_id"]=@([tDict[@"req_id"] intValue]);
                tDBDict[@"title"]=tDict[@"title"];
                tDBDict[@"cost"]=tDict[@"cost"];
                tDBDict[@"description"]=tDict[@"description"];
                tDBDict[@"end_timestamp"]=[Tools getDateFromAPIString:tDict[@"end_timestamp"]];
                tDBDict[@"start_timestamp"]=[Tools getDateFromAPIString:tDict[@"start_timestamp"]];
                tDBDict[@"lat"]= (tDict[@"lat"]!=[NSNull null]?@([tDict[@"lat"] floatValue]):[NSNull null]);
                tDBDict[@"lng"]= (tDict[@"lng"]!=[NSNull null]?@([tDict[@"lng"] floatValue]):[NSNull null]);
                tDBDict[@"media_id"]=@([tDict[@"media_id"] intValue]);
                tDBDict[@"radius"]=@([tDict[@"radius"] intValue]);
                tDBDict[@"status"]=@([tDict[@"status"] intValue]);
                tDBDict[@"distance"]=@([tDict[@"distance"] intValue]);
                tDBDict[@"location_type"]=@([tDict[@"location_type"] intValue]);
                NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM newsdemandlist WHERE req_id = '%d'", [tDBDict[@"req_id"] intValue]];
                if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                    tDBDict[@"isread"]=@0;
                    [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"NEWSDEMANDLIST"];
                }else{
                    [appdelegate.db updateDictionary:tDBDict forTable:@"NEWSDEMANDLIST" where:[NSString stringWithFormat:@" req_id='%d'", [tDict[@"req_id"] intValue]]];
                }
            }
            [self.delegate didFetchNewsDemands:result];
        }
        //Ako nije dobra konekcija
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.delegate fetchingFailedWithError:error];
                [Messages showErrorMsg:@"error_web_request"];
            });
            return;
        }
    }];
}

@end
