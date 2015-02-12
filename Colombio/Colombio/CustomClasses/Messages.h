/////////////////////////////////////////////////////////////
//
//  Messages.h
//  Armin Vrevic
//
//  Created by Colombio on 8/6/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that primarily serves for the message output functions
//  in the form of the alert views
//
///////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>


@interface  Messages : NSObject

+ (void)showErrorMsg:(NSString *)message;
+ (void)showNormalMsg:(NSString *)message;

@end
