//
//  BookmarkViewController.m
//  Varial
//
//  Created by dreams on 11/01/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "BookmarkViewController.h"
#import "ViewController.h"
#import "HeaderView.h"
#import "FeedsDesign.h"
#import "FeedCell.h"
#import "InviteFriends.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <ResponsiveLabel/ResponsiveLabel.h>

@interface BookmarkViewController () <UITableViewDelegate,UITableViewDataSource,HeaderViewDelegate,MLKMenuPopoverDelegate>
{
    FeedsDesign *feedsDesign;
    BOOL feedsLoading, myBoolIsMutePressed;;
    NSDictionary *reportFeed;
    int selectedyesNoPopUp, pageNumber;;
    NSString *movePostId, *movePostTypeId;
    YesNoPopup *popupView;
    NSIndexPath *menuPosition;
    KLCPopup *yesNoPopup;
    BOOL isDelete;
    KLCPopup *blockPopUp;
    AppDelegate *appDelegate;
    ViewController *rootViewController;
    Menu *menu;
    NSArray *reportType;
}

@property(nonatomic,strong) NSMutableArray *feedList;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic,strong) NSString *feedImageUrl;

// Menu View
@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic,strong) MLKMenuPopover *reportPopover;

@end

@implementation BookmarkViewController

