//
//  PostBuzzardRun.m
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

// 1. IF Can post is true can able to add post -> (If feed count is 0 should show + button else show menu button)
// 2. Submit For Approval : a. if submit for approval is true can able to submit the event
// 3. Buzzard Run Expiry : a. can see feeds list   b. can not able to delete post   c. can not able to add new post   d. can able to do like or comment   e. not able to do submit
// 4. Buzzard Run Delete or Invalid : a. No need to show the list

#import "PostBuzzardRun.h"
#import "Util.h"
#import "Config.h"
#import "BuzzardRunComments.h"
#import "FeedsDesign.h"
#import "FeedCell.h"
#import "FriendCell.h"
#import "FeedsDesign.h"

@interface PostBuzzardRun ()
{
    FeedsDesign *feedsDesign;
}

@end

@implementation PostBuzzardRun
@synthesize feeds;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    feeds = [[NSMutableArray alloc] init];
    _uploadCancelArray = [[NSMutableArray alloc] init];
    feedsDesign = [[FeedsDesign alloc] init];

    [self.postTable registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    [self.postTable registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
    [self.postTable registerNib:[UINib nibWithNibName:@"TeamFeedCell" bundle:nil] forCellReuseIdentifier:@"TeamFeedCell"];
    [self.postTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self designTheView];
    [self createPopUpWindows];
    [self getFeedsList];
    [Util addEmptyMessageToTable:self.postTable withMessage:PLEASE_LOADING withColor:[UIColor whiteColor]];
    
    //Register for the notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBuzzardRunStatus:) name:@"GeneralNotification" object:nil];
    
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self scrollViewDidScroll:_postTable];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    delegate.shouldAllowRotation = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askBackConfirmPostPage:) name:@"BackPressed" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackPressed" object:nil];
    [feedsDesign stopAllVideos];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Change Buzzard run status
-(void) changeBuzzardRunStatus:(NSNotification *) data{
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    NSDictionary *body = [notificationContent objectForKey:@"data"];
    if ([[notificationContent objectForKey:@"type"] isEqualToString:@"general_notification"]) {
        int value = [[body valueForKey:@"redirection_type"] intValue];
        if ( value == 8 || value == 9 || value == 7) {
            [self getFeedsList];
        }
    }
}


- (void)designTheView
{
    
    [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(EVENT_POST_TITLE, nil),_eventName]];

    [_headerView.logo setHidden:YES];
//    _headerView.restrictBack = TRUE;
    
    [Util createBorder:_tabView withColor:UIColorFromHexCode(THEME_COLOR)];
    [Util createBorder:_submitforApprovalView withColor:UIColorFromHexCode(THEME_COLOR) setBorderSize:0.3f];
    
    self.postTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _postTable.backgroundColor = [UIColor clearColor];
    
   // selectedTab = 1;
    [self changeTabColor:selectedTab];
    
    [_addPostView setHidden:YES];
    _menuButton.layer.cornerRadius = _menuButton.frame.size.height / 2 ;
    _menuButton.clipsToBounds = true;
    [_menuButton setHidden:YES];
    
    _details.editable = FALSE;
    
    _postTable.hidden = NO;
    _details.hidden = YES;
    _detailsView.hidden = YES;
    
    if ([_canShowPost isEqualToString:@"YES"]) {
        [self showPostDetails];
    }
    else{
        [self showDetailsView];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Check for update has made in the feed
    if (selectedPostIndex != -1) {
        [self updateTheFeedDetails];
    }
    [self postFeeds];
    [_postTable reloadData];
    //[self addEmptyMessageForFeedListTable];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [feedsDesign playVideoConditionally];
    });
}

- (void)updateTheFeedDetails{
    [_postTable reloadData];
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
    
    __weak PostBuzzardRun *feedRefreshSelf = self;
    
    // setup pull-to-refresh
    [self.postTable addPullToRefreshWithActionHandler:^{
        [feedRefreshSelf insertRowAtTop];
    }];
    feedRefreshSelf.postTable.pullToRefreshView.arrowColor = [UIColor whiteColor];
    feedRefreshSelf.postTable.pullToRefreshView.textColor = [UIColor whiteColor];
    [feedRefreshSelf.postTable.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    
    // setup infinite scrolling
    [self.postTable addInfiniteScrollingWithActionHandler:^{
        [feedRefreshSelf insertRowAtBottom];
    }];
    [feedRefreshSelf.postTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
}

- (void)insertRowAtTop {
    __weak PostBuzzardRun *feedRefreshSelf = self ;
    int64_t delayInSeconds = 1.0;
    
    if (selectedTab == 1)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // While pull to refresh remove all object and reload the api
            // If page Pull to to refresh -> remove all records and reload the records
            for (int i =0; i<[feeds count]; i++) {
                if ([[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"false"]) {
                    [feeds removeObjectAtIndex:i];
                    i--;
                }
            }
            [self getFeedsList];
            [feedRefreshSelf.postTable.pullToRefreshView stopAnimating];
        });
    }
    else{
        [feedRefreshSelf.postTable.infiniteScrollingView stopAnimating];
    }
    
}

- (void)insertRowAtBottom {
    
    __weak PostBuzzardRun *feedRefreshSelf = self ;
    int64_t delayInSeconds = 0.0;
    
    if (selectedTab == 1)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // while load more at bottom add the response array at bottom
            [self getFeedsList];
            [feedRefreshSelf.postTable.infiniteScrollingView stopAnimating];
        });
    }
    else{
        [feedRefreshSelf.postTable.infiniteScrollingView stopAnimating];
    }
}

