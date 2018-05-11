//
//  FriendsNotification.m
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "FriendsNotification.h"
#import "ViewController.h"

@interface FriendsNotification ()

@end

@implementation FriendsNotification
@synthesize page,generalPage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    _isFriendNotification = TRUE;
    
    notificationList = [[NSMutableArray alloc] init];
    page = previousPage = 1;
    
    generalNotification = [[NSMutableArray alloc] init];
    generalPage= generalPreviousPage = 1;
//    [self setInfiniteScrollForTableView];
//    [self designTheView];
//    [self createPopUpWindows];
    
     //Register for get notifacation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotificationCount:) name:@"TeamNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotificationCount:) name:@"GeneralNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotificationCount:) name:@"FriendNotification" object:nil];
    [self showBatchCountforFriend:[Util getFromDefaults:@"friendNotificationCount"] forGlobal:[Util getFromDefaults:@"globalNotificationCount"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisplayAd:) name:@"AdShown" object:nil];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    self.myHeaderView.delegate = self;
    [self.myHeaderView setBackHidden:NO];
    [self.myHeaderView setHeader:NSLocalizedString(NOTIFICATIONS, nil)];
    [self.myHeaderView.logo setHidden:YES];
}

- (void) didDisplayAd:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    BOOL remove = [[userInfo objectForKey:@"remove"] boolValue];
    if (remove) {
        _requestTableBottom.constant = 0;
        _generalTableBottom.constant = 0;
    } else {
        CGFloat height = [[userInfo objectForKey:@"height"] floatValue];
        _requestTableBottom.constant = height;
        _generalTableBottom.constant = height;
    }
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)showTable{
    if(_isFriendNotification)
    {
        [_requestTable setHidden:NO];
        [_generalTable setHidden:YES];
    }
    else{
        [_requestTable setHidden:YES];
        [_generalTable setHidden:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self showTable];

    //    [self setInfiniteScrollForTableView];
    [self designTheView];
    [self createPopUpWindows];

    [self reloadList];
    
    
    // Load from Session
    [_friendTab setBadgeValue:nil];
    
    NSDictionary *List = [[NSUserDefaults standardUserDefaults] objectForKey:@"FriendNotificationList"];
    if (List != nil) {
        mediaBase = [List valueForKey:@"base_url"];
        NSMutableArray *notifications = [[List objectForKey:@"friend_notifications"] mutableCopy];
        //[self convertNotifications:notifications];
        for (int i=0; i<[notifications count]; i++) {
            NSMutableDictionary *notification = [[notifications objectAtIndex:i] mutableCopy];
            [notificationList addObject:notification];
        }
        [_requestTable reloadData];
        [self addEmptyMessageToFriendsTable];
    }
    
    // Show List From Session
    NSDictionary *generalList = [[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralNotificationList"];
    if (generalList != nil) {
        mediaBase = [generalList valueForKey:@"media_base_url"];
        NSMutableArray *notifications = [[generalList objectForKey:@"general_notification_details"] mutableCopy];
        for (int i=0; i<[notifications count]; i++) {
            NSMutableDictionary *notification = [[notifications objectAtIndex:i] mutableCopy];
            [generalNotification addObject:notification];
        }
        [_generalTable reloadData];
        [self addEmptyMessageToGeneraTable];
    }
    
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];

}

- (void)viewWillDisappear:(BOOL)animated {
    [[GoogleAdMob sharedInstance] removeLastAd];

    [super viewWillDisappear:animated];
}

- (void) createPopUpWindows{
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(CONFIRMATION, nil)];
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    teamPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    [self acceptTeam];
}

- (void)onNoClick{
    [teamPopup dismiss:YES];
}

- (void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FriendNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeneralNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TeamNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AdShown" object:nil];
}

//Get the notification data
- (void)processIncomingNotificaiton:(NSNotification *) data{
    NSLog(@"Process notication");
    [self reloadList];
}

- (void)designTheView{
    
    _tabBar.delegate = self;
    [_tabBar setSelectionIndicatorImage:[Util convertColorToImage:UIColorFromHexCode(THEME_COLOR) byDivide:2 withHeight:60]];
    [_tabBar setTintColor:[UIColor whiteColor]];
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont fontWithName:@"CenturyGothic" size:13], NSFontAttributeName,
//                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
//    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [self setInitialScreen];
    [self showTable];
    
    //Set transparent color to tableview
    [self.requestTable setBackgroundColor:[UIColor clearColor]];
    self.requestTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Set transparent color to tableview
    [self.generalTable setBackgroundColor:[UIColor clearColor]];
    self.generalTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.friendTab.title = NSLocalizedString(@"Friends Request", nil);
    self.globalTab.title = NSLocalizedString(@"Global Notifications", nil);
}

