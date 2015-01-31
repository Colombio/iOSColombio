//
//  UITextField+XibAttributes.m
//  Colombio
//
//  Created by Vlatko Šprem on 30/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UITextField+XibAttributes.h"

@implementation UITextField (XibAttributes)
@dynamic configPlaceholder, placeholderColor;

- (void)setConfigPlaceholder:(NSString *)configPlaceholder{
    if ([self respondsToSelector:@selector(setPlaceholder:)]) {
        [self setPlaceholder:[Localized string:configPlaceholder]];
    }
}

- (void)setPlaceholderColor:(NSString *)placeholderColor{
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: [[UIConfiguration sharedInstance] getColor:placeholderColor]}];
    } 
}
@end
