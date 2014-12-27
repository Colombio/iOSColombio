//
//  HeaderView.h
//  colombio
//
//  Created by Vlatko Šprem on 13/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderViewDelegate <NSObject>
@optional
- (void)backButtonTapped;
- (void)nextButtonTapped;

@end

@interface HeaderView : UIView

@property (strong, nonatomic) IBOutlet id<HeaderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIImageView *imgTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *titleImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_ImagePosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_TitleWidth;

- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnBackClicked:(id)sender;

@end
