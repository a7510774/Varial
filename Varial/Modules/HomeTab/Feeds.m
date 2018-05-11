//
//  Feeds.m
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ViewController.h"
#import "Feeds.h"
#import "TTTAttributedLabel.h"
#import "Comments.h"
#import "BaiduMap.h"
#import "GoogleAdMob.h"
#import "AdCell.h"
#import "InviteFriends.h"
#import "FeedsDesign.h"
#import "UITableView+TableViewAnimations.h"
#import "FRHyperLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <ResponsiveLabel/ResponsiveLabel.h>
#import "Session.h"
//#import "UITapGestureRecognizer+LabelActionHandled.h"

@interface Feeds ()
{
    ViewController *rootViewController ;
    BOOL myBoolIsMutePressed;
    //FeedsDesign *feedsDesign;
}

@end

@implementation Feeds
@synthesize selectedFeedType;
NSTimer *newFeedsTimer;
BOOL needToShowFeedIcon,isShareAvailable;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    rootViewController = [[self.navigationController viewControllers] firstObject];
    selectedPostIndex = -1;
    selectedFeedType = rootViewController.selectedFeedType;
    mediaBaseUrl = rootViewController.mediaBase;
    
    [self.feedsTable registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    [self.feedsTable registerNib:[UINib nibWithNibName:@"AdCell" bundle:nil] forCellReuseIdentifier:@"AdCell"];
    [self.feedsTable registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
    [self.feedsTable registerNib:[UINib nibWithNibName:@"TeamFeedCell" bundle:nil] forCellReuseIdentifier:@"TeamFeedCell"];
    
//    [self getFeedValuesFromSelectedType];
    if ([rootViewController.feedTypeList count] == 0)
    {
        [self getFeedsTypesList];
    }
    else{
        feedTypeList = rootViewController.feedTypeList;
    }
    [self changeTableViewHeight];
    [self createPopUpWindows];
    [self registerForUploadRequest];
    
    feedsDesign = [[FeedsDesign alloc] init];
    
    _feedsTable.rowHeight = UITableViewAutomaticDimension;

    [self scrollViewDidScroll:_feedsTable];
    
    // Notification for View Count Increase
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView:)
                                                 name:@"ViewCountNotification"
                                               object:nil];
    
    [super viewDidLoad];
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Feeds viewDidAppear %d", animated);
    [super viewDidAppear:animated];

    [self designTheView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([feeds count] == 0)
        {
            [Util addEmptyMessageToTable:self.feedsTable withMessage:PLEASE_LOADING withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
        }
    });
    
    [self setFeedType];
    [self getFeedValuesFromSelectedType];
    
    NSLog(@"viewDidAppear Videos");
    [feedsDesign checkWhichVideoToEnable:_feedsTable];
}

-(void)PlayVideoOnAppForeground
{
//    NSLog(@"PlayVideoOnAppForeground");
//    [feedsDesign checkWhichVideoToEnable:_feedsTable];
}

- (void)StopVideoOnAppBackground {
    [feedsDesign StopVideoOnAppBackground:_feedsTable];
}

- (void)setFeedType {
    // After create new post -> based on the selected type should load.
    if ([feedTypeList count] != 0 ) {
        if ([feedTypeList count] >= [selectedFeedType intValue]) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[selectedFeedType intValue]-1 inSection:0];
            [self tableView:_feedsTypesTable didSelectRowAtIndexPath:indexPath];
            feed_type = [[[feedTypeList objectAtIndex:indexPath.row] objectForKey:@"feed_type"] intValue];
            feedTypeId = [NSString stringWithFormat:@"%@",[[feedTypeList objectAtIndex:indexPath.row] objectForKey:@"id"]];
        }
        else if([selectedFeedType intValue] == 6)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[feedTypeList count]-1 inSection:0];
            [self tableView:_feedsTypesTable didSelectRowAtIndexPath:indexPath];
            feed_type = 6;
            feedTypeId = [NSString stringWithFormat:@"%@",[[feedTypeList objectAtIndex:indexPath.row] objectForKey:@"id"]];
        }
        else{
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self tableView:_feedsTypesTable didSelectRowAtIndexPath:indexPath];
            feed_type = 1;
            feedTypeId = [NSString stringWithFormat:@"%@",[[feedTypeList objectAtIndex:indexPath.row] objectForKey:@"id"]];
        }
    }
    // Set FeedType Id to UserDefaults
    [Util setInDefaults:feedTypeId withKey:@"feed_type_id"];
    [self postFeeds];
}

- (void)viewDidUnload{
    [newFeedsTimer invalidate];
    newFeedsTimer = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"Feeds view will disappear");
    [feedsDesign stopAllVideos];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    
    [newFeedsTimer invalidate];
    newFeedsTimer = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
}

//Scroll to top while clicking the new feed button
- (IBAction)moveToTop:(id)sender {
    [_feedsIcon setHidden:YES];
    [_feedsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    needToShowFeedIcon = FALSE;
}

- (void)viewWillAppear:(BOOL)animated{
    //Check for name and image update
    BOOL isNameChanged = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isNameChanged"] boolValue];
    BOOL isImageChanged = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isImageChanged"] boolValue];
    if (isNameChanged || isImageChanged) {
        [self resetNamesInAllList];
    }
    
    //Check for update has made in the feed
    if (selectedPostIndex != -1) {
        [self updateTheFeedDetails];
    }
    
    newFeedsTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(refreshFeedList) userInfo:nil repeats: YES];
    [Util setStatusBar];
    appDelegate.shouldAllowRotation = FALSE;
    
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

- (void)refreshFeedList{
    needToShowFeedIcon = TRUE;
    [self getNewFeeds];
}

- (void)updateTheFeedDetails{
    [_feedsTable reloadDataWithAnimation];
    
    
    selectedPostIndex = -1;
}

//----------- Reset the name ----------
- (void)resetNamesInAllList{
    [self resetNames:rootViewController.publicFeeds];
    [self resetNames:rootViewController.privateFeeds];
    [self resetNames:rootViewController.teamAFeeds];
    [self resetNames:rootViewController.teamBFeeds];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:0] forKey:@"isNameChanged"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:0] forKey:@"isImageChanged"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [_feedsTable reloadDataWithAnimation];
}

//Reset name after change in profile page
- (void)resetNames:(NSMutableArray *)source{
    for (int i=0; i<[source count]; i++) {
        NSMutableDictionary *feed = [source objectAtIndex:i];
        if ([[feed valueForKey:@"am_owner"] boolValue] && ![[feed objectForKey:@"is_team_activity"] boolValue]) {
            [feed setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_name"] forKey:@"name"];
            NSMutableDictionary *profileImage = [feed objectForKey:@"posters_profile_image"];
            [profileImage setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"player_image"] forKey:@"profile_image"];
        }
    }
}
//----------- Reset the name ends ----------

- (void) designTheView
{
    [Util createRoundedCorener:_feedTypesView withCorner:5];
    
    // On page load show public feeds
    _feedTypesView.hidden = YES;
    
    selectedFeedTypeName = NSLocalizedString(POPULAR_FEED, nil);
    //selectedFeedType = @"1";
    feedTypeId =  @"6";
    feed_type = 6;
    post_id = 0;
    recent = 1;
    
    // Print selected feed type Image and Name
    _feedTypeName.text = selectedFeedTypeName;
    _feedTypeImage.image = [Util imageForFeed:[selectedFeedType intValue] withType:@"title"];
    [rootViewController setFeedType:[selectedFeedType intValue]];
    self.feedsTypesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Feed icon
    [_feedsIcon setHidden:YES];
    _feedsIcon.layer.cornerRadius = _feedsIcon.frame.size.height / 2 ;
    _feedsIcon.clipsToBounds = true;
}

- (void)insertRowAtTop {
    
//    __weak Feeds *feedRefreshSelf = self ;
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //[self getNewFeeds];
        [self getFeedsList];
//        [feedRefreshSelf.feedsTable.pullToRefreshView stopAnimating];
//        [refreshControl endRefreshing];
    });
}

//Get latest feeds
- (void)getNewFeeds{
    
    if ([feeds count] != 0) {
        
        for (int i=0; i<[feeds count]; i++) {
            if ([[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"false"]) {
                NSString *strPostId = [NSString stringWithFormat:@"%@",[[feeds objectAtIndex:i] objectForKey:@"post_id"]];
                NSString *strTimeStamp = [NSString stringWithFormat:@"%@",[[feeds objectAtIndex:i] objectForKey:@"time_stamp"]];
                [self loadMoreTopRow :strPostId getTimeStamp:strTimeStamp];
                i = (int) [feeds count];
            }
        }
        
        // Reload Table View
        [_feedsTable reloadData];
        
        if ([feeds count] == 1 && [[feeds[0] valueForKey:@"is_local"] isEqualToString:@"true"]) {
            [self getFeedsList];
        }
    }
    else
    {
        [self getFeedsList];
    }
    
}

- (void)insertRowAtBottom {
    
    __weak Feeds *feedRefreshSelf = self ;
    int64_t delayInSeconds = 0.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if ([feeds count] != 0) {
            [self loadMoreBottomRow];
        }
        else
        {
            [self getFeedsList];
        }
        
        [feedRefreshSelf.feedsTable.infiniteScrollingView stopAnimating];
//        [refreshControl endRefreshing];
    });
}

