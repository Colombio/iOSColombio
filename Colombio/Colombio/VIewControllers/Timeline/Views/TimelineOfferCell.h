//
//  TimelineOfferCell.h
//  Colombio
//
//  Created by Vlatko Šprem on 15/05/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeLineOfferCellDelegate

- (void)didAcceptOffer:(NSInteger)offer_id;
- (void)didRejectOffer:(NSInteger)offer_id;

@end

@interface TimelineOfferCell : UITableViewCell

@property (assign, nonatomic) id<TimeLineOfferCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;
@property (assign, nonatomic) NSInteger offerID;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTypeName;
@property (weak, nonatomic) IBOutlet UILabel *lblDisclaimer;
@property (weak, nonatomic) IBOutlet UIView *lblViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblMessageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblViewContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CS_lblDisclaimerHeight;

@end
