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
@property (nonatomic, assign) BOOL isNumber;
@property (nonatomic, assign) BOOL wrongInput;

- (id)initWithFrame:(CGRect)frame;
@end
