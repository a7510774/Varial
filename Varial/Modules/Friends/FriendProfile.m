//
//  FriendProfile.m
//  Varial
//
//  Created by Shanmuga priya on 2/13/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "FriendProfile.h"
#import "HeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "MyFriends.h"
#import "FeedsDesign.h"
#import "XMPPServer.h"
#import "FriendsChat.h"
#import "FeedCell.h"
#import "FriendCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "InviteFriends.h"
#import <ResponsiveLabel/ResponsiveLabel.h>
#import "BookmarkViewController.h"

@interface FriendProfile ()
{
    FeedsDesign *feedsDesign;
    NSInteger followCount, myIntPhotoCount, myIntVideoCount;
    BOOL myBoolIsMutePressed;
}

@end

@implementation FriendProfile
//@synthesize viewLeft,
@synthesize ProfileHolder;
//@synthesize  segment;
NSArray *friendStatusIcon,*friendStatusTitle;
NSString *friendMessage;
BOOL isRefresh = FALSE, canDonate = FALSE;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    friendsList = [[NSMutableArray alloc]init];
    feedList = [[NSMutableArray alloc]init];
    friendProfileData = [[NSMutableDictionary alloc] init];
    friendStatusIcon = [[NSArray alloc] initWithObjects:@"friendAddIcon",@"friendInvitedIcon",@"friendInvitedIcon",@"friendBlockedIcon",@"friendFriendsIcon", nil];
    
    friendStatusTitle = [[NSArray alloc] initWithObjects:@"Invite",@"Invited", @"Respond",@"Un Block",@"Friends",nil];
    
    _profileView.delegate = self;
    [_profileView hideMore:YES];
    [_profileView setHidden:YES];
    
    _headerView.delegate = self;
//    [_headerView setOptionHidden:NO];
    [_headerView setBookmarkHidden:YES];

    refreshControl = [[UIRefreshControl alloc] init];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        self.profileTable.refreshControl = refreshControl;
    } else {
        [self.profileTable addSubview:refreshControl];
    }
    
    [refreshControl addTarget:self action:@selector(reloadView) forControlEvents:UIControlEventValueChanged];
    
    [self setInfiniteScrollForTableView];

    [self.profileTable registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    [self.profileTable registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
    [self.profileTable registerNib:[UINib nibWithNibName:@"FriendInviteCell" bundle:nil] forCellReuseIdentifier:@"FriendInviteCell"];
    
    
    
//    [_profileTable setHidden:NO];
    
    [self designTheView];
//    [self setTint];
    [self getFriendProfileData];
    isRefresh = FALSE;
    //[self setInfiniteScrollForTableView];
    
    //Show Ad
    [GoogleAdMob sharedInstance].delegate = self;
    [[GoogleAdMob sharedInstance] addAdInViewController:self];

    //Set point icon
//    [Util setPointsIconText:_btnPoints withSize:18];
    
    [self.profileView.btnFollow addTarget:self action:@selector(followBtntapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void) startLoading {
    [refreshControl beginRefreshing];
}

// Stop loading if profile and feeds are done
- (void) stopLoading {
    if (!profileLoading && !feedsLoading) {
        [refreshControl endRefreshing];
    }
}

//Recieve instant notification for friend accept/request
-(void) reloadBaseData:(NSNotification *) data{
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    NSDictionary *body = [notificationContent objectForKey:@"data"];
    if ([[notificationContent objectForKey:@"type"] isEqualToString:@"friend_notification"]) {
        NSString *friend_id = [body valueForKey:@"friend_id"];
        if ([_friendId isEqualToString:friend_id]) {
            [responsePopup dismiss:YES];
            [self getFriendProfileData];
            [feedList removeAllObjects];
            [self getProfileFeeds];
        }
    }
}

- (void)reloadView {
    [self getProfileFeeds];
    [self getProfileInfo];
}

//Load the page details
- (void)getFriendProfileData{
    
    if ([feedList count] == 0) {
        [self getProfileFeeds];
    }
    
//    friendsPage = friendPreviousPage = 1;
//    [friendsList removeAllObjects];
//    [self getFriendsList];
    
    [self getProfileInfo];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
//    if (isRefresh) {
//        friendsPage = friendPreviousPage= 1;
//        [friendsList removeAllObjects];
//        [self getFriendsList];
//    }
    [_profileTable reloadData];
    isRefresh = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBaseData:) name:@"FriendNotification" object:nil];
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
    
//    [Util setStatusBar];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    appDelegate.shouldAllowRotation = NO;
}
-(void)viewDidAppear:(BOOL)animated{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[feedsDesign playVideoConditionally];
        [feedsDesign checkWhichVideoToEnable:_profileTable];
    });
}
- (void)displayAd:(CGFloat)height {
    _bottomMargin.constant = height;
}
- (void)removeAd {
    _bottomMargin.constant = 0;
}

