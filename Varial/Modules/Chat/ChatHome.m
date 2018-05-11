//
//  ChatHome.m
//  ChatApplication
//
//  Created by Shanmuga priya on 5/9/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "ChatHome.h"
#import "MyFriends.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "Util.h"
#import "DBManager.h"
#import "ChatDBManager.h"
#import "InviteFriends.h"
#import "XMPPServer.h"
#import "AlertMessage.h"
#import "CreateTeam.h"
#import "ViewController.h"

@interface ChatHome (){
    NSMutableDictionary *userData;
    NSMutableArray *friendsList;
    AppDelegate *appDelegate;
}

@end

@implementation ChatHome
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    menuArray = [[NSMutableArray alloc] init];
    conversations = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self designTheView];
    [self createPopUpWindows];
    [self registerForNotification];
    
    //Add Long press
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [_chatTableView addGestureRecognizer:lpgr];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    if([conversations count] == 0)
    {
        [view setHidden:NO];
        [view removeFromSuperview];
        if(IPAD)
            view = [[Util sharedInstance]drawArrowwithxCord:self.label.center.x yCord:self.label.center.y+250];
        else
            view = [[Util sharedInstance]drawArrowwithxCord:140 yCord:230];
        [self.view addSubview:view];
    }
    else
    {
        [view setHidden:YES];
    }
    
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    _chatTableView.userInteractionEnabled = TRUE;
    [appDelegate refreshNotification];
    [self getTeamList];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    friendsList = [[defaults objectForKey:@"friends_jabber_ids"] mutableCopy];
    [_tableView reloadData];
    [self getConversations];
    [[ChatDBManager sharedInstance] hideOrShowChatBadge:TRUE];
}

- (void)removeBlockedUsersChats{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *blockedUsers = [[defaults objectForKey:@"players_i_blocked"] mutableCopy];
    NSMutableArray *usersBlockedMe = [[defaults objectForKey:@"players_blocked_me"] mutableCopy];
    
    //Remove chat history of users who are blocked by me
    for (NSString *userJID in blockedUsers) {
        [[ChatDBManager sharedInstance] destroyUserChat:userJID];
    }
    
    //Remove chat history of users who are blocked me
    for (NSString *userJID in usersBlockedMe) {
        [[ChatDBManager sharedInstance] destroyUserChat:userJID];
    }
    [self getConversations];
    [[ChatDBManager sharedInstance] setUnreadCount];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[ChatDBManager sharedInstance] hideOrShowChatBadge:FALSE];
}

- (void)drawArrow{
    
    if([conversations count])
    {
        _label.hidden = TRUE;
        _linkLabel.hidden = TRUE;
        _chatTableView.hidden = FALSE;
        [view removeFromSuperview];
    }
    else
    {
        _label.hidden = FALSE;
        _linkLabel.hidden = FALSE;
        _chatTableView.hidden = TRUE;
    }
    
    if ([friendsList count] == 0 && [menuArray count] == 0 && [conversations count] == 0) {
        //You need friends or team to start a chat. Click here to
        _label.text = NSLocalizedString(YOU_NEED_FRIENDS_OR_TEAM_START_CHAT, nil);
        if (playerType == 1) {
            _linkLabel.text = NSLocalizedString(ADDFRIEND_OR_CREATE_TEAM, nil);
            [Util setHyperlinkForLabelWithUnderline:_linkLabel forText:NSLocalizedString(CREATE_TEAM_TITLE, nil) destinationURL:@"https://CreateTeam" forColor:UIColorFromHexCode(THEME_COLOR)];
        }
        else
        {
            _linkLabel.text = NSLocalizedString(ADDFRIENDS, nil);
        }
        
        [Util setHyperlinkForLabelWithUnderline:_linkLabel forText:NSLocalizedString(ADDFRIENDS, nil) destinationURL:@"https://AddFriends" forColor:UIColorFromHexCode(THEME_COLOR)];
        
        _linkLabel.delegate = self;
        _linkLabel.hidden = NO;
        _label.hidden = NO;
    }
    else if([conversations count] == 0){
        _linkLabel.hidden = YES;
        _label.text = NSLocalizedString(START_CHAT, nil);
        _label.hidden = NO;
    }
    
    if (view != nil) {
        [view setHidden:YES];
        [view removeFromSuperview];
    }
    
    if([conversations count] == 0)
    {
        if(IPAD)
            view = [[Util sharedInstance]drawArrowwithxCord:self.label.center.x yCord:self.label.center.y+250];
        else
            view = [[Util sharedInstance]drawArrowwithxCord:140 yCord:230];
        
        [view setHidden:NO];
        [self.view addSubview:view];
    }
    else{
        [view setHidden:YES];
        [view removeFromSuperview];
    }
}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    if ([[url absoluteString] rangeOfString:@"AddFriends"].location != NSNotFound) {
        InviteFriends *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
        [self.navigationController pushViewController:friends animated:YES];
    }
    if ([[url absoluteString] rangeOfString:@"CreateTeam"].location != NSNotFound) {
        CreateTeam *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeam"];
        friends.minimumPoints = minimumPoints;
        [self.navigationController pushViewController:friends animated:YES];
    }
    
}

