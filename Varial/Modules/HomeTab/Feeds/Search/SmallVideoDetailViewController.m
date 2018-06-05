//
//  SmallVideoDetailViewController.m
//  Varial
//
//  Created by user on 28/05/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "SmallVideoDetailViewController.h"
#import "FeedCell.h"
#import "Util.h"
#import "YYWebImage.h"
#import "LikedUsersList.h"
#import "InviteFriends.h"
#import "UITableView+TableViewAnimations.h"
#import "JPVideoPlayerCache.h"
#import "JPVideoPlayer.h"
#import "UIView+WebVideoCache.h"
#import "JPVideoPlayerControlViews.h"

@interface SmallVideoDetailViewController ()
{
    BOOL myBoolIsMutePressed;
}
@end

@implementation SmallVideoDetailViewController
NSInteger myViewCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUi];
    [self setUpModel];
    [self loadModel];
}


//MARK:- View Initialize
-(void) setUpUi {
    
    [self.myTblViewFeedsTable registerNib:[UINib nibWithNibName:NSStringFromClass([FeedCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FeedCell class])];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MuteUnMuteNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMuteUnMuteValue:)
                                                 name:@"MuteUnMuteNotification"
                                               object:nil];
    
    [_myViewHeader setHeader:NSLocalizedString(CHANNEL, nil)];
    
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(void) setUpModel {
    
    
}

-(void) loadModel {
    
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    FeedCell *aCell = [self.myTblViewFeedsTable cellForRowAtIndexPath:path];
    [aCell.videoView jp_resume];
    
    _myBoolIsVideoPlayInBigScreen = NO;
    if(_player != nil) {
        [_player play];
    }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        //[self checkWhichVideoToEnable:_myTblViewFeedsTable];
    });
}

- (void) updateMuteUnMuteValue:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"MuteUnMuteNotification"]){
        
        NSDictionary* userInfo = notification.userInfo;
        NSString * aGetStatus = (NSString *)userInfo[@"IsMuted"];
        
        if([aGetStatus isEqualToString:@"true"]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isVolumeMuted"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.isVolumeMuted = true;
        }
        
        else {
            
            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"isVolumeMuted"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.isVolumeMuted = false;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    if(_myBoolIsVideoPlayInBigScreen) {
        
        [self.player pause];
        
    } else {
        [self.player setMuted:YES];
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        
        [self.player pause];
        [self.videoLayer removeFromSuperlayer];
        self.player = nil;
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        FeedCell *aCell = [self.myTblViewFeedsTable cellForRowAtIndexPath:path];
        [aCell.videoView jp_stopPlay];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    
    if(_myBoolIsVideoPlayInBigScreen) {
        
        [self.player pause];
    } else {
        [self.player setMuted:YES];
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        
        [self.player pause];
        [self.videoLayer removeFromSuperlayer];
        self.player = nil;
    }
}

//MARK-: TableView Delegate and DataSource

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentifier = nil;
//    FeedCell *fcell;
//    
//    
//        cellIdentifier = @"FeedCell";
//        fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if (fcell == nil)
//        {
//            fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
    
    FeedCell *fcell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([FeedCell class])];

    
        // Mute Button Actions
        [fcell.gBtnMuteUnMute addTarget:self action:@selector(muteUnmutePressed:) forControlEvents:UIControlEventTouchUpInside];
        fcell.gBtnMuteUnMute.tag = indexPath.row;
    
        
        // Hide Share View
        [fcell.shareView setHidden:YES];
        fcell.shareViewHeightConstraint.constant = -70.0;
        
        fcell.backgroundColor = [UIColor clearColor];
    
    
        [self buildCommonDataInFeedList:fcell forFeedData:self.gDicFeeds];
    
        // Layout the parent views
        //    [self layoutFeedCell:cell forFeedData:currentFeed];
        [fcell setCellData:self.gDicFeeds];
        
        // Finish with enabling media
    
        // Play and activity icon for video
    
        [fcell.playIcon setHidden:YES];
    
        DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScale tintColor:[UIColor whiteColor] size:15.0f];
        activityIndicatorView.frame = fcell.activityIndicator.bounds;
        [activityIndicatorView startAnimating];
        [fcell.activityIndicator setHidden:YES];
        [[fcell.activityIndicator subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [fcell.activityIndicator addSubview:activityIndicatorView];
        fcell.isVideo = NO;
    
        if ([self.gDicFeeds objectForKey:@"post_id"] != nil) {
            [fcell setPostId:[self.gDicFeeds objectForKey:@"post_id"]];
        }
    
        fcell.message.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        [fcell.message setText:self.gDicFeeds[@"post_content"]];
        [Util highlightHashtagsInLabel:fcell.message];
    
        if ([[self.gDicFeeds objectForKey:@"continue_reading_flag"] intValue] == 1) {
            if ([[self.gDicFeeds objectForKey:@"is_local"] isEqualToString:@"true"]) {
                [Util setAddMoreTextForLabel:fcell.message endsWithString:ENDS_WITH_STRING forlength:256 forColor:UIColorFromHexCode(THEME_COLOR)];
            }
            else
            {
                [Util setAddMoreTextForLabel:fcell.message endsWithString:ENDS_WITH_STRING forlength:(int)[fcell.message.text length] forColor:UIColorFromHexCode(THEME_COLOR)];
            }
        }
    
        // Delegate callback for Continue Reading
        fcell.message.delegate = self;
    
    
        if([self.gDicFeeds objectForKey:@"video"] != nil && [[self.gDicFeeds objectForKey:@"video"] count] > 0){
            
            fcell.gBtnMuteUnMute.hidden = NO;
            NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[self.gDicFeeds objectForKey:@"video"]];
            //iterate the medias
            for(int loop = 0; loop < [medias count]; loop++){
                fcell.isVideo = YES;
                fcell.subPreview.hidden = YES;
                fcell.imageCount.hidden = YES;
                [fcell.videoView setHidden:YES];
                UIImageView *currentImage = [[UIImageView alloc] init];
                currentImage = (loop == 1)? fcell.subPreview : fcell.mainPreview;
                currentImage.clipsToBounds = YES;
                [fcell.mainPreview setHidden:NO];
                CGSize mediaSize = [Util getAspectRatio:[[medias objectAtIndex:0] objectForKey:@"media_dimension"] ofParentWidth:self.view.frame.size.width];
                
                //                cell.mediaHeight.constant = imageSize.height;
                
                fcell.videoView.frame = CGRectMake(0, 0, fcell.medias.frame.size.width, fcell.medias.frame.size.height);
                
                if ([[self.gDicFeeds objectForKey:@"is_local"] isEqualToString:@"true"]) {
                    // Remove any remaining video layers
                    [fcell.mainPreview.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
                    
                    NSMutableArray *getlocal = [[NSMutableArray alloc] initWithArray:[self.gDicFeeds objectForKey:@"is_media"]];
                    
                    currentImage.image =  [[getlocal objectAtIndex:0] objectForKey:@"mediaThumb"];
                    [fcell.playIcon setHidden:YES];
                    [fcell.activityIndicator setHidden:YES];
                    //Hide the view count label for local videos
                    //                    cell.videoViewCountHeight.constant = 0;
                    fcell.videoViewCount.hidden = NO;
                    
                }
                else
                {
                    //Show the view count label for video post
                    int viewCount = [[[medias objectAtIndex:0] objectForKey:@"views_count"] intValue];
                    if (viewCount == 0) {
                        //Hide the view count label for post contains 0 views
                        //                        cell.videoViewCountHeight.constant = 0;
                        fcell.videoViewCount.hidden = YES;
                    }
                    else {
                        //                        cell.videoViewCountHeight.constant = 20;
                        fcell.videoViewCount.hidden = NO;
                        fcell.videoViewCount.text = [Util getViewsString:viewCount];
                    }
                    
                    [delegate.videoIds setValue:[[medias objectAtIndex:loop] valueForKey:@"video_id"] forKey:[[medias objectAtIndex:loop] valueForKey:@"media_url"]];
                    
                    [currentImage.layer setValue:[[medias objectAtIndex:0] objectForKey:@"media_dimension"] forKey:@"dimension"];
                    
                    // Show DownLoad Progress for media
                    
                    
                        NSString *strVideoUrl = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",_gMediaBaseUrl,[[medias objectAtIndex:0] objectForKey:@"video_thumb_image_url"]]];
                        [self showDownloadProgress:fcell imageView:currentImage mediaUrl:strVideoUrl imageSize:fcell.medias.frame.size onProgressView:[Util designdownloadProgress:fcell.downloadProgress]];
                    //
                    [fcell.playIcon setHidden:YES];
                    [fcell.activityIndicator setHidden:YES];
                    //                    NSLog(@"frame height: %@", NSStringFromCGRect(cell.medias.frame));
                    fcell.videoView.frame = fcell.medias.frame;
                    
                    //Add click event
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPostDetailsAtFirstIndex:)];
                   
                    
                    //                    NSLog(@"before inline %@", NSStringFromCGRect(cell.videoView.frame));
                    //                    [self playInlineVideo:cell Url:[[medias objectAtIndex:loop] valueForKey:@"media_url"]];
//                    [self playInlineVideo:fcell withSize:mediaSize andUrl:[[medias objectAtIndex:loop] valueForKey:@"media_url"]];
                    
                     NSString *strVideoUrlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",_gMediaBaseUrl,[[medias objectAtIndex:loop] valueForKey:@"media_url"]]];
                    
                    NSURL *url = [NSURL URLWithString:strVideoUrlString];
                    
                    
//                     UIView *playerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mediaSize.width, mediaSize.height)];
                    [fcell.mainPreview setFrame:CGRectMake(0, 0, mediaSize.width, mediaSize.height)];
                    [fcell.mainPreview jp_playVideoWithURL:url
                            bufferingIndicator:nil
                                   controlView:nil
                                  progressView:nil
                       configurationCompletion:nil];
                    
                    [fcell.videoView setHidden:NO];
//                    [fcell.mainPreview addSubview:playerView];
                    fcell.mainPreview.backgroundColor = UIColor.blueColor;
//                    playerView.backgroundColor = UIColor.redColor;
                   
                    UIImageView *currentImage = [[UIImageView alloc] init];
                    currentImage =  fcell.mainPreview;
                    [currentImage setUserInteractionEnabled:YES];
                    [currentImage addGestureRecognizer:tap];
                    
                    
                    [fcell.playVideoFullscreen addTarget:self action:@selector(PlayVideoFullScreenPressed:) forControlEvents:UIControlEventTouchUpInside];
                }
                if(loop == 1){
                    [fcell.mainPreview setHidden:NO];
                    break;
                }
            }
        }
    
    return fcell;
}

