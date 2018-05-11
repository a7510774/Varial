//
//  BuzzardRunDetails.h
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "PostBuzzardRun.h"
#import "YesNoPopup.h"
#import "NetworkAlert.h"
#import "GetDirections.h"

@interface BuzzardRunDetails : UIViewController<UITableViewDataSource,UITableViewDelegate,YesNoPopDelegate,NetworkDelegate,UITextViewDelegate>
{
    int selectedTab;
    NSMutableArray *eventList;
    NSString *mediaBase, *instructions, *registrationToken;
    YesNoPopup *registerConfirm;
    NetworkAlert *activationCode;
    KLCPopup *registerConfirmPopup, *activationCodePopup;
    NSMutableDictionary *shopLocation;
    NSString *buzzardRunName;
}

@property (strong) NSString *buzzardRunId;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong)IBOutlet UITableView *eventsTable;
@property(nonatomic, strong)IBOutlet UIView *tableViewHeaderView;

// Buzzard run detail header page
@property(nonatomic, strong)IBOutlet UIImageView *profileImage;
@property(nonatomic, strong)IBOutlet UILabel *name;
@property(nonatomic, strong)IBOutlet UILabel *subName;
@property(nonatomic, strong)IBOutlet UILabel *address;
@property(nonatomic, strong)IBOutlet UILabel *points;

@property (nonatomic, strong) IBOutlet UIView *tabView;
@property (nonatomic, strong) IBOutlet UIButton *generalTab;
@property (nonatomic, strong) IBOutlet UIButton *eventsTab;
-(IBAction)generalButton:(id)sender;
-(IBAction)eventsButton:(id)sender;
- (IBAction)registerBuzzardRun:(id)sender;
- (IBAction)getDirection:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *registerLabel;

@end
