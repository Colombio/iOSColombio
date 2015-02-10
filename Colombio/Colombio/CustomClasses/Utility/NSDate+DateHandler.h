//
//  NSDate+DateHandler.h
//  Colombio
//
//  Created by Vlatko Šprem on 09/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
// NSDate convenience methods.

#import <Foundation/Foundation.h>

@interface NSDate (DateHandler)

+ (NSString*)getStringFromDate:(NSDate*)date;
+ (NSDate*)getDateFromAPIString:(NSString*)date;
+ (NSDate*)getDateFromString:(NSString*)date;
+ (NSInteger)daysDifferenceBetween:(NSDate*)startDate And:(NSDate*)endDate;

@end
