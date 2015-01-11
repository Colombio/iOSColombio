//
//  NewsData.h
//  Colombio
//
//  Created by Vlatko Šprem on 11/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsData : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, assign) BOOL prot;
@property (assign, nonatomic) float price;
@property (nonatomic, assign) BOOL be_credited;
@property (nonatomic, assign) BOOL be_contacted;
@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) NSMutableArray *media;
@property (assign, nonatomic) NSInteger did;
@property (assign, nonatomic) NSInteger type_id;

@property (strong, nonatomic) NSMutableArray *images;

@end
