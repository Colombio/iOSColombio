//
//  UITextField+XibAttributes.h
//  Colombio
//
//  Created by Vlatko Šprem on 30/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (XibAttributes)

@property (nonatomic, weak) NSString *configPlaceholder;
@property (nonatomic, weak) NSString *placeholderColor;

@end
