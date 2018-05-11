//
//  TeamInvitiesViewController.h
//  Varial
//
//  Created by Shanmuga priya on 2/25/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "SVPullToRefresh.h"
#import "FriendProfile.h"
#import "TeamMembersViewController.h"
#import "YesNoPopup.h"
#import "KLCPopup.h"
#import "Team.h"
#import "TeamViewController.h"

@interface TeamInvitiesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,YesNoPopDelegate>
{
    KLCPopup *yesNoPopup;
    YesNoPopup *popupView;
    NSMutableArray *teamList, *searchList, *titleList;
    NSString *strMediaUrl;
    NSURLSessionDataTask *task;
    int page, previousPage,row, searchpage, searchPreviousPage;
    
    // View Invities
    UITableViewCell *viewInvitiesRowSelected;
    NSIndexPath *viewInvitiesIndexPath;
    int viewInvitiesSearchTable;
    NSMutableDictionary *viewInvitiesSelectedValues;
}

@property (strong) NSString *teamId, *roomId, *type, *isCreateTeam, *selectCaptainFromListPage, *teamName, *teamImage, *coCaptainName;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *TeamTableView;
@property (weak, nonatomic) IBOutlet UITableView *SearchTableView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *doneView;




- (IBAction)tappedInviteButton:(id)sender;
- (IBAction)tappedSearchClear:(id)sender;
- (IBAction)tappedDone:(id)sender;


@end
