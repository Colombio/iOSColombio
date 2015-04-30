//
//  ColombioServiceCommunicator.m
//  Colombio
//
//  Created by Vlatko Šprem on 09/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "ColombioServiceCommunicator.h"
//#import "Settings.h"
#import "CryptoClass.h"
#import "AppDelegate.h"
#import "Tools.h"
#import "Messages.h"

@implementation ColombioServiceCommunicator
@synthesize request;
@synthesize locationManager;

+ (id)sharedManager {
    static ColombioServiceCommunicator *sharedMyManager = nil;
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


-(void)sendAsyncHttp:(NSString *)strUrl httpBody:(NSString *)strBody cache:(NSUInteger)cachePolicy timeoutInterval:(double)timeout{
    NSURL * url = [NSURL URLWithString:strUrl];
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeout];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[strBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    //Timeout wont work
    [request setTimeoutInterval:timeout];
}

#pragma mark Tags

- (void)fetchTags{
    NSString *url_str = [NSString stringWithFormat:@"%@/api_config/get_news_tags?signed_req=%@", BASE_URL, [ColombioServiceCommunicator getSignedRequest]];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(err!=nil&&data==nil){
                //TODO - check connection, check error
                [Messages showErrorMsg:@"This app requires internet connection. Please make sure that you are connected to the internet."];
                return;
            }else{
                NSMutableDictionary *result=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                [self.delegate didFetchTags:result];
            }
        });
    }];
            
}

#pragma mark User

- (void)fetchUserProfile{
    NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_get_profile?signed_req=%@", BASE_URL, [ColombioServiceCommunicator getSignedRequest]];
    NSURL * url = [NSURL URLWithString:url_str];
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error!=nil&&data==nil){
                //TODO - check connection, check error
                [Messages showErrorMsg:@"error_web_request"];
                return;
            }else{
                NSError* error = nil;
                NSDictionary  *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSString *test= result[@"s"];
                if (!strcmp("1", test.UTF8String)) {
                    NSMutableDictionary *dbDict = [[NSMutableDictionary alloc] init];
                    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    [appdelegate.db clearTable:@"USER"];
                    [appdelegate.db clearTable:@"USER_CASHOUT"];
                    dbDict[@"user_id"] = result[@"user_data"][@"user_id"];
                    dbDict[@"user_name"] = result[@"user_data"][@"user_name"];
                    dbDict[@"user_email"] = result[@"user_data"][@"user_email"];
                    dbDict[@"first_name"] = result[@"user_data"][@"first_name"];
                    dbDict[@"last_name"] = result[@"user_data"][@"last_name"];
                    dbDict[@"city"] = result[@"user_data"][@"city"];
                    dbDict[@"zip"] = result[@"user_data"][@"zip"];
                    dbDict[@"phone_number"] = result[@"user_data"][@"phone_number"];
                    dbDict[@"paypal_email"] = result[@"user_data"][@"paypal_email"];
                    dbDict[@"anonymous"] = result[@"user_data"][@"anonymous"];
                    dbDict[@"balance"] = result[@"user_data"][@"balance"];
                    dbDict[@"ntf_push"] = result[@"user_data"][@"ntf_push"];
                    dbDict[@"ntf_in_app"] = result[@"user_data"][@"ntf_in_app"];
                    dbDict[@"ntf_email"] = result[@"user_data"][@"ntf_email"];
                    dbDict[@"rating"] = result[@"user_data"][@"rating"];
                    [appdelegate.db insertDictionaryWithoutColumnCheck:dbDict forTable:@"USER"];
                    [[NSUserDefaults standardUserDefaults] setObject:result[@"user_data"][@"country_id"] forKey:COUNTRY_ID];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self.delegate didFetchUserDetails:result];
                }else{
                    [Messages showErrorMsg:@"error_web_request"];
                    return;
                }
                
            }
        });
    }];
}

