//
//  PointsActivityLog.h
//  Varial
//
//  Created by jagan on 17/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "Config.h"
#import "InAppPurchaseManager.h"
#import "RedirectNotification.h"
#import "SVPullToRefresh.h"

@interface PointsActivityLog : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    int page, previousPage;
    NSString *mediaBase;
    UIRefreshControl *refreshControl;
}

@property (strong) NSString *friendId, *teamId;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *pointsTable;



@end
