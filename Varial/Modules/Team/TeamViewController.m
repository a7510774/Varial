//
//  TeamViewController.m
//  Varial
//
//  Created by Shanmuga priya on 2/24/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "TeamViewController.h"
#import "FeedsDesign.h"
#import "FeedCell.h"
#import "FriendCell.h"
#import "FeedsDesign.h"
#import "ViewController.h"

@interface TeamViewController ()
{
    FeedsDesign *feedsDesign;
}

@end

// -------selectedPopup 1 is --> Remove Co-Captain
// -------selectedPopup 2 is --> Remove Captain
// -------selectedPopup 3 is --> Remove Member
// -------selectedPopup 4 is --> Leave Team Member or CoCaptain

@implementation TeamViewController
int teamRelation;
BOOL isNeedToReload;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view.
    teamDetailsToDonate = [[NSMutableDictionary alloc] init];
    self.menuItemsCaptain = [NSArray arrayWithObjects:NSLocalizedString(LEAVE_TEAM, nil), NSLocalizedString(CHANGE_CO_CAPTAIN, nil),NSLocalizedString(REMOVE_CO_CAPTAIN, nil),NSLocalizedString(VIEW_INVITIES, nil), nil];
    self.menuItemsCoCaptain = [NSArray arrayWithObjects:NSLocalizedString(LEAVE_TEAM, nil),NSLocalizedString(VIEW_INVITIES, nil), nil];
    self.menuItemsMember = [NSArray arrayWithObjects:NSLocalizedString(LEAVE_TEAM, nil), nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"FriendCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TeamFeedCell" bundle:nil] forCellReuseIdentifier:@"TeamFeedCell"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];


    [self designTheView];
    [self setInfiniteScrollForTableView];
    isNeedToReload = TRUE;
    
    [self getFeedsList];
    
    //Set point icon
    [Util setPointsIconText:_btnPoints withSize:16];
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
}

- (void)viewWillAppear:(BOOL)animated{
    feedpage = feedPreviousPage = 1;
    memberpage = memberPreviousPage = 1;
    if (isNeedToReload) {
        [self getTeamDetails];
        [self getTeamMemberList];
    }
    
    [Util setStatusBar];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    appDelegate.shouldAllowRotation = NO;
    
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
-(void)viewDidAppear:(BOOL)animated{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [feedsDesign playVideoConditionally];
    });
}
-(void)viewWillDisappear:(BOOL)animated{
    [feedsDesign stopAllVideos];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)PlayVideoOnAppForeground
{
    [feedsDesign checkWhichVideoToEnable:_tableView];
}

-(void)StopVideoOnAppBackground
{
    [feedsDesign StopVideoOnAppBackground:_tableView];
}

- (void)designTheView{
    
    feedsDesign = [[FeedsDesign alloc] init];
    
    [_tableView setHidden:YES];
    
    [_headerView setHeader:NSLocalizedString(TEAM_VIEW, nil)];
    [_headerView.logo setHidden:YES];
    
    memberList = [[NSMutableArray alloc] init];
    feeds = [[NSMutableArray alloc] init];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_btnMemberSearch setHidden:YES];
    [_btnAddPost setHidden:NO];
    
    [Util createRoundedCorener:_editNameView withCorner:5];
    [Util createRoundedCorener:_btnEditNameSave withCorner:3];
    [Util createRoundedCorener:_btnEditNameCancel withCorner:3];
    [Util setUpFloatIcon:_btnMemberSearch];
    [Util setUpFloatIcon:_btnAddPost];
    
    [Util createRoundedCorener:_editProfileView withCorner:5];
    [Util createRoundedCorener:_btnEditProfileCancel withCorner:3];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"CenturyGothic" size:16], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [_segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [_segment setTitleTextAttributes:attributes forState:UIControlStateSelected];
    [Util createBorder:_btnMore withColor:UIColorFromHexCode(THEME_COLOR)];
    
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableHeaderView.backgroundColor=[UIColor clearColor];
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(LEAVE_TEAM, nil)];
    popupView.message.text = NSLocalizedString(SURE_TO_REMOVE_CO_CAPTAIN, nil);
    [popupView.yesButton setTitle:NSLocalizedString(YES_STRING, nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    leaveTeamPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    removeMemberPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    leaveTeamMemberPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    UITapGestureRecognizer *tapEditProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(UpdateImage:)];
    [_editProfileImage setUserInteractionEnabled:YES];
    [_editProfileImage addGestureRecognizer:tapEditProfileImage];
    
    [[Util sharedInstance] addImageZoom:_teamImage];
    //[[Util sharedInstance] addImageZoom:_captainImage];
    
    UITapGestureRecognizer *tapCaptainImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCaptainProfile)];
    [_captainImage setUserInteractionEnabled:YES];
    [_captainImage addGestureRecognizer:tapCaptainImage];
    
    
    UITapGestureRecognizer *tapCoCaptainImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoCaptain:)];
    [_coCaptainImage setUserInteractionEnabled:YES];
    [_coCaptainImage addGestureRecognizer:tapCoCaptainImage];
    [Util makeAsLink:_coCaptainName withColor:[UIColor whiteColor] showUnderLine:NO range:NSMakeRange(0, [_coCaptainName.text length])];
    
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(handleLongPress:)];
    longpress.minimumPressDuration = 1.0; //seconds
    longpress.delegate = self;
    [_tableView addGestureRecognizer:longpress];
    
    _teamName.delegate = self;
    _captainName.delegate = self;
    _coCaptainName.delegate = self;
    
