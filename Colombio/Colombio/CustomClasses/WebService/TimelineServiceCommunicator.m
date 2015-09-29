//
//  TimelineServiceCommunicator.m
//  Colombio
//
//  Created by Vlatko Šprem on 20/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimelineServiceCommunicator.h"
#import "Messages.h"
#import "CryptoClass.h"
#import "AppDelegate.h"
#import "Tools.h"



@implementation TimelineServiceCommunicator

+ (id)sharedManager {
    static TimelineServiceCommunicator *sharedMyManager = nil;
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

- (void)fetchTimeLine{
    NSInteger lastTimestamp = ([[NSUserDefaults standardUserDefaults] integerForKey:TIMELINE_TIMESTAMP]?[[NSUserDefaults standardUserDefaults] integerForKey:TIMELINE_TIMESTAMP]:0);
   //lastTimestamp=0;
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/get_full_timeline?signed_req=%@&sync_time=%ld", BASE_URL, [[self class] getSignedRequest],(long)lastTimestamp];
    NSURL * url = [NSURL URLWithString:url_str];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error==nil && data!=nil){
            AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(result!=nil && result[@"s"] && !strcmp("1",((NSString*)[result objectForKey:@"s"]).UTF8String)){
                [[NSUserDefaults standardUserDefaults] setObject:result[@"data"][@"req_timestamp"] forKey:TIMELINE_TIMESTAMP];
                [[NSUserDefaults standardUserDefaults] synchronize];
                for(NSDictionary *tDict in result[@"data"][@"news"]){
                    NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
                    tDBDict[@"news_id"]=@([tDict[@"news_id"] intValue]);
                    tDBDict[@"news_title"]=tDict[@"news_title"];
                    tDBDict[@"news_text"]=tDict[@"news_text"];
                    tDBDict[@"cost"]=tDict[@"cost"];
                    tDBDict[@"timestamp"]=[Tools getDateFromAPIString:tDict[@"news_timestamp"]];
                    tDBDict[@"lat"]= (tDict[@"lat"]!=[NSNull null]?@([tDict[@"lat"] floatValue]):[NSNull null]);
                    tDBDict[@"lng"]= (tDict[@"lng"]!=[NSNull null]?@([tDict[@"lng"] floatValue]):[NSNull null]);
                    tDBDict[@"media_list"]=tDict[@"media_list"];
                    tDBDict[@"anonymous"]=@([tDict[@"anonymous"] intValue]);
                    tDBDict[@"type_id"]=@([tDict[@"type_id"] intValue]);
                    tDBDict[@"user_id"] = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
                    
                    if (tDict[@"ext_data"] && tDict[@"ext_data"] != [NSNull null])
                    {
                        NSData *extDataJson = [tDict[@"ext_data"] dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *e;
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:extDataJson options:NSJSONReadingMutableContainers error:&e];
                        
                        NSString *strDate = [NSString stringWithFormat:@"%@ %@", dict[@"date"], dict[@"time"]];
                        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                        tDBDict[@"date"] = [formatter dateFromString:strDate];
                    }
                    
                    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM timeline WHERE news_id = '%@'", tDBDict[@"news_id"]];
                    if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                        //tDBDict[@"isread"]=@0;
                        [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE"];
                    }else{
                        [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE" where:[NSString stringWithFormat:@" news_id='%lld'", [tDBDict[@"news_id"] longLongValue]]];
                    }
                    
                    tDBDict = [[NSMutableDictionary alloc] init];
                    if (tDict[@"image_data"] != [NSNull null]) {
                        NSArray *arrayImages = [(NSString*)tDict[@"image_data"] componentsSeparatedByString:@"\",\""];
                        for(NSString *tString in arrayImages){
                            NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"\"\\ {}"];
                            NSString *strippedString = [[tString componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
                            NSArray *arrImage =[strippedString componentsSeparatedByString:@":"];
                            tDBDict[arrImage[0]]= [NSString stringWithFormat:@"https://afs.colomb.io/%@",arrImage[1]];
                        }
                        tDBDict[@"news_id"]=@([tDict[@"news_id"] intValue]);
                        tDBDict[@"is_video"]=@0;
                        sql = [NSString stringWithFormat:@"SELECT count(*) FROM timeline_image WHERE news_id = '%@'", tDBDict[@"news_id"]];
                        if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                            [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE_IMAGE"];
                        }else{
                            [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE_IMAGE" where:[NSString stringWithFormat:@" news_id='%@'", tDBDict[@"news_id"]]];
                        }
                    }else if(tDict[@"video_thumb"] != [NSNull null]) {
                        NSArray *arrayImages = [(NSString*)tDict[@"video_thumb"] componentsSeparatedByString:@"\",\""];
                        for(NSString *tString in arrayImages){
                            NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"\"\\ {}"];
                            NSString *strippedString = [[tString componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
                            NSArray *arrImage =[strippedString componentsSeparatedByString:@":"];
                            tDBDict[arrImage[0]]= [NSString stringWithFormat:@"https://afs.colomb.io/%@",arrImage[1]];
                        }
                        tDBDict[@"news_id"]=@([tDict[@"news_id"] intValue]);
                        tDBDict[@"is_video"]=@1;
                        sql = [NSString stringWithFormat:@"SELECT count(*) FROM timeline_image WHERE news_id = '%@'", tDBDict[@"news_id"]];
                        if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                            [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE_IMAGE"];
                        }else{
                            [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE_IMAGE" where:[NSString stringWithFormat:@" news_id='%@'", tDBDict[@"news_id"]]];
                        }
                    }
                    
                    //VIDEO THUMB!!!!!!!
                }
                for(NSDictionary *tDict in result[@"data"][@"notif"]){
                    NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
                    tDBDict[@"id"] = tDict[@"id"];
                    tDBDict[@"user_id"] = tDict[@"user_id"];
                    tDBDict[@"timestamp"] = [Tools getDateFromAPIString:tDict[@"notif_timestamp"]];
                    tDBDict[@"type_id"] = tDict[@"type_id"];
                    tDBDict[@"is_read"] = tDict[@"is_read"];
                    
                    NSData *data = [tDict[@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *result =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    
                    tDBDict[@"mid"] = result[@"mid"]!=nil?result[@"mid"]:@"";
                    tDBDict[@"msg"] = result[@"msg"]!=nil?result[@"msg"]:@"";
                    tDBDict[@"nid"] = result[@"nid"]!=nil?result[@"nid"]:@"";
                    tDBDict[@"title"] = result[@"title"]!=nil?result[@"title"]:@"";
                    
                    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM timeline_notifications WHERE id = '%@'", tDBDict[@"id"]];
                    if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                        [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE_NOTIFICATIONS"];
                    }else{
                        [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE_NOTIFICATIONS" where:[NSString stringWithFormat:@" id='%@'", tDBDict[@"id"]]];
                    }
                }
                for(NSDictionary *tDict in result[@"data"][@"alerts"]){
                    /*NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
                     tDBDict[@"id"] = tDict[@"id"];
                     tDBDict[@"user_id"] = tDict[@"user_id"];
                     tDBDict[@"timestamp"] = [Tools getDateFromAPIString:tDict[@"notif_timestamp"]];
                     tDBDict[@"type_id"] = tDict[@"type_id"];
                     tDBDict[@"is_read"] = tDict[@"is_read"];
                     NSArray *arrayNotifs = [(NSString*)tDict[@"content"] componentsSeparatedByString:@"\",\""];
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
                     }*/
                }
                
                [self.timelineDelegate didFetchTimeline];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.timelineDelegate didFetchTimeline];
                    [Messages showErrorMsg:@"error_web_request"];
                });
            }
            
        }
        //Ako nije dobra konekcija
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.timelineDelegate didFetchTimeline];
                [Messages showErrorMsg:@"error_web_request"];
            });
            return;
        }
    }];
}

@end
