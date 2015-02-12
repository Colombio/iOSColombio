/////////////////////////////////////////////////////////////
//
//  CustomField.m
//  Armin Vrevic
//
//  Created by Colombio on 16/08/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom text field that disables all user gestures
//
///////////////////////////////////////////////////////////////

#import "CustomField.h"

@implementation CustomField

/**
 * Cant perform action on a cell
 *
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

/**
 * Disable long press on a cell
 *
 */
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    
    if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        gestureRecognizer.enabled=NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}

@end
