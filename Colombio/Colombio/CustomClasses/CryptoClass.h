/////////////////////////////////////////////////////////////
//
//  CryptoClass.h
//  Armin Vrevic
//
//  Created by Colombio on 8/6/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that primarily serves for the crypto algorithm functions
//
///////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@interface CryptoClass : NSObject

+ (NSMutableString*)base64Encoding:(NSData*)data;
+ (NSString *) md5:(NSString *) input;

@end
