//
//  PhotoLibraryViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 16/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <AppDelegate.h>
#import "PhotoLibraryViewController.h"
#import "LibraryCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UploadContainerViewController.h"

#define MAX_IMAGES 5
#define MAX_VIDEOS 1
@interface PhotoLibraryViewController ()
{
    NSMutableArray *content;
    BOOL cameraPicked;
    NSMutableArray *selectedImage;
    NSMutableArray *selectedVideo;
    NSMutableArray *selectedImageURLs;
    NSMutableArray *selectedVideoURLs;
    
    
}
@property (weak, nonatomic) IBOutlet CustomHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIImagePickerController *camera;

@end

@implementation PhotoLibraryViewController

- (instancetype)initWithSelectedAssets:(NSMutableArray*)selectedAssets{
    self = [super init];
    if (self) {
        selectedImageURLs = [[NSMutableArray alloc] init];
        selectedVideoURLs = [[NSMutableArray alloc] init];
        selectedImage=[[NSMutableArray alloc] init];
        selectedVideo=[[NSMutableArray alloc] init];
        if (selectedAssets!=nil && selectedAssets.count>0) {
            for(ALAsset *asset in selectedAssets){
                if([[asset valueForProperty:ALAssetPropertyType] isEqual:@"ALAssetTypePhoto"]){
                    [selectedImage addObject:asset];
                }else{
                    [selectedVideo addObject:asset];
                }
            }
        }
        [self setAssetsURLs];
    }
    return self;
}
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
    ALAssetsLibrary *al = [AppDelegate defaultAssetsLibrary];
    content = [[NSMutableArray alloc]init];
    [al enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group==nil){
            content = [[[content reverseObjectEnumerator]allObjects]mutableCopy ];
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

- (void)setAssetsURLs{
    [selectedImageURLs removeAllObjects];
    [selectedVideoURLs removeAllObjects];
    if (selectedImage!=nil && selectedImage.count>0) {
        for(ALAsset *asset in selectedImage){
            NSString *url = [asset valueForProperty:ALAssetPropertyAssetURL];
            [selectedImageURLs addObject:url];
        }
    }
    if (selectedVideo!=nil && selectedVideo.count>0) {
        for(ALAsset *asset in selectedVideo){
            NSString *url = [asset valueForProperty:ALAssetPropertyAssetURL];
            [selectedVideoURLs addObject:url];
        }
    }
}


#pragma mark HeaderView

- (void)btnBackClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnNextClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.caller isKindOfClass:[UploadContainerViewController class]]) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if (selectedImage.count>0){
            [tempArray addObjectsFromArray:selectedImage];
        }
        if (selectedVideo.count>0){
            [tempArray addObjectsFromArray:selectedVideo];
        }
        [(UploadContainerViewController*)self.caller selectedImageAction:tempArray];
    }
    
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
    ALAsset *asset =[content objectAtIndex:position-1];
    cell.img.image=[UIImage imageWithCGImage:[asset thumbnail]];
    
    
    if([[asset valueForProperty:ALAssetPropertyType] isEqual:@"ALAssetTypePhoto"]){
        [cell.watermark setHidden:YES];
        if ([selectedImageURLs containsObject:[asset valueForProperty:ALAssetPropertyAssetURL]]) {
            [cell.select setHidden:NO];
        }else{
            [cell.select setHidden:YES];
        }
    }
    else{
        [cell.watermark setHidden:NO];
        if ([selectedVideoURLs containsObject:[asset valueForProperty:ALAssetPropertyAssetURL]]) {
            [cell.select setHidden:NO];
        }else{
            [cell.select setHidden:YES];
        }
    }
    
    
    cell.select.tag=position-1;
    cell.notSelected.tag=position-1;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    long position = (indexPath.row)+(indexPath.section*3);
    if(position==0){
        _camera = [[UIImagePickerController alloc]init];
        _camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        _camera.delegate = self;
        
        [_camera setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:_camera animated:YES completion:NULL];
    }
    else{
        if ([[(ALAsset*)content[position-1] valueForProperty:ALAssetPropertyType] isEqual:@"ALAssetTypePhoto"]) {
            int indexToRemove=-1;
            if([selectedImageURLs containsObject:[(ALAsset*)content[position-1] valueForProperty:ALAssetPropertyAssetURL]]){
                for (int i=0; i<selectedImage.count; i++) {
                    NSString *tempAssetURL = [NSString stringWithFormat:@"%@",[(ALAsset*)selectedImage[i] valueForProperty:ALAssetPropertyAssetURL]];
                    NSString *selectedAssetURL = [NSString stringWithFormat:@"%@",[(ALAsset*)content[position-1] valueForProperty:ALAssetPropertyAssetURL]];
                        
                    if ([tempAssetURL isEqualToString:selectedAssetURL]) {
                        indexToRemove=i;
                    }
                }
                if (indexToRemove!=-1) {
                    [selectedImage removeObjectAtIndex:indexToRemove];
                }
            }
            else{
                if (selectedImage.count<5) {
                    [selectedImage addObject:content[position-1]];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Localized string:@"photos_max_num_title"] message:[Localized string:@"photos_max_num"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }else{
            if([selectedVideoURLs containsObject:[(ALAsset*)content[position-1] valueForProperty:ALAssetPropertyAssetURL]]){
                int indexToRemove=-1;
                for (int i=0; i<selectedVideo.count; i++) {
                    NSString *tempAssetURL = [NSString stringWithFormat:@"%@",[(ALAsset*)selectedVideo[i] valueForProperty:ALAssetPropertyAssetURL]];
                    NSString *selectedAssetURL = [NSString stringWithFormat:@"%@",[(ALAsset*)content[position-1] valueForProperty:ALAssetPropertyAssetURL]];
                    
                    if ([tempAssetURL isEqualToString:selectedAssetURL]) {
                        indexToRemove=i;
                    }
                }
                if (indexToRemove!=-1) {
                    [selectedVideo removeObjectAtIndex:indexToRemove];
                }
            }
            else{
                if (selectedVideo.count<1) {
                    [selectedVideo addObject:content[position-1]];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Localized string:@"photos_max_num_title"] message:[Localized string:@"photos_max_num"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
        [self setAssetsURLs];
        [_collectionView reloadData];
    }
}

#pragma mark Camera Action
/*- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image  =[info objectForKey:UIImagePickerControllerOriginalImage];
    cameraPicked=YES;
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    [temp addObject:@"0"];
    for(NSString *pozicija in odabrano){
        NSInteger poz = [pozicija intValue];
        poz+=1;
        [temp addObject:[NSString stringWithFormat:@"%li",(long)poz]];
    }
    odabrano=temp;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [al writeImageToSavedPhotosAlbum:slika.CGImage orientation:(ALAssetOrientation)slika.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadLibrary) userInfo:nil repeats:NO];
    }];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"]){
        NSString *sourcePath = [[info objectForKey:@"UIImagePickerControllerMediaURL"]relativePath];
        UISaveVideoAtPathToSavedPhotosAlbum(sourcePath, nil, @selector(finishVideoSaving:), nil);    }
}

- (IBAction)finishVideoSaving:(id)sender{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadLibrary) userInfo:nil repeats:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}*/
@end
