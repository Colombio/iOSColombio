//
//  UploadNewsViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 02/02/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//
//  This class is used to upload collected data stored in NewsData object. 

#import <UIKit/UIKit.h>
#import "NewsData.h"

@interface UploadNewsViewController : UIViewController

- (instancetype)initWithNewsData:(NewsData*)data;
@end
