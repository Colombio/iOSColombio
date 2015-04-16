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
#import "SelectMediaViewController.h"
#import "UserInfoUploadViewController.h"
#import "NewsDemandObject.h"

@interface UploadContainerViewController : ContainerViewController<CreateNewsViewControllerDelegate, UIAlertViewDelegate>
{
    CreateNewsViewController *contentVC;
    SelectMediaViewController *mediaVC;
    UserInfoUploadViewController *userInfoVC;
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forNewsDemandData:(NewsDemandObject*)newsDemandData isNewsDemand:(BOOL)isNewsDemand;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isNewsDemand:(BOOL)isNewsDemand; //initialization method.
- (void)selectedImageAction:(NSMutableArray*)selectedImagesArray;
@end
