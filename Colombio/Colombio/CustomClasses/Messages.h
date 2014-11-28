//
//  Messages.h
//  colombio
//
//  Created by Vlatko Šprem on 27/09/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface  Messages : NSObject

+ (void)showErrorMsg:(NSString *)message;
+ (void)showNormalMsg:(NSString *)message;

@end
