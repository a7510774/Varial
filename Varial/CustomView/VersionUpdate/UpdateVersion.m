//
//  UpdateVersion.m
//  Varial
//
//  Created by vis-1674 on 03/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "UpdateVersion.h"
#import "Util.h"

@interface UpdateVersion()
@end

@implementation UpdateVersion

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {

    [[NSBundle mainBundle] loadNibNamed:@"UpdateVersion" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    [self addSubview:self.mainView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _updateLabel.text = NSLocalizedString(@"A newer version of varial is available. Click to update", nil);
    [_updateButton setTitle:NSLocalizedString(@"Update", nil) forState:UIControlStateNormal];
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    [Util createRoundedCorener:_updateButton withCorner:3];
    [Util createRoundedCorener:_cancelButton withCorner:3];

}

- (IBAction)doUpdate:(id)sender {
    [self.delegate onUpdateClick];
}

- (IBAction)doCancel:(id)sender {
    [self.delegate onCancelClick];
}


@end