//Get latest feeds
- (void)getNewFeeds{
    
    if ([feeds count] != 0) {
       
        for (int i=0; i<[feeds count]; i++) {
            if ([[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"false"]) {
                NSString *strTimeStamp = [NSString stringWithFormat:@"%@",[[feeds objectAtIndex:i] objectForKey:@"time_stamp"]];
                [self loadMoreTopRow:strTimeStamp];
                break;
            }
        }
        
        if ([feeds count] == 1 && [[feeds[0] valueForKey:@"is_local"] isEqualToString:@"true"]) {
            [self getFeedsList];
        }
        
    }
    else
    {
        [self getFeedsList];
    }    
}

-(void)loadMoreTopRow:(NSString *)timeStamp
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_buzzardRunId forKey:@"buzzard_run_id"];
    [inputParams setValue:_buzzardRunEventId forKey:@"buzzard_run_event_id"];
    [inputParams setValue:@"1"  forKey:@"recent"];
    [inputParams setValue:timeStamp forKey:@"time_stamp"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BUZZARD_RUN_POST_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
            
            [self removeUploadedLocalFeeds:response];
            
            NSMutableArray *topResult = [response objectForKey:@"event_post_list"];
            
            for (int i = 0; i < [topResult count]; i++) {
                
                int index = ([topResult count]-1) - i;
                
                // Get index Data
                NSMutableDictionary *newFeeds = [[topResult objectAtIndex:index] mutableCopy];
                
                [newFeeds setValue:@"false" forKey:@"is_local"];
                [newFeeds setValue:@"false" forKey:@"is_upload"];
                [newFeeds setValue:@"" forKey:@"task_identifier"];
                [newFeeds setValue:@"" forKey:@"task"];
                [newFeeds setValue:@"true" forKey:@"isEnabled"];
                
                int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[newFeeds valueForKey:@"post_id"] from:feeds type:1];
                
                if (![[newFeeds objectForKey:@"is_buzzard_run_activity"] boolValue] && postIndex == -1) {
                    
                    if (![[newFeeds objectForKey:@"is_buzzard_run_activity"] boolValue]) {
                        
                        NSMutableDictionary *profileImage = [[newFeeds objectForKey:@"posters_profile_image"] mutableCopy];
                        [profileImage setValue: [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[profileImage  valueForKey:@"profile_image"]] forKey:@"profile_image"];
                        [newFeeds setObject:profileImage forKey:@"posters_profile_image"];
                        
                        NSMutableArray *mediaList = [[newFeeds valueForKey:@"image_present"] boolValue] ? [[newFeeds objectForKey:@"image"] mutableCopy] : [[newFeeds objectForKey:@"video"] mutableCopy];
                        for (int i=0; i<[mediaList count]; i++) {
                            NSMutableDictionary *media = [[mediaList objectAtIndex:i] mutableCopy];
                            NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[media valueForKey:@"media_url"]];
                            [media setValue:imageUrl forKey:@"media_url"];
                            [media setValue:@"true" forKey:@"isEnabled"];
                            [mediaList replaceObjectAtIndex:i withObject:media];
                        }
                        
                        if ( [[newFeeds valueForKey:@"image_present"] boolValue]) {
                            [newFeeds setObject:mediaList forKey:@"image"];
                        }
                        else{
                            [newFeeds setObject:mediaList forKey:@"video"];
                        }
                    }
                    // while pull to referesh add records at top
                    [feeds insertObject:newFeeds atIndex:0];
                    [self showAndHidePostButton];
                }
                else if ([[newFeeds objectForKey:@"is_buzzard_run_activity"] boolValue]){
                    // while pull to referesh add records at top
                    [feeds insertObject:newFeeds atIndex:0];
                }
            }
            [_postTable reloadData];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:NO];
}


-(IBAction)postButton:(id)sender
{
    [feedsDesign playVideoConditionally];
    [self showPostDetails];
}

- (void)showPostDetails{
   
    selectedTab = 1;
    [self changeTabColor:selectedTab];
    _postTable.hidden = NO;
    _detailsView.hidden = YES;
    
    if (expiry) {
        [_menuButton setHidden:YES];
    }
    else if (canPost) {
        [_menuButton setHidden:NO];
    }
    else
    {
        [_menuButton setHidden:YES];
    }
}

-(IBAction)detailsButton:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [feedsDesign stopAllVideos];
    });
    [self showDetailsView];
}

- (void)showDetailsView{
    selectedTab = 2;
    [_menuButton setHidden:YES];
    [self changeTabColor:selectedTab];
    _postTable.hidden = YES;
    _detailsView.hidden = NO;
}


//Check posting is going on
-(void)askBackConfirmPostPage:(NSNotification *) data{
    
    if ([[[Util sharedInstance].httpMultiFileTaskManager uploadTasks] count] > 0) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(BUZZARD_STILL_POSTING, nil)];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)changeTabColor:(int)tab
{
    if (tab == 1) {
        _postTab.backgroundColor = UIColorFromHexCode(THEME_COLOR);
        _detailsTab.backgroundColor = [UIColor clearColor];
    }
    else{
        _detailsTab.backgroundColor = UIColorFromHexCode(THEME_COLOR) ;
        _postTab.backgroundColor = [UIColor clearColor];
    }
    
    [_postTable reloadData];
}

-(IBAction)tappedMenuButton:(id)sender
{
    if ([feeds count] == 0) {
        [self AddNewPost];
    }
    else
    {
        [_addPostView setHidden:NO];
    }
}

-(IBAction)addPost:(id)sender
{
    [_addPostView setHidden:YES];
    [self AddNewPost];
}

// Navigate to CreatePostviewController for add Buzzard Run Post
-(void)AddNewPost
{
    CreatePostViewController *post = [self.storyboard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
    post.postFromBuzzardRun = @"yes";
    post.buzzardRunEventId = _buzzardRunEventId;
    post.buzzardRunId = _buzzardRunId;
    post.buzzardRunName = _buzzardRunName;
    [self.navigationController pushViewController:post animated:YES];
}

-(IBAction)submitForApproval:(id)sender
{
    if ([[[Util sharedInstance].httpMultiFileTaskManager uploadTasks] count] > 0) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(BUZZARD_STILL_POSTING, nil)];
    }
    else{
        
        [_addPostView setHidden:YES];        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_buzzardRunId forKey:@"buzzardrun_id"];
        [inputParams setValue:_buzzardRunEventId forKey:@"event_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SUBMIT_FOR_APPROVAL withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                canPost = TRUE;
                [_submitforApprovalView hideByHeight:YES];
                [self showAndHidePostButton];
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
            else
            {
                expiry = [[response objectForKey:@"expiry"] boolValue];
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                [_menuButton setHidden:YES];
                
                // 1.If Buzzard run expired should show feeds  2. If buzzard run delete or disable the buzzard run should hide the tableview
                if (expiry) {
                    [_postTable setHidden:NO];
                }
                else
                {
                    [_postTable setHidden:YES];
                }
                
            }
        } isShowLoader:NO];

    }
}

