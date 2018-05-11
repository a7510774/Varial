//
//  FeedsDesign.h
//  Varial
//
//  Created by jagan on 07/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostDetails.h"
#import "FeedCell.h"
#import "TTTAttributedLabel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "YYWebImage.h"
#import "DGActivityIndicatorView.h"
#import "Feeds.h"


@interface FeedsDesign : NSObject<TTTAttributedLabelDelegate>{
    UIImageView *thumbImage;
    AppDelegate *delegate;
    NSMutableDictionary *videoItems;
    NSIndexPath *currentPlayerIndexPath;
}
//@property(nonatomic,assign)id delegate;
@property (strong) NSString *mediaBaseUrl;
@property (strong) NSMutableArray *feeds;
@property (strong) NSString *bigVideoUrl, *currentVideoUrl;
@property (nonatomic) UITableView *feedTable;
//@property (nonatomic) AVPlayerViewController *playerViewController;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic) BOOL isNoNeedProfileRedirection, isNoNeedNameRedirection, myBoolIsVideoViewedInBigScreen, gBoolIsFromFeeds, isVolumeMuted, isVolumeClicked;

typedef void (^CompletionBlockForFeed)(BOOL);

- (void)addStar:(UITableView *)tableView fromArray:(NSMutableArray *)source forControl:(id)sender;
- (void)setStarAndCommentCount:(UITableViewCell *)cell forDictionary:(NSMutableDictionary  *)currentFeed;
- (void)designTheContainerView:(UITableViewCell *) cell forFeedData:(NSMutableDictionary *) currentFeed mediaBase:(NSString *)mediaBaseUrl forDelegate:(UIViewController *)delegate tableView:(UITableView *)tableview;
- (void) buildCommonDataInFeedList :(FeedCell *) cell forFeedData:(NSMutableDictionary *) currentFeed;
-(void)moveToPostDetails:(UIImageView *)imageView index:(int)index fromTable:(UITableView *)tableView fromController:(UIViewController *)contoller fromSource:(NSMutableArray *)sourceArray mediaBase:(NSString *)baseUrl;
-(void)showDownloadProgress :(FeedCell *)cell imageView:(UIImageView *)imageView mediaUrl:(NSString *)url imageSize:(CGSize )imageSize onProgressView:(MBCircularProgressBarView *)downloadProgress;
- (void)playVideoConditionally;
- (void)stopTheVideo:(UITableViewCell *)cell;
//-(void)playInlineVideo :(FeedCell *) cell  Url:(NSString *)videourl ;
- (void)playInlineVideo:(FeedCell *)cell withSize:(CGSize)size andUrl:(NSString *)videoUrl;
-(void)prepareTheVideo:(NSString *)videoURL;
-(void)stopAllVideos;
- (void)playVideo:(NSString *)mediaUrl withThumb:(UIImage *)thumbImg fromController:(UIViewController *)controller withUrl:(NSString *)thumbUrl;
- (void)increaseViewCount:(NSString *)mediaUrl;
-(void)checkWhichVideoToEnable :(UITableView *)tableView;
-(void)StopVideoOnAppBackground:(UITableView *)tableView;

- (CGFloat)heightForFeedCell:(NSDictionary *)data;

@property (nonatomic) BOOL isSelectVideoCell;
- (void)addBookmark:(UITableView *)tableView fromArray:(NSMutableArray *)source forControl:(UIButton*)sender;

@end


//@protocol feedListUpdateDelegate <NSObject>
////-(void)getFeedsList;
//-(void)getUpdatedFeedsListWithCallBack:(CompletionBlockForFeed)completed;
//
//@end