- (void)checkUserStatus{
    NSString *url_str = [NSString stringWithFormat:@"%@/api_user_managment/mau_check_status?signed_req=%@", BASE_URL, [ColombioServiceCommunicator getSignedRequest]];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(err!=nil&&data==nil){
                //TODO - check connection, check error
                [Messages showErrorMsg:@"error_web_request"];
                return;
            }else{
                NSMutableDictionary *result=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                [self.delegate didCheckUserStatus:result];
            }
        });
    }];
}


#pragma mark NewsDemands
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
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
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

#pragma mark Media

- (void)fetchMedia{
    NSInteger lastTimestamp = ([[NSUserDefaults standardUserDefaults] integerForKey:MEDIA_TIMESTAMP]?[[NSUserDefaults standardUserDefaults] integerForKey:MEDIA_TIMESTAMP]:0);
    
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableArray *countries = [appdelegate.db getAllForSQL:@"select c_id from selected_countries where status = 1"];
    NSMutableArray *selectedCountriesID = [[NSMutableArray alloc] init];
    [selectedCountriesID addObject:@([[NSUserDefaults standardUserDefaults] integerForKey:COUNTRY_ID])];
    if (countries.count>0) {
        for(NSDictionary *tDict in countries){
            [selectedCountriesID addObject:tDict[@"c_id"]];
        }
    }
    NSString *url_str;
    NSURL *url;
    if([[NSUserDefaults standardUserDefaults] integerForKey:COUNTRY_ID]!=0){
        NSData *jsonDataMedia = [NSJSONSerialization dataWithJSONObject:selectedCountriesID options:kNilOptions error:nil];
        NSString *selCountries = [[NSString alloc]initWithData:jsonDataMedia encoding:NSUTF8StringEncoding];
        url_str = [NSString stringWithFormat:@"%@/api_config/get_media?sync_time=%ld&cid=%@", BASE_URL, (long)lastTimestamp, selCountries];
        url = [NSURL URLWithString:url_str];
    }else{
        url_str = [NSString stringWithFormat:@"%@/api_config/get_media?sync_time=%ld", BASE_URL, (long)lastTimestamp];
        url = [NSURL URLWithString:url_str];
    }
    
    NSMutableURLRequest *req =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    /*if (_selectedCountries.count>0) {
     [request setHTTPBody:[selCountries dataUsingEncoding:NSUTF8StringEncoding]];
     }*/
    [req setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error==nil&&data!=nil){
                Boolean isDataChanged=true;
                NSDictionary *dataWsResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[dataWsResponse allKeys];
                for(NSString *key in keys){
                    //Nije mijenjan popis medija
                    if(!strcmp("s", key.UTF8String)){
                        isDataChanged=false;
                        break;
                    }
                }
                //Ako je mijenjan popis medija
                if(isDataChanged){
                    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    NSString *changeTimestamp= [NSString stringWithFormat:@"%@",[dataWsResponse objectForKey:@"change_timestamp"]];
                    [[NSUserDefaults standardUserDefaults] setObject:changeTimestamp forKey:MEDIA_TIMESTAMP];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    for(NSDictionary *tDict in dataWsResponse[@"data"]){
                        //[appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"MEDIA_LIST"];
                        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM media_list WHERE id = '%d'", [tDict[@"id"] intValue]];
                        if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                            [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"MEDIA_LIST"];
                        }else{
                            [appdelegate.db updateDictionary:tDict forTable:@"MEDIA_LIST" where:[NSString stringWithFormat:@" id='%d'", [tDict[@"id"] intValue]]];
                        }
                    }
                }
                [self.delegate didFetchMedia];
            }
            else{
                [Messages showErrorMsg:@"error_web_request"];
                [self.delegate fetchingFailedWithError:error];
                
            }
        });
    }];
}

