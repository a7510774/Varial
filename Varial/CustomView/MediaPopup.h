//
//  MediaPopup.h
//  Varial
//
//  Created by Shanmuga priya on 2/20/16.
//  Copyright © 2016 Velan. All rights reserved.
//



#import <UIKit/UIKit.h>


@protocol MediaPopupDelegate;

@interface MediaPopup : UIView

@property (assign) id<MediaPopupDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *CameraView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *myBtnProfileUpdate;
@property (weak, nonatomic) IBOutlet UIView *profileUpdateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MyconstraintContainerHeight;

- (IBAction)doCamera:(id)sender;
- (IBAction)doGallery:(id)sender;
- (IBAction)doOk:(id)sender;
- (IBAction)myBtnDoProfileUpdate:(id)sender;


@end

@protocol MediaPopupDelegate <NSObject>

-(void)onCameraClick;
-(void)onGalleryClick;
-(void)onOkClick;
-(void)onProfileUpdateClick;
@end


