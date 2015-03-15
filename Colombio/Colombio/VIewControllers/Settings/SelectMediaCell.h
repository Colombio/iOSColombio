//
//  SelectMediaCell.h
//  Colombio
//
//  Created by Vlatko Šprem on 07/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectMediaCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgMedia;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelected;
@property (weak, nonatomic) IBOutlet UILabel *lblMediaName;
@property (weak, nonatomic) IBOutlet UILabel *lblMediaType;
@property (weak, nonatomic) IBOutlet UILabel *lblMediaDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_DescriptionHeight;

@end
