//
//  SettingsInfoViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 25/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SettingsInfoViewController.h"
#import "CustomHeaderView.h"
#import "ColombioServiceCommunicator.h"
#import "Loading.h"
#import "AppDelegate.h"

enum Types{
    FAQ = 4,
    TERMS_OF_SERVICE=5,
    PRIVACY_POLICY=6,
    ABOUT=7
};
@interface SettingsInfoViewController ()<CustomHeaderViewDelegate, ColombioServiceCommunicatorDelegate, UIWebViewDelegate>
{
    Loading *spinner;
}
@property (assign, nonatomic) NSInteger type;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeaderView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation SettingsInfoViewController
- (instancetype)initForType:(NSInteger)type{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _customHeaderView.backButtonText = @"";
    switch (_type) {
        case FAQ:
            _customHeaderView.headerTitle = [Localized string:@"faq"];
           
            break;
        case TERMS_OF_SERVICE:
            _customHeaderView.headerTitle = [[Localized string:@"terms_of_service"] uppercaseString];
            break;
            
        case PRIVACY_POLICY:
            _customHeaderView.headerTitle = [[Localized string:@"privacy_policy"] uppercaseString];
            break;
        case ABOUT:
            _customHeaderView.headerTitle = [[Localized string:@"contact_us"] uppercaseString];
            break;
        default:
            break;
    }
    spinner = [[Loading alloc] init];
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate=self;
    [csc fetchInfoTexts];
    
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnBackClicked{
    if ([self isModal]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

#pragma mark CSC
- (void)didFetchInfoTexts{
    NSString *sql;
    NSString *txtId;
    switch (_type) {
        case FAQ:
            txtId = @"faq";
            sql = [NSString stringWithFormat:@"SELECT * FROM INTO_TEXTS WHERE text_id = '%@' and lang_id=%d", txtId, 2];
            break;
        case TERMS_OF_SERVICE:
            txtId = @"tos";
            sql = [NSString stringWithFormat:@"SELECT * FROM INTO_TEXTS WHERE text_id = '%@' and lang_id=%d", txtId, 2];
            break;
        case PRIVACY_POLICY:
            txtId = @"privacy";
            sql = [NSString stringWithFormat:@"SELECT * FROM INTO_TEXTS WHERE text_id = '%@' and lang_id=%d", txtId, 2];
            break;
        case ABOUT:
            txtId = @"about";
            sql = [NSString stringWithFormat:@"SELECT * FROM INTO_TEXTS WHERE text_id = '%@' and lang_id=%d", txtId, 2];
            break;
        default:
            break;
    }
    
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *txtDict = [appdelegate.db getRowForSQL:sql];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (txtDict.count>0) {
            _txtView.text = txtDict[@"content"];
            /*if (_type==FAQ) {
                [_webView loadHTMLString:[Localized string:@"faq_desc"] baseURL:nil];
            }else{
                [_webView loadHTMLString:txtDict[@"content"] baseURL:nil];
            }*/
            [_webView loadHTMLString:txtDict[@"content"] baseURL:nil];
            
        }
        [spinner removeCustomSpinner];
        
    });
    
}

- (void)fetchingFailedWithError:(NSError *)error{
    [spinner removeCustomSpinner];
}

- (BOOL)isModal{
    BOOL modal = self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
    return modal;
}


@end
