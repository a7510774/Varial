
//
//  EditInfoPopup.m
//  Varial
//
//  Created by Shanmuga priya on 2/29/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "EditInfoPopup.h"
#import "Util.h"

@implementation EditInfoPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    
    [[NSBundle mainBundle] loadNibNamed:@"EditInoPopup" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    [self addSubview:self.mainView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _header.text = NSLocalizedString(@"EDIT INFORMATION", nil);
    [_emailButton setTitle: NSLocalizedString(@"Email", nil) forState:UIControlStateNormal];
    [_phoneButton setTitle: NSLocalizedString(@"Phone number", nil) forState:UIControlStateNormal];
    [_locationButton setTitle: NSLocalizedString(@"Set Location", nil) forState:UIControlStateNormal];
    
    [Util createBorder:_emailButton withColor:UIColorFromHexCode(GREY_BORDER)];
    [Util createBorder:_phoneButton withColor:UIColorFromHexCode(GREY_BORDER)];
    [Util createBorder:_locationButton withColor:UIColorFromHexCode(GREY_BORDER)];
   
}

- (IBAction)doChangePhoneNumber:(id)sender {
    [self.delegate onChangePhoneNoClick];
}

- (IBAction)doChangeEmail:(id)sender {
    [self.delegate onChangeEmailClick];
}

- (IBAction)doChangeLocation:(id)sender {
    [self.delegate onChangeLocationClick];
}
@end
