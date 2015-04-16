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

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate, ColombioServiceCommunicatorDelegate>
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
    spinner = [[Loading alloc] init];
    [spinner startCustomSpinner:self.view spinMessage:@""];
    ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate=self;
    [csc fetchTimeLine];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return 230;
    }else{
        return 110;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimeLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[TimeLineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.lblTitle.text = _timelineArray[indexPath.row][@"news_title"];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *date = [formatter dateFromString:_timelineArray[indexPath.row][@"news_timestamp"]];
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
    return cell;
}

#pragma mark CSC Delegate
- (void)didFetchTimeline{
    
    NSString *sql = @"Select tl.*, tli.medium_image as img from timeline as tl left join timeline_image as tli on tli.news_id = tl.news_id order by news_timestamp desc";
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    _timelineArray = [appdelegate.db getAllForSQL:sql];
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner removeCustomSpinner];
        [_tableView reloadData];
    });

    
}

@end
