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

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate, ColombioServiceCommunicatorDelegate, CustomHeaderViewDelegate>
{
    Loading *spinner;
}
@property (weak, nonatomic) IBOutlet CustomHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *timelineArray;
@property (strong, nonatomic) NSArray *timelineImagesArray;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    spinner = [[Loading alloc] init];
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate=self;
    [csc fetchTimeLine];
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
    if (((NSString*)_timelineArray[indexPath.row][@"img"]).length>0) {
        return 231;
    }else{
        return 111;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimeLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[TimeLineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (_timelineArray[indexPath.row][@"news_id"]) {
        cell.lblTitle.text = _timelineArray[indexPath.row][@"news_title"];
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSDate *date = [formatter dateFromString:_timelineArray[indexPath.row][@"timestamp"]];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        cell.lblHeader.text = [NSString stringWithFormat:@"%@: %@ %@", [Localized string:@"sent"], [Localized string:((AppDelegate*)[UIApplication sharedApplication].delegate).dicTimelineButt[_timelineArray[indexPath.row][@"type_id"]]], [formatter stringFromDate:date]];
        cell.txtDescription.text = [NSString stringWithFormat:@"%@",_timelineArray[indexPath.row][@"news_text"]];
        [cell.txtDescription sizeToFit];
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
                    });
                }
            });
        }else{
            [cell.imgSample removeFromSuperview];
        }
    }else{
        cell.lblTitle.text = _timelineArray[indexPath.row][@"title"];
        cell.lblHeader.text = [Tools getStringFromDateString:_timelineArray[indexPath.row][@"timestamp"] withFormat:@"dd/MM/yyyy"];
        cell.txtDescription.text = [NSString stringWithFormat:@"%@",_timelineArray[indexPath.row][@"msg"]];
        [cell.imgSample removeFromSuperview];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TimelineDetailsViewController *vc = [[TimelineDetailsViewController alloc] initWithTimelineDetails:_timelineArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark CSC Delegate
- (void)didFetchTimeline{
    
    NSString *sql = @"Select tl.*, tli.medium_image as img, 1 as type from timeline as tl left join timeline_image as tli on tli.news_id = tl.news_id order by timestamp desc";
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _timelineArray = [appdelegate.db getAllForSQL:sql];
    
    sql = @"Select *, 2 as type from TIMELINE_NOTIFICATIONS where type_id = 2";
    _timelineArray = [_timelineArray arrayByAddingObjectsFromArray:[appdelegate.db getAllForSQL:sql]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"timestamp" ascending: NO];
    NSArray *sortedArray = [_timelineArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    _timelineArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner removeCustomSpinner];
        [_tableView reloadData];
    });

    
}

@end
