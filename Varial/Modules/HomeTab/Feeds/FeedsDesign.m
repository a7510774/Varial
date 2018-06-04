
//  FeedsDesign.m
//  Varial
//
//  Created by jagan on 07/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "FeedsDesign.h"
#import "Util.h"
#import "NonMemberTeamViewController.h"
#import "LikedUsersList.h"
#import "PostBuzzardRun.h"
#import "SRGMediaPlayer.h"
#import "Feeds.h"

@implementation FeedsDesign
NSInteger viewCount;
-(id)init
{
    [self initObject];
    return self;
}

- (void)initObject{
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateChanged)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    videoItems = [[NSMutableDictionary alloc] init];
    
    // Post Notification
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MuteUnMuteNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMuteUnMuteValue:)
                                                 name:@"MuteUnMuteNotification"
                                               object:nil];
}

// Notification Function
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


//Add star for post
- (void)addStar:(UITableView *)tableView fromArray:(NSMutableArray *)source forControl:(id)sender {
    
    if([[Util sharedInstance] getNetWorkStatus])
    {
        // Get index from the table
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        FeedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([source count] > indexPath.row) {
            
            NSMutableDictionary *selectedStar = [source objectAtIndex:indexPath.row];
            
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
        }
    }
    else{
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.networkPopup show];
    }
}


