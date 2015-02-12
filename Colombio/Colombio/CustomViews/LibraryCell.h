/////////////////////////////////////////////////////////////
//
//  LibraryCell.h
//  Armin Vrevic
//
//  Created by Colombio on 7/29/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Custom collection view cell for phone library item selecting
//  (video, pictures)
//
///////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

@interface LibraryCell : UICollectionViewCell{
    IBOutlet UIImageView *img;
    IBOutlet UIImageView *imgNotSelected;
    IBOutlet UIImageView *imgWatermark;
    IBOutlet UIImageView *imgSelected;
    IBOutlet UIImageView *watermark;
    IBOutlet UILabel *lblCellText;
}
@property (nonatomic, strong) IBOutlet UILabel *lblCellText;
@property (nonatomic, strong) IBOutlet UIImageView *img;
@property (nonatomic, strong) IBOutlet UIImageView *imgNotSelected;
@property (nonatomic, strong) IBOutlet UIImageView *imgWatermark;
@property (nonatomic, strong) IBOutlet UIImageView *imgSelected;
@property (nonatomic, strong) IBOutlet UIImageView *watermark;

- (void)hideWaterMark;

@end