-(void)updateMenuHeight
{
    for (NSLayoutConstraint *constraint in self.tableView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            int height = 165;
            for (int i=0; i<[menuArray count]; i++) {
                height = height + 55;
            }
            if ([menuArray count] == 0 && playerType == 1) {
                height = height + 55;
            }
            constraint.constant = height;
            [self.view layoutIfNeeded];
            break;
        }
    }
}

- (void)designTheView
{
    // PlayerType 1 is an Skater 2 is an Crew 3 is an Media
    playerType = [[Util getFromDefaults:@"playerType"] intValue];
    
    [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(CHAT, nil)]];
    _headerView.chatIcon.hidden = YES;
    _menuButton.layer.cornerRadius = _menuButton.frame.size.height / 2 ;
    _menuButton.clipsToBounds = true;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _chatTableView.backgroundColor = [UIColor clearColor];
    _chatTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self updateMenuHeight];
    
}

- (void)createPopUpWindows{
    chatMenuPopup = [KLCPopup popupWithContentView:self.tableView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutBottom);
    
    menu = [[Menu alloc]initWithViews:nil buttonTitle:[[NSMutableArray alloc] initWithObjects:VIEW_PROFILE,DELETE_CHAT_HISTORY, nil] withImage:nil];
    menu.delegate = self;
    menuPopup = [KLCPopup popupWithContentView:menu showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:_chatTableView];
    
    NSIndexPath *indexPath = [_chatTableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil) {
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([conversations count] > indexPath.row) {
            userData = [conversations objectAtIndex:indexPath.row];
            [menuPopup show];
        }
    } else {
        
    }
}

-(void)menuActionForIndex:(int)tag
{
    if (tag == 1) { //Player Profile
        
        int isPlayer = [[userData valueForKey:@"is_player"] intValue];
        [menuPopup dismiss:YES];
        if (isPlayer == 1) {
            FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            NSString *receiverId = [userData valueForKey:@"j_id"];
            NSArray *friendIds = [receiverId componentsSeparatedByString:@"_"];
            NSString *friendId = friendIds[0];
            friendProfile.friendId = friendId;
            friendProfile.friendName = [userData valueForKey:@"name"];
            
            UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
            [navigation pushViewController:friendProfile animated:YES];
        }
        else
        {
            NSString *jabberID = [userData valueForKey:@"j_id"];
            
            if ([Util isTeamPresent:jabberID]) {
                TeamViewController *teamDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
                teamDetails.teamId = [jabberID componentsSeparatedByString:@"_"][0];
                teamDetails.roomId = jabberID;
                [self.navigationController pushViewController:teamDetails animated:YES];
            }
            else
            {
                NonMemberTeamViewController *nonMember = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
                nonMember.teamId = [jabberID componentsSeparatedByString:@"_"][0];
                [self.navigationController pushViewController:nonMember animated:YES];
            }
            
        }
        
    }
    else if (tag == 2){ // Delete Chat history
        [menuPopup dismiss:YES];
        if ([[userData valueForKey:@"chat_type"] intValue] == 1) {
            [[ChatDBManager sharedInstance] destroyUserChat:[userData valueForKey:@"j_id"]];
        }
        else{
            [[ChatDBManager sharedInstance] destroyGroupUserChat:[userData valueForKey:@"j_id"]];
        }
        [self getConversations];
        [[ChatDBManager sharedInstance] setUnreadCount];
    }
    
}