- (void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FriendNotification" object:nil];
    [GoogleAdMob sharedInstance].delegate = nil;
}
- (void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FriendNotification" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [feedsDesign stopAllVideos];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark HeaderView Delegates

- (void)optionPressed {
    [self respondToUser:nil];
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ProfileView Delegates

- (void)tappedPoints:(id)sender {
    [self createPopUpWindows];
    if (KLCpointPopup != nil) {
        [KLCpointPopup show];
    }
}
- (void)tappedVideos:(id)sender {
    [self videosBtnTapped];
}

- (void)tappedPhotos:(id)sender {
    [self photosBtnTapped];
}

- (void)tappedUpdate:(id)sender {
    [self friendFollowBtntapped];
}

- (void)tappedFriends:(id)sender {
    [self goToFriends];
}

- (void)tappedLocation:(id)sender {
    
}
- (void)tappedName:(id)sender {
    
}

- (void)tappedProfileImage:(id)sender {
    [[Util sharedInstance] zoomImageView:_profileView.profileImage];
}
- (void)tappedBoardImage:(id)sender {

}

// Navigate to Photo List Page
-(void) photosBtnTapped {
    if (myIntPhotoCount > 0) {
        BookmarkViewController *aViewController = [BookmarkViewController new];
        aViewController.gStrSource = @"Images";
        aViewController.gStrFriendId = _friendId;
        [self.navigationController pushViewController:aViewController animated:YES];
    }
}

// Navigate to Video List Page
-(void) videosBtnTapped {
    if (myIntVideoCount > 0) {
        BookmarkViewController *aViewController = [BookmarkViewController new];
        aViewController.gStrSource = @"Videos";
        aViewController.gStrFriendId = _friendId;
        [self.navigationController pushViewController:aViewController animated:YES];
    }
    
}

//- (void)tappedMore:(id)sender {
//    [self goToMenu];
//}

//Navigate to Followers List Page
- (void)friendFollowBtntapped {
    
    MyFriends *myFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"MyFriends"];
    myFriends.isFromFollowers = YES;
    myFriends.isFromFriendsFollowers = YES;
    myFriends.friendName = _friendName;
    myFriends.friendId = _friendId;
    if (followCount > 0) {
        [self.navigationController pushViewController:myFriends animated:YES];
    }
}

#pragma mark Actions


- (void)designTheView{
    
    feedsDesign = [[FeedsDesign alloc] init];
    
    [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(FRIENDS_PROFILE, nil),_friendName]];
    [_headerView setHeader:@""];
    [_headerView.logo setHidden:YES];
    
//    viewLeft.layer.cornerRadius = viewLeft.frame.size.height / 2 ;
//    viewLeft.clipsToBounds = true;
    
//    _boardImage.layer.cornerRadius = _boardImage.frame.size.height / 2 ;
//    _boardImage.clipsToBounds = true;
    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont fontWithName:@"CenturyGothic" size:16], NSFontAttributeName,
//                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    
//    [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
//    [segment setTitleTextAttributes:attributes forState:UIControlStateSelected];
//    segment.layer.borderColor = UIColorFromHexCode(THEME_COLOR).CGColor;
//    segment.layer.borderWidth = 0.5;
    
//    _profileTable.backgroundColor = [UIColor clearColor];
    _profileTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    [_profileTable setHidden:YES];
    
    //Add rounded corner to buttons
//    [Util setUpFloatIcon:_searchButton];
    
//    [Util createBorder:_btnMore withColor:UIColorFromHexCode(THEME_COLOR)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)PlayVideoOnAppForeground
{
    [feedsDesign checkWhichVideoToEnable:_profileTable];
}

-(void)StopVideoOnAppBackground
{
    [feedsDesign StopVideoOnAppBackground:_profileTable];
}


