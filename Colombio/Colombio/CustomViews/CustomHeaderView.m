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
    
    }
    return self;
}

- (void)btnAction:(UIButton *)sender{
    if (sender==_btnBack) {
        [self.customHeaderDelegate btnBackClicked];
    }else{
        [self.customHeaderDelegate btnNextClicked];
    }
}

#pragma mark SetupLabel
- (void)setHeaderTitle:(NSString *)headerTitle{
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
        _lblTitle.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _lblTitle.textAlignment = NSTextAlignmentCenter;
        _lblTitle.adjustsFontSizeToFitWidth = YES;
        _lblTitle.minimumScaleFactor=0.5;
        _lblTitle.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_TITLE];
        _lblTitle.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
        _bottomBorder = [[UIView alloc]initWithFrame:CGRectMake(0, 42, 320, 2)];
        _bottomBorder.backgroundColor = [UIColor lightGrayColor];
        _bottomBorder.alpha=0.3;
        [self addSubview:_lblTitle];
        [self addSubview:_bottomBorder];
    }
    _lblTitle.text = [Localized string:headerTitle];
    
}

- (void)setBackButtonText:(NSString *)backButtonText{
    if(!_btnBack) {
        _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        if (backButtonText!=nil && backButtonText.length>0) {
            [_btnBack addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [_btnBack setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON] forState:UIControlStateNormal];
            [_btnBack setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON_HIGHLIGHT] forState:UIControlStateHighlighted];
            
            [_btnBack setTitle:[Localized string:backButtonText]  forState:UIControlStateNormal];
            _btnBack.titleLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
            CGSize stringsize = [[Localized string:backButtonText] sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT]];
            _btnBack.frame = CGRectMake(10, 12, stringsize.width, 20);
            //_btnBack.center = CGPointMake(0, self.bounds.size.height/2);
        }else{
            [_btnBack addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [_btnBack setBackgroundImage:[UIImage imageNamed:@"backgrey_normal"] forState:UIControlStateNormal];
            [_btnBack setBackgroundImage:[UIImage imageNamed:@"backgrey_pressed"] forState:UIControlStateHighlighted];
            _btnBack.frame = CGRectMake(10, 0, 44, 44);
        }
        [self addSubview:_btnBack];
    }else{
        if (backButtonText!=nil && backButtonText.length>0) {
            [_btnBack setTitle:[Localized string:backButtonText]  forState:UIControlStateNormal];
        }
    }
    
}

- (void)setNextButtonText:(NSString *)nextButtonText{
    if (nextButtonText.length>0) {
        if (!_btnNext) {
            _btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
            [_btnNext addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [_btnNext setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_NEXT_BUTTON] forState:UIControlStateNormal];
            [_btnNext setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_NEXT_BUTTON_SELECTED] forState:UIControlStateHighlighted];
            
            
            _btnNext.titleLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_NEXT];
            _btnNext.frame = CGRectMake(self.bounds.size.width-80, 11, 80, 20);
            _btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
            _btnNext.titleLabel.adjustsFontSizeToFitWidth = YES;
            _btnNext.titleLabel.minimumScaleFactor=0.5;
            [self addSubview:_btnNext];
        }
       [_btnNext setTitle:[Localized string:nextButtonText] forState:UIControlStateNormal];
    }
   
}




@end
