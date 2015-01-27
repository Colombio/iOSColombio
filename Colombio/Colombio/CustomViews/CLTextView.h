//
//  CLTextView.h
//  Colombio
//
//  Created by Vlatko Šprem on 23/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLTextViewDelegate
@optional

- (void)closeKeyboard;

@end

@interface CLTextView : UITextView<UITextViewDelegate>

@property(nonatomic, strong) NSString *placeholder;
@property(nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, weak) IBOutlet id <UITextViewDelegate> textViewDelegate;

@end
