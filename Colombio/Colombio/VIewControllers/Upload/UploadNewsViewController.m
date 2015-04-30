//
//  UploadNewsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 02/02/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UploadNewsViewController.h"
#import "NewsData.h"
#import "AppDelegate.h"
#import "ColombioServiceCommunicator.h"

@interface UploadNewsViewController ()
{
    NSInteger uploadCount;
    AppDelegate *appDelegate;
    NSString *news_id;
    NSString *result;
    NSInteger localNewsID;
    NSUInteger totalUploadFileSize;
    NSUInteger bytesSent;
}
@property (weak, nonatomic) IBOutlet UITextView *txtDidYouKnow;
@property (weak, nonatomic) IBOutlet UIImageView *imgLoading;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadPercentage;
@property (weak, nonatomic) IBOutlet UILabel *lblUploading;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadCount;
@property (weak, nonatomic) IBOutlet UIImageView *imgInfo;

@property (strong, nonatomic) NewsData *newsData;
@end

@implementation UploadNewsViewController

- (instancetype)initWithNewsData:(NewsData*)data{
    self = [super init];
    if (self) {
        _newsData = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    uploadCount=1;
    totalUploadFileSize = [self getTotalFileSize];
    bytesSent=0;
    _txtDidYouKnow.userInteractionEnabled=NO;
    [self spinLoading];
    [self uploadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Upload Data
- (void)uploadData{
    result = [ColombioServiceCommunicator getSignedRequest];
    if (result.length==0) {
        [_imgLoading.layer removeAllAnimations];
        [self fail];
        return;
    }
    
    ColombioServiceCommunicator *csc = [ColombioServiceCommunicator sharedManager];
    
    NSString *url_str = [NSString stringWithFormat:@"%@/api_content/add_news/", BASE_URL];
    NSDictionary *loc = @{@"lat":[NSString stringWithFormat:@"%f", _newsData.latitude],@"lng":[NSString stringWithFormat:@"%f", _newsData.longitude]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:loc options:NSJSONWritingPrettyPrinted error:&error];
    NSString *location = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *jsonDataTags = [NSJSONSerialization dataWithJSONObject:_newsData.tags options:NSJSONWritingPrettyPrinted error:&error];
    NSString *arTagsUpload = [[NSString alloc]initWithData:jsonDataTags encoding:NSUTF8StringEncoding];
    
    NSData *jsonDataMedia = [NSJSONSerialization dataWithJSONObject:_newsData.media options:NSJSONWritingPrettyPrinted error:nil];
    NSString *arMediaUpload = [[NSString alloc]initWithData:jsonDataMedia encoding:NSUTF8StringEncoding];
    
    //TODO chekirati bool crowdreporter info
    NSString *be_credited=[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:_newsData.be_credited]];
    NSString *whisperMode=[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:_newsData.prot]];
    NSString *be_contacted=[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:_newsData.be_contacted]];
    NSString *sell=[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:_newsData.sell]];
    
    NSString *httpBody;
    
    if(_newsData.did == 0){
        httpBody = [NSString stringWithFormat:@"signed_req=%@&title=%@&content=%@&loc=%@&prot=%@&cost=%f&be_credited=%@&be_contacted=%@&tags=%@&media=%@&type_id=%@&contact_data[contact_phone]=%@&sell=%@",result,_newsData.title,_newsData.content,location,whisperMode,_newsData.price,be_credited,be_contacted,arTagsUpload,arMediaUpload,[NSString stringWithFormat:@"%ld",(long)_newsData.type_id],_newsData.phone_number, sell];
    }
    else{
        httpBody = [NSString stringWithFormat:@"signed_req=%@&title=%@&content=%@&loc=%@&prot=%@&cost=%f&be_credited=%@&be_contacted=%@&tags=%@&req_id=%ld&media=%@&type_id=%@&contact_data[contact_phone]=%@&sell=%@",result,_newsData.title,_newsData.content,location,whisperMode,_newsData.price,be_credited,be_contacted,arTagsUpload,(long)_newsData.did,arMediaUpload,[NSString stringWithFormat:@"%ld",(long)_newsData.type_id],_newsData.phone_number, sell];
    }
    
    [csc sendAsyncHttp:url_str httpBody:httpBody cache:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    [NSURLConnection sendAsynchronousRequest:csc.request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(error==nil&&data!=nil){
                NSDictionary *response=nil;
                response =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                if(!strcmp("1",((NSString*)[response objectForKey:@"s"]).UTF8String)){
                    news_id = [response objectForKey:@"news_id"];
                    [self saveDataToDB];
                    if(_newsData.images.count>0){
                        /**
                        ** after we send textual data and if everything is ok, we can start sending media files we selected.
                        **/
                        [self uploadFile:(int)uploadCount-1];
                    }
                    else {
                        _lblUploadPercentage.text=@"100%";
                        [_imgLoading.layer removeAllAnimations];
                        [self success];
                        return;
                    }
                }
            }
            else{
                [_imgLoading.layer removeAllAnimations];
                [self fail];
                return;
            }
        });
    }];
   
    
}

