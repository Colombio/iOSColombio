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


@interface UploadContainerViewController ()

@property (assign, nonatomic) BOOL isNewsDemand;
@end



@implementation UploadContainerViewController
//@synthesize viewControllersArray=_viewControllersArray;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isNewsDemand:(BOOL)isNewsDemand{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isNewsDemand = isNewsDemand;
        contentVC = [[CreateNewsViewController alloc] init];
        contentVC.delegate = self;
        userInfoVC = [[UserInfoUploadViewController alloc] initWithDemand:_isNewsDemand];
        NSArray *array;
        if (!isNewsDemand) {
            mediaVC = [[NewsMediaViewController alloc] init];
            array = [[NSArray alloc] initWithObjects:contentVC, mediaVC, userInfoVC, nil];
        }else{
            array = [[NSArray alloc] initWithObjects:contentVC, userInfoVC, nil];
        }
        super.imgNextBtnNormal = [UIImage imageNamed:@"send_normal"];
        super.imgNextBtnPressed = [UIImage imageNamed:@"send_pressed"];
        super.viewControllersArray = array;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)navigateNext{
    if ([self validateData]) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NewsData *newsData = [[NewsData alloc] init];
        newsData.longitude = appDelegate.locationManager.location.coordinate.longitude;
        newsData.latitude = appDelegate.locationManager.location.coordinate.latitude;
        newsData.title = contentVC.txtTitle.text;
        newsData.content = contentVC.txtDescription.text;
        newsData.images = contentVC.selectedImagesArray;
        newsData.tags = contentVC.selectedTags;
        
        if (_isNewsDemand) {
            //složiti kak se šalje media_id is newsdemand
            //newsData.did=
        }else{
            newsData.media = mediaVC.selectedMedia;
            newsData.did=0;
            newsData.price = [userInfoVC.price floatValue];
        }
        
        newsData.prot = userInfoVC.btnToggleAnonymous.isON;
        //ime i prezima??
        newsData.be_credited = userInfoVC.be_credited;
        newsData.be_contacted = userInfoVC.btnToggleContactMe.isON;
        newsData.phone_number = userInfoVC.txtContactMe.text;
        
        newsData.type_id = 1;
        
        
        UploadNewsViewController *uploadNewsVC = [[UploadNewsViewController alloc] initWithNewsData:newsData];
        uploadNewsVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:uploadNewsVC animated:YES];
        
    }
}

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
    if (![contentVC validateImages]) {
        [self showErrorMessage:@"error_missing_images"];
        return NO;
    }
    if (![contentVC validateTags]) {
        [self showErrorMessage:@"error_missing_tags"];
        return NO;
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
@end
