//
//  FeedCell.h
//  Varial
//
//  Created by Apple on 10/08/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MBCircularProgressBarView.h"
#import "URLPreviewView.h"
#import "DGActivityIndicatorView.h"
#import "LLARingSpinnerView.h"
#import "MBCircularProgressBarView.h"
#import "FRHyperLabel.h"
#import <ResponsiveLabel/ResponsiveLabel.h>

#define CELL_MARGIN 10

@interface FeedCell : UITableViewCell<TTTAttributedLabelDelegate>

@property (strong, nonatomic) NSString *postId;

@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UIView *feedBody;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UILabel *sharedTime;
//@property (weak, nonatomic) IBOutlet UILabel *shareDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sharedPersonImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *dimView;
@property (weak, nonatomic) IBOutlet UILabel *shareCount;

@property (strong, nonatomic) IBOutlet UIView *checkinView;
@property (strong, nonatomic) IBOutlet UILabel *checkinLabel;
@property (strong, nonatomic) IBOutlet UIButton *checkinButton;
@property (weak, nonatomic) IBOutlet UIButton *shareListButton;

@property (strong, nonatomic) IBOutlet UIImageView *mainPreview;
@property (strong, nonatomic) IBOutlet UIView *medias;
@property (strong, nonatomic) IBOutlet UIImageView *subPreview;
@property (strong, nonatomic) IBOutlet UIImageView *playIcon;
@property (strong, nonatomic) IBOutlet UILabel *imageCount;
@property (strong, nonatomic) IBOutlet UIView *videoView;

@property (strong, nonatomic) IBOutlet TTTAttributedLabel *message;

@property (strong, nonatomic) IBOutlet UIButton *commentsButton;
@property (strong, nonatomic) IBOutlet UIButton *starButton;
@property (strong, nonatomic) IBOutlet UIButton *starListButton;
@property (strong, nonatomic) IBOutlet UILabel *starCount;
@property (strong, nonatomic) IBOutlet UILabel *commentCount;
@property (strong, nonatomic) IBOutlet UIImageView *starImage;
@property (strong, nonatomic) IBOutlet UIImageView *commentImage;

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *name;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UIImageView *privacyImage;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) AVPlayerItem* videoItem;
@property (strong, nonatomic) AVPlayer* videoPlayer;
@property (strong, nonatomic) AVPlayerLayer* avLayer;
@property (strong, nonatomic) IBOutlet MBCircularProgressBarView *downloadProgress;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mediaHeight;
@property (strong, nonatomic) IBOutlet URLPreviewView *urlPreview;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewHeight;
@property (strong, nonatomic) IBOutlet UIView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *videoViewCount;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoViewCountHeight;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *checkinMargin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageMargin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewMargin;
@property (weak, nonatomic) IBOutlet UIButton *sharedMenuButton;
@property (weak, nonatomic) IBOutlet UIImageView *sharedPrivacyImage;
@property (weak, nonatomic) IBOutlet UIButton *sharedBtnBookmark;
@property (weak, nonatomic) IBOutlet UIButton *sharedReportButton;
@property (weak, nonatomic) IBOutlet UIView *sharedTextView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sharedHeightConstraint;


@property (strong, nonatomic) IBOutlet UIButton *reportButton;
@property (nonatomic) BOOL isVideo;
@property (weak, nonatomic) IBOutlet LLARingSpinnerView *spinnerView;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *spinnerProgressView;

@property (weak, nonatomic) NSDictionary *cellData;

- (void)layoutConstraints;
- (void)deallocObjects;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@property (strong, nonatomic) IBOutlet UIButton *btnBookmark;
@property (weak, nonatomic) IBOutlet ResponsiveLabel *gLblShareDescription;

@property (weak, nonatomic) IBOutlet UIButton *gBtnMuteUnMute;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myConstraintShareViewTop;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myConstraintContainerViewTop;

@end
