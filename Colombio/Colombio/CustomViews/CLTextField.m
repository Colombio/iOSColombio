//
//  CLTextField.m
//  Colombio
//
//  Created by Vlatko Šprem on 19/12/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "CLTextField.h"
#import "Validation.h"

@implementation CLTextField

- (id)initWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isNumber=NO;
        _txtField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-45, self.frame.size.height)];
        _txtField.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
        _txtField.returnKeyType = UIReturnKeyDone;
        [_txtField setTextColor:[UIColor colorWithWhite:1 alpha:0.65]];
        [self addSubview:_txtField];
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-45, 11, 25, 25)];
        _imgView.image = TXT_FIELD_INPUT_IMG;
        [_imgView setHidden:YES];
        [self addSubview:_imgView];
        
        if (_txtField.text.length==0) {
            _txtField.placeholder = self.placeholderText;
        }
        _txtField.keyboardAppearance = UIKeyboardAppearanceLight;
        _txtField.spellCheckingType = UITextSpellCheckingTypeNo;
        _txtField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    
    if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        gestureRecognizer.enabled=NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}

/*- (void)awakeFromNib{
    _isNumber=NO;
    _txtField = [[UITextField alloc] initWithFrame:CGRectMake(45, 0, self.frame.size.width-90, self.frame.size.height)];
    _txtField.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
    _txtField.keyboardType  = UIKeyboardTypeDefault;
    _txtField.returnKeyType = UIReturnKeyNext;
    [_txtField setTextColor:[UIColor colorWithWhite:1 alpha:0.65]];
    [self addSubview:_txtField];
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-65, 11, 25, 25)];
    _imgView.image = TXT_FIELD_INPUT_IMG;
    [_imgView setHidden:YES];
    [self addSubview:_imgView];
    
    if (_txtField.text.length==0) {
        _txtField.placeholder = self.placeholderText;
    }
}*/

//set txt properties
@synthesize placeholderText=_placeholderText, errorText=_errorText, isNumber=_isNumber;

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = [Localized string:placeholderText];
    _txtField.placeholder = _placeholderText;
    _txtField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:_placeholderText attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.5], NSFontAttributeName:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT]}];
    [_imgView setHidden:YES];
}

- (void)setErrorText:(NSString *)errorText
{
    _errorText = [Localized string:errorText];
    [_imgView setHidden:NO];
    _txtField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:_errorText attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.5]}];
    _txtField.text=@"";
    _imgView.image = TXT_FIELD_FAIL_IMG;
}

- (void)setOkInput{
    [_imgView setHidden:NO];
    _imgView.image = TXT_FIELD_PASS_IMG;
}

- (void)setKeyboardType:(NSString *)keyboardType{
    _txtField.keyboardType = [[UIConfiguration sharedInstance] getKeyboardType:keyboardType];
}

- (void)setIsNumber:(BOOL)isNumber
{
    _isNumber=isNumber;
    if (_isNumber) {
        _txtField.keyboardType = UIKeyboardTypeNumberPad;
    }
}

- (void)setIsPassword:(BOOL)isPassword{
    _txtField.secureTextEntry = isPassword;
}

- (void)setWrongInput:(BOOL)wrongInput{
    _wrongInput=wrongInput;
    if(_wrongInput){
        _txtField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_errorText attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    }
}

- (void)setTextFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate{
    _txtField.delegate=textFieldDelegate;
}

#pragma mark TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (_isNumber && ![Validation isNumber:string]) {
        return NO;
    }
    return YES;
}

@end
