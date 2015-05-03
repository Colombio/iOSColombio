/////////////////////////////////////////////////////////////
//
//  LibraryCell.m
//  Armin Vrevic
//
//  Created by Colombio on 7/29/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom collection view cell for phone library item selecting
//  (video, pictures)
//
///////////////////////////////////////////////////////////////

#import "LibraryCell.h"

@implementation LibraryCell

@synthesize img = img;
@synthesize imgNotSelected =imgNotSelected;
@synthesize imgSelected;
@synthesize lblCellText;
@synthesize imgWatermark;

/**
 *  Method that inits cell and its elements
 *
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,99,99)];
        imgWatermark = [[UIImageView alloc] initWithFrame:CGRectMake(28,28,44,44)];
        imgNotSelected = [[UIImageView alloc] initWithFrame:CGRectMake(76, 5, 20, 20)];
        imgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 99, 99)];
        imgSelected.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        imgNotSelected.image=[UIImage imageNamed:@"unselected.png"];
        imgSelected.image=[UIImage imageNamed:@"selectedcontent"];
        imgWatermark.image=[UIImage imageNamed:@"watermark.png"];
        lblCellText = [[UILabel alloc] initWithFrame:CGRectMake(18,60,70,20)];
        lblCellText.text= @"Camera";
        lblCellText.font = [UIFont  fontWithName:@"HelveticaNeue-Light" size:19.0f];
        [lblCellText setHidden:YES];
        imgNotSelected.hidden=YES;//ne treba
        
        [self addSubview:img];
        [self addSubview:imgNotSelected];
        [self addSubview:imgSelected];
        [self addSubview:lblCellText];
        [self addSubview:imgWatermark];
    }
    return self;
}

/**
 *  Custom method that hides the watermark
 *
 **/
- (void)hideWaterMark{
    imgWatermark.hidden=YES;
}

@end
