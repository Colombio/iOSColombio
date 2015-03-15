//
//  SelectMediaCell.m
//  Colombio
//
//  Created by Vlatko Šprem on 07/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SelectMediaCell.h"

@implementation SelectMediaCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"SelectMediaCell"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
        

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

/*- (void)setLblMediaDescription:(UILabel *)lblMediaDescription{
    CGSize size = [_lblMediaDescription.text sizeWithFont:_lblMediaDescription.font
                            constrainedToSize:CGSizeMake(_lblMediaDescription.frame.size.width, MAXFLOAT)
                                lineBreakMode:NSLineBreakByWordWrapping];
    CS_DescriptionHeight.constant = size.height;
}*/


@end
