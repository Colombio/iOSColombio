//
//  SelectMediaViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 06/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

//Select media for 1st login and upload news. 

#import <UIKit/UIKit.h>
#import "ColombioServiceCommunicator.h"

@interface SelectMediaViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *selectedMedia;

- (instancetype)initForNewsUpload:(BOOL)newsUpload;
- (BOOL)validateMedia;
@end
