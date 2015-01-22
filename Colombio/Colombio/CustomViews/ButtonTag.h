//
//  ButtonTag.h
//  Colombio
//
//  Created by Vlatko Šprem on 22/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonTag : UIButton

@property (nonatomic, strong) NSString *tag_id;
@property (nonatomic, strong) NSString *tag_name;
@property (nonatomic, strong) NSString *display_name;
@property (nonatomic, assign) CGSize stringsize;

@end