-(void)loadMoreTopRow :(NSString *)postId getTimeStamp:(NSString *)timeStamp
{
    NSLog(@"loadMoreTopRow");
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:postId forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSString stringWithFormat:@"%d",[self teamPost]] forKey:@"team_post"];
    [inputParams setValue:feedTypeId forKey:@"post_type_id"];
    [inputParams setValue:@"1"  forKey:@"recent"];
    [inputParams setValue:timeStamp  forKey:@"time_stamp"];
    [inputParams setValue:feedTypeId  forKey:@"feed_list_type_key"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_LIST withCallBack:^(NSDictionary * response) {
        
        if([[response valueForKey:@"status"] boolValue]) {
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
            rootViewController.mediaBase = mediaBaseUrl;
            
            NSString *feed_list_type = [NSString stringWithFormat:@"%@",[response objectForKey:@"feed_list_type_key"]];
            
            // check response type and slected feed type are equal
            if ([feedTypeId isEqualToString:feed_list_type]) {
                
                [self removeUploadedLocalFeeds:response];
                
                NSMutableArray *topResult = [response objectForKey:@"feed_list"];
                for (int i = 0; i < [topResult count]; i++) {
                    
                    int index = (int) ([topResult count]-1) - i;
                    
                    // Get index Data
                    NSMutableDictionary *newFeeds = [[topResult objectAtIndex:index] mutableCopy];
                    
                    [newFeeds setValue:@"false" forKey:@"is_local"];
                    [newFeeds setValue:@"false" forKey:@"is_upload"];
                    [newFeeds setValue:@"" forKey:@"task_identifier"];
                    [newFeeds setValue:@"" forKey:@"task"];
                    [newFeeds setValue:@"true" forKey:@"isEnabled"];
                    
                    [newFeeds setValue:[NSNumber numberWithFloat:0] forKey:@"progress"];
                    
                    
                    int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[newFeeds valueForKey:@"post_id"] from:feeds type:1];
                    
                    if (![[newFeeds objectForKey:@"is_team_activity"] boolValue] && postIndex == -1) {
                        
                        if (![[newFeeds objectForKey:@"is_team_activity"] boolValue]) {
                            
                            NSMutableDictionary *profileImage = [[newFeeds objectForKey:@"posters_profile_image"] mutableCopy];
                            [profileImage setValue: [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[profileImage  valueForKey:@"profile_image_thumb"]] forKey:@"profile_image_thumb"];
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
                    }
                    else if([[newFeeds objectForKey:@"is_team_activity"] boolValue]){
                        // while pull to referesh add records at top
                        [feeds insertObject:newFeeds atIndex:0];
                    }
                    if (needToShowFeedIcon) {
                        if (_feedsTable.contentOffset.y > [Util getWindowSize].height) {
                            [_feedsIcon setHidden:NO];
                        }
                        needToShowFeedIcon = FALSE;
                    }
                }
                
                NSLog(@"loadMoreTopRow: reloadData");
                if ([topResult count] != 0) {
                    [_feedsTable reloadDataWithAnimation];
                } else {
//                    [feedsDesign checkWhichVideoToEnable:_feedsTable];
                }
            }
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:NO];
}

-(void)loadMoreBottomRow
{
    [self getAd];
    
    NSMutableDictionary *lastIndex = [feeds lastObject];
    NSString *strPostId = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"post_id"]];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:strPostId forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSString stringWithFormat:@"%d",[self teamPost]] forKey:@"team_post"];
    [inputParams setValue:feedTypeId forKey:@"post_type_id"];
    [inputParams setValue:@"0"  forKey:@"recent"];
    [inputParams setValue:[lastIndex objectForKey:@"time_stamp"]  forKey:@"time_stamp"];
    [inputParams setValue:feedTypeId  forKey:@"feed_list_type_key"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
            rootViewController.mediaBase = mediaBaseUrl;
            
            NSString *feed_list_type = [NSString stringWithFormat:@"%@",[response objectForKey:@"feed_list_type_key"]];
            
            // check response type and slected feed type are equal
            if ([feedTypeId isEqualToString:feed_list_type]) {
                
                // While load more at bottom if any local feeds available check the local feeds are uploaded or not. If uploaded remove from local feeds
                NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"%K CONTAINS %@",@"is_local",@"true"];
                NSArray* filteredData  = [feeds filteredArrayUsingPredicate:predicate];
                if ([filteredData count] != 0) {
                    [self removeUploadedLocalFeeds:response];
                }
                
                [self alterTheMediaList:response];
            }
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:NO];
}


