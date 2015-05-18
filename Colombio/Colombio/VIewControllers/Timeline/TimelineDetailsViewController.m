//
//  TimelineDetailsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 12/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TimelineDetailsViewController.h"
#import "CustomHeaderView.h"
#import "ColombioServiceCommunicator.h"
#import "AppDelegate.h"
#import "Tools.h"

#import "TimelineMediaReplyCell.h"
#import "TimelineUserReplyCell.h"
#import "TimelineOfferCell.h"
#import "TImelineWriteReplyCell.h"
#import "Loading.h"
#import "Messages.h"

enum TimelineDetailsType{
    TIMELINE_NEWS = 1,
    TIMELINE_NOTIFICATION = 2,
    TIMELINE_ALERT = 3
};

@interface TimelineDetailsViewController ()<CustomHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate, ColombioServiceCommunicatorDelegate, TimeLineOfferCellDelegate, UITextViewDelegate, TimeLineWriteReplyCellDelegate>
{
    ColombioServiceCommunicator *csc;
    int timelineType;
    AppDelegate *appdelegate;
    BOOL replyExists;
    Loading *spinner;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeader;

@property (strong, nonatomic) NSMutableArray *timelineDetailsArray;
@property (strong, nonatomic) NSDictionary *timelineDict;
@property (strong, nonatomic) NSMutableArray *tableDataArray;

@property (strong, nonatomic) NSMutableDictionary *textViewsDict;

@end

@implementation TimelineDetailsViewController


- (instancetype)initWithTimelineDetails:(NSDictionary*)timelineDict{
    self = [super init];
    if (self) {
        _timelineDict = timelineDict;
        timelineType = [_timelineDict[@"type"] intValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    _textViewsDict = [[NSMutableDictionary alloc] init];
    
    appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate=self;
    spinner = [[Loading alloc] init];
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    [csc fetchTimeLine];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (timelineType==TIMELINE_NEWS) {
        _customHeader.headerTitle = _timelineDict[@"news_title"];
    }
    _customHeader.backButtonText=@"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma  mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _tableDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ((NSMutableArray*)_tableDataArray){
        return ((NSMutableArray*)_tableDataArray[section]).count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *tDict = _tableDataArray[indexPath.section][indexPath.row];
    if ([tDict[@"detailtype"] integerValue] == 1) {
        
        return ((CGSize)[self getHeightForText:tDict[@"msg"]]).height + 102.0;

    }else if ([tDict[@"detailtype"] integerValue] == 2) {
        
        if ([tDict[@"offer_status"] integerValue]==0) {
            
            return ((CGSize)[self getHeightForText:[NSString stringWithFormat:[Localized string:@"price_offer"], tDict[@"offer"]]]).height + 156.0;
            
        }else if ([tDict[@"offer_status"] integerValue]==2) {
            
            CGFloat height =[self getHeightForText:[NSString stringWithFormat:[Localized string:@"accepted_offer"], tDict[@"offer"]]].height;
            height += [self getHeightForText:[Localized string:@"cannot_sell"]].height;
            
            return height + 102.0;
            
        }else {
            
            return ((CGSize)[self getHeightForText:[NSString stringWithFormat:[Localized string:@"rejected_offer"], tDict[@"offer"]]]).height + 102.0;
            
        }
        
    }else if ([tDict[@"detailtype"] integerValue] == 3) {
        if ([tDict[@"type"] isEqualToString:@"m"]) {
            return ((CGSize)[self getHeightForText:tDict[@"message"]]).height + 102.0;
        }else{
            return ((CGSize)[self getHeightForText:tDict[@"message"]]).height + 76.0;
        }
    }else if ([tDict[@"detailtype"] integerValue] == 4) {
        
        CGFloat height = [self textViewHeightForRowAtIndexPath:@(indexPath.section+indexPath.row)];
        //((CLTextView*)_textViewsDict[indexPath]).frame.size.width
        if (height>20.0) {
            return height;
        }else{
            return 20.0;
        }
        
    }
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *tDict = _tableDataArray[indexPath.section][indexPath.row];
    switch ([tDict[@"detailtype"] integerValue]) {
        case 1:
        {
            TimelineMediaReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratecell"];
            if (cell==nil) {
                cell=[[TimelineMediaReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ratecell"];
            }
            cell.lblName.text = tDict[@"medianame"];
            cell.lblTypeName.text = [[Localized string:appdelegate.dicMediaTypes[tDict[@"media_type"]]] uppercaseString];
            cell.lblDate.text =  [Tools getStringFromDateString:tDict[@"timestamp"] withFormat:@"dd/MM/yyyy"];
            cell.lblMessage.text = tDict[@"msg"];
            cell.CS_lblMessageHeight.constant = ((CGSize)[self getHeightForText:tDict[@"msg"]]).height;
            cell.CS_lblViewContainerHeight.constant += cell.CS_lblMessageHeight.constant;
            
            dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //this will start the image loading in bg
            dispatch_async(concurrentQueue, ^{
                if ([appdelegate.mediaImages objectForKey:tDict[@"mid"]]==nil) {
                    NSURL *url = [NSURL URLWithString:tDict[@"media_icon"]];
                    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
                    if (image!=nil) {
                        [appdelegate.mediaImages setObject:image forKey:tDict[@"mid"]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.imgLogo.image = [appdelegate.mediaImages objectForKey:tDict[@"mid"]];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.imgLogo.image = [UIImage imageNamed:@"uploadphoto"];
                        });
                    }
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgLogo.image = [appdelegate.mediaImages objectForKey:tDict[@"mid"]];
                    });
                }
            });
            
            return cell;
        }
            break;
            
        case 2:
        {
            TimelineOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:@"offercell"];
            if (cell==nil) {
                cell=[[TimelineOfferCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"offercell"];
            }
            cell.delegate = self;
            cell.lblName.text = tDict[@"medianame"];
            cell.lblTypeName.text = [[Localized string:appdelegate.dicMediaTypes[tDict[@"media_type"]]] uppercaseString];
            cell.lblDate.text =  [Tools getStringFromDateString:tDict[@"timestamp"] withFormat:@"dd/MM/yyyy"];
            cell.offerID = [tDict[@"c_offer_id"] integerValue];
            cell.CS_lblViewContainerHeight.constant -= cell.CS_lblMessageHeight.constant;
            
            if ([tDict[@"offer_status"] integerValue]==0) {
                
                cell.lblMessage.text = [NSString stringWithFormat:[Localized string:@"price_offer"], tDict[@"offer"]];
                
            }else if ([tDict[@"offer_status"] integerValue]==2) {
                
                cell.btnAccept.hidden=YES;
                cell.btnReject.hidden=YES;
                
                cell.lblMessage.text = [NSString stringWithFormat:[Localized string:@"accepted_offer"], tDict[@"offer"]];
                cell.lblDisclaimer.text = [Localized string:@"cannot_sell"];
                
                cell.CS_lblDisclaimerHeight.constant =  [self getHeightForText:cell.lblDisclaimer.text].height;
                cell.CS_lblMessageHeight.constant = ((CGSize)[self getHeightForText:cell.lblMessage.text]).height;
                cell.CS_lblViewContainerHeight.constant += cell.CS_lblMessageHeight.constant;
                cell.CS_lblViewContainerHeight.constant += cell.CS_lblDisclaimerHeight.constant +5;
                
                
                return cell;
                
            }else {
                
                cell.lblMessage.text = [NSString stringWithFormat:[Localized string:@"rejected_offer"], tDict[@"offer"]];
                cell.btnAccept.hidden=YES;
                cell.btnReject.hidden=YES;
            }
            
            dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //this will start the image loading in bg
            dispatch_async(concurrentQueue, ^{
                if ([appdelegate.mediaImages objectForKey:tDict[@"mid"]]==nil) {
                    NSURL *url = [NSURL URLWithString:tDict[@"media_icon"]];
                    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
                    if (image!=nil) {
                        [appdelegate.mediaImages setObject:image forKey:tDict[@"mid"]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.imgLogo.image = [appdelegate.mediaImages objectForKey:tDict[@"mid"]];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.imgLogo.image = [UIImage imageNamed:@"uploadphoto"];
                        });
                    }
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgLogo.image = [appdelegate.mediaImages objectForKey:tDict[@"mid"]];
                    });
                }
            });
            
            
            cell.CS_lblMessageHeight.constant = ((CGSize)[self getHeightForText:cell.lblMessage.text]).height;
            cell.CS_lblViewContainerHeight.constant += cell.CS_lblMessageHeight.constant+3;
            return cell;
        }
            break;
            
