//
//  FeedSingleImageViewTableViewCell.h
//  Varial
//
//  Created by Guru Prasad chelliah on 12/30/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCircularProgressBarView.h"

@interface FeedSingleImageViewTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *gContainerView;
@property (strong, nonatomic) IBOutlet UIView *gViewProfile;
@property (strong, nonatomic) IBOutlet UIImageView *gImageViewFeeds;
@property (strong, nonatomic) IBOutlet UIView *gViewLikeAndCmt;
@property (strong, nonatomic) IBOutlet UIView *gViewUseImage;
@property (strong, nonatomic) IBOutlet UIImageView *gImgViewUser;
@property (strong, nonatomic) IBOutlet UILabel *gLblTitle;
@property (strong, nonatomic) IBOutlet UILabel *gLblDateAndTime;
@property (strong, nonatomic) IBOutlet UIButton *gBtnMore;
@property (strong, nonatomic) IBOutlet UIImageView *gImgViewLocation;
@property (strong, nonatomic) IBOutlet UILabel *gLblLocation;
@property (strong, nonatomic) IBOutlet UILabel *gLblContent;
@property (strong, nonatomic) IBOutlet MBCircularProgressBarView *downloadProgress;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *gConstraintFeedImageHeight;
@property (strong, nonatomic) IBOutlet UIImageView *gImgViewPrivacy;
@property (strong, nonatomic) IBOutlet UIButton *gBtnLike;
@property (strong, nonatomic) IBOutlet UILabel *gLblLike;
@property (strong, nonatomic) IBOutlet UIButton *gBtnComment;
@property (strong, nonatomic) IBOutlet UILabel *gLblComment;
@property (strong, nonatomic) IBOutlet UILabel *gLblViews;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *gConstraintHeight;
@property (strong, nonatomic) IBOutlet UIView *gViewMediaVideo;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *gConstraintVideoViewHeight;
@end
