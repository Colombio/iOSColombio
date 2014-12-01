//
//  Tools.h
//  colombio
//
//  Created by Vlatko Šprem on 19/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+ (NSString*)getStringFromDate:(NSDate*)date;
+ (NSDate*)getDateFromAPIString:(NSString*)date;
+ (NSDate*)getDateFromString:(NSString*)date;
+ (NSInteger)daysDifferenceBetween:(NSDate*)startDate And:(NSDate*)endDate;

+ (NSInteger)getNumberOfNewDemands;
+ (UILabel*)getBadgeObject:(long )count frame:(CGRect)frame;

@end
