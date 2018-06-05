//
//  MyCheckinDetails.m
//  Varial
//
//  Created by vis-1041 on 3/22/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MyCheckinDetails.h"
#import "FeedsDesign.h"
#import "FeedCell.h"
#import "FeedsDesign.h"

@interface MyCheckinDetails ()
{
    FeedsDesign *feedsDesign;
    BOOL myBoolIsMutePressed;
}

@end

@implementation MyCheckinDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    feeds = [[NSMutableArray alloc] init];
    
    [self.feedsTable registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    [self.feedsTable registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
    [self.feedsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self designTheView];
    [self createPopUpWindows];
    
    [self getFeedsList];
    [self scrollViewDidScroll:_feedsTable];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [Util addEmptyMessageToTable:self.feedsTable withMessage:PLEASE_LOADING withColor:[UIColor whiteColor]];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView{
    
    feedsDesign = [[FeedsDesign alloc] init];
    
    if (_isFromChannel) {
        [_headerView setHeader:NSLocalizedString(CHANNEL, nil)];
    }
    else {
        [_headerView setHeader:NSLocalizedString(MY_CHECKIN_DETAILS, nil)];
    }
        
    

    _feedsTable.backgroundColor = [UIColor clearColor];
    _feedsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [Util setStatusBar];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    appDelegate.shouldAllowRotation = NO;
    
    //Check for update has made in the feed
    if (selectedPostIndex != -1) {
        [self updateTheFeedDetails];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [feedsDesign playVideoConditionally];
    });
    [super viewDidAppear:animated];
    
}
-(void)viewWillAppear:(BOOL)animated{
   
    
//    [_feedsTable reloadData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(PlayVideoOnAppForeground)
                                                name:UIApplicationWillEnterForegroundNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(PlayVideoOnAppForeground)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(StopVideoOnAppBackground)
                                                name:UIApplicationWillResignActiveNotification
                                              object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [feedsDesign muteAllVideos];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)PlayVideoOnAppForeground
{
    [feedsDesign checkWhichVideoToEnable:_feedsTable];
}

-(void)StopVideoOnAppBackground
{
    [feedsDesign StopVideoOnAppBackground:_feedsTable];
}

- (void)updateTheFeedDetails{
    if(!_isFromChannel) {
        [_feedsTable reloadData];
    }
    selectedPostIndex = -1;
}

- (void) createPopUpWindows
{
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(FEED, nil)];
    popupView.message.text = NSLocalizedString(DELETE_FOR_SURE, nil);
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    __weak MyCheckinDetails *feedRefreshSelf = self;
    
    // setup pull-to-refresh
    [self.feedsTable addPullToRefreshWithActionHandler:^{
        [feedRefreshSelf insertRowAtTop];
    }];
    feedRefreshSelf.feedsTable.pullToRefreshView.arrowColor = [UIColor whiteColor];
    feedRefreshSelf.feedsTable.pullToRefreshView.textColor = [UIColor whiteColor];
    [feedRefreshSelf.feedsTable.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    if (!_isFromChannel) {
    // setup infinite scrolling
    [self.feedsTable addInfiniteScrollingWithActionHandler:^{
        [feedRefreshSelf insertRowAtBottom];
    }];
    [feedRefreshSelf.feedsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    //Alert popup
    blockConfirmation = [[YesNoPopup alloc] init];
    blockConfirmation.delegate = self;
    [blockConfirmation setPopupHeader:NSLocalizedString(BLOCK_PERSON, nil)];
    blockConfirmation.message.text = NSLocalizedString(SURE_TO_BLOCK, nil);
    [blockConfirmation.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [blockConfirmation.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    blockPopUp = [KLCPopup popupWithContentView:blockConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}


- (void)insertRowAtTop {
    
    __weak MyCheckinDetails *feedRefreshSelf = self ;
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // While pull to refresh remove all object and reload the api
        [feeds removeAllObjects];
        [self getFeedsList];
        [feedRefreshSelf.feedsTable.pullToRefreshView stopAnimating];
    });
}

- (void)insertRowAtBottom {
    
    __weak MyCheckinDetails *feedRefreshSelf = self ;
    int64_t delayInSeconds = 0.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // while load more at bottom add the response array at bottom
        [self getFeedsList];
        [feedRefreshSelf.feedsTable.infiniteScrollingView stopAnimating];
    });
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [feeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.feedsTable) {
        
        NSNumber *key = @(indexPath.row);
        NSNumber *height = [cellHeightsDictionary objectForKey:key];
        
        if (height)
        {
            return height.doubleValue;
        }
        return UITableViewAutomaticDimension;
    }
    else {
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.feedsTable) {
        
        NSNumber *key = @(indexPath.row);
        NSNumber *height = @(cell.frame.size.height);
        
        [cellHeightsDictionary setObject:height forKey:key];
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.feedsTable) {
        
        NSNumber *key = @(indexPath.row);
        NSNumber *height = [cellHeightsDictionary objectForKey:key];
        
        if (height)
        {
            return height.doubleValue;
        }
        return UITableViewAutomaticDimension;
    }
    else {
        return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = nil;
    FeedCell *fcell;

    if([feeds count] > 0){
        
        cellIdentifier= ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feeds objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"FeedCell" : @"MessagesCell";
        fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (fcell == nil)
        {
            fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        // Mute Button Actions
        [fcell.gBtnMuteUnMute addTarget:self action:@selector(muteUnmutePressed:) forControlEvents:UIControlEventTouchUpInside];
        fcell.gBtnMuteUnMute.tag = indexPath.row;
        
         feedsDesign.feeds = feeds;
        feedsDesign.feedTable = _feedsTable;
         feedsDesign.mediaBaseUrl= mediaBaseUrl;
         feedsDesign.viewController = self;
         feedsDesign.isVolumeClicked = NO;
        feedsDesign.gIsFromChannel = YES;
        
        
         [feedsDesign designTheContainerView:fcell forFeedData:[feeds objectAtIndex:indexPath.row] mediaBase:mediaBaseUrl forDelegate:self tableView:tableView];
        
    
        
        // Hide Share View
        [fcell.shareView setHidden:YES];
        fcell.shareViewHeightConstraint.constant = 0.0;
        if (_isFromChannel) {
            fcell.myConstraintShareViewTop.constant = -70.0;
        }
        
        fcell.backgroundColor = [UIColor clearColor];
    }
    return fcell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
//    [feedsDesign stopTheVideo:cell];
//    
//    NSArray *visibleCells = [_feedsTable visibleCells];
//    for(UITableViewCell *visibleCell in visibleCells){
//        if(visibleCell == cell)
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [feedsDesign playVideoConditionally];
//            });
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[feedsDesign playVideoConditionally];
    [feedsDesign checkWhichVideoToEnable:_feedsTable];
}

#pragma mark - Attributed Label delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSString *tag = [[label.text substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
    [searchViewController searchFor:tag];
    [self.navigationController pushViewController:searchViewController animated:YES];
}
//Common Delegate for TTTAttributed Label
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    CGPoint position = [label convertPoint:CGPointZero toView:self.feedsTable];
    NSIndexPath *indexPath = [self.feedsTable indexPathForRowAtPoint:position];
    NSMutableDictionary *feed = [feeds objectAtIndex:indexPath.row];
    if ([[feed objectForKey:@"is_local"] isEqualToString:@"false"]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[feed valueForKey:@"post_id"] forKey:@"post_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [feed setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                [feed setValue:[NSNumber numberWithBool:FALSE] forKey:@"continue_reading_flag"];
                [_feedsTable reloadData];
            }else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        } isShowLoader:NO];
    }
    else{
        //Open Url
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    UIMenuController *menucontroller=[UIMenuController sharedMenuController];
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.feedsTable];
    NSIndexPath *indexPath = [self.feedsTable indexPathForRowAtPoint:buttonPosition];
    NSDictionary *feed = [feeds objectAtIndex:indexPath.row];
    
    if ([[feed valueForKey:@"is_local"] boolValue]) {
        UIMenuItem *Menuitem=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(CANCEL_UPLOAD, nil) action:@selector(DeletePost:)];
        [menucontroller setMenuItems:[NSArray arrayWithObjects:Menuitem,nil]];
    }
    else{
        UIMenuItem *Menuitem=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(DELETE_MENU, nil) action:@selector(DeletePost:)];
        [menucontroller setMenuItems:[NSArray arrayWithObjects:Menuitem,nil]];
    }
    
    
    menuPosition = indexPath;
    //It's mandatory
    [self becomeFirstResponder];
    //It's also mandatory ...remeber we've added a mehod on view class
    if([self canBecomeFirstResponder])
    {
        [menucontroller setTargetRect:CGRectMake(10,10, 0, 200) inView:tapRecognizer.view];
        [menucontroller setMenuVisible:YES animated:YES];
    }
}