#pragma mark tableview delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getNumberOfRows:tableView];
}

- (int)getNumberOfRows:(UITableView *)tableView{
    
    if(tableView == _tableView)
    {
        if ([menuArray count] == 0 && playerType != 1) {
            return 3;
        }
        return  [menuArray count] <= 1  ? 4 : (int)[menuArray count] + 3;
    }
    else
    {
        return  (int)[conversations count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    cellIdentifier = tableView == _tableView ? @"Cell" : @"chatCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(tableView == _tableView)
    {
        UIImageView *imageView = [cell viewWithTag:10];
        UILabel *name = [cell viewWithTag:11];
        name.numberOfLines = 2;
        
        if(indexPath.row == 0)
        {
            if ([friendsList count] == 0) {
                name.text = NSLocalizedString(NO_FRIENDS_AVAILABLE,nil);
            }else{
                name.text = NSLocalizedString(SEARCH_FRIENDS,nil);
            }
            
            imageView.image = [UIImage imageNamed: @"friendsNoti.png"];
            [name setFont:[name.font fontWithSize: 15]];
            cell.userInteractionEnabled = TRUE;
        }
        else if(indexPath.row == 1 && [menuArray count] == 0 && playerType == 1)
        {
            name.text = NSLocalizedString(NO_TEAM_AVAILABLE,nil);
            imageView.image = [UIImage imageNamed: @"teamWhite.png"];
            [name setFont:[name.font fontWithSize: 15]];
            cell.userInteractionEnabled = TRUE;
        }
        else if (indexPath.row <= [menuArray count])
        {
            imageView.image = [UIImage imageNamed: @"teamWhite.png"];
            name.text = [[menuArray objectAtIndex:indexPath.row-1] valueForKey:@"team_name"];
            [name setFont:[name.font fontWithSize: 15]];
            cell.userInteractionEnabled = TRUE;
        }
        else
        {
            int count = [self getNumberOfRows:_tableView];
            if ( count - 1 == indexPath.row) {
                imageView.image = [UIImage imageNamed: @"back.png"];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [name setFont:[name.font fontWithSize: 15]];
                name.text = NSLocalizedString(MAIN_MENU,nil);
                cell.userInteractionEnabled = TRUE;
            }
            else{
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [name setFont:[name.font fontWithSize: 15]];
                cell.userInteractionEnabled = TRUE;
                if ([Util getBoolFromDefaults:@"is_chat_enabled"]) {
                    name.text = NSLocalizedString(GO_OFFLINE,nil);
                    imageView.image = [UIImage imageNamed: @"Chatgray.png"];
                }
                else{
                    name.text = NSLocalizedString(GO_ONLINE,nil);
                    imageView.image = [UIImage imageNamed: @"Chatgreen.png"];
                }
            }
        }
        cell.backgroundColor = [UIColor blackColor];
        return cell;
    }
    else
    {
        UIImageView *profile = [cell viewWithTag:10];
        UILabel *name = [cell viewWithTag:11];
        UIImageView *type = [cell viewWithTag:12];
        UILabel *message = [cell viewWithTag:13];
        UILabel *time = [cell viewWithTag:14];
        UILabel *unread = [cell viewWithTag:15];
        UILabel *typing = [cell viewWithTag:16];
        UIView *statusView = [cell viewWithTag:110];
        
        
        statusView.layer.cornerRadius = 5;
        statusView.clipsToBounds = YES;
        profile.layer.cornerRadius = profile.frame.size.width / 2;
        profile.clipsToBounds = YES;
        profile.layer.borderWidth = 1.0f;
        profile.layer.borderColor = [UIColor redColor].CGColor;
        unread.layer.cornerRadius = unread.frame.size.width / 2;
        unread.clipsToBounds = YES;
        [typing setHidden:YES];
        typing.textColor = UIColorFromHexCode(THEME_COLOR);
        
        NSMutableDictionary *conversation = [conversations objectAtIndex:indexPath.row];
        
        
        //Bind Values
        [profile setImageWithURL:[NSURL URLWithString:[conversation valueForKey:@"profile_image"]] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        typing.text = NSLocalizedString(TYPING, nil);
        time.text = [Util getChatHistoryDate:[conversation valueForKey:@"time"]];
        
        //Set online offline status
        NSMutableArray *onlineUsers = [XMPPServer sharedInstance].onlineUsers;
        NSString *jabberID = [conversation valueForKey:@"j_id"];
        if ([onlineUsers indexOfObject:jabberID] != NSNotFound) {
            statusView.backgroundColor = [UIColor greenColor];
        }
        else{
            statusView.backgroundColor = [UIColor grayColor];
        }
        
        //Hide or show the status view based on chat
        int isPlayer = [[conversation valueForKey:@"is_player"] intValue];
        if (isPlayer == 1 && [Util getBoolFromDefaults:@"is_chat_enabled"]) {
            name.text = [NSString stringWithFormat:@"    %@",[conversation valueForKey:@"name"]];
            statusView.hidden = NO;
        }
        else{
            name.text = [conversation valueForKey:@"name"];
            statusView.hidden = YES;
        }
        
        //Set unread count
        NSString *count = [conversation valueForKey:@"unread_count"];
        unread.text = count;
        if (![count isEqualToString:@"0"]) {
            [unread setHidden:NO];
        }
        else{
            [unread setHidden:YES];
        }
        
        if([[conversation valueForKey:@"type"] intValue] == 1){
            [type hideByWidth:YES];
            message.text = [self getMessage:[conversation valueForKey:@"message"]];
        }
        else if([[conversation valueForKey:@"type"] intValue] == 2){
            [type hideByWidth:NO];
            message.text = NSLocalizedString(@"Image", nil);
            type.image = [UIImage imageNamed:@"CameraRed.png"];
        }
        else if([[conversation valueForKey:@"type"] intValue] == 3){
            [type hideByWidth:NO];
            message.text = NSLocalizedString(@"Video", nil);
            type.image = [UIImage imageNamed:@"PlayRed.png"];
        }
        
        type.backgroundColor = [UIColor clearColor];
        
        cell.backgroundColor = [UIColor clearColor];
        
        //Add zoom
        //[[Util sharedInstance] addImageZoom:profile];
        UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
        [profile setUserInteractionEnabled:YES];
        [profile addGestureRecognizer:tapProfileImage];
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _chatTableView.userInteractionEnabled = FALSE;
    
    if(tableView == _tableView)
    {
        if(indexPath.row == 0)
        {
            if ([friendsList count] == 0) {
                [chatMenuPopup dismiss:YES];
                InviteFriends *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
                [self.navigationController pushViewController:friends animated:YES];
            }else{
                [chatMenuPopup dismiss:YES];
                MyFriends *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"MyFriends"];
                friends.fromChat = TRUE;
                [self.navigationController pushViewController:friends animated:YES];
            }
        }
        else if(indexPath.row == 1 && [menuArray count] == 0 && playerType == 1)
        {
            [chatMenuPopup dismiss:YES];
            CreateTeam *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeam"];
            friends.minimumPoints = minimumPoints;
            [self.navigationController pushViewController:friends animated:YES];
        }
        else if (indexPath.row <= [menuArray count])
        {
            [chatMenuPopup dismiss:YES];
            if ([[XMPPServer sharedInstance].roomArray count] != 0) {
                NSMutableDictionary *teamDict = [[XMPPServer sharedInstance].roomArray objectAtIndex:indexPath.row-1];
                [XMPPServer sharedInstance].xmppRoom = [teamDict objectForKey:@"xmppRoom"];
                [self moveToGroupChat :[menuArray objectAtIndex:indexPath.row-1]];
            }
            else
            {
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(PLEASE_WAIT_JOINING, nil)];
            }
        }
        else {
            if ([self getNumberOfRows:tableView] - 1 == indexPath.row) {
                [chatMenuPopup dismiss:YES];
                ViewController *viewController =[self.navigationController.viewControllers firstObject];
                UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
                [viewController setCurrentPage:3];
                [viewController.tabBar setSelectedItem:viewController.tabFour];
                [navigation setViewControllers:@[viewController]];
                [UIApplication sharedApplication].delegate.window.rootViewController = navigation;
            }
            else{
                if ([[Util sharedInstance] getNetWorkStatus]){
                    
                    [chatMenuPopup dismiss:YES];
                    
                    BOOL status = ![Util getBoolFromDefaults:@"is_chat_enabled"];
                    
                    //Update chat notification
                    //Build Input Parameters
                    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
                    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
                    [inputParams setValue:[NSNumber numberWithBool:status] forKey:@"chat_notification_status"];
                    
                    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:UPDATE_CHAT_STATUS withCallBack:^(NSDictionary * response){
                        
                        _chatTableView.userInteractionEnabled = TRUE;
                        BOOL status = [Util getBoolFromDefaults:@"is_chat_enabled"];
                        if([[response valueForKey:@"status"] boolValue]){
                            
                            //Set chat enabled status in session
                            [[NSUserDefaults standardUserDefaults] setBool:!status forKey:@"is_chat_enabled"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            //Remove all online users
                            [[XMPPServer sharedInstance].onlineUsers removeAllObjects];
                            
                            //Reload the table view
                            [_chatTableView reloadData];
                            [_tableView reloadData];
                            if (!status) {
                                [appDelegate connectToChatServer];
                            }
                            else{
                                [[XMPPServer sharedInstance] goOffline];
                                [[XMPPServer sharedInstance] teardownStream];
                            }
                        }
                        else{
                            
                        }
                    } isShowLoader:YES];
                    
                }
            }
        }
    }
    else{
        if ([conversations count] > indexPath.row) {
            NSMutableDictionary *conversation = [conversations objectAtIndex:indexPath.row];
            FriendsChat *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsChat"];
            friends.receiverID = [conversation valueForKey:@"j_id"];
            friends.receiverName = [conversation valueForKey:@"name"];
            friends.receiverImage = [conversation valueForKey:@"profile_image"];
            if ([[conversation valueForKey:@"chat_type"] intValue] == 1) {
                friends.isSingleChat = @"TRUE";
            }
            else
            {
                friends.isSingleChat = @"FALSE";
                int index = [Util getMatchedObjectPosition:@"roomJID" valueToMatch:[conversation valueForKey:@"j_id"] from:[XMPPServer sharedInstance].roomArray type:0];
                if (index != -1) {
                    NSMutableDictionary *teamDict = [[XMPPServer sharedInstance].roomArray objectAtIndex:index];
                    [XMPPServer sharedInstance].xmppRoom = [teamDict objectForKey:@"xmppRoom"];
                }
            }
            [chatMenuPopup dismiss:YES];
            [self.navigationController pushViewController:friends animated:YES];
        }
    }
}


// ------- Group Chat---------

-(void)moveToGroupChat :(NSDictionary *)response
{
    // Navigate to Group Chat
    NSDictionary *profileImage = [response objectForKey:@"profile_image"];
    NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[profileImage valueForKey:@"profile_image"]];
    FriendsChat *chat =  [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsChat"];
    chat.receiverID = [response objectForKey:@"jabber_id"];
    chat.receiverName = [response objectForKey:@"team_name"];
    chat.receiverImage = profileUrl;
    chat.isSingleChat = @"FALSE";
    [self.navigationController pushViewController:chat animated:YES];
}

-(void) getTeamList
{
    NSDictionary *teamList = [[NSUserDefaults standardUserDefaults] objectForKey:@"TeamList"];
    if (teamList != nil)
    {
        //   menuArray = [[teamList objectForKey:@"team_details"] mutableCopy];
        mediaBase = [teamList valueForKey:@"media_base_url"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        menuArray = [[defaults objectForKey:@"team_details"] mutableCopy];
        minimumPoints = [[teamList objectForKey:@"team_creation_minimum_point"] intValue];
        
        [self updateMenuHeight];
    }
}

//Get message from XMPPMessage
- (NSString *)getMessage:(NSString *)message{
    XMPPMessage *xmppMessage = [[XMPPMessage alloc] initWithXMLString:message error:nil];
    
    if ([xmppMessage elementForName:@"teamstatus"] != nil) {
        return [[ChatDBManager sharedInstance] createTeamStatusBodyMessage:xmppMessage];
    }
    if ([[xmppMessage type] isEqualToString:@"groupchat"]) {
        
        NSXMLElement *userDataElement = [xmppMessage elementForName:@"userdata"];
        NSXMLElement *senderElement = [userDataElement elementForName:@"senderName"];
        NSXMLElement *fromElement = [userDataElement elementForName:@"from"];
        NSString *fromID = [fromElement stringValue];
        NSString *myJID = [[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"];
        NSString *senderName = [senderElement stringValue];
        if (![fromID isEqualToString:myJID]) {
            return [NSString stringWithFormat:@"%@ : %@",senderName,[xmppMessage valueForKey:@"body"]];
        }
        else
        {
            return [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(YOU, nil),[xmppMessage valueForKey:@"body"]];
        }
    }
    return [xmppMessage valueForKey:@"body"];
}

//Action for Menu
- (IBAction)tappedMenu:(id)sender
{
    [self getTeamList];
    [chatMenuPopup showWithLayout:layout];
    [_tableView setHidden:NO];
    [_tableView reloadData];
}

//Show friend profile
-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:buttonPosition];
    NSMutableDictionary *conversation = [conversations objectAtIndex:indexPath.row];
    
    NSString *JID = [NSString stringWithFormat:@"%@",[conversation valueForKey:@"j_id"]];
    if ([JID containsString:@"_team"]) {
        
        if (![Util isTeamPresent:JID]) {
            NonMemberTeamViewController *nonMember = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
            nonMember.teamId = [[conversation valueForKey:@"j_id"] componentsSeparatedByString:@"_"][0];
            [self.navigationController pushViewController:nonMember animated:YES];
        }
        else
        {
            TeamViewController *teamDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
            teamDetails.teamId = [[conversation valueForKey:@"j_id"] componentsSeparatedByString:@"_"][0];
            teamDetails.roomId = JID;
            [self.navigationController pushViewController:teamDetails animated:YES];
        }
    }
    else
    {
        FriendProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        profile.friendName = [conversation valueForKey:@"name"];
        profile.friendId = [[conversation valueForKey:@"j_id"] componentsSeparatedByString:@"_"][0];
        [self.navigationController pushViewController:profile animated:YES];
    }
}


//Get converstations

-(void)getConversations{
    
    queryString = [NSString stringWithFormat:@"SELECT * FROM player"];
    conversations = [[DBManager sharedInstance] findRecord:queryString];
    
    for (int i = 0; i < [conversations count]; i++)
    {
        NSMutableDictionary *conversation = [conversations objectAtIndex:i];
        NSString *receiver = [conversation valueForKey:@"j_id"];
        
        NSString *messageQuery = [NSString stringWithFormat:@"%@ ORDER BY id DESC limit 0 , 1",[[ChatDBManager sharedInstance] getChatHistoryQuery:[[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"] receiver:receiver]];
        
        if ([receiver rangeOfString:@"team"].location != NSNotFound) {
            messageQuery = [NSString stringWithFormat:@"%@ ORDER BY id DESC limit 0 , 1",[[ChatDBManager sharedInstance] getTeamChatHistoryQuery:receiver]];
        }
        
        NSMutableArray *messages = [[DBManager sharedInstance] findRecord:messageQuery];
        if ([messages count] > 0) {
            NSMutableDictionary *messageData = messages[0];
            [messageData setValue:[messageData valueForKey:@"id"] forKey:@"messageId"];
            [messageData removeObjectForKey:@"id"];
            [conversation addEntriesFromDictionary:messageData];
        }
        else{
            [conversations removeObjectAtIndex:i];
            i--;
        }
    }
    
    conversations = [[conversations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSMutableDictionary *first = (NSMutableDictionary *)a;
        NSMutableDictionary *second = (NSMutableDictionary*)b;
        return [[first valueForKey:@"time"] longLongValue] < [[second valueForKey:@"time"] longLongValue];
    }] mutableCopy];
    
    [_chatTableView reloadData];
    [self drawArrow];
}

///////// Handle the stanzas received from server //////////////

//Register for the Notification
- (void) registerForNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processIncomeMessage:) name:XMPPONMESSAGERECIEVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTeamList) name:XMPPRECEIVEDBLOCKEDLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlockedUsersChats) name:XMPPRECEIVEDBLOCKEDLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePresenceState:) name:XMPPRECIEVEPRESENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePresenceState:) name:XMPPRECEIVEDLASTSEEN object:nil];
}

