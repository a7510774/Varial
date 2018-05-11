//
//  BuzzardRunPostDetails.h
//  Varial
//
//  Created by vis-1041 on 3/30/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "Config.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "Comments.h"
#import "ShowCheckinInMap.h"
#import "YesNoPopup.h"
#import "KLCPopup.h"
#import "FriendProfile.h"
#import "TTTAttributedLabel.h"
#import "ZoomImage.h"
#import "MBCircularProgressBarView.h"

@interface BuzzardRunPostDetails : UIViewController<UITableViewDataSource,UITableViewDelegate,YesNoPopDelegate,TTTAttributedLabelDelegate>{
    KLCPopup *yesNoPopup;
    NSMutableArray *mediaList;
    BOOL pageLoad,needToReloadPostHeader;
    NSIndexPath *selectedIndexPath,*selectedMediaIndex;
    YesNoPopup *popupView;
    BOOL star,imagePresent;
    NSString *latitude,*longitude;
    BOOL isStarPressed;
    AppDelegate *appDelegate;
}

@property (strong)  NSString  *postId, *mediaBase, *isFromNotification;
@property (strong)  NSMutableDictionary  *postDetails;
@property NSUInteger startIndex;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

//Post Header
@property (weak, nonatomic) IBOutlet UIView *checkinView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *postContent;
@property (weak, nonatomic) IBOutlet UIView *postHeader;
@property (weak, nonatomic) IBOutlet UITableView *postTable;
@property (weak, nonatomic) IBOutlet UIView *profileImageHeader;


//Post header
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *name;
@property (weak, nonatomic) IBOutlet UILabel *postDescription;
@property (weak, nonatomic) IBOutlet UILabel *postedDate;
@property (weak, nonatomic) IBOutlet UIImageView *postTypeIcon;
- (IBAction)putStar:(id)sender;
- (IBAction)addCommentForPost:(id)sender;
- (IBAction)mediaDelete:(id)sender;

//Checkin view
@property (weak, nonatomic) IBOutlet UILabel *checkinTitle;
- (IBAction)moveToCheckinPage:(id)sender;

//Comment / Star
@property (weak, nonatomic) IBOutlet UIImageView *starImage;
@property (weak, nonatomic) IBOutlet UILabel *starCount;
@property (weak, nonatomic) IBOutlet UIImageView *commentImage;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;

@end