//Set initial tab to be selected
-(void)setInitialScreen
{
    if(!([[Util getFromDefaults:@"friendNotificationCount"] isEqualToString:@""] ||  [[Util getFromDefaults:@"friendNotificationCount"] isEqualToString:@"0"]))
    {
        [_tabBar setSelectedItem:_friendTab];
        [self showFriendNotification:YES];
    }
    else if(!([[Util getFromDefaults:@"globalNotificationCount"] isEqualToString:@""] ||  [[Util getFromDefaults:@"globalNotificationCount"] isEqualToString:@"0"]))
    {
        [_tabBar setSelectedItem:_globalTab];
        [self showFriendNotification:NO];
    }
    else{
        [_tabBar setSelectedItem:_friendTab];
        [self showFriendNotification:YES];
    }
}

//Reload the list while receiving a notification
- (void) reloadList{
    
    [self setInfiniteScrollForTableView];
    
    if (_isFriendNotification) {
        //reload the page once we back to this page
        page = previousPage = 1;
        [notificationList removeAllObjects];
        [self getFriendNotificationList];
    }
    else
    {
        //reload the page once we back to this page
        generalPage = generalPreviousPage = 1;
        [generalNotification removeAllObjects];
        [self getGeneralNotificationList];
    }
    
}

//Add empty message in table background view
- (void)addEmptyMessageToFriendsTable{
  
        if ([notificationList count] == 0) {
            [Util addEmptyMessageToTable:_requestTable withMessage:NO_NOTIFICATION withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
        }
        else{
            [Util addEmptyMessageToTable:_requestTable withMessage:@"" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
        }
    }
- (void)addEmptyMessageToGeneraTable{
        if ([generalNotification count] == 0) {
            [Util addEmptyMessageToTable:_generalTable withMessage:NO_NOTIFICATION withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
        }
        else{
            [Util addEmptyMessageToTable:_generalTable withMessage:@"" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
        }
}

-(void)getFriendNotificationList{
    
    //Send friend notification list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
   // [self.requestTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FRIEND_NOTIFICATION_LIST withCallBack:^(NSDictionary * response){
        [self.requestTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            
            if(mediaBase == nil)
                mediaBase = [response valueForKey:@"base_url"];
            
            if (page == 1) {
                [notificationList removeAllObjects];
                [Util setInDefaults:response withKey:@"FriendNotificationList"];
            }
            NSMutableArray *notifications = [[response objectForKey:@"friend_notifications"] mutableCopy];
            
            page = [[response valueForKey:@"page"] intValue];
            [self convertFriendsNotifications:notifications];
        }
        else{
            
        }
    } isShowLoader:NO];
    
}

-(void)getGeneralNotificationList{
    //Send general notification list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:generalPage] forKey:@"page"];
    
   // [self.generalTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GENERAL_NOTIFICATION_LIST withCallBack:^(NSDictionary * response){
        [self.generalTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            if(mediaBase == nil)
                mediaBase = [response valueForKey:@"media_base_url"];
            if (generalPage == 1) {
                [generalNotification removeAllObjects];
                [Util setInDefaults:response withKey:@"GeneralNotificationList"];
            }
            NSMutableArray *notifications = [[response objectForKey:@"general_notification_details"] mutableCopy];
            [self convertGeneralNotifications:notifications];
            generalPage = [[response valueForKey:@"page"]intValue];
        }
        else{
            
        }
    } isShowLoader:NO];

}