- (void) createPopUpWindows
{
    feedTypePopup = [KLCPopup popupWithContentView:self.feedTypesView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [Util setUpFloatIcon:_addPost];
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(FEED, nil)];
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    __weak Feeds *feedRefreshSelf = self;
    
    // setup pull-to-refresh
//    [self.feedsTable addPullToRefreshWithActionHandler:^{
//        [feedRefreshSelf insertRowAtTop];
//    }];
//    feedRefreshSelf.feedsTable.pullToRefreshView.arrowColor = [UIColor whiteColor];
//    feedRefreshSelf.feedsTable.pullToRefreshView.textColor = [UIColor whiteColor];
//    [feedRefreshSelf.feedsTable.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
//    
    refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.backgroundColor = [UIColor purpleColor];
//    self.refreshControl.tintColor = [UIColor whiteColor];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        self.feedsTable.refreshControl = refreshControl;
    } else {
        [self.feedsTable addSubview:refreshControl];
    }
    
    [refreshControl addTarget:self
                            action:@selector(insertRowAtTop)
                  forControlEvents:UIControlEventValueChanged];
    
    // setup infinite scrolling
    [self.feedsTable addInfiniteScrollingWithActionHandler:^{
        [feedRefreshSelf insertRowAtBottom];
    }];
    
    [feedRefreshSelf.feedsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    //Alert popup
    blockConfirmation = [[YesNoPopup alloc] init];
    blockConfirmation.delegate = self;
    [blockConfirmation setPopupHeader:NSLocalizedString(BLOCK_PERSON, nil)];
    blockConfirmation.message.text = NSLocalizedString(SURE_TO_BLOCK, nil);
    [blockConfirmation.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [blockConfirmation.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    blockPopUp = [KLCPopup popupWithContentView:blockConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

//-(IBAction)addPost:(id)sender
//{
//    if([[Util sharedInstance] getNetWorkStatus])
//    {
//        CreatePostViewController *createPostViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
//        createPostViewController.isPostFromFeeds = feedTypeId;
//        if([self teamPost])
//        {
//            createPostViewController.isPostFromFeeds = nil;
//            createPostViewController.isPostFromTeam = selectedFeedTypeName;
//        }
//        
//        [self.navigationController pushViewController:createPostViewController animated:YES];
//    }
//    else{
//        [appDelegate.networkPopup show];
//    }
//}

- (void)showFeedTypes {
    NSDictionary *feedTypeListResponse = [[NSUserDefaults standardUserDefaults] objectForKey:@"FeedsTypeList"];
    
    if (feedTypeListResponse != nil ) {
        [self setFeedTypesList:feedTypeListResponse];
        [self createPopUpWindows];
        _feedTypesView.hidden = NO;
        [feedTypePopup show];
    } else {
        [self getFeedsTypesList];
        [self createPopUpWindows];
        _feedTypesView.hidden = NO;
        [feedTypePopup show];
    }
}

- (IBAction)feedTypes:(id)sender {
    [self showFeedTypes];
}

#pragma mark - UITableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _feedsTable) {
        return [feeds count];
    }
    else if(tableView == _feedsTypesTable)
    {
        return [feedTypeList count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    
    if (tableView == _feedsTable) {
        // return [self cellHeight:[feeds objectAtIndex:indexPath.row]];
        return 240;
    }
    else if(tableView == _feedsTypesTable)
    {
        return  45.0f;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _feedsTable) {
        NSDictionary *feedItem = [feeds objectAtIndex:indexPath.row];
        if ([[feedItem objectForKey:@"is_ad"] boolValue]) {
            CGSize imageSize = [Util getAspectRatio:[feedItem valueForKey:@"media_dimension"] ofParentWidth:[[UIScreen mainScreen] bounds].size.width];
            return imageSize.height + 5.f;
        }
        return UITableViewAutomaticDimension;
    }
    else if(tableView == _feedsTypesTable)
    {
        return  45.0f;
    }
    return UITableViewAutomaticDimension;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = nil;
    UITableViewCell *cell;
    FeedCell *fcell;
    
    // feeds list table
    if (tableView == _feedsTable) {
        NSLog(@"Feeds Count %lu",(unsigned long)feeds.count);
        if ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"is_ad"] boolValue]) {
            AdCell *adCell = [tableView dequeueReusableCellWithIdentifier:@"AdCell"];
            [adCell setAdInfo:[feeds objectAtIndex:indexPath.row]];
            [adCell updateImage];
            return adCell;
        } else
        
        if ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"is_team_activity"] boolValue]) {
            fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:@"TeamFeedCell"];
            if (fcell == nil)
            {
                fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeamFeedCell"];
            }
            
            fcell.selectionStyle = UITableViewCellSelectionStyleNone;
            fcell.name.delegate =self;
            NSDictionary *Values = [[feeds objectAtIndex:indexPath.row] objectForKey:@"activity"];
            [Util createTeamActivityLabel:fcell.name fromValues:Values];
            fcell.date.text = [Util timeStamp:[[[feeds objectAtIndex:indexPath.row] objectForKey:@"time_stamp"] longValue]];
            fcell.backgroundColor = [UIColor clearColor];
            return fcell;
        }
        else
        {
            if([feeds count] > 0){
                static NSString *cellIdentifier = nil;
                cellIdentifier = ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feeds objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"FeedCell" : @"MessagesCell";
                
                fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (fcell == nil)
                {
                    fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
            }
            
            // Mute Button Actions
            [fcell.gBtnMuteUnMute addTarget:self action:@selector(muteUnmutePressed:) forControlEvents:UIControlEventTouchUpInside];
            fcell.gBtnMuteUnMute.tag = indexPath.row;
            
            if ([feeds count] > indexPath.row) {
                
                feedsDesign.feeds = feeds;
                feedsDesign.feedTable = tableView;
                feedsDesign.mediaBaseUrl= mediaBaseUrl;
                feedsDesign.viewController = self;
                // set Is From Feeds True
                feedsDesign.gBoolIsFromFeeds = YES;
                feedsDesign.isVolumeClicked = NO;
//                feedsDesign.delegate = self;
                [feedsDesign designTheContainerView:fcell forFeedData:[feeds objectAtIndex:indexPath.row] mediaBase:mediaBaseUrl forDelegate:self tableView:tableView];
            }
        }
        fcell.backgroundColor = [UIColor clearColor];
        fcell.shareView.hidden = YES;
        fcell.shareViewHeightConstraint.constant = 0.0;
        NSString * isShare = [feeds[indexPath.row][@"is_share"] stringValue];
        if ([isShare isEqualToString:@"1"]) {
            fcell.shareView.hidden = NO;
            fcell.shareViewHeightConstraint.constant = 60.0;
//            [fcell.shareView addConstraint:[NSLayoutConstraint constraintWithItem:fcell.shareView
//                                                              attribute:NSLayoutAttributeHeight
//                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
//                                                                 toItem:nil
//                                                              attribute: NSLayoutAttributeNotAnAttribute
//                                                             multiplier:1
//                                                               constant:70]];
            NSString * sharedPerson = feeds[indexPath.row][@"share_details"][@"name"];
//            NSString * postOwnerName = feeds[indexPath.row][@"name"];
            
            NSString * postOwnerName = [NSString stringWithFormat:@"%@'s ",feeds[indexPath.row][@"name"]];
            
            NSString * sharedPersonImgUrl = feeds[indexPath.row][@"share_details"][@"profile_image"][@"profile_image"];
            NSString * downloadUrl = [NSString stringWithFormat:@"https://dqloq8l38fi51.cloudfront.net%@",sharedPersonImgUrl];
            [fcell.sharedPersonImage sd_setImageWithURL:[NSURL URLWithString:downloadUrl]
                                       placeholderImage:nil
                                                options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
            UIColor *color = [UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:1.0];
//            UIFont * font = [UIFont systemFontOfSize:14.0];
            NSDictionary *attrs = @{ NSForegroundColorAttributeName : color};
            NSMutableAttributedString * combinedStr = [[NSMutableAttributedString alloc]init];
            NSAttributedString *attrStr2;
            NSAttributedString *attrStr4;
            NSAttributedString * attrStr1 = [[NSAttributedString alloc]initWithString:sharedPerson attributes:nil];
            if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
            {
                attrStr2 = [[NSAttributedString alloc] initWithString:@" shared " attributes:attrs];
                attrStr4 = [[NSAttributedString alloc] initWithString:@"post" attributes:attrs];
                
            }
            
            else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
            {
                attrStr2 = [[NSAttributedString alloc] initWithString:@" 分享了 " attributes:attrs];
                attrStr4 = [[NSAttributedString alloc] initWithString:@"的帖子" attributes:attrs];
            }
            
            NSAttributedString * attrStr3 = [[NSAttributedString alloc]initWithString:postOwnerName attributes:nil];
            [combinedStr appendAttributedString:attrStr1];
            [combinedStr appendAttributedString:attrStr2];
            [combinedStr appendAttributedString:attrStr3];
            [combinedStr appendAttributedString:attrStr4];
            fcell.gLblShareDescription.attributedText = combinedStr;
            fcell.gLblShareDescription.userInteractionEnabled = YES;
            
            PatternTapResponder stringTapAction = ^(NSString *tappedString) {
                if([tappedString isEqualToString: sharedPerson]){
                    
                    [self goToSharedPersonProfile:indexPath isSharedPersonName:YES];
                }
                
                else {
                    
                    [self goToSharedPersonProfile:indexPath isSharedPersonName:NO];
                }
                
            };
            [fcell.gLblShareDescription enableDetectionForStrings:@[sharedPerson,postOwnerName] withAttributes:@{RLTapResponderAttributeName:stringTapAction}];
            
            [fcell.sharedTime setText:[Util timeStamp: [feeds[indexPath.row][@"share_details"][@"share_time"] intValue]]];
            
        } else {
            fcell.shareView.hidden = YES;
            fcell.shareViewHeightConstraint.constant = 0.0;
        }
        return fcell;
    }
    else if(tableView == _feedsTypesTable)
    {
        cellIdentifier= @"recipientCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *feedTypeImage = (UIImageView *) [cell viewWithTag:10];
        UILabel *feedName = (UILabel *)[cell viewWithTag:11];
        
        NSDictionary *list = [feedTypeList objectAtIndex:indexPath.row];
        
        feedName.text = [list objectForKey:@"type"];
        feedTypeImage.tintColor = [UIColor darkGrayColor];
        feedTypeImage.image = [Util imageForFeed:[[list objectForKey:@"feed_type"] intValue] withType:@"list"];
        
        feedName.textColor = UIColorFromHexCode(GREY_TEXT);
    }
    
    return cell;
    
}


//-(void)doActionForSharedPerson:(id)sender{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedsTable];
//    NSIndexPath *path = [_feedsTable indexPathForRowAtPoint:buttonPosition];
//    [self goToSharedPersonProfile:path isSharedPersonName:YES];
//}
//
//-(void)doActionForShareOwner:(id)sender{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedsTable];
//    NSIndexPath *path = [_feedsTable indexPathForRowAtPoint:buttonPosition];
//    [self goToSharedPersonProfile:path isSharedPersonName:NO];
//}

