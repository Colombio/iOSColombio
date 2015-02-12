/////////////////////////////////////////////////////////////
//
//  CountriesCell.h
//  Armin Vrevic
//
//  Created by Colombio on 8/6/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom Collection View cell class for countries
//
///////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

@interface CountriesCell : UICollectionViewCell{
    IBOutlet UIImageView *imgCountryFlag;
    IBOutlet UIImageView *imgSelected;
    IBOutlet UILabel *lblCountryName;
    //Gray bottom border
    IBOutlet UIView *bottomBorder;
}

@property (nonatomic, strong) IBOutlet UIImageView *imgCountryFlag;
@property (nonatomic, strong) IBOutlet UIImageView *imgSelected;
@property (nonatomic, strong) IBOutlet UILabel *lblCountryName;
@property (nonatomic, strong) IBOutlet UIView *bottomBorder;

@end