- (void) copy:(id) sender {
    // called when copy clicked in menu
}
- (void) menuItemClicked:(id) sender {
    // called when Item clicked in menu
}
- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(DeletePost:) /*|| selector == @selector(copy:)*/ /**<enable that if you want the copy item */) {
        return YES;
    }
    return NO;
}
- (BOOL) canBecomeFirstResponder {
    return YES;
}

// ------------- Delete post Start ---------------

- (void)DeletePost:(UIMenuController *)sender
{
    if([[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_local"]  isEqualToString:@"true"])
    {
        popupView.message.text = NSLocalizedString(CANCEL_FOR_SURE, nil);
        isDelete = FALSE;
    }
    else{
        popupView.message.text = NSLocalizedString(DELETE_FOR_SURE, nil);
        isDelete = TRUE;
    }
    [yesNoPopup show];
}

-(void)deleteFeedPost
{
    [yesNoPopup dismiss:YES];
    
    if (isDelete) {
        NSString *strPostId = [NSString stringWithFormat:@"%@",[[feeds objectAtIndex:menuPosition.row] objectForKey:@"post_id"]];
        
        [_feedsTable beginUpdates];
        [feeds removeObjectAtIndex:menuPosition.row];
        [_feedsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
        [_feedsTable endUpdates];
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:strPostId  forKey:@"post_id"];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DELETE_POST withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                [self addEmptyMessageForFeedListTable];
            }
            else
            {
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
            
        } isShowLoader:NO];
    }
    else{
        
        // Cancel Local Feeds
        if([[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_local"]  isEqualToString:@"true"])
        {
            [_feedsTable beginUpdates];
            NSURLSessionTask *task = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"task"];
            [task cancel];
            [feeds removeObjectAtIndex:menuPosition.row];
            [_feedsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
            [_feedsTable endUpdates];
        }
        else{
            //[[AlertMessage sharedInstance] showMessage:NSLocalizedString(@"The post is uploaded you can't cancel now", nil)];
        }
    }
}


#pragma mark YesNoPopDelegate
- (void)onYesClick{
    if(!_isPopularCheckinDetail){
        [self deleteFeedPost];
    }
    else{
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[reportFeed objectForKey:@"post_owner_id"] forKey:@"friend_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BLOCKFRIEND withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [blockPopUp dismiss:YES];
                [self getFeedsList];
                [_feedsTable reloadData];
                [[AlertMessage sharedInstance]showMessage:[response valueForKey:@"message"] withDuration:3];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
            }
        } isShowLoader:YES];
    }
}

- (void)onNoClick{
    [yesNoPopup dismiss:YES];
    [blockPopUp dismiss:YES];
}

// ------------- Delete post End  ----------------

// Click Star & Unstar
- (IBAction)Star:(id)sender
{
    [feedsDesign addStar:self.feedsTable fromArray:feeds forControl:sender];
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender
{
    [feedsDesign addBookmark:self.feedsTable fromArray:feeds forControl:sender];
}

// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedsTable];
        NSIndexPath *path = [_feedsTable indexPathForRowAtPoint:buttonPosition];
        NSString *star_post_id = [[feeds objectAtIndex:path.row] objectForKey:@"post_id"];
        selectedPostIndex = (int) path.row;
        Comments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
        NSDictionary *imageInfo = [feeds objectAtIndex:path.row];
        comment.postId = star_post_id;
        comment.mediaId = [imageInfo valueForKey:@"image_id"];
        comment.postDetails = [feeds objectAtIndex:path.row];
        [self.navigationController pushViewController:comment animated:YES];
    }
    else
    {
        [appDelegate.networkPopup show];
    }
}

