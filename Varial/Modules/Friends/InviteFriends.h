//
//  InviteFriends.h
//  Varial
//
//  Created by jagan on 11/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "SVPullToRefresh.h"
#import "FriendProfile.h"

@interface InviteFriends : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NetworkDelegate>
{
    NSMutableArray *inviteFriendsList;
    NSMutableDictionary *emailList;
    NSString *strMediaUrl;
    NetworkAlert *emailInviteView;
    KLCPopup *inviteEmailPopup;
    NSURLSessionDataTask *task;
   
    int page,previousPage;
    BOOL search;
}

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *inviteEmailView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *sendInviteButton;
@property (weak, nonatomic) IBOutlet UITableView *inviteFriendTableView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (nonatomic,strong) NSString *getSearchString;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteFriendTableBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlHeightConstraint;


@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControlCategory;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTblViewY;


- (IBAction)tappedInviteButton:(id)sender;
- (IBAction)sendInvite:(id)sender;
- (IBAction)tappedSearchClear:(id)sender;



@end