- (void) createPopUpWindows{
    
    if (friendStatus == 4) {
        pointPopup = [[PointsPopup alloc] initWithViewsshowBuyPoints:FALSE showDonatePoints:canDonate showRedeemPoints:FALSE showPointsActivityLog:TRUE];
        [pointPopup setDelegate:self];
        KLCpointPopup = [KLCPopup popupWithContentView:pointPopup showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    }
    else{
        if (canDonate) {
            pointPopup = [[PointsPopup alloc] initWithViewsshowBuyPoints:FALSE showDonatePoints:canDonate showRedeemPoints:FALSE showPointsActivityLog:FALSE];
            [pointPopup setDelegate:self];
            KLCpointPopup = [KLCPopup popupWithContentView:pointPopup showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        }
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


- (IBAction)moveToChat:(id)sender
{
    if (friendJID != nil) {
        FriendsChat *chat =  [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsChat"];
        chat.receiverID = friendJID;
        chat.receiverName = _friendName;
        chat.receiverImage = profileImageURL;
        chat.isSingleChat = @"TRUE";
        [self.navigationController pushViewController:chat animated:YES];
    }
}

- (void)goToFriends {
    MyFriends *myFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"MyFriends"];
    myFriends.friendId = _friendId;
    myFriends.friendName = _friendName;
//    myFriends.isFromFollowers = NO;
    [self.navigationController pushViewController:myFriends animated:YES];
}

//Move friends search page
- (IBAction)moveToSearch:(id)sender {
    [self goToFriends];
}

- (IBAction)tappedSegment:(id)sender {
    [self setTint];
}

//Change the segment on click
-(void)setTint{
    
//    for (int i=0; i<[segment.subviews count]; i++)
//    {
//        
//        if ([[segment.subviews objectAtIndex:i]isSelected] )
//        {
//            UIColor *themeColor = UIColorFromHexCode(THEME_COLOR);
//            [[segment.subviews objectAtIndex:i]setTintColor:themeColor];
//        }
//        else
//        {
//            UIColor *bckcolor=[UIColor blackColor];
//            [[segment.subviews objectAtIndex:i]setTintColor:bckcolor];
//        }
//    }
//    
//    //Hide/show the floating button
//    if(segment.selectedSegmentIndex == 0){
//        [_searchButton setHidden:YES];
//        //[feedsDesign playVideoConditionally];
//        [feedsDesign checkWhichVideoToEnable:_profileTable];
//    }else{
//        [feedsDesign stopAllVideos];
//        if(friendStatus == 4){
//            _searchButton.hidden = NO;
//        }
//        else{
//            _searchButton.hidden = YES;
//        }
//    }

    _profileTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addEmptyMessageForProfileTable];
    [_profileTable reloadData];
    
}

//Show points popup
- (IBAction)openPointsPopup:(id)sender {
    [self createPopUpWindows];
    if (KLCpointPopup != nil) {
        [KLCpointPopup show];
    }
}

//Respond to the user based on status
- (IBAction)respondToUser:(id)sender {
    
    if(friendStatus == 0)
    {
        //Non-friend view, need to show invite and block
        responsePopupView = [[ResponsePopup alloc]initWithOptions:YES showUnFriend:NO showCancelInvite:NO showAccept:NO showCancelRequest:NO];
    }
    if(friendStatus == 1)
    {
        //Non-friend view, already invite has been sent
        //need to show cancel invite and block
        responsePopupView = [[ResponsePopup alloc]initWithOptions:NO showUnFriend:NO showCancelInvite:YES showAccept:NO showCancelRequest:NO];
        
    }
    if(friendStatus == 2)
    {
        //Non-friend view, he/she give invite to us
        //need to show accept/cancel invite and block
        responsePopupView = [[ResponsePopup alloc]initWithOptions:NO showUnFriend:NO showCancelInvite:NO showAccept:YES showCancelRequest:YES];
        
    }
    if(friendStatus == 4)
    {
        //Friend view
        //need to show unfriend and block
        responsePopupView = [[ResponsePopup alloc]initWithOptions:NO showUnFriend:YES showCancelInvite:NO showAccept:NO showCancelRequest:NO];
        
    }
    if (friendStatus != 3) {
        [responsePopupView setDelegate:self];
        responsePopup = [KLCPopup popupWithContentView:responsePopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        [responsePopup show];
    }
    else{
        //Un block the user
        [self unBlockTheUser];
    }
    
}

//Un block the user
- (void)unBlockTheUser{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_friendId forKey:@"friend_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:UNBLOCKED_PLAYERS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            friendStatus = 0;
            [self changeFriendStatusIcon:friendStatus];
            
            //Get public feeds
            feedPage = 1;
            [feedList removeAllObjects];
            [self getProfileFeeds];
            
            //Unblock the user
            [self changePrivacy:2];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:YES];
}

// ------------- Block popup  Start ---------------
#pragma mark YesNoPopDelegate
- (void)onYesClick{
    [self doAction:4 url:BLOCKFRIEND];
}

- (void)onNoClick{
    [blockPopUp dismiss:YES];
}

// ------------- Block popup End  ----------------

//Get user details
- (void)getProfileInfo {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        profileLoading = NO;
        [self stopLoading];
    });
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_friendId forKey:@"friend_id"];
    [inputParams setValue:self.strNameTag forKey:@"name"];

    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:FRIEND_PROFILE withCallBack:^(NSDictionary * response)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             profileLoading = NO;
             [self stopLoading];
         });
         
         NSLog(@"Response %@",response);
         
         if([[response valueForKey:@"status"] boolValue]){
             
//             [_profileTable setHidden:NO];
             [_profileView setHidden:NO];
             
//             _friendId =  response[@"id"];
//             _friendName =  response[@"name"];

             strMediaUrl = [response objectForKey:@"media_base_url"];
             NSDictionary *details=[[NSDictionary alloc]init];
             details = [response objectForKey:@"player_details"];

             [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(FRIENDS_PROFILE, nil),[details objectForKey:@"name"]]];
             jabberId = [details valueForKey:@"jabber_id"];
             _profileView.name.text = [details objectForKey:@"name"];
             _friendName = [details objectForKey:@"name"];
             _friendId = [details objectForKey:@"id"];
             
             myIntPhotoCount = [[details objectForKey:@"photo_count"] intValue];
             myIntVideoCount = [[details objectForKey:@"video_count"] intValue];
             
             [_profileView.pointsButton setTitle:[NSString stringWithFormat:@"%@", [details objectForKey:@"leader_board_points"]] forState:UIControlStateNormal];
             _profileView.rank.text = [Util playerTypeInProfilePage:[[details objectForKey:@"player_type_id"] intValue] playerRank:[details objectForKey:@"rank"]];
             [_profileView.friendsButton setTitle:[NSString stringWithFormat:@"%@", [details objectForKey:@"friends_count"]] forState:UIControlStateNormal];
             [_profileView.photosButton setTitle:[NSString stringWithFormat:@"%d", [[details objectForKey:@"photo_count"] intValue]] forState:UIControlStateNormal];
             [_profileView.videosButton setTitle:[NSString stringWithFormat:@"%d", [[details objectForKey:@"video_count"] intValue]] forState:UIControlStateNormal];
             _profileView.location.text = [details objectForKey:@"location"];
             
             if(![[details objectForKey:@"follow_count"] isEqualToString:@""]){
                 [_profileView.profileUpdateButton setTitle:[NSString stringWithFormat:@"%@",[details objectForKey:@"follow_count"]] forState:UIControlStateNormal];
             }
             followCount = [[details objectForKey:@"follow_count"] integerValue];
             
//             NSMutableArray * profileImagesArr = [[NSMutableArray alloc]init];
//             profileImagesArr = [details objectForKey:@"profile_images"];
//             if(profileImagesArr.count > 0){
//                 [_profileView.profileUpdateButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)profileImagesArr.count] forState:UIControlStateNormal];
//             }
             // Player_type_id 1 is an skater 2 is an Crew 3 is an Media
//             if ([[details objectForKey:@"player_type_id"] intValue] != 1) {
//                 [_starImage setHidden:YES];
//             }
             
             NSDictionary *proImage = [details objectForKey:@"profile_image_details"];
             NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[proImage  objectForKey:@"profile_image"]];
             profileImageURL = strURL;
             friendJID = [details objectForKey:@"jabber_id"];
             
             [_profileView.profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
             
             //Add zoom
//             [[Util sharedInstance] addImageZoom:_profileView.profileImage];
             
             NSString *board = [NSString stringWithFormat:@"%@%@",strMediaUrl,[details valueForKey:@"skate_board_image"]];
             [_profileView.boardImage setImageWithURL:[NSURL URLWithString:board]];
//             [_profileView.boardImage setImageWithURL:[NSURL URLWithString:board] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
             
             //Relation status
             [self changeFriendStatusIcon:[[details objectForKey:@"friend_relation_status"] intValue]];
             
//             [_profileTable setHidden:NO];
             canDonate = [[details valueForKey:@"can_donate"] boolValue];
             
             self.strFrndRelationshipStatus = details[@"friend_relation_status"];
             self.strFollow = details[@"follow"];

             //Create friend details
             [friendProfileData setValue:[details objectForKey:@"name"] forKey:@"player_name"];
             [friendProfileData setValue:[details objectForKey:@"leader_board_points"] forKey:@"point"];
             [friendProfileData setValue:[details objectForKey:@"rank"] forKey:@"rank"];
             [friendProfileData setValue:[details objectForKey:@"player_type_id"] forKey:@"player_type_id"];
             [friendProfileData setValue:[proImage  objectForKey:@"profile_image"] forKey:@"profile_image"];
             [friendProfileData setValue:_friendId forKey:@"player_id"];
             [friendProfileData setValue:[details valueForKey:@"skate_board_image"] forKey:@"player_skate_pic"];
             [self createPopUpWindows];
             [self setAndAdjustFollowFrame];
            
         }
         else{
             [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
         }
         
     } isShowLoader:NO];
}

