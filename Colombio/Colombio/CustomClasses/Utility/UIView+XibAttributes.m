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

@dynamic configText;

- (void)setConfigText:(NSString *)configText
{
    if ( [self respondsToSelector:@selector(setText:)] )
    {
        [(id)self setText:[Localized string:configText]];
    }
}

@end
