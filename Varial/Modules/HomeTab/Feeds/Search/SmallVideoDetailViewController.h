//
//  SmallVideoDetailViewController.h
//  Varial
//
//  Created by user on 28/05/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import <Foundation/Foundation.h>
#import "PostDetails.h"
#import "FeedCell.h"
#import "TTTAttributedLabel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "YYWebImage.h"
#import "DGActivityIndicatorView.h"


@interface SmallVideoDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate>
{
    UIImageView *myThumbImage;
    AppDelegate *delegate;
}

//@property(nonatomic, strong)NSMutableArray *feeds;
@property(nonatomic, strong)NSMutableDictionary *gDicFeeds;
@property(nonatomic, strong)NSString *gMediaBaseUrl;
@property (weak, nonatomic) IBOutlet HeaderView *myViewHeader;
@property (weak, nonatomic) IBOutlet UITableView *myTblViewFeedsTable;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerLayer *videoLayer;

@property (nonatomic) BOOL isNoNeedProfileRedirection, isNoNeedNameRedirection, myBoolIsVideoViewedInBigScreen, gBoolIsFromFeeds, isVolumeMuted, isVolumeClicked, gIsFromChannel, isSelectVideoCell, myBoolIsVideoPlayInBigScreen;



@end