-(void)getNotificationListToSave:(BOOL)isFriendNotification{
    
    if(isFriendNotification)
    {
        //Send friend notification list request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FRIEND_NOTIFICATION_LIST withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                if(mediaBase == nil)
                    mediaBase = [response valueForKey:@"base_url"];
                
                if (page == 1) {
                    [Util setInDefaults:response withKey:@"FriendNotificationList"];
                }
            }
            else{
                
            }
        } isShowLoader:NO];
    }
    else
    {
        //Send general notification list request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[NSNumber numberWithInt:generalPage] forKey:@"page"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GENERAL_NOTIFICATION_LIST withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                
                if (generalPage == 1) {
                    [Util setInDefaults:response withKey:@"GeneralNotificationList"];
                }
            }
            else{
                
            }
        } isShowLoader:NO];
    }
}

//Convert the notification
- (void)convertFriendsNotifications:(NSMutableArray *)notifications{
    for (int i=0; i<[notifications count]; i++) {
        NSMutableDictionary *notification = [[notifications objectAtIndex:i] mutableCopy];
        [notification setValue:[NSNumber numberWithBool:NO] forKey:@"isFriendAccept"];
        int index = [Util getMatchedObjectPosition:@"notification_id" valueToMatch:[notification valueForKey:@"notification_id"] from:notificationList type:0];
        
        if (index == -1) {
            [notificationList addObject:notification];
        }
        
    }
    [_requestTable reloadData];
    [self addEmptyMessageToFriendsTable];
}

- (void)convertGeneralNotifications:(NSMutableArray *)notifications{
    for (int i=0; i<[notifications count]; i++) {
        NSMutableDictionary *notification = [[notifications objectAtIndex:i] mutableCopy];
        [notification setValue:[NSNumber numberWithBool:NO] forKey:@"isTeamAccept"];
        int index = [Util getMatchedObjectPosition:@"notification_id" valueToMatch:[notification valueForKey:@"notification_id"] from:generalNotification type:0];
        if (index == -1) {
            [generalNotification addObject:notification];
        }
    }
    [_generalTable reloadData];
    [self addEmptyMessageToGeneraTable];
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak FriendsNotification *weakSelf = self;
    // setup infinite scrolling
    [self.requestTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
  //  [self.requestTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    __weak FriendsNotification *generalWeakSelf = self;
    // setup infinite scrolling
    [self.generalTable addInfiniteScrollingWithActionHandler:^{
        [generalWeakSelf insertRowAtBottom];
    }];
  //  [self.generalTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
}

//Add load more items
- (void)insertRowAtBottom {
    
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak FriendsNotification *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getFriendNotificationList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.requestTable.infiniteScrollingView stopAnimating];
    }
    
    if(generalPage > 0 && generalPage != generalPreviousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak FriendsNotification *generalWeakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            generalPreviousPage = generalPage;
            [generalWeakSelf getGeneralNotificationList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.generalTable.infiniteScrollingView stopAnimating];
    }
}


