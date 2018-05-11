//
//  FriendsNotification.h
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"
#import "SVPullToRefresh.h"
#import "FriendProfile.h"
#import "YesNoPopup.h"
#import "GoogleAdMob.h"
#import "AppDelegate.h"

@interface FriendsNotification : UIViewController<UITableViewDataSource,UITableViewDelegate,YesNoPopDelegate>{
    NSMutableArray *notificationList, *generalNotification;
    int previousPage;
    NSString *mediaBase;
    
    KLCPopup *teamPopup;
    YesNoPopup *popupView;
    int generalPreviousPage;
    NSString *generalMediaBase;
    
    NSIndexPath *selectedIndexPath;
    NSDictionary *rowValue;
    int status;
    AppDelegate *appDelegate;
}
@property (nonatomic, assign) BOOL isFriendNotification;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (nonatomic, assign) int page;
@property (weak, nonatomic) IBOutlet UITableView *requestTable;

@property (nonatomic, assign) int generalPage;
@property (weak, nonatomic) IBOutlet UITableView *generalTable;

@property (weak, nonatomic) IBOutlet UITabBarItem *friendTab;
@property (weak, nonatomic) IBOutlet UITabBarItem *globalTab;
@property (nonatomic, assign) NSString *globalCount,*friendCount;
-(void)getFriendNotificationList;
-(void)getGeneralNotificationList;
-(void)getNotificationListToSave;
-(void)showBatchCountforFriend:(NSString*)friend forGlobal:(NSString*)global;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *requestTableBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generalTableBottom;

@property (weak, nonatomic) IBOutlet HeaderView *myHeaderView;


@end
