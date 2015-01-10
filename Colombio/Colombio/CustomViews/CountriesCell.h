//
//  CountriesCell.h
//  colombio
//
//  Created by Vlatko Šprem on 28/09/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountriesCell : UICollectionViewCell{
    IBOutlet UIImageView *imgCountryFlag;
    IBOutlet UIImageView *imgSelected;
    IBOutlet UILabel *lblCountryName;
}

@property (nonatomic, strong) IBOutlet UIImageView *imgCountryFlag;
@property (nonatomic, strong) IBOutlet UIImageView *imgSelected;
@property (nonatomic, strong) IBOutlet UILabel *lblCountryName;

@end