// Action for accept/cancel button in tableview
- (IBAction)sendAcceptRejectRequest:(UIButton *)sender
{
    if(_isFriendNotification)
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.requestTable];
        NSIndexPath *path = [self.requestTable indexPathForRowAtPoint:buttonPosition];
        BOOL accStatus = TRUE;
        accStatus = sender.tag == 100 ? TRUE : FALSE;
        
        //Send friend notification list request
        //Build Input Parameters
        if([notificationList count] > path.row)
        {
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            NSDictionary *rowValue = [notificationList objectAtIndex:path.row];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            [inputParams setValue:[NSNumber numberWithBool:accStatus] forKey:@"accept_flag"];
            [inputParams setValue:[rowValue valueForKey:@"friend_id"] forKey:@"friend_id"];
            
            [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ACCEPT_REJECT withCallBack:^(NSDictionary * response){
                
                if([[response valueForKey:@"status"] boolValue]){
                    if (accStatus) {
                        [self changeTheRequestStatus:path];
                    }
                    else{ //Remove the record if we reject the request
                        if ([notificationList count] > path.row) {
                            [_requestTable beginUpdates];
                            [notificationList removeObjectAtIndex:path.row];
                            [_requestTable deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
                            [_requestTable endUpdates];
                            [self addEmptyMessageToFriendsTable];
                        }
                    }
                    // Update local Storage
                    [LocalStorageManager localStorage:@"FRIENDNOTIFICATION" Response:notificationList feedType:0];
                }
                else{
                    //Remove the record if we perform invalid action
                    if ([[response valueForKey:@"action_expired_flag"] boolValue]) {
                        if ([notificationList count] > path.row) {
                            [_requestTable beginUpdates];
                            [notificationList removeObjectAtIndex:path.row];
                            [_requestTable deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
                            [_requestTable endUpdates];
                            [self addEmptyMessageToFriendsTable];
                        }
                    }
                    [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
                }
            } isShowLoader:YES];
        }
    }
    else
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.generalTable];
        selectedIndexPath = [self.generalTable indexPathForRowAtPoint:buttonPosition];
        
        if([generalNotification count] > selectedIndexPath.row){
            status = sender.tag == 100 ? 1 : 0;
            rowValue = [generalNotification objectAtIndex:selectedIndexPath.row];
            if (status == 1)
            {
                popupView.message.text = [NSString stringWithFormat:NSLocalizedString(JOIN_TEAM, nil),[rowValue objectForKey:@"team_name"],[rowValue objectForKey:@"team_join__minimum_point"]];
                [teamPopup show];
            }
            else
            {
                [self acceptTeam];
            }
        }
    }
}

