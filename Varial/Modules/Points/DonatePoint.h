//
//  DonatePoint.h
//  Varial
//
//  Created by jagan on 14/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "DonateForm.h"

@interface DonatePoint : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    int teamPage, teamPrevious, memberPage, memberPrevious, teamSearch, teamSearchPrevious, memberSearch, memberSearchPrevious;
    NSMutableArray *members, *searchMembers, *teams, *searchTeams;
    NSString *memberSearchText, *teamSearchText;
    NSURLSessionDataTask *task;
    NSString *mediaBase;

}

@property (nonatomic) NSUInteger donationFrom;
@property (strong) NSString *donatorId;

@property (weak, nonatomic) IBOutlet UILabel *donaterRank;
@property (weak, nonatomic) IBOutlet UILabel *donaterPoints;
@property (weak, nonatomic) IBOutlet UILabel *donaterName;
@property (weak, nonatomic) IBOutlet UIImageView *donaterImage;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *donateTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *clearIcon;
- (IBAction)clearSearch:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
- (IBAction)optionChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPoints;

@end