- (void)fetchFavoriteMedia{
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/get_fav_media?signed_req=%@", BASE_URL,[[self class] getSignedRequest]];
    NSURL *url = [NSURL URLWithString:url_str];
    NSMutableURLRequest *req =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [req setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error==nil&&data!=nil){
                NSDictionary *dataWsResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                [self.delegate didFetchFavoriteMedia:(NSArray*)dataWsResponse];
            }
            else{
                [Messages showErrorMsg:@"error_web_request"];
                [self.delegate fetchingFailedWithError:error];
            }
        });
    }];
}

- (void)fetchMediaPhoneNumber:(NSInteger)mediaId{
    NSString *url_str = [NSString stringWithFormat:@"%@/api_config/call_media?signed_req=%@&mid=%d", BASE_URL,[[self class] getSignedRequest], mediaId];
    NSURL *url = [NSURL URLWithString:url_str];
    NSMutableURLRequest *req =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [req setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error==nil&&data!=nil){
                NSDictionary *dataWsResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                [self.delegate didFetchMediaNumber:(NSString*)dataWsResponse[@"media_number"]];
            }
            else{
                [Messages showErrorMsg:@"error_web_request"];
                [self.delegate fetchingFailedWithError:error];
            }
        });
    }];

}

#pragma mark Fetc Countries
- (void)fetchCountries{
    NSInteger lastTimestamp = ([[NSUserDefaults standardUserDefaults] integerForKey:COUNTRIES_TIMESTAMP]?[[NSUserDefaults standardUserDefaults] integerForKey:COUNTRIES_TIMESTAMP]:0);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api_config/get_sys_countries?sync_time=%ld", BASE_URL, (long)lastTimestamp]];
    NSMutableURLRequest *req =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //If data from server is successfuly fetched
            if(error==nil&&data!=nil){
                NSDictionary *dataWsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                if (!dataWsResponse[@"s"]) {
                     //&& strcmp("0", ((NSString*)dataWsResponse[@"s"]).UTF8String
                    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    [appdelegate.db clearTable:@"COUNTRIES_LIST"];
                    
                    NSString *changeTimestamp=[dataWsResponse objectForKey:@"change_timestamp"];
                    [[NSUserDefaults standardUserDefaults] setObject:changeTimestamp forKey:COUNTRIES_TIMESTAMP];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    for(NSDictionary *tDict in dataWsResponse[@"data"]){
                        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM countries_list WHERE c_id = '%d'", [tDict[@"c_id"] intValue]];
                        if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                            [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"COUNTRIES_LIST"];
                        }else{
                            [appdelegate.db updateDictionary:tDict forTable:@"COUNTRIES_LIST" where:[NSString stringWithFormat:@" c_id='%d'", [tDict[@"c_id"] intValue]]];
                        }
                    }
                }
                [self.delegate didFetchCountries];
            }
            else{
                [Messages showErrorMsg:@"error_web_request"];
                [self.delegate fetchingFailedWithError:error];
            }
        });
    }];
}

