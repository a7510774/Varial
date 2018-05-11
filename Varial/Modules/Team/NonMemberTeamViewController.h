//
//  NonMemberTeamViewController.h
//  Varial
//
//  Created by Shanmuga priya on 2/25/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "KLCPopup.h"
#import "PointsPopup.h"
#import "BuyPointsViewController.h"
#import "PointsActivityLog.h"
#import "TeamMembersViewController.h"
#import "YesNoPopup.h"
#import "FeedsDesign.h"
#import "TTTAttributedLabel.h"
#import "MLKMenuPopover.h"
#import "Menu.h"

@interface NonMemberTeamViewController : UIViewController<UITableViewDataSource,UITabBarDelegate,PointsPopupDelegate,TTTAttributedLabelDelegate,YesNoPopDelegate,MLKMenuPopoverDelegate,MenuDelegate>
{
    KLCPopup *pointPopup, *teamPopup;
    YesNoPopup *popupView;
    PointsPopup *pointsPopupView;
    NSMutableArray *members, *feeds;
    int page,previousPage;
    NSString *mediaBase, *teamMediaBase;
    NSMutableDictionary *teamDetails, *teamDetailsToDonate;
    AppDelegate *appDelegate;
    BOOL is_Invite;
    NSString *joinMinimumPoints;
    
    YesNoPopup *blockConfirmation,*deleteConfirmation;
    KLCPopup *blockPopUp,*deletePopup;
    NSDictionary *reportFeed;
    Menu *menu;
    KLCPopup *menuPopup;
    NSArray *reportType;
    int selectedPopup;
    NSIndexPath *menuPosition;
    
}
@property(nonatomic,strong) MLKMenuPopover *reportPopover;
@property (nonatomic) BOOL canLike, canComment;
@property (strong) NSString *teamId;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UITableView *nonMemberTable;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
- (IBAction)showPoints:(id)sender;


@property (weak, nonatomic) IBOutlet UIImageView *captainImage;
@property (weak, nonatomic) IBOutlet UIImageView *teamImage;
@property (weak, nonatomic) IBOutlet UIImageView *coCaptainImage;
@property (weak, nonatomic) IBOutlet UILabel *teamName;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *captainName;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *coCapTainName;
@property (weak, nonatomic) IBOutlet UILabel *rank;
@property (weak, nonatomic) IBOutlet UILabel *points;
- (IBAction)searchMembers:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
- (IBAction)tappedSegment:(id)sender;

- (void)addEmptyMessageForTeamTable;


@property (weak, nonatomic) IBOutlet UIButton *btnPoints;
@end
