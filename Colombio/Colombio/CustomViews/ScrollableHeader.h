//
//  ScrollableHeader.h
//  Colombio
//
//  Created by Colombio on 30/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScrollableHeader : NSObject<UIScrollViewDelegate>{
    //Lokalno se sprema aktivni viewController kako bi mogao handlati navigaciju
    UIViewController *activeVC;
    //Lokalno se sprema proslijedeni view kako bi se mogli dodavati elementi na view
    UIView *activeView;
}

- (void)addHeader:(UIView *)view self:(UIViewController *)vc activeView:(int)activeView;

@end
