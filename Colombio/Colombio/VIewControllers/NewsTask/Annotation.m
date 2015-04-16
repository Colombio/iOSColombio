//
//  Annotation.m
//  Colombio
//
//  Created by Vlatko Šprem on 30/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
    if ((self = [super init])) {
        self.coordinate =coordinate;
        self.title = title;
    }
    return self;
}

@end
