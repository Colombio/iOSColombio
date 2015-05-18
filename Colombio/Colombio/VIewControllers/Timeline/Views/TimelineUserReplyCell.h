//
//  TimelineUserReplyCell.h
//  Colombio
//
//  Created by Vlatko Šprem on 15/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineUserReplyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *lblViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblMessageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblViewContainerHeight;

@end
