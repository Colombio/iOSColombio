//
//  TImelineWriteReplyCell.m
//  Colombio
//
//  Created by Vlatko Šprem on 15/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TImelineWriteReplyCell.h"

@implementation TImelineWriteReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TImelineWriteReplyCell"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];

        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

- (IBAction)btnReplySelected:(id)sender{
    if (_txtView.text.length>0) {
        [self.delegate didSelectSendReply:_txtView.text forNewsId:_nid andMediaId:_mid];
    }
}

@end