// Get Feeds List
-(void)getFeedsList
{
    NSString *strPostId, *URL;
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    if(_isFromChannel) {
        URL = POST_DETAILS;
        strPostId = _post_Id;
    }
    else {
        
        strPostId = @"0";
        [inputParams setValue:@"0"  forKey:@"recent"];
        [inputParams setValue:_checkinId  forKey:@"checkin_id"];
        if ([_isPopularCheckinDetail isEqualToString:@"YES"]) {
            URL = CHECKIN_POST_DETAIL;
        }
        else
        {
            URL = CHECKIN_POST_LIST;
        }
        
        if ([feeds count] != 0) {
            NSMutableDictionary *lastIndex = [feeds lastObject];
            strPostId = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"post_id"]];
        }
    }
    
    
    
    [inputParams setValue:strPostId forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [_feedsTable.infiniteScrollingView startAnimating];
    
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:URL withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [_feedsTable.infiniteScrollingView stopAnimating];
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
            [self alterTheMediaList:response];
            //show empty message
            [self addEmptyMessageForFeedListTable];
        }
        else
        {
            [_feedsTable.infiniteScrollingView stopAnimating];
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:YES];
}


//Append the media url with base
- (void)alterTheMediaList:(NSDictionary *)response{
    
    NSMutableDictionary * dict;
    if(_isFromChannel) {
        
        dict = [[response objectForKey:@"post_detail"] mutableCopy];
        int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[dict valueForKey:@"post_id"] from:feeds type:1];
        
        if (postIndex == -1) {
            [dict setValue:@"false" forKey:@"is_local"];
            [dict setValue:@"false" forKey:@"is_upload"];
            [dict setValue:@"" forKey:@"task_identifier"];
            [dict setValue:@"" forKey:@"task"];
            [dict setValue:@"true" forKey:@"isEnabled"];
            
            NSMutableDictionary *profileImage = [[dict objectForKey:@"posters_profile_image"] mutableCopy];
            [profileImage setValue: [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[profileImage  valueForKey:@"profile_image"]] forKey:@"profile_image"];
            [dict setObject:profileImage forKey:@"posters_profile_image"];
            
            NSMutableArray *mediaList = [[dict valueForKey:@"image_present"] boolValue] ? [[dict objectForKey:@"image"] mutableCopy] : [[dict objectForKey:@"video"] mutableCopy];
            for (int i=0; i<[mediaList count]; i++) {
                NSMutableDictionary *media = [[mediaList objectAtIndex:i] mutableCopy];
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[media valueForKey:@"media_url"]];
                [media setValue:imageUrl forKey:@"media_url"];
                [media setValue:@"true" forKey:@"isEnabled"];
                [mediaList replaceObjectAtIndex:i withObject:media];
            }
            
            if ([[dict valueForKey:@"image_present"] boolValue]) {
                [dict setObject:mediaList forKey:@"image"];
            }
            else{
                [dict setObject:mediaList forKey:@"video"];
            }
            
            // Add response array to the selected feed type
            [feeds addObject:dict];
        }
    }
    
    else {
        
        for (int i=0; i< [[response objectForKey:@"feed_list"] count]; i++) {
            dict = [[[response objectForKey:@"feed_list"] objectAtIndex:i] mutableCopy];
            int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[dict valueForKey:@"post_id"] from:feeds type:1];
            
            if (postIndex == -1) {
                [dict setValue:@"false" forKey:@"is_local"];
                [dict setValue:@"false" forKey:@"is_upload"];
                [dict setValue:@"" forKey:@"task_identifier"];
                [dict setValue:@"" forKey:@"task"];
                [dict setValue:@"true" forKey:@"isEnabled"];
                
                NSMutableDictionary *profileImage = [[dict objectForKey:@"posters_profile_image"] mutableCopy];
                [profileImage setValue: [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[profileImage  valueForKey:@"profile_image"]] forKey:@"profile_image"];
                [dict setObject:profileImage forKey:@"posters_profile_image"];
                
                NSMutableArray *mediaList = [[dict valueForKey:@"image_present"] boolValue] ? [[dict objectForKey:@"image"] mutableCopy] : [[dict objectForKey:@"video"] mutableCopy];
                for (int i=0; i<[mediaList count]; i++) {
                    NSMutableDictionary *media = [[mediaList objectAtIndex:i] mutableCopy];
                    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[media valueForKey:@"media_url"]];
                    [media setValue:imageUrl forKey:@"media_url"];
                    [media setValue:@"true" forKey:@"isEnabled"];
                    [mediaList replaceObjectAtIndex:i withObject:media];
                }
                
                if ([[dict valueForKey:@"image_present"] boolValue]) {
                    [dict setObject:mediaList forKey:@"image"];
                }
                else{
                    [dict setObject:mediaList forKey:@"video"];
                }
                
                // Add response array to the selected feed type
                [feeds addObject:dict];
            }
        }
    }
    
    
    [_feedsTable reloadData];
    
}