#pragma mark Private Functions

-(void)PlayVideoFullScreenPressed:(UIButton*)sender {
    UITapGestureRecognizer *tap;
    [self showPostDetailsAtFirstIndex:tap];
}
//MARK :- Private Functions
- (void) showPostDetailsAtFirstIndex:(UITapGestureRecognizer *)tapRecognizer {
    //Convert view to imageview
    
    if (!self.isSelectVideoCell) {
        
        self.isSelectVideoCell = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            self.isSelectVideoCell = NO;
        });
        
        UIImageView *imageView = (UIImageView *)tapRecognizer.view;
        [self showPostDetails:imageView index:0];
    }
}


- (void)showPostDetails:(UIImageView *)imageView index:(int)index{
    [self moveToPostDetails:imageView index:index fromTable:_myTblViewFeedsTable fromController:_viewController fromSource:_gDicFeeds mediaBase:_gMediaBaseUrl];
}

-(void)showDownloadProgress :(FeedCell *)cell imageView:(UIImageView *)imageView mediaUrl:(NSString *)url imageSize:(CGSize )imageSize onProgressView:(MBCircularProgressBarView *)downloadProgress{
    
    [imageView yy_setImageWithURL:[NSURL URLWithString:url]
                      placeholder:[UIImage imageNamed:@"image_placeholder.png"]
                          options:YYWebImageOptionIgnoreFailedURL | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             if (expectedSize > 0 && receivedSize > 0) {
                                 CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                 downloadProgress.hidden = YES;
                                 [downloadProgress setValue:progress];
                             }
                         }
                        transform:nil
                       completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                           if (stage == YYWebImageStageFinished) {
                               
                               downloadProgress.hidden = YES;
                               
                               if (!image)
                                   imageView.image = image;
                           }
                       }];
}


