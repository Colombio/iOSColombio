//
//  SelectCountriesViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 08/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

//For 1st login only

#import <UIKit/UIKit.h>

@interface SelectCountriesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *selectedCountries;

- (BOOL)validateCountries;
@end
