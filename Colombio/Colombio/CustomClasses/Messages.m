/////////////////////////////////////////////////////////////
//
//  Messages.m
//  Armin Vrevic
//
//  Created by Colombio on 8/6/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that primarily serves for the message output functions
//  in the form of the alert views
//
///////////////////////////////////////////////////////////////

#import "Messages.h"

@implementation Messages

/**
 *  shows error message
 *
 *  @param message "Message that user wants to display"
 *
 */
+ (void)showErrorMsg:(NSString *)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[Localized string:message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

/**
 *  shows normal message
 *
 *  @param message "Message that user wants to display"
 *
 */
+ (void)showNormalMsg:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[Localized string:message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
