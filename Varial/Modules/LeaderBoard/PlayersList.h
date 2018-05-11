//
//  PlayersList.h
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

@interface PlayersList : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSMutableArray *playerList,*searchResult;
    NSString *strMediaUrl;
    int page,searchPage,row,playersPreviousPage,searchPreviousPage;
    NSURLSessionDataTask *task;
}

@property(strong)NSString *listType;

@property (weak, nonatomic) IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *playersTable;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;



@end