        case 3:
        {
            if ([tDict[@"type"] isEqualToString:@"m"]) {
                TimelineMediaReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replycell"];
                if (cell==nil) {
                    cell=[[TimelineMediaReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"replycell"];
                }
                cell.lblName.text = tDict[@"medianame"];
                cell.lblTypeName.text = [[Localized string:appdelegate.dicMediaTypes[tDict[@"media_type"]]] uppercaseString];
                cell.lblDate.text =  [Tools getStringFromDateString:tDict[@"timestamp"] withFormat:@"dd/MM/yyyy"];
                cell.lblMessage.text = tDict[@"message"];
                cell.CS_lblMessageHeight.constant = ((CGSize)[self getHeightForText:tDict[@"message"]]).height;
                cell.CS_lblViewContainerHeight.constant += cell.CS_lblMessageHeight.constant+3;
                
                dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                //this will start the image loading in bg
                dispatch_async(concurrentQueue, ^{
                    if ([appdelegate.mediaImages objectForKey:tDict[@"mid"]]==nil) {
                        NSURL *url = [NSURL URLWithString:tDict[@"media_icon"]];
                        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
                        if (image!=nil) {
                            [appdelegate.mediaImages setObject:image forKey:tDict[@"mid"]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                cell.imgLogo.image = [appdelegate.mediaImages objectForKey:tDict[@"mid"]];
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                cell.imgLogo.image = [UIImage imageNamed:@"uploadphoto"];
                            });
                        }
                        
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.imgLogo.image = [appdelegate.mediaImages objectForKey:tDict[@"mid"]];
                        });
                    }
                });
                
