//
//  MyCheckinDetails.h
//  Varial
//
//  Created by vis-1041 on 3/22/16.
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
#import "MLKMenuPopover.h"
#import "Menu.h"

@interface MyCheckinDetails : UIViewController<UITableViewDataSource,UITableViewDelegate,YesNoPopDelegate,TTTAttributedLabelDelegate,MLKMenuPopoverDelegate,MenuDelegate>
{
    NSMutableArray *feeds;
    NSString *mediaBaseUrl;
    NSIndexPath *menuPosition;
    YesNoPopup *popupView;
    KLCPopup *yesNoPopup;
    int selectedPostIndex, page , previousPage;
    BOOL isDelete;
    AppDelegate *appDelegate;
    
    YesNoPopup *blockConfirmation;
    KLCPopup *blockPopUp;
    NSDictionary *reportFeed;
    Menu *menu;
    KLCPopup *menuPopup;
    NSArray *reportType;
}
@property(nonatomic)BOOL isFromChannel;
@property(nonatomic,strong) MLKMenuPopover *reportPopover;
@property (strong) NSString *checkinId, *post_Id, *isPopularCheckinDetail;
@property (weak, nonatomic) IBOutlet UITableView *feedsTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
- (void)addEmptyMessageForFeedListTable;

@end
