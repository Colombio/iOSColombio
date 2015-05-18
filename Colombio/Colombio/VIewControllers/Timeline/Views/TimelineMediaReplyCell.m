//
//  TimelineMediaReplyCell.m
//  Colombio
//
//  Created by Vlatko Šprem on 15/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimelineMediaReplyCell.h"

@implementation TimelineMediaReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TimelineMediaReplyCell"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
        
        _imgLogo.layer.cornerRadius = _imgLogo.frame.size.width/2;
        _imgLogo.clipsToBounds=YES;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
