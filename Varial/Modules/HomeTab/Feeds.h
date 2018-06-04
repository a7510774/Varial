//
//  Feeds.h
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertMessage.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "UIImageView+AFNetworking.h"
#import "SVPullToRefresh.h"
#import "CreatePostViewController.h"
#import "EditPostViewController.h"
#import "ShowCheckinInMap.h"
#import "YesNoPopup.h"
#import "FriendProfile.h"
#import "TeamViewController.h"
#import "MLKMenuPopover.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LocalStorageManager.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "Menu.h"

@class FeedsDesign;

@interface Feeds : UIViewController<UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,YesNoPopDelegate,MLKMenuPopoverDelegate,MenuDelegate>{
    KLCPopup *feedTypePopup, *yesNoPopup;
    NSMutableArray *feeds,*feedTypeList;
    NSString *selectedFeedTypeName, *feedTypeId;
    NSString *mediaBaseUrl;
    int post_id, recent, selectedPostIndex;
    BOOL isDelete;
    NSIndexPath *menuPosition;
    YesNoPopup *popupView;
    int selectedyesNoPopUp;
    int feed_type;
    NSString *movePostId, *movePostTypeId;
    NSTimer *timer;
    float time;
    AppDelegate *appDelegate;
    FeedsDesign *feedsDesign;
    YesNoPopup *blockConfirmation;
    KLCPopup *blockPopUp;
    NSDictionary *reportFeed;
    Menu *menu;
    KLCPopup *menuPopup;
    NSArray *reportType;
    BOOL clearData;
    UIRefreshControl *refreshControl;
    NSMutableDictionary * cellHeightsDictionary;
    NSDictionary *currentAdInfo;
}

@property(strong)NSString *selectedFeedType;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedTypeHeight;

// Menu View
@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic,strong) MLKMenuPopover *reportPopover;

@property(nonatomic,strong) MLKMenuPopover *sharedMenuPopover;
@property(nonatomic,strong) MLKMenuPopover *sharedReportPopover;

@property (weak, nonatomic) IBOutlet UITableView *feedsTable;

@property (weak, nonatomic) IBOutlet UITableView *feedsTypesTable;

@property (weak, nonatomic) IBOutlet UIView *feedTypesView;

@property (weak, nonatomic) IBOutlet UIButton *btnFeedTypes;

@property (weak, nonatomic) IBOutlet UILabel *feedTypeName;

@property (weak, nonatomic) IBOutlet UIImageView *feedTypeImage;

- (IBAction)feedTypes:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *feedsIcon;
- (IBAction)moveToTop:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *addPost;

- (CGFloat)cellHeight:(NSMutableDictionary *)data;

- (void)buildFeedData:(UITableViewCell *) cell forFeedData:(NSMutableDictionary *) currentFeed;
- (void)addEmptyMessageForFeedListTable;

- (void)updateLocalStorage;
- (void)getFeedsTypesList;
- (void)uploadPost:(NSMutableDictionary *)inputparams Media:(NSMutableArray *)medias feedType:(NSString *)type getIndex:(int)index;
- (void)showFeedTypes;

@end
