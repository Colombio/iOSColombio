/////////////////////////////////////////////////////////////
//
//  CustomField.h
//  Armin Vrevic
//
//  Created by Colombio on 16/08/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom text field that disables all user gestures
//
///////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

@interface CustomField : UITextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@end