-(void)goToSharedPersonProfile:(NSIndexPath *)indexpath isSharedPersonName:(BOOL)isSharedPerson{
    if ([feeds count] > indexpath.row) {
        if (![[[feeds objectAtIndex:indexpath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            if (isSharedPerson) {
                if ([[Util getFromDefaults:@"user_name"] isEqualToString:[feeds objectAtIndex:indexpath.row][@"share_details"][@"name"]]) {
                    MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
                    [self.navigationController pushViewController:myProfile animated:YES];
                } else {
                    profile.friendId = [feeds objectAtIndex:indexpath.row][@"share_details"][@"player_id"];
                    profile.friendName = [feeds objectAtIndex:indexpath.row][@"share_details"][@"name"];
                    [self.navigationController pushViewController:profile animated:YES];
                }
            } else {
                if ([[Util getFromDefaults:@"user_name"] isEqualToString:[feeds objectAtIndex:indexpath.row][@"name"]]) {
                    MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
                    [self.navigationController pushViewController:myProfile animated:YES];
                } else {
                    profile.friendId = [feeds objectAtIndex:indexpath.row][@"post_owner_id"];
                    profile.friendName = [feeds objectAtIndex:indexpath.row][@"name"];
                    [self.navigationController pushViewController:profile animated:YES];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If select feed types table, should reload the data
    if(tableView == _feedsTypesTable)
    {
        if ([feedTypeList count] > indexPath.row) {
            
            [self removeOldFeeds];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
            
            NSDictionary *list = [feedTypeList objectAtIndex:indexPath.row];
            
            // Is new feed type different?
            int newType = [[list objectForKey:@"feed_type"] intValue];
            if (feed_type != newType) {
                [feedsDesign stopAllVideos];
            }
            
            NSLog(@"Indexpath row %ld Indexpath section %d", (long)indexPath.row,indexPath.section);
            NSLog(@"Feed selected %d %d", feed_type, newType);
            
            selectedFeedTypeName = [NSString stringWithFormat:@"%@",[list objectForKey:@"type"]];
            feed_type = [[list objectForKey:@"feed_type"] intValue];
            selectedFeedType = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
            
            if ([[list objectForKey:@"feed_type"] intValue] == 6) {
                selectedFeedType = @"6";
            }
            
            rootViewController.selectedFeedType = selectedFeedType;
            feedTypeId = [NSString stringWithFormat:@"%@",[list objectForKey:@"id"]];
            
            // Print selected feed type Image and Name
            _feedTypeName.text = selectedFeedTypeName;
            _feedTypeImage.image = [Util imageForFeed:[selectedFeedType intValue] withType:@"title"];
            [rootViewController setFeedType:[selectedFeedType intValue]];
            [feedTypePopup dismiss:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([feeds count] == 0)
                {
                    [Util addEmptyMessageToTable:self.feedsTable withMessage:PLEASE_LOADING withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
                }
            });
            
            // 1. If having local feeds show progress.  2.Assign feed array from selected feed type.
            [self registerForUploadRequest];
            [self getFeedValuesFromSelectedType];
            //  [self insertRowAtTop];
            
            NSLog(@"TableView did select: reloadData");
            //[_feedsTable reloadDataWithAnimation];
           // [self.feedsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

           // [_feedsTable reloadData];
        }
    }
    else{
    }
}

#pragma mark - Attributed Label delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSString *tag = [[label.text substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
//
//        CGPoint hitPoint = [label convertPoint:CGPointZero toView:self.feedsTable];
//        NSIndexPath *indexpath = [self.feedsTable indexPathForRowAtPoint:hitPoint];
//        if (![[[feeds objectAtIndex:indexpath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//            FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
//
////            profile.friendId = [feeds objectAtIndex:indexpath.row][@"post_owner_id"];
////            profile.friendName = [feeds objectAtIndex:indexpath.row][@"name"];
//            //profile.friendName = [feeds objectAtIndex:indexpath.row][@"name"];
//
//            profile.friendId = @"";
//            profile.friendName = @"";
//            profile.strNameTag = [tag stringByReplacingOccurrencesOfString:@"@" withString:@""];
//            [self.navigationController pushViewController:profile animated:YES];
//        }
//    }
    
//    else {
//        InviteFriends *inviteFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
//        NSString *stringWithoutSpecialChar = [tag
//                                              stringByReplacingOccurrencesOfString:@"@" withString:@""];
//        inviteFriends.getSearchString = stringWithoutSpecialChar;
//        [self.navigationController pushViewController:inviteFriends animated:YES];
//    }
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
        CGPoint position = [label convertPoint:CGPointZero toView:self.feedsTable];
        NSIndexPath *indexPath = [self.feedsTable indexPathForRowAtPoint:position];
        if ([feeds count] > indexPath.row) {
            
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
                        [_feedsTable reloadDataWithAnimation];
                    }else{
                        [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                    }
                } isShowLoader:NO];
            }
        }
    }
}

-(void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.feedsTable];
        NSIndexPath *indexPath = [self.feedsTable indexPathForRowAtPoint:buttonPosition];
        menuPosition = indexPath;
        
        if ([feeds count] > indexPath.row) {
            
            NSDictionary *feed = [feeds objectAtIndex:indexPath.row];
            
            if ([selectedFeedType intValue] == 2) // Private Feeds
            {
                // Hide already showing popover
                [self.menuPopover dismissMenuPopover];
                
                if ([[feed valueForKey:@"is_local"] boolValue]) {
                    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - _feedsTable.contentOffset.y, 140, 42) menuItems:@[NSLocalizedString(@"Cancel Upload",nil)]];
                }
                else{
                    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - _feedsTable.contentOffset.y, 140, 130) menuItems:
                                        @[NSLocalizedString(EDIT_MENU,nil),
                                          NSLocalizedString(DELETE_MENU,nil),
                                          NSLocalizedString(POST_TO_PUBLIC,nil),
                                          NSLocalizedString(POST_TO_FRIENDS,nil)]];
                }
                self.menuPopover.menuPopoverDelegate = self;
                self.menuPopover.tag = 100;
                [self.menuPopover showInView:self.view];
            }
            else{
                UIMenuController *menucontroller=[UIMenuController sharedMenuController];
                
                if ([[feed valueForKey:@"is_local"] boolValue]) {
                    
                    UIMenuItem *Menuitem=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Cancel Upload", nil) action:@selector(DeletePost:)];
                    [menucontroller setMenuItems:[NSArray arrayWithObjects:Menuitem,nil]];
                    
                }
                else{
                    UIMenuItem *Menuitem=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(DELETE_MENU, nil) action:@selector(DeletePost:)];
                    [menucontroller setMenuItems:[NSArray arrayWithObjects:Menuitem,nil]];
                }
                
                //It's mandatory
                [self becomeFirstResponder];
                //It's also mandatory ...remeber we've added a mehod on view class
                if([self canBecomeFirstResponder])
                {
                    UIButton *btn = (UIButton *)tapRecognizer.view;
                    [menucontroller setTargetRect:CGRectMake(10,10, 0, 200) inView:btn];
                    [menucontroller setMenuVisible:YES animated:YES];
                }
            }
            
        }
    }
    else{
        [appDelegate.networkPopup show];
    }
}

-(void)ShowSharedMenu:(UITapGestureRecognizer *)tapRecognizer
{
    [self ShowMenu:tapRecognizer];
//    if([[Util sharedInstance] getNetWorkStatus])
//    {
//        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.feedsTable];
//        NSIndexPath *indexPath = [self.feedsTable indexPathForRowAtPoint:buttonPosition];
//        menuPosition = indexPath;
//
//        if ([feeds count] > indexPath.row) {
//
//            NSDictionary *feed = [feeds objectAtIndex:indexPath.row];
//
//            if ([selectedFeedType intValue] == 2) // Private Feeds
//            {
//                // Hide already showing popover
//                [self.menuPopover dismissMenuPopover];
//
//                if ([[feed valueForKey:@"is_local"] boolValue]) {
//                    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - _feedsTable.contentOffset.y, 140, 42) menuItems:@[NSLocalizedString(@"Cancel Upload",nil)]];
//                }
//                else{
//                    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - _feedsTable.contentOffset.y, 140, 130) menuItems:
//                                        @[NSLocalizedString(EDIT_MENU,nil),
//                                          NSLocalizedString(DELETE_MENU,nil),
//                                          NSLocalizedString(POST_TO_PUBLIC,nil),
//                                          NSLocalizedString(POST_TO_FRIENDS,nil)]];
//                }
//                self.menuPopover.menuPopoverDelegate = self;
//                self.menuPopover.tag = 100;
//                [self.menuPopover showInView:self.view];
//            }
//            else{
//                UIMenuController *menucontroller=[UIMenuController sharedMenuController];
//
//                if ([[feed valueForKey:@"is_local"] boolValue]) {
//
//                    UIMenuItem *Menuitem=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Cancel Upload", nil) action:@selector(DeletePost:)];
//                    [menucontroller setMenuItems:[NSArray arrayWithObjects:Menuitem,nil]];
//
//                }
//                else{
//                    UIMenuItem *Menuitem=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(DELETE_MENU, nil) action:@selector(DeletePost:)];
//                    [menucontroller setMenuItems:[NSArray arrayWithObjects:Menuitem,nil]];
//                }
//
//                //It's mandatory
//                [self becomeFirstResponder];
//                //It's also mandatory ...remeber we've added a mehod on view class
//                if([self canBecomeFirstResponder])
//                {
//                    UIButton *btn = (UIButton *)tapRecognizer.view;
//                    [menucontroller setTargetRect:CGRectMake(10,10, 0, 200) inView:btn];
//                    [menucontroller setMenuVisible:YES animated:YES];
//                }
//            }
//
//        }
//    }
//    else{
//        [appDelegate.networkPopup show];
//    }
}


-(void)reportButtonAction:(UITapGestureRecognizer *)tapRecognizer{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.feedsTable];
        NSIndexPath *indexPath = [self.feedsTable indexPathForRowAtPoint:buttonPosition];
        reportFeed = [feeds objectAtIndex:indexPath.row];
        
        [self.reportPopover dismissMenuPopover];
        
        self.reportPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - _feedsTable.contentOffset.y, 140, 84) menuItems:@[NSLocalizedString(REPORT_THE_POST,nil),NSLocalizedString(BLOCK_THE_USER, nil)]];
        self.reportPopover.menuPopoverDelegate = self;
        self.reportPopover.tag = 101;
        [self.reportPopover showInView:self.view];
    }
}

-(void)sharedReportButtonAction:(UITapGestureRecognizer *)tapRecognizer{
    [self reportButtonAction:tapRecognizer];
//    if([[Util sharedInstance] getNetWorkStatus])
//    {
//        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.feedsTable];
//        NSIndexPath *indexPath = [self.feedsTable indexPathForRowAtPoint:buttonPosition];
//        reportFeed = [feeds objectAtIndex:indexPath.row];
//
//        [self.reportPopover dismissMenuPopover];
//
//        self.reportPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - _feedsTable.contentOffset.y, 140, 84) menuItems:@[NSLocalizedString(REPORT_THE_POST,nil),NSLocalizedString(BLOCK_THE_USER, nil)]];
//        self.reportPopover.menuPopoverDelegate = self;
//        self.reportPopover.tag = 101;
//        [self.reportPopover showInView:self.view];
//    }
}
// Delegate method for MLKMenuPopover
- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    [self.menuPopover dismissMenuPopover];
    [self.reportPopover dismissMenuPopover];
    [self.sharedMenuPopover dismissMenuPopover];
    [self.sharedReportPopover dismissMenuPopover];
    if([[Util sharedInstance] getNetWorkStatus])
    {
        if(menuPopover.tag == 100)
        {
            int clickedIndex = (int) selectedIndex;
            if (clickedIndex == 0) {
//                movePostId = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"post_id"];
                [self editPost];
            }
            else if (clickedIndex == 1) {
                [self showDeletePopUp];
            }
            else
            {
                if ([feeds count] > menuPosition.row) {
                    selectedyesNoPopUp = 2;
                    movePostId = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"post_id"];
                    movePostTypeId = (clickedIndex == 2) ? @"1" : @"3" ;
                    popupView.title.text = (clickedIndex == 2) ? NSLocalizedString(POST_TO_PUBLIC, nil) : NSLocalizedString(POST_TO_FRIENDS, nil)  ;
                    popupView.message.text = NSLocalizedString(MOVE_FEED_MESSAGE, nil);
                    [yesNoPopup show];
                }
            }
        }
        else if(menuPopover.tag == 101){
            //  int clickedIndex = selectedIndex;
            if(selectedIndex == 0){
                [self reportPost];
            }
            else{
                selectedyesNoPopUp = 3;
                [blockPopUp show];
            }
        }
    }
    else{
        [appDelegate.networkPopup show];
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


// ------------- Edit post Start -----------------

- (void)editPost {
    if([[Util sharedInstance] getNetWorkStatus])
    {
        if ([feeds count] > menuPosition.row) {
            
            NSMutableDictionary *postInfo = [feeds objectAtIndex:menuPosition.row];
            
            EditPostViewController *editPostController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"EditViewController"];
            
            [editPostController setPostInfo:postInfo];

            [self.navigationController presentViewController:editPostController animated:YES completion:nil];
        }
    }
}

