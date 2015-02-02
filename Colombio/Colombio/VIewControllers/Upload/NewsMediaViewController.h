//
//  NewsMediaViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 25/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "MediaListViewController.h"

@interface NewsMediaViewController : MediaListViewController

@property (strong, nonatomic) NSMutableArray *selectedMedia;

- (BOOL)validateMedia;
@end