#pragma mark TimeLine
- (void)fetchTimeLine{
    NSInteger lastTimestamp = ([[NSUserDefaults standardUserDefaults] integerForKey:TIMELINE_TIMESTAMP]?[[NSUserDefaults standardUserDefaults] integerForKey:TIMELINE_TIMESTAMP]:0);
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/get_full_timeline?signed_req=%@&sync_time=%ld", BASE_URL, [[self class] getSignedRequest],(long)lastTimestamp];
    NSURL * url = [NSURL URLWithString:url_str];
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error==nil && data!=nil){
            AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            [[NSUserDefaults standardUserDefaults] setObject:result[@"data"][@"req_timestamp"] forKey:TIMELINE_TIMESTAMP];
            [[NSUserDefaults standardUserDefaults] synchronize];
            for(NSDictionary *tDict in result[@"data"][@"news"]){
                NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
                tDBDict[@"news_id"]=@([tDict[@"news_id"] intValue]);
                tDBDict[@"news_title"]=tDict[@"news_title"];
                tDBDict[@"news_text"]=tDict[@"news_text"];
                tDBDict[@"cost"]=tDict[@"cost"];
                tDBDict[@"news_timestamp"]=[Tools getDateFromAPIString:tDict[@"news_timestamp"]];
                tDBDict[@"lat"]= (tDict[@"lat"]!=[NSNull null]?@([tDict[@"lat"] floatValue]):[NSNull null]);
                tDBDict[@"lng"]= (tDict[@"lng"]!=[NSNull null]?@([tDict[@"lng"] floatValue]):[NSNull null]);
                tDBDict[@"media_list"]=@([tDict[@"media_list"] intValue]);
                tDBDict[@"anonymous"]=@([tDict[@"anonymous"] intValue]);
                tDBDict[@"type_id"]=@([tDict[@"type_id"] intValue]);
                NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM timeline WHERE news_id = '%d'", [tDBDict[@"news_id"] intValue]];
                if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                    //tDBDict[@"isread"]=@0;
                    [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE"];
                }else{
                    [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE" where:[NSString stringWithFormat:@" news_id='%d'", [tDict[@"news_id"] intValue]]];
                }
                
                tDBDict = [[NSMutableDictionary alloc] init];
                if (tDict[@"image_data"] != [NSNull null]) {
                    NSArray *arrayImages = [(NSString*)tDict[@"image_data"] componentsSeparatedByString:@","];
                    for(NSString *tString in arrayImages){
                        NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"\"\\ {}"];
                        NSString *strippedString = [[tString componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
                        NSArray *arrImage =[strippedString componentsSeparatedByString:@":"];
                        tDBDict[arrImage[0]]= [NSString stringWithFormat:@"https://afs.colomb.io/%@",arrImage[1]];
                    }
                    tDBDict[@"news_id"]=@([tDict[@"news_id"] intValue]);
                    sql = [NSString stringWithFormat:@"SELECT count(*) FROM timeline_image WHERE news_id = '%d'", [tDBDict[@"news_id"] intValue]];
                    if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                        [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE_IMAGE"];
                    }else{
                        [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE_IMAGE" where:[NSString stringWithFormat:@" news_id='%d'", [tDict[@"news_id"] intValue]]];
                    }
                }
                
                //VIDEO THUMB!!!!!!!
            }
             for(NSDictionary *tDict in result[@"data"][@"notif"]){
                 NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
                 tDBDict[@"id"] = tDict[@"id"];
                 tDBDict[@"user_id"] = tDict[@"user_id"];
                 tDBDict[@"notif_timestamp"] = [Tools getDateFromAPIString:tDict[@"notif_timestamp"]];
                 tDBDict[@"type_id"] = tDict[@"type_id"];
                 tDBDict[@"is_read"] = tDict[@"is_read"];
                 NSArray *arrayNotifs = [(NSString*)tDict[@"content"] componentsSeparatedByString:@","];
                 for(NSString *tString in arrayNotifs){
                     NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"\"\\{}"];
                     NSString *strippedString = [[tString componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
                     NSArray *arrNotif =[strippedString componentsSeparatedByString:@":"];
                     tDBDict[arrNotif[0]]= arrNotif[1];
                 }
                 NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM timeline_notifications WHERE id = '%d'", [tDBDict[@"id"] intValue]];
                 if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                     [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE_NOTIFICATIONS"];
                 }else{
                     [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE_NOTIFICATIONS" where:[NSString stringWithFormat:@" id='%d'", [tDict[@"id"] intValue]]];
                 }
             }
            [self.delegate didFetchTimeline];
        }
        //Ako nije dobra konekcija
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didFetchTimeline];
                [Messages showErrorMsg:@"error_web_request"];
            });
            return;
        }
    }];
}

