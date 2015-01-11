//
//  HomeViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 07/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewHolderPhoto;
@property (weak, nonatomic) IBOutlet UIView *viewHolderSend;
@property (weak, nonatomic) IBOutlet UIView *viewHolderAlert;
@property (weak, nonatomic) IBOutlet UIView *viewHolderCommunity;
@property (weak, nonatomic) IBOutlet UIView *viewHolderAnnounce;
@property (weak, nonatomic) IBOutlet UIView *viewHolderCall;

@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIButton *btnAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnCommunity;
@property (weak, nonatomic) IBOutlet UIButton *btnAnnounce;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;


- (IBAction)btnSendClicked:(id)sender;
- (IBAction)btnPhotoClicked:(id)sender;
- (IBAction)btnAlertClicked:(id)sender;
- (IBAction)btnCommunityClicked:(id)sender;
- (IBAction)btnAnnounceClicked:(id)sender;
- (IBAction)btnCallClicked:(id)sender;
@end