//Update the player status
- (void) updatePresenceState:(NSNotification *) data
{
    [_chatTableView reloadData];
}

//To process the type of the notification
- (void) processIncomeMessage:(NSNotification *) data{
    
    NSMutableDictionary *receivedMessage = [data.userInfo mutableCopy];
    XMPPMessage *message = [receivedMessage valueForKey:@"message"];
    
    //1.Check message type
    if ([[message attributeStringValueForName:@"type"] isEqualToString:@"chat"] || [[message attributeStringValueForName:@"type"] isEqualToString:@"groupchat"]) {
        
        //Check message for current conversation
        NSArray *from = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
        NSString *jabberId = from[0];
        
        //Check is composing
        if ([message elementForName:@"composing"] != nil && [message elementForName:@"delay"] == nil) {
            
            int index = [Util getMatchedObjectPosition:@"j_id" valueToMatch:jabberId from:conversations type:0];
            if (index != -1) {
                [self hideMessage:TRUE hideTyping:FALSE inCell:index fromMessage:message];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTyping:) object:nil];
                [self performSelector:@selector(hideTyping:) withObject:message afterDelay:2.0];
            }
        }
    }
}

//Hide typing status
-(void)hideTyping:(XMPPMessage *)message{
    
    NSString *fromId;
    
    //1.Check message type
    if ([[message attributeStringValueForName:@"type"] isEqualToString:@"chat"] || [[message attributeStringValueForName:@"type"] isEqualToString:@"groupchat"]) {
        
        //Check is composing
        if ([message elementForName:@"composing"] != nil && [message elementForName:@"delay"] == nil) {
            
            //Check message for current conversation
            NSArray *from = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
            fromId = from[0];
        }
    }
    
    int index = [Util getMatchedObjectPosition:@"j_id" valueToMatch:fromId from:conversations type:0];
    if (index != -1 ) {
        [self hideMessage:FALSE hideTyping:TRUE inCell:index fromMessage:message];
    }
}

