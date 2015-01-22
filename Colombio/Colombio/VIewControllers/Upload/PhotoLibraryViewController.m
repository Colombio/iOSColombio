//
//  PhotoLibraryViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 16/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "PhotoLibraryViewController.h"
#import "LibraryCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoLibraryViewController ()
{
    ALAssetsLibrary *al;
    NSMutableArray *content;
    BOOL cameraPicked;
}
@property (weak, nonatomic) IBOutlet CustomHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotoLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_collectionView registerClass:[LibraryCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self loadLibrary];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLibrary{
    al= [[ALAssetsLibrary alloc] init];
    content = [[NSMutableArray alloc]init];
    [al enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group==nil){
            content = [[[content reverseObjectEnumerator]allObjects]mutableCopy ];
            //[labela setTitle:@"Select Photo/Video" forState:UIControlStateNormal];
            [_collectionView reloadData];
        }
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
                [content addObject:result];
            }
        }];
    } failureBlock:^(NSError *error) {
        
    }];
}

#pragma mark HeaderView Delegate

- (void)btnBackClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnNextClicked{

}

#pragma mark CollectionView
//Velicina jedne celije
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(99, 99);
}

//Razmak izmedu celija
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//Razmak izmedu celija
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1.5;
}

//Padding od rubova
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return content.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LibraryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    long position = (indexPath.row)+(indexPath.section*3);
    [cell.red2 setHidden:YES];
    cell.tag=position;
    if(position==0){
        //[cell hideWaterMark];
        [cell.watermark setHidden:YES];
        [cell.red2 setHidden:NO];
        [cell.notSelected setHidden:YES];
        [cell.select setHidden:YES];
        cell.img.image=[UIImage imageNamed:@"uploadcamera.png"];
        return cell;
    }
    if(position==1&&cameraPicked==YES){
        cameraPicked=NO;
    }
    
    //Dohvacanje url-a i naziva slike iz polja medija
    ALAsset *slika =[content objectAtIndex:position-1];
    
    cell.img.image=[UIImage imageWithCGImage:[slika thumbnail]];
    if([[slika valueForProperty:ALAssetPropertyType] isEqual:@"ALAssetTypePhoto"]){
        [cell.watermark setHidden:YES];
    }
    else{
        [cell.watermark setHidden:NO];
    }
    /*if([odabrano containsObject:[NSString stringWithFormat:@"%li",pozicija-1]]){
        [cell.notSelected setHidden:YES];
        [cell.select setHidden:NO];
    }
    else{
        [cell.notSelected setHidden:NO];
        [cell.select setHidden:YES];
    }*/
    
    cell.select.tag=position-1;
    cell.notSelected.tag=position-1;
    
    return cell;
}
@end
