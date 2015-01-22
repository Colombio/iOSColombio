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

@interface CreateNewsViewController ()

@property (weak,nonatomic) IBOutlet CustomHeaderView *customHeader;
@property (weak,nonatomic) IBOutlet UIView *viewHolder;
@property (weak,nonatomic) IBOutlet UITextView *txtTitle;
@property (weak,nonatomic) IBOutlet UITextView *txtDescription;
@property (weak,nonatomic) IBOutlet UIView *viewImageHolder;
@property (weak,nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak,nonatomic) IBOutlet UIView *viewTagsHolder;

@property (strong, nonatomic) NSMutableArray *tagsButtons;
@property (strong, nonatomic) NSMutableArray *tagsResult;
@property (strong, nonatomic) NSMutableArray *selectedTags;

@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_imageHolderHeight;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_tagsHolderHeight;

- (IBAction)btnAddImageTapped:(id)sender;
@end

@implementation CreateNewsViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.title = [Localized string:@"SELECT MEDIA"];
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
    // Dispose of any resources that can be recreated.
}




#pragma mark Button Action

- (IBAction)btnAddImageTapped:(id)sender{
    PhotoLibraryViewController *library = [[PhotoLibraryViewController alloc] init];
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
@end
