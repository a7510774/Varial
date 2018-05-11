//
//  TeamMembersViewController.h
//  Varial
//
//  Created by Shanmuga priya on 2/25/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Config.h"
#import "Util.h"
#import "SVPullToRefresh.h"
#import "FriendProfile.h"
#import "YesNoPopup.h"
#import "KLCPopup.h"

@interface TeamMembersViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate,YesNoPopDelegate>
{
    NSMutableArray *TeamMembersList,*searchResult;
    NSString *strMediaUrl;
    int page,searchPage,searchPreviousPage,previousPage;    
    NSURLSessionDataTask *task;
    YesNoPopup *removeConfirmation;
    KLCPopup *removeConfirmationPopup;
    
}

@property (strong) NSString *teamId,*ableToRemove;
@property (weak, nonatomic) IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *TeamMembersTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;


@end