//gets total file size for progress purposes
- (NSUInteger)getTotalFileSize{
    NSUInteger totalFileSize=0;
    for(ALAsset *asset in _newsData.images){
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        UIImage *img = [UIImage imageWithCGImage:iref];
        NSData *imgData;
        if([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]){
            Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
            imgData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        }
        else{
            imgData = UIImageJPEGRepresentation(img, 1.0);
        }
        totalFileSize += imgData.length;
    }
    return totalFileSize;
}

- (void)uploadFile:(int)index{
    ALAsset *img = _newsData.images[index];
    
    ALAssetRepresentation *rep = [img defaultRepresentation];
    CGImageRef iref = [rep fullResolutionImage];
    NSString *name=[rep filename];
    if(iref){
        UIImage *obj = [UIImage imageWithCGImage:iref];
        NSString *url_str = [NSString stringWithFormat:@"%@/api_upload/upload_file/", BASE_URL_IMAGES];
        NSURL *wigiURL = [[NSURL alloc] initWithString:url_str];
        // create the connection
        NSMutableURLRequest *wigiRequest = [NSMutableURLRequest requestWithURL:wigiURL
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:60.0];
        
        // change type to POST (default is GET)
        [wigiRequest setHTTPMethod:@"POST"];
        // just some random text that will never occur in the body
        NSString *stringBoundary = @"0xKhTmLbOuNdArY---This_Is_ThE_BoUnDaRyy---pqo";
        // header value
        NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                                    stringBoundary];
        // set header
        [wigiRequest addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
        //add body
        NSMutableData *postBody = [NSMutableData data];
        NSLog(@"body made");
        //SID param
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"sid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //SignedReg param
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"signed_req\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[result dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //NID param
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"nid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[news_id dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //image param
        // get the image data from main bundle directly into NSData object
        NSData *imgData;
        if([[img valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]){
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"video\"; filename=\"%@\"\r\n",name] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            ALAssetRepresentation *rep = [img defaultRepresentation];
            Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
            imgData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        }
        else{
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"img\"; filename=\"%@\"\r\n",name] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            imgData = UIImageJPEGRepresentation(obj, 1.0);
        }
        // add it to body
        [postBody appendData:imgData];
        [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"message added");
        // final boundary
        [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // add body to post
        [wigiRequest setHTTPBody:postBody];
        NSLog(@"body set");
        // pointers to some necessary objects
        // synchronous filling of data from HTTP POST response
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread code goes in here
            [self uploadMedia:wigiRequest];
        });
    }
}

- (void)uploadMedia:(NSURLRequest*)wigiRequest{
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:wigiRequest delegate:self];
}

#pragma mark Action

- (void)spinLoading{
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration=2.0;
    fullRotation.repeatCount=INT32_MAX;
    [_imgLoading.layer addAnimation:fullRotation forKey:@"360"];
}

- (void)fail{
    [_imgInfo setHidden:NO];
    _lblUploadPercentage.hidden=YES;
    _imgInfo.image = [UIImage imageNamed:@"failicon.png"];
    _lblUploading.text=[Localized string:@"send_failed"];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(backToHome) userInfo:nil repeats:NO];
}

- (void)success{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(backToHome) userInfo:nil repeats:NO];
    [_imgInfo setHidden:NO];
    _lblUploadPercentage.hidden=YES;
    _imgInfo.image = [UIImage imageNamed:@"pass.png"];
    _lblUploading.text = [Localized string:@"send_success"];
}