//Change friends status icon
- (void)changeFriendStatusIcon:(int)status{
    [_headerView setOptionHidden:NO];
    friendStatus = status;
    
    [_headerView setOptionImage:[UIImage imageNamed:[friendStatusIcon objectAtIndex:friendStatus]] forState:UIControlStateNormal];
    
//    [_respondButton setBackgroundImage:[UIImage imageNamed:[friendStatusIcon objectAtIndex:friendStatus]] forState:UIControlStateNormal];
//    _statusLable.text = NSLocalizedString([friendStatusTitle objectAtIndex:friendStatus],nil);
//    
//    // If FriendStatus is an Friends and current Language is CHINA
//    if ([[friendStatusTitle objectAtIndex:friendStatus] isEqualToString:@"Friends"]) {
//        
//        if (CHAT_ENABLED) {
//            [_btnChat setHidden:NO];
//            [_chatLable setHidden:NO];
//        }
//        else
//        {
//            [_btnChat setHidden:YES];
//            [_chatLable setHidden:YES];
//        }
//        
//        if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
//        {
//            _statusLable.text = @"关系。" ;
//        }
//    }
//    else
//    {
//        [_btnChat setHidden:YES];
//        [_chatLable setHidden:YES];
//    }
//    
//    if (segment.selectedSegmentIndex == 1) {
//        if(friendStatus == 4){
//            _searchButton.hidden = NO;
//        }
//        else{
//            _searchButton.hidden = YES;
//        }
//    }
    
}

- (IBAction)showProfile:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.profileTable];
    NSIndexPath *path = [self.profileTable indexPathForRowAtPoint:buttonPosition];
    NSDictionary *friend = [friendsList objectAtIndex:path.row];
    FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    friendProfile.friendId = [friend valueForKey:@"friend_id"];
    friendProfile.friendName = [friend valueForKey:@"name"];
    [self.navigationController pushViewController:friendProfile animated:YES];
}

// Action for invite button in tableview
- (IBAction)tappedInviteButton:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.profileTable];
    NSIndexPath *path = [self.profileTable indexPathForRowAtPoint:buttonPosition];
    FriendCell *rowSelected = [_profileTable cellForRowAtIndexPath:path];
    [rowSelected.statusButton setTitle:@"Inviting" forState:UIControlStateNormal];
    [self sendInviteFriend:path];
}

