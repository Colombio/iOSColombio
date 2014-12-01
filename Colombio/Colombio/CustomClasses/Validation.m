//
//  Validation.m
//  colombio
//
//  Created by Vlatko Šprem on 27/09/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "Validation.h"

@implementation Validation

+ (BOOL)validateEmail:(NSString *)emailStr{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

+ (BOOL)isNumber:(NSString *)Str{
    NSString *numRegex = @"^0{2}[1-9][0-9]*$|^\\+[1-9][0-9]*$|^$";
    NSPredicate *numTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numRegex];
    return [numTest evaluateWithObject:Str];
}
@end
