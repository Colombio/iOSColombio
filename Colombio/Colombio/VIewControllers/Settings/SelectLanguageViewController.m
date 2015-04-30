//
//  SelectLanguageViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 26/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "SelectLanguageViewController.h"
#import "CustomHeaderView.h"

@interface SelectLanguageViewController ()<UITableViewDataSource, UITableViewDelegate, CustomHeaderViewDelegate>

@property (nonatomic, strong) NSString *previousLanguage;
@property (nonatomic, strong) NSArray *languageArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeader;
@end

@implementation SelectLanguageViewController

- (id)init{
    self = [super init];
    if (self) {
        _languageArray = [[NSBundle mainBundle] localizations];
        _previousLanguage = [Localized prefferedLocalization];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    _customHeader.headerTitle = [[Localized string:@"select_language"] uppercaseString];
    _customHeader.backButtonText = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _languageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_REGULAR_19];
    cell.textLabel.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NEWS_TITLE];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [Localized string:self.languageArray[indexPath.row]];
    
    if([self.languageArray[indexPath.row] isEqualToString:[Localized prefferedLocalization]]){
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected"]];
        cell.accessoryView = checkmark;
    }else{
        cell.accessoryView = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [Localized save:self.languageArray[indexPath.row]];
    if (![self.languageArray[indexPath.row] isEqualToString:self.previousLanguage])
    {
        _previousLanguage = [Localized prefferedLocalization];
        _customHeader.headerTitle = [[Localized string:@"select_language"] uppercaseString];
        [_tableView reloadData];
    }
    
}
@end