// API access for send invite
-(void) sendInviteFriend:(NSIndexPath *)path
{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    NSMutableDictionary *dic=[[friendsList objectAtIndex:path.row]mutableCopy];
    
    [inputParams setValue: [dic objectForKey:@"friend_id"] forKey:@"friend_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ADD_FRIEND withCallBack:^(NSDictionary * response){
        
        FriendCell *rowSelected = [_profileTable cellForRowAtIndexPath:path];
        
        if([[response valueForKey:@"status"] boolValue]){
            //invitation send
            [rowSelected.statusButton setTitle:NSLocalizedString(@"Invited", nil) forState:UIControlStateNormal];
            [rowSelected.statusView setBackgroundColor:[UIColor grayColor]];
            [rowSelected.plus setImage:[UIImage imageNamed: @"invited.png"]];
            [dic setObject:@"1" forKey:@"relationship_status"];
            [friendsList replaceObjectAtIndex:path.row withObject:dic];
            [rowSelected.statusButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        }else{
            [rowSelected.statusButton setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
        }
        
    } isShowLoader:NO];
    
}


#pragma argu - tableView delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [feedList count];
//    return segment.selectedSegmentIndex == 0 ? [feedList count] :[friendsList count];;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    FeedCell *fcell;
    if (tableView == _profileTable) {
        
//        if (segment.selectedSegmentIndex == 0) {
        
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
            feedsDesign.mediaBaseUrl= strMediaUrl;
            feedsDesign.viewController = self;
            feedsDesign.isVolumeClicked = NO;
//            feedsDesign.isNoNeedNameRedirection = TRUE;
//            feedsDesign.isNoNeedProfileRedirection = TRUE;
            [feedsDesign designTheContainerView:fcell forFeedData:[feedList objectAtIndex:indexPath.row] mediaBase:strMediaUrl forDelegate:self tableView:tableView];
        fcell.shareView.hidden = YES;
        fcell.shareViewHeightConstraint.constant = 0.0;
        NSString * isShare = [feedList[indexPath.row][@"is_share"] stringValue];
        if ([isShare isEqualToString:@"1"]) {
            fcell.shareView.hidden = NO;
            fcell.shareViewHeightConstraint.constant = 70.0;
            NSString * sharedPerson = feedList[indexPath.row][@"share_details"][@"name"];
//            NSString * postOwnerName = feedList[indexPath.row][@"name"];
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
            return  fcell;
//        }else{
//            static NSString *cellIdentifier = @"FriendInviteCell";
//            FriendCell *frndCell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//            if (frndCell == nil)
//            {
//                frndCell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//            }
//            
//            frndCell.backgroundColor = [UIColor clearColor];
//            
//            NSDictionary *list = [friendsList objectAtIndex:indexPath.row];
//            
//            frndCell.name.text = [list objectForKey:@"name"];
//            frndCell.points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[list objectForKey:@"point"]];
//            frndCell.rankLabel.text = [Util playerType:[[list objectForKey:@"player_type_id"] intValue] playerRank:[list objectForKey:@"rank"]];
//            
//            NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"profile_image"]];
//            [frndCell.profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
//            
//            strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"player_skate_pic"]];
//            [frndCell.board setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
//            
//            if ([[list objectForKey:@"my_self"] boolValue]) {
//                [frndCell.statusView setHidden:YES];
//            }
//            else{
//                [frndCell.statusView setHidden:NO];
//                //Check Relationship status
//                if([[list objectForKey:@"relationship_status"] integerValue]==0)
//                {
//                    [frndCell.statusButton setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
//                    [frndCell.statusView setBackgroundColor:[UIColor redColor]];
//                    [frndCell.plus setImage:[UIImage imageNamed: @"invite.png"]];
//                    row = indexPath.row;
//                    [frndCell.statusButton addTarget:self action:@selector(tappedInviteButton:) forControlEvents:UIControlEventTouchUpInside];
//                }
//                else{
//                    [frndCell.statusButton addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside];
//                }
//                
//                if([[list objectForKey:@"relationship_status"] integerValue]==1)
//                {
//                    [frndCell.statusButton setTitle:NSLocalizedString(@"Invited", nil) forState:UIControlStateNormal];
//                    [frndCell.statusView setBackgroundColor:[UIColor grayColor]];
//                    [frndCell.plus setImage:[UIImage imageNamed: @"invited.png"]];
//                }
//                else if([[list objectForKey:@"relationship_status"] integerValue]==2)
//                {
//                    [frndCell.statusButton setTitle:@"Accept" forState:UIControlStateNormal];
//                    [frndCell.statusView setBackgroundColor:[UIColor redColor]];
//                    [frndCell.plus setImage:[UIImage imageNamed: @"accept.png"]];
//                }
//                else if([[list objectForKey:@"relationship_status"] integerValue]==4)
//                {
//                    [frndCell.statusButton setTitle:NSLocalizedString(@"Friends", nil) forState:UIControlStateNormal];
//                    [frndCell.statusView setBackgroundColor:[UIColor blackColor]];
//                    [frndCell.plus setImage:[UIImage imageNamed: @"friendsTick.png"]];
//                }
//            }
//            return  frndCell;
//        }
    }
    return  cell;
}


//-(void)doActionForSharedPerson:(id)sender{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_profileTable];
//    NSIndexPath *path = [_profileTable indexPathForRowAtPoint:buttonPosition];
//    [self goToSharedPersonProfile:path isSharedPersonName:YES];
//}
//
//-(void)doActionForShareOwner:(id)sender{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_profileTable];
//    NSIndexPath *path = [_profileTable indexPathForRowAtPoint:buttonPosition];
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

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if(segment.selectedSegmentIndex == 1) {
//        NSDictionary *friend = [friendsList objectAtIndex:indexPath.row];
//        if ([[friend valueForKey:@"my_self"] boolValue]) {
//            MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
//            [self.navigationController pushViewController:myProfile animated:YES];
//        }
//        else{
//            FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
//            friendProfile.friendId = [friend valueForKey:@"friend_id"];
//            friendProfile.friendName = [friend valueForKey:@"name"];
//            [self.navigationController pushViewController:friendProfile animated:YES];
//        }
//    }
//    else{
//        
//    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
//    [feedsDesign stopTheVideo:cell];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [feedsDesign playVideoConditionally];
//    });
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    [feedsDesign stopAllVideos];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [feedsDesign playVideoConditionally];
//    });
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [feedsDesign stopAllVideos];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    [feedsDesign checkWhichVideoToEnable:_profileTable];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [feedsDesign checkWhichVideoToEnable:_profileTable];
}

#pragma argu - KLCPointpopup delegate
- (void)onBuyPointsClick{
    [KLCpointPopup dismiss:YES];
    BuyPointsViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"BuyPointsViewController"];
    [self.navigationController pushViewController:profile animated:YES];
}

-(void)onDonatePointsClick{
    [KLCpointPopup dismiss:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

    DonateForm *donateForm = [mainStoryboard instantiateViewControllerWithIdentifier:@"DonateForm"];
    donateForm.donateTo = friendProfileData;
    donateForm.donationType = 0; //For player
    donateForm.mediaBase = strMediaUrl;
    donateForm.donatedFrom = 1; //From member
    [self.navigationController pushViewController:donateForm animated:YES];
    
}
-(void)onRedeemPointsClick{
    [KLCpointPopup dismiss:YES];
}
-(void)onPointsActivityLog{
    [KLCpointPopup dismiss:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

    PointsActivityLog *points = [mainStoryboard instantiateViewControllerWithIdentifier:@"PointsActivityLog"];
    points.friendId = _friendId;
    [self.navigationController pushViewController:points animated:YES];
}



//------------> Friends related code <------------

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak FriendProfile *weakSelf = self;
    // setup infinite scrolling
    [self.profileTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [self.profileTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
}

//Add load more items
- (void)insertRowAtBottom {
//    if((friendsPage > 0 && friendsPage != friendPreviousPage && segment.selectedSegmentIndex == 1 )|| segment.selectedSegmentIndex == 0){
        __weak FriendProfile *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            if (segment.selectedSegmentIndex == 0) {
                [weakSelf getProfileFeeds];
//            }
//            else{
//                [weakSelf getFriendsList];
//            }
        });
//    }
//    else{
//        NSLog(@"NO MORE CONTENTS...!");
//        [self.profileTable.infiniteScrollingView stopAnimating];
//    }
}

//Add empty message in table background view
- (void)addEmptyMessageForProfileTable{
    
//    if(segment.selectedSegmentIndex == 1) {
//        if ([friendsList count] == 0 && friendMessage == nil) {
//            [Util addEmptyMessageToTableWithHeader:self.profileTable withMessage:FRIENDS_NIL withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
//        }
//        else if ([friendsList count] == 0 && friendMessage != nil) {
//            [Util addEmptyMessageToTableWithHeader:self.profileTable withMessage:friendMessage withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
//        }
//        else{
//            _profileTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//        }
//        
//    }else{
        if ([feedList count] == 0) {
            [Util addEmptyMessageToTableWithHeader:self.profileTable withMessage:NO_FEEDS withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
        }
        else{
            _profileTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
//    }
    
}

//Get friends list
-(void) getFriendsList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:friendsPage] forKey:@"page"];
    [inputParams setValue:_friendId forKey:@"friend_id"];
    
    [self.profileTable.infiniteScrollingView startAnimating];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:MY_FRIENDS withCallBack:^(NSDictionary * response){
        
        [self.profileTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            if (strMediaUrl == nil) {
                strMediaUrl = [response objectForKey:@"media_base_url"];
            }
            friendsPage = [[response valueForKey:@"page"] intValue];
            [friendsList addObjectsFromArray:[[response objectForKey:@"friend_list"] mutableCopy]];
            [self addEmptyMessageForProfileTable];
            [_profileTable reloadData];
        }else{
            friendMessage = [response valueForKey:@"message"];
            [self addEmptyMessageForProfileTable];
        }
        
    } isShowLoader:NO];
    
}

