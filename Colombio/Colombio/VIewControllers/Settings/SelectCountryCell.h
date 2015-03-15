//
//  SelectCountryCell.h
//  Colombio
//
//  Created by Vlatko Šprem on 08/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCountryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgFlag;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelected;
@property (weak, nonatomic) IBOutlet UILabel *lblCountry;

@end
