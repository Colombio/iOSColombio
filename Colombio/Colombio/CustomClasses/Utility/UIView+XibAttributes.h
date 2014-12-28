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
 *  setText:
 */
@property (nonatomic, weak) NSString *configText;
@property (nonatomic, weak) NSString *configTextColor;
@property (nonatomic, weak) NSString *configTextFont;
@property (nonatomic, weak) NSString *buttonTextColorNormal;
@property (nonatomic, weak) NSString *buttonTextColorHighlighted;

@end