//----------------> friends code ends <------------------

#pragma args ResponsePopup delegate
- (void) onInviteClick{
    
    [self doAction:1 url:ADD_FRIEND];
}

- (void) onUnFriendClick{
    
    [self doAction:2 url:UNFRIEND];
}

- (void) onCancelInviteClick{
    
    [self doAction:3 url:CANCEL_INVITE];
}

- (void) onAcceptClick{
    
    [self doAcceptReject:TRUE url:ACCEPT_REJECT];
    
}

- (void) onCancelRequestClick{
    
    [self doAcceptReject:FALSE url:ACCEPT_REJECT];
    
}

- (void) onBlockClick{
    [responsePopup dismiss:YES];
    [self createPopUpWindows];
    [blockPopUp show];
}

- (void)doAction:(int)action url:(NSString *)url{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_friendId forKey:@"friend_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            if (action == 1) {
                friendStatus = 1;
                [responsePopup dismiss:YES];
                [self changeFriendStatusIcon:friendStatus];
            }
            if (action == 2) {
                
                friendStatus = 0;
                [responsePopup dismiss:YES];
                [self changeFriendStatusIcon:friendStatus];
                [self getProfileInfo];
                
                //need to clear friends list
                [friendsList removeAllObjects];
                friendsPage = friendPreviousPage = 1;
                [self addEmptyMessageForProfileTable];
                
                //Get public feeds
                feedPage = 1;
                [feedList removeAllObjects];
                [self getProfileFeeds];
                [_profileTable reloadData];
                
                //Get varial notifications to updates configuration
                [appDelegate refreshNotification];
                
                //Block the user in chat
                [self changePrivacyForUnfriend:1];
                
            }
            if (action == 3) {
                friendStatus = 0;
                [responsePopup dismiss:YES];
                [self changeFriendStatusIcon:friendStatus];
            }
            if (action == 4) {
                
                //after block
                [blockPopUp dismiss:YES];
                [[AlertMessage sharedInstance]showMessage:[response valueForKey:@"message"] withDuration:3];
                
                friendStatus = 3;
                [self changeFriendStatusIcon:friendStatus];
                
                //Need to clear the feeds and friends
                friendsPage = friendPreviousPage = feedPage = 1;
                [feedList removeAllObjects];
                [friendsList removeAllObjects];
                [_profileTable reloadData];
                [self addEmptyMessageForProfileTable];
                
                //Block the user in chat
                [self changePrivacy:1];
            }
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
        
    } isShowLoader:YES];
}

//Block or unblock the user in chat
- (void)changePrivacy:(int)privacy{
    XMPPBlocking *block = [XMPPServer sharedInstance].xmppBlocking;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *blockedUsers = [[defaults objectForKey:@"blockedUsers"] mutableCopy];
    NSMutableArray *playersiBlocked = [[defaults objectForKey:@"players_i_blocked"] mutableCopy];
    if (privacy == 1) {
        [block blockJID:[XMPPJID jidWithString:jabberId]];
        [blockedUsers addObject:jabberId];
        [playersiBlocked addObject:jabberId];
    }
    else{
        [block unblockJID:[XMPPJID jidWithString:jabberId]];
        [blockedUsers removeObject:jabberId];
        [playersiBlocked removeObject:jabberId];
    }
    [defaults setObject:blockedUsers forKey:@"blockedUsers"];
    [defaults setObject:blockedUsers forKey:@"players_i_blocked"];
}

//Block or unblock the user in chat
- (void)changePrivacyForUnfriend:(int)privacy{
    XMPPBlocking *block = [XMPPServer sharedInstance].xmppBlocking;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *blockedUsers = [[defaults objectForKey:@"blockedUsers"] mutableCopy];
    if (privacy == 1) {
        [block blockJID:[XMPPJID jidWithString:jabberId]];
        [blockedUsers addObject:jabberId];
    }
    else{
        [block unblockJID:[XMPPJID jidWithString:jabberId]];
        [blockedUsers removeObject:jabberId];
    }
    [defaults setObject:blockedUsers forKey:@"blockedUsers"];
}


