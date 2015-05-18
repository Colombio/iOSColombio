//
//  TimelineOfferCell.m
//  Colombio
//
//  Created by Vlatko Šprem on 15/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimelineOfferCell.h"

@implementation TimelineOfferCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TimelineOfferCell"
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

    // Configure the view for the selected state
}

- (IBAction)btnAcceptSelected:(id)sender{
    [self.delegate didAcceptOffer:_offerID];
}

- (IBAction)btnRejectSelected:(id)sender{
    [self.delegate didRejectOffer:_offerID];
}

@end
