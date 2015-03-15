//
//  SelectMediaViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 06/03/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SelectMediaViewController.h"
#import "SelectMediaCell.h"
#import "Loading.h"
#import "Tools.h"
#import "Messages.h"
#import "AppDelegate.h"

@interface SelectMediaViewController ()
{
    Loading *spinner;
    AppDelegate *appdelegate;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (strong, nonatomic) NSArray *media;
@property (strong, nonatomic) NSArray *selectedCountries;
@property (strong, nonatomic) NSMutableArray *filteredMedia;
@property (strong, nonatomic) NSMutableArray *imagesLoaded;


@end

@implementation SelectMediaViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.title = [Localized string:@"select_media"];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedMedia = [[NSMutableArray alloc] init];
    _tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblView.alwaysBounceVertical = NO;
    appdelegate = [[UIApplication sharedApplication] delegate];
    _selectedCountries = [[NSArray alloc] init];
    _selectedCountries = [self loadSelectedCountries];
    [self loadMedia];
}

- (void)viewWillAppear:(BOOL)animated{
    if ([self selectedCountriesChanged]) {
        [self loadMedia];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _filteredMedia.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_selectedMedia containsObject:_filteredMedia[indexPath.row][@"id"] ]) {
        return ((CGSize)[self getDescriptionHeightForText:_filteredMedia[indexPath.row][@"description"]]).height + 60.0;
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
    cell.lblMediaName.text = _filteredMedia[indexPath.row][@"name"];
    //cell.lblMediaType.text = _filteredMedia[indexPath.row][@"media_type"];
    if ([_selectedMedia containsObject:_filteredMedia[indexPath.row][@"id"] ]) {
        cell.lblMediaDescription.text = _filteredMedia[indexPath.row][@"description"];
    }
    if ([_selectedMedia containsObject:_filteredMedia[indexPath.row][@"id"]]) {
        cell.imgSelected.hidden = NO;
        cell.imgMedia.alpha = 1;
        cell.lblMediaName.alpha = 1;
    }else{
        cell.imgSelected.hidden = YES;
        cell.imgMedia.alpha = 0.3;
        cell.lblMediaName.alpha = 0.3;
    }

    //TODO dodati da se ne raspetljava kod samog odabira medija (upload)
    if ([_selectedMedia containsObject:_filteredMedia[indexPath.row][@"status"]]) {
        cell.CS_DescriptionHeight.constant = ((CGSize)[self getDescriptionHeightForText:_filteredMedia[indexPath.row][@"description"]]).height;
    }
    
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //this will start the image loading in bg
    dispatch_async(concurrentQueue, ^{
        if ([appdelegate.mediaImages objectForKey:_filteredMedia[indexPath.row][@"id"]]==nil) {
            NSURL *url = [NSURL URLWithString:_filteredMedia[indexPath.row][@"media_icon"]];
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
            if (image!=nil) {
                [appdelegate.mediaImages setObject:image forKey:_filteredMedia[indexPath.row][@"id"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imgMedia.image = [appdelegate.mediaImages objectForKey:_filteredMedia[indexPath.row][@"id"]];
                });
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imgMedia.image = [appdelegate.mediaImages objectForKey:_filteredMedia[indexPath.row][@"id"]];
        });
    });

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_selectedMedia containsObject:_filteredMedia[indexPath.row][@"id"] ]) {
        [_selectedMedia removeObject:_filteredMedia[indexPath.row][@"id"]];
        _filteredMedia[indexPath.row][@"status"] = @0;
        for(NSMutableDictionary *media in _media){
            if ([media[@"id"] integerValue] == [_filteredMedia[indexPath.row][@"id"] integerValue]) {
                media[@"status"] = @0;
            }
        }
    }else{
        [_selectedMedia addObject:_media[indexPath.row][@"id"]];
        _filteredMedia[indexPath.row][@"status"] = @1;
        for(NSMutableDictionary *media in _media){
            if ([media[@"id"] integerValue] == [_filteredMedia[indexPath.row][@"id"] integerValue]) {
                media[@"status"] = @1;
            }
        }
    }
    NSArray *indexPaths = [[NSMutableArray alloc]initWithObjects:indexPath, nil];
    [_tblView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSMutableDictionary *tDict = [[NSMutableDictionary alloc] init];
    tDict[@"status"] = _filteredMedia[indexPath.row][@"status"];
    tDict[@"media_id"] = @([_filteredMedia[indexPath.row][@"id"] integerValue]);
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM selected_media WHERE media_id = '%d'", [_filteredMedia[indexPath.row][@"id"] intValue]];
    if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
        [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"SELECTED_MEDIA"];
    }else{
        [appdelegate.db updateDictionary:tDict forTable:@"SELECTED_MEDIA" where:[NSString stringWithFormat:@" media_id='%d'", [_filteredMedia[indexPath.row][@"media_id"] intValue]]];
    }
}

- (CGSize)getDescriptionHeightForText:(NSString*)txt{
    return [txt sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT_SMALL]
                            constrainedToSize:CGSizeMake(_tblView.frame.size.width, MAXFLOAT)
                                lineBreakMode:NSLineBreakByWordWrapping];
}