//    [_teamChat setHidden:YES];
//    [_teamChatLabel setHidden:YES];
    [_teamChat addTarget:self action:@selector(gotoChat:) forControlEvents:UIControlEventTouchUpInside];
    
    if(IPAD)
    {
        [_tableHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 290)];
    }
    
}

-(IBAction)gotoChat:(id)sender
{
    if (_roomId != nil) {
        FriendsChat *chat =  [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsChat"];
        chat.receiverID = _roomId;
        chat.receiverName = _teamName.text;
        chat.receiverImage = teamImageUrl;
//        chat.isFromFriends = @"FALSE";
        chat.isSingleChat = @"FALSE";
        [self.navigationController pushViewController:chat animated:YES];
    }
}

- (void) createPopUpWindows{
    
    editNamePopup = [KLCPopup popupWithContentView:self.editNameView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    editProfilePopup = [KLCPopup popupWithContentView:self.editProfileView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    if (teamRelation == 1 || teamRelation == 2){
        pointsPopup = [[PointsPopup alloc] initWithViewsshowBuyPoints:TRUE showDonatePoints:TRUE showRedeemPoints:canRedeem showPointsActivityLog:TRUE];
    }
    else if (teamRelation == 3) {
        pointsPopup = [[PointsPopup alloc] initWithViewsshowBuyPoints:FALSE showDonatePoints:TRUE showRedeemPoints:FALSE showPointsActivityLog:TRUE];
    }
    
    [pointsPopup setDelegate:self];
    KLCpointsPopup = [KLCPopup popupWithContentView:pointsPopup showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    mediaPopupView = [[MediaPopup alloc] init];
    mediaPopupView.delegate = self;
    KLCMediaPopup = [KLCPopup popupWithContentView:mediaPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    editNamePopup.didFinishShowingCompletion = ^{
        _editTeamName.text = _teamName.text;
    };
    
    editProfilePopup.didFinishShowingCompletion = ^{
        _editProfileImage.image  = _teamImage.image;
    };
    //Alert popup
    blockConfirmation = [[YesNoPopup alloc] init];
    blockConfirmation.delegate = self;
    [blockConfirmation setPopupHeader:NSLocalizedString(BLOCK_PERSON, nil)];
    blockConfirmation.message.text = NSLocalizedString(SURE_TO_BLOCK, nil);
    [blockConfirmation.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [blockConfirmation.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    blockPopUp = [KLCPopup popupWithContentView:blockConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}
- (IBAction)tappedSegment:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
        [feedsDesign playVideoConditionally];
        [_btnMemberSearch setHidden:YES];
        [_btnAddPost setHidden:NO];
    }
    else
    {
        [feedsDesign stopAllVideos];
        [_btnMemberSearch setHidden:NO];
        [_btnAddPost setHidden:YES];
    }
    [self addEmptyMessageForTeamTable];
    [_tableView reloadData];
}


//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak TeamViewController *weakSelf = self;
    
    // setup infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [weakSelf.tableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
}

//Add load more items
- (void)insertRowAtBottom {
    
    if ((_segment.selectedSegmentIndex == 1 && memberpage > 0 && memberpage != memberPreviousPage) || _segment.selectedSegmentIndex == 0 ) {
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak TeamViewController *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_segment.selectedSegmentIndex == 0) {
                // Feed list
                feedPreviousPage = feedpage;
                [weakSelf getFeedsList];
            }
            else{
                memberPreviousPage = memberpage;
                [weakSelf getTeamMemberList];
            }
            [self.tableView.infiniteScrollingView stopAnimating];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.tableView.infiniteScrollingView stopAnimating];
    }
}

- (void)showCoCaptainProfile{
    
    // If current user is Co-Captain should navigate to MyProfile Page else Friends Profile Page
    if (teamRelation == 2) {
        [self moveToMyProfile];
    }
    else
    {
        if (![[teamDetails objectForKey:@"co_captain_present_id"] isEqualToString:@""]) {
            
            [self moveToFriendProfile:[teamDetails objectForKey:@"co_captain_name"] friendId:[teamDetails objectForKey:@"co_captain_present_id"]];
        }
        else if(teamRelation == 3 && [[teamDetails objectForKey:@"co_captain_present_id"] isEqualToString:@""])
        {
            [[AlertMessage sharedInstance] showMessage:COCAPTAIN_NOT_PRESENT];
        }
    }
}

- (void)showCaptainProfile {
    
    // If current user is Captain should navigate to MyProfile Page else Friends Profile Page
    if (teamRelation == 1) {
        [self moveToMyProfile];
    }
    else
    {
        [self moveToFriendProfile:[teamDetails objectForKey:@"captain_name"] friendId:[teamDetails objectForKey:@"captain_id"]];
    }
}

-(void)moveToMyProfile
{
    MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
    [self.navigationController pushViewController:myProfile animated:YES];
}

-(void)moveToFriendProfile:(NSString *)FrinendName friendId:(NSString *)fId
{
    FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    friendProfile.friendId = fId;
    friendProfile.friendName = FrinendName;
    [self.navigationController pushViewController:friendProfile animated:YES];
}

- (void)tapTeamName:(UITapGestureRecognizer *)tapRecognizer {
    [self showTeamEditPopup];
}

- (void)showTeamEditPopup{
    if(teamRelation == 1)
    {
        [_editNameView setHidden:NO];
        [editNamePopup showWithLayout:layout];
    }
}

- (void) tapCoCaptain:(UITapGestureRecognizer *)tapRecognizer {
    
    // If captain present, can change the co-captains
    if(![[teamDetails objectForKey:@"co_captain_present"] boolValue] && teamRelation == 1)
    {
        [self nextViewController:@"1" teamId:_teamId];
    }
    else
    {
        if(teamRelation == 3 && ![[teamDetails objectForKey:@"co_captain_present"] boolValue]) // If current user is member and cocaptain is not present
        {
            [[AlertMessage sharedInstance] showMessage:COCAPTAIN_NOT_PRESENT];
        }
        else
        {
            //UIImageView *imageView = (UIImageView *)tapRecognizer.view;
            //[[Util sharedInstance] addImageZoom:imageView];
            UITapGestureRecognizer *tapCoCaptainImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCoCaptainProfile)];
            [_coCaptainImage setUserInteractionEnabled:YES];
            [_coCaptainImage addGestureRecognizer:tapCoCaptainImage];
        }
        
    }
}

-(void)setUpViews{
    if (teamRelation == 1) {
        
    }
    else if (teamRelation == 2){
        [_teamImageEdit setHidden:YES];
        [_nameEdit setHidden:YES];
    }
    else if (teamRelation == 3){
        [_teamImageEdit setHidden:YES];
        [_nameEdit setHidden:YES];
        _addMemberLabel.text = NSLocalizedString(TEAM_CHAT, nil);
        [_addMember setImage:[UIImage imageNamed:@"chatIcon.png"] forState:UIControlStateNormal];
        
        // This is in feature module so currently hided
        [_addMember setHidden:YES];
        [_addMemberLabel setHidden:YES];
        
        if ([[teamDetails objectForKey:@"co_captain_present"] intValue] == 0) {
            _coCaptainImage.image =  [UIImage imageNamed:@"cocaptain.png"];
        }
    }
    
    [self createPopUpWindows];
}

// -------------------------- Start Tableview HeaderView --------------------------------

- (IBAction)tappedEditName:(id)sender {
    [_editNameView setHidden:NO];
    [editNamePopup showWithLayout:layout];
}

-(IBAction)saveEditName:(id)sender
{
    if([self validateEditTeamName]) {
        NSString *strTeamName = [_editTeamName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Build Parameter
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:strTeamName forKey:@"team_name"];
        [inputParams setValue:_teamId forKey:@"team_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:EDIT_TEAM_NAME withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                _teamName.text = strTeamName;
                [Util makeAsLink:_teamName withColor:[UIColor whiteColor] showUnderLine:NO range:NSMakeRange(0, [_teamName.text length])];
                [editNamePopup dismiss:YES];
                
                Feeds *feed = [[Feeds alloc] init];
                [feed getFeedsTypesList];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] ];
            }
        } isShowLoader:YES];
    }
}

