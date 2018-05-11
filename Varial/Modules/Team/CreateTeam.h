//
//  CreateTeam.h
//  Varial
//
//  Created by Shanmuga priya on 2/26/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "MediaPopup.h"
#import "KLCPopup.h"
#import "PECropViewController.h"
#import "LLARingSpinnerView.h"
#import "Util.h"
#import "TeamViewController.h"

@interface CreateTeam : UIViewController<MediaPopupDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIActionSheetDelegate, PECropViewControllerDelegate>
{
    MediaPopup *mediaPopup;
    KLCPopup *KLCMediaPopup;
    UIImage *profilePicture;
    NSURLSessionTask *task;
    BOOL pictureChanged, buttonClicked;
}

@property (nonatomic) int minimumPoints;
@property (nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *teamNameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *pointsTxtField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

- (IBAction)tappedAddProfilePicture:(id)sender;
- (IBAction)tappedCreateTeam:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *minimumPointsLabel;

@end
