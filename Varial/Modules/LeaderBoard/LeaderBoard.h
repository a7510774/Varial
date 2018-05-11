//
//  LeaderBoard.h
//  Varial
//
//  Created by jagan on 11/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "KLCPopup.h"
#import "PointsPopup.h"
#import "BuyPointsViewController.h"
#import "PointsActivityLog.h"
#import "NonMemberTeamViewController.h"

@interface LeaderBoard : UIViewController <UITableViewDataSource,UITabBarDelegate,PointsPopupDelegate>{
    int page,previousPage,teamPage,teamPreviousPage;
    NSMutableArray *leaders,*team;
    NSString *mediaBase;
    KLCPopup *pointPopup;
    PointsPopup *pointsPopupView;
    int selectedTab;

}

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *board;
@property (weak, nonatomic) IBOutlet UILabel *rank;
@property (weak, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) IBOutlet UITableView *leaderBoardTable;
@property (weak, nonatomic) IBOutlet UIView *leaderBoardHeaderView;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UITableView *TeamTableView;
@property (weak, nonatomic) IBOutlet UIView *teamHeaderView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)openPointsPopup:(id)sender;
- (IBAction)openPointsInformation:(id)sender;
- (IBAction)openTeampoints:(id)sender;
- (IBAction)searchList:(id)sender;


@property (nonatomic, strong) IBOutlet UIView *tabView;
@property (nonatomic, strong) IBOutlet UIButton *playerTab;
@property (nonatomic, strong) IBOutlet UIButton *teamTab;
-(IBAction)generalButton:(id)sender;
-(IBAction)eventsButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPoints;

@end