-(IBAction)cancelView:(id)sender
{
    [_addPostView setHidden:YES];
}

-(void)showAndHidePostButton
{
    if (selectedTab == 1) {
        
        if (expiry) {
            [_menuButton setHidden:YES];
        }
        else if (canPost && [feeds count] == 0) {
            [_menuButton setImage:[UIImage imageNamed:@"invite.png"] forState:UIControlStateNormal];
            [_menuButton setHidden:NO];
        }
        else if (canPost && [feeds count] > 0)
        {
            [_menuButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
            [_menuButton setHidden:NO];
            
            if (canSubmit) {
                // show submitforapproval Button
            }
            else{
                //[_submitforApprovalView setHidden:YES];
                [_submitforApprovalView hideByHeight:YES];
                
            }
        }
        else
        {
            [_menuButton setHidden:YES];
        }
    }
    else{
        [_menuButton setHidden:YES];
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [feeds count];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = nil;

    FeedCell *fcell;
    fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:@"TeamFeedCell"];
    [fcell setHidden:YES];
    if ([feeds count] > indexPath.row){
        if([[[feeds objectAtIndex:indexPath.row] valueForKey:@"is_buzzard_run_activity"] boolValue]) {
            cellIdentifier = @"TeamFeedCell";
            fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:@"TeamFeedCell"];
            if (fcell == nil)
            {
                fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FeedCell"];
            }
            fcell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            fcell.name.delegate = self;
            NSDictionary *Values = [[feeds objectAtIndex:indexPath.row] objectForKey:@"activity"] ;
            [Util createTeamActivityLabel:fcell.name fromValues:Values];
            fcell.date.text = [Util timeStamp:[[[feeds objectAtIndex:indexPath.row] objectForKey:@"time_stamp"] longValue]];
            fcell.backgroundColor = [UIColor clearColor];
            [fcell setHidden:NO];
            return fcell;
        }
        else
        {
            if([feeds count] > indexPath.row && [feeds count] > 0){
                
                cellIdentifier= ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feeds objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"FeedCell" : @"MessagesCell";
                fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if(fcell == nil){
                    fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                
                //Build the feed data
                [self buildFeedData:fcell forFeedData:[feeds objectAtIndex:indexPath.row]];
                
                fcell.backgroundColor = [UIColor clearColor];
                [fcell setHidden:NO];
                return fcell;
            }
        }
    }
    return fcell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (selectedTab == 1) {
        
    }
    else
    {
        
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    
   // [feedsDesign stopTheVideo:cell];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    [feedsDesign stopAllVideos];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [feedsDesign playVideoConditionally];
//    });
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [feedsDesign checkWhichVideoToEnable:_postTable];
}

// ---------------------------- START FEEDS LIST ------------------------------------

- (void) buildFeedData:(FeedCell *) cell forFeedData:(NSMutableDictionary *) currentFeed{
    
    [self buildFeedCommonData:cell forFeedData:currentFeed];
    
    [cell.playIcon setHidden:YES];
    [cell.reportButton setHidden:YES];
    
    DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScale tintColor:[UIColor whiteColor] size:15.0f];
    activityIndicatorView.frame = cell.activityIndicator.bounds;
    [activityIndicatorView startAnimating];
    [cell.activityIndicator setHidden:YES];
    [[cell.activityIndicator subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.activityIndicator addSubview:activityIndicatorView];
    cell.isVideo = FALSE;
    
    //check for the media content, if true call the update media Content method
    if([[currentFeed objectForKey:@"image"] count] > 0 || [[currentFeed objectForKey:@"video"] count] > 0){
        cell.message.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        [cell.message setText:[currentFeed objectForKey:@"post_content"]];
        
        if ([[currentFeed objectForKey:@"continue_reading_flag"] intValue] == 1) {
            if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
                [Util setAddMoreTextForLabel:cell.message endsWithString:ENDS_WITH_STRING forlength:256 forColor:UIColorFromHexCode(THEME_COLOR)];
            }
            else
            {
                [Util setAddMoreTextForLabel:cell.message endsWithString:ENDS_WITH_STRING forlength:[cell.message.text length] forColor:UIColorFromHexCode(THEME_COLOR)];
            }
        }
        cell.message.delegate = self;
        
        if([currentFeed objectForKey:@"image"] != nil && [[currentFeed objectForKey:@"image"] count] > 0){
            
            
            //hide the view count label for image post
            cell.videoViewCountHeight.constant = 0;

            
            NSMutableArray *medias = [currentFeed objectForKey:@"image"];
            
            //iterate the medias
            for(int loop = 0; loop < [medias count]; loop++){
                
                NSDictionary *mediaData = [medias objectAtIndex:loop];
                CGSize imageSize = [Util getAspectRatio:[mediaData valueForKey:@"media_dimension"] ofParentWidth:self.view.frame.size.width - 20];
                UIImageView *currentImage = (loop == 1)? cell.subPreview : cell.mainPreview;
                                
                if (loop == 0 ){
                    cell.subPreview.hidden = YES;
                    CGRect frame = currentImage.frame;
                    currentImage.frame = CGRectMake(frame.origin.x, frame.origin.y, imageSize.width, imageSize.height);
                    cell.mediaHeight.constant = imageSize.height;
                    currentImage.clipsToBounds = YES;
                }
                else{
                    cell.subPreview.hidden = NO;
                    cell.subPreview.clipsToBounds = YES;
                    cell.subPreview.contentMode = UIViewContentModeScaleAspectFill;
                }
                
                // Show image from local
                if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
                    NSMutableArray *getlocal = [currentFeed objectForKey:@"is_media"];
                    currentImage.image =  [Util imageWithImage:[[getlocal objectAtIndex:loop] objectForKey:@"mediaThumb"] scaledToWidth:self.view.frame.size.width];
                }
                else // show image from server
                {
                   
                    if (loop == 0) {
                        [currentImage.layer setValue:[mediaData valueForKey:@"media_dimension"] forKey:@"dimension"];
                    }
                   
                    [feedsDesign showDownloadProgress:cell imageView:currentImage mediaUrl:[mediaData valueForKey:@"media_url"] imageSize:imageSize onProgressView:[Util designdownloadProgress:cell.downloadProgress]];
                    
                }
                
                cell.imageCount.hidden = YES;
                if(loop == 1 )
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
        }
        else if([currentFeed objectForKey:@"video"] != nil && [[currentFeed objectForKey:@"video"] count] > 0){
            cell.isVideo = TRUE;
            NSMutableArray *medias = [currentFeed objectForKey:@"video"];
            //iterate the medias
            for(int loop = 0; loop < [medias count]; loop++){
                
                cell.subPreview.hidden = YES;
                cell.imageCount.hidden = YES;
                
                UIImageView *currentImage = (loop == 1)? cell.subPreview : cell.mainPreview;
                currentImage.clipsToBounds = YES;
                
                CGSize imageSize = [Util getAspectRatio:[[medias objectAtIndex:0] objectForKey:@"media_dimension"] ofParentWidth:self.view.frame.size.width - 20];
                
                cell.mediaHeight.constant = imageSize.height;
                
                if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
                    NSMutableArray *getlocal = [currentFeed objectForKey:@"is_media"];
                    
                    currentImage.image =  [[getlocal objectAtIndex:0] objectForKey:@"mediaThumb"];
                    [cell.playIcon setHidden:YES];
                    [cell.activityIndicator setHidden:YES];
                    
                    //Hide the view count label for local videos
                    cell.videoViewCountHeight.constant = 0;
                }
                else
                {
                    
                    //Show the view count label for video post
                    long viewCount = [[[medias objectAtIndex:0] objectForKey:@"views_count"] longLongValue];
                    if (viewCount == 0) {
                        //Hide the view count label for post contains 0 views
                        cell.videoViewCountHeight.constant = 0;
                    }
                    else{
                        cell.videoViewCountHeight.constant = 20;
                        cell.videoViewCount.text = [Util getViewsString:viewCount];
                    }
                    
                    [delegate.videoIds setValue:[[medias objectAtIndex:0] valueForKey:@"video_id"] forKey:[[medias objectAtIndex:0] valueForKey:@"media_url"]];
                    
                    CGSize imageSize = [Util getAspectRatio:[[medias objectAtIndex:0] objectForKey:@"media_dimension"] ofParentWidth:self.view.frame.size.width - 20];
                    cell.mediaHeight.constant = imageSize.height;
                    
                    NSString *videoUrl = [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[[medias objectAtIndex:0] objectForKey:@"video_thumb_image_url"]];
                    
                    [feedsDesign showDownloadProgress:cell imageView:currentImage mediaUrl:videoUrl imageSize:imageSize onProgressView:[Util designdownloadProgress:cell.downloadProgress]];
                    [cell.playIcon setHidden:YES];
                    [cell.activityIndicator setHidden:YES];
                    
                    //Add click event
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPostDetailsAtFirstIndex:)];
                    [currentImage setUserInteractionEnabled:YES];
                    [currentImage addGestureRecognizer:tap];
                    
                    //Play inline video in feeds list
//                    [feedsDesign playInlineVideo:cell Url:[[medias objectAtIndex:loop] valueForKey:@"media_url"]];
                    [feedsDesign playInlineVideo:cell withSize:imageSize andUrl:[[medias objectAtIndex:loop] valueForKey:@"media_url"]];
                    
                }
                if(loop == 1){
                    [cell.mainPreview setHidden:NO];
                    break;
                }
            }
        }
    }
    else{
        cell.message.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        [cell.message setText:[currentFeed objectForKey:@"post_content"]];
        cell.message.delegate = self;
        if ([[currentFeed objectForKey:@"continue_reading_flag"] intValue] == 1) {
            if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
                [Util setAddMoreTextForLabel:cell.message endsWithString:ENDS_WITH_STRING forlength:256 forColor:UIColorFromHexCode(THEME_COLOR)];
            }
            else
            {
                [Util setAddMoreTextForLabel:cell.message endsWithString:ENDS_WITH_STRING forlength:[cell.message.text length] forColor:UIColorFromHexCode(THEME_COLOR)];
            }
        }
    }
    
    NSArray *urlPreviewDetails = [currentFeed objectForKey:@"link_details"];
    if([urlPreviewDetails count] != 0){
        NSDictionary *previewDetails = [urlPreviewDetails objectAtIndex:0];
        cell.urlPreviewHeight.constant = 70;
        [cell.urlPreview setHidden:NO];
        [cell.urlPreview loadWithSiteData:[previewDetails objectForKey:@"link"] title:[previewDetails objectForKey:@"link_title"] description:[previewDetails objectForKey:@"link_description"] siteName:[previewDetails objectForKey:@"link_sitename"] imageUrl:[previewDetails objectForKey:@"link_image_url"]];
        
        if([[previewDetails objectForKey:@"link_image_url"] length] == 0)
            cell.urlPreview.imageViewWidth.constant = 0;
        
        if([[previewDetails objectForKey:@"link_image_url"] length] == 0 && [[previewDetails objectForKey:@"link_title"] length] == 0 && [[previewDetails objectForKey:@"link_description"] length] == 0 &&  [[previewDetails objectForKey:@"link_sitename"] length] == 0)
        {
            [cell.urlPreview setHidden:YES];
            cell.urlPreviewHeight.constant = 0;
        }
    }
    else{
        [cell.urlPreview setHidden:YES];
        cell.urlPreviewHeight.constant = 0;
    }
}


