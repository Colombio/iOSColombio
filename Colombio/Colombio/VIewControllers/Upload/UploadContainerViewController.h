//
//  UploadContainerViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 19/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "ContainerViewController.h"
#import "CreateNewsViewController.h"
#import "NewsMediaViewController.h"
#import "DummyViewController.h"

@interface UploadContainerViewController : ContainerViewController<CreateAccViewControllerDelegate>
{
    CreateNewsViewController *contentVC;
    NewsMediaViewController *mediaVC;
    DummyViewController *dummyVC;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isNewsDemand:(BOOL)isNewsDemand;
- (void)selectedImageAction:(NSMutableArray*)selectedImagesArray;
@end