- (void)addEmptyMessageForFeedListTable{
    
    if ([feeds count] == 0) {
        [Util addEmptyMessageToTable:self.feedsTable withMessage:DONT_HAVE_FEED withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:self.feedsTable withMessage:@"" withColor:[UIColor blackColor]];
    }
    
}

-(void)reportButtonAction:(UITapGestureRecognizer *)tapRecognizer{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.feedsTable];
        NSIndexPath *indexPath = [self.feedsTable indexPathForRowAtPoint:buttonPosition];
        reportFeed = [feeds objectAtIndex:indexPath.row];
        
        [self.reportPopover dismissMenuPopover];
        
        self.reportPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 65 - _feedsTable.contentOffset.y, 140, 84) menuItems:@[NSLocalizedString(REPORT_THE_POST,nil),NSLocalizedString(BLOCK_THE_USER, nil)]];
        self.reportPopover.menuPopoverDelegate = self;
        self.reportPopover.tag = 101;
        [self.reportPopover showInView:self.view];
    }
}

// Delegate method for MLKMenuPopover
- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    [self.reportPopover dismissMenuPopover];
    if([[Util sharedInstance] getNetWorkStatus])
    {
       // int clickedIndex = selectedIndex;
        if(selectedIndex == 0){
            [self reportPost];
        }
        else{
            [blockPopUp show];
        }
    }
    else{
        [appDelegate.networkPopup show];
    }
}
-(void)reportPost{
    NSMutableArray *menuArray = [[NSMutableArray alloc] init];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"report_Type"] != nil)
    {
        reportType = [[NSUserDefaults standardUserDefaults] objectForKey:@"report_Type"];
        if([reportType count] > 0){
            for(NSDictionary *dictionary in reportType){
                [menuArray addObject:[dictionary objectForKey:@"type"]];
            }
            if([menuArray count] != 0){
                menu = [[Menu alloc]initWithViews:NSLocalizedString(REPORT_POST, nil) buttonTitle:menuArray withImage:nil];
                menu.delegate = self;
                menuPopup = [KLCPopup popupWithContentView:menu showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
                [menuPopup show];
            }
        }
    }
}
-(void)menuActionForIndex:(int)tag{
    [menuPopup dismiss:YES];
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[reportFeed objectForKey:@"post_id"] forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
    [inputParams setValue:[[reportType objectAtIndex:tag-1] objectForKey:@"id"] forKey:@"report_type_id"];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEND_REPORT withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            int row = (int)[feeds indexOfObject:reportFeed];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [_feedsTable beginUpdates];
            [feeds removeObject:reportFeed];
            [_feedsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [_feedsTable endUpdates];
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
    } isShowLoader:YES];
}

