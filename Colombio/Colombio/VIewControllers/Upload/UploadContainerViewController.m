//
//  UploadContainerViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 19/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "UploadContainerViewController.h"
#import "NewsData.h"
#import "AppDelegate.h"
#import "UploadNewsViewController.h"
#import "Messages.h"



@interface UploadContainerViewController ()
{
    NewsData *newsData;
}
@property (assign, nonatomic) BOOL isNewsDemand;
@property (strong, nonatomic) NewsDemandObject *newsDemandData;
@property (assign, nonatomic) NSInteger typeID;
@end



@implementation UploadContainerViewController
//@synthesize viewControllersArray=_viewControllersArray;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forNewsDemandData:(NewsDemandObject*)newsDemandData isNewsDemand:(BOOL)isNewsDemand{
    _newsDemandData = newsDemandData;
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil isNewsDemand:isNewsDemand forType:0];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isNewsDemand:(BOOL)isNewsDemand forType:(NSInteger)typeID{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _typeID=typeID;
        //set child view controllers and their properties
        super.isSingleTitle=YES;
        super.progressBarAnimation=YES;
        _isNewsDemand = isNewsDemand;
        if (_typeID==5) {
            announcedVC = [[AnnounceEventViewController alloc] init];
        }else{
            contentVC = [[CreateNewsViewController alloc] init];
            contentVC.delegate = self;
        }
        userInfoVC = [[UserInfoUploadViewController alloc] initWithDemand:_isNewsDemand withPrice:_newsDemandData.cost];
        newsData = [[NewsData alloc] init];
        NSArray *array;
        if (!isNewsDemand) {
            mediaVC = [[SelectMediaViewController alloc] initForNewsUpload:YES];
            if (_typeID==5) {
                array = [[NSArray alloc] initWithObjects:announcedVC, mediaVC, userInfoVC, nil];
            }else{
                if(_typeID==1){
                    contentVC.openCamera=YES;
                }else{
                    contentVC.openCamera=NO;
                }
                array = [[NSArray alloc] initWithObjects:contentVC,mediaVC, userInfoVC, nil];
            }
        }else{
            newsData.did = _newsDemandData.req_id;
            newsData.media = [[NSMutableArray alloc] initWithObjects:@(_newsDemandData.media_id), nil];
            newsData.longitude = _newsDemandData.longitude;
            newsData.latitude = _newsDemandData.latitude;
            newsData.price = [_newsDemandData.cost longLongValue];
            array = [[NSArray alloc] initWithObjects:contentVC, userInfoVC, nil];
            
        }
        super.lastNextBtnText = [Localized string:@"header_send"];
        super.viewControllersArray = array;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isNewsDemand) {
        contentVC.txtTitle.text = _newsDemandData.title;
        contentVC.txtDescription.text = _newsDemandData.desc;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectedImageAction:(NSMutableArray *)selectedImagesArray{
    contentVC.selectedImagesArray = selectedImagesArray;
    [contentVC loadImages];
}

#pragma mark Custom Delegates
- (void)navigateToVC:(PhotoLibraryViewController *)viewController{
    viewController.caller = self;
    [self presentViewController:viewController animated:YES completion:nil];
}


- (void)btnBack:(UIButton*)sender{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[Localized string:@"do_you_really_want_to_exit"] delegate:self cancelButtonTitle:[Localized string:@"no"] otherButtonTitles:[Localized string:@"yes"], nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1){
        if ([self isModal])
            [self dismissViewControllerAnimated:NO completion:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)navigateNext{
    if ([self validateData]) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (!_isNewsDemand) {
            newsData.longitude = appDelegate.locationManager.location.coordinate.longitude;
            newsData.latitude = appDelegate.locationManager.location.coordinate.latitude;
            newsData.media = mediaVC.selectedMedia;
            newsData.did=0;
        }
        if (_typeID==5) {
            newsData.title = announcedVC.txtTitle.text.length>0?announcedVC.txtTitle.text:[Localized string:@"no_title"];
            newsData.content = announcedVC.txtDescription.text.length>0?announcedVC.txtDescription.text:[Localized string:@"no_title"];
            newsData.images = nil;
            newsData.tags = announcedVC.selectedTags;
            newsData.content = announcedVC.txtDescription.text;
            //DATUM!!!!
        }else{
            newsData.title = contentVC.txtTitle.text.length>0?contentVC.txtTitle.text:[Localized string:@"no_title"];
            newsData.content = contentVC.txtDescription.text.length>0?contentVC.txtDescription.text:[Localized string:@"no_title"];
            newsData.images = contentVC.selectedImagesArray;
            newsData.tags = contentVC.selectedTags;
            newsData.content = contentVC.txtDescription.text;
        }
        newsData.prot = userInfoVC.swToggleAnonymous.isOn;
        //ime i prezima??
        newsData.be_credited = userInfoVC.be_credited;
        newsData.be_contacted = userInfoVC.swToggleContactMe.isOn;
        newsData.phone_number = userInfoVC.txtContactMe.text;
        newsData.sell = userInfoVC.swTogglePrice.isOn;
        
        newsData.type_id = _typeID;
        
        
        UploadNewsViewController *uploadNewsVC = [[UploadNewsViewController alloc] initWithNewsData:newsData];
        uploadNewsVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:uploadNewsVC animated:YES];
        
    }
}

#pragma mark Validate Data

- (BOOL)validateData{
    BOOL dataOK  = YES;
    /*if (![contentVC validateFields]) {
        dataOK=NO;
    }*/
    if (![userInfoVC validateFields]) {
        dataOK=NO;
    }
    if (!dataOK) {
        [self showErrorMessage:@"error_fill_fields"];
        return NO;
    }
    /*if (![contentVC validateImages]) {
        [self showErrorMessage:@"error_missing_images"];
        return NO;
    }*/
    if (!_isNewsDemand) {
        if (![contentVC validateTags]) {
            [self showErrorMessage:@"error_missing_tags"];
            return NO;
        }
    }
    
    if (!_isNewsDemand) {
        if (![mediaVC validateMedia]) {
            [self showErrorMessage:@"error_missing_media"];
            return NO;
        }
    }
    return YES;
}

- (void)showErrorMessage:(NSString*)errorString{
    [Messages showNormalMsg:errorString];
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}
@end