- (void)changeTheRequestStatus:(NSIndexPath *)path{
    if(_isFriendNotification)
    {
        if ([notificationList count] > path.row) {
            //Change status
            NSMutableDictionary *notification = [[notificationList objectAtIndex:path.row] mutableCopy];
            [notification setValue:[NSNumber numberWithBool:YES] forKey:@"isFriendAccept"];
            [notificationList replaceObjectAtIndex:path.row withObject:notification];
            //Reload the cell
            [_requestTable beginUpdates];
            [_requestTable reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            [_requestTable endUpdates];
            [self addEmptyMessageToFriendsTable];
        }
    }
    else
    {
        if ([generalNotification count] > path.row) {
            //Change status
            NSMutableDictionary *notification = [[generalNotification objectAtIndex:path.row] mutableCopy];
            [notification setValue:[NSNumber numberWithBool:YES] forKey:@"isTeamAccept"];
            [generalNotification replaceObjectAtIndex:path.row withObject:notification];
            //Reload the cell
            [_generalTable beginUpdates];
            [_generalTable reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            [_generalTable endUpdates];
            [self addEmptyMessageToFriendsTable];
        }
    }
}

// Action for accept/cancel button in tableview
- (IBAction)showFriendProfile:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.requestTable];
    NSIndexPath *path = [self.requestTable indexPathForRowAtPoint:buttonPosition];
    [self moveToFriendProfile:path];
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _requestTable)
        return [notificationList count];
    else
        return [generalNotification count];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    if(tableView ==_requestTable)
        return 90;
    else
        return UITableViewAutomaticDimension;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView ==_requestTable)
        return 90;
    else
        return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _requestTable)
    {
        static NSString *cellIdentifier = @"friendRequestCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        //Read elements
        UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
        UILabel *name = [cell viewWithTag:11];
        UILabel *message = [cell viewWithTag:12];
        UIView *confirmView = [cell viewWithTag:20];
        UIView *cancelView = [cell viewWithTag:21];
        UIView *friendView = [cell viewWithTag:22];
        UIButton *confirmButton = [cell viewWithTag:100];
        UIButton *cancelButton = [cell viewWithTag:101];
        UIButton *friendsButton = [cell viewWithTag:102];
        
        //Add rounded corner
        [Util createRoundedCorener:confirmView withCorner:3];
        [Util createRoundedCorener:cancelView withCorner:3];
        [Util createRoundedCorener:friendView withCorner:3];
        
        if ([notificationList count] > indexPath.row) {
            
            NSDictionary *request = [notificationList objectAtIndex:indexPath.row];
            if (![[request valueForKey:@"isFriendAccept"] boolValue]) {
                if ([[request valueForKey:@"friend_request_flag"] boolValue]) {
                    [message setHidden:YES];
                    [confirmView setHidden:NO];
                    [cancelView setHidden:NO];
                }else{
                    message.text = [request valueForKey:@"message"];
                    [message setHidden:NO];
                    [confirmView setHidden:YES];
                    [cancelView setHidden:YES];
                }
                [friendView setHidden:YES];
            }else{
                [message setHidden:YES];
                [friendView setHidden:NO];
//                [Util createBorder:friendView withColor:UIColorFromHexCode(THEME_COLOR)];
                [confirmView setHidden:YES];
                [cancelView setHidden:YES];
            }
            
            name.text = [request valueForKey:@"name"];
            
            
            //Remove all targets
            [confirmButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [cancelButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            
            //Add button click events
            [confirmButton addTarget:self action:@selector(sendAcceptRejectRequest:) forControlEvents:UIControlEventTouchUpInside];
            [cancelButton addTarget:self action:@selector(sendAcceptRejectRequest:) forControlEvents:UIControlEventTouchUpInside];
            [friendsButton addTarget:self action:@selector(showFriendProfile:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[[notificationList objectAtIndex:indexPath.row] valueForKey:@"profile_image"]];
            [profile setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            //Add zoom
            //[[Util sharedInstance] addImageZoom:profile];
        }
        
        
        return cell;

    }
    else{
        static NSString *cellIdentifier = @"generalCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        //Read elements
        UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
        UILabel *title =  (UILabel *)[cell viewWithTag:11];
        UILabel *description = (UILabel *) [cell viewWithTag:12];
        UILabel *timeStamp = (UILabel *) [cell viewWithTag:13];
        UIView *confirmView = [cell viewWithTag:20];
        UIView *cancelView = [cell viewWithTag:21];
        UIView *memberView = [cell viewWithTag:22];
        UIButton *confirmButton = [cell viewWithTag:100];
        UIButton *cancelButton = [cell viewWithTag:101];
        UIButton *memberButton = [cell viewWithTag:102];
        
        [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [confirmButton setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
        [memberButton setTitle:NSLocalizedString(@"Members", nil) forState:UIControlStateNormal];

        
        //Add rounded corner
        [Util createRoundedCorener:confirmView withCorner:3];
        [Util createRoundedCorener:cancelView withCorner:3];
        
        if([generalNotification count] > indexPath.row)
        {
            NSDictionary *notification = [generalNotification objectAtIndex:indexPath.row];
            
            [confirmView hideByHeight:NO];
            [cancelView hideByHeight:NO];
            [cancelView setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
            [confirmView setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
            
            if (![[notification valueForKey:@"isTeamAccept"] boolValue]) {
                if ([[notification objectForKey:@"team_request_flag"] boolValue]) {
                    [confirmView hideByHeight:NO];
                    [cancelView hideByHeight:NO];
                    [cancelView setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
                    [confirmView setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
                }
                else
                {
                    [confirmView hideByHeight:YES];
                    [cancelView hideByHeight:YES];
                }
                [memberView hideByHeight:YES];
            }
            else{
                [confirmView setHidden:YES];
                [cancelView setHidden:YES];
                [memberView hideByHeight:NO];
                [memberView setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
                [Util createBorder:memberView withColor:UIColorFromHexCode(THEME_COLOR)];
            }
            
            //Add button click events
            [confirmButton addTarget:self action:@selector(sendAcceptRejectRequest:) forControlEvents:UIControlEventTouchUpInside];
            [cancelButton addTarget:self action:@selector(sendAcceptRejectRequest:) forControlEvents:UIControlEventTouchUpInside];
            [memberButton addTarget:self action:@selector(showTeamProfile:) forControlEvents:UIControlEventTouchUpInside];
            
            //Bind the values into elements
            title.text = [notification valueForKey:@"player_name"];
            description.text = [notification valueForKey:@"message"];
            timeStamp.text = [Util timeStamp:[[notification valueForKey:@"time_stamp"] longValue]];
            NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[notification valueForKey:@"profile_image_url"]];
            
            [profile setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            //Add zoom
            //[[Util sharedInstance] addImageZoom:profile];
            
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile:)];
            
            if ([notification objectForKey:@"player_id"] != nil) {
                [profile setUserInteractionEnabled:YES];
                [profile addGestureRecognizer:tapProfileImage];
            }
            else
            {
                [profile setUserInteractionEnabled:NO];
                [profile removeGestureRecognizer:tapProfileImage];
            }
            
        }
        return cell;
    }
}


//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _requestTable)
    {
        if ([notificationList count] > indexPath.row) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self moveToFriendProfile:indexPath];
        }
    }
    else{
        if ([generalNotification count] > indexPath.row) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSDictionary *notification = [generalNotification objectAtIndex:indexPath.row];
            if ([[notification valueForKey:@"isTeamAccept"] boolValue]) {
                TeamViewController *teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
                teamView.teamId = [notification valueForKey:@"redirection_id"];
                [self.navigationController pushViewController:teamView animated:YES];
            }
            else{
                [[RedirectNotification sharedInstance] redirectGeneralNotificationTo:[[notification valueForKey:@"redirection_type"] intValue] withObject:notification];
            }
        }
    }
    
}

- (void)moveToFriendProfile:(NSIndexPath *)indexPath{
    if ([notificationList count] > indexPath.row) {
        NSDictionary *friend = [notificationList objectAtIndex:indexPath.row];
        FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        friendProfile.friendId = [friend valueForKey:@"friend_id"];
        friendProfile.friendName = [friend valueForKey:@"name"];
        [self.navigationController pushViewController:friendProfile animated:YES];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item.tag == 1)
        [self showFriendNotification:YES];
    else
        [self showFriendNotification:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"RemoveBadge" object:nil ];
}

-(void)showFriendNotification:(BOOL)friendNotification
{
    _isFriendNotification = friendNotification;
    
    [self showTable];
    if(friendNotification)
    {
        if (page != -1) {
            [self getFriendNotificationList];
        }
        [_friendTab setBadgeValue:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"friendNotificationCount"];
        [[Util sharedInstance] resetNotificationCount:2];
    }
    else
    {
        if (generalPage != -1) {
            [self getGeneralNotificationList];
        }
        [_globalTab setBadgeValue:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"globalNotificationCount"];
        [[Util sharedInstance] resetNotificationCount:1];
    }
}
-(void)acceptTeam
{
    [teamPopup dismiss:YES];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:status] forKey:@"accept_flag"];
    [inputParams setValue:[rowValue valueForKey:@"redirection_id"] forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ACCEPT_REJECT_TEAM withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            if (status) {
                
                //Reload Team list api for Team chat
                AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
                [[XMPPServer sharedInstance].arrayInvitation addObject:[rowValue valueForKey:@"redirection_id"]];
                [appDelegate getTeamList];

                [self changeTheRequestStatus:selectedIndexPath];
                ViewController *viewController = [[self.navigationController viewControllers] firstObject];
                [viewController.feedTypeList removeAllObjects];
                Feeds *feed = [[Feeds alloc] init];
                [feed getFeedsTypesList];
            }
            else{ //If we cancel the request
                if ([generalNotification count] > selectedIndexPath.row) {
                    [_generalTable beginUpdates];
                    [generalNotification removeObjectAtIndex:selectedIndexPath.row];
                    [_generalTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    [_generalTable endUpdates];
                }
            }
            // Update local Storage
            [LocalStorageManager localStorage:@"GLOBALNOTIFICATION" Response:generalNotification feedType:0];
        }
        else{
            //Remove the record if we perform invalid action
            if ([[response valueForKey:@"action_expired_flag"] boolValue]) {
                if ([generalNotification count] > selectedIndexPath.row) {
                    [_generalTable beginUpdates];
                    [generalNotification removeObjectAtIndex:selectedIndexPath.row];
                    [_generalTable deleteRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    [_generalTable endUpdates];
                    [self addEmptyMessageToGeneraTable];
                }
            }
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:YES];
}
// Action for accept/cancel button in tableview
- (IBAction)showTeamProfile:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.generalTable];
    NSIndexPath *path = [self.generalTable indexPathForRowAtPoint:buttonPosition];
    
    if ([generalNotification count] > path.row) {
        
        NSMutableDictionary *notification = [generalNotification objectAtIndex:path.row];
        
        TeamViewController *teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
        teamView.teamId = [notification valueForKey:@"redirection_id"];
        [self.navigationController pushViewController:teamView animated:YES];
    }
}

-(void)showProfile:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint tapPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.generalTable];
    NSIndexPath *indexPath = [self.generalTable indexPathForRowAtPoint:tapPosition];
    NSMutableDictionary *notificationDetail = [generalNotification objectAtIndex:indexPath.row];
    
    
    if ([[notificationDetail objectForKey:@"my_self"] intValue] == 1) {
        
        MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
        [self.navigationController pushViewController:myProfile animated:YES];
    }
    else
    {
        FriendProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        profile.friendId = [notificationDetail objectForKey:@"player_id"];
        profile.friendName = [notificationDetail objectForKey:@"player_name"];
        [self.navigationController pushViewController:profile animated:YES];
    }
}
-(void)showBatchCountforFriend:(NSString*)friend forGlobal:(NSString*)global{

    if ([friend isEqualToString:@"0"]  || [friend isEqualToString:@""])
        [_friendTab setBadgeValue:nil];
    else
        [_friendTab setBadgeValue:[self getFormatedCount:[friend intValue]]];
    
    
    if ([global isEqualToString:@"0"] || [global isEqualToString:@""])
        [_globalTab setBadgeValue:nil];
    else
        [_globalTab setBadgeValue:[self getFormatedCount:[global intValue]]];
}

