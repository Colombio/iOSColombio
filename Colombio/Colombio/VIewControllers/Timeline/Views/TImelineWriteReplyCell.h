//
//  TImelineWriteReplyCell.h
//  Colombio
//
//  Created by Vlatko Šprem on 15/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLTextView.h"

@protocol TimeLineWriteReplyCellDelegate

- (void)didSelectSendReply:(NSString*)message forNewsId:(NSInteger)nid andMediaId:(NSInteger)mid;

@end

@interface TImelineWriteReplyCell : UITableViewCell<UITextViewDelegate>

@property (assign, nonatomic) id<TimeLineWriteReplyCellDelegate>delegate;
@property (assign, nonatomic) NSInteger nid;
@property (assign, nonatomic) NSInteger mid;

@property (weak, nonatomic) IBOutlet CLTextView *txtView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *CS_textViewHeight;

@end
