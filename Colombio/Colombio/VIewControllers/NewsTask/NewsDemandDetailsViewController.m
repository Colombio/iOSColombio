//
//  NewsDemandDetailsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 28/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "NewsDemandDetailsViewController.h"
#import "AppDelegate.h"
#import "Annotation.h"
#import "Tools.h"

@interface NewsDemandDetailsViewController ()
{
    AppDelegate *appdelegate;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgMediaLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblReward;
@property (weak, nonatomic) IBOutlet UILabel *lblNewsTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtNewsDescription;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;

@property (strong, nonatomic) NewsDemandObject *data;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblDescriptionHeight;

- (IBAction)btnSelectTapped:(id)sender;

@end

@implementation NewsDemandDetailsViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withNewsDemand:(NewsDemandObject*)newsDemandObject{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _data = newsDemandObject;
        self.title = _data.mediaName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appdelegate = [[UIApplication sharedApplication] delegate];
    _imgMediaLogo.layer.cornerRadius=_imgMediaLogo.frame.size.width/2;
    _imgMediaLogo.layer.masksToBounds=YES;
    
    _txtNewsDescription.userInteractionEnabled = NO;
    
    [self setFields];
    [self setLabelHeights];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    _txtNewsDescription.contentInset = UIEdgeInsetsMake(0, -4, 0, -4);
    [self saveToDB];
}

- (void)saveToDB{
    NSDictionary *tDict = @{@"isread":@TRUE};
    [appdelegate.db updateDictionary:tDict forTable:@"NEWSDEMANDLIST" where:[NSString stringWithFormat:@" req_id='%d'", _data.req_id]];
    NSInteger count = [Tools getNumberOfNewDemands];
    if (count>0) {
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld",(long)count]];
    }else{
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
    }
}
     

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFields{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *date = [formatter dateFromString:_data.start_timestamp];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    _lblDate.text = [formatter stringFromDate:date];
    _lblReward.text = [NSString stringWithFormat:@"$%@", _data.cost];
    _lblNewsTitle.text = _data.title;
    _txtNewsDescription.text = _data.desc;
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        if ([appdelegate.mediaImages objectForKey:@(_data.media_id)]==nil) {
            NSURL *url = [NSURL URLWithString:_data.media_icon];
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
            if (image!=nil) {
                [appdelegate.mediaImages setObject:image forKey:@(_data.media_id)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imgMediaLogo.image = [appdelegate.mediaImages objectForKey:@(_data.media_id)];
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _imgMediaLogo.image = [appdelegate.mediaImages objectForKey:@(_data.media_id)];
        });
    });
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _data.latitude;
    coordinate.longitude= _data.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, _data.radius,_data.radius);
    
    Annotation *annotation = [[Annotation alloc] initWithCoordinate:coordinate title:_data.title];
    [_mapView addAnnotation:annotation];
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)setLabelHeights{
    CGFloat currentHeight =  _CS_lblDescriptionHeight.constant;
    CGSize size = [_txtNewsDescription sizeThatFits:CGSizeMake(_txtNewsDescription.frame.size.width, MAXFLOAT)];
    if (size.height>currentHeight) {
        _CS_lblDescriptionHeight.constant = size.height;
    }
}

#pragma mark MapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString *identifier = @"myAnnotation";
    MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"locator"];
    }else {
        annotationView.annotation = annotation;
        
    }
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}

- (void)btnSelectTapped:(id)sender{
    [self.delegate newsDemandIsSelected:_data];
}

@end
