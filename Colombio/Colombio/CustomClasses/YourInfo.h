//
//  YourInfo.h
//  colombio
//
//  Created by Vlatko Šprem on 28/09/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YourInfo : NSObject

@property (strong,nonatomic) NSString *strName;
@property (strong,nonatomic) NSString *strSurname;
@property (strong,nonatomic) NSString *strPhone;
@property (strong,nonatomic) NSString *strPayPalEmail;
@property (nonatomic,assign) BOOL *anonymous;
@property (nonatomic,assign) BOOL *paypal;

@end