#pragma mark TextField
-(IBAction)textFieldDidChange:(UITextField *)textField{
    if (textField.text.length>1) {
        [self filterMedia:textField.text];
    }else{
        _filteredMedia = [[NSMutableArray alloc] initWithArray:_media];
    }
    [_tblView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark LoadData
- (NSArray*)loadSelectedCountries{
    NSString *sql = @"SELECT c_id FROM selected_countries where status = 1";
    return (NSArray*)[appdelegate.db getAllForSQL:sql];
}

- (BOOL)selectedCountriesChanged{
    NSArray *tempArray = [self loadSelectedCountries];
    tempArray = [tempArray sortedArrayUsingSelector:@selector(compare:)];
    _selectedCountries = [_selectedCountries sortedArrayUsingSelector:@selector(compare:)];
    
    if([_selectedCountries isEqualToArray:tempArray]){
        return NO;
    }else{
        _selectedCountries = tempArray;
        return YES;
    }
}


- (void)loadMedia{
    [spinner startCustomSpinner:self.view spinMessage:@""];
    NSString *lastTimestamp = ([[NSUserDefaults standardUserDefaults] stringForKey:MEDIA_TIMESTAMP]!=nil?[[NSUserDefaults standardUserDefaults] stringForKey:MEDIA_TIMESTAMP]:@"0");
    
    ColombioServiceCommunicator *csc = [[ColombioServiceCommunicator alloc] init];
    if (_selectedCountries.count>0) {
        NSData *jsonDataMedia = [NSJSONSerialization dataWithJSONObject:_selectedCountries options:NSJSONWritingPrettyPrinted error:nil];
        NSString *selCountries = [[NSString alloc]initWithData:jsonDataMedia encoding:NSUTF8StringEncoding];
        [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_config/get_media/", BASE_URL] httpBody:[NSString stringWithFormat:@"sync_time=%@&cid=%@",lastTimestamp, selCountries]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    }else{
        [csc sendAsyncHttp:[NSString stringWithFormat:@"%@/api_config/get_media/", BASE_URL] httpBody:[NSString stringWithFormat:@"sync_time=%@",lastTimestamp]cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    }
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error==nil&&data!=nil){
                [self prepareMedia:data response:response];
            }
            else{
                [Messages showErrorMsg:@"error_web_request"];
            }
            //timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(toggleSpinnerOff) userInfo:nil repeats:NO];
        });
    }];
}

- (void)prepareMedia:(NSData *)data response:(NSURLResponse*)response{
    Boolean isDataChanged=true;
    NSDictionary *dataWsResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *keys =[dataWsResponse allKeys];
    for(NSString *key in keys){
        //Nije mijenjan popis medija
        if(!strcmp("s", key.UTF8String)){
            isDataChanged=false;
            break;
        }
    }
    //Ako je mijenjan popis medija
    if(isDataChanged){
        appdelegate = [[UIApplication sharedApplication] delegate];
        [appdelegate.db clearTable:@"MEDIA_LIST"];
        
        NSString *changeTimestamp= [NSString stringWithFormat:@"%@",[dataWsResponse objectForKey:@"change_timestamp"]];
        [[NSUserDefaults standardUserDefaults] setObject:changeTimestamp forKey:MEDIA_TIMESTAMP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        for(NSDictionary *tDict in dataWsResponse[@"data"]){
            [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"MEDIA_LIST"];
            /*NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM media_list WHERE id = '%d'", [tDict[@"id"] intValue]];
            if ([[appdelegate.db getColForSQL:sql] integerValue] == 0) {
                [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"MEDIA_LIST"];
            }else{
                [appdelegate.db updateDictionary:tDict forTable:@"MEDIA_LIST" where:[NSString stringWithFormat:@" id='%d'", [tDict[@"id"] intValue]]];
            }*/
        }
    }
    
    NSString *sql = @"SELECT ml.id as id, country_id, media_icon, description, media_type, name, ifnull(sm.status, 0) as status FROM media_list ml LEFT OUTER JOIN selected_media sm on sm.media_id = ml.id";
    _media = [appdelegate.db getAllForSQL:sql];
    _filteredMedia = [[NSMutableArray alloc] initWithArray:_media];
    for(NSDictionary *media in _media){
        if ([media[@"status"] boolValue]) {
            [_selectedMedia addObject:media[@"id"]];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tblView reloadData];
    });
}

#pragma mark Filter Media
- (void)filterMedia:(NSString*)searchCondition{
    _filteredMedia=[[NSMutableArray alloc] init];
    for (NSDictionary *media in _media){
        if ([[media[@"name"] lowercaseString] containsString:[searchCondition lowercaseString]]) {
            [_filteredMedia addObject:media];
        }
    }
}

#pragma mark Validation
- (BOOL)validateMedia{
    if (_selectedMedia.count>0) {
        return YES;
    }else{
        return NO;
    }
}
@end
