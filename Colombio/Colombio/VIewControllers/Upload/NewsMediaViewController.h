//
//  NewsMediaViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 25/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//
// Select Media from media list.

#import "MediaListViewController.h"

@interface NewsMediaViewController : MediaListViewController

@property (strong, nonatomic) NSMutableArray *selectedMedia;

- (BOOL)validateMedia;
@end
