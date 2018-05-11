//
//  Forward.h
//  Varial
//
//  Created by vis-1674 on 05/07/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "AppDelegate.h"

@interface Forward : UIViewController<UITableViewDelegate, UITableViewDataSource>{

    NSMutableArray *recentChats, *searchRecentChats, *friends, *searchFriends, *teams;
    int page, previousPage, searchPage, searchPreviousPage, selectedTab;
    NSURLSessionDataTask *task;
    NSString *strMediaUrl;
    AppDelegate *appDelegate;
}

@property (strong) NSMutableDictionary *message;

//Header view
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *recentChat;
@property (weak, nonatomic) IBOutlet UIButton *friendsMenu;
@property (weak, nonatomic) IBOutlet UIButton *teamMenu;
- (IBAction)showRecentChats:(id)sender;
- (IBAction)showTeams:(id)sender;
- (IBAction)showFriends:(id)sender;


//Recent
@property (weak, nonatomic) IBOutlet UIView *recentView;
@property (weak, nonatomic) IBOutlet UITextField *recentSearch;
@property (weak, nonatomic) IBOutlet UIButton *recentClear;
- (IBAction)clearRecent:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *recentTable;
@property (weak, nonatomic) IBOutlet UIButton *recentSearchIcon;
@property (weak, nonatomic) IBOutlet UIView *headerMenu;


//Friends
@property (weak, nonatomic) IBOutlet UIView *friendsView;
@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
@property (weak, nonatomic) IBOutlet UITextField *friendsSearch;
@property (weak, nonatomic) IBOutlet UIButton *friendClear;
- (IBAction)clearFriends:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *friendsSearchIcon;

//Team
@property (weak, nonatomic) IBOutlet UIView *teamView;
@property (weak, nonatomic) IBOutlet UITableView *teamTable;

@end