-(IBAction)cancelEditName:(id)sender
{
    [editNamePopup dismiss:YES];
}


- (IBAction)tappedEditProfile:(id)sender {
    [KLCMediaPopup show];
}

-(IBAction)cancelEditProfile:(id)sender
{
    [editProfilePopup dismiss:YES];
}

-(void)UpdateImage:(UITapGestureRecognizer *)tapRecognizer
{
    [editProfilePopup dismiss:YES];
    [KLCMediaPopup show];
}

// --------------- End Tableview HeaderView ----------------


- (IBAction)tappedPoints:(id)sender {
    [KLCpointsPopup show];
}

- (IBAction)tappedMore:(id)sender {
    
    // Hide already showing popover
    [self.menuPopover dismissMenuPopover];
    
    // If current user is captain and co captain is present should show below four options
    if ([[teamDetails objectForKey:@"co_captain_present"] boolValue] && teamRelation == 1) {
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(_btnMore.frame.origin.x-165, 340 - _tableView.contentOffset.y, 180, 170) menuItems:self.menuItemsCaptain];
    }
    else if((![[teamDetails objectForKey:@"co_captain_present"] boolValue] && teamRelation == 1) || teamRelation == 2)
    {
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(_btnMore.frame.origin.x-165, 340 - _tableView.contentOffset.y, 180, 85) menuItems:self.menuItemsCoCaptain];
    }
    else
    {
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(_btnMore.frame.origin.x-165, 340 - _tableView.contentOffset.y, 180, 42) menuItems:self.menuItemsMember];
    }
    self.menuPopover.menuPopoverDelegate = self;
    self.menuPopover.tag = 100;
    [self.menuPopover showInView:self.view];
    
}

// Delegate method for MLKMenuPopover
- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    if(menuPopover.tag == 100){
        [self.menuPopover dismissMenuPopover];
        
        int clickedIndex = selectedIndex;
        
        // If current user is captain and co captain is present
        if ([[teamDetails objectForKey:@"co_captain_present"] boolValue] && teamRelation == 1) {
            if (clickedIndex == 0) {
                [self leaveFromTeam];  // Leave Team
            }
            else if (clickedIndex == 1)
            {
                [self nextViewController:@"2" teamId:_teamId];  // Change Co-Captain
            }
            else if (clickedIndex == 2) // Remove Co-Captain
            {
                [popupView setPopupHeader:NSLocalizedString(LEAVE_TEAM, nil)];
                selectedPopup = 1;
                popupView.message.text = NSLocalizedString(SURE_TO_REMOVE_CO_CAPTAIN, nil);
                [yesNoPopup show];
            }
            else if (clickedIndex == 3) //
            {
                [self nextViewController:@"4" teamId:_teamId];
            }
            
        }
        // If Current user is captain and co-captain is not present OR current user is co-captin
        else if((![[teamDetails objectForKey:@"co_captain_present"] boolValue] && teamRelation == 1) || teamRelation == 2)
        {
            if (clickedIndex == 0) {
                [self leaveFromTeam];
            }
            else if (clickedIndex == 1)
            {
                [self nextViewController:@"4" teamId:_teamId];
            }
        }
        // If Current user is member
        else
        {
            if (clickedIndex == 0) {
                [self leaveFromTeam];
            }
        }
    }
    else{
        [self.reportPopover dismissMenuPopover];
        if([[Util sharedInstance] getNetWorkStatus])
        {
        
            if(selectedIndex == 0){
                [self reportPost];
            }
            else{
                selectedPopup =6;
                [blockPopUp show];
            }
        }
        else{
            [appDelegate.networkPopup show];
        }
    }
}