// ------------- Delete post Start ---------------

- (void)DeletePost:(UIMenuController *)sender
{
    [self showDeletePopUp];
}

-(void)showDeletePopUp
{
    if([feeds count] > menuPosition.row && [[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_local"]  isEqualToString:@"true"])
    {
        if (![[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_upload"]  isEqualToString:@"completed"]) {
            popupView.message.text = NSLocalizedString(CANCEL_FOR_SURE, nil);
            selectedyesNoPopUp = 1;
            isDelete = FALSE;
            [yesNoPopup show];
        }
    }
    else{
        popupView.message.text = NSLocalizedString(DELETE_FOR_SURE, nil);
        
        selectedyesNoPopUp = 1;
        isDelete = TRUE;
        [yesNoPopup show];
    }
}

-(void)deleteFeedPost
{
    [yesNoPopup dismiss:YES];
    
    if (isDelete) {
        
        [feedsDesign stopAllVideos];
        
        if ([feeds count] > menuPosition.row) {
            
            NSString *strPostId = [NSString stringWithFormat:@"%@",[[feeds objectAtIndex:menuPosition.row] objectForKey:@"post_id"]];
            
            [_feedsTable beginUpdates];
            [feeds removeObjectAtIndex:menuPosition.row];
            [_feedsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
            [_feedsTable endUpdates];
            
            //Build Input Parameters
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:strPostId forKey:@"post_id"];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            
            [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DELETE_POST withCallBack:^(NSDictionary * response){
                
                if([[response valueForKey:@"status"] boolValue]){
                    
                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                    [self updateLocalStorage];
                    [self addEmptyMessageForFeedListTable];
                }
                else
                {
                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                }
                
            } isShowLoader:NO];
        }
    }
    else{
        if ([feeds count] > menuPosition.row) {
            
            // Cancel Local Feeds
            if([[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_local"]  isEqualToString:@"true"])
            {
                if (![[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_upload"]  isEqualToString:@"completed"]) {
                    [_feedsTable beginUpdates];
                    NSMutableDictionary *dict = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"new_post"];
                    [rootViewController.uploadCancelArray addObject:[dict objectForKey:@"unique_id"]];
                    NSURLSessionTask *task = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"task"];
                    [task cancel];
                    [feeds removeObjectAtIndex:menuPosition.row];
                    [_feedsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
                    [self cancelPost:dict];
                    [_feedsTable endUpdates];
                    [[AlertMessage sharedInstance] showMessage:NSLocalizedString(POST_CANCELLED, nil)];
                }
                else{
                    [[AlertMessage sharedInstance] showMessage:NSLocalizedString(POST_UPLOADED, nil)];
                }
            }
            else{
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(POST_UPLOADED, nil)];
            }
        }
    }
}

-(void)cancelPost:(NSDictionary *)inputParams{
    BOOL isCurrentPost = YES;
    NSMutableArray *dictionary = [[NSMutableArray alloc] initWithArray:appDelegate.postRequest];
    for(NSDictionary *dict in dictionary){
        NSDictionary *input = [dict objectForKey:@"inputparams"];
        if([[input objectForKey:@"unique_id"] isEqualToString:[inputParams objectForKey:@"unique_id"]]){
            [appDelegate.postRequest removeObject:dict];
            isCurrentPost = NO;
        }
    }
    if(isCurrentPost){
        appDelegate.postInProgress = NO;
        if([appDelegate.postRequest count] > 0){
            NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[appDelegate.postRequest objectAtIndex:0]];
            [self uploadPost:[dict objectForKey:@"inputparams"] Media:[dict objectForKey:@"medias"] feedType:[dict objectForKey:@"type"] getIndex:[[dict objectForKey:@"index"] intValue]];
            [appDelegate.postRequest removeObjectAtIndex:0];
        }
    }
}


#pragma mark YesNoPopDelegate
- (void)onYesClick{
    
    if (selectedyesNoPopUp == 1) {
        [self deleteFeedPost];
    }
    else if(selectedyesNoPopUp == 2){
        [self movePrivateFeed:movePostId postTypeId:movePostTypeId];
    }
    else if(selectedyesNoPopUp == 3){
        //Build Input Parameters
        NSString *post_owner_id = [NSString stringWithFormat:@"%@", [reportFeed objectForKey:@"post_owner_id"]];
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[reportFeed objectForKey:@"post_owner_id"] forKey:@"friend_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BLOCKFRIEND withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [blockPopUp dismiss:YES];
                //[self getFeedsList];
                [self removeBlockedUserPost:post_owner_id];
                [_feedsTable reloadDataWithAnimation];
                [[AlertMessage sharedInstance]showMessage:[response valueForKey:@"message"] withDuration:3];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
            }
        } isShowLoader:YES];
    }
}

- (void)onNoClick{
    [blockPopUp dismiss:YES];
    [yesNoPopup dismiss:YES];
}

// ------------- Delete post End  ----------------

// Click Star & Unstar
- (IBAction)Star:(id)sender
{
    NSLog(@"feeds %@", feeds);
    
    [feedsDesign addStar:self.feedsTable fromArray:feeds forControl:sender];
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender {
    
    [HELPER tapAnimationFor:sender withCallBack:^{
        
        [feedsDesign addBookmark:self.feedsTable fromArray:feeds forControl:sender];
    }];
    
}

// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedsTable];
        NSIndexPath *path = [_feedsTable indexPathForRowAtPoint:buttonPosition];
        
        if ([feeds count] > path.row) {
            
            NSString *star_post_id = [[feeds objectAtIndex:path.row] objectForKey:@"post_id"];
            if(star_post_id != nil && ![star_post_id isEqualToString:@""]){
                selectedPostIndex = (int) path.row;
                Comments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
                NSDictionary *imageInfo = [feeds objectAtIndex:path.row];
                comment.postId = star_post_id;
                comment.mediaId = [imageInfo valueForKey:@"image_id"];
                comment.postDetails = [feeds objectAtIndex:path.row];
                comment.isFromFeedsPage = @"YES";
                comment.feeds = feeds;
                [self.navigationController pushViewController:comment animated:YES];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:PERFORM_LATER];
            }
        }
    }
    else{
        [appDelegate.networkPopup show];
    }
}


// Move Private feed to Public and Friends feeds
-(void)movePrivateFeed:(NSString *)postId postTypeId:(NSString *)postTypeId
{
    [yesNoPopup dismiss:YES];
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:postId forKey:@"post_id"];
    [inputParams setValue:postTypeId forKey:@"post_type_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:MOVE_PRIVATE_FEEDS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            if ([feeds count] > (int)menuPosition.row) {
                
                [_feedsTable beginUpdates];
                [feeds removeObjectAtIndex:menuPosition.row];
                [_feedsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
                [_feedsTable endUpdates];
                [LocalStorageManager assignOfflineFeeds:response Type:[selectedFeedType intValue]]; // Get response for is user is offline to show last seen 10 feeds
                [rootViewController.publicFeeds removeAllObjects];
            }
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:NO];
}

// Get post types list
-(void)getFeedsTypesList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:0] forKey:@"post_feed_type_list"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_TYPES_LIST withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            [Util setInDefaults:response withKey:@"FeedsTypeList"];
            [self setFeedTypesList:response];
            [self setFeedType];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:NO];
}

-(void)setFeedTypesList:(NSDictionary *)response
{
    rootViewController.feedTypeList = [[response objectForKey:@"post_types"] mutableCopy];
    feedTypeList = rootViewController.feedTypeList;
    [_feedsTypesTable reloadData];
    [self changeTableViewHeight];
}

//Change the autocomplete table view height
- (void) changeTableViewHeight {
    
    CGFloat height = _feedsTypesTable.rowHeight;
    height *= feedTypeList.count;
    _feedTypeHeight.constant = height + 48;
    [_feedTypesView layoutIfNeeded];
}

- (void)getAd {
    [[GoogleAdMob sharedInstance] fetchFeedAdWithCallback:^(NSDictionary *response) {
        NSLog(@"current ad info %@", response);
        if ([[response valueForKey:@"status"] boolValue]) {
            currentAdInfo = response;
        } else {
            currentAdInfo = nil;
        }
    }];
}

