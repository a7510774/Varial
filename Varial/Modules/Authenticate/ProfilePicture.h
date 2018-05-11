//
//  ProfilePicture.h
//  Varial
//
//  Created by jagan on 29/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertMessage.h"
#import "KLCPopup.h"
#import "PECropViewController.h"
#import "LLARingSpinnerView.h"
#import "UIImageView+AFNetworking.h"
#import "MediaPopup.h"

@interface ProfilePicture : UIViewController< UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, PECropViewControllerDelegate,MediaPopupDelegate>{
    KLCPopup *invitePopup, *friendPopup,*KLCMediaPopup;
    UIImage *profilePicture;
    MediaPopup *mediaPopupView;
    BOOL isMessageShown;
    int visibleWindow;

}

@property (strong) NSString *inviteMessage;

//Invite code
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UITextField *inviteCode;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *applySkipButton;
@property (weak, nonatomic) IBOutlet UIButton *findInvieCodeButton;
- (IBAction)showHowToFind:(id)sender;
- (IBAction)applyInviteCode:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *inviteMessageLabel;

//Freinds accept
@property (weak, nonatomic) IBOutlet UIView *friendView;
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UILabel *message;
- (IBAction)showHomePage:(id)sender;

- (IBAction)chooseProfileImage:(id)sender;

//Main view
@property (weak, nonatomic) IBOutlet UIButton *profileSkip;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
- (IBAction)skipProfilePic:(id)sender;
@property (nonatomic, strong) UIPopoverController *popover;
@property (strong) IBOutlet LLARingSpinnerView *spinnerView;

@end