- (void)playInlineVideo:(FeedCell *)cell withSize:(CGSize)size andUrl:(NSString *)videoUrl {
    
    
    NSString *strVideoUrl = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",_gMediaBaseUrl,videoUrl]];
    
    UIImage * aImgUnMute = [UIImage imageNamed:@"icon_unmute"];
    UIImage * aImgMute = [UIImage imageNamed:@"icon_mute"];
    
//    if(self.isVolumeClicked) {
//
//        NSURL *url = [NSURL URLWithString:strVideoUrl];
////        if ([delegate.moviePlayer objectForKey:strVideoUrl] != nil) {
//            if([Util getBoolFromDefaults:@"isVolumeMuted"]) {
//
//                [self.player setMuted:YES];
//                [cell.gBtnMuteUnMute setImage:aImgMute forState:UIControlStateNormal];
//            }
//
//            else {
//                [cell.gBtnMuteUnMute setImage:aImgUnMute forState:UIControlStateNormal];
//                [self.player setMuted:NO];
//            }
////        }
//
//
//    }
    
//    else {
    
        NSURL *url = [NSURL URLWithString:strVideoUrl];
        [cell.playIcon setHidden:NO];
        
        self.player = nil;
        
        
        [self.player playImmediatelyAtRate:1];
        
        self.player = [AVPlayer playerWithURL:url];
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        self.videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
        self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [cell.mainPreview.layer addSublayer:self.videoLayer];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            [cell.playIcon setHidden:YES];
            [_player play];
            
        });
    
        if (_player.rate == 0) {
            [cell.playIcon setHidden:NO];
        } else {
            [cell.activityIndicator setHidden:NO];
        }
        [cell.activityIndicator setHidden:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
        
        if([Util getBoolFromDefaults:@"isVolumeMuted"]) {
            
            [_player setMuted:YES];
            [cell.gBtnMuteUnMute setImage:aImgMute forState:UIControlStateNormal];
        }
        
        else {
            [cell.gBtnMuteUnMute setImage:aImgUnMute forState:UIControlStateNormal];
            [_player setMuted:NO];
        }
        
        [cell.videoView setHidden:NO];
//    }
    
    
}


- (void)itemDidFinishPlaying:(NSNotification *)notification {
//    AVPlayerItem *player = [notification object];
//    [player seekToTime:kCMTimeZero];
    
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
    
    AVAsset *currentPlayerAsset = playerItem.asset;
    NSString *videoUrl = [(AVURLAsset *)currentPlayerAsset URL].absoluteString;
    
//    _pla
    
//    AVPlayer *player = [delegate.moviePlayer objectForKey:videoUrl];
    //    [player setMuted: YES];
    
    if([Util getBoolFromDefaults:@"isVolumeMuted"]) {
        
        [_player setMuted:YES];
//        [cell.gBtnMuteUnMute setImage:aImgMute forState:UIControlStateNormal];
    }
    
    else {
//        [cell.gBtnMuteUnMute setImage:aImgUnMute forState:UIControlStateNormal];
        [_player setMuted:NO];
    }
    
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        [_player play];
    });
    
//    [self increaseViewCount:videoUrl];
    if (delegate.currentVideoUrl != nil && [videoUrl isEqualToString:delegate.currentVideoUrl]) {
        [delegate.playerViewController dismissViewControllerAnimated:YES completion:nil];
        delegate.currentVideoUrl = nil;
    }
    else{
        [self increaseViewCount:videoUrl];
    }
}


//Check and play the video if cell displayed in user view
- (void)playVideoConditionally{
    NSArray *visibleCells = [_myTblViewFeedsTable visibleCells];
    
    if([visibleCells count] != 0){
        for(UITableViewCell *cell in visibleCells){
            if ([cell isKindOfClass:[FeedCell class]]) {
                FeedCell *feedCell = (FeedCell*)cell;
                
                if(feedCell.isVideo){
                    [feedCell.playIcon setHidden:NO];
                    [feedCell.activityIndicator setHidden:YES];
                }
            }
        }
        
        if([visibleCells count] >= 3){
            if([[visibleCells objectAtIndex:1] isKindOfClass:[FeedCell class]]){
                FeedCell *currentCell = [visibleCells objectAtIndex:1];
                if(currentCell.isVideo){
                    [currentCell.playIcon setHidden:YES];
                    [currentCell.activityIndicator setHidden:NO];
                    [self playeVideoFromTheCell:currentCell];
                }
            }
            
        }
        else if([[visibleCells objectAtIndex:0] isKindOfClass:[FeedCell class]]){
            FeedCell *currentCell = [visibleCells objectAtIndex:0];
            if(currentCell.isVideo){
                [currentCell.playIcon setHidden:YES];
                [currentCell.activityIndicator setHidden:NO];
                [self playeVideoFromTheCell:currentCell];
            }
        }
    }
}


//Play the video
- (BOOL)playeVideoFromTheCell:(UITableViewCell *)cell{
    
    if([cell isKindOfClass:[FeedCell class]])
    {
        FeedCell *feedCell = (FeedCell *)cell;
        AVPlayer *player = [delegate.moviePlayer objectForKey:feedCell.videoUrl];
        if (player != nil) {
            
            //Check if video has already in play state
            if (player.rate != 0) {
                return true;
            }
            
            if(feedCell.isVideo){
                [feedCell.playIcon setHidden:YES];
                [feedCell.activityIndicator setHidden:NO];
            }
            
            //Play current video
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
                // dispatch_async( dispatch_get_main_queue(), ^{
                [player play];
                // });
            });
            
            return true;
        }
    }
    return false;
}

//Stop the video
- (void)stopTheVideo:(UITableViewCell *)cell{
    
    FeedCell *feedCell = (FeedCell *) cell;
    if([feedCell isKindOfClass:[FeedCell class]])
    {
        AVPlayer *player = [delegate.moviePlayer objectForKey:feedCell.videoUrl];
        if([feedCell isKindOfClass:[FeedCell class]])
        {
            [feedCell.videoView.layer.sublayers makeObjectsPerformSelector: @selector(removeFromSuperlayer)];
            
            if(feedCell.isVideo){
                [feedCell.playIcon setHidden:NO];
                [feedCell.activityIndicator setHidden:YES];
            }
            
            //Play current video
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
                
                [player pause];
                
            });
            
        }
    }
}


// Build Common data in feeds list
- (void) buildCommonDataInFeedList :(FeedCell *) cell forFeedData:(NSMutableDictionary *) currentFeed {
    
    // Poster Profile IMage
    NSMutableDictionary *postersProfileImage = [[NSMutableDictionary alloc] initWithDictionary:[currentFeed objectForKey:@"posters_profile_image"]];
    
    NSString *profileImageUrl = [[NSString alloc] initWithString:[postersProfileImage  objectForKey:@"profile_image"]];
    
    NSString * aStrProfileImage = [NSString stringWithFormat:@"%@%@",_gMediaBaseUrl,profileImageUrl];
//    [cell.profileImage setImageWithURL:[NSURL URLWithString:profileImageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    //    if (![isShare isEqualToString:@"1"]) {
    [cell.profileImage yy_setImageWithURL:[NSURL URLWithString:aStrProfileImage] placeholder:[UIImage imageNamed:IMAGE_HOLDER]];
    //    }
    
    
    [Util makeCircularImage:cell.profileImage withBorderColor:UIColorFromHexCode(THEME_COLOR)];
    
    if (!_isNoNeedProfileRedirection) {
        UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
        [cell.profileImage setUserInteractionEnabled:YES];
        [cell.profileImage addGestureRecognizer:tapProfileImage];
        
        UITapGestureRecognizer *tapSharedProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfileImageTapped:)];
        [cell.sharedPersonImage setUserInteractionEnabled:YES];
        [cell.sharedPersonImage addGestureRecognizer:tapSharedProfileImage];
    }
    
    // poster Profile Name and Description
    //    NSString *postDescription = [[NSString alloc] initWithString:[currentFeed objectForKey:@"post_description"]];
    NSString *nameValue = [[NSString alloc] initWithString:[currentFeed objectForKey:@"name"]];
    //    [cell.name setAttributedText:[Util feedsHeaderName:nameValue desc:postDescription]];
    [cell.name setText:nameValue];
    NSRange range = NSMakeRange(0, [nameValue length]);
    [Util makeAsLink:cell.name withColor:[UIColor blackColor] showUnderLine:NO range:range];
    
    if (!_isNoNeedNameRedirection) {
        UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
        [cell.name setUserInteractionEnabled:YES];
        [cell.name addGestureRecognizer:tapName];
    }
    //    cell.name.delegate = _viewController;
    
    ///////////////////////  MENU //////////////////////////
    cell.reportButton.hidden = YES;
    cell.sharedReportButton.hidden = YES;
