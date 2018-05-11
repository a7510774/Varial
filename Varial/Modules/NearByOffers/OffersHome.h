//
//  OffersHome.h
//  Varial
//
//  Created by Shanmuga priya on 3/15/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "OffersList.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "SVPullToRefresh.h"
@interface OffersHome : UIViewController<UITableViewDataSource,UITableViewDelegate,UITabBarDelegate>{
    int page,previousPage;
    NSMutableArray *fromShopList, *nearByList;
    NSString *mediaBase;
    BOOL locationUpdated;
    int selectedTabBar;
}

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *viewOfferListButton;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabOne;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *nearByTableView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;


- (IBAction)viewOfferList:(id)sender;
- (IBAction)enableLocationService:(id)sender;

@end
