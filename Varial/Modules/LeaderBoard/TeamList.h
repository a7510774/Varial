//
//  TeamList.h
//  Varial
//
//  Created by Shanmuga priya on 4/21/16.
//  Copyright © 2016 Velan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Config.h"
#import "Util.h"
#import "SVPullToRefresh.h"
#import "FriendProfile.h"

@interface TeamList : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSMutableArray *teamList,*searchResult;
    NSString *strMediaUrl;
    int page,searchPage,row,teamPreviousPage,searchPreviousPage,relationStatus;
    NSURLSessionDataTask *task;

}


@property (weak, nonatomic) IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *teamTable;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;



@end