//    int isOwner = [[currentFeed objectForKey:@"am_owner"] intValue];
//    if (isOwner == 1) {
//        cell.menuButton.hidden = NO;
//        cell.reportButton.hidden = YES;
//        cell.sharedReportButton.hidden = YES;
//        cell.sharedMenuButton.hidden = NO;
//    }
//    else{
//        cell.menuButton.hidden = YES;
//        cell.reportButton.hidden = NO;
//        cell.sharedMenuButton.hidden = YES;
//        cell.sharedReportButton.hidden = NO;
//    }
    
    ////////////////////// CHECK IN ////////////////////////////
    [cell.checkinButton addTarget:self action:@selector(CheckIn:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *checkInDetails = [[NSArray alloc] initWithArray:[currentFeed objectForKey:@"check_in_details"]];
    if ([checkInDetails count] != 0) {
        //        [cell.checkinView hideByHeight:NO];
        //        [cell.checkinMargin setActive:YES];
        [cell.checkinLabel setText:[[checkInDetails objectAtIndex:0] objectForKey:@"name"]];
    }
    else
    {
        //        [cell.checkinView hideByHeight:YES];
        //        [cell.checkinMargin setActive:NO];
    }
    
    // post date time
    [cell.date setText:[Util timeStamp: [[currentFeed objectForKey:@"time_stamp"] intValue]]];
    
    // Privacy Type Image
    int privacy_type = [[currentFeed objectForKey:@"privacy_type"] intValue];
    [cell.privacyImage setImage:[Util imageForFeed:privacy_type withType:@"privacy"]];
    [cell.sharedPrivacyImage setImage:[Util imageForFeed:privacy_type withType:@"privacy"]];
    //Set star and command counts
    [self setStarAndCommentCount:cell forDictionary:currentFeed];
    
    // Reset spinner views
    [cell.spinnerView setLineWidth:2.0];
    [cell.spinnerView setTintColor:UIColorFromHexCode(THEME_COLOR)];
    //    [cell.spinnerView setTintColor:UIColorFromHexCode(0x00FF00)];
    
    if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
        if ([[currentFeed objectForKey:@"is_upload"] isEqualToString:@"completed"]) {
            //            cell.dimView.hidden = YES;
            cell.menuButton.hidden = YES;
            cell.sharedMenuButton.hidden = YES;
            //            [cell.spinnerView stopAnimating];
        }
        
        cell.dimView.hidden = NO;
        cell.spinnerView.hidden = NO;
        cell.spinnerProgressView.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell.spinnerView startAnimating];
        });
    }
    else {
        cell.dimView.hidden = YES;
        cell.spinnerView.hidden = YES;
        [cell.spinnerView stopAnimating];
        cell.spinnerProgressView.hidden = YES;
    }
    
    [cell.starButton addTarget:self action:@selector(Star:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentsButton addTarget:self action:@selector(showCommentPage:) forControlEvents:UIControlEventTouchUpInside];
    [cell.starListButton addTarget:self action:@selector(showStaredUsersList:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareListButton addTarget:self action:@selector(showSharedUsersList:) forControlEvents:UIControlEventTouchUpInside];
//
    [cell.btnShare addTarget:self action:@selector(shareBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnBookmark addTarget:_viewController action:@selector(bookmarkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.sharedBtnBookmark addTarget:self action:@selector(bookmarkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
//
    cell.sharedMenuButton.hidden = YES;
    cell.sharedBtnBookmark.hidden = YES;
    cell.sharedPrivacyImage.hidden = YES;
    cell.sharedReportButton.hidden = YES;
    cell.menuButton.hidden = YES;
    cell.privacyImage.hidden = YES;
    cell.btnBookmark.hidden = YES;
    cell.reportButton.hidden = YES;
    cell.sharedHeightConstraint.active = NO;
}


-(void)checkWhichVideoToEnable :(UITableView *)tableView
{
    int i = 0;
    for(UITableViewCell *cell in [tableView visibleCells])
    {
        i++;
        if([cell isKindOfClass:[FeedCell class]])
        {
            NSIndexPath *indexPath = [tableView indexPathForCell:cell];
            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
            UIView *superview = tableView.superview;
            
            CGRect convertedRect=[tableView convertRect:cellRect toView:superview];
            CGRect intersect = CGRectIntersection(tableView.frame, convertedRect);
            float visibleHeight = CGRectGetHeight(intersect);
            
            if(visibleHeight>(cell.frame.size.height)*0.6 || (visibleHeight > tableView.frame.size.height/2)) // only if 60% of the cell is visible
            {
                
                FeedCell *feedCell = (FeedCell *)cell;
                AVPlayer *player = [delegate.moviePlayer objectForKey:feedCell.videoUrl];
                if (player != nil) {
                    
                    if(feedCell.isVideo){
                        [feedCell.playIcon setHidden:YES];
                        [feedCell.activityIndicator setHidden:NO];
                        NSLog(@"Playing: icon hidden");
                        //Play current video
                        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
                            if ((player.rate != 0) && (player.error == nil)) {
                                // player is playing
                            }
                            else {
                                [player play];
                                if (CMTimeGetSeconds(player.currentTime) == 0) {
                                    [self increaseViewCount:feedCell.videoUrl];
                                }
                            }
                        });
                    }
                    
                }
                NSArray *visibleCells = [tableView visibleCells];
                
                if([visibleCells count] == 2  && i == 1)
                {
                    // Stop second cell
                    [self CheckTwoIndexFullyVisible:tableView cell:[[tableView visibleCells] objectAtIndex:1]];
                    break;
                }
                
            }
            else
            {
                FeedCell *feedCell = (FeedCell *)cell;
                AVPlayer *player = [delegate.moviePlayer objectForKey:feedCell.videoUrl];
                if (player != nil) {
                    
                    if(feedCell.isVideo){
                        [feedCell.playIcon setHidden:NO];
                        [feedCell.activityIndicator setHidden:NO];
                    }
                    
                    //Play current video
                    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
                        [player seekToTime:kCMTimeZero];
                        [player pause];
                    });
                }
            }
        }
    }
}

// Stop second cell if two cell is visible more than 60 %
- (void)CheckTwoIndexFullyVisible :(UITableView *)tableView cell:(FeedCell *)cell
{
    if([cell isKindOfClass:[FeedCell class]])
    {
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        UIView *superview = tableView.superview;
        
        CGRect convertedRect=[tableView convertRect:cellRect toView:superview];
        CGRect intersect = CGRectIntersection(tableView.frame, convertedRect);
        float visibleHeight = CGRectGetHeight(intersect);
        
        if(visibleHeight>(cell.frame.size.height)*0.6 || (visibleHeight > tableView.frame.size.height/2))
        {
            FeedCell *feedCell = (FeedCell *)cell;
            AVPlayer *player = [delegate.moviePlayer objectForKey:feedCell.videoUrl];
            if (player != nil) {
                
                if(feedCell.isVideo){
                    [feedCell.playIcon setHidden:NO];
                    [feedCell.activityIndicator setHidden:NO];
                    
                    //Play current video
                    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
                        [player seekToTime:kCMTimeZero];
                        [player pause];
                    });
                }
            }
        }
        
    }
}


