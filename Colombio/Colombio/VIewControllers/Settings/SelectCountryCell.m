//
//  SelectCountryCell.m
//  Colombio
//
//  Created by Vlatko Šprem on 08/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SelectCountryCell.h"

@implementation SelectCountryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"SelectCountryCell"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
    }
    _imgFlag.layer.cornerRadius=_imgFlag.frame.size.width/2;
    _imgFlag.layer.masksToBounds=YES;
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
