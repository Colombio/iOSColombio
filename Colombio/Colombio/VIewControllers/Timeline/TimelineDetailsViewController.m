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
#import "TimelineSentNewsCell.h"
#import "SelectMediaCell.h"
#import "TimeLineTableViewCell.h"
#import "Loading.h"
#import "Messages.h"



enum TimelineDetailsType{
    TIMELINE_NEWS = 1,
    TIMELINE_NOTIFICATION = 2,
    TIMELINE_ALERT = 3
};

@interface TimelineDetailsViewController ()<CustomHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate, ColombioServiceCommunicatorDelegate, TimeLineOfferCellDelegate, UITextViewDelegate, TimeLineWriteReplyCellDelegate, UIWebViewDelegate>
{
    ColombioServiceCommunicator *csc;
    int timelineType;
    AppDelegate *appdelegate;
    BOOL replyExists;
    Loading *spinner;
    CGFloat webViewHeight;
    UIWebView *dummyWebView;
    
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
    self = [super initWithNibName:@"TImelineDetailsSubviewViewController" bundle:nil];
    if (self) {
        _timelineDict = timelineDict;
        timelineType = [_timelineDict[@"type"] intValue];
        if (timelineType==TIMELINE_NEWS) {
            self.title = _timelineDict[@"news_title"];
        }else if(timelineType==TIMELINE_NOTIFICATION){
            self.title = @"COLOMBIO";
        }
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
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (webView==dummyWebView) {
        webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
        [_tblView reloadData];
    }else{
        [webView sizeToFit];
    }
    [spinner removeCustomSpinner];
    
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (timelineType==TIMELINE_NEWS) {
        if ([self.delegate respondsToSelector:@selector(timelineDetailsProcessing)]) {
            [self.delegate timelineDetailsProcessing];
        }
        csc = [ColombioServiceCommunicator sharedManager];
        csc.delegate=self;
        spinner = [[Loading alloc] init];
        [spinner startCustomSpinner2:self.view spinMessage:@""];
        [csc fetchTimeLine];
    }else if(timelineType==TIMELINE_NOTIFICATION){
        spinner = [[Loading alloc] init];
        [spinner startCustomSpinner2:self.view spinMessage:@""];
        dummyWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 236, 1)];
        dummyWebView.delegate=self;
        [dummyWebView loadHTMLString:_timelineDict[@"msg"] baseURL:nil];
        [self setSystemNotificationToRead:[_timelineDict[@"id"] longValue]];
        
    }
    /*if (timelineType==TIMELINE_NEWS) {
        [self.customHeader setHeaderTitle:_timelineDict[@"news_title"]];
    }else if (timelineType==TIMELINE_NOTIFICATION){
        [self.customHeader setHeaderTitle:@"COLOMBIO"];
    }
    _customHeader.backButtonText=@"";
    _customHeader.lblTitle.lineBreakMode=NSLineBreakByTruncatingTail;
    _customHeader.lblTitle.adjustsFontSizeToFitWidth=NO;*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma  mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (timelineType==TIMELINE_NOTIFICATION) {
        return 1;
    }else{
        return _tableDataArray.count;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ((NSMutableArray*)_tableDataArray){
        return ((NSMutableArray*)_tableDataArray[section]).count;
    }else{
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (timelineType==TIMELINE_NEWS) {
        if (section==0 && section!=_tableDataArray.count-1) {
            UILabel *myLabel = [[UILabel alloc] init];
            myLabel.frame = CGRectMake(5, 8, 320,15);
            myLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_MEDIUM_15];
            myLabel.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_NEXT_BUTTON];
            myLabel.text  = [[Localized string:@"media_communication"] uppercaseString];
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
            headerView.backgroundColor = [UIColor whiteColor];
            [headerView addSubview:myLabel];
            return headerView;
        }else if(section==_tableDataArray.count-2){
            UILabel *myLabel = [[UILabel alloc] init];
            myLabel.frame = CGRectMake(5, 8, 320, 15);
            myLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_MEDIUM_15];
            myLabel.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_NEXT_BUTTON];
            myLabel.text  = [[Localized string:@"sent_news"] uppercaseString];
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
            headerView.backgroundColor = [UIColor whiteColor];
            [headerView addSubview:myLabel];
            return headerView;
        }else if(section==_tableDataArray.count-1){
            UILabel *myLabel = [[UILabel alloc] init];
            myLabel.frame = CGRectMake(5, 8, 320, 15);
            myLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_MEDIUM_15];
            myLabel.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_NEXT_BUTTON];
            myLabel.text  = [[Localized string:@"sent_to"] uppercaseString];
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
            headerView.backgroundColor = [UIColor whiteColor];
            [headerView addSubview:myLabel];
            return headerView;
        }else{
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
            headerView.backgroundColor = [UIColor grayColor];
            return headerView;
        }
    }
    return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (timelineType==TIMELINE_NOTIFICATION) {
        return 0.1;
    }else{
        return 23.0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (timelineType == TIMELINE_NEWS) {
        NSDictionary *tDict = _tableDataArray[indexPath.section][indexPath.row];
        
        if (_tableDataArray.count-2 == indexPath.section) {
            if (indexPath.row==0) {
                CGSize size = [tDict[@"news_text"] sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR]
                                              constrainedToSize:CGSizeMake(236, MAXFLOAT)
                                                  lineBreakMode:NSLineBreakByWordWrapping];
                
                if (((NSString*)tDict[@"img"]).length>0) {
                    return 217+size.height+5;
                }else{
                    return 97+size.height+5;
                }
            }else{
                return 60.0;
            }
            
            
        }if (_tableDataArray.count-1 == indexPath.section) {
            return 60.0;
        }else{
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
                if (height>50.0) {
                    return height+5.0;
                }else{
                    return 50.0;
                }
                
            }
        }
    }else if(timelineType == TIMELINE_NOTIFICATION){
        if ([_timelineDict[@"title"] isEqualToString:@""]) {
            if (webViewHeight+25>60) {
                return webViewHeight+25+173;
            }else{
                return 233.0;
            }
        }else{
            UITextView *dummyTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 236.0, 40.0)];
            dummyTextView.text = _timelineDict[@"msg"];
            CGSize goodSize = [dummyTextView sizeThatFits:CGSizeMake(236.0,MAXFLOAT)];
            
            if (goodSize.height>40) {
                return goodSize.height+193;
            }else{
                return 233.0;
            }
        }
        return 44.0;
    }
    
    
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (timelineType == TIMELINE_NEWS) {
        NSDictionary *tDict = _tableDataArray[indexPath.section][indexPath.row];
        if (_tableDataArray.count-2 == indexPath.section) {
                TimelineSentNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
                if (cell==nil) {
                    cell=[[TimelineSentNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                }
                
                cell.lblName.text =  ([_timelineDict[@"anonymous"] boolValue]?[NSString stringWithFormat:@"%@", [Localized string:@"anonymous"]]:[Tools getUserName]);
                cell.lblTitle.text = tDict[@"news_title"];
                NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *date = [formatter dateFromString:tDict[@"timestamp"]];
                [formatter setDateFormat:@"dd/MM/yyyy"];
                cell.lblDate.text = [NSString stringWithFormat:@"%@ %@", [Localized string:((AppDelegate*)[UIApplication sharedApplication].delegate).dicTimelineButt[tDict[@"type_id"]]], [formatter stringFromDate:date]];
                
                cell.lblDescription.text = tDict[@"news_text"];
                
                CGSize size = [tDict[@"news_text"] sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR] constrainedToSize:CGSizeMake(236, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                
                cell.CS_lblDescriptionHeight.constant = size.height+5;
                
                if (((NSString*)tDict[@"img"]).length>0) {
                    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(concurrentQueue, ^{
                        NSURL *url = [NSURL URLWithString:tDict[@"img"]];
                        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
                        if (image!=nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                cell.imgSample.image = image;
                                cell.imgSample.contentMode = UIViewContentModeScaleAspectFill;
                                cell.imgSample.clipsToBounds=YES;
                                if ([tDict[@"videoimg"] boolValue]) {
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
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
        }else if(_tableDataArray.count-1 == indexPath.section){
            SelectMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell==nil) {
                cell=[[SelectMediaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            }
            if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
            {
                cell.contentView.frame = cell.bounds;
                cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
            }
            
            cell.lblMediaName.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR];
            cell.lblMediaType.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR_15];
            
            cell.lblMediaName.text = tDict[@"medianame"];
            cell.lblMediaType.text = [[Localized string:appdelegate.dicMediaTypes[tDict[@"media_type"]]] uppercaseString];
            
            dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //this will start the image loading in bg
            dispatch_async(concurrentQueue, ^{
                if ([appdelegate.mediaImages objectForKey:tDict[@"id"]]==nil) {
                    NSURL *url = [NSURL URLWithString:tDict[@"media_icon"]];
                    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
                    if (image!=nil) {
                        [appdelegate.mediaImages setObject:image forKey:tDict[@"id"]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.imgMedia.image = [appdelegate.mediaImages objectForKey:tDict[@"id"]];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.imgMedia.image = [UIImage imageNamed:@"uploadphoto"];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgMedia.image = [appdelegate.mediaImages objectForKey:tDict[@"id"]];
                    });
                }
            });
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
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
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
                        cell.CS_lblViewContainerHeight.constant += cell.CS_lblDisclaimerHeight.constant +3;
                        
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
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        return cell;
                        
                    }else{
                        
                        TimelineUserReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userreplycell"];
                        if (cell==nil) {
                            cell=[[TimelineUserReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userreplycell"];
                        }
                        cell.lblName.text = ([_timelineDict[@"anonymous"] boolValue]?[NSString stringWithFormat:@"%@", [Localized string:@"anonymous"]]:tDict[@"name"]);
                        cell.lblDate.text =  [Tools getStringFromDateString:tDict[@"timestamp"] withFormat:@"dd/MM/yyyy"];
                        cell.lblMessage.text = tDict[@"message"];
                        cell.CS_lblMessageHeight.constant = ((CGSize)[self getHeightForText:tDict[@"message"]]).height;
                        cell.CS_lblViewContainerHeight.constant += cell.CS_lblMessageHeight.constant+3;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    
                }
                    break;
                default:{
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
                    if (cell==nil) {
                        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                    }
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
                    break;
            }
        }
    }else if(timelineType==TIMELINE_NOTIFICATION){
        TimeLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell==nil) {
            cell=[[TimeLineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.alertImage.hidden=YES;
        if ([_timelineDict[@"title"] isEqualToString:@""]){
            cell.lblTitle.hidden=YES;
            cell.txtDescription.hidden=YES;
            cell.webView.hidden=NO;
            cell.webView.delegate = self;
            
            if ([cell.webView respondsToSelector:@selector(scrollView)]) {
                cell.webView.scrollView.scrollEnabled = NO;
            } else {
                for (id subview in cell.webView.subviews)
                    if ([[subview class] isSubclassOfClass: [UIScrollView class]])
                        ((UIScrollView *)subview).scrollEnabled = NO;
            }
            
            NSData *data = [_timelineDict[@"msg"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:NULL];
            
            
            [cell.webView loadData:[_timelineDict[@"msg"] dataUsingEncoding:NSUTF8StringEncoding]
                          MIMEType:@"text/html"
                  textEncodingName:@"UTF-8"
                           baseURL:nil];
           // [cell.webView loadHTMLString:_timelineDict[@"msg"] baseURL:nil];
            cell.lblHeader.text = [Tools getStringFromDateString:_timelineDict[@"timestamp"] withFormat:@"dd/MM/yyyy"];
            cell.imgSample.image = [UIImage imageNamed:@"colombiotimeline"];
            cell.CS_webViewHeight.constant=webViewHeight+25;
        }else{
            cell.lblTitle.text = _timelineDict[@"title"];
            cell.lblHeader.text = [Tools getStringFromDateString:_timelineDict[@"timestamp"] withFormat:@"dd/MM/yyyy"];
            cell.txtDescription.text = [NSString stringWithFormat:@"%@",_timelineDict[@"msg"]];
            cell.imgSample.image = [UIImage imageNamed:@"colombiotimeline"];
            [cell.txtDescription sizeToFit];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
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
    return size.height+5;
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
                if ([tDict[@"detailtype"] longValue]==3 || [tDict[@"detailtype"] longValue]==2) {
                    addWriteReply=YES;
                }
            }
        }
        if (addWriteReply) {
            NSDictionary *dict = @{@"detailtype":@4, @"mid":@(mediaid), @"nid":_timelineDict[@"news_id"]};
            [tArray addObject:dict];
        }
        if (tArray.count>0) {
            [_tableDataArray addObject:tArray];
        }
        
    }
    
    //add sent news
    NSMutableArray *tArray = [[NSMutableArray alloc] init];
    [tArray addObject:_timelineDict];
    [_tableDataArray addObject:tArray];

    //add media
    tArray = [[NSMutableArray alloc] init];
    AppDelegate *appdelegte = (AppDelegate*)[UIApplication sharedApplication].delegate;
    for (NSString *mediaid in mediaList) {
       NSString *sql = [NSString stringWithFormat:@"select id, name as medianame, media_type, media_icon from media_list where id = %ld ", (long)[mediaid integerValue]];
       [tArray  addObject:[appdelegte.db getRowForSQL:sql]];
    }
    
    //update db
    if ([_timelineDict[@"type"] longLongValue] == 1) {
        [self setNotificationsToRead:[_timelineDict[@"news_id"] longValue]];
    }else if ([_timelineDict[@"type"] longLongValue] == 2){
        [self setSystemNotificationToRead:[_timelineDict[@"id"] longValue]];
    }
    
    
    [_tableDataArray addObject:tArray];
    [spinner removeCustomSpinner];
    [_tblView reloadData];
    if ([self.delegate respondsToSelector:@selector(timelineDetailsDidFinishProcessing)]) {
        [self.delegate timelineDetailsDidFinishProcessing];
    }
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
    NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&coid=%ld&status=%ld",signedRequest, (long)offer_id, (long)offer_status];
    
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
    NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&nid=%ld&mid=%ld&message=%@",signedRequest, (long)newsid, (long)mid, strReply];
    
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

#pragma mark Update DB
- (void)setNotificationsToRead:(NSInteger)timelineid{
    /*NSString *sql =[NSString stringWithFormat:@"SELECT id from TIMELINE_NOTIFICATIONS where nid = ='%ld'", (long)timelineid];
    NSArray *tArray = [appdelegate.db getColForSQL:sql];
    for(NSNumber *tID in tArray){
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM TIMELINE_NOTIFICATIONS WHERE id = '%ld'", (long)[tID integerValue]];
        NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
        tDBDict[@"is_read"]=@1;
        if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
            tDBDict[@"id"]=tID;
            [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE_NOTIFICATIONS"];
        }else{
            [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE_NOTIFICATIONS" where:[NSString stringWithFormat:@" id='%ld'", (long)[tID integerValue]]];
        }
    }*/

    NSDictionary *tDict = @{@"is_read":@TRUE};
    [appdelegate.db updateDictionary:tDict forTable:@"TIMELINE_NOTIFICATIONS" where:[NSString stringWithFormat:@" nid='%ld'", (long)timelineid]];
    [self setNotificationBadge];
}

- (void)setSystemNotificationToRead:(NSInteger)id{
        /*NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM TIMELINE_NOTIFICATIONS WHERE id = '%ld'", (long)id];
        NSMutableDictionary *tDBDict = [[NSMutableDictionary alloc] init];
        tDBDict[@"is_read"]=@1;
        if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
            tDBDict[@"id"]=@(id);
            [appdelegate.db insertDictionaryWithoutColumnCheck:tDBDict forTable:@"TIMELINE_NOTIFICATIONS"];
        }else{
            [appdelegate.db updateDictionary:tDBDict forTable:@"TIMELINE_NOTIFICATIONS" where:[NSString stringWithFormat:@" id='%ld'", (long)id]];
        }*/ 
    
    NSDictionary *tDict = @{@"is_read":@TRUE};
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