- (void)navigateBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backToHome{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark Connection Delegate
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    //float progress = [[NSNumber numberWithInteger:totalBytesWritten] floatValue];
    //float total = [[NSNumber numberWithInteger: totalBytesExpectedToWrite] floatValue];
    bytesSent+=bytesWritten;
    dispatch_async(dispatch_get_main_queue(), ^{
        //_lblUploadCount.text = [NSString stringWithFormat:@"%ld/%lu", (long)uploadCount, (unsigned long)_newsData.images.count];
        //_lblUploadPercentage.text=[NSString stringWithFormat:@"%d%%", (int)((progress/total)*100)];
        _lblUploadPercentage.text=[NSString stringWithFormat:@"%d%%", (int)(((float)bytesSent/(float)totalUploadFileSize)*100)];
    });
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [_imgLoading.layer removeAllAnimations];
    [self fail];
    return;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (uploadCount<_newsData.images.count&&_newsData.images.count>0) {
        uploadCount++;
        [self uploadFile:uploadCount-1];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imgLoading.layer removeAllAnimations];
            [_lblUploadPercentage setHidden:YES];
            //update db status
            NSMutableDictionary *dbDict = [[NSMutableDictionary alloc] init];
            dbDict[@"STATUS"] = @1;
            [appDelegate.db updateDictionary:dbDict forTable:@"UPLOAD_DATA" where:[NSString stringWithFormat:@" NEWS_ID='%d'", localNewsID]];
            [self success];
        });
        
    }
}

#pragma mark Database
- (void)saveDataToDB{
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *tDict = [[NSMutableDictionary alloc] init];
    localNewsID = [self setNewsID];
    tDict[@"NEWS_ID"] = @(localNewsID);
    tDict[@"NEWS_ID_SERVER"] = (news_id!=nil?@([news_id intValue]):[NSNull null]);
    tDict[@"NEWSDEMAND_ID"] = @(_newsData.did);
    tDict[@"TITLE"] = _newsData.title;
    tDict[@"DESCRIPTION"] = _newsData.content;
    tDict[@"LAT"] = @(_newsData.latitude);
    tDict[@"LNG"] = @(_newsData.longitude);
    tDict[@"MEDIA_ID"] = [_newsData.media componentsJoinedByString:@","];
    //tDict[@"SELECTED_IMGS"] = [self.odabraneSlike componentsJoinedByString:@","];
    tDict[@"SELECTED_IMGS"] = [self getSelectedMediaURL:_newsData.images];
    //tDict[@"SELECTED_ROWS"] = [self.arSelectedRows componentsJoinedByString:@","];
    tDict[@"ISNEWSDEMAND"] = (_newsData.did!=0?@1:@0);
    //tDict[@"IMAGES"] - tu idu urlovi (za provjeru kasnije da li postoji)
    tDict[@"TAGS"] = [_newsData.tags componentsJoinedByString:@","];
    tDict[@"ANONYMOUS"] = @(_newsData.prot);
    tDict[@"CONTACTED"] = @(_newsData.be_contacted);
    tDict[@"CREDITED"] = @(_newsData.be_credited);
    //tDict[@"NEWSVALUE"] = @(self.newsValue);
    tDict[@"PRICE"] = @(_newsData.price);
    tDict[@"STATUS"] = @0;
    tDict[@"UPLOAD_COUNT"] = @1;
    
    [appdelegate.db insertDictionaryWithoutColumnCheck:tDict forTable:@"UPLOAD_DATA"];
    
    
}

- (NSInteger)setNewsID{
    NSString *sql = @"SELECT ifnull(max(news_id),0) FROM upload_data";
    NSInteger newsID = [[appDelegate.db getColForSQL:sql] integerValue];
    return newsID+1;
}
#pragma mark ColombioSC Delegate
- (void)didFetchNewsDemands:(NSDictionary *)result{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self setNewsDemandBadge];
    });
    
}

- (NSString*)getSelectedMediaURL:(NSMutableArray*)images{
    NSMutableArray *selectedImageURLs = [[NSMutableArray alloc] init];
    for(ALAsset *asset in images){
        NSString *url = [NSString stringWithFormat:@"%@",[asset valueForProperty:ALAssetPropertyAssetURL]];
        [selectedImageURLs addObject:url];
    }
    return [selectedImageURLs componentsJoinedByString:@","];
    
}

#pragma mark SetBadges
/*- (void)setNewsDemandBadge{
    NSInteger count = [_Tools getNumberOfNewDemands];
    if (count>0) {
        UILabel *lblBadge = [_Tools getBadgeObject:count frame:newsDemand.frame];
        [self.view addSubview:lblBadge];
    }
}*/

@end
