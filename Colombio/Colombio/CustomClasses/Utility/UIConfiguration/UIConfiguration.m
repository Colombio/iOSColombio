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

- (instancetype)init{
    self = [super init];
    if (self) {
        colorMap = [[NSMutableDictionary alloc] init];
        colorMap[COLOR_BLACK_TRANSPARENT] = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
        colorMap[COLOR_WHITE_TRANSPARENT] = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
        colorMap[COLOR_CUSTOM_RED] = [UIColor redColor];
        colorMap[COLOR_TEXT_NAVIGATIONBAR_TITLE] = [UIColor colorWithWhite:0.2 alpha:1.0];
        colorMap[COLOR_TEXT_NAVIGATIONBAR_BUTTONLABEL] = [UIColor colorWithWhite:0.1 alpha:0.9];
        colorMap[COLOR_TEXT_NAVIGATIONBAR_BUTTON] = [UIColor colorWithWhite:0.1 alpha:0.5];
        colorMap[COLOR_TEXT_NAVIGATIONBAR_BUTTON_HIGHLIGHT] = [UIColor colorWithWhite:0.1 alpha:0.2];
        colorMap[COLOR_TAGS_TEXT_NORMAL] = [UIColor colorWithWhite:0.5 alpha:0.5];
        colorMap[COLOR_TAGS_TEXT_SELECTED] = [UIColor colorWithWhite:0.1 alpha:0.9];
        colorMap[COLOR_TAGS_BACKGROUND_SELECTED] = [UIColor colorWithWhite:0.9 alpha:0.5];
        colorMap[COLOR_PROGRES_BAR] = [UIColor colorWithRed:197.0/255.0 green:69.0/255.0 blue:42.0/255.0 alpha:1.0];
        colorMap[COLOR_WHITE_CUSTOM] = [UIColor whiteColor];
        colorMap[COLOR_PLACEHOLDER_NEWS_TITLE] = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        colorMap[COLOR_TEXT_NEWS_TITLE] = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0];
        colorMap[COLOR_TEXT_TXT_FIELD] = [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
        colorMap[COLOR_PLACEHOLDER_TXT_FIELD] = [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:0.5];
        colorMap[COLOR_NEWS_DEMAND_DESCRIPTION] = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        colorMap[COLOR_NEWS_DEMAND_LIGHT_GRAY] = [UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:0.3];
        colorMap[COLOR_NEXT_BUTTON] = [UIColor colorWithRed:228.0/255.0 green:67.0/255.0 blue:36.0/255.0 alpha:1.0];
        colorMap[COLOR_NEXT_BUTTON_SELECTED] = [UIColor colorWithRed:228.0/255.0 green:67.0/255.0 blue:36.0/255.0 alpha:0.3];
        colorMap[COLOR_TEXT_79_04] = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:0.4];
        
        
        fontMap = [[NSMutableDictionary alloc] init];
        fontMap[FONT_HELVETICA_NEUE_REGULAR_EXTRA_SMALL]    = [UIFont fontWithName:@"HelveticaNeue" size:10];
        fontMap[FONT_HELVETICA_NEUE_REGULAR_SMALL]          = [UIFont fontWithName:@"HelveticaNeue" size:14];
        fontMap[FONT_HELVETICA_NEUE_BOLD_SMALL]             = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        fontMap[FONT_HELVETICA_NEUE_LIGHT_SMALL]            = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        fontMap[FONT_HELVETICA_NEUE_LIGHT_SMALL_15]            = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        fontMap[FONT_HELVETICA_NEUE_MEDIUM_15]              = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
        fontMap[FONT_HELVETICA_NEUE_TAGS_ITALIC]            = [UIFont fontWithName:@"HelveticaNeue-Italic" size:16];
        fontMap[FONT_HELVETICA_NEUE_ULTRALIGHT]             = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:17];
        fontMap[FONT_HELVETICA_NEUE_BOLD]                   = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        fontMap[FONT_HELVETICA_NEUE_MEDIUM]                 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
        fontMap[FONT_HELVETICA_NEUE_LIGHT]                  = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        fontMap[FONT_HELVETICA_NEUE_REGULAR]                = [UIFont fontWithName:@"HelveticaNeue" size:17];
        fontMap[FONT_HELVETICA_NEUE_REGULAR_19]                = [UIFont fontWithName:@"HelveticaNeue" size:19];
        fontMap[FONT_HELVETICA_NEUE_MEDIUM_19]              = [UIFont fontWithName:@"HelveticaNeue-Medium" size:19];
        fontMap[FONT_HELVETICA_NEUE_NEXT]                   = [UIFont fontWithName:@"HelveticaNeue" size:20];
        fontMap[FONT_HELVETICA_NEUE_BOLD_MIDDLE]            = [UIFont fontWithName:@"HelveticaNeue" size:25];
        fontMap[FONT_HELVETICA_NEUE_BOLD_LARGE_OFFER]       = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28];
        fontMap[FONT_HELVETICA_NEUE_BOLD_LARGE]             = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
        
        
   
        keyboardMap = [[NSMutableDictionary alloc] init];
        keyboardMap[KEYBOARD_DEFAULT]       = @(UIKeyboardTypeDefault);
        keyboardMap[KEYBOARD_DIAL]          = @(UIKeyboardTypeNamePhonePad);
        keyboardMap[KEYBOARD_NUMERIC]       = @(UIKeyboardTypeDecimalPad);
        keyboardMap[KEYBOARD_EMAIL]         = @(UIKeyboardTypeEmailAddress);
    }
    return self;
}

- (UIColor *)getColor:(NSString *)colorName{
    UIColor *color = (UIColor *)[colorMap objectForKey:colorName];
    return color ? color : [UIColor blackColor];
}

- (UIFont *) getFont:(NSString *)fontName{
    
    return (UIFont *)[fontMap objectForKey:fontName];
    
}

- (UIKeyboardType)getKeyboardType:(NSString*)keyboardType{
    return (UIKeyboardType)[[keyboardMap objectForKey:keyboardType] integerValue];
}
@end
