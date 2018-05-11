//
//  CheckInPopup.m
//  Varial
//
//  Created by jagan on 07/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "CheckInPopup.h"
#import "Util.h"
@implementation CheckInPopup

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    [[NSBundle mainBundle] loadNibNamed:@"CheckInPopup" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    [self addSubview:self.mainView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _header.text =  NSLocalizedString(@"CURRENT LOCATION", nil);
    _locationField.placeholder = NSLocalizedString(@"Enter the Location", nil);
    
    [_checkInButton setTitle:NSLocalizedString(@"Check In", nil) forState:UIControlStateNormal];
    
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [Util createBottomLine:_locationField withColor:[UIColor lightGrayColor]];
    [Util createRoundedCorener:_checkInButton withCorner:3];
    [Util createRoundedCorener:_cancelButton withCorner:3];

}

- (IBAction)doCheckIn:(id)sender {
    [self.delegate onCheckInClick];
}

- (IBAction)doCancel:(id)sender {
    [self.delegate onCheckInCancelClick];
}
@end
