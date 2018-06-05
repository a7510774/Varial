//
//  MyProfile.h
//  Varial
//
//  Created by Shanmuga priya on 2/13/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "KLCPopup.h"
#import "PointsPopup.h"
#import "BuyPointsViewController.h"
#import "PointsActivityLog.h"
#import "MediaPopup.h"
#import "EditInfoPopup.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "PECropViewController.h"
#import "LLARingSpinnerView.h"
#import "UIImageView+AFNetworking.h"
#import "FriendProfile.h"
#import "PostDetails.h"
#import "CreatePostViewController.h"
#import "SearchViewController.h"
#import "DonatePoint.h"
#import "MLKMenuPopover.h"
#import "MyCheckins.h"
#import "Board.h"
#import "ShoppingHome.h"
#import "ProfileView.h"
#import "StoriesCollectionViewCell.h"
#import "ProfileUpdateViewController.h"
@interface MyProfile : UIViewController<UITableViewDataSource,UITableViewDelegate,PointsPopupDelegate,MediaPopupDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, PECropViewControllerDelegate,EditInfoPopupDelegate,NetworkDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,TTTAttributedLabelDelegate,YesNoPopDelegate,MLKMenuPopoverDelegate,UIPopoverControllerDelegate, ProfileViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource, senddataProtocol>
{
    KLCPopup *editNamePopup, *editProfilePopup, *editDashboardPopup, *KLCpointPopup, *KLCMediaPopup, *KLCEditInfoPopup, *setEmailPopup, *setPhonePopup, *otpPopup, *emailConfirmationPopup, *changeEmailPopup, *changePhonePopup, *yesNoPopup, *setLocationPopup;
    NSArray *textFields;
    NSMutableArray *countries;
    UIPickerView *countryPicker;
    NetworkAlert *emailConfirmation;
    NSTimer *countDown;
    int secondsLeft;
    NSIndexPath *menuPosition;
    NSMutableArray *friendsList,*boardList,*feedList,*profileImagesArr;
    int friendsPage,boardPage,feedPage,friendsPrevious,selectedPostIndex;
    PointsPopup *pointPopup;
    MediaPopup *mediaPopup;
    EditInfoPopup *editInfo;
    NSString *strMediaUrl,*feedImageUrl,*myProfile;
    UIImage *profilePicture;
    BOOL havingEmail,havingPhoneNumber,canRedeem;
    NSString *countryId,*oldCountryId,*oldCounCode, *oldPhNo;
    YesNoPopup *popupView;
    int visibleWindow;
    NSString *profileImageUrl;
    NSString *currentLocation;
    AppDelegate *appDelegate;
    KLCPopupLayout layout;
    UIImagePickerController *controller;
    UIRefreshControl *refreshControl;
    BOOL profileLoading,feedsLoading,isFromProfileUpdate;
    NSMutableDictionary * cellHeightsDictionary;
}
@property (nonatomic) NSUInteger needToReload;
@property (weak, nonatomic) IBOutlet ProfileView *profileView;
@property(strong) NSString * userName;
//@property (weak, nonatomic) IBOutlet UIImageView *starImage;
//@property (weak, nonatomic) IBOutlet UIImageView *boardImage;
//@property (weak, nonatomic) IBOutlet UIImageView *imgViewProfile;
//@property (weak, nonatomic) IBOutlet UIView *viewLeft;
//@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
//@property (weak, nonatomic) IBOutlet UIButton *btnPoints;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
//@property (weak, nonatomic) IBOutlet UIButton *btnEditImage;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIView *statusBackground;

@property (weak, nonatomic) IBOutlet UIView *ProfileHolder;
@property (weak, nonatomic) IBOutlet UITableView *profileTable;
//@property (weak, nonatomic) IBOutlet UIButton *btnMore;
//@property (weak, nonatomic) IBOutlet TTTAttributedLabel *name;
//@property (weak, nonatomic) IBOutlet UILabel *points;
//@property (weak, nonatomic) IBOutlet UILabel *rank;
@property (weak, nonatomic) IBOutlet LLARingSpinnerView *spinnerView;
@property (weak, nonatomic) IBOutlet UIButton *addPostButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)addPost:(id)sender;
- (IBAction)moveToSearch:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *boardTable;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintProfileViewHeaderHeight;


//- (IBAction)tappedSegment:(id)sender;
//- (IBAction)tappedEditName:(id)sender;
//- (IBAction)tappedEditProfile:(id)sender;
//- (IBAction)tappedEditDashboard:(id)sender;
//- (IBAction)tappedPoints:(id)sender;
//- (IBAction)tappedOption:(id)sender;
- (IBAction)setDefaultCountry:(id)sender;

// Menu View
@property(nonatomic,strong) MLKMenuPopover *menuPopover;

//Edit Name
@property (weak, nonatomic) IBOutlet UIView *editNameView;
@property (weak, nonatomic) IBOutlet UIButton *btnEditNameSave;
@property (weak, nonatomic) IBOutlet UIButton *btnEditNameCancel;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
- (IBAction)tappedEditNameCancel:(id)sender;
- (IBAction)tappedEditNameSave:(id)sender;

//Edit Profile
@property (weak, nonatomic) IBOutlet UIView *editProfileView;
@property (weak, nonatomic) IBOutlet UIButton *btnEditProfileCancel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) UIPopoverController *popover;
- (IBAction)tappedEditProfileCancel:(id)sender;

//EditDashBoard
@property (weak, nonatomic) IBOutlet UIView *editDashboardView;


//Set email id
@property (weak, nonatomic) IBOutlet UIView *setEmailView;
@property (weak, nonatomic) IBOutlet UITextField *setEmail;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *saveEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelEmailButton;
- (IBAction)setEmailAction:(id)sender;
- (IBAction)cancelSetEmail:(id)sender;



//OTP window
@property (weak, nonatomic) IBOutlet UILabel *otpMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *otpView;
@property (weak, nonatomic) IBOutlet UITextField *otpCode;
@property (weak, nonatomic) IBOutlet UIButton *otpSubmitButton;
@property (weak, nonatomic) IBOutlet UIButton *otpResendButton;
- (IBAction)submitOTP:(id)sender;
- (IBAction)resendOTP:(id)sender;
- (IBAction)cancelOTP:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *otpCancelButton;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;


//Set Phone number
@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UITextField *country;

@property (weak, nonatomic) IBOutlet UITextField *countryCode;
@property (weak, nonatomic) IBOutlet UIButton *savePhoneNumberButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelSetPhoneWindow;
- (IBAction)setPhoneNumber:(id)sender;
- (IBAction)cancelPhoneWindow:(id)sender;
- (IBAction)doTouchCountryField:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumber;


//Change email window
@property (weak, nonatomic) IBOutlet UIView *changeEmailView;
@property (weak, nonatomic) IBOutlet UITextField *changeEmail;
@property (weak, nonatomic) IBOutlet UIButton *changeEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *closeEmailButton;
- (IBAction)changeEmail:(id)sender;
- (IBAction)closeChangeEmail:(id)sender;

//Change phone number
@property (weak, nonatomic) IBOutlet UIView *changePhoneView;
@property (weak, nonatomic) IBOutlet UITextField *oldCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *oldPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *changeCountry;
@property (weak, nonatomic) IBOutlet UITextField *neCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *nePhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *changePhoneSaveButton;
@property (weak, nonatomic) IBOutlet UIButton *closeChangePhoneButton;
- (IBAction)changePhoneNumber:(id)sender;
- (IBAction)closeChangePhoneWindow:(id)sender;
- (IBAction)showMore:(id)sender;

//Change location
@property (weak, nonatomic) IBOutlet UIView *setLocationView;
@property (weak, nonatomic) IBOutlet UITextField *locationField;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)addEmptyMessageForProfileTable;

- (void)setHeaderVisible:(BOOL)visible;

@end