// Get Feeds List
-(void)getFeedsList
{
    [self getAd];
    
    NSString *strPostId = [NSString stringWithFormat:@"%d",post_id];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:strPostId forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSString stringWithFormat:@"%d",[self teamPost]] forKey:@"team_post"];
    [inputParams setValue:feedTypeId forKey:@"post_type_id"];
    [inputParams setValue:@"0"  forKey:@"recent"];
    [inputParams setValue:@"0"  forKey:@"time_stamp"];
    [inputParams setValue:feedTypeId  forKey:@"feed_list_type_key"];
    
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_LIST withCallBack:^(NSDictionary * response) {
        
        [refreshControl endRefreshing];
        
        if([[response valueForKey:@"status"] boolValue]) {
            
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
            rootViewController.mediaBase = mediaBaseUrl;
            
            NSString *feed_list_type = [NSString stringWithFormat:@"%@",[response objectForKey:@"feed_list_type_key"]];
            
            NSLog(@"Feed list type: %@", feed_list_type);
            // check response type and slected feed type are equal
            if ([feedTypeId isEqualToString:feed_list_type]) {
                
                // If page load and Pull to to refresh -> remove all records and reload the records
                for (int i =0; i<[feeds count]; i++) {
//                    if ([[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"false"]) {
                    if (![[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"true"]) {
                        [feeds removeObjectAtIndex:i];
                        i--;
                    }
                }
                [LocalStorageManager assignOfflineFeeds:response Type:[selectedFeedType intValue]]; // Get response for is user is offline to show last seen 10 feeds
                [self removeUploadedLocalFeeds:response];
                [self alterTheMediaList:response];
                //show empty message
                [self addEmptyMessageForFeedListTable];
            }
            
        }
        else
        {
            UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
            
            if ([navigation isKindOfClass:[UINavigationController class]]) {
                
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        }
    } isShowLoader:NO];
}


//-(void)getUpdatedFeedsListWithCallBack:(CompletionBlockForFeed)completed
//{
//    [self getAd];
//
//    NSString *strPostId = [NSString stringWithFormat:@"%d",post_id];
//
//    //Build Input Parameters
//    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
//    [inputParams setValue:strPostId forKey:@"post_id"];
//    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
//    [inputParams setValue:[NSString stringWithFormat:@"%d",[self teamPost]] forKey:@"team_post"];
//    [inputParams setValue:feedTypeId forKey:@"post_type_id"];
//    [inputParams setValue:@"0"  forKey:@"recent"];
//    [inputParams setValue:@"0"  forKey:@"time_stamp"];
//    [inputParams setValue:feedTypeId  forKey:@"feed_list_type_key"];
//
//    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_LIST withCallBack:^(NSDictionary * response) {
//
//        [refreshControl endRefreshing];
//
//        if([[response valueForKey:@"status"] boolValue]) {
//
//            mediaBaseUrl = [response objectForKey:@"media_base_url"];
//            rootViewController.mediaBase = mediaBaseUrl;
//
//            NSString *feed_list_type = [NSString stringWithFormat:@"%@",[response objectForKey:@"feed_list_type_key"]];
//
//            NSLog(@"Feed list type: %@", feed_list_type);
//            // check response type and slected feed type are equal
//            if ([feedTypeId isEqualToString:feed_list_type]) {
//
//                // If page load and Pull to to refresh -> remove all records and reload the records
//                for (int i =0; i<[feeds count]; i++) {
//                    //                    if ([[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"false"]) {
//                    if (![[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"true"]) {
//                        [feeds removeObjectAtIndex:i];
//                        i--;
//                    }
//                }
//                [LocalStorageManager assignOfflineFeeds:response Type:[selectedFeedType intValue]]; // Get response for is user is offline to show last seen 10 feeds
//                [self removeUploadedLocalFeeds:response];
//                [self alterTheMediaList:response];
//                //show empty message
//                [self addEmptyMessageForFeedListTable];
//            }
//
//        }
//        else
//        {
//            UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
//
//            if ([navigation isKindOfClass:[UINavigationController class]]) {
//
//                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
//            }
//        }
//        completed(YES);
//    } isShowLoader:NO];
//
//}


//Append the media url with base
- (void)alterTheMediaList:(NSDictionary *)response{
    
    BOOL adAdded = NO;
    
    for (int i=0; i < [[response objectForKey:@"feed_list"] count]; i++) {
        NSMutableDictionary *dict = [[[response objectForKey:@"feed_list"] objectAtIndex:i] mutableCopy];
        
        if (feed_type == 6 && !adAdded && i == 2 && currentAdInfo != nil) {
            NSMutableDictionary *adDict = [[NSMutableDictionary alloc] init];
            
            NSDictionary *details = [currentAdInfo valueForKey:@"ad_details"];
            
            [adDict setValue:[NSNumber numberWithBool:YES] forKey:@"is_ad"];
            [adDict setValue:[details valueForKey:@"image_size"] forKey:@"media_dimension"];
            [adDict setValue:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[details valueForKey:@"image_url"]] forKey: @"ad_image"];
            [adDict setValue:[currentAdInfo valueForKey:@"ad_link"] forKey:@"ad_link"];
            [feeds addObject:adDict];
            adAdded = YES;
        }
        
        [dict setValue:@"false" forKey:@"is_local"];
        [dict setValue:@"true" forKey:@"is_upload"];
        [dict setValue:@"false" forKey:@"isAnimate"];
        [dict setValue:@"true" forKey:@"isEnabled"];
        
        [dict setValue:@"" forKey:@"task_identifier"];
        [dict setValue:@"" forKey:@"task"];
        [dict setValue:@"false" forKey:@"is_resized"];
        [dict setValue:[NSNumber numberWithFloat:0] forKey:@"progress"];
        
        int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[dict valueForKey:@"post_id"] from:feeds type:1];
        
        if (![[dict objectForKey:@"is_team_activity"] boolValue] && postIndex == -1) {
            
            if (![[dict objectForKey:@"is_team_activity"] boolValue]) {
                
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
            }
            
            // Add response array to the selected feed type
            [feeds addObject:dict];
        }
        else if([[dict objectForKey:@"is_team_activity"] boolValue]){
            
            // Add response array to the selected feed type
            [feeds addObject:dict];
        }
    }
    
    if ([[response objectForKey:@"feed_list"] count] != 0) {
        NSLog(@"alterTheMediaList reloadData");
       // [_feedsTable reloadDataWithAnimation];
        
        [_feedsTable reloadData];
    }
    
}

