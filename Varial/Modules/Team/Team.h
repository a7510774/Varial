//
//  Team.h
//  Varial
//
//  Created by Shanmuga priya on 3/3/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "CreateTeam.h"
#import "YesNoPopup.h"
#import "KLCPopup.h"
#import "TeamInvitiesViewController.h"

@interface Team : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,YesNoPopDelegate>{
    KLCPopup *yesNoPopup;
    YesNoPopup *popupView;
    NSMutableArray *teamList;
    NSString *mediaBase;
    
    // Leave Team
    NSIndexPath *selecetedIndexPath;
    int selectedPopup;
}


@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIView *createView;
@property (weak, nonatomic) IBOutlet UITableView *teamTable;
- (IBAction)creatTeam:(id)sender;
- (void)getTeamList;

@end