- (void)doAcceptReject:(BOOL)action url:(NSString *)url{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_friendId forKey:@"friend_id"];
    [inputParams setValue:[NSNumber numberWithBool:action] forKey:@"accept_flag"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            if (action) {
                friendStatus = 4;
                [responsePopup dismiss:YES];
                [self changeFriendStatusIcon:friendStatus];
                
                //need to referesh friends list
//                [friendsList removeAllObjects];
//                friendsPage = friendPreviousPage = 1;
//                [self getFriendsList];
                
                //Get public feeds
                feedPage = 1;
                [feedList removeAllObjects];
                [self getProfileFeeds];
                [self getProfileInfo];
                
                //Get varial notifications to updates configuration
                [appDelegate refreshNotification];
                
                //Block the user in chat
                [self changePrivacyForUnfriend:2];
            }
            else{
                friendStatus = 0;
                [responsePopup dismiss:YES];
                [self changeFriendStatusIcon:friendStatus];
            }
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
            [responsePopup dismiss:YES];
            [self getProfileInfo];
        }
        
    } isShowLoader:YES];
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
//        CGPoint hitPoint = [label convertPoint:CGPointZero toView:self.profileTable];
//        NSIndexPath *indexpath = [self.profileTable indexPathForRowAtPoint:hitPoint];
//        if (![[[feedList objectAtIndex:indexpath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//            FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
//
//            //            profile.friendId = [feeds objectAtIndex:indexpath.row][@"post_owner_id"];
//            //            profile.friendName = [feeds objectAtIndex:indexpath.row][@"name"];
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
//Common Delegate for TTTAttributed Label
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (url != nil && ![[url absoluteString] isEqualToString:@""]) {
        //Open Url
        [[UIApplication sharedApplication] openURL:url];
    }
    else if (label.tag != 2) {
        
        CGPoint position = [label convertPoint:CGPointZero toView:self.profileTable];
        NSIndexPath *indexPath = [self.profileTable indexPathForRowAtPoint:position];
        NSMutableDictionary *feed = [feedList objectAtIndex:indexPath.row];
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[feed valueForKey:@"post_id"] forKey:@"post_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                [feed setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                [feed setValue:[NSNumber numberWithBool:FALSE] forKey:@"continue_reading_flag"];
                [_profileTable reloadData];
            }else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        } isShowLoader:NO];
    }
}

-(void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    UIMenuController *menucontroller=[UIMenuController sharedMenuController];
    UIMenuItem *MenuitemA=[[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(DeletePost:)];
    [menucontroller setMenuItems:[NSArray arrayWithObjects:MenuitemA,nil]];
    
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:_profileTable];
    NSIndexPath *indexPath = [_profileTable indexPathForRowAtPoint:buttonPosition];
    
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

// Click Star & Unstar
- (IBAction)Star:(id)sender
{
    [feedsDesign addStar:_profileTable fromArray:feedList forControl:sender];
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender
{
    [feedsDesign addBookmark:_profileTable fromArray:feedList forControl:sender];
}

// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_profileTable];
        NSIndexPath *path = [_profileTable indexPathForRowAtPoint:buttonPosition];
        NSString *star_post_id = [[feedList objectAtIndex:path.row] objectForKey:@"post_id"];
        selectedPostIndex = (int) path.row;
        Comments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
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

//Append the media url with base
- (void)alterTheMediaList:(NSDictionary *)response{
    
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
        [_profileTable reloadData];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [feedsDesign checkWhichVideoToEnable:_profileTable];
        });
    }
}

//Get user feeds
-(void) getProfileFeeds
{
    if(friendStatus != 3 )
    {
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_friendId forKey:@"friend_id"];
        
        [inputParams setValue:@"0" forKey:@"recent"];
        if ([feedList count] == 0) {
            [inputParams setValue:@"0" forKey:@"post_id"];
        }
        else{
            [inputParams setValue:[[feedList lastObject] valueForKey:@"post_id"] forKey:@"post_id"];
        }
        
        [inputParams setValue:self.strNameTag forKey:@"name"];

//        [self.profileTable.infiniteScrollingView startAnimating];
        dispatch_async(dispatch_get_main_queue(), ^{
            feedsLoading = YES;
            [self startLoading];
        });
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PROFILE_FEEDS withCallBack:^(NSDictionary * response)
         {
             [self.profileTable.infiniteScrollingView stopAnimating];
             feedsLoading = NO;
             [self stopLoading];
             if([[response valueForKey:@"status"] boolValue]){
                 
//                 feedImageUrl = @"https://dqloq8l38fi51.cloudfront.net";
                 if (feedImageUrl == nil) {
                     feedImageUrl = [response objectForKey:@"media_base_url"];
                 }
                 [self alterTheMediaList:response];
                 [self addEmptyMessageForProfileTable];
//                 [_profileTable reloadData];
             }
             
         } isShowLoader:NO];
    }
    else
    {
        [self stopLoading];
//        [self.profileTable.infiniteScrollingView stopAnimating];
    }
}

- (void)createMutableCopyForFeedsList:(NSMutableArray *)list{
    for (int i=0;i<[list count];i++) {
        NSMutableDictionary *feed = [[list objectAtIndex:i] mutableCopy];
        NSMutableDictionary *profileImage = [[feed objectForKey:@"posters_profile_image"] mutableCopy];
        [feed setObject:profileImage forKey:@"posters_profile_image"];
        [feedList addObject:feed];
    }
}
//--------------- feed list code end -----------------

-(void)reportButtonAction:(UITapGestureRecognizer *)tapRecognizer{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.profileTable];
        NSIndexPath *indexPath = [self.profileTable indexPathForRowAtPoint:buttonPosition];
        reportFeed = [feedList objectAtIndex:indexPath.row];
        
        [self.reportPopover dismissMenuPopover];
        
        self.reportPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 65 - _profileTable.contentOffset.y, 140, 84) menuItems:@[NSLocalizedString(REPORT_THE_POST,nil),NSLocalizedString(BLOCK_THE_USER, nil)]];
        self.reportPopover.menuPopoverDelegate = self;
        [self.reportPopover showInView:self.view];
    }
    else{
        [appDelegate.networkPopup show];
    }
}

