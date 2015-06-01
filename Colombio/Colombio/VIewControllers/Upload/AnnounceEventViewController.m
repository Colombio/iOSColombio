//
//  AnnounceEventViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 22/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "AnnounceEventViewController.h"
#import "ButtonTag.h"

@interface AnnounceEventViewController ()

@property (weak,nonatomic) IBOutlet UIView *viewTagsHolder;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableArray *tagsButtons;

@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_tagsHolderHeight;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_txtTitleHeight;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_txtDescriptionHeight;
@end

@implementation AnnounceEventViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.title = [[Localized string:@"announce_event"] uppercaseString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    _tagsButtons = [[NSMutableArray alloc] init];
    _selectedTags = [[NSMutableArray alloc] init];
    _dateEvent = _pkrDate.date;
    ColombioServiceCommunicator *colombioSC = [ColombioServiceCommunicator sharedManager];
    colombioSC.delegate=self;
    [colombioSC fetchTags];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark PickerAction
- (IBAction)pickerAction:(UIPickerView*)sender{
    _dateEvent=_pkrDate.date;
}

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
@end
