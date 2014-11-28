//
//  CountriesCell.m
//  colombio
//
//  Created by Vlatko Šprem on 28/09/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "CountriesCell.h"

@implementation CountriesCell

@synthesize notSelected;
@synthesize select;
@synthesize countryName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        notSelected = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 20, 20)];
        select = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 20, 20)];
        notSelected.image=[UIImage imageNamed:@"unselected.png"];
        select.image=[UIImage imageNamed:@"selected.png"];
        countryName = [[UILabel alloc] initWithFrame:CGRectMake(45,13,230,20)];
        countryName.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:19.0f];
        
        [self addSubview:countryName];
        [self addSubview:notSelected];
        [self addSubview:select];
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


@end
