//
//  Tools.h
//  colombio
//
//  Created by Vlatko Šprem on 19/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+ (NSInteger)getNumberOfNewDemands;
+ (UILabel*)getBadgeObject:(long )count frame:(CGRect)frame;

@end