//Add bookmark for post
- (void)addBookmark:(UITableView *)tableView fromArray:(NSMutableArray *)source forControl:(UIButton*)sender {
    
    if([[Util sharedInstance] getNetWorkStatus]) {
        
        // Get index from the table
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        FeedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([source count] > indexPath.row) {
            
            NSMutableDictionary *selectedStar = [source objectAtIndex:indexPath.row];
            
            // Get values from the Index
            NSString *star_post_id = [selectedStar objectForKey:@"post_id"];
            if (star_post_id != nil && ![star_post_id isEqualToString:@""]) {
                
                if ([[selectedStar valueForKey:@"isEnabled"] isEqualToString:@"true"]) {
                    
                    [selectedStar setValue:@"false" forKey:@"isEnabled"];
                    
                    NSString *bookmarkStatus = [selectedStar objectForKey:@"bookmark"];
                    NSString *updateBookmarkStatus = ([bookmarkStatus intValue] == 0)? @"1" : @"0";
                    [selectedStar setObject:updateBookmarkStatus forKey:@"bookmark"];
                    
                    if ([updateBookmarkStatus boolValue]) {
                        
                        [sender setImage:[UIImage imageNamed:ICON_BOOKMARK_SELECT] forState:UIControlStateNormal];
                    }
                    
                    else {
                        
                        [sender setImage:[UIImage imageNamed:ICON_BOOKMARK_UN_SELECT] forState:UIControlStateNormal];
                    }
                    
                    // [self designTheStarView:sender Status:update_star_status Count:updated_starCount forTableView:tableView];
                    
                    //Build Input Parameters
                    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
                    [inputParams setValue:star_post_id forKey:@"post_id"];
                    [inputParams setValue:updateBookmarkStatus forKey:@"bookmark"];
                   // [inputParams setValue:@"1" forKey:@"bookmark"];

                    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
                    
                    [[Util sharedInstance] sendHTTPPostRequestWithError:inputParams withRequestUrl:ADD_BOOKMARK withCallBack:^(NSDictionary * response, NSError *error){
                        if (error != nil) {
                            [selectedStar setValue:@"true" forKey:@"isEnabled"];
                            //[self designTheStarView:sender Status:update_star_status Count:updated_starCount forTableView:tableView];
                        }
                        else{
                            // Check if cell matches post id
                            NSString *postId = [cell postId];
                            if([[response valueForKey:@"status"] boolValue]){
                                
                                // Update Stat Status
                                if ([postId isEqualToString:star_post_id]) {
                                    //[self designTheStarView:sender Status:update_star_status Count:[response objectForKey:@"star_count"] forTableView:tableView];
                                }
                                
                                // Update star status and star count in array
                                [selectedStar setValue:@"true" forKey:@"isEnabled"];
                            }
                            else
                            {
                                if ([postId isEqualToString:star_post_id]) {
                                    [selectedStar setValue:@"true" forKey:@"isEnabled"];
                                    //[self designTheStarView:sender Status:star_status Count:old_Count forTableView:tableView];
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
        }
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

//Set star and comment count
- (void)setStarAndCommentCount:(FeedCell *)cell forDictionary:(NSMutableDictionary  *)currentFeed{
    
    int starStatus = [[currentFeed objectForKey:@"star_status"] intValue];
//    cell.starImage.image = (starStatus == 1)? [UIImage imageNamed:@"starActive"] : [UIImage imageNamed:@"star"];
    cell.starButton.selected = (starStatus == 1);
        
    long sCount = [[currentFeed objectForKey:@"stars_count"] longLongValue];
    if (sCount == 0){
        cell.starListButton.hidden = YES;
    }
    else
    {
        if (![_viewController isKindOfClass:[PostBuzzardRun class]]) {
            cell.starListButton.hidden = NO;
        }
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
- (void)moveToPostDetails:(UIImageView *)imageView index:(int)index fromTable:(UITableView *)tableView fromController:(UIViewController *)contoller fromSource:(NSMutableArray *)sourceArray mediaBase:(NSString *)baseUrl{
    
    CGPoint imagePosition = [imageView convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:imagePosition];
    
    if ([sourceArray count] > indexPath.row) {
        NSMutableDictionary *feed = [sourceArray objectAtIndex:indexPath.row];
        if (([feed objectForKey:@"is_local"] != nil && [[feed objectForKey:@"is_local"] isEqualToString:@"false"]) || [feed objectForKey:@"is_local"] == nil) {
            
            //1.Check post has image
            if ([[feed valueForKey:@"image_present"] boolValue] && [[feed objectForKey:@"image"] count] == 1) {
                
                NSMutableArray *mediaList = [[feed objectForKey:@"image"] mutableCopy];
                NSMutableArray *sliderImages = [[NSMutableArray alloc] init];
                for (int i=0; i<[mediaList count]; i++) {
                    NSMutableDictionary *img = [[NSMutableDictionary alloc] init];
                    [img setValue:[[mediaList objectAtIndex:i] valueForKey:@"media_url"] forKey:@"imageUrl"];
                    [sliderImages addObject:img];
                }
                [Util showSlider:contoller forImage:sliderImages atIndex:0];
            }
            //2. If post has more than a image
            else if ([[feed valueForKey:@"image_present"] boolValue] && [[feed objectForKey:@"image"] count] > 1) {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                PostDetails *postDetails = [storyBoard instantiateViewControllerWithIdentifier:@"PostDetails"];
                postDetails.postId = [feed valueForKey:@"post_id"];
                postDetails.postDetails = feed;
                postDetails.mediaBase = baseUrl;
                postDetails.startIndex = index;
                postDetails.feedTable = tableView;
                postDetails.previousController = contoller;
                postDetails.feedsList = sourceArray;
                postDetails.feedIndex = indexPath.row;
                if ([contoller isKindOfClass:[NonMemberTeamViewController class]]) {
                    NonMemberTeamViewController *nonMember = (NonMemberTeamViewController *)contoller;
                    postDetails.canNotLike = nonMember.canLike ? nil : @"YES";
                    postDetails.canNotComment = nonMember.canComment ? nil : @"YES";
                }
                [contoller.navigationController pushViewController:postDetails animated:YES];
            }
            //3. Play video
            else if ([[feed valueForKey:@"video_present"] boolValue]) {
                
                NSMutableArray *mediaList = [[feed objectForKey:@"video"] mutableCopy];
                NSString *mediaUrl = [[mediaList objectAtIndex:index] valueForKey:@"media_url"];
                viewCount = [[[mediaList objectAtIndex:index] valueForKey:@"views_count"] integerValue];
                viewCount = viewCount + 1;
                NSString *thumbUrl = [NSString stringWithFormat:@"%@%@",baseUrl,[[mediaList objectAtIndex:0] valueForKey:@"video_thumb_image_url"]];
                [self playVideo:mediaUrl withThumb:nil fromController:contoller withUrl:thumbUrl]; // Will trigger viewDidDisappear
                self.myBoolIsVideoViewedInBigScreen = YES;
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
                [self increaseViewCount:mediaUrl];
            }
        }
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
            if (Media_Type)  // Image
            {
                [Util showSlider:contoller forImage:sliderImages atIndex:indexPath.row];
            }
            else  // Video
            {
                NSString *mediaUrl = [[arrayMedia objectAtIndex:0] valueForKey:@"mediaUrl"];
                [self playVideo:mediaUrl withThumb:[[arrayMedia objectAtIndex:0] valueForKey:@"mediaThumb"] fromController:contoller withUrl:nil];
            }
        }
    }
}

//Play video
- (void)playVideo:(NSString *)mediaUrl withThumb:(UIImage *)thumbImg fromController:(UIViewController *)controller withUrl:(NSString *)thumbUrl{
    
    NSURL *url = [NSURL URLWithString:mediaUrl];
    
    //Allow landscape orientation
    delegate.shouldAllowRotation = TRUE;
    
    //Get player from data source
//    AVPlayer *player = [delegate.moviePlayer objectForKey:mediaUrl];
     AVPlayer *player = [AVPlayer playerWithURL:url];
    [player setMuted:NO];
    
//    delegate.currentVideoUrl = mediaUrl;
    
    
    //Create player view controller
    self.playerViewController = [[AVPlayerViewController alloc] init];
    self.playerViewController.player = nil;
    self.playerViewController.player = player;
    
    //Assign the thumbimage in player view controller
    //It shows untill the player gets ready
    thumbImage = [[UIImageView alloc] initWithFrame:self.playerViewController.view.frame];
    if (thumbImg != nil) {
        [thumbImage setImage:thumbImg];
    }
    
    if (thumbUrl != nil) {
        [thumbImage setImageWithURL:[NSURL URLWithString:thumbUrl]];
    }
    
    if (self.playerViewController.player.currentItem.playbackBufferEmpty) {
        NSLog(@"Buffer Empty");
    }
    
    thumbImage.contentMode = UIViewContentModeScaleAspectFit;
    thumbImage.center = self.playerViewController.view.center;
    thumbImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  //  [delegate.playerViewController.view insertSubview:thumbImage atIndex:0];FIXME
    
//    if ((player.rate != 0) && (player.error == nil)) {
//        // player is playing
//    }
//    else{
//        [player play];
//    }
    
    //Launch the player
//    [controller presentViewController:delegate.playerViewController animated:YES completion:NULL];
    [controller presentViewController:self.playerViewController animated:YES completion:^{
        if ((player.rate != 0) && (player.error == nil)) {
            // player is playing
        }
        else{
            [player play];
        }
    }];
}


//Remove the background view once player state has changed
-(void)moviePlayBackStateChanged{
    //[thumbImage setHidden:YES];
    //kp
    [delegate.playerViewController.view willRemoveSubview:thumbImage];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

# pragma mark - Layout

// Some known values
// TODO: Needs to be updated for Team Feed Activity
//- (CGFloat)heightForFeedCell:(NSDictionary *)data {
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    
//    // Profile view
//    float contentHeight = 44.0 + CELL_MARGIN * 2;
//    
//    // Text view
//    NSString *postContent = [data objectForKey:@"post_content"];
//    if (![postContent isEqualToString:@""]) {
//        CGSize contentSize = [self sizeForText:postContent withWidth:screenRect.size.width - 14*2 andFont:[UIFont fontWithName:@"CenturyGothic" size:14]];
//        contentHeight += contentSize.height + CELL_MARGIN;
//    }
//    
//    if ([[data objectForKey:@"check_in_details"] count] > 0) {
//        contentHeight += 40 + CELL_MARGIN;
//    }
//    
//    if ([[data objectForKey:@"link_details"] count] > 0) {
//        contentHeight += 70 + CELL_MARGIN;
//    }
//    
//    if ([[data objectForKey:@"image_present"] boolValue]) {
//        NSArray *images = [data objectForKey:@"image"];
//        CGSize imageSize = [Util getAspectRatio:[[images firstObject] objectForKey:@"media_dimension"] ofParentWidth:screenRect.size.width];
//        contentHeight += imageSize.height;
//    }
//    else if ([[data objectForKey:@"video_present"] boolValue]) {
//        NSArray *video = [data objectForKey:@"video"];
//        CGSize videoSize = [Util getAspectRatio:[[video firstObject] objectForKey:@"media_dimension"] ofParentWidth:screenRect.size.width];
//        contentHeight += videoSize.height;
//    }
//    
//    // options view
//    contentHeight += 42.0 + CELL_MARGIN;
//    
//    return contentHeight;
//}

- (CGSize)sizeForText:(NSString *)text withWidth:(CGFloat)width andFont:(UIFont * _Nullable)font {
    CGSize size = CGSizeZero;
    if (text && ![text isEqualToString:@""]) {
        CGRect frame = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size;
}





// Design the Image, Video, and text Container
- (void)designTheContainerView:(FeedCell *)cell forFeedData:(NSMutableDictionary *)currentFeed mediaBase:(NSString *)mediaBaseUrl forDelegate:(UIViewController *)viewController tableView:(UITableView *)tableview {
    
    // Build Common feed data
    [self buildCommonDataInFeedList:cell forFeedData:currentFeed];
    
    // Layout the parent views
//    [self layoutFeedCell:cell forFeedData:currentFeed];
    [cell setCellData:currentFeed];

    // Finish with enabling media
    
    // Play and activity icon for video

    [cell.playIcon setHidden:YES];
    
    DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScale tintColor:[UIColor whiteColor] size:15.0f];
    activityIndicatorView.frame = cell.activityIndicator.bounds;
    [activityIndicatorView startAnimating];
    [cell.activityIndicator setHidden:YES];
    [[cell.activityIndicator subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.activityIndicator addSubview:activityIndicatorView];
    cell.isVideo = NO;
    
    if ([currentFeed objectForKey:@"post_id"] != nil) {
        [cell setPostId:[currentFeed objectForKey:@"post_id"]];
    }
    
    //check for the media content, if true call the update media Content method
    if([[currentFeed objectForKey:@"image"] count] > 0 || [[currentFeed objectForKey:@"video"] count] > 0){
        cell.message.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        [cell.message setText:[currentFeed objectForKey:@"post_content"]];
        [Util highlightHashtagsInLabel:cell.message];
        
        if ([[currentFeed objectForKey:@"continue_reading_flag"] intValue] == 1) {
            if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
                [Util setAddMoreTextForLabel:cell.message endsWithString:ENDS_WITH_STRING forlength:256 forColor:UIColorFromHexCode(THEME_COLOR)];
            }
            else
            {
                [Util setAddMoreTextForLabel:cell.message endsWithString:ENDS_WITH_STRING forlength:(int)[cell.message.text length] forColor:UIColorFromHexCode(THEME_COLOR)];
            }
        }

        // Delegate callback for Continue Reading
        cell.message.delegate = _viewController;
        
        if([currentFeed objectForKey:@"image"] != nil && [[currentFeed objectForKey:@"image"] count] > 0){
            NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[currentFeed objectForKey:@"image"]];
            
            // Remove any remaining video layers
            [cell.mainPreview.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
            
            //hide the view count label for image post
//            cell.videoViewCountHeight.constant = 0;
            cell.videoViewCount.hidden = YES;
            cell.gBtnMuteUnMute.hidden = YES;
            //iterate the medias
            for(int loop = 0; loop < [medias count]; loop++) {
                
                NSDictionary *mediaData = [[NSDictionary alloc] initWithDictionary:[medias objectAtIndex:loop]];
                CGSize imageSize = [Util getAspectRatio:[mediaData valueForKey:@"media_dimension"] ofParentWidth:self.viewController.view.frame.size.width];
//                UIImageView *currentImage = [[UIImageView alloc] init];
                UIImageView *currentImage = (loop == 1) ? cell.subPreview : cell.mainPreview;
                
                // Container already sized
                if (loop == 0){
                    cell.subPreview.hidden = YES;
                    CGRect frame = currentImage.frame;
                    currentImage.frame = CGRectMake(frame.origin.x, frame.origin.y, imageSize.width, imageSize.height);
//                    currentImage.frame = CGRectMake(0, 0, cell.medias.frame.size.width, cell.medias.frame.size.height);
                    
//                    cell.mediaHeight.constant = imageSize.height;
                    currentImage.clipsToBounds = YES;
                }
                else{
                    cell.subPreview.hidden = NO;
                    cell.subPreview.clipsToBounds = YES;
                    cell.subPreview.contentMode = UIViewContentModeScaleAspectFill;
                }
                
                // Show image from local
                if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
                    NSMutableArray *getlocal = [[NSMutableArray alloc] initWithArray:[currentFeed objectForKey:@"is_media"]];
                    [currentImage setImage:[[getlocal objectAtIndex:loop] objectForKey:@"mediaThumb"]];
                }
                else // show image from server
                {
                    if (loop == 0) {
                        [currentImage.layer setValue:[mediaData valueForKey:@"media_dimension"] forKey:@"dimension"];
                    }
                    
                    // Show DownLoad Progress for media
                    [self showDownloadProgress:cell imageView:currentImage mediaUrl:[mediaData valueForKey:@"media_url"] imageSize:imageSize onProgressView:[Util designdownloadProgress:cell.downloadProgress]];
//                    [self showDownloadProgress:cell imageView:currentImage mediaUrl:[mediaData valueForKey:@"media_url"] imageSize:cell.medias.frame.size onProgressView:[Util designdownloadProgress:cell.downloadProgress]];
                    
                }
                
                cell.imageCount.hidden = YES;
                if(loop == 1)
                {
                    // Show border color for small image
                    currentImage.layer.masksToBounds = YES;
                    currentImage.layer.borderColor = [[UIColor whiteColor] CGColor];
                    currentImage.layer.borderWidth = 1.0f;
                    
                    // Show image count
                    [cell.imageCount setText:[NSString stringWithFormat:@"+%lu",(unsigned long)[medias count]-2]];
                    [Util makeCircularImage:cell.imageCount withBorderColor:[UIColor clearColor]];
                    if([medias count] != 2)
                        cell.imageCount.hidden = NO;
                    else
                        cell.imageCount.hidden = YES;
                    
                    //Add click event
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPostDetailsAtSecondIndex:)];
                    [cell.subPreview setUserInteractionEnabled:YES];
                    [cell.subPreview addGestureRecognizer:tap];
                    
                    break;
                }
                else{
                    //Add click event
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPostDetailsAtFirstIndex:)];
                    [currentImage setUserInteractionEnabled:YES];
                    [currentImage addGestureRecognizer:tap];
                }
            }
            cell.isVideo = FALSE;
            [cell.videoView.layer.sublayers makeObjectsPerformSelector: @selector(removeFromSuperlayer)];
//            [cell setNeedsLayout];
//            [cell setNeedsUpdateConstraints];
        }
        else if([currentFeed objectForKey:@"video"] != nil && [[currentFeed objectForKey:@"video"] count] > 0){
            
            cell.gBtnMuteUnMute.hidden = NO;
            NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[currentFeed objectForKey:@"video"]];
            //iterate the medias
            for(int loop = 0; loop < [medias count]; loop++){
                cell.isVideo = YES;
                cell.subPreview.hidden = YES;
                cell.imageCount.hidden = YES;
                [cell.videoView setHidden:YES];
                UIImageView *currentImage = [[UIImageView alloc] init];
                currentImage = (loop == 1)? cell.subPreview : cell.mainPreview;
                currentImage.clipsToBounds = YES;
                [cell.mainPreview setHidden:NO];
                CGSize mediaSize = [Util getAspectRatio:[[medias objectAtIndex:0] objectForKey:@"media_dimension"] ofParentWidth:self.viewController.view.frame.size.width];
                
//                cell.mediaHeight.constant = imageSize.height;
                
                cell.videoView.frame = CGRectMake(0, 0, cell.medias.frame.size.width, cell.medias.frame.size.height);
                
                if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
                    // Remove any remaining video layers
                    [cell.mainPreview.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
                    
                    NSMutableArray *getlocal = [[NSMutableArray alloc] initWithArray:[currentFeed objectForKey:@"is_media"]];
                    
                    currentImage.image =  [[getlocal objectAtIndex:0] objectForKey:@"mediaThumb"];
                    [cell.playIcon setHidden:YES];
                    [cell.activityIndicator setHidden:YES];
                    //Hide the view count label for local videos
//                    cell.videoViewCountHeight.constant = 0;
                    cell.videoViewCount.hidden = NO;
                    
                }
                else
                {
                    //Show the view count label for video post
                    int viewCount = [[[medias objectAtIndex:0] objectForKey:@"views_count"] intValue];
                    if (viewCount == 0) {
                        //Hide the view count label for post contains 0 views
//                        cell.videoViewCountHeight.constant = 0;
                        cell.videoViewCount.hidden = YES;
                    }
                    else {
//                        cell.videoViewCountHeight.constant = 20;
                        cell.videoViewCount.hidden = NO;
                        cell.videoViewCount.text = [Util getViewsString:viewCount];
                    }
                    
                    [delegate.videoIds setValue:[[medias objectAtIndex:loop] valueForKey:@"video_id"] forKey:[[medias objectAtIndex:loop] valueForKey:@"media_url"]];
                    
                    [currentImage.layer setValue:[[medias objectAtIndex:0] objectForKey:@"media_dimension"] forKey:@"dimension"];
                    
                    // Show DownLoad Progress for media
                    
                    if(!_gIsFromChannel) {
                        NSString *strVideoUrl = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[[medias objectAtIndex:0] objectForKey:@"video_thumb_image_url"]]];
                        [self showDownloadProgress:cell imageView:currentImage mediaUrl:strVideoUrl imageSize:cell.medias.frame.size onProgressView:[Util designdownloadProgress:cell.downloadProgress]];
                    }
//
                    [cell.playIcon setHidden:YES];
                    [cell.activityIndicator setHidden:YES];
//                    NSLog(@"frame height: %@", NSStringFromCGRect(cell.medias.frame));
                    cell.videoView.frame = cell.medias.frame;
                    
                    //Add click event
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPostDetailsAtFirstIndex:)];
                    [currentImage setUserInteractionEnabled:YES];
                    [currentImage addGestureRecognizer:tap];
                    
//                    NSLog(@"before inline %@", NSStringFromCGRect(cell.videoView.frame));
//                    [self playInlineVideo:cell Url:[[medias objectAtIndex:loop] valueForKey:@"media_url"]];
                    [self playInlineVideo:cell withSize:mediaSize andUrl:[[medias objectAtIndex:loop] valueForKey:@"media_url"]];
                    
                }
                if(loop == 1){
                    [cell.mainPreview setHidden:NO];
                    break;
                }
            }
        }
//        if ([cell.message.text isEqualToString:@""]) {
//            cell.messageMargin.active = NO;
//        } else {
//            cell.messageMargin.active = YES;
//        }
        
    }
    else{
        cell.message.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        [cell.message setText:[currentFeed objectForKey:@"post_content"]];
        [Util highlightHashtagsInLabel:cell.message];
        cell.message.delegate = _viewController;
        if ([[currentFeed objectForKey:@"continue_reading_flag"] intValue] == 1) {
            if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
                [Util setAddMoreTextForLabel:cell.message endsWithString:ENDS_WITH_STRING forlength:256 forColor:UIColorFromHexCode(THEME_COLOR)];
            }
            else
            {
                [Util setAddMoreTextForLabel:cell.message endsWithString:ENDS_WITH_STRING forlength:(int)[cell.message.text length] forColor:UIColorFromHexCode(THEME_COLOR)];
            }
        }
    }
    
    NSArray *urlPreviewDetails = [[NSArray alloc] initWithArray:[currentFeed objectForKey:@"link_details"]];
    if ([urlPreviewDetails count] != 0) {
        NSDictionary *previewDetails = [[NSDictionary alloc] initWithDictionary:[urlPreviewDetails objectAtIndex:0]];
        cell.urlPreviewHeight.constant = 70;
        [cell.urlPreview setHidden:NO];
//        cell.urlPreviewMargin.active = NO;
        [cell.urlPreview loadWithSiteData:[previewDetails objectForKey:@"link"] title:[previewDetails objectForKey:@"link_title"] description:[previewDetails objectForKey:@"link_description"] siteName:[previewDetails objectForKey:@"link_sitename"] imageUrl:[previewDetails objectForKey:@"link_image_url"]];
        
        if([[previewDetails objectForKey:@"link_image_url"] length] == 0)
            cell.urlPreview.imageViewWidth.constant = 0;
        
        if([[previewDetails objectForKey:@"link_image_url"] length] == 0 && [[previewDetails objectForKey:@"link_title"] length] == 0 && [[previewDetails objectForKey:@"link_description"] length] == 0 &&  [[previewDetails objectForKey:@"link_sitename"] length] == 0)
        {
            [cell.urlPreview setHidden:YES];
            cell.urlPreviewHeight.constant = 0;
//            cell.urlPreviewMargin.active = YES;
        }
        
    }
    else {
        [cell.urlPreview setHidden:YES];
        cell.urlPreviewHeight.constant = 0;
//        cell.urlPreviewMargin.active = YES;
    }
//    cell.mainPreview.hidden = YES;
    
//    int64_t delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [cell layoutSubviews];
//        [cell setNeedsLayout];
//        [cell layoutIfNeeded];
//        [_feedTable reloadData];
//    });
    
//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];
    
//    [cell.contentView setNeedsLayout];
//    [cell.contentView setNeedsUpdateConstraints];

//    [cell setNeedsUpdateConstraints];
    
    [cell layoutConstraints];
    [cell setNeedsLayout];
}

