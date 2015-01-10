//
//  CustomHeaderView.h
//  Colombio
//
//  Created by Vlatko Šprem on 10/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomHeaderViewDelegate
@optional

- (void)btnNextClicked;
- (void)btnBackClicked;

@end


@interface CustomHeaderView : UIView

@property (weak, nonatomic) IBOutlet id<CustomHeaderViewDelegate>customHeaderDelegate;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UIButton *btnBack;
@property (strong, nonatomic) UIButton *btnNext;
@property (assign, nonatomic) BOOL isBackButtonText;
@property (strong, nonatomic) NSString *backButtonText;
@property (strong, nonatomic) NSString *nextButtonText;

- (void)btnAction:(UIButton*)sender;
@end
