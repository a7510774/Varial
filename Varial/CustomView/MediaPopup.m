//
//  MediaPopup.m
//  Varial
//
//  Created by Shanmuga priya on 2/20/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MediaPopup.h"
#import "Util.h"

@interface MediaPopup()
@end

@implementation MediaPopup


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    
    [[NSBundle mainBundle] loadNibNamed:@"MediaPopup" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    if([SESSION getBoolValue]) {
        _profileUpdateView.hidden = YES;
        [Util createBottomLine:_CameraView withColor:[UIColor lightGrayColor]];
        _MyconstraintContainerHeight.constant = 160.0;
    }
    
    
    [_cameraButton setTitle: NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
    [_galleryButton setTitle: NSLocalizedString(@"Gallery", nil) forState:UIControlStateNormal];
    [_myBtnProfileUpdate setTitle: NSLocalizedString(@"Profile Update", nil) forState:UIControlStateNormal];
    
    [_okButton setTitle: NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];

    [self addSubview:self.mainView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    
//    [Util createBottomLine:_CameraView withColor:[UIColor lightGrayColor]];
}



- (IBAction)doCamera:(id)sender {
    [self.delegate onCameraClick];
}

- (IBAction)doGallery:(id)sender {
    [self.delegate onGalleryClick];
}

- (IBAction)doOk:(id)sender {
    [self.delegate onOkClick];
}

- (IBAction)myBtnDoProfileUpdate:(id)sender {
    [self.delegate onProfileUpdateClick];
}
@end
