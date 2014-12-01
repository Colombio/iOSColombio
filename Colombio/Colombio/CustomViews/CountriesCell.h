//
//  CountriesCell.h
//  colombio
//
//  Created by Vlatko Šprem on 28/09/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountriesCell : UICollectionViewCell{
    IBOutlet UIImageView *notSelected;
    IBOutlet UIImageView *select;
    IBOutlet UILabel *countryName;
}

@property (nonatomic, strong) IBOutlet UILabel *countryName;
@property (nonatomic, strong) IBOutlet UIImageView *select;
@property (nonatomic, strong) IBOutlet UIImageView *notSelected;

@end
