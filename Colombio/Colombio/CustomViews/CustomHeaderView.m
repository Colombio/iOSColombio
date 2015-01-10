//
//  CustomHeaderView.m
//  Colombio
//
//  Created by Vlatko Šprem on 10/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "CustomHeaderView.h"

@implementation CustomHeaderView

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setTitle];
    
    }
    return self;
}

- (void)btnAction:(UIButton *)sender{

}

#pragma mark SetupLabel
- (void)setTitle{
    _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    _lblTitle.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    _lblTitle.text = @"SELECT CONTENT";
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    _lblTitle.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_TITLE];
    _lblTitle.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
    [self addSubview:_lblTitle];
}

- (void)setBackButtonText:(NSString *)backButtonText{
     _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    if (backButtonText!=nil && backButtonText.length>0) {
        [_btnBack addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_btnBack setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON] forState:UIControlStateNormal];
        [_btnBack setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON_HIGHLIGHT] forState:UIControlStateHighlighted];
        
        [_btnBack setTitle:backButtonText forState:UIControlStateNormal];
        _btnBack.titleLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
        CGSize stringsize = [backButtonText sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT]];
        _btnBack.frame = CGRectMake(0, 0, stringsize.width, 20);
        _btnBack.center = CGPointMake(0, self.bounds.size.height/2);
    }else{
        [_btnBack addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_btnBack setBackgroundImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
        [_btnBack setBackgroundImage:[UIImage imageNamed:@"back_pressed"] forState:UIControlStateHighlighted];
        _btnBack.frame = CGRectMake(10, 0, 44, 44);
    }
    [self addSubview:_btnBack];
}

- (void)setNextButtonText:(NSString *)nextButtonText{
    if (nextButtonText.length>0) {
        _btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnNext addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_btnNext setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON] forState:UIControlStateNormal];
        [_btnNext setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON_HIGHLIGHT] forState:UIControlStateHighlighted];
        
        [_btnNext setTitle:nextButtonText forState:UIControlStateNormal];
        _btnNext.titleLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
        CGSize stringsize = [nextButtonText sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT]];
        _btnNext.frame = CGRectMake(0, 0, stringsize.width, 20);
        _btnNext.center = CGPointMake(self.bounds.size.width, self.bounds.size.height/2);
        [self addSubview:_btnNext];
    }
   
}




@end
