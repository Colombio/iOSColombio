//
//  SelectMediaViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 06/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColombioServiceCommunicator.h"

@interface SelectMediaViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *selectedMedia;

- (instancetype)initForNewsUpload:(BOOL)newsUpload;
- (BOOL)validateMedia;
@end
