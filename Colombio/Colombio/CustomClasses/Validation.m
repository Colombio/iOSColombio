/////////////////////////////////////////////////////////////
//
//  Validation.m
//  Armin Vrevic
//
//  Created by Colombio on 8/6/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that provides methods for regex or other types of
//  string validation
//
///////////////////////////////////////////////////////////////

#import "Validation.h"

@implementation Validation

/**
 *  Method that validates provided email with regex
 *
 *  @param emailStr "email string needed to validate"
 *
 *  @return true if correct, false if not correct
 *
 */
+ (BOOL)validateEmail:(NSString *)emailStr{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

/**
 *  Method that validates provided number with regex
 *
 *  @param emailStr "number string needed to validate"
 *
 *  @return true if correct, false if not correct
 *
 */
+ (BOOL)isNumber:(NSString *)Str{
    NSString *numRegex = @"^0{2}[1-9][0-9]*$|^\\+[1-9][0-9]*$|^$";
    NSPredicate *numTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numRegex];
    return [numTest evaluateWithObject:Str];
}
@end
