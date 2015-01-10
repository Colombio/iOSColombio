//
//  CLTextField.h
//  Colombio
//
//  Created by Vlatko Šprem on 19/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

@interface CLTextField : UIView<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *txtField;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, weak) NSString *placeholderText;
@property (nonatomic, weak) NSString *errorText;
@property (nonatomic, weak) NSString *keyboardType;//KEYBOARD_DEFAULT, KEYBOARD_NUMERIC, KEYBOARD_DIAL, KEYBOARD_EMAIL
@property (nonatomic, assign) BOOL isNumber;//mozda visak, koristiti keyboardType za provjeru
@property (nonatomic, assign) BOOL isPassword;
@property (nonatomic, assign) BOOL wrongInput;

@property (nonatomic, weak) IBOutlet id <UITextFieldDelegate> textFieldDelegate;

- (id)initWithFrame:(CGRect)frame;
@end
