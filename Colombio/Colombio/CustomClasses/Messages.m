//
//  Messages.m
//  colombio
//
//  Created by Vlatko Šprem on 27/09/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "Messages.h"

@implementation Messages

+ (void)showErrorMsg:(NSString *)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (void)showNormalMsg:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