                return cell;
                
            }else{
                
                TimelineUserReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userreplycell"];
                if (cell==nil) {
                    cell=[[TimelineUserReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userreplycell"];
                }
                cell.lblName.text = ((NSString*)tDict[@"name"]).length>0?tDict[@"name"]:@"N/A";
                cell.lblDate.text =  [Tools getStringFromDateString:tDict[@"timestamp"] withFormat:@"dd/MM/yyyy"];
                cell.lblMessage.text = tDict[@"message"];
                cell.CS_lblMessageHeight.constant = ((CGSize)[self getHeightForText:tDict[@"message"]]).height;
                cell.CS_lblViewContainerHeight.constant += cell.CS_lblMessageHeight.constant+3;
                return cell;
            }
        }
            break;
        case 4:{
            TImelineWriteReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"writereplycell"];
            if (cell==nil) {
                cell=[[TImelineWriteReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"writereplycell"];
            }
            cell.delegate = self;
            _textViewsDict[@(indexPath.section+indexPath.row)] = cell.txtView;
            
            cell.nid = [tDict[@"nid"] longValue];
            cell.mid = [tDict[@"mid"] longValue];
            cell.txtView.delegate = self;
        
            return cell;
            
        }
            break;
        default:{
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell==nil) {
                cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            }
            return cell;
        }
            break;
    }
}

- (CGSize)getHeightForText:(NSString*)txt{
    return [txt sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR_16]
           constrainedToSize:CGSizeMake(223, MAXFLOAT)
               lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGFloat)textViewHeightForRowAtIndexPath: (NSNumber*)indexPath {
    CLTextView *calculationView = [_textViewsDict objectForKey:indexPath];
    CGFloat textViewWidth = calculationView.frame.size.width;
    CGSize size = [calculationView sizeThatFits:CGSizeMake(textViewWidth, MAXFLOAT)];
    return size.height+2;
}

#pragma mark TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
     [self scrollToCursorForTextView:textView];
}

- (void)textViewDidChange:(UITextView *)textView{
    [_tblView beginUpdates];
    [_tblView endUpdates];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}


- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    cursorRect = [_tblView convertRect:cursorRect fromView:textView];
    
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [_tblView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (BOOL)rectVisible: (CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = _tblView.contentOffset;
    visibleRect.origin.y +=_tblView.contentInset.top;
    visibleRect.size = _tblView.bounds.size;
    visibleRect.size.height -=_tblView.contentInset.top + _tblView.contentInset.bottom;
    
    return CGRectContainsRect(visibleRect, rect);
}

#pragma mark CSC
- (void)didFetchTimeline{
    if (timelineType==TIMELINE_NEWS) {
        [csc fetchTimeLineCounterOffers:[_timelineDict[@"news_id"] longValue]];
    }
}

- (void)didFetchTimeLineCounterOffers:(NSDictionary *)result{
    if (timelineType==TIMELINE_NEWS) {
        [csc fetchTimeLineCommunication:[_timelineDict[@"news_id"] longValue]];
    }
}

- (void)didFetchTimeLineCommunication{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDataArray];
    });
    
}

