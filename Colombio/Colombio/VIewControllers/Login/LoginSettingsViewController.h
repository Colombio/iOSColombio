//
//  LoginSettingsViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 06/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "ContainerViewController.h"
#import "SelectCountriesViewController.h"
#import "SelectMediaViewController.h"
#import "UserInfoViewController.h"

@interface LoginSettingsViewController : ContainerViewController{
    SelectCountriesViewController *countriesVC;
    SelectMediaViewController *mediaVC;
    UserInfoViewController *userInfoVC;
}

@end