-(void)leaveFromTeam
{
    [popupView setPopupHeader:NSLocalizedString(LEAVE_TEAM, nil)];
    
    if (teamRelation == 1) {
        // Captain left team
        // if captain want to leave from team, set another captain for team
        selectedPopup = 2;
        popupView.message.text = NSLocalizedString(SELECT_CAPTAIN_TO_LEAVE, nil);
        [leaveTeamPopup show];
    }
    else{
        selectedPopup = 4;
        popupView.message.text = NSLocalizedString(SURE_TO_LEAVE_TEAM, nil);
        [leaveTeamMemberPopup show];
    }
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    // Selected popup 1 is an remove co-captain
    // Selected popup 2 is an remove captain, so navigate to list page
    // Selected popup 3 is an remove member
    // Selected popup 4 is an leave team, member or co-captain
    // Selected popup 5 is an delete post from feeds list
    
    if (selectedPopup == 1)
    {
        [self removeCoCaptain];
    }
    else if(selectedPopup == 2){
        [leaveTeamPopup dismiss:YES];
        [self nextViewController:@"5" teamId:_teamId];
    }
    else if (selectedPopup ==3)
    {
        [removeMemberPopup dismiss:YES];
        [self removeMember];
    }
    else if (selectedPopup ==4)
    {
        [leaveTeamMemberPopup dismiss:YES];
        [self coCaptainAndMemberLeftTeam];
    }
    else if (selectedPopup == 5)
    {
        [self deleteFeedPost];
    }
    else if(selectedPopup == 6){
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[reportFeed objectForKey:@"post_owner_id"] forKey:@"friend_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BLOCKFRIEND withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [blockPopUp dismiss:YES];
                [self getFeedsList];
                [_tableView reloadData];
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
    [leaveTeamPopup dismiss:YES];
    [removeMemberPopup dismiss:YES];
    [leaveTeamMemberPopup dismiss:YES];
    [blockPopUp dismiss:YES];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:_tableView];    
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on table view at row %ld", (long)indexPath.row);
        if(_segment.selectedSegmentIndex == 1)
        {
            if (teamRelation == 1 || teamRelation == 2) {
                selectedIndex = indexPath;
                selectedPopup = 3;
                [popupView setPopupHeader:NSLocalizedString(LEAVE_TEAM, nil)];
                popupView.message.text = NSLocalizedString(SURE_TO_REMOVE, nil);
                [removeMemberPopup show];
            }
        }
        
    } else {
        NSLog(@"gestureRecognizer.state = %ld", (long)gestureRecognizer.state);
    }
}

// Remove Member
-(void)removeMember
{
    NSString *memberId = [[memberList objectAtIndex:selectedIndex.row] objectForKey:@"team_member_id"];
    NSString *memberName = [[memberList objectAtIndex:selectedIndex.row] objectForKey:@"name"];
    
    // Build Parameter
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:memberId forKey:@"team_member_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:REMOVE_TEAM_MEMBER withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            [_tableView beginUpdates];
            [memberList removeObjectAtIndex:selectedIndex.row];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndex] withRowAnimation: UITableViewRowAnimationLeft];
            [_tableView endUpdates];
            Feeds *feed = [[Feeds alloc] init];
            [feed getFeedsTypesList];
            [self addEmptyMessageForTeamTable];
            
            FriendsChat *friendsChat = [[FriendsChat alloc] init];
            friendsChat.receiverName = _teamName.text;
            friendsChat.receiverImage = teamImageUrl;
            friendsChat.receiverID = _roomId;
            [friendsChat sendMessageIfUserLeft:_roomId name1:[Util getFromDefaults:@"user_name"] name2:memberName type:@"1"];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] ];
        }
    } isShowLoader:YES];
}


//Remove Co-Captain
-(void)removeCoCaptain
{
    [yesNoPopup dismiss:YES];
    
    NSString *coCaptainId = [teamDetails objectForKey:@"co_captain_present_id"];
    NSString *coCaptainName = [teamDetails objectForKey:@"co_captain_name"];
    // Build Parameter
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:coCaptainId forKey:@"co_captain_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:REMOVE_COCAPTAIN withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            _coCaptainImage.image = [UIImage imageNamed:@"addCocaptain.png"];
            [teamDetails setValue:@"0" forKey:@"co_captain_present"];
            [_coCaptainName setText:NSLocalizedString(@"Co-Captain", nil)];
            memberpage = memberPreviousPage = 1;
            [memberList removeAllObjects];
            [self getTeamMemberList];
            
            FriendsChat *friendsChat = [[FriendsChat alloc] init];
            friendsChat.receiverName = _teamName.text;
            friendsChat.receiverImage = teamImageUrl;
            friendsChat.receiverID = _roomId;            
            [friendsChat sendMessageIfUserLeft:_roomId name1:[Util getFromDefaults:@"user_name"] name2:coCaptainName type:@"3"];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] ];
        }
    } isShowLoader:YES];
}



