//
//  LibraryCell.m
//  colombio
//
//  Created by Colombio on 7/29/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom celija za collection view koji prikazuje
//  slike iz librarya

#import "LibraryCell.h"

@implementation LibraryCell

@synthesize img = img;
@synthesize notSelected =notSelected;
@synthesize select;
@synthesize red2;
@synthesize watermark;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,99,99)];
        watermark = [[UIImageView alloc] initWithFrame:CGRectMake(28,28,44,44)];
        notSelected = [[UIImageView alloc] initWithFrame:CGRectMake(76, 5, 20, 20)];
        select = [[UIImageView alloc] initWithFrame:CGRectMake(76, 5, 20, 20)];
        notSelected.image=[UIImage imageNamed:@"unselected.png"];
        select.image=[UIImage imageNamed:@"selected.png"];
        watermark.image=[UIImage imageNamed:@"watermark.png"];
        
        red2 = [[UILabel alloc] initWithFrame:CGRectMake(18,60,70,20)];
        red2.text= @"Camera";
        red2.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:19.0f];
        [red2 setHidden:YES];
        
        [self addSubview:img];
        [self addSubview:notSelected];
        [self addSubview:select];
        [self addSubview:red2];
        [self addSubview:watermark];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)hideWaterMark{
    watermark.hidden=YES;
}

@end
