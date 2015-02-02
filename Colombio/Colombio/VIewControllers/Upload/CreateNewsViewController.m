//
//  CreateNewsViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 09/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "CreateNewsViewController.h"
#import "CustomHeaderView.h"
#import "PhotoLibraryViewController.h"
#import "ButtonTag.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CreateNewsViewController ()

@property (weak,nonatomic) IBOutlet CustomHeaderView *customHeader;
@property (weak,nonatomic) IBOutlet UIView *viewHolder;
@property (weak,nonatomic) IBOutlet UIView *viewImageHolder;
@property (weak,nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak,nonatomic) IBOutlet UIView *viewTagsHolder;

@property (strong, nonatomic) NSMutableArray *tagsButtons;


@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_imageHolderHeight;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_tagsHolderHeight;

- (IBAction)btnAddImageTapped:(id)sender;
@end

CGFloat const kImageHeight = 120.0;
CGFloat const kImagePadding = 1.0;

@implementation CreateNewsViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.title = [Localized string:@"send_news"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tagsButtons = [[NSMutableArray alloc] init];
    _selectedTags = [[NSMutableArray alloc] init];
    ColombioServiceCommunicator *colombioSC = [ColombioServiceCommunicator sharedManager];
    colombioSC.delegate=self;
    [colombioSC fetchTags];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Set Images

- (void)loadImages{
    int yoffset=0;
     _CS_imageHolderHeight.constant = kImageHeight;
    for(UIView *view in _viewImageHolder.subviews){
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    for(int i=0;i<_selectedImagesArray.count;i++){
        ALAsset *asset =_selectedImagesArray[i];
        UIImageView *thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, yoffset, _viewImageHolder.frame.size.width, kImageHeight)];
        thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        thumbnail.clipsToBounds=YES;
        UITapGestureRecognizer *btnLibrary =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnAddImageTapped:)];
        btnLibrary.numberOfTapsRequired = 1;
        btnLibrary.numberOfTouchesRequired = 1;
        [thumbnail addGestureRecognizer:btnLibrary];
        [thumbnail setUserInteractionEnabled:YES];
        thumbnail.image =[UIImage imageWithCGImage:[asset thumbnail]];
        [_viewImageHolder addSubview:thumbnail];
                                  
        yoffset+=kImageHeight+kImagePadding;
    }
    _CS_imageHolderHeight.constant +=yoffset;
    
}



#pragma mark Button Action

- (IBAction)btnAddImageTapped:(id)sender{
    PhotoLibraryViewController *library = [[PhotoLibraryViewController alloc] initWithSelectedAssets:_selectedImagesArray];
    [self.delegate navigateToVC:library];
    
}

#pragma mark Tags
- (void)didFetchTags:(NSDictionary *)result{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for(int i=0;i<((NSArray*)result[@"data"]).count;i++){// (NSDictionary *dict in result[@"data"]) {
            NSDictionary *dict = result[@"data"][i];
            ButtonTag  *btn = [ButtonTag buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.tag_id = dict[@"tag_id"];
            btn.tag_name = dict[@"tag_name"];
            btn.display_name = dict[@"display_name"];
            [btn setTitle:[NSString stringWithFormat:@"#%@",dict[@"display_name"]] forState:UIControlStateNormal];
            btn.titleLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_TAGS_ITALIC];
            btn.stringsize = [[NSString stringWithFormat:@"#%@",dict[@"display_name"]] sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_TAGS_ITALIC]];
            btn.backgroundColor = [UIColor clearColor];
            [btn addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];
            [btn sizeToFit];
            [_tagsButtons addObject:btn];
        }
        [self setupTags];
    });
    
}

- (void)setupTags{
    int offset = 1;
    CGFloat nextButtonPadding = 15.0;
    CGFloat frameWidth = _viewTagsHolder.bounds.size.width;
    
    for(ButtonTag *btn in _tagsButtons){
        if (nextButtonPadding + btn.stringsize.width > frameWidth) {
            offset++;
            nextButtonPadding= 15.0;
        }
        btn.frame = CGRectMake(nextButtonPadding, offset*(22.0+5.0), btn.stringsize.width, btn.stringsize.height);
        nextButtonPadding = btn.frame.origin.x + btn.frame.size.width + 15.0;
        if ([_selectedTags containsObject:btn.tag_id]) {
            [btn setSelected:YES];
        }else{
            [btn setSelected:NO];
        }
        
        [_viewTagsHolder addSubview:btn];
        
    }
    _CS_tagsHolderHeight.constant = offset*(22.0+5.0);
}

- (void)tagAction:(ButtonTag*)sender{
    if ([_selectedTags containsObject:sender.tag_id]) {
        [_selectedTags removeObject:sender.tag_id];
    }else{
        [_selectedTags addObject:sender.tag_id];
    }
    [self setupTags];
}

#pragma mark Validation

/*
 * Not used
 **/
- (BOOL)validateFields{
    BOOL dataOK = YES;
    if (_txtTitle.text.length==0) {
        [_txtTitle setPlaceholderColor:COLOR_CUSTOM_RED];
        dataOK = NO;
    }
    if (_txtDescription.text.length==0) {
        [_txtDescription setPlaceholderColor:COLOR_CUSTOM_RED];
        dataOK = NO;
    }
    return dataOK;
}

- (BOOL)validateImages{
    if (_selectedImagesArray.count==0) {
        return NO;
    }
    return YES;
}

- (BOOL)validateTags{
    if (_selectedTags.count==0) {
        return NO;
    }
    return YES;
}
@end