- (IBAction)Star:(id)sender
{    
    [self addStar:_myTblViewFeedsTable fromDic:_gDicFeeds forControl:sender];
}

//Add star for post
- (void)addStar:(UITableView *)tableView fromDic:(NSMutableDictionary *)source forControl:(id)sender {
    
    if([[Util sharedInstance] getNetWorkStatus])
    {
        // Get index from the table
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        FeedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
//        if ([source count] > indexPath.row) {
        
            [source setValue:@"true" forKey:@"isEnabled"];
        
            NSMutableDictionary *selectedStar = source;
            
            // Get values from the Index
            NSString *star_post_id = [selectedStar objectForKey:@"post_id"];
            if (star_post_id != nil && ![star_post_id isEqualToString:@""]) {
                
                if ([[selectedStar valueForKey:@"isEnabled"] isEqualToString:@"true"]) {
                
                    [selectedStar setValue:@"false" forKey:@"isEnabled"];
                
                    NSString *star_status = [selectedStar objectForKey:@"star_status"];
                    NSString *update_star_status = ([star_status intValue] == 0)? @"1" : @"0";
                    NSString *old_Count = [NSString stringWithFormat:@"%@", [selectedStar objectForKey:@"stars_count"]];
                    NSString *updated_starCount = ([update_star_status intValue] == 1)? [NSString stringWithFormat:@"%lld", [old_Count longLongValue]+1]  :  [NSString stringWithFormat:@"%lld",[old_Count longLongValue]-1];
                    
                    [self designTheStarView:sender Status:update_star_status Count:updated_starCount forTableView:tableView];
                    
                    //Build Input Parameters
                    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
                    [inputParams setValue:star_post_id forKey:@"post_id"];
                    [inputParams setValue:update_star_status forKey:@"star_flag"];
                    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
                    
                    [[Util sharedInstance] sendHTTPPostRequestWithError:inputParams withRequestUrl:STAR_UNSTAR withCallBack:^(NSDictionary * response, NSError *error){
                        if (error != nil) {
                            [selectedStar setValue:@"true" forKey:@"isEnabled"];
                            [self designTheStarView:sender Status:update_star_status Count:updated_starCount forTableView:tableView];
                        }
                        else{
                            // Check if cell matches post id
                            NSString *postId = [cell postId];
                            if([[response valueForKey:@"status"] boolValue]){
                                
                                // Update Stat Status
                                if ([postId isEqualToString:star_post_id]) {
                                    [self designTheStarView:sender Status:update_star_status Count:[response objectForKey:@"star_count"] forTableView:tableView];
                                }
                                
                                // Update star status and star count in array
                                [selectedStar setObject:update_star_status forKey:@"star_status"];
                                [selectedStar setObject:[response objectForKey:@"star_count"] forKey:@"stars_count"];
                                [selectedStar setValue:@"true" forKey:@"isEnabled"];
                            }
                            else
                            {
                                if ([postId isEqualToString:star_post_id]) {
                                    [selectedStar setValue:@"true" forKey:@"isEnabled"];
                                    [self designTheStarView:sender Status:star_status Count:old_Count forTableView:tableView];
                                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                                }
                            }
                            
                        }
                        
                    } isShowLoader:NO];
                    
                }
                
            }
            else{
                [[AlertMessage sharedInstance] showMessage:PERFORM_LATER];
            }
//        }
    }
    else{
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.networkPopup show];
    }
}


//Design the star view
- (void)designTheStarView:(id)sender Status:(NSString *)status Count:(NSString *)count forTableView:(UITableView *)sourceTable
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:sourceTable];
    NSIndexPath *indexPath = [sourceTable indexPathForRowAtPoint:buttonPosition];
    FeedCell *cell = [sourceTable cellForRowAtIndexPath:indexPath];
    //    UIImageView *starImage = (UIImageView *) [cell viewWithTag:7];
    
    UIButton *starButton = cell.starButton;
    UIButton *starListButton = cell.starListButton;
    
    //    UILabel *starsCount = (UILabel*)[cell viewWithTag:8];
    
    // Update Stat Status
    long sCount = [count longLongValue];
    if (sCount == 0){
        starListButton.hidden = YES;
    }
    else
    {
        if (![_viewController isKindOfClass:[PostBuzzardRun class]]) {
            starListButton.hidden = NO;
        }
    }
    
    
    //    [starsCount setText:[Util getStarString:sCount]];
    [starListButton setTitle:[NSString stringWithFormat:@"%ld", sCount] forState:UIControlStateNormal];
    
    //    starsCount.textColor = ([status intValue] == 1)? UIColorFromHexCode(THEME_COLOR) : [UIColor darkGrayColor];
    //    starImage.image = ([status intValue] == 1)? [UIImage imageNamed:@"starActive"] : [UIImage imageNamed:@"star"];
    
    starListButton.selected = [status intValue] == 1;
    starButton.selected = [status intValue] == 1;
    
}