@synthesize feedList, feedImageUrl;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpUI];;
    [self setUpModel];
    [self loadModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [feedsDesign stopAllVideos];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpUI {
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    _headerView.delegate = self;
    [_headerView setBackHidden:NO];
    
    if ([self.gStrSource isEqualToString:@"Images"]) {
        [_headerView setHeader:NSLocalizedString(IMAGE, nil)];
    }
    
    else if ([self.gStrSource isEqualToString:@"Videos"]) {
        [_headerView setHeader:NSLocalizedString(VIDEO, nil)];
    }
    
    else {
        
        [_headerView setHeader:NSLocalizedString(BOOKMARK, nil)];
    }
    
    
    [_headerView.logo setHidden:YES];
    
    [self.myTblView registerNib:[UINib nibWithNibName:NSStringFromClass([FeedCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FeedCell class])];
    
    self.myTblView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.myTblView.tableFooterView = [UIView new];
    
    self.myTblView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    feedsDesign = [[FeedsDesign alloc] init];
    
    // set page number to 0
    pageNumber = 0;
}

- (void)setUpModel {
    
    feedList = [NSMutableArray new];
}

- (void)loadModel {
    
    [self setInfiniteScrollForTableView];
    [self getFeedsList];
}

# pragma mark - UITableView Delegate & datasource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return feedList.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FeedCell *fcell;
    
    static NSString *cellIdentifier = nil;
    cellIdentifier= ([[[feedList objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feedList objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"FeedCell" : @"MessagesCell";
    fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (fcell == nil)
    {
        fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    fcell.backgroundColor = [UIColor clearColor];
    
    // Mute Button Actions
    [fcell.gBtnMuteUnMute addTarget:self action:@selector(muteUnmutePressed:) forControlEvents:UIControlEventTouchUpInside];
    fcell.gBtnMuteUnMute.tag = indexPath.row;
    
    feedsDesign.feeds = feedList;
    feedsDesign.feedTable = tableView;
    feedsDesign.mediaBaseUrl= feedImageUrl;
    feedsDesign.viewController = self;
    feedsDesign.isVolumeClicked = NO;
//    feedsDesign.isNoNeedNameRedirection = TRUE;
//    feedsDesign.isNoNeedProfileRedirection = TRUE;
    
    fcell.btnBookmark.tag = indexPath.row;
    
    [feedsDesign designTheContainerView:fcell forFeedData:[feedList objectAtIndex:indexPath.row] mediaBase:feedImageUrl forDelegate:self tableView:tableView];
    fcell.shareView.hidden = YES;
    fcell.shareViewHeightConstraint.constant = 0.0;
    NSString * isShare = [feedList[indexPath.row][@"is_share"] stringValue];
    if ([isShare isEqualToString:@"1"]) {
        fcell.shareView.hidden = NO;
        fcell.shareViewHeightConstraint.constant = 70.0;
        NSString * sharedPerson = feedList[indexPath.row][@"share_details"][@"name"];
//        NSString * postOwnerName = feedList[indexPath.row][@"name"];
        NSString * postOwnerName = [NSString stringWithFormat:@"%@'s ",feedList[indexPath.row][@"name"]];
        
        NSString * sharedPersonImgUrl = feedList[indexPath.row][@"share_details"][@"profile_image"][@"profile_image"];
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
        [fcell.sharedTime setText:[Util timeStamp: [feedList[indexPath.row][@"share_details"][@"share_time"] intValue]]];
    } else {
        fcell.shareView.hidden = YES;
        fcell.shareViewHeightConstraint.constant = 0.0;
    }
    
    return fcell;
}

//-(void)doActionForSharedPerson:(id)sender{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTblView];
//    NSIndexPath *path = [self.myTblView indexPathForRowAtPoint:buttonPosition];
//    [self goToSharedPersonProfile:path isSharedPersonName:YES];
//}
//
//-(void)doActionForShareOwner:(id)sender{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTblView];
//    NSIndexPath *path = [self.myTblView indexPathForRowAtPoint:buttonPosition];
//    [self goToSharedPersonProfile:path isSharedPersonName:NO];
//}

-(void)goToSharedPersonProfile:(NSIndexPath *)indexpath isSharedPersonName:(BOOL)isSharedPerson{
    if ([feedList count] > indexpath.row) {
        if (![[[feedList objectAtIndex:indexpath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            if (isSharedPerson) {
                profile.friendId = [feedList objectAtIndex:indexpath.row][@"share_details"][@"player_id"];
                profile.friendName = [feedList objectAtIndex:indexpath.row][@"share_details"][@"name"];
            } else {
                profile.friendId = [feedList objectAtIndex:indexpath.row][@"post_owner_id"];
                profile.friendName = [feedList objectAtIndex:indexpath.row][@"name"];
            }
            [self.navigationController pushViewController:profile animated:YES];
        }
    }
}

- (void)reportButtonAction:(UITapGestureRecognizer *)tapRecognizer {
    
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.myTblView];
        NSIndexPath *indexPath = [self.myTblView indexPathForRowAtPoint:buttonPosition];
        reportFeed = [feedList objectAtIndex:indexPath.row];
        
        [self.reportPopover dismissMenuPopover];
        
        self.reportPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - self.myTblView.contentOffset.y, 140, 84) menuItems:@[NSLocalizedString(REPORT_THE_POST,nil),NSLocalizedString(BLOCK_THE_USER, nil)]];
        self.reportPopover.menuPopoverDelegate = self;
        self.reportPopover.tag = 101;
        [self.reportPopover showInView:self.view];
    }
}

-(void)sharedReportButtonAction:(UITapGestureRecognizer *)tapRecognizer{
    [self reportButtonAction:tapRecognizer];
}

#pragma mark -  method for MLKMenuPopover
- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex {
    
    [self.menuPopover dismissMenuPopover];
    
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
                [self deletePost];
            }
        }
    } else {
        [appDelegate.networkPopup show];
    }
}


#pragma mark - Attributed Label delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
//    NSString *tag = [[label.text substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
//    [searchViewController searchFor:tag];
//    [self.navigationController pushViewController:searchViewController animated:YES];
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
}

//Common Delegate for TTTAttributed Label
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    //    if (_profileView.name == label) {
    //        [self showEditNamePopup];
    //    }
    //    else
    if (url != nil && ![[url absoluteString] isEqualToString:@""]){
        //Open Url
        [[UIApplication sharedApplication] openURL:url];
    }
    else if (label.tag != 2) {
        
        CGPoint position = [label convertPoint:CGPointZero toView:self.myTblView];
        NSIndexPath *indexPath = [self.myTblView indexPathForRowAtPoint:position];
        NSMutableDictionary *feed = [feedList objectAtIndex:indexPath.row];
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[feed valueForKey:@"post_id"] forKey:@"post_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [feed setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                [feed setValue:[NSNumber numberWithBool:FALSE] forKey:@"continue_reading_flag"];
                [self.myTblView reloadData];
            }else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        } isShowLoader:NO];
    }
}

//- (void)moveToPostDetails:(UIImageView *)imageView index:(int)index{
//    _needToReload = 0;
//    [[FeedsDesign sharedInstance] moveToPostDetails:imageView index:index fromTable:_profileTable fromController:self fromSource:feedList mediaBase:feedImageUrl];
//}

-(void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.myTblView];
    NSIndexPath *indexPath = [self.myTblView indexPathForRowAtPoint:buttonPosition];
    menuPosition = indexPath;
    
    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - self.myTblView.contentOffset.y + self.myTblView.frame.origin.y, 140, 90) menuItems:
                        @[NSLocalizedString(EDIT_MENU,nil),
                          NSLocalizedString(DELETE_MENU,nil)]];
    self.menuPopover.menuPopoverDelegate = self;
    self.menuPopover.tag = 100;
    [self.menuPopover showInView:self.view];
    
    
    //    UIMenuController *menucontroller=[UIMenuController sharedMenuController];
    //    UIMenuItem *MenuitemA=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) action:@selector(DeletePost:)];
    //    [menucontroller setMenuItems:[NSArray arrayWithObjects:MenuitemA,nil]];
    //    //menucontroller.arrowDirection = UIMenuControllerArrowDown;
    //
    //
    //    menuPosition = indexPath;
    //    //It's mandatory
    //    [self becomeFirstResponder];
    //    //It's also mandatory ...remeber we've added a mehod on view class
    //    if([self canBecomeFirstResponder])
    //    {
    //        [menucontroller setTargetRect:CGRectMake(10,10, 0, 200) inView:tapRecognizer.view];
    //        [menucontroller setMenuVisible:YES animated:YES];
    //    }
}

