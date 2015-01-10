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
        colorMap[COLOR_BLACK_TRANSPARENT] = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
        colorMap[COLOR_CUSTOM_RED] = [UIColor redColor];
        colorMap[COLOR_TEXT_NAVIGATIONBAR_TITLE] = [UIColor colorWithWhite:0.2 alpha:1.0];
        colorMap[COLOR_TEXT_NAVIGATIONBAR_BUTTON] = [UIColor colorWithWhite:0.1 alpha:0.5];
        colorMap[COLOR_TEXT_NAVIGATIONBAR_BUTTON_HIGHLIGHT] = [UIColor colorWithWhite:0.1 alpha:0.2];
        
        fontMap = [[NSMutableDictionary alloc] init];
        fontMap[FONT_HELVETICA_NEUE_ULTRALIGHT]             = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:17];
        fontMap[FONT_HELVETICA_NEUE_BOLD]                   = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        fontMap[FONT_HELVETICA_NEUE_REGULAR_SMALL]          = [UIFont fontWithName:@"HelveticaNeue" size:14];
        fontMap[FONT_HELVETICA_NEUE_REGULAR_EXTRA_SMALL]    = [UIFont fontWithName:@"HelveticaNeue" size:10];
        fontMap[FONT_HELVETICA_NEUE_BOLD_SMALL]             = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        fontMap[FONT_HELVETICA_NEUE_LIGHT_SMALL]                  = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        fontMap[FONT_HELVETICA_NEUE_LIGHT]                  = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        fontMap[FONT_HELVETICA_NEUE_REGULAR]                = [UIFont fontWithName:@"HelveticaNeue" size:17];
        fontMap[FONT_HELVETICA_NEUE_BOLD_LARGE]             = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
        fontMap[FONT_HELVETICA_NEUE_BOLD_MIDDLE]             = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
        
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
