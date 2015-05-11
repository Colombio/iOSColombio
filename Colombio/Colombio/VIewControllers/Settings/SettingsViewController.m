//
//  SettingsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 25/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SettingsViewController.h"
#import "CustomHeaderView.h"
#import "SettingsInfoViewController.h"
#import "SimpleMediaSelectViewController.h"
#import "SimpleCountrySelectViewController.h"
#import "SelectLanguageViewController.h"
#import "AlertsViewController.h"
#import "AppDelegate.h"
#import "Messages.h"
#import "LoginViewController.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeader;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblView.alwaysBounceVertical = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    _customHeader.headerTitle = [[Localized string:@"settings"] uppercaseString];
    _customHeader.backButtonText=@"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnBackClicked{
    [self.tabBarController setSelectedIndex:2];
}

#pragma mark TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
    cell.textLabel.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NEWS_TITLE];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [Localized string:@"select_country"];
            break;
        case 1:
            cell.textLabel.text = [Localized string:@"select_media"];
            break;
        case 2:
            cell.textLabel.text = [Localized string:@"select_language"];
            break;
        case 3:
            cell.textLabel.text = [Localized string:@"alerts"];
            break;
        case 4:
            cell.textLabel.text = [Localized string:@"faq"];
            break;
        case 5:
            cell.textLabel.text = [Localized string:@"terms_of_service"];
            break;
        case 6:
            cell.textLabel.text = [Localized string:@"privacy_policy"];
            break;
        case 7:
            cell.textLabel.text = [Localized string:@"contact_us"];
            break;
        case 8:
            cell.textLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_BOLD];
            cell.textLabel.text = [Localized string:@"log_off"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    for (int i=0; i<9; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexpath];
        cell.textLabel.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NEWS_TITLE];
    }
    /*UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0];*/
    
    
    switch (indexPath.row) {
        case 0:
        {
            SimpleCountrySelectViewController *vc = [[SimpleCountrySelectViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            SimpleMediaSelectViewController *vc = [[SimpleMediaSelectViewController alloc] initForCallMedia:NO];
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
        case 2:
        {
            SelectLanguageViewController *vc = [[SelectLanguageViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            AlertsViewController *vc = [[AlertsViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            SettingsInfoViewController *vc = [[SettingsInfoViewController alloc] initForType:(indexPath.row)];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        {
            SettingsInfoViewController *vc = [[SettingsInfoViewController alloc] initForType:(indexPath.row)];
            [self.navigationController pushViewController:vc animated:YES];
        }

            break;
        case 6:
        {
            SettingsInfoViewController *vc = [[SettingsInfoViewController alloc] initForType:(indexPath.row)];
            [self.navigationController pushViewController:vc animated:YES];
        }

            break;
        case 7:
        {
            NSString *subject = @"Colombio - iOS App";
            NSString *mailto = [NSString stringWithFormat:@"mailto:support@colomb.io?subject=%@", subject];
            mailto = [mailto stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailto]];
        }

            break;
        case 8:{
            NSString *result = [ColombioServiceCommunicator getSignedRequest];
            ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
            [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_user_managment/mau_logout/", BASE_URL] httpBody:[NSString stringWithFormat:@"signed_req=%@",result]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
            [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if(error){
                    [Messages showErrorMsg:@"error_web_request"];
                }
                
                //Request is successfuly sent
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                        [appdelegate.db clearTable:@"USER"];
                        [appdelegate.db clearTable:@"USER_CASHOUT"];
                        [appdelegate.db clearTable:@"NEWSDEMANDLIST"];
                        [appdelegate.db clearTable:@"UPLOAD_DATA"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:TIMELINE_TIMESTAMP];
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:NEWSDEMAND_TIMESTAMP];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        //[appdelegate.db clearTable:@"MEDIA_LIST"];
                        //[appdelegate.db clearTable:@"SELECTED_MEDIA"];
                        //[appdelegate.db clearTable:@"COUNTRIES_LIST"];
                        //[appdelegate.db clearTable:@"SELECTED_COUNTRIES"];
                        
                        appdelegate.window.rootViewController = [[LoginViewController alloc] init];
                        [appdelegate.window makeKeyAndVisible];
                    });
                    
                }
            }];
        }
            
            break;
            
        default:
            break;
    }
}

@end
