//
//  TimelineUserReplyCell.m
//  Colombio
//
//  Created by Vlatko Šprem on 15/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimelineUserReplyCell.h"

@implementation TimelineUserReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TimelineUserReplyCell"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
