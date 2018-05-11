//
//  PostBuzzardRun.h
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "Config.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "FriendProfile.h"
#import "MyProfile.h"
#import "YesNoPopup.h"
#import "KLCPopup.h"
#import "TTTAttributedLabel.h"
#import "CreatePostViewController.h"
#import "BuzzardRunPostDetails.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PostBuzzardRun : UIViewController<UITableViewDataSource,UITableViewDelegate,YesNoPopDelegate,TTTAttributedLabelDelegate>
{
    int selectedTab;
    NSString *mediaBaseUrl;
    NSIndexPath *menuPosition;
    YesNoPopup *popupView;
    KLCPopup *yesNoPopup;
    int selectedPostIndex, page, previousPage;
    NSString *eventDetails;
    BOOL isDelete, canPost, canSubmit, expiry;
    AppDelegate *delegate;
    UIImageView *thumbImage;
    BOOL pullToRefreshAtTop;
    AVPlayerViewController *playerViewController;
}

@property (strong,nonatomic) MPMoviePlayerViewController *player;
@property(nonatomic,retain) NSMutableArray *feeds, *uploadCancelArray;
@property (strong) NSString *buzzardRunName, *buzzardRunId, *buzzardRunEventId, *shopName, *eventName, *canShowPost;
@property (strong) NSString *bigVideoUrl, *currentVideoUrl;


@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong)IBOutlet UITableView *postTable;

@property (nonatomic, strong) IBOutlet UIView *tabView;
@property (nonatomic, strong) IBOutlet UIButton *postTab;
@property (nonatomic, strong) IBOutlet UIButton *detailsTab;

-(IBAction)postButton:(id)sender;
-(IBAction)detailsButton:(id)sender;


@property (nonatomic, strong) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) IBOutlet UIView *submitforApprovalView;
@property (nonatomic, strong) IBOutlet UIView *addPostView;

-(IBAction)tappedMenuButton:(id)sender;
-(IBAction)addPost:(id)sender;
-(IBAction)submitForApproval:(id)sender;
-(IBAction)cancelView:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *details;
@property (weak, nonatomic) IBOutlet UIWebView *detailsView;

@end
