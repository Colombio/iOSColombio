//
//  CreateNewsViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 09/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoLibraryViewController.h"
#import "ColombioServiceCommunicator.h"

@protocol CreateAccViewControllerDelegate

- (void)navigateToVC:(PhotoLibraryViewController*)viewController;

@end

@interface CreateNewsViewController : UIViewController<UITextViewDelegate, ColombioServiceCommunicatorDelegate>

@property (nonatomic, strong) id<CreateAccViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *selectedImagesArray;

- (void)loadImages;

@end
