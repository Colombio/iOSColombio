//
//  CashoutViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 07/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "CashoutViewController.h"
#import "CustomHeaderView.h"

@interface CashoutViewController ()<CustomHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary *dictPayPalData;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblInfoHeight;
@property (weak, nonatomic) IBOutlet CustomHeaderView *customHeader;
@end

@implementation CashoutViewController

- (instancetype)initWithData:(NSDictionary*)data{
    self = [super init];
    if (self) {
        _dictPayPalData=data;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblView.alwaysBounceVertical = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    _customHeader.backButtonText=@"";
    _customHeader.headerTitle=[Localized string:@"cashout_request"];
    _lblInfo.text = [NSString stringWithFormat:[Localized string:@"cash_out_confirmation"], _dictPayPalData[@"paypal_email"]];
    [self setupLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupLabel{
   CGSize size = [_lblInfo.text sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT_SMALL] constrainedToSize:CGSizeMake(_lblInfo.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    _CS_lblInfoHeight.constant = size.height;
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(5, 8, 320, 20);
    myLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_BOLD_SMALL];
    myLabel.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NEWS_TITLE];
    myLabel.text = [Localized string:@"cashout_info"];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:myLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = _dictPayPalData[@"paypal_email"];
            break;
        case 1:
            cell.textLabel.text = _dictPayPalData[@"first_name"];
            break;
        case 2:
            cell.textLabel.text = _dictPayPalData[@"last_name"];
            break;
        case 3:
            cell.textLabel.text = _dictPayPalData[@"street"];
            break;
        case 4:
            cell.textLabel.text = _dictPayPalData[@"city"];
            break;
        case 5:
            cell.textLabel.text = _dictPayPalData[@"zip"];
            break;
        case 6:
            cell.textLabel.text = _dictPayPalData[@"country"];
            break;
            
        default:
            break;
    }
    
    
    
    return cell;
}

#pragma mark Navigation
- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
