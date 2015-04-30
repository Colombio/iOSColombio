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
#import "AppDelegate.h"
#import "Loading.h"

@interface CreateNewsViewController ()
{
    ALAssetsLibrary *al;
    NSMutableArray *content;
    Loading *loadingView;
}
@property (weak,nonatomic) IBOutlet CustomHeaderView *customHeader;
@property (weak,nonatomic) IBOutlet UIView *viewHolder;
@property (weak,nonatomic) IBOutlet UIView *viewImageHolder;
@property (weak,nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak,nonatomic) IBOutlet UIView *viewTagsHolder;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableArray *tagsButtons;


@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_imageHolderHeight;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_tagsHolderHeight;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_txtTitleHeight;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_txtDescriptionHeight;

@property (strong, nonatomic) UIImagePickerController *camera;

- (IBAction)btnAddImageTapped:(id)sender;
@end

CGFloat const kImageHeight = 120.0;
CGFloat const kImageAddHeight = 50.0;
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
    if (_openCamera) {
        loadingView = [[Loading alloc] init];
        al = [AppDelegate defaultAssetsLibrary];
        [self openCameraVC];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
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
     _CS_imageHolderHeight.constant = kImageAddHeight;
    for(UIView *view in _viewImageHolder.subviews){
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }else if([view isKindOfClass:[UIButton class]]){
            if (view.tag>-1) {
                [view removeFromSuperview];
            }
        }
    }
    for(int i=0;i<_selectedImagesArray.count;i++){
        ALAsset *asset =_selectedImagesArray[i];
        UIImageView *thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, yoffset, _viewImageHolder.frame.size.width, kImageHeight)];
        thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        thumbnail.clipsToBounds=YES;
        /*UITapGestureRecognizer *btnLibrary =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnAddImageTapped:)];
        btnLibrary.numberOfTapsRequired = 1;
        btnLibrary.numberOfTouchesRequired = 1;
        [thumbnail addGestureRecognizer:btnLibrary];
        [thumbnail setUserInteractionEnabled:YES];*/
        thumbnail.image =[UIImage imageWithCGImage:[asset thumbnail]];
        [_viewImageHolder addSubview:thumbnail];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(thumbnail.frame.size.width-49, thumbnail.frame.origin.y+5, 44, 44);
        [btn setBackgroundImage:[UIImage imageNamed:@"close_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"close_pressed"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [_viewImageHolder addSubview:btn];
                                  
        yoffset+=kImageHeight+kImagePadding;
    }
    _CS_imageHolderHeight.constant +=yoffset;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DoestThePictureExist" object:nil userInfo:@{@"picexistance":(_selectedImagesArray.count>0?@(YES):@(NO))}];
    
}

- (void)removeImage:(UIButton*)sender{
    [_selectedImagesArray removeObjectAtIndex:sender.tag];
    [self loadImages];
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
    CGFloat nextButtonPadding = 5.0;
    CGFloat frameWidth = _viewTagsHolder.bounds.size.width;
    
    for(ButtonTag *btn in _tagsButtons){
        if (nextButtonPadding + btn.stringsize.width > frameWidth) {
            offset++;
            nextButtonPadding= 5.0;
        }
        btn.frame = CGRectMake(nextButtonPadding, offset*(22.0+15.0), btn.stringsize.width+10, btn.stringsize.height+15);
        nextButtonPadding = btn.frame.origin.x + btn.frame.size.width + 5.0;
        if ([_selectedTags containsObject:btn.tag_id]) {
            [btn setSelected:YES];
        }else{
            [btn setSelected:NO];
        }
        
        [_viewTagsHolder addSubview:btn];
        
    }
    _CS_tagsHolderHeight.constant = offset*(22.0+15.0)+20;
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

#pragma mark TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSString *replacedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (textView==_txtTitle) {
        if (replacedString.length>255) {
            return NO;
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    
    if (textView==_txtTitle) {
        if (size.height>45.0) {
        _CS_txtTitleHeight.constant = size.height;
        }else{
        _CS_txtTitleHeight.constant = 45.0;
        }
    }else if (textView==_txtDescription) {
        if (size.height>120.0) {
        _CS_txtDescriptionHeight.constant = size.height;
        }else{
        _CS_txtDescriptionHeight.constant = 120.0;
        }
    }
}

#pragma mark Keyboard

- (void)keyboardUp:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    UIEdgeInsets contentInset = _scrollView.contentInset;
    contentInset.bottom = keyboardRect.size.height;
    _scrollView.contentInset = contentInset;
}

- (void)keyboardDown:(NSNotification*)notification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark Camera Action
- (void)openCameraVC{
    _camera = [[UIImagePickerController alloc]init];
    _camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    _camera.delegate = self;
    
    [_camera setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:_camera animated:YES completion:NULL];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
     UIImage *image  =[info objectForKey:UIImagePickerControllerOriginalImage];
     [self dismissViewControllerAnimated:YES completion:NULL];
     [loadingView startCustomSpinner:self.view spinMessage:@""];
     [al writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
         [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadLibrary) userInfo:nil repeats:NO];
     }];
     NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
     if([mediaType isEqualToString:@"public.movie"]){
     NSString *sourcePath = [[info objectForKey:@"UIImagePickerControllerMediaURL"]relativePath];
     UISaveVideoAtPathToSavedPhotosAlbum(sourcePath, nil, @selector(finishVideoSaving:), nil);
     }
}


- (IBAction)finishVideoSaving:(id)sender{
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadLibrary) userInfo:nil repeats:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)loadLibrary{
    _selectedImagesArray = [[NSMutableArray alloc] init];
    content = [[NSMutableArray alloc]init];
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                [content addObject:alAsset];
                *stop=YES;
                *innerStop=YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_selectedImagesArray addObject:content[0]];
                    [self loadImages];
                    [loadingView removeCustomSpinner];
                });
            }
        }];
    } failureBlock: ^(NSError *error) {
        NSLog(@"No groups");
    }];
}

@end
