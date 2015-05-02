//
//  SimpleMediaSelectViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 24/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SimpleMediaSelectViewController.h"
#import "Loading.h"
#import "AppDelegate.h"
#import "SelectMediaCell.h"
#import "CustomHeaderView.h"
#import "Messages.h"

@interface SimpleMediaSelectViewController ()<CustomHeaderViewDelegate>
{
    Loading *spinner;
    AppDelegate *appdelegate;
    ColombioServiceCommunicator *csc;
    NSString *mediaName;
}
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeader;

@property (strong, nonatomic) NSArray *media;
@property (strong, nonatomic) NSMutableArray *selectedMedia;
@property (strong, nonatomic) NSArray *selectedCountries;
@property (strong, nonatomic) NSMutableArray *favMedia;
@property (strong, nonatomic) NSArray *favMediaID;
@property (strong, nonatomic) NSArray *otherMedia;
@property (strong, nonatomic) NSArray *filteredOtherMedia;
@property (strong, nonatomic) NSArray *filteredFavMedia;
@property (strong, nonatomic) NSMutableArray *mergedMedia;

@property (assign, nonatomic) BOOL isCallMedia;

@end

@implementation SimpleMediaSelectViewController

- (instancetype)initForCallMedia:(BOOL)callMedia{
    self = [super init];
    if (self) {
        _isCallMedia = callMedia;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblView.alwaysBounceVertical = NO;
    
    _selectedMedia = [[NSMutableArray alloc] init];
    _selectedCountries = [[NSArray alloc] init];
    _selectedCountries = [self loadSelectedCountries];
    
    spinner = [[Loading alloc] init];
    [spinner startCustomSpinner2:self.view spinMessage:@""];
    
    csc = [ColombioServiceCommunicator sharedManager];
    csc.delegate=self;
    [csc fetchFavoriteMedia];
}

- (void)viewWillAppear:(BOOL)animated{
    _customHeader.headerTitle = [Localized string:@"btn_call"];
    if (!_isCallMedia) {
        _customHeader.nextButtonText = [Localized string:@"header_save"];
        _customHeader.btnBack.hidden=NO;
    }else{
        _customHeader.btnBack.hidden=YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnNextClicked{
    [self uploadFavMedia];
}


#pragma mark Table View Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_filteredFavMedia.count>0 && _filteredOtherMedia.count>0) {
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_filteredFavMedia.count>0 && _filteredOtherMedia.count>0) {
        if (section==0) {
            return _filteredFavMedia.count;
        }else{
            return _filteredOtherMedia.count;
        }
    }else{
        if (_filteredOtherMedia.count>0) {
            return _filteredOtherMedia.count;
        }else{
            return _filteredFavMedia.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_mergedMedia.count) {
        return 20.0;
    }else{
        return 0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_mergedMedia.count) {
        UILabel *myLabel = [[UILabel alloc] init];
        myLabel.frame = CGRectMake(5, 8, 320, 20);
        myLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_MEDIUM_15];
        myLabel.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_NEXT_BUTTON];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 25)];
        headerView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:myLabel];
        if (_filteredFavMedia.count>0 && _filteredOtherMedia.count>0) {
            if (section==0) {
                myLabel.text  = [Localized string:@"select_media_favorites"];
            }else{
                myLabel.text  = [Localized string:@"select_media_othermedia"];
            }
        }else{
            if (_filteredOtherMedia.count>0) {
                myLabel.text  = [Localized string:@"select_media_othermedia"];
            }else if(_filteredFavMedia.count>0){
                myLabel.text  = [Localized string:@"select_media_favorites"];
            }else{
                return nil;
            }
        }
        return headerView;
    }
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_mergedMedia[indexPath.section][indexPath.row] && [_selectedMedia containsObject:_mergedMedia[indexPath.section][indexPath.row][@"id"]] && !_isCallMedia) {
        return ((CGSize)[self getDescriptionHeightForText:_mergedMedia[indexPath.section][indexPath.row][@"description"]]).height + 60.0;
    }
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[SelectMediaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    if (_isCallMedia) {
        cell.lblMediaName.text = _mergedMedia[indexPath.section][indexPath.row][@"name"];
        cell.lblMediaType.text = [[Localized string:appdelegate.dicMediaTypes[_mergedMedia[indexPath.section][indexPath.row][@"media_type"]]] uppercaseString];
        
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //this will start the image loading in bg
        dispatch_async(concurrentQueue, ^{
            if ([appdelegate.mediaImages objectForKey:_mergedMedia[indexPath.section][indexPath.row][@"id"]]==nil) {
                NSURL *url = [NSURL URLWithString:_mergedMedia[indexPath.section][indexPath.row][@"media_icon"]];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
                if (image!=nil) {
                    [appdelegate.mediaImages setObject:image forKey:_mergedMedia[indexPath.section][indexPath.row][@"id"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgMedia.image = [appdelegate.mediaImages objectForKey:_mergedMedia[indexPath.section][indexPath.row][@"id"]];
                    });
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imgMedia.image = [appdelegate.mediaImages objectForKey:_mergedMedia[indexPath.section][indexPath.row][@"id"]];
                });
            }
        });
        
    }else{
        cell.lblMediaName.text = _mergedMedia[indexPath.section][indexPath.row][@"name"];
        cell.lblMediaType.text = [[Localized string:appdelegate.dicMediaTypes[_mergedMedia[indexPath.section][indexPath.row][@"media_type"]]] uppercaseString];
        
        if ([_selectedMedia containsObject:_mergedMedia[indexPath.section][indexPath.row][@"id"]] && !_isCallMedia) {
            cell.lblMediaDescription.text = _mergedMedia[indexPath.section][indexPath.row][@"description"];
            cell.CS_DescriptionHeight.constant = ((CGSize)[self getDescriptionHeightForText:_mergedMedia[indexPath.section][indexPath.row][@"description"]]).height;
        }
        
        if ([_selectedMedia containsObject:_mergedMedia[indexPath.section][indexPath.row][@"id"]]) {
            cell.imgSelected.hidden = NO;
        }else{
            cell.imgSelected.hidden = YES;
        }
        
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //this will start the image loading in bg
        dispatch_async(concurrentQueue, ^{
            if ([appdelegate.mediaImages objectForKey:_mergedMedia[indexPath.section][indexPath.row][@"id"]]==nil) {
                NSURL *url = [NSURL URLWithString:_mergedMedia[indexPath.section][indexPath.row][@"media_icon"]];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
                if (image!=nil) {
                    [appdelegate.mediaImages setObject:image forKey:_mergedMedia[indexPath.section][indexPath.row][@"id"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgMedia.image = [appdelegate.mediaImages objectForKey:_mergedMedia[indexPath.section][indexPath.row][@"id"]];
                    });
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imgMedia.image = [appdelegate.mediaImages objectForKey:_mergedMedia[indexPath.section][indexPath.row][@"id"]];
            });
        });
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_isCallMedia){
        [spinner startCustomSpinner2:self.view spinMessage:@""];
        mediaName = _mergedMedia[indexPath.section][indexPath.row][@"name"];
        [csc fetchMediaPhoneNumber:[_mergedMedia[indexPath.section][indexPath.row][@"id"] integerValue]];
    }else{
        if ([_selectedMedia containsObject:_mergedMedia[indexPath.section][indexPath.row][@"id"] ]) {
         [_selectedMedia removeObject:_mergedMedia[indexPath.section][indexPath.row][@"id"]];
         _mergedMedia[indexPath.section][indexPath.row][@"status"] = @0;
         }else{
             [_selectedMedia addObject:_mergedMedia[indexPath.section][indexPath.row][@"id"]];
             _mergedMedia[indexPath.section][indexPath.row][@"status"] = @1;
         }
         NSArray *indexPaths = [[NSMutableArray alloc]initWithObjects:indexPath, nil];
         [_tblView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
         NSMutableDictionary *tDict = [[NSMutableDictionary alloc] init];
         //tDict[@"status"] = _filteredMedia[indexPath.row][@"status"];
         tDict[@"media_id"] = @([_mergedMedia[indexPath.section][indexPath.row][@"id"] integerValue]);
         NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM selected_media WHERE media_id = '%d'", [_mergedMedia[indexPath.section][indexPath.row][@"id"] intValue]];
         if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
             [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"SELECTED_MEDIA"];
         }else{
             [appdelegate.db updateDictionary:tDict forTable:@"SELECTED_MEDIA" where:[NSString stringWithFormat:@" media_id='%d'", [_mergedMedia[indexPath.section][indexPath.row][@"media_id"] intValue]]];
         }
    }
}



