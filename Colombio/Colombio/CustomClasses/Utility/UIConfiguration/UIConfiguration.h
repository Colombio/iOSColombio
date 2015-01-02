//
//  UIConfiguration.h
//  Colombio
//
//  Created by Vlatko Šprem on 20/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

//colors
static NSString *COLOR_BLACK_TRANSPARENT = @"COLOR_BLACK_TRANSPARENT";
static NSString *COLOR_CUSTOM_RED = @"COLOR_CUSTOM_RED";

//fonts
static NSString *FONT_HELVETICA_NEUE_ULTRALIGHT = @"FONT_HELVETICA_NEUE_ULTRALIGHT";
static NSString *FONT_HELVETICA_NEUE_BOLD = @"FONT_HELVETICA_NEUE_BOLD";
static NSString *FONT_HELVETICA_NEUE_REGULAR_SMALL = @"FONT_HELVETICA_NEUE_REGULAR_SMALL";
static NSString *FONT_HELVETICA_NEUE_REGULAR_EXTRA_SMALL = @"FONT_HELVETICA_NEUE_REGULAR_EXTRA_SMALL";
static NSString *FONT_HELVETICA_NEUE_BOLD_SMALL = @"FONT_HELVETICA_NEUE_BOLD_SMALL";
static NSString *FONT_HELVETICA_NEUE_LIGHT = @"FONT_HELVETICA_NEUE_LIGHT";

@interface UIConfiguration : NSObject
{
    NSMutableDictionary *colorMap;
    NSMutableDictionary *fontMap;
}
+ (UIConfiguration *)sharedInstance;

- (UIFont *) getFont:(NSString *) fontName;
- (UIColor *) getColor:(NSString *) colorName;
@end
