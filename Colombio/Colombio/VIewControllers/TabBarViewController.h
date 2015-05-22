//
//  TabBarViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 08/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarViewController : UITabBarController<UITabBarControllerDelegate>

- (instancetype)initWithUserInfo:(NSDictionary*)userInfo;
@end
