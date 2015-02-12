/////////////////////////////////////////////////////////////
//
//  Validation.h
//  Armin Vrevic
//
//  Created by Colombio on 8/6/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that provides methods for regex or other types of
//  string validation
//
///////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@interface Validation : NSObject

+ (BOOL)validateEmail:(NSString *)emailStr;
+ (BOOL)isNumber:(NSString *)Str;

@end
