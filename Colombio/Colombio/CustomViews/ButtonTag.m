//
//  ButtonTag.m
//  Colombio
//
//  Created by Vlatko Šprem on 22/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "ButtonTag.h"

@implementation ButtonTag

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    ButtonTag *btn = [super buttonWithType:buttonType];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    return btn;
}

/// Because we can't override init on a uibutton, do init steps here.

- (void)setSelected:(BOOL)selected{
    if (selected) {
        [self setBackgroundColor:[[UIConfiguration sharedInstance] getColor:COLOR_TAGS_BACKGROUND_SELECTED]];
        [self setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TAGS_TEXT_SELECTED] forState:UIControlStateNormal];
    }else{
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TAGS_TEXT_NORMAL] forState:UIControlStateNormal];
    }
}

    

@end