//change notification count
-(void) processNotificationCount:(NSNotification *) data{
    
    ViewController *viewController = [[self.navigationController viewControllers] firstObject];
    if(viewController.tabBar.selectedItem.tag == 1)
    {
        NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
        NSMutableDictionary *body = [[notificationContent objectForKey:@"data"] mutableCopy];
        if ([[notificationContent objectForKey:@"type"] isEqualToString:@"general_notification"] || [[notificationContent objectForKey:@"type"] isEqualToString:@"team_notification"]) {
            if (_tabBar.selectedItem.tag != 2) {
                _isFriendNotification = FALSE;
                generalPage = 1;
                [self getNotificationListToSave:FALSE];
                [[NSUserDefaults standardUserDefaults] setObject:[body valueForKey:@"general_notification_count"] forKey:@"globalNotificationCount"];
                [self showBatchCountforFriend:@"" forGlobal:[body valueForKey:@"general_notification_count"]];
            }
        }
        else if([[notificationContent objectForKey:@"type"] isEqualToString:@"friend_notification"]){
            if (_tabBar.selectedItem.tag != 1) {
                _isFriendNotification = TRUE;
                page = 1;
                [self getNotificationListToSave:TRUE];
                [[NSUserDefaults standardUserDefaults] setObject:[body valueForKey:@"friend_notification_count"] forKey:@"friendNotificationCount"];
                [self showBatchCountforFriend:[body valueForKey:@"friend_notification_count"] forGlobal:@""];
            }
        }
        [self reloadList];
        if(_tabBar.selectedItem == _friendTab){
            [self showFriendNotification:YES];
        }
        else if(_tabBar.selectedItem == _globalTab){
            [self showFriendNotification:NO];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName: @"RemoveBadge" object:nil ];
    }
}

//Convert the count
-(NSString *)getFormatedCount:(int)count{
    NSString *countString = count > 9 ? @"9+" : [NSString stringWithFormat:@"%d",count];
    return [countString isEqualToString:@"0"] ? @"" : countString;
}

@end
