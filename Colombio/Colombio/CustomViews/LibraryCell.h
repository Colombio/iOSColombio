//
//  LibraryCell.h
//  colombio
//
//  Created by Colombio on 7/29/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibraryCell : UICollectionViewCell{
    IBOutlet UIImageView *img;
    IBOutlet UIImageView *notSelected;
    IBOutlet UIImageView *imgWatermark;
    IBOutlet UIImageView *select;
    IBOutlet UIImageView *watermark;
    IBOutlet UILabel *red2;
}
@property (nonatomic, strong) IBOutlet UILabel *red2;
@property (nonatomic, strong) IBOutlet UIImageView *img;
@property (nonatomic, strong) IBOutlet UIImageView *notSelected;
@property (nonatomic, strong) IBOutlet UIImageView *imgWatermark;
@property (nonatomic, strong) IBOutlet UIImageView *select;
@property (nonatomic, strong) IBOutlet UIImageView *watermark;

- (void)hideWaterMark;

@end
