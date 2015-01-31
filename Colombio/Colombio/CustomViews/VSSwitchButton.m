//
//  VSSwitchButton.m
//  CustomStuffFactory
//
//  Created by Vlatko Šprem on 14/12/14.
//  Copyright (c) 2014 vlatko. All rights reserved.
//

#import "VSSwitchButton.h"

@implementation VSSwitchButton

- (id)initWithValue:(BOOL)value andFrame:(CGRect)frame{
    self = [self initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [self initWithValue:NO andFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isON=NO; //default value
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (void)buttonPressed{
    _isON=!_isON;
    [self setState];
}

/*- (void)awakeFromNib{
    self.isON=NO; //default value
    [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
}*/

- (void)setIsON:(BOOL)isON{
    _isON = isON;
    [self setState];
}

- (void)setState{
    if (self.isON==YES) {
        [self setTitle:@"ON" forState:UIControlStateNormal];
    }else{
        [self setTitle:@"OFF" forState:UIControlStateNormal];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
}*/


@end
