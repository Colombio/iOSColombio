//
//  CLTextView.m
//  Colombio
//
//  Created by Vlatko Šprem on 23/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "CLTextView.h"
CGFloat const UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION = 0.25;

@implementation CLTextView

- (void)awakeFromNib{
    self.inputAccessoryView = [self keyboardToolbarFor:@selector(resignFirstResponder)];
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if ([[self placeholder] length]>0) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 0, 0)];
        [l setFont:self.font];
        [l setTextColor:self.placeholderColor];
        [l setText:self.placeholder];
        [l setAlpha:0];
        [l setTag:999];
        [self addSubview:l];
        [l sizeToFit];
        [self sendSubviewToBack:l];
    }
    if ([[self text] length]==0 && [[self placeholder] length]>0) {
        [[self viewWithTag:999] setAlpha:1];
    }
    [super drawRect:rect];
}

- (void)setTextViewDelegate:(id<UITextViewDelegate>)textViewDelegate{
    self.delegate = textViewDelegate;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    [UIView animateWithDuration:UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION animations:^{
        if([[self text] length] == 0)
        {
            [[self viewWithTag:999] setAlpha:1];
        }
        else
        {
            [[self viewWithTag:999] setAlpha:0];
        }
    }];
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = [Localized string:placeholder];
}

- (void)setPlaceholderColor:(NSString *)placeholderColor{
    _placeholderColor = [[UIConfiguration sharedInstance] getColor:placeholderColor];
}

- (UIToolbar *)keyboardToolbarFor:(SEL)action {
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.backgroundColor = [UIColor lightGrayColor];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:action];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];
    return keyboardDoneButtonView;
}



@end
