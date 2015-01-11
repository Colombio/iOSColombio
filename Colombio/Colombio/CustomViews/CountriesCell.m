//
//  CountriesCell.m
//  colombio
//
//  Created by Vlatko Šprem on 28/09/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "CountriesCell.h"

@implementation CountriesCell

@synthesize lblCountryName;
@synthesize imgCountryFlag;
@synthesize imgSelected;
@synthesize bottomBorder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(265, 0, 44, 44)];
        imgSelected.image=COLLECTION_SELECTED;
        lblCountryName = [[UILabel alloc] initWithFrame:CGRectMake(50,8,230,25)];
        lblCountryName.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:19.0f];
        bottomBorder = [[UIView alloc]initWithFrame:CGRectMake(10, 42, 280, 1)];
        bottomBorder.backgroundColor = [UIColor grayColor];
        bottomBorder.alpha=0.3;
        imgCountryFlag = [[UIImageView alloc]initWithFrame:CGRectMake(12, 11, 30, 20)];
        
        [self addSubview:lblCountryName];
        [self addSubview:imgSelected];
        [self addSubview:bottomBorder];
        [self addSubview:imgCountryFlag];
    }
    return self;
}

@end