-(void)sharedReportButtonAction:(UITapGestureRecognizer *)tapRecognizer{
    [self reportButtonAction:tapRecognizer];
}
// Delegate method for MLKMenuPopover
- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    [self.reportPopover dismissMenuPopover];
    if([[Util sharedInstance] getNetWorkStatus])
    {
        int clickedIndex = selectedIndex;
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
            int row = (int)[feedList indexOfObject:reportFeed];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [_profileTable beginUpdates];
            [feedList removeObject:reportFeed];
            [_profileTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [_profileTable endUpdates];
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
    } isShowLoader:YES];
}


#pragma mark - follow and unfollow

- (void)setAndAdjustFollowFrame {
    
    CGRect aRectframe = self.ProfileHolder.frame;
    aRectframe.size.height = 230;
    self.ProfileHolder.frame = aRectframe;
    
    self.profileView.constraiintStatsViewTop.constant = 20;
    self.constraintProfileViewHeaderHeight.constant = 230;
    
    if ([self.strFollow intValue] == 0) {
        
        UIImage * addFollow = [UIImage imageNamed:@"icon_add_follow"];
        
        [self.profileView.btnFollow setTitle:NSLocalizedString(FOLLOW, nil) forState:UIControlStateNormal];
        [self.profileView.btnFollow setImage:addFollow forState:UIControlStateNormal];
//        [self.profileView.btnFollow setBackgroundImage:[UIImage imageNamed:@"btnFollow"] forState:UIControlStateNormal];
//        [self.profileView.btnFollow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [HELPER roundCornerForView:self.profileView.btnFollow withRadius:5.0];
//        [HELPER roundCornerForView:self.profileView.btnFollow radius:self.profileView.btnFollow.frame.size.height / 2 borderColor:[UIColor blackColor] borderWidth:1.0];
    }
    
    else {
        
        UIImage * addFollowing = [UIImage imageNamed:@"icon_following"];
        [self.profileView.btnFollow setTitle:NSLocalizedString(FOLLOWING, nil) forState:UIControlStateNormal];
        [self.profileView.btnFollow setImage:addFollowing forState:UIControlStateNormal];
//        [self.profileView.btnFollow setBackgroundImage:[UIImage imageNamed:@"btnFollowing"] forState:UIControlStateNormal];
        [HELPER roundCornerForView:self.profileView.btnFollow withRadius:5.0];
//        [self.profileView.btnFollow setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [HELPER roundCornerForView:self.profileView.btnFollow radius:self.profileView.btnFollow.frame.size.height / 2 borderColor:[UIColor redColor] borderWidth:1.0];
    }
    
//    if ([self.strFrndRelationshipStatus intValue] != 0) {
//
//        CGRect aRectframe = self.ProfileHolder.frame;
//        aRectframe.size.height = 230;
//        self.ProfileHolder.frame = aRectframe;
//
//        self.profileView.constraiintStatsViewTop.constant = 20;
//        self.constraintProfileViewHeaderHeight.constant = 230;
//
//        if ([self.strFollow intValue] == 0) {
//
//            [self.profileView.btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
//            [self.profileView.btnFollow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [HELPER roundCornerForView:self.profileView.btnFollow radius:self.profileView.btnFollow.frame.size.height / 2 borderColor:[UIColor blackColor] borderWidth:1.0];
//        }
//
//        else {
//
//            [self.profileView.btnFollow setTitle:@"Following" forState:UIControlStateNormal];
//            [self.profileView.btnFollow setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//            [HELPER roundCornerForView:self.profileView.btnFollow radius:self.profileView.btnFollow.frame.size.height / 2 borderColor:[UIColor redColor] borderWidth:1.0];
//        }
//    }
//
//    else {
//
//        CGRect aRectframe = self.ProfileHolder.frame;
//        aRectframe.size.height = 150;
//        self.ProfileHolder.frame = aRectframe;
//
//        self.profileView.constraiintStatsViewTop.constant = - 60;
//        self.profileView.btnFollow.hidden = YES;
//        self.constraintProfileViewHeaderHeight.constant = 150;
//    }
    
    [self.profileTable reloadData];
    
//    [self.ProfileHolder layoutIfNeeded];
//    [self.view layoutIfNeeded];
//    [self.profileTable layoutIfNeeded];
}

- (void)followBtntapped {
    
    self.strFollow = [self.strFollow intValue] == 0 ? @"1" : @"0";

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self setAndAdjustFollowFrame];
    });
    
    [HELPER tapAnimationFor:self.profileView.btnFollow withCallBack:^{
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_friendId forKey:@"friend_id"];
        [inputParams setValue:self.strFollow forKey:@"follow"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FOLLOW_UNFOLLOW withCallBack:^(NSDictionary * response)
        {
            if([[response valueForKey:@"status"] boolValue]) {
                if([[response valueForKey:@"is_follow"] boolValue]) {
                    self.strFollow = @"1";
                } else {
                    self.strFollow = @"0";
                }
                [self setAndAdjustFollowFrame];
            }
            else {
                self.strFollow = [self.strFollow intValue] == 0 ? @"0" : @"1";
                [self setAndAdjustFollowFrame];
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
            }
            
        } isShowLoader:YES];
    }];
}

// Mute/Unmute Pressed

-(void)muteUnmutePressed:(UIButton*)sender {
    
    UIButton *btn = sender;
    //    btn.selected = !btn.selected;
    NSDictionary* userInfo;
    UIImage * aImgMute = [UIImage imageNamed:@"icon_mute"];
    UIImage * aImgUnMute = [UIImage imageNamed:@"icon_unmute"];
    
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    FeedCell *cell = (FeedCell*)[_profileTable cellForRowAtIndexPath:myIP];
    
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
        feedsDesign.feedTable = _profileTable;
        feedsDesign.mediaBaseUrl= strMediaUrl;
        feedsDesign.viewController = self;
        feedsDesign.isVolumeClicked = YES;
        
        [feedsDesign designTheContainerView:cell forFeedData:[feedList objectAtIndex:sender.tag] mediaBase:strMediaUrl forDelegate:self tableView:_profileTable];
    }
}

@end