-(void)ShowSharedMenu:(UITapGestureRecognizer *)tapRecognizer
{
    [self ShowMenu:tapRecognizer];
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

// ------------- Edit post Start -----------------

- (void)editPost {
    if([[Util sharedInstance] getNetWorkStatus])
    {
        if ([feedList count] > menuPosition.row) {
            
            NSMutableDictionary *postInfo = [feedList objectAtIndex:menuPosition.row];
            
            EditPostViewController *editPostController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"EditViewController"];
            
            [editPostController setPostInfo:postInfo];
            
            [self.navigationController presentViewController:editPostController animated:YES completion:nil];
        }
    }
}

// ------------- Delete post Start ---------------

- (void)deletePost {
    
    [yesNoPopup show];
}

- (void)DeletePost:(UIMenuController *)sender {
    
    [yesNoPopup show];
}

- (void)deleteFeedPost {
    
    [yesNoPopup dismiss:YES];
    
    NSString *strPostId = [NSString stringWithFormat:@"%@",[[feedList objectAtIndex:menuPosition.row] objectForKey:@"post_id"]];
    
    [self.myTblView beginUpdates];
    [feedList removeObjectAtIndex:menuPosition.row];
    [self.myTblView deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
    [self.myTblView endUpdates];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:strPostId  forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DELETE_POST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
        
    } isShowLoader:NO];
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
    [feedsDesign addStar:self.myTblView fromArray:feedList forControl:sender];
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender
{
    if([self.gStrSource isEqualToString:@""]) {
        
        [HELPER tapAnimationFor:sender withCallBack:^{
            
            [feedsDesign addBookmark:self.myTblView fromArray:feedList forControl:sender];
            
            [feedList removeObjectAtIndex:sender.tag];
            
            [self.myTblView reloadData];
            [self addEmptyMessageForProfileTable];
        }];
    }
    
    else {
        
        [HELPER tapAnimationFor:sender withCallBack:^{
            
            [feedsDesign addBookmark:self.myTblView fromArray:feedList forControl:sender];
        }];
    }
}

// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTblView];
        NSIndexPath *path = [self.myTblView indexPathForRowAtPoint:buttonPosition];
        NSString *star_post_id = [[feedList objectAtIndex:path.row] objectForKey:@"post_id"];
        selectedPostIndex = (int) path.row;
        //Comments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        Comments *comment = [storyboard instantiateViewControllerWithIdentifier:@"Comments"];
        
        //UINavigationController *aNavi = [[UINavigationController alloc]initWithRootViewController:insuranceController];
        //SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];

        NSDictionary *imageInfo = [feedList objectAtIndex:path.row];
        comment.postId = star_post_id;
        comment.mediaId = [imageInfo valueForKey:@"image_id"];
        comment.postDetails = [feedList objectAtIndex:path.row];
        [self.navigationController pushViewController:comment animated:YES];
    }
    else{
        [appDelegate.networkPopup show];
    }
}

# pragma mark - Get bookmark details -

// Get Feeds List
- (void)getFeedsList {
    
    feedsLoading = YES;
    
    //[self startLoading];
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:pageNumber] forKey:@"page_number"];
    [inputParams setValue:@"10" forKey:@"page_limit"];
    if([self.gStrFriendId isEqualToString:@""]){
        [inputParams setValue:@"" forKey:@"friend_id"];
    }
    else {
        [inputParams setValue:self.gStrFriendId forKey:@"friend_id"];
    }
    
    [inputParams setValue:@"0" forKey:@"recent"];
    [inputParams setValue:self.gStrSource forKey:@"source"];
    if ([feedList count] == 0) {
        [inputParams setValue:@"0" forKey:@"post_id"];
    }
    else{
        [inputParams setValue:[[feedList lastObject] valueForKey:@"post_id"] forKey:@"post_id"];
    }
    
    //    [self.profileTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:BOOKMARK_LIST withCallBack:^(NSDictionary * response)
     {
         feedsLoading = NO;
        // [self stopLoading];
         [self.myTblView.infiniteScrollingView stopAnimating];
         if([[response valueForKey:@"status"] boolValue]){
             
             if (feedImageUrl == nil) {
                 feedImageUrl = [response objectForKey:@"media_base_url"];
             }
             
             pageNumber = [[response objectForKey:@"page_number"] intValue];
             feedImageUrl = @"https://dqloq8l38fi51.cloudfront.net";
             [self alterTheMediaList:response];
             [self addEmptyMessageForProfileTable];
         }
         
     } isShowLoader:YES];
}