-(void)hideMessage:(BOOL)message hideTyping:(BOOL)typing inCell:(int)index fromMessage:(XMPPMessage *)messageStanza{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [_chatTableView cellForRowAtIndexPath:indexPath];
    UILabel *messageLabel = [cell viewWithTag:13];
    UILabel *typingLabel = [cell viewWithTag:16];
    UIImageView *type = [cell viewWithTag:12];
    
    if ([[messageStanza type] isEqualToString:@"chat"]) {
        //typingLabel.text = NSLocalizedString(TYPING, nil);
    }
    else
    {
        //Show typing name if its a group chat
        NSXMLElement *userDataElement = [messageStanza elementForName:@"userdata"];
       // NSXMLElement *senderElement = [userDataElement elementForName:@"senderName"];
        NSXMLElement *fromElement = [userDataElement elementForName:@"from"];
        NSString *fromID = [fromElement stringValue];
        NSString *myJID = [[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"];
       // NSString *senderName = [senderElement stringValue];
        if (![fromID isEqualToString:myJID]) {
            //typingLabel.text = [NSString stringWithFormat:NSLocalizedString(USER_TYPING, nil), senderName];
        }
    }
    
    [typingLabel setFont:[typingLabel.font fontWithSize: 25]];
    typingLabel.text = @"...";
    
    NSMutableDictionary *conversation = [conversations objectAtIndex:indexPath.row];
    int messageType = [[conversation valueForKey:@"type"] intValue];
    if (messageType == 2) {
        [type hideByWidth:message];
    }
    messageLabel.hidden = message;
    typingLabel.hidden = typing;
}
///////// Handle the stanzas received from server ends //////////////



@end
