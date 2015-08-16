//
//  TimeLineTableViewCell.h
//  Colombio
//
//  Created by Vlatko Šprem on 10/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineTableViewCell : UITableViewCell<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *alertImage;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgSample;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_txtViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_webViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblDescriptionHeight;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end