//Add empty message in table background view
- (void)addEmptyMessageForTeamTable{
    
    if(_segment.selectedSegmentIndex == 1) {
        if ([memberList count] == 0) {
            [Util addEmptyMessageToTableWithHeader:self.tableView withMessage:NO_MEMBERS withColor:[UIColor whiteColor]];
        }
        else{
            _tableView.tableFooterView.hidden = YES;
        }
        
    }else{
        if ([feeds count] == 0) {
            [Util addEmptyMessageToTableWithHeader:self.tableView withMessage:NO_FEEDS withColor:[UIColor whiteColor]];
        }
        else{
            _tableView.tableFooterView.hidden = YES;
        }
    }
    
}

- (IBAction)addMember:(id)sender
{
    // member can not add member
    if (teamRelation == 3) {
        NSLog(@"Member can not add new members");
    }
    else // Captain or Co-Captain can add the team member
    {
        [self nextViewController:@"3" teamId:_teamId];
    }
    
}

-(IBAction)memberSearch:(id)sender
{
    TeamMembersViewController *membersList = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamMembersViewController"];
    membersList.teamId = _teamId;
    if (teamRelation == 1 || teamRelation == 2) {
        membersList.ableToRemove = @"YES";
    }
    else{
        membersList.ableToRemove = @"NO";
    }
    [self.navigationController pushViewController:membersList animated:YES];
}

-(IBAction)addPost:(id)sender
{
    CreatePostViewController *postCreate = [self.storyboard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
    postCreate.postFromProfile = @"true";
    postCreate.isPostFromTeam = [teamDetails objectForKey:@"team_name"];
    [self.navigationController pushViewController:postCreate animated:NO];
}

-(void)coCaptainAndMemberLeftTeam
{
    // Build Parameter
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LEAVE_MEMBER_COCAPTAIN withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            FriendsChat *friendsChat = [[FriendsChat alloc] init];
            friendsChat.receiverName = _teamName.text;
            friendsChat.receiverImage = teamImageUrl;
            friendsChat.receiverID = _roomId;
            [friendsChat sendMessageIfUserLeft:_roomId name1:[Util getFromDefaults:@"user_name"] name2:@" " type:@"5"];
            
          //  [[XMPPServer sharedInstance] sendMessageforLeaveTeam:_roomId receiverName:_teamName.text image:teamImageUrl type:@"5"];
            
            ViewController *viewController = [[self.navigationController viewControllers] firstObject];
            [viewController.feedTypeList removeAllObjects];
            
            // IF member or co-captain removed from team should navigate to team list page
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] ];
        }
    } isShowLoader:YES];
}

// API Call for Get Team Members List
-(void)getTeamMemberList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:memberpage] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [self.tableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LIST_TEAM_MEMBERS withCallBack:^(NSDictionary * response){
        [self.tableView.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            if (memberpage == 1) {
                [memberList removeAllObjects];
            }
            [memberList addObjectsFromArray:[[response objectForKey:@"team_member_list"] mutableCopy]];
            [self addEmptyMessageForTeamTable];
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        memberpage = [[response valueForKey:@"page"] intValue];
        if (media_base_url == nil) {
            media_base_url = [response valueForKey:@"media_base_url"];
        }
        
        [self.tableView reloadData];
        
    } isShowLoader:NO];
    
}


//Get team details
-(void)getTeamDetails{
    
    // Build Parameter
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_DETAILS withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            media_base_url = [response objectForKey:@"media_base_url"];
            teamDetails = [[response objectForKey:@"team_details"] mutableCopy];
            teamRelation = [[teamDetails objectForKey:@"team_relation"] intValue];
            _teamName.text = [teamDetails objectForKey:@"team_name"];
            [Util makeAsLink:_teamName withColor:[UIColor whiteColor] showUnderLine:NO range:NSMakeRange(0, [_teamName.text length])];
            _captainName.text = [teamDetails objectForKey:@"captain_name"];
            [Util makeAsLink:_captainName withColor:[UIColor whiteColor] showUnderLine:NO range:NSMakeRange(0, [_captainName.text length])];
            _teamPoints.text = [teamDetails objectForKey:@"points"];
            
            _roomId =  [teamDetails objectForKey:@"jabber_id"];
            
            NSString *urlTeamImage = [NSString stringWithFormat:@"%@%@",media_base_url,[[teamDetails objectForKey:@"team_profile_image"] objectForKey:@"profile_image"]];
            teamImageUrl = urlTeamImage;
            NSString *urlCaptainImage = [NSString stringWithFormat:@"%@%@",media_base_url,[[teamDetails objectForKey:@"captain_profile_image"] objectForKey:@"profile_image"]];
            
            [_teamImage setImageWithURL:[NSURL URLWithString:urlTeamImage] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            [_captainImage setImageWithURL:[NSURL URLWithString:urlCaptainImage] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            // IF Co-Captain present should display the co-captain Image
            if([[teamDetails objectForKey:@"co_captain_present"] boolValue])
            {
                NSString *urlCoCaptainImage = [NSString stringWithFormat:@"%@%@",media_base_url,[[teamDetails objectForKey:@"co_captain_profile_image"] objectForKey:@"profile_image"]];
                [_coCaptainImage setImageWithURL:[NSURL URLWithString:urlCoCaptainImage] placeholderImage:[UIImage imageNamed:@"addCocaptain.png"]];
                [_coCaptainName setText:[teamDetails objectForKey:@"co_captain_name"]];
                [Util makeAsLink:_coCaptainName withColor:[UIColor whiteColor] showUnderLine:NO range:NSMakeRange(0, [_coCaptainName.text length])];
            }
            else
            {
                
            }
            [self setUpViews];
            
            if (teamRelation != 4) {
                [_tableView setHidden:NO];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(INVALID_OPERATION,nil)];
                [_btnAddPost setHidden:YES];
            }
            
            //Prepare data for donate
            [teamDetailsToDonate setValue:_captainName.text forKey:@"captain_name"];
            [teamDetailsToDonate setValue:[[teamDetails objectForKey:@"team_profile_image"] objectForKey:@"profile_image"] forKey:@"image_url"];
            [teamDetailsToDonate setValue:_teamName.text forKey:@"name"];
            [teamDetailsToDonate setValue:_teamPoints.text forKey:@"team_points"];
            [teamDetailsToDonate setValue:_teamId forKey:@"id"];
            
            //Disable the chat feature based on user type
            if (![[teamDetails valueForKey:@"can_chat"] boolValue]) {
                [_teamChat setHidden:YES];
                [_teamChatLabel setHidden:YES];
            }
            
            //Disable or show the redeem options based on user
            canRedeem = [[teamDetails valueForKey:@"can_redeem"] boolValue] && [Util getBoolFromDefaults:@"can_show_shoping"];
            [self createPopUpWindows];
            
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:YES];
}


