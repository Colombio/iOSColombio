//
//  NewsDemandCell.h
//  colombio
//
//  Created by Vlatko Šprem on 15/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsDemandCell : UITableViewCell{
    
    UIActivityIndicatorView *loading;
    UIView *loadingView;
}

@property (weak, nonatomic) IBOutlet UILabel *lblMediaName;
@property (weak, nonatomic) IBOutlet UILabel *lblMediaType;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblRewardAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblNewsTitle;
@property (weak, nonatomic) IBOutlet UITextView *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgMediaLogo;
@property (weak, nonatomic) IBOutlet UIImageView *imgUnread;
@end
