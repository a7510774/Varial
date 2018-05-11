//
//  BuyPointsViewController.h
//  Varial
//
//  Created by jagan on 18/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "Config.h"
#import "InAppPurchaseManager.h"
#import "MyProfile.h"
#import "SVPullToRefresh.h"

@interface BuyPointsViewController : UIViewController{
    NSMutableArray *pointsList;
    int page;
}
@property (nonatomic,assign) BOOL isTeamBuy;
@property (strong) NSString *teamId;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *pointsTable;

@end