#pragma mark - PointsPopup delegate

-(void)onBuyPointsClick{
    isNeedToReload = TRUE;
    [KLCpointsPopup dismiss:YES];
    BuyPointsViewController *buyPoints = [self.storyboard instantiateViewControllerWithIdentifier:@"BuyPointsViewController"];
    buyPoints.isTeamBuy = TRUE;
    buyPoints.teamId = _teamId;
    [self.navigationController pushViewController:buyPoints animated:YES];
}


-(void)onDonatePointsClick{
    isNeedToReload = TRUE;
    [KLCpointsPopup dismiss:YES];
    if (teamRelation == 1 || teamRelation == 2) {
        DonatePoint *donatePoint = [self.storyboard instantiateViewControllerWithIdentifier:@"DonatePoint"];
        donatePoint.donatorId = _teamId;
        donatePoint.donationFrom = 2;
        [self.navigationController pushViewController:donatePoint animated:YES];
    }
    else{
        //Directly move to donate form
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

        DonateForm *donateForm = [mainStoryboard instantiateViewControllerWithIdentifier:@"DonateForm"];
        donateForm.donateTo = teamDetailsToDonate;
        donateForm.donationType = 1; //For Team
        donateForm.mediaBase = media_base_url;
        donateForm.donatedFrom = 1; //From Player
        [self.navigationController pushViewController:donateForm animated:YES];
    }
}
-(void)onRedeemPointsClick{
    isNeedToReload = TRUE;
    [KLCpointsPopup dismiss:YES];
    ShoppingHome *shoppingHome = [self.storyboard instantiateViewControllerWithIdentifier:@"ShoppingHome"];
    [self.navigationController pushViewController:shoppingHome animated:YES];
}
-(void)onPointsActivityLog{
    isNeedToReload = FALSE;
    [KLCpointsPopup dismiss:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];

    PointsActivityLog *pointsLog = [mainStoryboard instantiateViewControllerWithIdentifier:@"PointsActivityLog"];
    pointsLog.teamId = _teamId;
    [self.navigationController pushViewController:pointsLog animated:YES];
}

-(BOOL)validateEditTeamName
{
    //Validate name
    if(![Util validateTextField:_editTeamName withValueToDisplay:TEAM_NAME_TITLE withIsEmailType:FALSE withMinLength:NAME_MIN withMaxLength:NAME_MAX_LEN]){
        return FALSE;
    }
    if(![Util validCharacter:_editTeamName forString:_editTeamName.text withValueToDisplay:TEAM_NAME_TITLE]){
        return FALSE;
    }
    
    if(![Util validateName:_editTeamName.text]){
        [Util showErrorMessage:_editTeamName withErrorMessage:NSLocalizedString(INVALID_TEAM_NAME, nil)];
        return FALSE;
    }
    
    return TRUE;
}

//  -------------- Update Image ------------------

#pragma mark - MediaPopup delegates methods
-(void)onCameraClick{
    [KLCMediaPopup dismiss:YES];
    isNeedToReload = FALSE;
    [self showCamera];
}

-(void)onGalleryClick{
    [KLCMediaPopup dismiss:YES];
    isNeedToReload = FALSE;
    [self openPhotoAlbum];
}

-(void)onOkClick{
    [KLCMediaPopup dismiss:YES];
}


#pragma mark - Private methods
//step 3.1 handle for camera action
- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Place image picker on the screen
            [self presentViewController:controller animated:YES completion:NULL];
        }];
        
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

//step 3.2 handle for photot action
- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Place image picker on the screen
            [self presentViewController:controller animated:YES completion:NULL];
        }];
        
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

