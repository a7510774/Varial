//
//  SetEmailPopup.m
//  Varial
//
//  Created by Shanmuga priya on 3/8/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "SetEmailPopup.h"

@implementation SetEmailPopup


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    
    [[NSBundle mainBundle] loadNibNamed:@"SetEmailPopup" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    [self addSubview:self.mainView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _header.text = NSLocalizedString(@"SET EMAIL ID", nil);
    
    [_emailID setValue:NSLocalizedString(@"Enter Email ID", nil)forKeyPath:@"_placeholderLabel.text"];
    [_password setValue:NSLocalizedString(@"Password", nil)forKeyPath:@"_placeholderLabel.text"];
    [_confirmPassword setValue:NSLocalizedString(@"Confirm Password", nil)forKeyPath:@"_placeholderLabel.text"];
    
    [_saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    [Util createRoundedCorener:_saveButton withCorner:3];
    [Util createRoundedCorener:_cancelButton withCorner:3];
    [Util createBottomLine:_emailID withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_password withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_confirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}

- (IBAction)doSave:(id)sender {
    [self.delegate onSaveClick];
}

- (IBAction)doCancel:(id)sender {
    [self.delegate onCancelClick];
}
@end
