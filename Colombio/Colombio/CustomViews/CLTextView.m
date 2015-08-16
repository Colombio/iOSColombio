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
    /*if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON];
    }*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //[self setPlaceholder:@""];
        ///[self setPlaceholderColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if ([[self placeholder] length]>0) {
        l = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 0, 0)];
        [l setFont:self.font];
        [l setTextColor:[[UIConfiguration sharedInstance] getColor:_placeholderColor]];
        [l setText:self.placeholder];
        [l setAlpha:0];
        [self viewWithTag:999].hidden=YES;
        [l setTag:999];
        [self addSubview:l];
        [l sizeToFit];
        [self sendSubviewToBack:l];
    }
    if ([[self text] length]==0 && [[self placeholder] length]>0) {
        [[self viewWithTag:999] setAlpha:1];
        [self viewWithTag:999].hidden=NO;
    }
    [super drawRect:rect];
}

- (void)setTextViewDelegate:(id<UITextViewDelegate>)textViewDelegate{
    self.delegate = textViewDelegate;
}

- (void)textBeginEditing:(NSNotification*)notification{
    
    if (notification.object == self) {
        if(_placeholder.length == 0)
        {
            return;
        }else{
            [self viewWithTag:999].alpha=0.0;
            [self viewWithTag:999].hidden=YES;
        }
    }
}

- (void)textEndEditing:(NSNotification*)notification{
    if (((CLTextView*)notification.object).text.length<1 && notification.object == self) {
        [self viewWithTag:999].alpha=1.0;
        [self viewWithTag:999].hidden=NO;
    }
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
            [self viewWithTag:999].hidden=NO;
        }
        else
        {
            [[self viewWithTag:999] setAlpha:0];
            [self viewWithTag:999].hidden=YES;
        }
    }];
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = [Localized string:placeholder];
}

- (void)setPlaceholderColor:(NSString *)placeholderColor{
    _placeholderColor = placeholderColor;
    l.textColor = [[UIConfiguration sharedInstance] getColor:placeholderColor];
}

#pragma mark Set Keyboard Toolbar

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
