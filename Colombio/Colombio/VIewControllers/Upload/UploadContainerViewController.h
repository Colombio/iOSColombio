//
//  UploadContainerViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 19/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//
//  This class subclasses ContainerViewController and adds only methods for particular use. It also adds child view controllers which can be navigated with swipe.

#import "ContainerViewController.h"
#import "CreateNewsViewController.h"
#import "NewsMediaViewController.h"
#import "UserInfoUploadViewController.h"

@interface UploadContainerViewController : ContainerViewController<CreateAccViewControllerDelegate>
{
    CreateNewsViewController *contentVC;
    NewsMediaViewController *mediaVC;
    UserInfoUploadViewController *userInfoVC;
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isNewsDemand:(BOOL)isNewsDemand; //initialization method.
- (void)selectedImageAction:(NSMutableArray*)selectedImagesArray;
@end
