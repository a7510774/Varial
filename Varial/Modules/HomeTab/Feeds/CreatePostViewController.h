//
//  CreatePostViewController.h
//  Varial
//
//  Created by jagan on 08/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "Config.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "KLCPopup.h"
#import "SAMTextView.h"
#import "IQMediaPickerController.h"
#import "IQFileManager.h"

#import "GMImagePickerController.h"

#import "UIImageView+AFNetworking.h"
#import "GoogleCheckin.h"
#import "YesNoPopup.h"
#import "MediaPopup.h"
#import "CheckInViewController.h"
#import "Feeds.h"
#import "PostBuzzardRun.h"
#import "LocationPopup.h"
#import "CheckInPopup.h"
#import "AGEmojiKeyBoardView.h"
#import "URLPreviewView.h"
#import "FeedsDesign.h"
//kp
#import "CLImageEditor.h"
//kp
@protocol CreatePostDelegate <NSObject>

- (void)newPost:(NSDictionary *)postInfo forFeed:(int)feedId;
- (void)newPostWasPosted:(int)feedId;

@end

@interface CreatePostViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,YesNoPopDelegate,MediaPopupDelegate,UITextFieldDelegate,LocationPopupDelegate,CheckInPopupDelegate, UITextViewDelegate,URLPreviewViewDelegate, HeaderViewDelegate, GMImagePickerControllerDelegate,CLImageEditorDelegate, UITabBarDelegate, UIScrollViewDelegate>{
    KLCPopup *recipientPopup, *mediaCountPopup, *yesNoPopup, *mediaPopup,*locationPopup,*checkInPopup;
    
//    IQMediaPickerController *mediaPickerController;
//    UIImagePickerController *capturePicker;

    int maxImage, maxVideo, maxVideoFileSize, maxImageFileSize;
    NetworkAlert *mediaExceed;
    BOOL hasCheckin,tappedChat,isEmojiKeyboard,isVideoTapped,isUrlPreviewShown,firstPreview,mediaAttachment,isPhotoFilter;
    NSArray *postTypeIcons;
    NSMutableDictionary *selectedRecepie;
    YesNoPopup *popupView;
    LocationPopup *locationPopupView;
    CheckInPopup *checkInPopupView;
    MediaPopup *mediaPopupView;
    MBProgressHUD *progressLoader;    
    int selectedIndex;
    KLCPopupLayout layout;
    AppDelegate *appDelegate;
    NSString *previewURL;
    NSURLSessionUploadTask *task;
    PHAsset * asset;
    IBOutlet __weak UIScrollView *_scrollView;
    IBOutlet __weak UIImageView *_imageView;
    
   

}

@property (strong) NSString *postFromProfile, *postFromBuzzardRun, *isPostFromTeam, *isPostFromFeeds;
@property (strong) NSString *buzzardRunName, *buzzardRunId, *buzzardRunEventId;

@property (weak, nonatomic) id<CreatePostDelegate> delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedTypesHeight;
@property (strong)  NSMutableDictionary  *inputParams;
//Main view
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIView *toView;
@property (weak, nonatomic) IBOutlet SAMTextView *comment;


//

@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UIView *composeView;

@property (weak, nonatomic) IBOutlet UIImageView *toIcon;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@property (weak, nonatomic) IBOutlet UIView *checkinView;
@property (weak, nonatomic) IBOutlet UILabel *checkinTitle;
@property (weak, nonatomic) IBOutlet UIButton *clearCheckinButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UIButton *showImageButton;

@property (weak, nonatomic) IBOutlet UIImageView *videoIcon;
@property (weak, nonatomic) IBOutlet UIButton *showVideoIcon;

@property (weak, nonatomic) IBOutlet UIImageView *checkinIcon;
@property (weak, nonatomic) IBOutlet UIButton *showCheckin;

@property (weak, nonatomic) IBOutlet UIView *recipientView;
@property (weak, nonatomic) IBOutlet UITableView *recipientTable;
@property (weak, nonatomic) IBOutlet UITableView *mediaTable;

@property (weak, nonatomic) IBOutlet UIImageView *dropDownIcon;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButton;
@property (weak, nonatomic) IBOutlet URLPreviewView *urlPreview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewHeight;

@property (weak, nonatomic) IBOutlet UIView *dimView;
@property (weak, nonatomic) IBOutlet LLARingSpinnerView *spinnerView;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *spinnerProgressView;
@property (weak, nonatomic) IBOutlet UILabel *cameraLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkInLabel;

- (IBAction)postFeed:(id)sender;
- (IBAction)showRecipes:(id)sender;
- (IBAction)removeCheckin:(id)sender;
- (IBAction)addImage:(id)sender;
- (IBAction)addCheckIn:(id)sender;
- (IBAction)addVideo:(id)sender;
- (IBAction)openEmoji:(id)sender;

@property (nonatomic, strong) PHImageRequestOptions *requestOptions;

////kp
//IBOutlet __weak UIScrollView *_scrollView;
//IBOutlet __weak UIImageView *_imageView;
////kp
@property (strong, nonatomic) IBOutlet UIView *viewChoosePostOptionView;
@property (strong, nonatomic) IBOutlet UIView *viewPhoto;
@property (strong, nonatomic) IBOutlet UIView *viewCamera;
@property (strong, nonatomic) IBOutlet UIView *viewVideo;
@property (strong, nonatomic) IBOutlet UIView *viewCheckIn;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewCamera;

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;


@property (nonatomic, retain) NSMutableArray *autoCompleteArray;
@property (nonatomic, retain) NSMutableArray *autoCompleteFilterArray;

@property (nonatomic, retain) NSMutableArray *selectedArray;

@end
