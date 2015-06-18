//
//  SimpleMediaSelectViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 24/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

//Select media for user settings or call media

#import "BackgroundViewController.h"
#import "ColombioServiceCommunicator.h"

@interface SimpleMediaSelectViewController : BackgroundViewController<ColombioServiceCommunicatorDelegate, UIAlertViewDelegate>

- (instancetype)init __attribute__((unavailable("use initForCallMedia:")));
- (instancetype)initForCallMedia:(BOOL)callMedia;
@end
