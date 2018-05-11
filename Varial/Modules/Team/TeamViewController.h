//
//  TeamViewController.h
//  Varial
//
//  Created by Shanmuga priya on 2/24/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "KLCPopup.h"
#import "PointsPopup.h"
#import "MediaPopup.h"
#import "UIImageView+AFNetworking.h"
#import "TeamInvitiesViewController.h"
#import "DonatePoint.h"
#import "PECropViewController.h"
#import "YesNoPopup.h"
#import "BuyPointsViewController.h"
#import "MLKMenuPopover.h"
#import "Util.h"
#import "Config.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "FriendProfile.h"
#import "MyProfile.h"
#import "YesNoPopup.h"
#import "TTTAttributedLabel.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "NonMemberTeamViewController.h"
#import "FriendsChat.h"
#import "Menu.h"


@interface TeamViewController : UIViewController<PointsPopupDelegate,MediaPopupDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,YesNoPopDelegate,MLKMenuPopoverDelegate,TTTAttributedLabelDelegate,PECropViewControllerDelegate,MenuDelegate>
{
    
    KLCPopup *editNamePopup, *editProfilePopup, *KLCpointsPopup, *KLCMediaPopup, *yesNoPopup, *leaveTeamPopup, *leaveTeamMemberPopup, *removeMemberPopup;
    PointsPopup *pointsPopup;
    NSMutableDictionary *teamDetails,*teamDetailsToDonate;
    MediaPopup *mediaPopupView;
    NSString *media_base_url, *team_Message, *teamImageUrl;
    NSMutableArray *memberList, *feeds;
    UIImage *profilePicture;
    YesNoPopup *popupView;
    NSIndexPath *selectedIndex;
    
    int selectedPopup;
    int feedpage, feedPreviousPage, memberpage, memberPreviousPage;
    
    // Feeds    
    NSString *mediaBaseUrl;
    int selectedPostIndex;
    NSIndexPath *menuPosition;
    BOOL isDelete,canRedeem;
    AppDelegate *appDelegate;
    
     KLCPopupLayout layout;
    
    YesNoPopup *blockConfirmation;
    KLCPopup *blockPopUp;
    NSDictionary *reportFeed;
    Menu *menu;
    KLCPopup *menuPopup;
    NSArray *reportType;

}

@property (strong) NSString *teamId, *roomId;
@property(nonatomic,strong) MLKMenuPopover *reportPopover;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *teamName;
@property (weak, nonatomic) IBOutlet UITextField *editTeamName;
@property (weak, nonatomic) IBOutlet UIButton *nameEdit;
@property (weak, nonatomic) IBOutlet UIImageView *captainImage;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *captainName;

@property (weak, nonatomic) IBOutlet UIImageView *teamImage;
@property (weak, nonatomic) IBOutlet UIButton *teamImageEdit;

@property (weak, nonatomic) IBOutlet UIImageView *coCaptainImage;
@property (weak, nonatomic) IBOutlet UIImageView *coCaptainEdit;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *coCaptainName;

@property (weak, nonatomic) IBOutlet UILabel *teamPoints;
@property (weak, nonatomic) IBOutlet UIButton *teamChat;
@property (weak, nonatomic) IBOutlet UILabel *teamChatLabel;
@property (weak, nonatomic) IBOutlet UIButton *addMember;
@property (weak, nonatomic) IBOutlet UILabel *addMemberLabel;

// Menu View
@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic,strong) NSArray *menuItemsCaptain,*menuItemsCoCaptain,*menuItemsMember;

- (IBAction)addMember:(id)sender;
- (IBAction)tappedEditName:(id)sender;
- (IBAction)tappedEditProfile:(id)sender;
- (IBAction)tappedPoints:(id)sender;
- (IBAction)tappedMore:(id)sender;

//Edit Name
@property (weak, nonatomic) IBOutlet UIView *editNameView;
@property (weak, nonatomic) IBOutlet UIButton *btnEditNameSave;
@property (weak, nonatomic) IBOutlet UIButton *btnEditNameCancel;
-(IBAction)saveEditName:(id)sender;
-(IBAction)cancelEditName:(id)sender;

//Edit profile
@property (weak, nonatomic) IBOutlet UIView *editProfileView;
@property (weak, nonatomic) IBOutlet UIImageView *editProfileImage;
@property (weak, nonatomic) IBOutlet UIButton *btnEditProfileCancel;
-(IBAction)cancelEditProfile:(id)sender;

@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) IBOutlet UIButton *btnMemberSearch;
@property (nonatomic, strong) IBOutlet UIButton *btnAddPost;
-(IBAction)memberSearch:(id)sender;
-(IBAction)addPost:(id)sender;

- (void)addEmptyMessageForTeamTable;
@property (weak, nonatomic) IBOutlet UIButton *btnPoints;

@end