//----------- post details start -----------------

//Tap gesture recognizer for image to show post feeds
- (void) showPostDetailsAtFirstIndex:(UITapGestureRecognizer *)tapRecognizer {
    //Convert view to imageview
    UIImageView *imageView = (UIImageView *)tapRecognizer.view;
    [self moveToPostDetails:imageView index:0];
}
- (void) showPostDetailsAtSecondIndex:(UITapGestureRecognizer *)tapRecognizer {
    //Convert view to imageview
    UIImageView *imageView = (UIImageView *)tapRecognizer.view;
    [self moveToPostDetails:imageView index:1];
}

- (void)moveToPostDetails:(UIImageView *)imageView index:(int)index{
    
    CGPoint imagePosition = [imageView convertPoint:CGPointZero toView:self.postTable];
    NSIndexPath *indexPath = [self.postTable indexPathForRowAtPoint:imagePosition];
    FeedCell *cell = [self.postTable cellForRowAtIndexPath:indexPath];
    
    if ([feeds count] > indexPath.row) {
        NSMutableDictionary *feed = [feeds objectAtIndex:indexPath.row];
        if ([[feed objectForKey:@"is_local"] isEqualToString:@"false"]) {
            
            //1. Check post has image
            if ([[feed valueForKey:@"image_present"] boolValue] && [[feed objectForKey:@"image"] count] == 1) {
                NSMutableArray *mediaList = [[feed objectForKey:@"image"] mutableCopy];
                NSMutableArray *sliderImages = [[NSMutableArray alloc] init];
                for (int i=0; i<[mediaList count]; i++) {
                    NSMutableDictionary *img = [[NSMutableDictionary alloc] init];
                    [img setValue:[[mediaList objectAtIndex:i] valueForKey:@"media_url"] forKey:@"imageUrl"];
                    [sliderImages addObject:img];
                }
                [Util showSlider:self forImage:sliderImages atIndex:0];
            }
            //2. If post has more than a image
            else if ([[feed valueForKey:@"image_present"] boolValue] && [[feed objectForKey:@"image"] count] > 1) {
                BuzzardRunPostDetails *postDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"BuzzardRunPostDetails"];
                postDetails.postId = [feed valueForKey:@"post_id"];
                postDetails.postDetails = feed;
                postDetails.mediaBase = mediaBaseUrl;
                postDetails.startIndex = index;
                selectedPostIndex = (int)indexPath.row;
                [self.navigationController pushViewController:postDetails animated:YES];
            }
            //3. Play video
            else if ([[feed valueForKey:@"video_present"] boolValue]) {
                
                NSMutableArray *mediaList = [[feed objectForKey:@"video"] mutableCopy];
                NSString *mediaUrl = [[mediaList objectAtIndex:index] valueForKey:@"media_url"];
                NSString *thumbUrl = [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[[mediaList objectAtIndex:0] valueForKey:@"video_thumb_image_url"]];
                [feedsDesign playVideo:mediaUrl withThumb:nil fromController:self withUrl:thumbUrl];
                [feedsDesign increaseViewCount:mediaUrl];
            }
        }
        else // Show from Local
        {
            NSMutableDictionary *feed = [feeds objectAtIndex:indexPath.row];
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
                [Util showSlider:self forImage:sliderImages atIndex:indexPath.row];
            }
            else  // Video
            {
                NSMutableArray *mediaList = [[feed objectForKey:@"video"] mutableCopy];
                NSString *mediaUrl = [[mediaList objectAtIndex:index] valueForKey:@"media_url"];
                
                [feedsDesign playVideo:mediaUrl withThumb:[[arrayMedia objectAtIndex:0] valueForKey:@"mediaThumb"] fromController:self withUrl:nil];                
              
            }
        }
    }
}