#pragma mark Navigation
- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark DB
- (void)setDataArray{
    AppDelegate *appdelegte = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *sql = [NSString stringWithFormat:@"select timeline_notifications.*, 1 as detailtype, m.name as medianame, m.media_type, m.media_icon from timeline_notifications left join media_LIST as m on m.id = timeline_notifications.mid  where nid = %@ and type_id = 1 order by timeline_notifications.timestamp", _timelineDict[@"news_id"]];
    _timelineDetailsArray = [appdelegte.db getAllForSQL:sql];
    
    sql = [NSString stringWithFormat:@"select timeline_offers.*, 2 as detailtype, m.name as medianame, m.media_type, m.media_icon from timeline_offers left join media_LIST as m on m.id = timeline_offers.mid where nid = %@ order by timeline_offers.timestamp", _timelineDict[@"news_id"]];
    [_timelineDetailsArray  addObjectsFromArray:[appdelegte.db getAllForSQL:sql]];
    
    sql = [NSString stringWithFormat:@"select timeline_messages.*, 3  as detailtype, m.name as medianame, m.media_type, m.media_icon from timeline_messages left join media_LIST as m on m.id = timeline_messages.mid where nid = %@ order by timeline_messages.timestamp", _timelineDict[@"news_id"]];
    
    [_timelineDetailsArray  addObjectsFromArray:[appdelegte.db getAllForSQL:sql]];
    
    /*NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"timestamp" ascending: YES];
    NSArray *sortedArray = [_timelineDetailsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    _timelineDetailsArray = [[NSMutableArray alloc] initWithArray:sortedArray];*/
    
    [self groupByMedia];

}

- (void)groupByMedia{
    NSArray *mediaList = [_timelineDict[@"media_list"] componentsSeparatedByString:@","];
    _tableDataArray = [[NSMutableArray alloc] init];
    for (int i=0;i<mediaList.count;i++) {
        BOOL addWriteReply=NO;
        NSInteger mediaid = [(NSString*)mediaList[i] integerValue];
        NSMutableArray *tArray = [[NSMutableArray alloc] init];
        for (NSDictionary *tDict in _timelineDetailsArray) {
            if ([tDict[@"mid"] longValue]==mediaid) {
                [tArray addObject:tDict];
                if ([tDict[@"detailtype"] longValue]==3) {
                    addWriteReply=YES;
                }
            }
        }
        if (addWriteReply) {
            NSDictionary *dict = @{@"detailtype":@4, @"mid":@(mediaid), @"nid":_timelineDict[@"news_id"]};
            [tArray addObject:dict];
        }
        [_tableDataArray addObject:tArray];
    }
    
    
    [spinner removeCustomSpinner];
    [_tblView reloadData];
}

#pragma mark keyboard
- (void)keyboardUp:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(_tblView.contentInset.top, 0.0, kbSize.height, 0.0);
    _tblView.contentInset = contentInsets;
    _tblView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardDown:(NSNotification*)aNotification {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(_tblView.contentInset.top, 0.0, 0.0, 0.0);
    _tblView.contentInset = contentInsets;
    _tblView.scrollIndicatorInsets = contentInsets;
    [UIView commitAnimations];
}

#pragma mark Delegate Buttons
- (void)didAcceptOffer:(NSInteger)offer_id{
    [self offerResponse:offer_id withStatus:2];
}

- (void)didRejectOffer:(NSInteger)offer_id{
    [self offerResponse:offer_id withStatus:1];
}

- (void)didSelectSendReply:(NSString *)message forNewsId:(NSInteger)nid andMediaId:(NSInteger)mid{
    [self postReply:message forNewsID:nid andMediaId:mid];
}

#pragma mark Communication
- (void)offerResponse:(NSInteger)offer_id withStatus:(NSInteger)offer_status{
    NSString *signedRequest = [ColombioServiceCommunicator getSignedRequest];
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/select_news_counteroffers/", BASE_URL];
    NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&coid=%ld&status=%ld",signedRequest, offer_id, offer_status];
    
    NSURL * url = [NSURL URLWithString:url_str];

    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       
        if(error==nil&&data!=nil){
            NSDictionary *response=nil;
            response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(!strcmp("1",((NSString*)[response objectForKey:@"s"]).UTF8String)){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner startCustomSpinner2:self.view spinMessage:@""];
                });
                [csc fetchTimeLine];
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeCustomSpinner];
                [Messages showErrorMsg:@"error_web_request"];
            });
            
        }
    }];
}

- (void)postReply:(NSString*)strReply forNewsID:(NSInteger)newsid andMediaId:(NSInteger)mid{
    NSString *signedRequest = [ColombioServiceCommunicator getSignedRequest];
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/add_news_communication/", BASE_URL];
    NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&nid=%ld&mid=%ld&message=%@",signedRequest, newsid, mid, strReply];
    
    NSURL * url = [NSURL URLWithString:url_str];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error==nil&&data!=nil){
            NSDictionary *response=nil;
            response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(!strcmp("1",((NSString*)[response objectForKey:@"s"]).UTF8String)){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner startCustomSpinner2:self.view spinMessage:@""];
                });
                [csc fetchTimeLine];
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeCustomSpinner];
                [Messages showErrorMsg:@"error_web_request"];
            });
            
        }
    }];
}
@end
