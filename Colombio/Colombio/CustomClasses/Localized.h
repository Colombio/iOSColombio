//
//  Localized.h
//  Colombio
//
//  Created by Vlatko Šprem on 29/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Localized : NSObject{
    NSBundle *bundleAttribute;
    NSString *pathAttribute;
}
@property (nonatomic, strong) NSBundle *bundleAttribute;
@property (nonatomic, strong) NSString *pathAttribute;
+ (NSBundle *)bundle;
+ (NSString *)string:(NSString *)stringKey;
+ (void)save:(NSString *)languageKey;
+ (void)reset;
+ (NSString *)path;
+ (NSString *)prefferedLocalization;

@end

