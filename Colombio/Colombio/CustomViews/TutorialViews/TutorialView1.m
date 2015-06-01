//
//  TutorialView1.m
//  Colombio
//
//  Created by Vlatko Šprem on 26/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TutorialView1.h"

@implementation TutorialView1

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TutorialView1"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
        
        
        
        
    }
    return self;
}

@end
