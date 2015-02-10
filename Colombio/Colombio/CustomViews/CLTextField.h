//
//  CLTextField.h
//  Colombio
//
//  Created by Vlatko Šprem on 19/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Used for text input fields with image notifications!
//  Implement in IB, use UIView object and change class to CLTextField.
//  Key properties can be set in User defined runtime attributes section.

@interface CLTextField : UIView<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *txtField;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, weak) NSString *placeholderText;
@property (nonatomic, weak) NSString *errorText;
@property (nonatomic, weak) NSString *keyboardType; //KEYBOARD_DEFAULT, KEYBOARD_NUMERIC, KEYBOARD_DIAL, KEYBOARD_EMAIL
@property (nonatomic, assign) BOOL isNumber; //used for setting if TextField is number, you can also check keyboard type
@property (nonatomic, assign) BOOL isPassword; //used to set if text input is in password style
@property (nonatomic, assign) BOOL wrongInput; //used to set error placeholder if wrong input

@property (nonatomic, weak) IBOutlet id <UITextFieldDelegate> textFieldDelegate; //you can connect it in IB!

- (id)initWithFrame:(CGRect)frame;
- (void)setOkInput;

@end
