//
//  BlockedUsers.h
//  Varial
//
//  Created by vis-1674 on 2016-02-06.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"
#import "HeaderView.h"
#import "SVPullToRefresh.h"

@interface BlockedUsers : UIViewController
{
    NSMutableArray *blockedUsersList;
    NSString *strMediaUrl;
    int page,previousPage;
}

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;


@end
