//
//  SetPhoneNumberPopup.m
//  Varial
//
//  Created by Shanmuga priya on 3/8/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "SetPhoneNumberPopup.h"


@implementation SetPhoneNumberPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    
    [[NSBundle mainBundle] loadNibNamed:@"SetPhoneNumberPopup" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    [self addSubview:self.mainView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _header.text = NSLocalizedString(@"SET PHONE NUMBER", nil);
    _country.text = NSLocalizedString(@"Country", nil);
    _phoneNumber.text = NSLocalizedString(@"Enter Your Phone  Number", nil);
    
    [_saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    [Util createRoundedCorener:_saveButton withCorner:3];
    [Util createRoundedCorener:_cancelButton withCorner:3];
}

- (IBAction)doSave:(id)sender {
    [self.delegate onSaveClick];
}

- (IBAction)doCancel:(id)sender {
    [self.delegate onCancelClick];
}
@end