- (IBAction)CheckIn:(id)sender{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//    if ([_feeds count] > indexPath.row) {
        NSDictionary *checkinData = [[_gDicFeeds objectForKey:@"check_in_details"] objectAtIndex:0];
        
        ShowCheckinInMap *checkinMap = [storyBoard instantiateViewControllerWithIdentifier:@"ShowCheckinInMap"];
        checkinMap.checkinName = [checkinData valueForKey:@"name"];
        checkinMap.latitude = [checkinData valueForKey:@"latitude"];
        checkinMap.longitude = [checkinData valueForKey:@"longitude"];
        [self.viewController.navigationController pushViewController:checkinMap animated:YES];
//    }
}


- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
//        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedsTable];
//        NSIndexPath *path = [_feedsTable indexPathForRowAtPoint:buttonPosition];

//        if ([feeds count] > path.row) {

            NSString *star_post_id = [_gDicFeeds objectForKey:@"post_id"];
            if(star_post_id != nil && ![star_post_id isEqualToString:@""]){
//                selectedPostIndex = (int) path.row;
                Comments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
                NSDictionary *imageInfo = _gDicFeeds;
                comment.postId = star_post_id;
                comment.mediaId = [imageInfo valueForKey:@"image_id"];
                comment.postDetails = _gDicFeeds;
                comment.isFromFeedsPage = @"YES";
//                comment.feeds = feeds;
                [self.navigationController pushViewController:comment animated:YES];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:PERFORM_LATER];
            }
//        }
    }
    else{
        [delegate.networkPopup show];
    }
}

-(IBAction)showStaredUsersList:(id)sender{
    if([[Util sharedInstance] getNetWorkStatus])
    {
//        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedTable];
//        NSIndexPath *path = [_feedTable indexPathForRowAtPoint:buttonPosition];
        NSMutableDictionary *feedDetail = _gDicFeeds;
        
//        if ([_feeds count] > path.row) {
            LikedUsersList *likedUsers = [[LikedUsersList alloc] initWithNibName:@"LikedUsersList" bundle:nil];
            likedUsers.postId = [feedDetail objectForKey:@"post_id"];
            [self.navigationController pushViewController:likedUsers animated:YES];
            
//        }
        
    }
}

//Set star and comment count
- (void)setStarAndCommentCount:(FeedCell *)cell forDictionary:(NSMutableDictionary  *)currentFeed{
    
    int starStatus = [[currentFeed objectForKey:@"star_status"] intValue];
    //    cell.starImage.image = (starStatus == 1)? [UIImage imageNamed:@"starActive"] : [UIImage imageNamed:@"star"];
    cell.starButton.selected = (starStatus == 1);
    
    long sCount = [[currentFeed objectForKey:@"stars_count"] longLongValue];
    if (sCount == 0){
        cell.starListButton.hidden = YES;
    }
    
    //    [cell.starCount setText:[Util getStarString:sCount]];
    //    cell.starCount.textColor = (starStatus == 1)? UIColorFromHexCode(THEME_COLOR) : [UIColor darkGrayColor];
    
    //    [cell.starListButton setTitle:[Util getStarString:sCount] forState:UIControlStateNormal];
    [cell.starListButton setTitle:[NSString stringWithFormat:@"%ld", sCount] forState:UIControlStateNormal];
    cell.starListButton.selected = starStatus == 1;
    
    ///////////////////////////////// Comment ////////////////////////
    
    long cComment = [[currentFeed valueForKey:@"comments_count"] longLongValue];
    
    //    cell.commentCount.text = [Util getCommentsString:cComment];
    cell.commentCount.text = [NSString stringWithFormat:@"%ld", cComment];
    
    ///////////////////////////////// Share ////////////////////////
    //    NSString * isShare = [[currentFeed valueForKey:@"is_share"] stringValue];
    
    long shareCount = [[currentFeed valueForKey:@"share_count"] longLongValue];
    cell.shareCount.text = [NSString stringWithFormat:@"%ld",shareCount];
    //    if (shareCount > 0) {
    //        cell.shareCount.text = [NSString stringWithFormat:@"%ld",shareCount];
    //    } else {
    //        cell.shareCount.text = @"0";
    //    }
}


//Show slider or move to post details page
- (void)moveToPostDetails:(UIImageView *)imageView index:(int)index fromTable:(UITableView *)tableView fromController:(UIViewController *)contoller fromSource:(NSMutableDictionary *)sourceDic mediaBase:(NSString *)baseUrl{
    
//    CGPoint imagePosition = [imageView convertPoint:CGPointZero toView:tableView];
//    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:imagePosition];
    
//    if ([sourceArray count] > indexPath.row) {
        NSMutableDictionary *feed = sourceDic;
//        if (([feed objectForKey:@"is_local"] != nil && [[feed objectForKey:@"is_local"] isEqualToString:@"false"]) || [feed objectForKey:@"is_local"] == nil) {
    
            //3. Play video
        if ([[feed valueForKey:@"video_present"] boolValue]) {
                
                NSMutableArray *mediaList = [[feed objectForKey:@"video"] mutableCopy];
                NSString *mediaUrl = [[mediaList objectAtIndex:index] valueForKey:@"media_url"];
                myViewCount = [[[mediaList objectAtIndex:index] valueForKey:@"views_count"] integerValue];
                myViewCount = myViewCount + 1;
                NSString *thumbUrl = [NSString stringWithFormat:@"%@%@",baseUrl,[[mediaList objectAtIndex:0] valueForKey:@"video_thumb_image_url"]];
                [self playVideo:mediaUrl withThumb:nil fromController:contoller withUrl:thumbUrl]; // Will trigger viewDidDisappear
                self.myBoolIsVideoViewedInBigScreen = YES;
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
                [self increaseViewCount:mediaUrl];
            }
//        }
        else // Show from Local
        {
            NSMutableArray *arrayMedia = [feed objectForKey:@"is_media"];
            BOOL Media_Type = false;
            NSMutableArray *sliderImages = [[NSMutableArray alloc] init];
            for (int i=0; i<[arrayMedia count]; i++) {
                NSMutableDictionary *img = [[NSMutableDictionary alloc] init];
                [img setValue:[[arrayMedia objectAtIndex:i] valueForKey:@"mediaThumb"] forKey:@"thumbImage"];
                Media_Type = [[[arrayMedia objectAtIndex:i] valueForKey:@"mediaType"] boolValue];
                [sliderImages addObject:img];
            }
            
            NSString *mediaUrl = [[arrayMedia objectAtIndex:0] valueForKey:@"mediaUrl"];
            [self playVideo:mediaUrl withThumb:[[arrayMedia objectAtIndex:0] valueForKey:@"mediaThumb"] fromController:contoller withUrl:nil];
            
        }
}


