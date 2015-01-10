//
//  ScrollableHeaderContentView.m
//  Colombio
//
//  Created by Vlatko Šprem on 10/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "ScrollableHeaderContentView.h"

@implementation ScrollableHeaderContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"ScrollableHeaderContentView"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