-(void)showDownloadProgress :(FeedCell *)cell imageView:(UIImageView *)imageView mediaUrl:(NSString *)url imageSize:(CGSize )imageSize onProgressView:(MBCircularProgressBarView *)downloadProgress{
    
    [imageView yy_setImageWithURL:[NSURL URLWithString:url]
                      placeholder:[UIImage imageNamed:@"image_placeholder.png"]
                          options:YYWebImageOptionIgnoreFailedURL | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             if (expectedSize > 0 && receivedSize > 0) {
                                 CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                 downloadProgress.hidden = NO;
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


# pragma mark - Post Details

//Tap gesture recognizer for image to show post feeds
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

- (void) showPostDetailsAtSecondIndex:(UITapGestureRecognizer *)tapRecognizer {
    //Convert view to imageview
    
    if (!self.isSelectVideoCell) {
        
        self.isSelectVideoCell = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            self.isSelectVideoCell = NO;
            
        });
        
        UIImageView *imageView = (UIImageView *)tapRecognizer.view;
        [self showPostDetails:imageView index:1];
    }
}

- (void)showPostDetails:(UIImageView *)imageView index:(int)index{
    [self moveToPostDetails:imageView index:index fromTable:_feedTable fromController:_viewController fromSource:_feeds mediaBase:_mediaBaseUrl];
}

// Build Common data in feeds list
- (void) buildCommonDataInFeedList :(FeedCell *) cell forFeedData:(NSMutableDictionary *) currentFeed {
    
    // Poster Profile IMage
    NSMutableDictionary *postersProfileImage = [[NSMutableDictionary alloc] initWithDictionary:[currentFeed objectForKey:@"posters_profile_image"]];
    NSString *profileImageUrl = [[NSString alloc] initWithString:[postersProfileImage  objectForKey:@"profile_image"]];
    //[cell.profileImage setImageWithURL:[NSURL URLWithString:profileImageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    NSString * isShare = [[currentFeed valueForKey:@"is_share"] stringValue];
//    if (![isShare isEqualToString:@"1"]) {
        [cell.profileImage yy_setImageWithURL:[NSURL URLWithString:profileImageUrl] placeholder:[UIImage imageNamed:IMAGE_HOLDER]];
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
    int isOwner = [[currentFeed objectForKey:@"am_owner"] intValue];
    if (isOwner == 1) {
        cell.menuButton.hidden = NO;
        cell.reportButton.hidden = YES;
        cell.sharedReportButton.hidden = YES;
        cell.sharedMenuButton.hidden = NO;
    }
    else{
        cell.menuButton.hidden = YES;
        cell.reportButton.hidden = NO;
        cell.sharedMenuButton.hidden = YES;
        cell.sharedReportButton.hidden = NO;
    }
    
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

    if ([isShare isEqualToString:@"1"]) {
        cell.sharedMenuButton.hidden = NO;
        cell.sharedBtnBookmark.hidden = NO;
        cell.sharedPrivacyImage.hidden = NO;
        cell.sharedReportButton.hidden = NO;
        cell.menuButton.hidden = YES;
        cell.privacyImage.hidden = YES;
        cell.btnBookmark.hidden = YES;
        cell.reportButton.hidden = YES;
        cell.sharedHeightConstraint.active = YES;
    } else {
        cell.sharedMenuButton.hidden = YES;
        cell.sharedBtnBookmark.hidden = YES;
        cell.sharedPrivacyImage.hidden = YES;
        cell.sharedReportButton.hidden = YES;
        cell.sharedHeightConstraint.active = NO;
//        cell.menuButton.hidden = NO;
        cell.privacyImage.hidden = NO;
        cell.btnBookmark.hidden = NO;
//        cell.reportButton.hidden = NO;
    }
    
    if([_viewController isKindOfClass:[MyProfile class]]){
        cell.sharedReportButton.hidden = YES;
        cell.reportButton.hidden = YES;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_viewController action:@selector(ShowMenu:)];
    [cell.menuButton setUserInteractionEnabled:YES];
    [cell.menuButton addGestureRecognizer:tap];
    UITapGestureRecognizer *Sharedtap = [[UITapGestureRecognizer alloc] initWithTarget:_viewController action:@selector(ShowSharedMenu:)];
    [cell.sharedMenuButton setUserInteractionEnabled:YES];
    [cell.sharedMenuButton addGestureRecognizer:Sharedtap];
    UITapGestureRecognizer *reportTap = [[UITapGestureRecognizer alloc] initWithTarget:_viewController action:@selector(reportButtonAction:)];
    UITapGestureRecognizer *sharedReportTap = [[UITapGestureRecognizer alloc] initWithTarget:_viewController action:@selector(sharedReportButtonAction:)];
    [cell.reportButton setUserInteractionEnabled:YES];
    [cell.reportButton addGestureRecognizer:reportTap];
    [cell.sharedReportButton setUserInteractionEnabled:YES];
    [cell.sharedReportButton addGestureRecognizer:sharedReportTap];
    
    [cell.starButton addTarget:_viewController action:@selector(Star:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentsButton addTarget:_viewController action:@selector(showCommentPage:) forControlEvents:UIControlEventTouchUpInside];
    [cell.starListButton addTarget:self action:@selector(showStaredUsersList:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareListButton addTarget:self action:@selector(showSharedUsersList:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnShare addTarget:self action:@selector(shareBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnBookmark addTarget:_viewController action:@selector(bookmarkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.sharedBtnBookmark addTarget:_viewController action:@selector(bookmarkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSString *bookmarkStatus = [currentFeed objectForKey:@"bookmark"];

    if ([bookmarkStatus boolValue]) {
        
//        cell.btnBookmark.hidden = NO;
        
        [cell.btnBookmark setImage:[UIImage imageNamed:ICON_BOOKMARK_SELECT] forState:UIControlStateNormal];
        [cell.sharedBtnBookmark setImage:[UIImage imageNamed:ICON_BOOKMARK_SELECT] forState:UIControlStateNormal];
    }
    
    else {
        
//        cell.btnBookmark.hidden = NO;
        [cell.btnBookmark setImage:[UIImage imageNamed:ICON_BOOKMARK_UN_SELECT] forState:UIControlStateNormal];
        [cell.sharedBtnBookmark setImage:[UIImage imageNamed:ICON_BOOKMARK_UN_SELECT] forState:UIControlStateNormal];
    }
}

-(IBAction)showStaredUsersList:(id)sender{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedTable];
        NSIndexPath *path = [_feedTable indexPathForRowAtPoint:buttonPosition];
        NSMutableDictionary *feedDetail = [_feeds objectAtIndex:path.row];

        if ([_feeds count] > path.row) {
            LikedUsersList *likedUsers = [[LikedUsersList alloc] initWithNibName:@"LikedUsersList" bundle:nil];
            likedUsers.postId = [feedDetail objectForKey:@"post_id"];
            [_viewController.navigationController pushViewController:likedUsers animated:YES];

        }

    }
}

-(void)showSharedUsersList:(UIButton*)sender{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedTable];
        NSIndexPath *path = [_feedTable indexPathForRowAtPoint:buttonPosition];
        NSMutableDictionary *feedDetail = [_feeds objectAtIndex:path.row];
        
        if ([_feeds count] > path.row) {
            LikedUsersList *likedUsers = [[LikedUsersList alloc] initWithNibName:@"LikedUsersList" bundle:nil];
            likedUsers.isShareList = YES;
            likedUsers.postId = [feedDetail objectForKey:@"post_id"];
            NSString * isShare = [[feedDetail valueForKey:@"is_share"] stringValue];
            if ([isShare isEqualToString:@"1"]) {
                [_viewController.navigationController pushViewController:likedUsers animated:YES];
            }
        }
        
    }
}

//- (void)bookmarkBtnTapped:(UIButton*)sender {
//
//    if([[Util sharedInstance] getNetWorkStatus])
//    {
//        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedTable];
//        NSIndexPath *path = [_feedTable indexPathForRowAtPoint:buttonPosition];
//
//            if ([_feeds count] > path.row) {
//
//            NSMutableDictionary *selectedStar = [source objectAtIndex:indexPath.row];
//
//            // Get values from the Index
//            NSString *star_post_id = [selectedStar objectForKey:@"post_id"];
//            if (star_post_id != nil && ![star_post_id isEqualToString:@""]) {
//
//                if ([[selectedStar valueForKey:@"isEnabled"] isEqualToString:@"true"]) {
//
//                    [selectedStar setValue:@"false" forKey:@"isEnabled"];
//
//                    NSString *star_status = [selectedStar objectForKey:@"star_status"];
//                    NSString *update_star_status = ([star_status intValue] == 0)? @"1" : @"0";
//                    NSString *old_Count = [NSString stringWithFormat:@"%@", [selectedStar objectForKey:@"stars_count"]];
//                    NSString *updated_starCount = ([update_star_status intValue] == 1)? [NSString stringWithFormat:@"%lld", [old_Count longLongValue]+1]  :  [NSString stringWithFormat:@"%lld",[old_Count longLongValue]-1];
//
//                    [self designTheStarView:sender Status:update_star_status Count:updated_starCount forTableView:tableView];
//
//                    //Build Input Parameters
//                    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
//                    [inputParams setValue:star_post_id forKey:@"post_id"];
//                    [inputParams setValue:update_star_status forKey:@"star_flag"];
//                    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
//
//                    [[Util sharedInstance] sendHTTPPostRequestWithError:inputParams withRequestUrl:STAR_UNSTAR withCallBack:^(NSDictionary * response, NSError *error){
//                        if (error != nil) {
//
//
//                        }
//
//                        else{
//                            if([[response valueForKey:@"status"] boolValue]) {
//
//                                // Update Stat Status
//                                if ([postId isEqualToString:star_post_id]) {
//                                    [self designTheStarView:sender Status:update_star_status Count:[response objectForKey:@"star_count"] forTableView:tableView];
//                                }
//
//                                // Update star status and star count in array
//                                [selectedStar setObject:update_star_status forKey:@"star_status"];
//                                [selectedStar setObject:[response objectForKey:@"star_count"] forKey:@"stars_count"];
//                                [selectedStar setValue:@"true" forKey:@"isEnabled"];
//                            }
//                            else
//                            {
//                                if ([postId isEqualToString:star_post_id]) {
//                                    [selectedStar setValue:@"true" forKey:@"isEnabled"];
//                                    [self designTheStarView:sender Status:star_status Count:old_Count forTableView:tableView];
//                                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
//                                }
//                            }
//
//                        }
//
//                    } isShowLoader:NO];
//
//                }
//
//            }
//            else{
//                [[AlertMessage sharedInstance] showMessage:PERFORM_LATER];
//            }
//        }
//    }
//    else{
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [delegate.networkPopup show];
//    }
//
////    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedTable];
////    NSIndexPath *path = [_feedTable indexPathForRowAtPoint:buttonPosition];
////    NSMutableDictionary *feedDetail = [_feeds objectAtIndex:path.row];
////
////    if ([_feeds count] > path.row) {
////
////        if ([feedDetail[@"is_bookmark"] boolValue]) {
////
////        }
////    }
//}

- (void)shareBtnTapped:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedTable];
    NSIndexPath *path = [_feedTable indexPathForRowAtPoint:buttonPosition];
    NSMutableDictionary *feedDetail = [_feeds objectAtIndex:path.row];
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
        [_viewController dismissViewControllerAnimated:YES completion:^{
        }];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:aStrSocialShareTit style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [_viewController dismissViewControllerAnimated:YES completion:^{
        }];
        
//        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedTable];
//        NSIndexPath *path = [_feedTable indexPathForRowAtPoint:buttonPosition];
//        NSMutableDictionary *feedDetail = [_feeds objectAtIndex:path.row];
        
        NSString *aStrFeedName;
//        NSString *aStrPostUrl = @"";
        
        UIImage * aShareImg = [UIImage imageNamed:@"icon_skatting_logo"];
        
        if ([[feedDetail valueForKey:@"video_present"] boolValue]) {
            
            NSString * aStrVideoUrl = feedDetail[@"video"][0][@"video_thumb_image_url"];
            NSString * aStrAppendVideoUrl = [NSString stringWithFormat:@"%@%@",_mediaBaseUrl,aStrVideoUrl];
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
        [_viewController presentViewController:controller animated:YES completion:^{
            
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
        
        [_viewController dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    // Present action sheet.
    [_viewController presentViewController:actionSheet animated:YES completion:nil];
}

-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer{
    // Get selected Index
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:_feedTable];
    NSIndexPath *indexPath = [_feedTable indexPathForRowAtPoint:buttonPosition];
    
    if ([_feeds count] > indexPath.row) {
        
        if (![[[_feeds objectAtIndex:indexPath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
            NSString *ownerId = [[_feeds objectAtIndex:indexPath.row] valueForKey:@"post_owner_id"];
            
            if ( [[Util getFromDefaults:@"player_id"] isEqualToString:ownerId]) {
                if(_gBoolIsFromFeeds){
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                    MyProfile *myProfile = [storyBoard instantiateViewControllerWithIdentifier:@"MyProfile"];
                    [self.viewController.navigationController pushViewController:myProfile animated:YES];
                }
            }
            else{
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
                profile.friendId = [[_feeds objectAtIndex:indexPath.row] objectForKey:@"post_owner_id"];
                profile.friendName = [[_feeds objectAtIndex:indexPath.row] objectForKey:@"name"];
                [self.viewController.navigationController pushViewController:profile animated:YES];
            }
        }
    }
}

-(void)FriendProfileImageTapped:(UITapGestureRecognizer *)tapRecognizer{
    // Get selected Index
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:_feedTable];
    NSIndexPath *indexPath = [_feedTable indexPathForRowAtPoint:buttonPosition];
    
    if ([_feeds count] > indexPath.row) {
        
        if (![[[_feeds objectAtIndex:indexPath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
            
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
                profile.friendId = [_feeds objectAtIndex:indexPath.row] [@"share_details"][@"player_id"];
                profile.friendName = [_feeds objectAtIndex:indexPath.row] [@"share_details"][@"name"];
                [self.viewController.navigationController pushViewController:profile animated:YES];
        }
    }
}



// show Checkin
- (IBAction)CheckIn:(id)sender{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.feedTable];
    NSIndexPath *indexPath = [self.feedTable indexPathForRowAtPoint:buttonPosition];
    if ([_feeds count] > indexPath.row) {
        NSDictionary *checkinData = [[[_feeds objectAtIndex:indexPath.row] objectForKey:@"check_in_details"] objectAtIndex:0];
        
        ShowCheckinInMap *checkinMap = [storyBoard instantiateViewControllerWithIdentifier:@"ShowCheckinInMap"];
        checkinMap.checkinName = [checkinData valueForKey:@"name"];
        checkinMap.latitude = [checkinData valueForKey:@"latitude"];
        checkinMap.longitude = [checkinData valueForKey:@"longitude"];
        [self.viewController.navigationController pushViewController:checkinMap animated:YES];
    }
}

//Create or reuse the video
- (void)playInlineVideo:(FeedCell *)cell withSize:(CGSize)size andUrl:(NSString *)videoUrl {
    
//    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
    
    
    UIImage * aImgUnMute = [UIImage imageNamed:@"icon_unmute"];
    UIImage * aImgMute = [UIImage imageNamed:@"icon_mute"];
    
    if(self.isVolumeClicked) {
        
        if ([delegate.moviePlayer objectForKey:videoUrl] != nil) {
            AVPlayer * player;
            player = [delegate.moviePlayer objectForKey:videoUrl];
            if([Util getBoolFromDefaults:@"isVolumeMuted"]) {
                
                [player setMuted:YES];
                [cell.gBtnMuteUnMute setImage:aImgMute forState:UIControlStateNormal];
            }
            
            else {
                [cell.gBtnMuteUnMute setImage:aImgUnMute forState:UIControlStateNormal];
                [player setMuted:NO];
            }
        }
        
        
    }
    
    else {
        
        NSURL *url = [NSURL URLWithString:videoUrl];
        
        
        AVPlayer *player = nil;
        
        BOOL isSameVideo = [cell.videoUrl isEqualToString:videoUrl];
        if (isSameVideo) {
            NSLog(@"Same video to play");
        }
        
        cell.videoUrl = videoUrl;
        if ([delegate.moviePlayer objectForKey:videoUrl] != nil) {
            player = [delegate.moviePlayer objectForKey:videoUrl];
            NSLog(@"got existing player");
        }
        else {
            player = [AVPlayer playerWithURL:url];
            if(player != nil && player.currentItem != nil)
            {
                [delegate.moviePlayer setValue:player forKey:videoUrl];
                [delegate.videoUrls addObject:videoUrl];
                
                // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
                //[player addObserver:self forKeyPath:@"status" options:0 context:nil];
            }
        }
        
        //        [player setMuted:NO];
        
        //        dispatch_async( dispatch_get_main_queue(), ^{
        
        // Different video or has no video layer
        if (!isSameVideo || [cell.videoView.layer.sublayers count] == 0) {
            NSLog(@"Making an AVPlayerLayer %d %d", isSameVideo, (int)[cell.videoView.layer.sublayers count]);
            
            AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:player];
            
            
            
            [cell.mainPreview.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
            
            videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [cell.mainPreview.layer addSublayer:videoLayer];
        }
        
        if (player.rate == 0) {
            [cell.playIcon setHidden:NO];
        } else {
            [cell.activityIndicator setHidden:NO];
        }
        
        if([Util getBoolFromDefaults:@"isVolumeMuted"]) {
            
            [player setMuted:YES];
            [cell.gBtnMuteUnMute setImage:aImgMute forState:UIControlStateNormal];
        }
        
        else {
            [cell.gBtnMuteUnMute setImage:aImgUnMute forState:UIControlStateNormal];
            [player setMuted:NO];
        }
        
        [cell.videoView setHidden:NO];
    }
    
}

//Check and play the video if cell displayed in user view
- (void)playVideoConditionally{
    NSArray *visibleCells = [_feedTable visibleCells];
    
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

- (void)stopAllVideos{
    NSMutableDictionary *movieDictionary = [delegate.moviePlayer copy];
    for (NSString* key in movieDictionary) {
        AVPlayer *player = [movieDictionary objectForKey:key];
        //  dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        if(player != nil){
            [player pause];
            
//            if([Util getBoolFromDefaults:@"isVolumeMuted"]) {
//                [player setMuted:YES];
//            }
//            else {
//                [player setMuted:NO];
//            }
        }
        else {
            NSLog(@"Player Nil");
        }
        //  });
    }
}

- (void)muteAllVideos{
    NSMutableDictionary *movieDictionary = [delegate.moviePlayer copy];
    for (NSString* key in movieDictionary) {
        AVPlayer *player = [movieDictionary objectForKey:key];
        //  dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        if(player != nil){
            [player setMuted:YES];
        }
        //  });
    }
}


// Will be called when AVPlayer finishes playing playerItem
-(void)itemDidFinishPlaying:(NSNotification *) notification {
    NSLog(@"itemDidFinishPlaying");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//    });
    
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
    
    AVAsset *currentPlayerAsset = playerItem.asset;
    NSString *videoUrl = [(AVURLAsset *)currentPlayerAsset URL].absoluteString;
    
    AVPlayer *player = [delegate.moviePlayer objectForKey:videoUrl];
//    [player setMuted: YES];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        [player play];
    });
    
    if (delegate.currentVideoUrl != nil && [videoUrl isEqualToString:delegate.currentVideoUrl]) {
        [delegate.playerViewController dismissViewControllerAnimated:YES completion:nil];
        delegate.currentVideoUrl = nil;
    }
    else{
        [self increaseViewCount:videoUrl];
    }
    
}

-(FeedCell *)getCellFromUrl:(NSString *)url{
    NSArray *visibleCells = [_feedTable visibleCells];
    for(UITableViewCell *cell in visibleCells){
        FeedCell *feedCell = (FeedCell *) cell;
        if([feedCell isKindOfClass:[FeedCell class]] && feedCell.videoUrl != nil && [feedCell.videoUrl isEqualToString:url])
        {
            return feedCell;
        }
    }
    return nil;
}


//Detect the player has ready to play
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    AVPlayer *player = (AVPlayer *) object;
    AVAsset *currentPlayerAsset = [player currentItem].asset;
    NSString *videoUrl = [(AVURLAsset *)currentPlayerAsset URL].absoluteString;
    
    if ([keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
            [self increaseViewCount:videoUrl];
        }
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

-(void)StopVideoOnAppBackground:(UITableView *)tableView
{
    for(UITableViewCell *cell in [tableView visibleCells])
    {
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
                        [feedCell.playIcon setHidden:NO];
                        [feedCell.activityIndicator setHidden:NO];
                        
                        //Play current video
                        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
                            if ((player.rate != 0) && (player.error == nil)) {
                                [player pause];
                            }
                            else
                            {
                                [player pause];
                            }
                        });
                    }
                    
                }
            }
        }
    }

}

@end
