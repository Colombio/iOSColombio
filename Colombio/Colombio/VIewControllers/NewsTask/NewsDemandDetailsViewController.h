//
//  NewsDemandDetailsViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 28/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsDemandObject.h"
#import <MapKit/MapKit.h>

@protocol NewsDemandDetailsDelegate

- (void)newsDemandIsSelected:(NewsDemandObject*)newsDemandData;

@end

@interface NewsDemandDetailsViewController : UIViewController <MKMapViewDelegate, MKAnnotation>

@property (strong, nonatomic) id<NewsDemandDetailsDelegate> delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withNewsDemand:(NewsDemandObject*)newsDemandObject;
@end
