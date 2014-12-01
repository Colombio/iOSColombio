//
//  CryptoClass.h
//  colombio
//
//  Created by Colombio on 8/6/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptoClass : NSObject

+ (NSMutableString*)base64Encoding:(NSData*)data;
+ (NSString *) md5:(NSString *) input;

@end
