//
//  Tools.h
//  colombio
//
//  Created by Vlatko Šprem on 19/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
// Convenience methods.

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+ (NSInteger)getNumberOfNewDemands;
+ (UILabel*)getBadgeObject:(long )count frame:(CGRect)frame;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (NSString*)getFilePaths:(NSString *)filePathName;
+ (UIImage *)convertImageToGrayScale:(UIImage *)image;

+ (NSString*)getStringFromDate:(NSDate*)date;
+ (NSDate*)getDateFromAPIString:(NSString*)date;
+ (NSDate*)getDateFromString:(NSString*)date;
+ (NSInteger)daysDifferenceBetween:(NSDate*)startDate And:(NSDate*)endDate;
+ (NSString*)getStringFromDateString:(NSString*)strDate withFormat:(NSString*)strFormat;
@end
