//
//  FriendProfile.h
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
#import "ResponsePopup.h"
#import "PostDetails.h"
#import "MyProfile.h"
#import "KLCPopup.h"
#import "MLKMenuPopover.h"
#import "YesNoPopup.h"
#import "Menu.h"
#import "ProfileView.h"
#import "GoogleAdMob.h"
@interface FriendProfile : UIViewController<UITableViewDataSource,UITableViewDelegate,PointsPopupDelegate,ResponseDelegate,YesNoPopDelegate,TTTAttributedLabelDelegate,YesNoPopDelegate,MLKMenuPopoverDelegate,MenuDelegate,ProfileViewDelegate,HeaderViewDelegate,AdMobDelegate>
{
    KLCPopup *KLCpointPopup, *responsePopup,*blockPopUp,*menuPopup;
    NSMutableArray *friendsList,*feedList;
    int friendsPage,feedPage,friendStatus,row,friendPreviousPage,selectedPostIndex;
    PointsPopup *pointPopup;
    ResponsePopup *responsePopupView;
    NSString *strMediaUrl,*feedImageUrl, *jabberId, *profileImageURL, *friendJID;
    NSIndexPath *menuPosition;
    UIImage *profilePicture;
    YesNoPopup *blockConfirmation;
    NSMutableDictionary *friendProfileData;
    AppDelegate *appDelegate;
    NSDictionary *reportFeed;
    Menu *menu;
    NSArray *reportType;
    BOOL profileLoading, feedsLoading;
    UIRefreshControl *refreshControl;
    NSMutableDictionary * cellHeightsDictionary;
}

@property(nonatomic,strong) MLKMenuPopover *reportPopover;
@property (weak, nonatomic) IBOutlet ProfileView *profileView;
//@property (weak, nonatomic) IBOutlet UIImageView *starImage;
//@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong)  NSString  *friendId, *friendName;
//@property (weak, nonatomic) IBOutlet UIImageView *boardImage;
//@property (weak, nonatomic) IBOutlet UIView *viewLeft;
//@property (weak, nonatomic) IBOutlet UIButton *btnPoints;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIView *ProfileHolder;
@property (weak, nonatomic) IBOutlet UITableView *profileTable;
//@property (weak, nonatomic) IBOutlet UIButton *btnMore;
//@property (weak, nonatomic) IBOutlet UILabel *name;
//@property (weak, nonatomic) IBOutlet UILabel *points;
//@property (weak, nonatomic) IBOutlet UILabel *rank;
//@property (weak, nonatomic) IBOutlet UIButton *searchButton;
//@property (weak, nonatomic) IBOutlet UILabel *statusLable;
@property (weak, nonatomic) IBOutlet UILabel *chatLable;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;

@property (strong, nonatomic) NSString *strFollow, *strFrndRelationshipStatus;

@property (strong, nonatomic) NSString *strNameTag;

//@property (weak, nonatomic) IBOutlet UIButton *respondButton;

- (IBAction)moveToSearch:(id)sender;
- (IBAction)tappedSegment:(id)sender;
- (IBAction)respondToUser:(id)sender;
- (IBAction)openPointsPopup:(id)sender;
- (IBAction)moveToChat:(id)sender;

- (void)addEmptyMessageForProfileTable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintProfileViewHeaderHeight;

@end
