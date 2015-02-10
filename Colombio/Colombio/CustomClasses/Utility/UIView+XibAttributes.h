//
//  UIView+XibAttributes.h
//  Colombio
//
//  Created by Vlatko Šprem on 30/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XibAttributes)

/**
 *  Config User Defined Runtime Attributes in your .xib for any UIView subclass
 *
 *	e.g.
 *	KEY PATH				TYPE			VALUE
 *	configText				String			localized_key
 */

@property (nonatomic, weak) NSString *configText;
@property (nonatomic, weak) NSString *configTextColor;
@property (nonatomic, weak) NSString *configTextFont;
@property (nonatomic, weak) NSString *buttonTextColorNormal;
@property (nonatomic, weak) NSString *buttonTextColorHighlighted;

@end
