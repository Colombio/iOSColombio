//
//  TimelineViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 03/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimelineViewController.h"
#import "CustomHeaderView.h"
#import "ColombioServiceCommunicator.h"
#import "Loading.h"
#import "AppDelegate.h"
#import "TimeLineTableViewCell.h"
#import "Tools.h"
#import "TimelineDetailsViewController.h"
#import "TimelineServiceCommunicator.h"

#import "TimelineContainerViewController.h"

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate, TimelineServiceCommunicatorDelegate, CustomHeaderViewDelegate>
{
    Loading *spinner;
}
@property (weak, nonatomic) IBOutlet CustomHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *timelineArray;
@property (strong, nonatomic) NSArray *timelineImagesArray;
@property (strong, nonatomic) NSDictionary *userInfo;

@end

@implementation TimelineViewController

- (instancetype)initWithNotification:(NSDictionary*)userInfo{
    self = [super init];
    if (self) {
        _userInfo = userInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    spinner = [[Loading alloc] init];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    TimelineServiceCommunicator *csc = [TimelineServiceCommunicator sharedManager];
    csc.timelineDelegate=self;
    [csc fetchTimeLine];
}

- (void)viewWillDisappear:(BOOL)animated{
    [spinner removeCustomSpinner];
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
    return _timelineArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_timelineArray[indexPath.row][@"type"] integerValue]==2){
        return 253;
    }else if (((NSString*)_timelineArray[indexPath.row][@"img"]).length>0 ) {
        CGFloat startSize = 193;
        CGSize size = [_timelineArray[indexPath.row][@"news_text"] sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR_16]
                                          constrainedToSize:CGSizeMake(236, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        if (size.height>60) {
            return 253;
        }else{
            return startSize+size.height;
        }
    }else{
        CGFloat startSize = 73;
        CGSize size = [_timelineArray[indexPath.row][@"news_text"] sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR_16]
                                                              constrainedToSize:CGSizeMake(236, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        if (size.height>60) {
            return 133;
        }else{
            return startSize+size.height;
        }
        return 133;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimeLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[TimeLineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (_timelineArray[indexPath.row][@"news_id"]) {
        cell.lblTitle.text = _timelineArray[indexPath.row][@"news_title"];
        
        cell.alertImage.hidden = ![Tools checkForNewNotificationWithID:[_timelineArray[indexPath.row][@"news_id"] integerValue]];
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSDate *date = [formatter dateFromString:_timelineArray[indexPath.row][@"date"]];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        cell.lblHeader.text = [NSString stringWithFormat:@"%@ %@", [Localized string:((AppDelegate*)[UIApplication sharedApplication].delegate).dicTimelineButt[_timelineArray[indexPath.row][@"type_id"]]], [formatter stringFromDate:date]];
        //cell.lblDescription.text = [NSString stringWithFormat:@"%@",_timelineArray[indexPath.row][@"news_text"]];
        cell.lblDescription.text = _timelineArray[indexPath.row][@"news_text"];
        CGSize size = [cell.lblDescription.text sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR_16] constrainedToSize:CGSizeMake(236, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        if (size.height>60) {
            cell.CS_lblDescriptionHeight.constant = 60;
        }else{
            cell.CS_lblDescriptionHeight.constant = size.height;
        }
        
        if (((NSString*)_timelineArray[indexPath.row][@"img"]).length>0) {
            dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(concurrentQueue, ^{
                NSURL *url = [NSURL URLWithString:_timelineArray[indexPath.row][@"img"]];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
                if (image!=nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgSample.image = image;
                        cell.imgSample.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imgSample.clipsToBounds=YES;
                        if ([_timelineArray[indexPath.row][@"videoimg"] boolValue]) {
                            UIImageView *imgVideo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"watermark.png"]];
                            imgVideo.frame = CGRectMake(0, 0, 44, 44);
                            imgVideo.center = CGPointMake(cell.imgSample.frame.size.width  / 2,  cell.imgSample.frame.size.height / 2);
                            [cell.imgSample addSubview:imgVideo];
                        }
                    });
                }
            });
        }else{
            [cell.imgSample removeFromSuperview];
        }
    }else{
         cell.alertImage.hidden = ![Tools checkIfSystemNotificationIsRead:[_timelineArray[indexPath.row][@"id"] integerValue]];
        if ([_timelineArray[indexPath.row][@"title"] isEqualToString:@""]){
            cell.lblTitle.hidden=YES;
            cell.txtDescription.hidden=YES;
            cell.webView.hidden=NO;
            
            [cell.webView loadData:[_timelineArray[indexPath.row][@"msg"] dataUsingEncoding:NSUTF8StringEncoding]
                     MIMEType:@"text/html"
             textEncodingName:@"UTF-8"
                      baseURL:nil];

            //[cell.webView loadHTMLString:_timelineArray[indexPath.row][@"msg"] baseURL:nil];
            cell.lblHeader.text = [Tools getStringFromDateString:_timelineArray[indexPath.row][@"date"] withFormat:@"dd/MM/yyyy"];
            cell.imgSample.image = [UIImage imageNamed:@"colombiotimeline"];
        }else{
            cell.lblTitle.text = _timelineArray[indexPath.row][@"title"];
            cell.lblHeader.text = [Tools getStringFromDateString:_timelineArray[indexPath.row][@"date"] withFormat:@"dd/MM/yyyy"];
            cell.txtDescription.text = [NSString stringWithFormat:@"%@",_timelineArray[indexPath.row][@"msg"]];
            cell.imgSample.image = [UIImage imageNamed:@"colombiotimeline"];
        }
        
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //TimelineDetailsViewController *vc = [[TimelineDetailsViewController alloc] initWithTimelineDetails:_timelineArray[indexPath.row]];
    TimelineContainerViewController *vc = [[TimelineContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil focusOnControllerIndex:indexPath.row withDataArray:_timelineArray];
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*if ([_timelineArray[indexPath.row][@"type"] longLongValue] == 1) {
        [self setNotificationsToRead:[_timelineArray[indexPath.row][@"news_id"] longValue]];
    }else if ([_timelineArray[indexPath.row][@"type"] longLongValue] == 2){
        [self setSystemNotificationToRead:[_timelineArray[indexPath.row][@"id"] longValue]];
    }*/
    
}

#pragma mark CSC Delegate
- (void)didFetchTimeline{
    
    NSString *sql = [NSString stringWithFormat:@"Select tl.*, tli.medium_image as img, tli.is_video as videoimg, 1 as type from timeline as tl left join timeline_image as tli on tli.news_id = tl.news_id where tl.user_id = '%@' order by timestamp desc", [[NSUserDefaults standardUserDefaults] objectForKey:USERID]];
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _timelineArray = [appdelegate.db getAllForSQL:sql];
    
    sql = [NSString stringWithFormat:@"Select *, 2 as type from TIMELINE_NOTIFICATIONS where type_id = 2 and user_id = '%@'", [[NSUserDefaults standardUserDefaults] objectForKey:USERID]];
    _timelineArray = [_timelineArray arrayByAddingObjectsFromArray:[appdelegate.db getAllForSQL:sql]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"timestamp" ascending: NO];
    NSArray *sortedArray = [_timelineArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    _timelineArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner removeCustomSpinner];
        if (_userInfo) {
            int index = -1;
            for(int i=0;i<_timelineArray.count;i++){
                if ([_userInfo[@"payload"][@"nid"] integerValue] == [_timelineArray[i][@"news_id"] integerValue]) {
                    index=i;
                }
            }
            if (index>-1) {
                TimelineContainerViewController *vc = [[TimelineContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil focusOnControllerIndex:index withDataArray:_timelineArray];
                [self.navigationController pushViewController:vc animated:YES];
            }
            [self setNotificationsToRead:[_userInfo[@"payload"][@"nid"] integerValue]];
            _userInfo=nil;
        }
        [self setNotificationBadge];
        [_tableView reloadData];
    });
}

- (void)setNotificationsToRead:(NSInteger)timelineid{
    NSDictionary *tDict = @{@"is_read":@TRUE};
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appdelegate.db updateDictionary:tDict forTable:@"TIMELINE_NOTIFICATIONS" where:[NSString stringWithFormat:@" nid='%ld'", (long)timelineid]];
    [self setNotificationBadge];
}

- (void)setSystemNotificationToRead:(NSInteger)id{
    NSDictionary *tDict = @{@"is_read":@TRUE};
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appdelegate.db updateDictionary:tDict forTable:@"TIMELINE_NOTIFICATIONS" where:[NSString stringWithFormat:@" id='%ld'", (long)id]];
    [self setNotificationBadge];
}

- (void)setNotificationBadge{
    if ([Tools checkForNewNotification]) {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"!"];
    }else{
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
    }
}
@end
