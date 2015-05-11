//
//  UINavigationController+statusbar.m
//  Colombio
//
//  Created by Vlatko Šprem on 08/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UINavigationController+statusbar.h"

@implementation UINavigationController (statusbar)

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [[self topViewController] preferredStatusBarStyle];
}

@end
