//
//  AnnounceEventViewController.h
//  Colombio
//
//  Created by Vlatko Šprem on 22/04/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "BackgroundViewController.h"
#import "ColombioServiceCommunicator.h"
#import "CLTextView.h"

@interface AnnounceEventViewController : BackgroundViewController<UITextViewDelegate, ColombioServiceCommunicatorDelegate>

@property (strong, nonatomic) NSMutableArray *selectedTags;
@property (weak,nonatomic) IBOutlet CLTextView *txtTitle;
@property (weak,nonatomic) IBOutlet CLTextView *txtDescription;
@property (weak, nonatomic) IBOutlet UIDatePicker *pkrDate;
@property (strong, nonatomic) NSDate *dateEvent;

@end
