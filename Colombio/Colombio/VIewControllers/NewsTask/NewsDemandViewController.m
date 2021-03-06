//
//  NewsDemandViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 26/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "NewsDemandViewController.h"
#import "CustomHeaderView.h"
#import "NewsDemandCell.h"
#import "AppDelegate.h"
#import "NewsDemandObject.h"
#import "Tools.h"
#import "ColombioServiceCommunicator.h"
#import "NewsDemandContainerViewController.h"
#import "NewsDemandServiceCommunicator.h"
#import "Loading.h"

@interface NewsDemandViewController ()<UITableViewDataSource, UITableViewDelegate, CustomHeaderViewDelegate, ColombioServiceCommunicatorDelegate, NewsDemandServiceCommunicatorDelegate>
{
    Loading *spinner;
}
@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeader;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong,nonatomic) NSMutableArray *newsDemandArray;
@property (weak, nonatomic) IBOutlet UITextView *txtNoTask;
@property (strong, nonatomic) NSDictionary *userInfo;
@end

@implementation NewsDemandViewController

- (instancetype)initWithNotification:(NSDictionary*)userInfo{
    self = [super init];
    if (self) {
        _userInfo = userInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _newsDemandArray = [[NSMutableArray alloc] init];
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
}

- (void)viewWillAppear:(BOOL)animated{
    _customHeader.headerTitle = @"NEWS TASK";
    _customHeader.backButtonText=@"";
   _txtNoTask.text = [Localized string:@"no_task"];
    //_customHeader.btnBack.hidden=YES;
    if (_userInfo) {
        spinner = [[Loading alloc] init];
        [spinner startCustomSpinner2:self.view spinMessage:@""];
        NewsDemandServiceCommunicator *newsSC = [NewsDemandServiceCommunicator sharedManager];
        newsSC.delegate=self;
        [newsSC fetchNewsDemands];
    }else
    {
        [self getNewsDeamandList];
    }
    
    
}

- (void)didReceiveMemoryWarning { 
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnBackClicked{
    [self.tabBarController setSelectedIndex:2];
}

#pragma mark NewsDemandServiceCommnunicator

- (void)didFetchNewsDemands:(NSDictionary *)result{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getNewsDeamandList];
    });
    
}

