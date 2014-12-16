//
//  VSSwitchButton.h
//  CustomStuffFactory
//
//  Created by Vlatko Šprem on 14/12/14.
//  Copyright (c) 2014 vlatko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSSwitchButton : UIButton


//switch-like property
@property (assign, nonatomic) BOOL isON;//default isON=NO;

//initialization
- (id)initWithFrame:(CGRect)frame;
- (id)initWithValue:(BOOL)value andFrame:(CGRect)frame;
@end