#pragma mark CSC Delegate
- (void)didFetchFavoriteMedia:(NSArray *)favMediaId{
    _favMediaID = favMediaId;
    [csc fetchMedia];
}

- (void)didFetchMedia{
    NSString *sql = @"SELECT ml.id as id, country_id, media_icon, description, media_type, name, ifnull(sm.status, 0) as status FROM media_list ml LEFT OUTER JOIN selected_media sm on sm.media_id = ml.id";
    _media = [appdelegate.db getAllForSQL:sql];
    [self setupMediaData];
}

- (void)didFetchMediaNumber:(NSString *)mediaPhoneNumber{
    [spinner removeCustomSpinner];
    UIAlertView *info = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@",[Localized string:@"call"], mediaName] message:mediaPhoneNumber delegate:self cancelButtonTitle:[Localized string:@"cancel"] otherButtonTitles:[Localized string:@"call"], nil];
    [info show];
}

- (void)fetchingFailedWithError:(NSError *)error{
    [spinner removeCustomSpinner];
}

#pragma mark LoadData
- (NSArray*)loadSelectedCountries{
    NSString *sql = @"SELECT c_id FROM selected_countries where status = 1";
    return (NSArray*)[appdelegate.db getAllForSQL:sql];
}

- (void)setupMediaData{
    _favMedia = [[NSMutableArray alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_media];
    for(NSDictionary *media in _media){
        if ([_favMediaID containsObject:media[@"id"]]) {
            [tempArray removeObject:media];
            [_favMedia addObject:media];
        }
    }
    _otherMedia = [self addColombioOnTop:tempArray];
    _filteredOtherMedia = _otherMedia;
    _filteredFavMedia = [self addColombioOnTop:_favMedia];
    //[_selectedMedia addObjectsFromArray:_favMediaID];
    _mergedMedia = [[NSMutableArray alloc] initWithObjects:_filteredFavMedia, _filteredOtherMedia, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tblView reloadData];
        [spinner removeCustomSpinner];
    });
}

