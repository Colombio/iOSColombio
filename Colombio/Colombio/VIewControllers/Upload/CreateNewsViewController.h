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
#import "CLTextView.h"

@protocol CreateAccViewControllerDelegate

- (void)navigateToVC:(PhotoLibraryViewController*)viewController;

@end

@interface CreateNewsViewController : UIViewController<UITextViewDelegate, ColombioServiceCommunicatorDelegate>

@property (nonatomic, strong) id<CreateAccViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *selectedImagesArray;
@property (strong, nonatomic) NSMutableArray *selectedTags;
@property (weak,nonatomic) IBOutlet CLTextView *txtTitle;
@property (weak,nonatomic) IBOutlet CLTextView *txtDescription;

- (void)loadImages;
- (BOOL)validateFields;
- (BOOL)validateImages;
- (BOOL)validateTags;

@end
