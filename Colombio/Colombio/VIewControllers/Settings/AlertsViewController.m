//
//  AlertsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 26/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "AlertsViewController.h"
#import "CustomHeaderView.h"
#import "ColombioServiceCommunicator.h"
#import "Loading.h"
#import "AppDelegate.h"

@interface AlertsViewController ()<ColombioServiceCommunicatorDelegate, CustomHeaderViewDelegate>
{
    Loading *spinner;
}
@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblInfoText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_infoTextHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblPush;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UISwitch *swPush;
@property (weak, nonatomic) IBOutlet UISwitch *swEmail;

@end

@implementation AlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    _customHeader.headerTitle = [[Localized string:@"alerts"] uppercaseString];
    _customHeader.backButtonText = @"";
    _customHeader.nextButtonText = [Localized string:@"header_save"];
    [self setLabelHeights];
    [self setupSwitches];
}

- (void)setupSwitches{
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *sql = @"select ntf_push, ntf_in_app, ntf_email from user";
    NSMutableDictionary *dict = [appdelegate.db getRowForSQL:sql];
    
    [_swPush setOn:[dict[@"ntf_push"] boolValue]];
    [_swEmail setOn:[dict[@"ntf_email"] boolValue]];
    
}

- (void)setLabelHeights{
    CGFloat currentHeight =  _CS_infoTextHeight.constant;
    CGSize size =  [_lblInfoText.text sizeWithFont:_lblInfoText.font  constrainedToSize:CGSizeMake(_lblInfoText.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    if (size.height>currentHeight) {
        _CS_infoTextHeight.constant = size.height+5;
    }
}

- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnNextClicked{
    spinner = [[Loading alloc] init];
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    
    ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate = self;
    /*NSArray *array = @[@{@"ntf_push":(_swPush.isOn?@1:@0)},
                       @{@"ntf_in_app":@0},
                       @{@"ntf_email":(_swEmail.isOn?@1:@0)}];*/
    
    NSDictionary *dict = @{@"ntf_push":(_swPush.isOn?@1:@0),
                           @"ntf_in_app":@0,
                           @"ntf_email":(_swEmail.isOn?@1:@0)};
    [csc updateUserPreferences:dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CSC Delegate
- (void)didSendUserPreferences{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner removeCustomSpinner];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)fetchingFailedWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner removeCustomSpinner];
    });
}
@end
