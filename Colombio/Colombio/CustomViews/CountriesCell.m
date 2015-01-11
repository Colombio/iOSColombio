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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 20, 20)];
        imgSelected.image=[UIImage imageNamed:@"selected.png"];
        lblCountryName = [[UILabel alloc] initWithFrame:CGRectMake(45,13,230,20)];
        lblCountryName.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:19.0f];
        
        [self addSubview:lblCountryName];
        [self addSubview:imgSelected];
    }
    return self;
}

@end