//Append the media url with base
- (void)alterTheMediaList:(NSDictionary *)response {
    
    for (int i=0; i< [[response objectForKey:@"feed_list"] count]; i++) {
        
        NSMutableDictionary *dict = [[[response objectForKey:@"feed_list"] objectAtIndex:i] mutableCopy];
        
        int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[dict valueForKey:@"post_id"] from:feedList type:1];
        
        if (postIndex == -1) {
            
            NSMutableDictionary *profileImage = [[dict objectForKey:@"posters_profile_image"] mutableCopy];
            [profileImage setValue: [NSString stringWithFormat:@"%@%@",feedImageUrl,[profileImage  valueForKey:@"profile_image"]] forKey:@"profile_image"];
            [dict setObject:profileImage forKey:@"posters_profile_image"];
            
            NSMutableArray *mediaList = [[dict valueForKey:@"image_present"] boolValue] ? [[dict objectForKey:@"image"] mutableCopy] : [[dict objectForKey:@"video"] mutableCopy];
            for (int i=0; i<[mediaList count]; i++) {
                NSMutableDictionary *media = [[mediaList objectAtIndex:i] mutableCopy];
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@",feedImageUrl,[media valueForKey:@"media_url"]];
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
            
            [dict setValue:@"true" forKey:@"isEnabled"];
            
            // Add response array to the selected feed type
            [feedList addObject:dict];
        }
    }
    if ([[response objectForKey:@"feed_list"] count] != 0) {
        [self.myTblView reloadData];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [feedsDesign checkWhichVideoToEnable:_myTblView];
        });
    }
}

//Add empty message in table background view

- (void)addEmptyMessageForProfileTable {
    
    if ([feedList count] == 0) {
        
        if ([self.gStrSource isEqualToString:@""]) {
            [Util addEmptyMessageToTableWithHeader:self.myTblView withMessage:[NSString stringWithFormat:@"No Bookmarks"] withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
        }
        else {
            [Util addEmptyMessageToTableWithHeader:self.myTblView withMessage:[NSString stringWithFormat:@"No %@",self.gStrSource] withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
        }
    }
    
    else {
        self.myTblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (void)backPressed {
   
    [self.navigationController popViewControllerAnimated:YES];
}

// Mute/Unmute Pressed

-(void)muteUnmutePressed:(UIButton*)sender {
    
    UIButton *btn = sender;
    //    btn.selected = !btn.selected;
    NSDictionary* userInfo;
    UIImage * aImgMute = [UIImage imageNamed:@"icon_mute"];
    UIImage * aImgUnMute = [UIImage imageNamed:@"icon_unmute"];
    
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    FeedCell *cell = (FeedCell*)[_myTblView cellForRowAtIndexPath:myIP];
    
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
    
    if ([feedList count] > sender.tag) {
        
        feedsDesign.feeds = feedList;
        feedsDesign.feedTable = _myTblView;
        feedsDesign.mediaBaseUrl= feedImageUrl;
        feedsDesign.viewController = self;
        feedsDesign.isVolumeClicked = YES;
        
        [feedsDesign designTheContainerView:cell forFeedData:[feedList objectAtIndex:sender.tag] mediaBase:feedImageUrl forDelegate:self tableView:_myTblView];
    }
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView
{
    __weak BookmarkViewController *weakSelf = self;
    // setup infinite scrolling
    [self.myTblView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [self.myTblView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
//    // setup infinite scrolling for board
//    [self.boardTable addInfiniteScrollingWithActionHandler:^{
//        [weakSelf insertRowAtBottomForBoard];
//    }];
    
}

//Add load more items
- (void)insertRowAtBottom {
    
    __weak BookmarkViewController *weakSelf = self;
    int64_t delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (pageNumber != -1) {
            [weakSelf getFeedsList];
        }
        else {
            [self.myTblView.infiniteScrollingView stopAnimating];
        }
    });
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    [feedsDesign playVideoConditionally];
    //    [feedsDesign checkWhichVideoToEnable:_feedsTable];
    [feedsDesign stopAllVideos];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    [feedsDesign checkWhichVideoToEnable:_myTblView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [feedsDesign checkWhichVideoToEnable:_myTblView];

}
    
@end
