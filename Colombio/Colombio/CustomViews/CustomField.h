//
//  CustomField.h
//  colombio
//
//  Created by Vlatko Šprem on 16/08/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomField : UITextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@end