//
//  MyFriends.h
//  Varial
//
//  Created by jagan on 11/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Config.h"
#import "Util.h"
#import "SVPullToRefresh.h"
#import "FriendProfile.h"
//#import "ChatDBManager.h"

@interface MyFriends : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,HeaderViewDelegate>
{
    NSMutableArray *friendsList,*searchResult;
    NSString *strMediaUrl;
    int page,searchPage,row,friendsPriviousPage,searchPreviousPage;
    NSURLSessionDataTask *task;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addFriendsBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *friendsTableTopConstraint;

@property (strong)  NSString  *friendId,*friendName;
@property (nonatomic) BOOL fromChat;
@property (nonatomic) BOOL isFromFollowers, isFromFollowing, isFromFriendsFollowers;
@property (weak, nonatomic) IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *firendsTable;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
- (IBAction)addFriend:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;

@end
