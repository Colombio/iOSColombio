//
//  UIConfiguration.m
//  Colombio
//
//  Created by Vlatko Šprem on 20/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "UIConfiguration.h"

@implementation UIConfiguration

+ (UIConfiguration *)sharedInstance {
    static UIConfiguration *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UIConfiguration alloc] init];
    });
    return sharedInstance;
}


@end
