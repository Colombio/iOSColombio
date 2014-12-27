//
//  HeaderView.m
//  colombio
//
//  Created by Vlatko Šprem on 13/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView
@synthesize delegate, lblTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            NSArray *nib = [[NSBundle mainBundle]
                            loadNibNamed:@"HeaderView"
                            owner:self
                            options:nil];
        self = [nib objectAtIndex:0];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    lblTitle.text = title;
    [lblTitle setFont:[UIFont  fontWithName:@"HelveticaNeue-Bold" size:19.0f]];
    
    CGFloat width =  ([self.lblTitle.text sizeWithFont:[UIFont  fontWithName:@"HelveticaNeue-Bold" size:19.0f]].width<200.0?[self.lblTitle.text sizeWithFont:[UIFont systemFontOfSize:17.0 ]].width:200.0);
    self.CS_TitleWidth.constant = width+20;

}

- (void)setTitleImage:(UIImage *)titleImage{
    self.imgTitle.image=titleImage;
}

#pragma mark ButtonAction

- (void)btnBackClicked:(id)sender{
    [delegate backButtonTapped];
}

- (void)btnNextClicked:(id)sender{
    [delegate nextButtonTapped];
}



@end