//Increase the video view count
- (void)increaseViewCount:(NSString *)mediaUrl {
    
    //Increase the video view count
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[delegate.videoIds valueForKey:mediaUrl] forKey:@"media_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ADD_VIDEO_COUNT withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            if(self.myBoolIsVideoViewedInBigScreen){
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ViewCountNotification"
                 object:nil];
            }
        }
        else{
            
        }
    } isShowLoader:NO];
}


//Play video
- (void)playVideo:(NSString *)mediaUrl withThumb:(UIImage *)thumbImg fromController:(UIViewController *)controller withUrl:(NSString *)thumbUrl{
    
    //    NSURL *url = [NSURL URLWithString:mediaUrl];
    
    NSString * aVideoUrl = [NSString stringWithFormat:@"%@%@",_gMediaBaseUrl,mediaUrl];
    
    //Allow landscape orientation
    delegate.shouldAllowRotation = TRUE;
    
    //Get player from data source
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:aVideoUrl]];
    //    AVPlayer *player = [delegate.moviePlayer objectForKey:mediaUrl];
    // AVPlayer *player = [AVPlayer playerWithURL:url];
//    [player setMuted:NO];
    
    delegate.currentVideoUrl = aVideoUrl;
    
    
    //Create player view controller
    //_playerViewController = [[AVPlayerViewController alloc] init];
    delegate.playerViewController.player = nil;
    delegate.playerViewController.player = player;
    
    //Assign the thumbimage in player view controller
    //It shows untill the player gets ready
    myThumbImage = [[UIImageView alloc] initWithFrame:delegate.playerViewController.view.frame];
    if (thumbImg != nil) {
        [myThumbImage setImage:thumbImg];
    }
    
    if (thumbUrl != nil) {
        [myThumbImage setImageWithURL:[NSURL URLWithString:thumbUrl]];
    }
    
    if (delegate.playerViewController.player.currentItem.playbackBufferEmpty) {
        NSLog(@"Buffer Empty");
    }
    
    myThumbImage.contentMode = UIViewContentModeScaleAspectFit;
    myThumbImage.center = delegate.playerViewController.view.center;
    myThumbImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _myBoolIsVideoPlayInBigScreen = YES;
    [self presentViewController:delegate.playerViewController animated:YES completion:^{
        if ((player.rate != 0) && (player.error == nil)) {
            // player is playing
        }
        else{
            [player play];
        }
    }];
}



-(void)showSharedUsersList:(UIButton*)sender{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        NSMutableDictionary *feedDetail = _gDicFeeds;
        
//        if ([_feeds count] > path.row) {
            LikedUsersList *likedUsers = [[LikedUsersList alloc] initWithNibName:@"LikedUsersList" bundle:nil];
            likedUsers.isShareList = YES;
            likedUsers.postId = [feedDetail objectForKey:@"post_id"];
//            NSString * isShare = [[feedDetail valueForKey:@"is_share"] stringValue];
            long shareCount = [[feedDetail valueForKey:@"share_count"] longLongValue];
            if (shareCount > 0) {
                [self.navigationController pushViewController:likedUsers animated:YES];
            }
//        }
        
    }
}

-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer{
    // Get selected Index
//    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:_feedTable];
//    NSIndexPath *indexPath = [_feedTable indexPathForRowAtPoint:buttonPosition];
//
//    if ([_feeds count] > indexPath.row) {
    
        if (![[_gDicFeeds objectForKey:@"is_local"] isEqualToString:@"true"]) {
            NSString *ownerId = [_gDicFeeds valueForKey:@"post_owner_id"];
            
            if ( [[Util getFromDefaults:@"player_id"] isEqualToString:ownerId]) {
                if(_gBoolIsFromFeeds){
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                    MyProfile *myProfile = [storyBoard instantiateViewControllerWithIdentifier:@"MyProfile"];
                    [self.navigationController pushViewController:myProfile animated:YES];
                }
            }
            else{
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
                profile.friendId = [_gDicFeeds objectForKey:@"post_owner_id"];
                profile.friendName = [_gDicFeeds objectForKey:@"name"];
                [self.navigationController pushViewController:profile animated:YES];
            }
        }
//    }
}

-(void)FriendProfileImageTapped:(UITapGestureRecognizer *)tapRecognizer{
    // Get selected Index
//    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:_feedTable];
//    NSIndexPath *indexPath = [_feedTable indexPathForRowAtPoint:buttonPosition];
//
//    if ([_feeds count] > indexPath.row) {
    
        if (![[_gDicFeeds objectForKey:@"is_local"] isEqualToString:@"true"]) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            profile.friendId = _gDicFeeds [@"share_details"][@"player_id"];
            profile.friendName = _gDicFeeds [@"share_details"][@"name"];
            [self.navigationController pushViewController:profile animated:YES];
        }
//    }
}

