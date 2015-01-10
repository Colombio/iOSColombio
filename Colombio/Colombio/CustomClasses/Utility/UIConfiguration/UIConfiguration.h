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
static NSString *FONT_HELVETICA_NEUE_LIGHT_SMALL = @"FONT_HELVETICA_NEUE_LIGHT_SMALL";
static NSString *FONT_HELVETICA_NEUE_LIGHT = @"FONT_HELVETICA_NEUE_LIGHT";
static NSString *FONT_HELVETICA_NEUE_BOLD_LARGE = @"FONT_HELVETICA_NEUE_BOLD_LARGE";
static NSString *FONT_HELVETICA_NEUE_REGULAR = @"FONT_HELVETICA_NEUE_REGULAR";
static NSString *FONT_HELVETICA_NEUE_BOLD_MIDDLE = @"FONT_HELVETICA_NEUE_BOLD_MIDDLE";

//keyboard type
static NSString *KEYBOARD_DEFAULT = @"KEYBOARD_DEFAULT";
static NSString *KEYBOARD_NUMERIC = @"KEYBOARD_NUMBERIC";
static NSString *KEYBOARD_DIAL = @"KEYBOARD_DIAL";
static NSString *KEYBOARD_EMAIL = @"KEYBOARD_EMAIL";

@interface UIConfiguration : NSObject
{
    NSMutableDictionary *colorMap;
    NSMutableDictionary *fontMap;
    NSMutableDictionary *keyboardMap;
}
+ (UIConfiguration *)sharedInstance;

- (UIFont *) getFont:(NSString *) fontName;
- (UIColor *) getColor:(NSString *) colorName;
- (UIKeyboardType)getKeyboardType:(NSString*)keyboardType;
@end