// step 4 - Receive the image from the gallery/camera Open PECropViewController automattically when image selected
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    profilePicture = image;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [picker dismissViewControllerAnimated:YES completion:^{
                [self openEditor:nil];
            }];
        }];
        
        //  [self updateTeamImage:image];
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            // [self updateTeamImage:image];
            [self openEditor:nil];
        }];
    }
}


//step 5 - Crop the image after the user chosen
#pragma mark - Action methods
- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    
    //replace with user image
    controller.image = profilePicture;
    controller.keepingCropAspectRatio = YES;
    
    
    CGFloat width = profilePicture.size.width;
    CGFloat height = profilePicture.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - PECropViewControllerDelegate methods
//Step - 6 - Update the profile image after cropping
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    //replace with user image
    self.teamImage.image = [Util resizeProfileImage:croppedImage];
    
    //Upload image
    [self updateTeamImage:_teamImage.image];
    
}

//Step - 7 - Perform action if the image is cancelled
- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"Cancelled...!");
}


-(void)updateTeamImage:(UIImage *)image
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    NSData *imgData= UIImageJPEGRepresentation(image,0.5);
    
    [[Util sharedInstance] sendHTTPPostRequestWithImage:inputParams withRequestUrl:EDIT_TEAM_IMAGE withImage:imgData  withFileName:@"profile_image" withCallBack:^(NSDictionary *response)  {
        
        if ( response != nil && [[response valueForKey:@"status"] boolValue]) {
            _teamImage.image = image;
        }
        
    } onProgressView:nil withExtension:@"filename.jpg" ofType:@"image/jpeg"] ;
}

// 1. Set CoCaptain  2. Change CO-Captain  3. Add Member
-(void)nextViewController:(NSString *)pageType teamId:(NSString *)teamid
{
    TeamInvitiesViewController *teaminvities = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamInvitiesViewController"];
    teaminvities.teamId = teamid;
    teaminvities.type = pageType;
    teaminvities.roomId = _roomId;
    teaminvities.teamName = _teamName.text;
    teaminvities.teamImage = teamImageUrl;
    teaminvities.coCaptainName = _coCaptainName.text;
    [self.navigationController pushViewController:teaminvities animated:YES];
}


#pragma mark - UITableViewDelegate method
//set number of rows in tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _segment.selectedSegmentIndex == 0 ? [feeds count] : [memberList count];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}


#pragma mark - UITableViewDelegate method
//set tableview content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
   
    static NSString *cellIdentifier = @"";
    
    if (_segment.selectedSegmentIndex == 0) // Feed List
    {
        FeedCell *fcell;
        if ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"is_team_activity"] boolValue]) {
            cellIdentifier = @"TeamFeedCell";
            fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (fcell == nil)
            {
                fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            fcell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            fcell.name.delegate = self;
            NSDictionary *Values = [[feeds objectAtIndex:indexPath.row] objectForKey:@"activity"] ;
            [Util createTeamActivityLabel:fcell.name fromValues:Values];
            fcell.date.text = [Util timeStamp:[[[feeds objectAtIndex:indexPath.row] objectForKey:@"time_stamp"] longValue]];
        }
        else
        {
            if([feeds count] > 0){
                
                cellIdentifier= ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feeds objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"FeedCell" : @"MessagesCell";
                fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (fcell == nil)
                {
                    fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                
                feedsDesign.feeds = feeds;
                feedsDesign.feedTable = tableView;
                feedsDesign.mediaBaseUrl= mediaBaseUrl;
                feedsDesign.viewController = self;
                
                [feedsDesign designTheContainerView:fcell forFeedData:[feeds objectAtIndex:indexPath.row] mediaBase:mediaBaseUrl forDelegate:self tableView:tableView];
                
            }
        }
         fcell.backgroundColor = [UIColor clearColor];
        return  fcell;
    }
    else  // Member List
    {
        cellIdentifier = @"FriendCell";
        FriendCell *frndCell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];

        if(frndCell == nil)
        {
            frndCell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        frndCell.backgroundColor = [UIColor clearColor];
        frndCell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        NSDictionary *list = [memberList objectAtIndex:indexPath.row];
        
        frndCell.name.text = [list objectForKey:@"name"];
        frndCell.points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[list objectForKey:@"point"]];
        NSString *rankLabel = [Util playerType:[[list valueForKey:@"player_type_id"] intValue] playerRank:[list objectForKey:@"rank"]];
        frndCell.rankLabel.text = rankLabel;
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",media_base_url,[list objectForKey:@"profile_image"]];
        [frndCell.profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        
        strURL = [NSString stringWithFormat:@"%@%@",media_base_url,[list objectForKey:@"player_skate_pic"]];
        [frndCell.board setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return frndCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_segment.selectedSegmentIndex == 0) {
        // Feed list
    }
    else{
        [self showProfileScreen:[memberList objectAtIndex:indexPath.row]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [feedsDesign checkWhichVideoToEnable:_tableView];

}
-(void)showProfileScreen :(NSMutableDictionary *)selectedValues
{
    if ([[selectedValues valueForKey:@"my_self"] boolValue]) {
        MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
        [self.navigationController pushViewController:myProfile animated:YES];
    }
    else{
        FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        friendProfile.friendId = [selectedValues valueForKey:@"team_member_id"];
        friendProfile.friendName = [selectedValues valueForKey:@"name"];
        [self.navigationController pushViewController:friendProfile animated:YES];
    }
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
    
    NSString *strUrl = [url absoluteString];
    if (label == _teamName) {
        [self showTeamEditPopup];
    }
    else if (label == _captainName){
        [self showCaptainProfile];
    }
    else if (label == _coCaptainName){
        [self showCoCaptainProfile];
    }
    else if (![strUrl isEqualToString:@""]) {
        
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
                if (![[array objectAtIndex:2] isEqualToString:_teamId]) { //check current team
                    [self.navigationController pushViewController:teamView animated:YES];
                }
            }
        }
        else{
            //Open Url
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else{
        
        CGPoint position = [label convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
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
                    [_tableView reloadData];
                }else{
                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                }
            } isShowLoader:NO];
        }
    }
    
}

