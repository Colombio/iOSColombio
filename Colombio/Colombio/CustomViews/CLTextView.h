//
//  CLTextView.h
//  Colombio
//
//  Created by Vlatko Šprem on 23/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//
//  Used for text input views
//  Implement in IB, use UIView object and change class to CLTextView.
//  Key properties can be set in User defined runtime attributes section.

#import <UIKit/UIKit.h>

@protocol CLTextViewDelegate
@optional

- (void)closeKeyboard;

@end

@interface CLTextView : UITextView<UITextViewDelegate>
{
    UILabel *l;
}
@property(nonatomic, strong) NSString *placeholder; //fake placeholder implemented via UILabel in drawRect method
@property(nonatomic, strong) NSString *placeholderColor;
@property (nonatomic, weak) IBOutlet id <UITextViewDelegate> textViewDelegate;

- (id)initWithFrame:(CGRect)frame;
@end