//----------- post details end -----------------

//Build feed cell with common data
- (void) buildFeedCommonData :(FeedCell *) cell forFeedData:(NSMutableDictionary *) currentFeed{
    
    // Hide the stared list button
    cell.starListButton.hidden = YES;
    
    // Poster Profile IMage
    NSMutableDictionary *postersProfileImage = [currentFeed objectForKey:@"posters_profile_image"];
    NSString *profileImageUrl =[postersProfileImage  objectForKey:@"profile_image"];
    [cell.profileImage setImageWithURL:[NSURL URLWithString:profileImageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    [Util makeCircularImage:cell.profileImage withBorderColor:UIColorFromHexCode(THEME_COLOR)];
    
    //Add zoom
//    [[Util sharedInstance] addImageZoom:profileImage];
    
    UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
    [cell.profileImage setUserInteractionEnabled:YES];
    [cell.profileImage addGestureRecognizer:tapProfileImage];
    
    // poster Profile Name and Description
    NSString *postDescription = [currentFeed objectForKey:@"post_description"];
    NSString *nameValue = [currentFeed objectForKey:@"name"];
    [cell.name setAttributedText:[Util feedsHeaderName:nameValue desc:postDescription]];
    NSRange range = NSMakeRange(0, [nameValue length]);
    [Util makeAsLink:cell.name withColor:[UIColor blackColor] showUnderLine:NO range:range];
    
    UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
    [cell.name setUserInteractionEnabled:YES];
    [cell.name addGestureRecognizer:tapName];
    
    ///////////////////////  MENU ///////////////////////////
    
    // 1. If buzzard run Expiry or Invalid or Deleted from admin, should not show the menu button
    if (canPost && ! expiry) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ShowMenu:)];
        [cell.menuButton setUserInteractionEnabled:YES];
        [cell.menuButton addGestureRecognizer:tap];
        
        int isOwner = [[currentFeed objectForKey:@"am_owner"] intValue];
        if (isOwner == 1) {
            cell.menuButton.hidden = NO;
        }
        else{
            cell.menuButton.hidden = YES;
        }
    }
    else{
        cell.menuButton.hidden = YES;
    }
    
    ////////////////////// CHECK IN ////////////////////////////
    [cell.checkinButton addTarget:self action:@selector(CheckIn:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *checkInDetails = [currentFeed objectForKey:@"check_in_details"];
    if ([checkInDetails count] != 0) {
        [cell.checkinView hideByHeight:NO];
        [cell.checkinLabel setText:[[checkInDetails objectAtIndex:0] objectForKey:@"name"]];
    }
    else
    {
        [cell.checkinView hideByHeight:YES];
    }
    
    // post date time
    [cell.date setText:[Util timeStamp: [[currentFeed objectForKey:@"time_stamp"] intValue]]];
    
    // Privacy Type Image
    int privacy_type = [[currentFeed objectForKey:@"privacy_type"] intValue];
    [cell.privacyImage setImage:[Util imageForFeed:privacy_type withType:@"privacy"]];
    
    feedsDesign.feeds = feeds;
    feedsDesign.feedTable = _postTable;
    feedsDesign.mediaBaseUrl= mediaBaseUrl;
    feedsDesign.viewController = self;
    
    //Set star and command counts
    [feedsDesign setStarAndCommentCount:cell forDictionary:currentFeed];
    
    
    if ([[currentFeed objectForKey:@"is_local"] isEqualToString:@"true"]) {
        if ([[currentFeed objectForKey:@"is_upload"] isEqualToString:@"completed"]) {
            cell.dimView.hidden = YES;
            cell.menuButton.hidden = YES;
        }
        else
        {
            cell.dimView.hidden = NO;
        }
    }
    else{
        cell.dimView.hidden = YES;
    }
    [cell.starButton addTarget:self action:@selector(Star:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentsButton addTarget:self action:@selector(showCommentPage:) forControlEvents:UIControlEventTouchUpInside];
}

//Common Delegate for TTTAttributed Label
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    CGPoint position = [label convertPoint:CGPointZero toView:self.postTable];
    NSIndexPath *indexPath = [self.postTable indexPathForRowAtPoint:position];
    if ([feeds count] > indexPath.row) {
        NSMutableDictionary *feed = [feeds objectAtIndex:indexPath.row];
        if ([[feed objectForKey:@"is_local"] isEqualToString:@"false"]) {            
            if(url == nil){
                //Build Input Parameters
                NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
                [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
                [inputParams setValue:[feed valueForKey:@"post_id"] forKey:@"post_id"];
                
                [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
                    if([[response valueForKey:@"status"] boolValue]){
                        [feed setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                        [feed setValue:[NSNumber numberWithBool:FALSE] forKey:@"continue_reading_flag"];
                        [_postTable reloadData];
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
    }
}

-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer
{
    // Get selected Index
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.postTable];
    NSIndexPath *indexPath = [self.postTable indexPathForRowAtPoint:buttonPosition];
    if ([feeds count] > indexPath.row) {
        if (![[[feeds objectAtIndex:indexPath.row] valueForKey:@"is_buzzard_run_activity"] boolValue]  && ![[[feeds objectAtIndex:indexPath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
            MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
            [self.navigationController pushViewController:myProfile animated:YES];
        }
    }    
}

-(void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        UIMenuController *menucontroller=[UIMenuController sharedMenuController];
        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.postTable];
        NSIndexPath *indexPath = [self.postTable indexPathForRowAtPoint:buttonPosition];
        
        if ([feeds count] > indexPath.row) {
            
            NSDictionary *feed = [feeds objectAtIndex:indexPath.row];
            
            if ([[feed valueForKey:@"is_local"] boolValue]) {
                UIMenuItem *Menuitem=[[UIMenuItem alloc] initWithTitle:@"Cancel Upload" action:@selector(DeletePost:)];
                [menucontroller setMenuItems:[NSArray arrayWithObjects:Menuitem,nil]];
            }
            else{
                UIMenuItem *Menuitem=[[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(DeletePost:)];
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
    if([feeds count] > menuPosition.row && [[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_local"]  isEqualToString:@"true"])
    {
        if (![[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_upload"]  isEqualToString:@"completed"]) {
            popupView.message.text = NSLocalizedString(CANCEL_FOR_SURE, nil);
            isDelete = FALSE;
        }
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
        if ([feeds count] > menuPosition.row) {
            
            NSString *strPostId = [NSString stringWithFormat:@"%@",[[feeds objectAtIndex:menuPosition.row] objectForKey:@"post_id"]];
            
            [_postTable beginUpdates];
            [feeds removeObjectAtIndex:menuPosition.row];
            [_postTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
            [_postTable endUpdates];
            
            //Build Input Parameters
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:strPostId  forKey:@"post_id"];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            
            [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DELETE_POST withCallBack:^(NSDictionary * response){
                
                if([[response valueForKey:@"status"] boolValue]){
                    
                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                    [self showAndHidePostButton];
                }
                else
                {
                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                }
                
            } isShowLoader:NO];
        }
    }
    else{
        
        // Cancel Local Feeds
        if([feeds count] > menuPosition.row && [[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_local"]  isEqualToString:@"true"])
        {
            
            if ([[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_upload"] isEqualToString:@"completed"]) {
                
                [_postTable beginUpdates];
                NSMutableDictionary *dict = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"new_post"];
                [_uploadCancelArray addObject:[dict objectForKey:@"unique_id"]];
                NSURLSessionTask *task = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"task"];
                [task cancel];
                [feeds removeObjectAtIndex:menuPosition.row];
                [_postTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
                [_postTable endUpdates];
            }
            else
            {                
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(POST_UPLOADED, nil)];
            }
        }
        else{
           [[AlertMessage sharedInstance] showMessage:NSLocalizedString(POST_UPLOADED, nil)];
        }
    }
}


#pragma mark YesNoPopDelegate
- (void)onYesClick{
    [self deleteFeedPost];
}

- (void)onNoClick{
    [yesNoPopup dismiss:YES];
}

// ------------- Delete post End  ----------------

// Click Star & Unstar
- (IBAction)Star:(id)sender
{
    [feedsDesign addStar:self.postTable fromArray:feeds forControl:sender];
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender
{
    [feedsDesign addBookmark:self.postTable fromArray:feeds forControl:sender];
}

// show Checkin
- (IBAction)CheckIn:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.postTable];
    NSIndexPath *indexPath = [self.postTable indexPathForRowAtPoint:buttonPosition];
    if ([feeds count] > indexPath.row) {
        
        NSDictionary *checkinData = [[[feeds objectAtIndex:indexPath.row] objectForKey:@"check_in_details"] objectAtIndex:0];
        
        ShowCheckinInMap *checkinMap = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowCheckinInMap"];
        checkinMap.checkinName = [checkinData valueForKey:@"name"];
        checkinMap.latitude = [checkinData valueForKey:@"latitude"];
        checkinMap.longitude = [checkinData valueForKey:@"longitude"];
        [self.navigationController pushViewController:checkinMap animated:YES];
    }
}

// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_postTable];
        NSIndexPath *path = [_postTable indexPathForRowAtPoint:buttonPosition];
        if ([feeds count] > path.row) {
            NSString *star_post_id = [[feeds objectAtIndex:path.row] objectForKey:@"post_id"];
            if(star_post_id != nil && ![star_post_id isEqualToString:@""]){
                selectedPostIndex = (int) path.row;
                BuzzardRunComments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"BuzzardRunComments"];
                NSDictionary *imageInfo = [feeds objectAtIndex:path.row];
                comment.postId = star_post_id;
                comment.mediaId = [imageInfo valueForKey:@"image_id"];
                comment.postDetails = [feeds objectAtIndex:path.row];
                comment.buzzardRunId = [imageInfo objectForKey:@"buzzard_run_id"];
                comment.buzzardRunEventId = [imageInfo objectForKey:@"buzzard_run_event_id"];
                [self.navigationController pushViewController:comment animated:YES];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:PERFORM_LATER];
            }
        }
    }
}

- (void)setInstructions:(NSString *)instructions{
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithData:[instructions dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"CenturyGothic" size:15], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString.string length] - 1)];
    _details.attributedText = attributedString;
    [_detailsView loadHTMLString:instructions baseURL:nil];
    _detailsView.backgroundColor = [UIColor blackColor];
}

// Get Feeds List
-(void)getFeedsList
{
    NSString *strtimeStamp = @"0";
    NSString *strRecent = @"0";
    
    int postIndex = [Util getMatchedObjectPosition:@"is_local" valueToMatch:@"false" from:feeds type:0];
    
    if ([feeds count] != 0 && postIndex != -1) {
        NSMutableDictionary *lastIndex = [feeds lastObject];
        strtimeStamp = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"time_stamp"]];
        strRecent = @"0";
    }
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_buzzardRunId forKey:@"buzzard_run_id"];
    [inputParams setValue:_buzzardRunEventId forKey:@"buzzard_run_event_id"];
    [inputParams setValue:strRecent  forKey:@"recent"];
    [inputParams setValue:strtimeStamp forKey:@"time_stamp"];
    
    [_postTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BUZZARD_RUN_POST_LIST withCallBack:^(NSDictionary * response){
        [_postTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
            eventDetails = [response objectForKey:@"event_details"];
            canPost = [[response objectForKey:@"can_post"] boolValue];
            canSubmit = [[response objectForKey:@"can_submit"] boolValue];
            expiry = [[response objectForKey:@"expiry"] boolValue];
            [self setInstructions:eventDetails];
            
            [self removeUploadedLocalFeeds:response];
            [self alterTheMediaList:response];
            
            //show empty message
            [self addEmptyMessageForFeedListTable];
        
            [self showAndHidePostButton];
            
            // if Expiry is true -> is an Buzzard run or event expired so we can not add or delete the post
            
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:NO];
}


//Append the media url with base
- (void)alterTheMediaList:(NSDictionary *)response{
    
    for (int i=0; i< [[response objectForKey:@"event_post_list"] count]; i++) {
        NSMutableDictionary *dict = [[[response objectForKey:@"event_post_list"] objectAtIndex:i] mutableCopy];
        
        [dict setValue:@"false" forKey:@"is_local"];
        [dict setValue:@"false" forKey:@"is_upload"];
        [dict setValue:@"" forKey:@"task_identifier"];
        [dict setValue:@"" forKey:@"task"];
        [dict setValue:@"true" forKey:@"isEnabled"];
        
        int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[dict valueForKey:@"post_id"] from:feeds type:1];
        
        if (![[dict objectForKey:@"is_buzzard_run_activity"] boolValue] && postIndex == -1) {
            
            if (![[dict objectForKey:@"is_buzzard_run_activity"] boolValue]) {
                
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
        else if ([[dict objectForKey:@"is_buzzard_run_activity"] boolValue]){
            // Add response array to the selected feed type
            [feeds addObject:dict];
        }
        
    }
    [_postTable reloadData];    
}


-(void)removeUploadedLocalFeeds:(NSDictionary *)response
{
    
    for (int i=0; i<[feeds count]; i++) {
        
        if ([[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"true"]) {
            
            NSMutableDictionary *localInputParams = [[feeds objectAtIndex:i] objectForKey:@"new_post"]; // [indexValues objectForKey:@"new_post"];
            NSString *localUniqueId = [localInputParams objectForKey:@"unique_id"];
            
            for (int j=0; j< [[response objectForKey:@"event_post_list"] count]; j++) {
                NSMutableDictionary *dict = [[[response objectForKey:@"event_post_list"] objectAtIndex:j] mutableCopy];
                NSString *uniqueID = [dict objectForKey:@"unique_id"];
                if (![[dict objectForKey:@"is_team_activity"] boolValue]) {
                    if ([uniqueID isEqualToString:localUniqueId]) {
                        [feeds removeObjectAtIndex:i];
                        i--;
                    }
                }
            }
        }
    }
}


- (void)addEmptyMessageForFeedListTable{
    
    if (expiry && [feeds count] == 0)
    {
        [Util addEmptyMessageToTable:self.postTable withMessage:NO_FEEDS withColor:[UIColor whiteColor]];
    }
    else if(!canPost && [feeds count] == 0)
    {
        [Util addEmptyMessageToTable:self.postTable withMessage:NEED_APPROVED withColor:[UIColor whiteColor]];
    }
    else if ([feeds count] == 0) {
        [Util addEmptyMessageToTable:self.postTable withMessage:NO_FEEDS withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:self.postTable withMessage:@"" withColor:[UIColor blackColor]];
    }
    
}

// ---------------------------- END FEEDS LIST ------------------------------------



// ---------------------------- START POST LOCAL FEEDS -----------------------------------

// New Post feeds
-(void)postFeeds
{
    for (int i=0; i<[feeds count]; i++) {
        NSMutableDictionary *indexValues = [feeds objectAtIndex:i];
        NSMutableArray *medias = [indexValues objectForKey:@"is_media"];
        if ([[indexValues objectForKey:@"is_upload"] isEqualToString:@"false"] && [[indexValues objectForKey:@"is_local"] isEqualToString:@"true"])
        {
            NSMutableDictionary *inputParams = [indexValues objectForKey:@"new_post"];
            
            // New Post
            [self postNewfeeds:inputParams Media:medias feedType:@"1" getIndex:i];
            
            // Change the is_upload status while uploading to server
            [[feeds objectAtIndex:i]setObject:@"true" forKey:@"is_upload"];
        }
    }
}

// API call for new post
-(void)postNewfeeds:(NSMutableDictionary *)inputparams Media:(NSMutableArray *)medias feedType:(NSString *)type getIndex:(int)index
{
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [inputparams setObject:UUID forKey:@"unique_id"];
    
    if ([feeds count] >= 2) {
        // while new post tableview scroll to top
        NSIndexPath *scrollindex = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.postTable scrollToRowAtIndexPath:scrollindex atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }    
    
    //Check is the video request
    //If so, compress the video, else send the request
    if ([medias count] > 0 && ![[[medias objectAtIndex:0] valueForKey:@"mediaType"] boolValue]) {
        
        NSMutableDictionary *media = [medias objectAtIndex:0];
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        NSNumber *mediaSize = [config objectForKey:@"default_video_size"];
        [[Util sharedInstance]compressVideo:[media valueForKey:@"mediaUrl"] isCaptured:NO toPass:^(NSData * assetData, UIImage * thumbnail) {
            [media setObject:assetData forKey:@"assetData"];
            if (![self isMediaPostCancel:[inputparams objectForKey:@"unique_id"]]) {
                [self uploadPost:inputparams Media:medias feedType:type getIndex:index];
            }
        } withSize:mediaSize withImage:nil];
    }
    else{
        [self uploadPost:inputparams Media:medias feedType:type getIndex:index];
    }
    
    //Show progress
    UIProgressView *progressView = [self getProgressViewAtIndex:0];
    
    //If so, compress the video, else send the request
    if ([medias count] > 0) {
        [Util setProgressWithAnimation:progressView withDuration:15];
    }
    
}

-(BOOL)isMediaPostCancel :(NSString *)uniuqeId
{
    for (int i=0; i<[_uploadCancelArray count]; i++) {
        
        if ([uniuqeId isEqualToString:[_uploadCancelArray objectAtIndex:i]]) {
            [_uploadCancelArray removeObjectAtIndex:i];
            i--;
            return TRUE;
        }
    }
    return false;
}

- (void)uploadPost:(NSMutableDictionary *)inputparams Media:(NSMutableArray *)medias feedType:(NSString *)type getIndex:(int)index{
    
    NSURLSessionUploadTask *task = [[Util sharedInstance]  sendHTTPPostRequestWithMultiPart:inputparams withMultiPart:medias withRequestUrl:POST_CREATE_BUZZARD_RUN withImage:nil withCallBack:^(NSDictionary * response) {
        if([[response valueForKey:@"status"] boolValue]){
            // post_id
            [self getNewFeeds];
            [_submitforApprovalView hideByHeight:NO];
        }
        else
        {
            if (response != nil) {
                expiry = [[response objectForKey:@"expiry"] boolValue];
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                [_menuButton setHidden:YES];
                
                // 1.If Buzzard run expired should show feeds  2. If buzzard run delete or disable the buzzard run should hide the tableview
                if (expiry) {
                    [_postTable setHidden:NO];
                }
                else
                {
                    [_postTable setHidden:YES];
                }
            }
            
        }
    } onProgressView:nil isFromBuzzardRun:TRUE];
    
    NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier];
    
    [[feeds objectAtIndex:index] setValue:taskIdentifier forKey:@"task_identifier"];
    [[feeds objectAtIndex:index] setValue:task forKey:@"task"];
    
    // Showing progrss while uploading feeds
    [self registerForUploadRequest];
    
}

// Register for new Feed upload Request
-(void)registerForUploadRequest
{
    [[Util sharedInstance].httpMultiFileTaskManager setTaskDidSendBodyDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            double percentDone = (totalBytesSent / (totalBytesExpectedToSend * 1.0f));
            
            NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier];
            
            // If current feed type is uploading local feeds show progrss bar and trigger the pull to refresh
            int index = [self getMatchedObjectIndex:feeds valuetoMatch:taskIdentifier];
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            FeedCell *cell = [self.postTable cellForRowAtIndexPath:path];
            [cell.activityIndicator setHidden:YES];
            [cell.playIcon setHidden:NO];
            if (index != -1) {
                if (percentDone == 1) {
                    cell.dimView.hidden = YES;
                    
                    [[feeds objectAtIndex:index] setObject:@"completed" forKey:@"is_upload"];
                    [_postTable reloadData];
                    
                }
                else{
                    UIProgressView *progressView = [self getProgressViewAtIndex:index];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (percentDone > .15)
                        {
                            progressView.progress =  percentDone;
                        }
                        cell.dimView.hidden = NO;
                    });
                }
            }
            else
            {
                cell.dimView.hidden = YES;
            }
            
        });
        
    } ];
}

-(int)getMatchedObjectIndex :(NSMutableArray *)data valuetoMatch:(NSString *)taskIdentifier
{
    for (int i=0; i<[data count]; i++) {
        if ([[[data objectAtIndex:i] valueForKey:@"task_identifier"] isEqualToString:taskIdentifier]) {
            return i;
        }
    }
    
    return -1;
}

- (UIProgressView *)getProgressViewAtIndex:(int)index{
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    FeedCell *cell = [self.postTable cellForRowAtIndexPath:path];
    cell.progressView.hidden = NO;
    return cell.progressView;
}

// ---------------------------- END POST LOCAL FEEDS -----------------------------------




@end
