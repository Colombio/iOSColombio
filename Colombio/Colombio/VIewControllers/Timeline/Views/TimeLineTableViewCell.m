//
//  TimeLineTableViewCell.m
//  Colombio
//
//  Created by Vlatko Šprem on 10/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimeLineTableViewCell.h"

@implementation TimeLineTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TimeLineTableViewCell"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
        _profileImage.layer.cornerRadius=_profileImage.frame.size.width/2;
        _profileImage.layer.masksToBounds=YES;
        _txtDescription.contentInset = UIEdgeInsetsMake(-4, 0, -4, -4);
        _txtDescription.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
