//
//  ViewController.h
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feeds.h"
#import "FriendsNotification.h"
#import "GeneralNotification.h"
#import "MainMenu.h"
#import "CreatePostViewController.h"
#import "Util.h"
#import "AlertMessage.h"
#import "HeaderView.h"
#import "KLCPopup.h"
#import "EmailAlert.h"
#import "AGPushNoteView.h"
#import "JSQMessages.h"
#import "FeedsDesign.h"

@interface ViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UITabBarDelegate,HeaderViewDelegate,CreatePostDelegate>
{
    KLCPopup *emailAlertPopup;
    KLCPopupLayout layout;
    AppDelegate *delegate;    
}

@property(strong) NSString *selectedFeedType, *mediaBase;
@property(nonatomic,retain)NSMutableArray *createPost,*feedTypeList,*viewControllers, *popularVideoslist, *channelsList;

@property(nonatomic,retain) NSMutableArray *popularFeeds, *publicFeeds, *privateFeeds, *friendsFeeds, *teamAFeeds, *teamBFeeds, *uploadCancelArray;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabFour;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIButton *emailAlertIcon;
- (void)setCurrentPage:(int)index;
- (void)setFeedType:(int)type;
- (void)createEmailAlertView;
- (void)setBadge;


@end