-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer
{
    // Get selected Index
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSString *ownerId = [[feeds objectAtIndex:indexPath.row] valueForKey:@"post_owner_id"];
    if ( [[Util getFromDefaults:@"player_id"] isEqualToString:ownerId]) {
        MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
        [self.navigationController pushViewController:myProfile animated:YES];
    }
    else{
        FriendProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        profile.friendId = [[feeds objectAtIndex:indexPath.row] objectForKey:@"post_owner_id"];
        profile.friendName = [[feeds objectAtIndex:indexPath.row] objectForKey:@"name"];
        [self.navigationController pushViewController:profile animated:YES];
    }
}

-(void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    UIMenuController *menucontroller=[UIMenuController sharedMenuController];
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
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

- (void) copy:(id) sender {
    // called when copy clicked in menu
}
- (void) menuItemClicked:(id) sender {
    // called when Item clicked in menu
}
- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(DeletePost:) /*|| selector == @selector(copy:)*/ /*<--enable that if you want the copy item */) {
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
    [popupView setPopupHeader:NSLocalizedString(FEED, nil)];
    
    if([[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_local"]  isEqualToString:@"true"])
    {
        popupView.message.text = NSLocalizedString(CANCEL_FOR_SURE, nil);
        isDelete = FALSE;
    }
    else{
        popupView.message.text = NSLocalizedString(DELETE_FOR_SURE, nil);
        isDelete = TRUE;
    }
    selectedPopup = 5;
    [yesNoPopup show];
}

-(void)deleteFeedPost
{
    [yesNoPopup dismiss:YES];
    
    if (isDelete) {
        NSString *strPostId = [NSString stringWithFormat:@"%@",[[feeds objectAtIndex:menuPosition.row] objectForKey:@"post_id"]];
        
        [_tableView beginUpdates];
        [feeds removeObjectAtIndex:menuPosition.row];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
        [_tableView endUpdates];
        
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
    else{
        
        // Cancel Local Feeds
        if([[[feeds objectAtIndex:menuPosition.row] objectForKey:@"is_local"]  isEqualToString:@"true"])
        {
            [_tableView beginUpdates];
            NSURLSessionTask *task = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"task"];
            [task cancel];
            [feeds removeObjectAtIndex:menuPosition.row];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
            [_tableView endUpdates];
        }
        else{
            //[[AlertMessage sharedInstance] showMessage:NSLocalizedString(@"The post is uploaded you can't cancel now", nil)];
        }
    }
}

// ------------- Delete post End  ----------------

// Click Star & Unstar
- (IBAction)Star:(id)sender
{
    [feedsDesign addStar:self.tableView fromArray:feeds forControl:sender];
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender
{
    [feedsDesign addBookmark:self.tableView fromArray:feeds forControl:sender];
}

// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tableView];
        NSIndexPath *path = [_tableView indexPathForRowAtPoint:buttonPosition];
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
    NSString *strPostId = @"0";
    NSString *timeStamp = @"0";
    
    if ([feeds count] != 0) {
        NSMutableDictionary *lastIndex = [feeds lastObject];
        strPostId = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"post_id"]];
        timeStamp = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"time_stamp"]];
    }
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:strPostId forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"1" forKey:@"team_post"];
    [inputParams setValue:_teamId forKey:@"post_type_id"];
    [inputParams setValue:@"0"  forKey:@"recent"];
    [inputParams setValue:timeStamp  forKey:@"time_stamp"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
            [self alterTheMediaList:response];
            //show empty message
            [self addEmptyMessageForTeamTable];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:NO];
}


//Append the media url with base
- (void)alterTheMediaList:(NSDictionary *)response{
    
    for (int i=0; i< [[response objectForKey:@"feed_list"] count]; i++) {
        NSMutableDictionary *dict = [[[response objectForKey:@"feed_list"] objectAtIndex:i] mutableCopy];
        
        [dict setValue:@"false" forKey:@"is_local"];
        [dict setValue:@"false" forKey:@"is_upload"];
        [dict setValue:@"" forKey:@"task_identifier"];
        [dict setValue:@"" forKey:@"task"];
        [dict setValue:@"true" forKey:@"isEnabled"];
        
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
    [_tableView reloadData];
    
}

-(void)reportButtonAction:(UITapGestureRecognizer *)tapRecognizer{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        reportFeed = [feeds objectAtIndex:indexPath.row];
        
        [self.reportPopover dismissMenuPopover];
        
        self.reportPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 65 - _tableView.contentOffset.y, 140, 84) menuItems:@[NSLocalizedString(REPORT_THE_POST,nil),NSLocalizedString(BLOCK_THE_USER, nil)]];
        self.reportPopover.menuPopoverDelegate = self;
        self.reportPopover.tag = 101;
        [self.reportPopover showInView:self.view];
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
            [_tableView beginUpdates];
            [feeds removeObject:reportFeed];
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView endUpdates];
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
    } isShowLoader:YES];
}


@end