-(void)muteUnmutePressed:(UIButton*)sender {
    
    UIButton *btn = sender;
    //    btn.selected = !btn.selected;
    NSDictionary* userInfo;
    UIImage * aImgMute = [UIImage imageNamed:@"icon_mute"];
    UIImage * aImgUnMute = [UIImage imageNamed:@"icon_unmute"];
    
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    FeedCell *cell = (FeedCell*)[_feedsTable cellForRowAtIndexPath:myIP];
    
    if (myBoolIsMutePressed) {
        myBoolIsMutePressed = false;
        userInfo = @{@"IsMuted": @"false"};
        [btn setImage:aImgUnMute forState:UIControlStateNormal];
        
    }
    
    else {
        myBoolIsMutePressed = true;
        userInfo = @{@"IsMuted": @"true"};
        [btn setImage:aImgMute forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MuteUnMuteNotification"
     object:self userInfo:userInfo];
    
    if ([feeds count] > sender.tag) {
        
        feedsDesign.feeds = feeds;
        feedsDesign.feedTable = _feedsTable;
        feedsDesign.mediaBaseUrl= mediaBaseUrl;
        feedsDesign.viewController = self;
        feedsDesign.isVolumeClicked = YES;
        [feedsDesign designTheContainerView:cell forFeedData:[feeds objectAtIndex:sender.tag] mediaBase:mediaBaseUrl forDelegate:self tableView:_feedsTable];
    }
}

@end
