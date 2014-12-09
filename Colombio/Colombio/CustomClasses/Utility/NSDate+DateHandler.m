//
//  NSDate+DateHandler.m
//  Colombio
//
//  Created by Vlatko Šprem on 09/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "NSDate+DateHandler.h"

@implementation NSDate (DateHandler)

+ (NSString*)getStringFromDate:(NSDate*)date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

+ (NSDate*)getDateFromAPIString:(NSString*)date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:date];
}

+ (NSDate*)getDateFromString:(NSString*)date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZ"];
    return [formatter dateFromString:date];
}

+ (NSInteger)daysDifferenceBetween:(NSDate*)startDate And:(NSDate*)endDate{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    return [components day]+1;
}

@end