#pragma mark TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _newsDemandArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsDemandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[NewsDemandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NewsDemandObject *newsDemand = (NewsDemandObject*)_newsDemandArray[indexPath.row];
    if (![self checkDemandInDB:newsDemand.req_id]) {
        cell.imgUnread.hidden=NO;
    }else{
        cell.imgUnread.hidden=YES;
    }
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary *mediaInfo = [self getMediaInfo:newsDemand.media_id];
    cell.lblRewardAmount.text = [NSString stringWithFormat:@"%@€", newsDemand.cost];
    cell.lblMediaName.text = [mediaInfo[@"name"] uppercaseString];
    newsDemand.mediaName = mediaInfo[@"name"];
    cell.lblMediaType.text = [appdelegate.dicMediaTypes[mediaInfo[@"media_type"]] uppercaseString];
    cell.lblNewsTitle.text = newsDemand.title;
    cell.lblDescription.text = [NSString stringWithFormat:@"%@",newsDemand.desc];
    
    newsDemand.media_icon = mediaInfo[@"media_icon"];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    //NSDate *date = [formatter dateFromString:newsDemand.start_timestamp];
    NSDate *endDate = [formatter dateFromString:newsDemand.end_timestamp];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    //[formatter setDateStyle:NSDateFormatterMediumStyle];
    cell.lblDate.text = [NSString stringWithFormat:@"%@ %@",[Localized string:@"until"], [formatter stringFromDate:endDate]];
    //NSInteger daysLeft = [_Tools daysDifferenceBetween:[_Tools getDateFromString:newsDemand.start_timestamp] And:[_Tools getDateFromString:newsDemand.end_timestamp]];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        if ([appdelegate.mediaImages objectForKey:@(newsDemand.media_id)]==nil) {
            NSURL *url = [NSURL URLWithString:mediaInfo[@"media_icon"]];
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
            if (image!=nil) {
                [appdelegate.mediaImages setObject:image forKey:@(newsDemand.media_id)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imgMediaLogo.image = [appdelegate.mediaImages objectForKey:@(newsDemand.media_id)];
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imgMediaLogo.image = [appdelegate.mediaImages objectForKey:@(newsDemand.media_id)];
        });
    });
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsDemandContainerViewController *vc = [[NewsDemandContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil focusOnControllerIndex:indexPath.row withDataArray:_newsDemandArray];
    [self saveToDB:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark DB
- (void)saveToDB:(NSInteger)index{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary *tDict = @{@"isread":@TRUE};
    [appdelegate.db updateDictionary:tDict forTable:@"NEWSDEMANDLIST" where:[NSString stringWithFormat:@" req_id='%d' and user_id = '%@'", ((NewsDemandObject*)_newsDemandArray[index]).req_id, [[NSUserDefaults standardUserDefaults] objectForKey:USERID]]];
    /*if (![self checkDemandInDB:((NewsDemandObject*)_newsDemandArray[index]).req_id]) {
        NSDictionary *tDict = @{@"req_id":@(((NewsDemandObject*)_newsDemandArray[index]).req_id), @"title":((NewsDemandObject*)_newsDemandArray[index]).title, @"isread":@TRUE};
        [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"NEWSDEMANDLIST"];
    }*/
}

- (BOOL)checkDemandInDB:(NSInteger)demand_id{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *sql = [NSString stringWithFormat:@"SELECT isread FROM NEWSDEMANDLIST WHERE req_id = %ld and user_id = '%@'", (long)demand_id, [[NSUserDefaults standardUserDefaults] objectForKey:USERID]];
    if ([[appdelegate.db getColForSQL:sql] boolValue] == TRUE) {
        return YES;
    }else{
        return NO;
    }
}

- (NSDictionary*)getMediaInfo:(int)mediaID{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM media_list where id = %d", mediaID];
    NSArray *result = [appdelegate.db getAllForSQL:sql];
    if (result.count==0) {
        return nil;
    }else{
        return result[0];
    }
    
}

- (void)didFetchMedia{
    
}
#pragma mark NewsDemandList

- (void)getNewsDeamandList{
    [_newsDemandArray removeAllObjects];
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"SELECT * FROM newsdemandlist WHERE end_timestamp >= '%@' and user_id = '%@' and status <> 2",[NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:USERID]];
    //[sql appendFormat:@"SELECT * FROM newsdemandlist"];
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSMutableArray *tArray = [appdelegate.db getAllForSQL:sql];
    if (tArray.count>0) {
        _txtNoTask.hidden=YES;
        _tblView.hidden=NO;
    }else{
        _tblView.hidden=YES;
        _txtNoTask.hidden=NO;
    }
    for(NSDictionary *tDict in tArray){
        NewsDemandObject *newsDemand = [[NewsDemandObject alloc] init];
        newsDemand.cost = [tDict[@"cost"] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        newsDemand.desc = tDict[@"description"];
        newsDemand.end_timestamp = tDict[@"end_timestamp"];
        newsDemand.start_timestamp = tDict[@"start_timestamp"];
        newsDemand.latitude = [tDict[@"lat"] floatValue];
        newsDemand.longitude = [tDict[@"lng"] floatValue];
        newsDemand.media_id = [tDict[@"media_id"] intValue];
        newsDemand.radius = [tDict[@"radius"] integerValue];
        newsDemand.req_id = [tDict[@"req_id"] intValue];
        newsDemand.title = tDict[@"title"];
        newsDemand.start_timestamp_date = [Tools getDateFromString:tDict[@"stat_timestamp"]];
        [_newsDemandArray addObject:newsDemand];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"start_timestamp_date" ascending: NO];
    NSArray *sortedArray = [_newsDemandArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    _newsDemandArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        /*loadingView.alpha=0.4;
        [loading removeFromSuperview];
        [loadingView removeFromSuperview];
        [self.view setUserInteractionEnabled:YES];*/
        if (_userInfo) {
            [spinner removeCustomSpinner];
            int index = -1;
            for(int i=0;i<_newsDemandArray.count;i++){
                if ([_userInfo[@"payload"][@"did"] integerValue] == [_newsDemandArray[i][@"news_id"] integerValue]) {
                    index=i;
                }
            }
            if (index>-1) {
                NewsDemandContainerViewController *vc = [[NewsDemandContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil focusOnControllerIndex:index withDataArray:_newsDemandArray];
                [self saveToDB:index];
                [self.navigationController pushViewController:vc animated:YES];
            }
            _userInfo=nil;
        }
        else
        {
            [_tblView reloadData];
        }
        
        
    });
}

@end