- (void)shareBtnTapped:(UIButton*)sender {
    
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_myTblViewFeedsTable];
//    NSIndexPath *path = [_myTblViewFeedsTable indexPathForRowAtPoint:buttonPosition];
    NSMutableDictionary *feedDetail = _gDicFeeds;
    //    shareIndexPath = path;
    UIAlertController *actionSheet;
    NSString * aStrCancelTit, * aStrSocialShareTit, *aStrTimelineTit;
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        actionSheet = [UIAlertController alertControllerWithTitle:@"Share" message:@"Share the post via" preferredStyle:UIAlertControllerStyleActionSheet];
        aStrCancelTit = @"Cancel";
        aStrSocialShareTit = @"Social";
        aStrTimelineTit = @"Timeline";
    }
    
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        actionSheet = [UIAlertController alertControllerWithTitle:@"分享" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        aStrCancelTit = @"取消";
        aStrSocialShareTit = @"社交";
        aStrTimelineTit = @"時間線";
    }
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:aStrCancelTit style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:aStrSocialShareTit style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
        
        //        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedTable];
        //        NSIndexPath *path = [_feedTable indexPathForRowAtPoint:buttonPosition];
        //        NSMutableDictionary *feedDetail = [_feeds objectAtIndex:path.row];
        
        NSString *aStrFeedName;
        //        NSString *aStrPostUrl = @"";
        
        UIImage * aShareImg = [UIImage imageNamed:@"icon_skatting_logo"];
        
        if ([[feedDetail valueForKey:@"video_present"] boolValue]) {
            
            NSString * aStrVideoUrl = feedDetail[@"video"][0][@"video_thumb_image_url"];
            NSString * aStrAppendVideoUrl = [NSString stringWithFormat:@"%@%@",_gMediaBaseUrl,aStrVideoUrl];
            NSURL * aVideoUrl = [NSURL URLWithString:aStrAppendVideoUrl];
            NSData *imageData = [NSData dataWithContentsOfURL:aVideoUrl];
            aShareImg = [UIImage imageWithData:imageData];
        }
        
        else if ([[feedDetail valueForKey:@"image_present"] boolValue] && [[feedDetail objectForKey:@"image"] count] > 0) {
            
            NSString * aStrImageUrl = feedDetail[@"image"][0][@"media_url"];
            //            NSString * aStrAppendVideoUrl = [NSString stringWithFormat:@"%@%@",_mediaBaseUrl,aStrVideoUrl];
            NSURL * aUrlImage = [NSURL URLWithString:aStrImageUrl];
            NSData *imageData = [NSData dataWithContentsOfURL:aUrlImage];
            aShareImg = [UIImage imageWithData:imageData];
        }
        
        
        aStrFeedName = feedDetail[@"social_share_link"];
        
        //        if ([_feeds count] > path.row) {
        //
        //            if (![feedDetail[@"post_content"]length]) {
        //
        //                aStrFeedName = feedDetail[@"name"];
        //            }
        //
        //            else {
        //
        //                aStrFeedName = feedDetail[@"post_content"];
        //            }
        //
        //            if ([feedDetail[@"image_count"] integerValue] != 0) {
        //
        //                aStrPostUrl = feedDetail[@"image"][0][@"media_url"];
        //            }
        //
        //            if ([feedDetail[@"video_count"] integerValue] != 0) {
        //
        //                aStrPostUrl = feedDetail[@"video"][0][@"media_url"];
        //            }
        //        }
        
        NSString *textToShare = aStrFeedName;
        //        NSURL *myWebsite = [NSURL URLWithString:aStrPostUrl];
        
        NSString * title =[NSString stringWithFormat:@"Varial %@",textToShare];
        
        NSArray *objectsToShare = @[title,aShareImg]; // @[title,aShareImg];
        
        // build an activity view controller
        UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:objectsToShare applicationActivities:nil];
        
        // and present it
        [self presentViewController:controller animated:YES completion:^{
            
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            [inputParams setValue:[feedDetail valueForKey:@"post_id"] forKey:@"post_id"];
            [inputParams setValue:[Util getFromDefaults:@"feed_type_id"] forKey:@"post_type"];
            [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:PROFILE_SHARE withCallBack:^(NSDictionary * response)
             {
                 if([[response valueForKey:@"status"] boolValue]){
                     //                     [[AlertMessage sharedInstance] showMessage:@"Your Share has been Posted"];
                     
                 }
                 else{
                 }
             } isShowLoader:NO];
            
            
        }];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:aStrTimelineTit style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[feedDetail valueForKey:@"post_id"] forKey:@"post_id"];
        [inputParams setValue:[Util getFromDefaults:@"feed_type_id"] forKey:@"post_type"];
        [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:PROFILE_SHARE withCallBack:^(NSDictionary * response)
         {
             if([[response valueForKey:@"status"] boolValue]){
                 [[AlertMessage sharedInstance] showMessage:@"Your Share has been Posted"];
                 
             }
             else{
             }
         } isShowLoader:NO];
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}


-(void)muteUnmutePressed:(UIButton*)sender {
    
    UIButton *btn = sender;
    //    btn.selected = !btn.selected;
    NSDictionary* userInfo;
    UIImage * aImgMute = [UIImage imageNamed:@"icon_mute"];
    UIImage * aImgUnMute = [UIImage imageNamed:@"icon_unmute"];
    
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    FeedCell *fcell = (FeedCell*)[_myTblViewFeedsTable cellForRowAtIndexPath:myIP];
    
    if (myBoolIsMutePressed) {
        myBoolIsMutePressed = false;
        userInfo = @{@"IsMuted": @"false"};
        [btn setImage:aImgUnMute forState:UIControlStateNormal];
        [self.player setMuted:NO];
        [fcell.videoView setJp_muted:NO];
    }
    
    else {
        myBoolIsMutePressed = true;
        userInfo = @{@"IsMuted": @"true"};
        [btn setImage:aImgMute forState:UIControlStateNormal];
        [self.player setMuted:YES];
        [fcell.videoView setJp_muted:true];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MuteUnMuteNotification"
     object:self userInfo:userInfo];
    
}

#pragma mark - Attributed Label delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSString *tag = [[label.text substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _myBoolIsVideoPlayInBigScreen = YES;
    if([tag containsString:@"#"]){
        SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
        [searchViewController searchFor:tag];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
    
    else if ([tag containsString:@"@"]) {
        InviteFriends *inviteFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
        NSString *stringWithoutSpecialChar = [tag
                                              stringByReplacingOccurrencesOfString:@"@" withString:@""];
        inviteFriends.getSearchString = stringWithoutSpecialChar;
        [self.navigationController pushViewController:inviteFriends animated:YES];
    }
}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    NSString *strUrl = [url absoluteString];
    
    if (![strUrl isEqualToString:@""]) {
        
        NSArray *array = [strUrl componentsSeparatedByString:@"/"];
        if ([array count] == 4 && [[array objectAtIndex:0] isEqualToString:@"VarialLink"]) {
            if ([[array objectAtIndex:1] intValue] == 0) {
                if ([[Util getFromDefaults:@"player_id"] isEqualToString:[array objectAtIndex:2]]) {
                    MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
                    [self.navigationController pushViewController:myProfile animated:YES];
                }
                else{
                    FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
                    friendProfile.friendId = [array objectAtIndex:2];
                    friendProfile.friendName =  friendProfile.friendName = [[array objectAtIndex:3] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    [self.navigationController pushViewController:friendProfile animated:YES];
                }
            }
            else
            {
                TeamViewController  *teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
                if ([[array objectAtIndex:3] isEqualToString:@"4"]) {
                    teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
                }
                teamView.teamId = [array objectAtIndex:2];
                [self.navigationController pushViewController:teamView animated:YES];
            }
        }
        else{
            //Open Url
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }
    else{
        //        CGPoint position = [label convertPoint:CGPointZero toView:_myTblViewFeedsTable];
        //        NSIndexPath *indexPath = [_myTblViewFeedsTable indexPathForRowAtPoint:position];
        //        if ([feeds count] > indexPath.row) {
        
        NSMutableDictionary *feed = _gDicFeeds;
        //            if ([[feed objectForKey:@"is_local"] isEqualToString:@"false"]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[feed valueForKey:@"post_id"] forKey:@"post_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [feed setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                [feed setValue:[NSNumber numberWithBool:FALSE] forKey:@"continue_reading_flag"];
                [_myTblViewFeedsTable reloadDataWithAnimation];
            }else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        } isShowLoader:NO];
        //            }
        //        }
    }
}
- (BOOL)shouldDownloadVideoForURL:(NSURL *)videoURL {
    return true;
}
- (BOOL)shouldAutoReplayForURL:(NSURL *)videoURL {
    
    return true;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
