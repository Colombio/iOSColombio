//
//  TimelineSentNewsCell.h
//  Colombio
//
//  Created by Vlatko Šprem on 20/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineSentNewsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgMediaLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgSample;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblDescriptionHeight;

@end
