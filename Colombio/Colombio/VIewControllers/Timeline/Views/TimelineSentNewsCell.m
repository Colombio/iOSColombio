//
//  TimelineSentNewsCell.m
//  Colombio
//
//  Created by Vlatko Šprem on 20/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimelineSentNewsCell.h"

@implementation TimelineSentNewsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TimelineSentNewsCell"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
        _imgMediaLogo.layer.cornerRadius=_imgMediaLogo.frame.size.width/2;
        _imgMediaLogo.layer.masksToBounds=YES;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