- (void)fetchTimeLineCounterOffers:(NSInteger)news_id{
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/get_news_counteroffers?signed_req=%@&nid=%d", BASE_URL, [[self class] getSignedRequest],news_id];
    NSURL * url = [NSURL URLWithString:url_str];
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error==nil && data!=nil){
            NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            [self.delegate didFetchTimeLineCounterOffers:result];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didFetchTimeline];
                [Messages showErrorMsg:@"error_web_request"];
            });
            return;
        }
    }];
}

- (void)fetchTimeLineCommunication:(NSInteger)news_id{
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/get_news_communication?signed_req=%@&nid=%d", BASE_URL, [[self class] getSignedRequest],news_id];
    NSURL * url = [NSURL URLWithString:url_str];
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error==nil && data!=nil){
            NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            [self.delegate didFetchTimeLineCommunication:result];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didFetchTimeline];
                [Messages showErrorMsg:@"error_web_request"];
            });
            return;
        }
    }];
}

#pragma mark User Action
- (void)updateUserPreferences:(NSDictionary*)userDict{
    NSString *signedRequest = [ColombioServiceCommunicator getSignedRequest];
    NSString *url = [NSString stringWithFormat:@"%@/api_user_managment/mau_update_preferences/", BASE_URL];
    
    NSData *jsonDataMedia = [NSJSONSerialization dataWithJSONObject:userDict options:kNilOptions error:nil];
    NSString *userPrefs = [[NSString alloc]initWithData:jsonDataMedia encoding:NSUTF8StringEncoding];
    
    NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&allertSettings=%@",signedRequest, userPrefs];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error==nil&&data!=nil){
            NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(!strcmp("1",((NSString*)[result objectForKey:@"s"]).UTF8String)){
                [self.delegate didSendUserPreferences];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate fetchingFailedWithError:error];
                    [Messages showErrorMsg:@"error_web_request"];
                });
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate fetchingFailedWithError:error];
                [Messages showErrorMsg:@"error_web_request"];
            });
        }
    }];
}

#pragma mark Info Text
- (void)fetchInfoTexts{
    NSInteger timestamp = [[NSUserDefaults standardUserDefaults] integerForKey:INFO_TEXTS_TIMESTAMP];
    NSInteger langId = 1;
    NSString *url_str = [NSString stringWithFormat:@"%@/api_config/get_texts?signed_req=%@&sync_time=%ld&lang_id=%ld", BASE_URL, [[self class] getSignedRequest],(long)timestamp, (long)langId];
    NSURL * url = [NSURL URLWithString:url_str];
    request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error==nil && data!=nil){
            NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(!strcmp("1",((NSString*)[result objectForKey:@"s"]).UTF8String)){
                [[NSUserDefaults standardUserDefaults] setObject:result[@"change_timestamp"] forKey:INFO_TEXTS_TIMESTAMP];
                [[NSUserDefaults standardUserDefaults] synchronize];
                for(NSDictionary *tDict in result[@"data"]){
                    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
                    tDBDict[@"text_id"] = tDict[@"text_id"];
                    tDBDict[@"lang_id"] = tDict[@"lang_id"];
                    tDBDict[@"edit_timestamp"] = [Tools getDateFromAPIString:tDict[@"edit_timestamp"]];
                    tDBDict[@"title"] = tDict[@"title"];
                    tDBDict[@"content"] = tDict[@"content"];
                    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM INTO_TEXTS WHERE text_id = '%@'", tDBDict[@"text_id"]];
                    if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                        [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"INTO_TEXTS"];
                    }else{
                        [appdelegate.db updateDictionary:tDBDict forTable:@"INTO_TEXTS" where:[NSString stringWithFormat:@" text_id='%@'", tDict[@"text_id"]]];
                    }
                }
            }
            
            [self.delegate didFetchInfoTexts];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate fetchingFailedWithError:error];
                [Messages showErrorMsg:@"error_web_request"];
            });
            return;
        }
    }];
}

@end

