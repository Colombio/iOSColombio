//
//  UIView+XibAttributes.m
//  Colombio
//
//  Created by Vlatko Šprem on 30/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "UIView+XibAttributes.h"

/**
 *  Config User Defined Runtime Attributes in your .xib for any UIView subclass
 *
 *	e.g.
 *	KEY PATH				TYPE			VALUE
 *	configText				String			localized_key
 */

@implementation UIView (XibAttributes)

@dynamic configText, configTextColor, buttonTextColorHighlighted, buttonTextColorNormal, configTextFont;

- (void)setConfigText:(NSString *)configText
{
    if ( [self respondsToSelector:@selector(setText:)] )
    {
        [(id)self setText:[Localized string:configText]];
    }else if([self respondsToSelector:@selector(setTitle:forState:)]){
        [(id)self setTitle:[Localized string:configText] forState:UIControlStateNormal];
    }
}

- (void)setConfigTextColor:(NSString *)configTextColor
{
    if ( [self respondsToSelector:@selector(setTextColor:)] )
    {
        UIColor *color = [[UIConfiguration sharedInstance] getColor:configTextColor];
        [(id)self setTextColor:color];
    }
}

- (void)setConfigTextFont:(NSString *)configTextFont{
    if ([self respondsToSelector:@selector(setFont:)]) {
        UIFont *font = [[UIConfiguration sharedInstance] getFont:configTextFont];
        [(id)self setFont:font];
    }else if([((UIButton*)self).titleLabel respondsToSelector:@selector(setFont:)]){
        UIFont *font = [[UIConfiguration sharedInstance] getFont:configTextFont];
        [((UIButton*)self).titleLabel setFont:font];
    }
}

- (void)setButtonTextColorNormal:(NSString *)buttonTextColorNormal{
    if ( [self respondsToSelector:@selector(setTitleColor:forState:)] )
    {
        UIColor *color = [[UIConfiguration sharedInstance] getColor:buttonTextColorNormal];
        [(id)self setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)setButtonTextColorHighlighted:(NSString *)buttonTextColorHighlighted{
    if ( [self respondsToSelector:@selector(setTitleColor:forState:)] )
    {
        UIColor *color = [[UIConfiguration sharedInstance] getColor:buttonTextColorHighlighted];
        [(id)self setTitleColor:color forState:UIControlStateHighlighted];
    }
}


@end