- (NSArray*)addColombioOnTop:(NSMutableArray*)originalArray{
    NSMutableArray *tArray = [[NSMutableArray alloc] initWithArray:originalArray];
    int indexToMove=-1;
    NSMutableDictionary *objectToMove = [[NSMutableDictionary alloc] init];
    for (int i=0; i<tArray.count; i++) {
        if ([tArray[i][@"name"] isEqualToString:@"Colombio"]) {
            indexToMove = i;
            objectToMove = tArray[i];
        }
    }
    if (indexToMove!=-1) {
        [tArray removeObjectAtIndex:indexToMove];
        [tArray insertObject:objectToMove atIndex:0];
    }
    return (NSArray*)tArray;
}

- (CGSize)getDescriptionHeightForText:(NSString*)txt{
    return [txt sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT_SMALL]
           constrainedToSize:CGSizeMake(_tblView.frame.size.width, MAXFLOAT)
               lineBreakMode:NSLineBreakByWordWrapping];
}

#pragma mark Save Media
- (void)uploadFavMedia{
    NSString *signedRequest = [ColombioServiceCommunicator getSignedRequest];
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/update_fav_media/", BASE_URL];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_selectedMedia options:NSJSONWritingPrettyPrinted error:&error];
    NSString *selectedMedia = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *httpBody = [NSString stringWithFormat:@"signed_req=%@&media=%@",signedRequest, selectedMedia];
    [csc sendAsyncHttp:url_str httpBody:httpBody cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error==nil&&data!=nil){
            NSDictionary *response=nil;
            response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if(!strcmp("1",((NSString*)[response objectForKey:@"s"]).UTF8String)){
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else{
            [Messages showErrorMsg:@"error_web_request"];
        }
    }];
}

#pragma mark TextField
-(IBAction)textFieldDidChange:(UITextField *)textField{
    @synchronized(self) {
        if (textField.text.length>0) {
            [self filterMedia:textField.text];
        }else{
            _filteredFavMedia = [[NSMutableArray alloc] initWithArray:_favMedia];
            _filteredOtherMedia = [[NSMutableArray alloc] initWithArray:_otherMedia];
            
            _mergedMedia = [[NSMutableArray alloc] init];
            if (_filteredFavMedia.count>0) {
                [_mergedMedia addObject:_filteredFavMedia];
            }
            if (_filteredOtherMedia.count>0) {
                [_mergedMedia addObject:_filteredOtherMedia];
            }
        }
        [_tblView reloadData];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Filter Media
- (void)filterMedia:(NSString*)searchCondition{
    _filteredFavMedia=[[NSArray alloc] init];
    _filteredOtherMedia = [[NSArray alloc] init];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchCondition];
    _filteredFavMedia = [_favMedia filteredArrayUsingPredicate:resultPredicate];
    _filteredOtherMedia = [_otherMedia filteredArrayUsingPredicate:resultPredicate];
    _mergedMedia = [[NSMutableArray alloc] init];
    if (_filteredFavMedia.count>0) {
        [_mergedMedia addObject:_filteredFavMedia];
    }
    if (_filteredOtherMedia.count>0) {
        [_mergedMedia addObject:_filteredOtherMedia];
    }
}

- (IBAction)btnDismissSearchSelected:(id)sender{
    @synchronized(self){
        _txtSearch.text=@"";
        _filteredFavMedia = [[NSMutableArray alloc] initWithArray:_favMedia];
        _filteredOtherMedia = [[NSMutableArray alloc] initWithArray:_otherMedia];
        _mergedMedia = [[NSMutableArray alloc] initWithObjects:_filteredFavMedia, _filteredOtherMedia, nil];
        [_tblView reloadData];
    }
}


#pragma mark Keyboard

- (void)keyboardUp:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    UIEdgeInsets contentInset = _tblView.contentInset;
    contentInset.bottom = keyboardRect.size.height;
    _tblView.contentInset = contentInset;
}

- (void)keyboardDown:(NSNotification*)notification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _tblView.contentInset = contentInsets;
    _tblView.scrollIndicatorInsets = contentInsets;
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        NSString *phoneNumber = [@"tell://" stringByAppendingString:alertView.message];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}


@end
