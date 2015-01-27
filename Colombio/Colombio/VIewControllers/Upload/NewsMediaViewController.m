//
//  NewsMediaViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 25/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "NewsMediaViewController.h"

@interface NewsMediaViewController ()

@end

@implementation NewsMediaViewController
@synthesize selectedMedia;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSelectCell:(NSIndexPath*)indexPath{
    long cellPosition = (indexPath.row)+(indexPath.section*3);
    
    if([super.arSelectedMedia containsObject:[[super.media objectAtIndex:cellPosition] objectForKey:@"id"]]){
        NSString *strMediaId = [[super.media objectAtIndex:cellPosition]objectForKey:@"id"];
        [super.arSelectedMedia removeObject:strMediaId];
    }
    //Ako odabrani medij nije selektiran, dodaj ga u polje selektiranih i refreshaj pogled
    else{
        NSString *strMediaId = [[super.media objectAtIndex:cellPosition]objectForKey:@"id"];
        [super.arSelectedMedia addObject:strMediaId];
    }
    self.selectedMedia = super.arSelectedMedia;
    [self reloadCollectionView];
}

- (void)reloadCollectionView {
    [super.settingsCollectionView.collectionView reloadData];
}

@end
