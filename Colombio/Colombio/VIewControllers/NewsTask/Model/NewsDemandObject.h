//
//  NewsDemandObject.h
//  Colombio
//
//  Created by Vlatko Šprem on 27/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsDemandObject : NSObject

@property(nonatomic, strong) NSString *cost;
@property(nonatomic, strong) NSString *desc;
@property(nonatomic, strong) NSString *end_timestamp;
@property(nonatomic, strong) NSString *start_timestamp;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) CGFloat latitude;
@property(nonatomic, assign) CGFloat longitude;
@property(nonatomic, assign) int media_id;
@property(nonatomic, assign) NSInteger radius;
@property(nonatomic, assign) int req_id;
@property(nonatomic, strong) NSDate *start_timestamp_date;
@property(nonatomic, assign) CGFloat distance;
@property(nonatomic, assign) int location_type;
@property(nonatomic, strong) NSString *media_icon;
@property(nonatomic, strong) NSString *mediaName;


@end