-(void)removeUploadedLocalFeeds:(NSDictionary *)response
{
    
    for (int i=0; i<[feeds count]; i++) {
        
        if ([[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"true"]) {
            
            NSMutableDictionary *localInputParams = [[feeds objectAtIndex:i] objectForKey:@"new_post"]; // [indexValues objectForKey:@"new_post"];
            NSString *localUniqueId = [localInputParams objectForKey:@"unique_id"];
            
            for (int j=0; j< [[response objectForKey:@"feed_list"] count]; j++) {
                NSMutableDictionary *dict = [[[response objectForKey:@"feed_list"] objectAtIndex:j] mutableCopy];
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

-(int)teamPost
{
    if (feed_type == 1 || feed_type == 2 || feed_type == 6) {
        return 0;
    }
    
    return 1;
}

- (void)addEmptyMessageForFeedListTable{
    
    if ([selectedFeedType isEqualToString:@"1"] && [feeds count] == 0) {
        [Util addEmptyMessageToTable:self.feedsTable withMessage:NO_FRIENDS_FEEDS withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
    }
    else if ([selectedFeedType isEqualToString:@"2"] && [feeds count] == 0) {
        [Util addEmptyMessageToTable:self.feedsTable withMessage:NO_PRIVATE_FEEDS withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
    }
    else if (([selectedFeedType isEqualToString:@"3"] || [selectedFeedType isEqualToString:@"4"] ) && [feeds count] == 0) {
        [Util addEmptyMessageToTable:self.feedsTable withMessage:NO_TEAM_FEEDS withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
    }
    else if ([selectedFeedType isEqualToString:@"6"]&& [feeds count] == 0) {
        [Util addEmptyMessageToTable:self.feedsTable withMessage:NO_POPULAR_PUBLIC_FEEDS withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
    }
    else{
        [Util addEmptyMessageToTable:self.feedsTable withMessage:@"" withColor:[UIColor blackColor]];
    }
    
}

// Global Feed list cell height

-(CGFloat)cellHeight:(NSMutableDictionary *)data
{
    float content_height = 0.0;
    NSString *post_content = [data objectForKey:@"post_content"];
    
    CGSize size = [self findHeightForText:post_content havingWidth:320 andFont:[UIFont fontWithName:@"CenturyGothic" size:14]];
    
    if (size.height > 50) {
        content_height = size.height;
    }
    
    if([[data objectForKey:@"image_present"] boolValue] || [[data objectForKey:@"video_present"] boolValue]){
        if ([[data objectForKey:@"check_in_details"] count] == 0) {
            return 340.0f + content_height;
        }
        return 380.0f + content_height;
    }
    else
    {
        if ([[data objectForKey:@"check_in_details"] count] == 0) {
            return 180.0f + content_height;
        }
    }
    return 220.0f + content_height;
    
}

- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (text) {
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size;
}

// New Post feeds
-(void)postFeeds
{
    rootViewController = [[self.navigationController viewControllers] firstObject];
    
    // Local public feeds list
    if ([rootViewController.publicFeeds count] != 0) {
        
        for (int i=0; i<[rootViewController.publicFeeds count]; i++) {
            NSMutableDictionary *indexValues = [rootViewController.publicFeeds objectAtIndex:i];
            NSMutableArray *medias = [indexValues objectForKey:@"is_media"];
            if ([[indexValues objectForKey:@"is_upload"] isEqualToString:@"false"] && [[indexValues objectForKey:@"is_local"] isEqualToString:@"true"])
            {
                NSMutableDictionary *inputParams = [indexValues objectForKey:@"new_post"];
                
                // After completion of new post
                [self postNewfeeds:inputParams Media:medias feedType:@"1" getIndex:i];
                
                // Change the is_upload status while uploading to server
                [[rootViewController.publicFeeds objectAtIndex:i]setObject:@"true" forKey:@"is_upload"];
            }
        }
    }
    
    // Local private feeds list
    if ([rootViewController.privateFeeds count] != 0) {
        
        for (int i=0; i<[rootViewController.privateFeeds count]; i++) {
            NSMutableDictionary *indexValues = [rootViewController.privateFeeds objectAtIndex:i];
            NSMutableArray *medias = [indexValues objectForKey:@"is_media"];
            if ([[indexValues objectForKey:@"is_upload"] isEqualToString:@"false"] && [[indexValues objectForKey:@"is_local"] isEqualToString:@"true"])
            {
                NSMutableDictionary *inputParams = [indexValues objectForKey:@"new_post"];
                
                // New Post
                [self postNewfeeds:inputParams Media:medias feedType:@"2" getIndex:i];
                
                // Change the is_upload status while uploading to server
                [[rootViewController.privateFeeds objectAtIndex:i]setObject:@"true" forKey:@"is_upload"];
            }
        }
    }
    
    // Local team A feeds list
    if ([rootViewController.teamAFeeds count] != 0) {
        
        for (int i=0; i<[rootViewController.teamAFeeds count]; i++) {
            NSMutableDictionary *indexValues = [rootViewController.teamAFeeds objectAtIndex:i];
            NSMutableArray *medias = [indexValues objectForKey:@"is_media"];
            if ([[indexValues objectForKey:@"is_upload"] isEqualToString:@"false"] && [[indexValues objectForKey:@"is_local"] isEqualToString:@"true"])
            {
                NSMutableDictionary *inputParams = [indexValues objectForKey:@"new_post"];
                
                // New Post
                [self postNewfeeds:inputParams Media:medias feedType:@"3" getIndex:i];
                
                // Change the is_upload status while uploading to server
                [[rootViewController.teamAFeeds objectAtIndex:i]setObject:@"true" forKey:@"is_upload"];
            }
        }
    }
    
    // Local team B feeds list
    if ([rootViewController.teamBFeeds count] != 0) {
        
        for (int i=0; i<[rootViewController.teamBFeeds count]; i++) {
            NSMutableDictionary *indexValues = [rootViewController.teamBFeeds objectAtIndex:i];
            NSMutableArray *medias = [indexValues objectForKey:@"is_media"];
            if ([[indexValues objectForKey:@"is_upload"] isEqualToString:@"false"] && [[indexValues objectForKey:@"is_local"] isEqualToString:@"true"])
            {
                NSMutableDictionary *inputParams = [indexValues objectForKey:@"new_post"];
                
                // New Post
                [self postNewfeeds:inputParams Media:medias feedType:@"4" getIndex:i];
                
                // Change the is_upload status while uploading to server
                [[rootViewController.teamBFeeds objectAtIndex:i]setObject:@"true" forKey:@"is_upload"];
            }
        }
    }
    
}

// API call for new post
-(void)postNewfeeds:(NSMutableDictionary *)inputparams Media:(NSMutableArray *)medias feedType:(NSString *)type getIndex:(int)index
{
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [inputparams setObject:UUID forKey:@"unique_id"];
    
    if ([feeds count] != 0) {
        // while new post tableview scroll to top
        NSIndexPath *scrollindex = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.feedsTable scrollToRowAtIndexPath:scrollindex atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    //Check is the video request
    //If so, compress the video, else send the request
    if ([medias count] > 0 && ![[[medias objectAtIndex:0] valueForKey:@"isCaptured"] boolValue] && ![[[medias objectAtIndex:0] valueForKey:@"mediaType"] boolValue]) {
        NSMutableDictionary *media = [medias objectAtIndex:0];
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        NSNumber *mediaSize = [config objectForKey:@"default_video_size"];
//        MBProgressHUD *loader = [Util showLoading];
        
        // Using Photos library
        PHAsset *asset = [media valueForKey:@"asset"];
        if (asset != nil) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
//            options.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
            options.deliveryMode = PHVideoRequestOptionsVersionCurrent;
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
                if (asset != nil) {
                    NSURL *url = (NSURL *)[(AVURLAsset *)asset URL];
                    [Util compressVideo:url withCallback:^(NSURL * outputURL) {
                        NSData *mediaData = [NSData dataWithContentsOfURL:outputURL];
                        NSLog(@"Video compressed %ld url: %@", [mediaData length], outputURL);
                        [media setObject:[outputURL absoluteString] forKey:@"mediaUrl"];
                        [media setObject:mediaData forKey:@"assetData"];
                        
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [loader hide:YES];
//                        });
                        
                        if (![self isMediaPostCancel:[inputparams objectForKey:@"unique_id"]]) {
                            [self uploadPost:inputparams Media:medias feedType:type getIndex:index];
                        }
                    }];
                } else {
                    NSLog(@"No Asset %@", info);
                }
            }];
        }

    // Captured media is a url
    } else if ([medias count] > 0 && [[[medias objectAtIndex:0] valueForKey:@"isCaptured"] boolValue] && ![[[medias objectAtIndex:0] valueForKey:@"mediaType"] boolValue]) {
        NSMutableDictionary *media = [medias objectAtIndex:0];
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        NSNumber *mediaSize = [config objectForKey:@"default_video_size"];
//        MBProgressHUD *loader = [Util showLoading];
        
//        NSURL *url = [media valueForKey:@"mediaData"];
        NSURL *url = [NSURL URLWithString:[media valueForKey:@"mediaUrl"]];
        NSLog(@"NSURL %@", url);
        [Util compressVideo:url withCallback:^(NSURL *outputURL) {
//            [loader hide:YES];
            
            NSData *assetData = [NSData dataWithContentsOfURL:outputURL];
            [media setObject:assetData forKey:@"assetData"];
            [media setObject:[outputURL absoluteString] forKey:@"mediaUrl"];
            if (![self isMediaPostCancel:[inputparams objectForKey:@"unique_id"]]) {
                [self uploadPost:inputparams Media:medias feedType:type getIndex:index];
            }
        }];
    }
    else{
        [self uploadPost:inputparams Media:medias feedType:type getIndex:index];
    }
    
    //Show progress
//    UIProgressView *progressView = [self getProgressViewAtIndex:0];
//    if ([medias count] > 0) {
//        [Util setProgressWithAnimation:progressView withDuration:15];
//    }
}
-(BOOL)isMediaPostCancel :(NSString *)uniuqeId
{
    for (int i=0; i<[rootViewController.uploadCancelArray count]; i++) {
        
        if ([uniuqeId isEqualToString:[rootViewController.uploadCancelArray objectAtIndex:i]]) {
            [rootViewController.uploadCancelArray removeObjectAtIndex:i];
            i--;
            return TRUE;
        }
    }
    return false;
}

- (void)uploadPost:(NSMutableDictionary *)inputparams Media:(NSMutableArray *)medias feedType:(NSString *)type getIndex:(int)index{
    
    if(!appDelegate.postInProgress){
        appDelegate.postInProgress = YES;
        NSLog(@"post format %@", inputparams);
        NSURLSessionUploadTask *task = [[Util sharedInstance] sendHTTPPostRequestWithMultiPart:inputparams withMultiPart:medias withRequestUrl:POST_CREATE withImage:nil withCallBack:^(NSDictionary  *response) {
            NSLog(@"sendHTTPPostRequestWithMultiPart complete %@", response);
            appDelegate.postInProgress = NO;
            if([[response valueForKey:@"status"] boolValue]){
                // After completion of post local feeds should remove from local and reload the "getNewFeeds" api.
                [self getNewFeeds];
            }
            else if([[response valueForKey:@"error"] isEqualToString:@"time_out"])
            {
                NSLog(@"Posting failed %d", index);
                // Time Out Error
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(TRY_AGAIN_STRING, nil)];
//                [self getNewFeeds];
                
                // Change the is_upload status while uploading to server
//                [[rootViewController.privateFeeds objectAtIndex:i]setObject:@"true" forKey:@"is_upload"];
                
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setObject:inputparams forKey:@"inputparams"];
                [dictionary setObject:medias forKey:@"medias"];
                [dictionary setObject:type forKey:@"type"];
                [dictionary setObject:[NSNumber numberWithInt:index] forKey:@"index"];
                [appDelegate.postRequest addObject:dictionary];
                
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
            if([appDelegate.postRequest count] > 0){
                NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[appDelegate.postRequest objectAtIndex:0]];
                [self uploadPost:[dict objectForKey:@"inputparams"] Media:[dict objectForKey:@"medias"] feedType:[dict objectForKey:@"type"] getIndex:[[dict objectForKey:@"index"] intValue]];
                [appDelegate.postRequest removeObjectAtIndex:0];
            }
        } onProgressView:nil isFromBuzzardRun:FALSE];
        
        NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier];
        
        if ([type intValue] == 1) {
            [[rootViewController.publicFeeds objectAtIndex:index] setValue:taskIdentifier forKey:@"task_identifier"];
            [[rootViewController.publicFeeds objectAtIndex:index] setValue:task forKey:@"task"];
        }
        else if ([type intValue] == 2) {
            [[rootViewController.privateFeeds objectAtIndex:index] setValue:taskIdentifier forKey:@"task_identifier"];
            [[rootViewController.privateFeeds objectAtIndex:index] setValue:task forKey:@"task"];
        }
        else if ([type intValue] == 3) {
            [[rootViewController.teamAFeeds objectAtIndex:index] setValue:taskIdentifier forKey:@"task_identifier"];
            [[rootViewController.teamAFeeds objectAtIndex:index] setValue:task forKey:@"task"];
        }
        else if ([type intValue] == 4) {
            [[rootViewController.teamBFeeds objectAtIndex:index] setValue:taskIdentifier forKey:@"task_identifier"];
            [[rootViewController.teamBFeeds objectAtIndex:index] setValue:task forKey:@"task"];
        }
        
        // Showing progrss while uploading feeds
        [self registerForUploadRequest];
    }
    else{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:inputparams forKey:@"inputparams"];
        [dictionary setObject:medias forKey:@"medias"];
        [dictionary setObject:type forKey:@"type"];
        [dictionary setObject:[NSNumber numberWithInt:index] forKey:@"index"];
        [appDelegate.postRequest addObject:dictionary];
    }
}

// Register for new Feed upload Request
-(void)registerForUploadRequest
{
    [[Util sharedInstance].dataTaskManager setTaskDidSendBodyDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            double percentDone = (totalBytesSent / (totalBytesExpectedToSend * 1.0f));
            
            NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier];
            
            // If current feed type is uploading local feeds show progrss bar and trigger the pull to refresh
            int index = [self getMatchedObjectIndex:feeds valuetoMatch:taskIdentifier];
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            FeedCell *cell = [self.feedsTable cellForRowAtIndexPath:path];
            
            [cell.activityIndicator setHidden:YES];
            
//            if (cell.isVideo) {
//                [cell.playIcon setHidden:NO];
//            }
            
            if (index != -1) {
                
                [[feeds objectAtIndex:index] setObject:[NSNumber numberWithFloat:percentDone] forKey:@"progress"];
                if (percentDone == 1) {
                    NSLog(@"UPLOAD 100");
//                    cell.dimView.hidden = YES;
                    // Done uploading, show infinite spinner until call returns
//                    cell.spinnerProgressView.hidden = YES;
//                    cell.spinnerView.hidden = NO;
//                    [cell.spinnerView startAnimating];
                    
                    [[feeds objectAtIndex:index] setObject:@"completed" forKey:@"is_upload"];
                    [_feedsTable reloadDataWithAnimation];
                }
                else{
//                    UIProgressView *progressView = [self getProgressViewAtIndex:index];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (percentDone > .15 )
                        {
                            cell.spinnerProgressView.value = percentDone;
//                            progressView.progress =  percentDone;
                        }
                        cell.spinnerView.hidden = YES;
                        [cell.spinnerView stopAnimating];
                        cell.spinnerProgressView.hidden = NO;
                        cell.dimView.hidden = NO;
                    });
                }
            }
            else
            {
                cell.dimView.hidden = YES;
            }
            
            // If having local feeds, after upload complete remove from publicfeed array
            int publicIndex = [self getMatchedObjectIndex:rootViewController.publicFeeds valuetoMatch:taskIdentifier];
            if (publicIndex != -1 && percentDone == 1 && feed_type != 1)
            {
                [rootViewController.publicFeeds removeObjectAtIndex:publicIndex];
            }
            
            // If having local feeds, after upload complete remove from privatefeed array
            int privateIndex = [self getMatchedObjectIndex:rootViewController.privateFeeds valuetoMatch:taskIdentifier];
            if (privateIndex != -1 && percentDone == 1 && feed_type != 2)
            {
                [rootViewController.privateFeeds removeObjectAtIndex:privateIndex];
            }
            
            // If having local feeds, after upload complete remove from teamAfeed array
            int teamAIndex = [self getMatchedObjectIndex:rootViewController.teamAFeeds valuetoMatch:taskIdentifier];
            if (teamAIndex != -1 && percentDone == 1 && feed_type != [[[feedTypeList objectAtIndex:2] objectForKey:@"feed_type"] intValue])
            {
                [rootViewController.teamAFeeds removeObjectAtIndex:teamAIndex];
            }
            
            
            // If having local feeds, after upload complete remove from teamBfeed array
            int teamBIndex = [self getMatchedObjectIndex:rootViewController.teamBFeeds valuetoMatch:taskIdentifier];
            if (teamBIndex != -1 && percentDone == 1 && feed_type != [[[feedTypeList objectAtIndex:3] objectForKey:@"feed_type"] intValue])
            {
                [rootViewController.teamBFeeds removeObjectAtIndex:teamBIndex];
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
    FeedCell *cell = [self.feedsTable cellForRowAtIndexPath:path];
    cell.progressView.hidden = NO;
    return cell.progressView;
}

// Assign Feeds list for selected feed type
-(void)getFeedValuesFromSelectedType
{
    feeds = [self getCurrentArray];
        
    if ([feeds count] == 0)
    {
        [self getFeedsList];
        NSLog(@"FEED TYPE %@", selectedFeedType);
        [self getOldFeedList];
    } else {
        [self getNewFeeds];
    }
    
    [self addEmptyMessageForFeedListTable];
}

-(NSMutableArray *)getCurrentArray
{
    if ([selectedFeedType intValue] == 1) {
        return rootViewController.publicFeeds ;
    }
    else if ([selectedFeedType intValue] == 2) {
        return rootViewController.privateFeeds;
    }
    else if ([selectedFeedType intValue] == 3) {
        return  rootViewController.teamAFeeds;
    }
    else if ([selectedFeedType intValue] == 4) {
        return  rootViewController.teamBFeeds;
    }
    else if ([selectedFeedType intValue] == 6) {
        return  rootViewController.popularFeeds;
    }
    
    return nil;
}

-(void)getOldFeedList
{
    NSDictionary *response ;
    if ([selectedFeedType intValue] == 1) {
        response = [[NSUserDefaults standardUserDefaults] objectForKey:@"PublicFeedsList"];
    }
    else if ([selectedFeedType intValue] == 2) {
        response = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateFeedsList"];
    }
    else if ([selectedFeedType intValue] == 3) {
        response = [[NSUserDefaults standardUserDefaults] objectForKey:@"TeamAFeedsList"];
    }
    else if ([selectedFeedType intValue] == 4) {
        response = [[NSUserDefaults standardUserDefaults] objectForKey:@"TeamBFeedsList"];
    }
    else if ([selectedFeedType intValue] == 6) {
        response = [[NSUserDefaults standardUserDefaults] objectForKey:@"PopularFeedsList"];
    }
    if (response != nil) {
        mediaBaseUrl = [response objectForKey:@"media_base_url"];
        rootViewController.mediaBase = mediaBaseUrl;
        [self alterTheMediaList:response];
    }
    NSLog(@"Cached feed reload data");
    [_feedsTable reloadDataWithAnimation];
}

-(void)updateLocalStorage
{
    NSMutableArray *localArray =[[NSMutableArray alloc] init];
    if ([selectedFeedType intValue] == 1 ) {
        localArray = rootViewController.publicFeeds;
    }
    else if ([selectedFeedType intValue] == 2) {
        localArray = rootViewController.privateFeeds;
    }
    else if ([selectedFeedType intValue] == 3) {
        localArray = rootViewController.teamAFeeds;
    }
    else if ([selectedFeedType intValue] == 4) {
        localArray = rootViewController.teamBFeeds;
    }
    else if ([selectedFeedType intValue] == 6) {
        localArray = rootViewController.popularFeeds;
    }
    
    [LocalStorageManager localStorage:@"FEED" Response:[localArray mutableCopy] feedType:[selectedFeedType intValue]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [feedsDesign playVideoConditionally];
//    [feedsDesign checkWhichVideoToEnable:_feedsTable];
    [feedsDesign stopAllVideos];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    [feedsDesign checkWhichVideoToEnable:_feedsTable];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [feedsDesign checkWhichVideoToEnable:_feedsTable];
}

-(void)removeBlockedUserPost: (NSString *)block_user_id
{
    for (int i=0; i<[feeds count]; i++) {
        NSString *post_owner_id = [[feeds objectAtIndex:i] valueForKey:@"post_owner_id"];
        if([block_user_id isEqualToString:post_owner_id])
        {
            [feeds removeObjectAtIndex:i];
            i--;
        }
    }
}

// Keep maximum 10 records while switch feeds

-(void) removeOldFeeds
{
    bool remove = [[[NSUserDefaults standardUserDefaults] objectForKey:@"keep_more_feeds"] boolValue];
    if (remove) {
        NSMutableArray *currentArray = [self getCurrentArray];
        for (int i= (int)[currentArray count]; i > 10; i--) {
            [currentArray removeObjectAtIndex:(i-1)];
        }
    }
}

// Reload Table View for Increase view count
- (void) reloadTableView:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"ViewCountNotification"]){
        NSLog (@"Successfully received the test notification!");
        newFeedsTimer = [NSTimer scheduledTimerWithTimeInterval:80 target:self selector:@selector(getFeedsList) userInfo:nil repeats: YES];
//        [self getFeedsList];
    }
}

// Mute/Unmute Pressed

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
        // set Is From Feeds True
        feedsDesign.gBoolIsFromFeeds = YES;
        feedsDesign.isVolumeClicked = YES;
        //                feedsDesign.delegate = self;
        [feedsDesign designTheContainerView:cell forFeedData:[feeds objectAtIndex:sender.tag] mediaBase:mediaBaseUrl forDelegate:self tableView:_feedsTable];
    }
}
@end
