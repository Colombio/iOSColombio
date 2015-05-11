//
//  NewsDemandCell.m
//  colombio
//
//  Created by Vlatko Šprem on 15/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "NewsDemandCell.h"

@implementation NewsDemandCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"NewsDemandCell"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
        _imgMediaLogo.layer.cornerRadius=_imgMediaLogo.frame.size.width/2;
        _imgMediaLogo.layer.masksToBounds=YES;
        _lblDescription.contentInset = UIEdgeInsetsMake(-4, -4, 0, -4);
        _lblDescription.userInteractionEnabled = NO;
        //[_lblDescription setContentOffset:CGPointZero animated:YES];
        _lblDescription.scrollEnabled = NO;
        _lblDescription.textContainer.maximumNumberOfLines = 0;
        _lblDescription.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
