//
//  MyFriends.m
//  Varial
//
//  Created by jagan on 11/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MyFriends.h"
#import "InviteFriends.h"
#import "UIImageView+AFNetworking.h"
#import "FriendsChat.h"
#import "ChatDBManager.h"

@interface MyFriends ()

@end

@implementation MyFriends

@synthesize  firendsTable;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    searchPage = searchPreviousPage = 1;
    searchResult = [[NSMutableArray alloc] init];
    friendsList = [[NSMutableArray alloc] init];
    
    [self designTheView];
    [self setInfiniteScrollForTableView];
    [self registerForKeyboardNotifications];
    _headerView.delegate = self;
    [_headerView setOptionHidden:NO];
    [_headerView setBookmarkHidden:YES];

    [_headerView setOptionImage:[UIImage imageNamed:@"addFriendIcon"] forState:UIControlStateNormal];
    
   // _fromChat = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    page = friendsPriviousPage = 1;
    
    if(!self.isFromFollowers && !self.isFromFollowing) {
        
        NSDictionary *friendList = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyFriendsList"];
        if (friendList != nil && _friendId == nil) {
            friendsList = [[NSMutableArray alloc] init];
            [self showFriendsList:friendList];
        }
    }
    
    // Hide Search for Followers list
    if(_isFromFollowers || _isFromFollowing){
        self.searchField.hidden = YES;
        self.clearButton.hidden = YES;
        self.searchButton.hidden = YES;
        self.friendsTableTopConstraint.constant = -40.0;
    } else {
        self.searchField.hidden = NO;
        self.clearButton.hidden = NO;
        self.searchButton.hidden = NO;
        self.friendsTableTopConstraint.constant = 10.0;
    }
    
    [self getFriendsList];
}

- (void)designTheView
{
    [Util setPadding:_searchField];
    
    if(_isFromFollowers && _isFromFriendsFollowers){
        NSString * aStrFriendName = [NSString stringWithFormat:@"%@ %@",_friendName,@"Followers"];
        [_headerView setHeader:NSLocalizedString(aStrFriendName, nil)];
    }
    else if(_isFromFollowers){
        [_headerView setHeader:NSLocalizedString(MY_FOLLOWERS, nil)];
    } else if(_isFromFollowing){
        [_headerView setHeader:NSLocalizedString(MY_FOLLOWEINGS, nil)];
    } else if (_friendId != nil) {
        [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(USER_FRIEND, nil),_friendName]];
    }
    else{
        [_headerView setHeader:NSLocalizedString(MY_FRIEND, nil)];
    }
    
    if (_fromChat) {
        [_headerView setHeader:NSLocalizedString(START_A_CHAT, nil)];
    }
    
    [_headerView.logo setHidden:YES];
    
    //Set transparent color to tableview
    [self.firendsTable setBackgroundColor:[UIColor clearColor]];
    self.firendsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchTable setBackgroundColor:[UIColor clearColor]];
    self.searchTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_searchTable setHidden:YES];
    
//    _addButton.layer.cornerRadius = _addButton.frame.size.width / 2;
//    _addButton.layer.masksToBounds = YES;
//    [_addButton setTitle:@"" forState:UIControlStateNormal];
//    [_addButton setImage:[UIImage imageNamed:@"adduser.png"] forState:UIControlStateNormal];
    
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_searchField addTarget:self  action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak MyFriends *weakSelf = self;
    // setup infinite scrolling
    [self.firendsTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.searchTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreSearchResult];
    }];
    [self.firendsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.searchTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != friendsPriviousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak MyFriends *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            friendsPriviousPage = page;
            [weakSelf getFriendsList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.firendsTable.infiniteScrollingView stopAnimating];
    }
}

//Add load more items
- (void)loadMoreSearchResult {
    if(searchPage > 0 && searchPreviousPage != searchPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak MyFriends *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            searchPreviousPage = searchPage;
            [weakSelf getSearchFriendsList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.searchTable.infiniteScrollingView stopAnimating];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark HeaderView Delegates
- (void)optionPressed {
    [self addFriend:nil];
}

- (void) textChangeListener :(UITextField *) searchBox
{
    if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        self.firendsTable.hidden = YES;
        self.searchTable.hidden = NO;
        searchPage = 1;
        if (task != nil) {
            [task cancel];
        }
        [self getSearchFriendsList];
    }
    else{
        [_clearButton setHidden:YES];
        [self.searchTable setHidden:YES];
        self.firendsTable.hidden = NO;
    }
    
    if ([_searchField.text length] > 0) {
        [_clearButton setHidden:NO];
    }
}


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.firendsTable) {
        return [friendsList count];
    }
    else
        return [searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"friendsCell";
    cellIdentifier = tableView == _searchTable ? @"friendsSearchCell" : @"friendsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    //Read elements
    UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
    UILabel *name = (UILabel *)[cell viewWithTag:11];
    UILabel *points = (UILabel *) [cell viewWithTag:12];
    UILabel *rank = (UILabel *) [cell viewWithTag:13];
    UIImageView *board = (UIImageView *)[cell viewWithTag:14];
    
    UIImageView *plus=(UIImageView *)[cell viewWithTag:15];
    UIButton *status=(UIButton *)[cell viewWithTag:16];
    UIView *statusView =(UIView *)[cell viewWithTag:17];
    
    [Util createRoundedCorener:statusView withCorner:3];
    
    if (_friendId != nil) {
        [board setHidden:YES];
    }
    else{
        [statusView setHidden:YES];
    }
    
//    UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
//    [profile setUserInteractionEnabled:YES];
//    [profile addGestureRecognizer:tapProfileImage];
    
//    NSDictionary *list = tableView == self.searchTable ? [searchResult objectAtIndex:indexPath.row] : [friendsList objectAtIndex:indexPath.row];
    
    NSDictionary *list;
    if (tableView == self.searchTable && [searchResult count] > indexPath.row) {
        list = [searchResult objectAtIndex:indexPath.row];
    } else if (tableView == self.firendsTable && [friendsList count] > indexPath.row) {
        list = [friendsList objectAtIndex:indexPath.row];
    }
    
    // Avoid out of range exceptions
    if (!list) {
        name.text = @"";
        points.text = @"";
        rank.text = @"";
        return cell;
    }
    
    name.text = [list objectForKey:@"name"];
    points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[list objectForKey:@"point"]];
    rank.text = [Util playerType:[[list objectForKey:@"player_type_id"] intValue] playerRank:[list objectForKey:@"rank"]]; //[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Rank", nil),[list objectForKey:@"rank"]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"profile_image"]];
    [profile setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    
    strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"player_skate_pic"]];
    [board setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
    
    //Add zoom
    //[[Util sharedInstance] addImageZoom:profile];
    
    [status removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    if ([[list objectForKey:@"my_self"] boolValue] || _fromChat) {
        [statusView setHidden:YES];
    }
    else{
        //Check Relationship status
        if([[list objectForKey:@"relationship_status"] integerValue]==0)
        {
            [status setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor redColor]];
            [plus setImage:[UIImage imageNamed: @"invite.png"]];
            row = (int) indexPath.row;
            [status addTarget:self action:@selector(tappedInviteButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            [status addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if([[list objectForKey:@"relationship_status"] integerValue]==1)
        {
            [status setTitle:NSLocalizedString(@"Invited", nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor grayColor]];
            [plus setImage:[UIImage imageNamed: @"invited.png"]];
        }
        
        else if([[list objectForKey:@"relationship_status"] integerValue]==2)
        {
            [status setTitle:NSLocalizedString(@"Accept", nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor redColor]];
            [plus setImage:[UIImage imageNamed: @"accept.png"]];
        }
        
        else if([[list objectForKey:@"relationship_status"] integerValue]==4)
        {
            [status setTitle:NSLocalizedString(@"Friends", nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor blackColor]];
            [plus setImage:[UIImage imageNamed: @"friendsTick.png"]];
        }
    }
        
    return cell;
}


//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(_fromChat)
    {
        _fromChat = FALSE;
        NSDictionary *list = tableView == self.searchTable ? [searchResult objectAtIndex:indexPath.row] : [friendsList objectAtIndex:indexPath.row];
        NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"profile_image"]];
        FriendsChat *chat =  [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsChat"];
        chat.receiverID = [list objectForKey:@"jabber_id"];
        chat.receiverName = [list objectForKey:@"name"];
        chat.receiverImage = strURL;
        chat.isFromFriends = @"TRUE";
        chat.isSingleChat = @"TRUE";
        [self.navigationController pushViewController:chat animated:YES];
        
    }
     else if (((tableView == self.searchTable) && ([searchResult count] > indexPath.row)) ||  ((tableView == self.firendsTable) && ([friendsList count] > indexPath.row))) {
        
        NSDictionary *friend = tableView == self.searchTable ? [searchResult objectAtIndex:indexPath.row] : [friendsList objectAtIndex:indexPath.row];
        if ([[friend valueForKey:@"my_self"] boolValue]) {
            MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
            [self.navigationController pushViewController:myProfile animated:YES];
        }
        else{
            FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            friendProfile.friendId = [friend valueForKey:@"friend_id"];
            friendProfile.friendName = [friend valueForKey:@"name"];
            [self.navigationController pushViewController:friendProfile animated:YES];
        }
    }
    
}

- (IBAction)addFriend:(id)sender {
    InviteFriends *inviteFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
    [self.navigationController pushViewController:inviteFriends animated:YES];
}

- (IBAction)clearClick:(id)sender
{
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    [self.searchTable setHidden:YES];
    [self.firendsTable setHidden:NO];
}

-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint buttonPosition;
    NSIndexPath *indexPath;
    NSMutableDictionary *friendDetail;
    
    if ([self.searchTable isHidden]) {
        
        buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.firendsTable];
        indexPath = [self.firendsTable indexPathForRowAtPoint:buttonPosition];
        friendDetail = [friendsList objectAtIndex:indexPath.row];
    }
    else
    {
        buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.searchTable];
        indexPath = [self.searchTable indexPathForRowAtPoint:buttonPosition];
        friendDetail = [searchResult objectAtIndex:indexPath.row];
    }
    
    FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    friendProfile.friendId = [friendDetail valueForKey:@"friend_id"];
    friendProfile.friendName = [friendDetail valueForKey:@"name"];
    [self.navigationController pushViewController:friendProfile animated:YES];
}

//Add empty message in table background view
- (void)addEmptyMessageForFriendsTable{
    
    if ([friendsList count] == 0) {
        [Util addEmptyMessageToTable:self.firendsTable withMessage:NO_FRIENDS withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
    else{
        [Util addEmptyMessageToTable:self.firendsTable withMessage:@"" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
}
- (void)addEmptyMessageForSearchTable{
    
    if ([searchResult count] == 0) {
        [Util addEmptyMessageToTable:self.searchTable withMessage:NO_RESULT_FOUND withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
    else{
        [Util addEmptyMessageToTable:self.searchTable withMessage:@"" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
}


//Show profile image
- (IBAction)showProfile:(id)sender
{
    UITableView *table = ![[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ? _searchTable : self.firendsTable;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:table];
    NSIndexPath *path = [table indexPathForRowAtPoint:buttonPosition];
    NSMutableArray *list = ![[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ? searchResult : friendsList;
    NSDictionary *friend = [list objectAtIndex:path.row];
    FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    friendProfile.friendId = [friend valueForKey:@"friend_id"];
    friendProfile.friendName = [friend valueForKey:@"name"];
    [self.navigationController pushViewController:friendProfile animated:YES];
}


// Action for invite button in tableview
- (IBAction)tappedInviteButton:(id)sender
{
    UITableView *table = ![[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ? _searchTable : self.firendsTable;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:table];
    NSIndexPath *path = [table indexPathForRowAtPoint:buttonPosition];
    UITableViewCell *rowSelected = [table cellForRowAtIndexPath:path];
    UIButton *button = (UIButton *)[rowSelected viewWithTag:16];
    [button setTitle:@"Inviting" forState:UIControlStateNormal];
    [self sendInviteFriend:path];
}


// API access for send invite
-(void) sendInviteFriend:(NSIndexPath *)path
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    NSMutableArray *list = ![[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ? searchResult : friendsList;
    UITableView *table = ![[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ? _searchTable : self.firendsTable;
    
    NSMutableDictionary *dic=[[list objectAtIndex:path.row]mutableCopy];
    
    [inputParams setValue: [dic objectForKey:@"friend_id"] forKey:@"friend_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ADD_FRIEND withCallBack:^(NSDictionary * response){
        
        UITableViewCell *rowSelected = [table cellForRowAtIndexPath:path];
        UIImageView *plus=(UIImageView *)[rowSelected viewWithTag:15];
        UIButton *status=(UIButton *)[rowSelected viewWithTag:16];
        UIView *statusView =(UIView *)[rowSelected viewWithTag:17];
        
        if([[response valueForKey:@"status"] boolValue]){
            //invitation send
            [status setTitle:NSLocalizedString(@"Invited", nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor grayColor]];
            [plus setImage:[UIImage imageNamed: @"invited.png"]];
            [dic setObject:@"1" forKey:@"relationship_status"];
            [list replaceObjectAtIndex:path.row withObject:dic];
            [status removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        }else{
            [status setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
        }
        
    } isShowLoader:NO];
    
}

// MTUxODUwMjkwOUE3NjQ5MjRGLUYwQkEtNEUxRS04MDAzLThDMkM1Q0Y0MkNEMzIyMTYzNw==

//Get friends list
- (void) getFriendsList{
    
    if (task != nil) {
        [task cancel];
    }
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    if (_friendId == nil) {
        [inputParams setValue:@"" forKey:@"friend_id"];
    }else{
        [inputParams setValue:_friendId forKey:@"friend_id"];
    }
    if(self.isFromFollowers){
        [inputParams setValue:@"1" forKey:@"followers"];
    } else if(self.isFromFollowing) {
        [inputParams setValue:@"2" forKey:@"followers"];
    } else {
        [inputParams setValue:@"0" forKey:@"followers"];
    }
    
    [firendsTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:MY_FRIENDS withCallBack:^(NSDictionary * response){
        
        [firendsTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            
            if (page == 1)
            {
                [friendsList removeAllObjects];
                if (_friendId == nil) {
                    [Util setInDefaults:response withKey:@"MyFriendsList"];

                    //Update the friends name in Chat DB
                    [[ChatDBManager sharedInstance] updateUserNameAndImage:[response mutableCopy]];
                }
            }
            
            [self showFriendsList:response];
            page = [[response valueForKey:@"page"] intValue];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}

-(void)showFriendsList:(NSDictionary *)response
{
    if (strMediaUrl == nil) {
        strMediaUrl = [response objectForKey:@"media_base_url"];
    }
    
    [friendsList addObjectsFromArray:[[response objectForKey:@"friend_list"] mutableCopy]];
    [self addEmptyMessageForFriendsTable];
    [firendsTable reloadData];
}


//Get search friends
-(void) getSearchFriendsList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchPage] forKey:@"page"];
    if (_friendId == nil) {
        [inputParams setValue:@"" forKey:@"friend_id"];
    }else{
        [inputParams setValue:_friendId forKey:@"friend_id"];
    }
    
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    
    [_searchTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_MY_FRIENDS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [_searchTable.infiniteScrollingView stopAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //Hide or show the search table
                [self.searchTable setHidden:NO];
                if([_searchField.text isEqualToString:@""]){
                    [self.searchTable setHidden:YES];
                }
                
                if (searchPage == 1) {
                    [searchResult removeAllObjects];
                    strMediaUrl = [response objectForKey:@"media_base_url"];
                }
                
                [searchResult addObjectsFromArray: [[response objectForKey:@"search_via_varial"] mutableCopy]];
                [self.searchTable reloadData];
                
                searchPage = [[response valueForKey:@"page"] intValue];
                
                //Add no result message
                [self addEmptyMessageForSearchTable];
                
                //Scroll to top
                [Util scrollToTop:_searchTable fromArrayList:searchResult];
            });
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    _addFriendsBottom.constant = kbSize.height+10;
    
    [UIView animateWithDuration:0 animations:^{
        [self.view layoutIfNeeded];
    }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    _addFriendsBottom.constant = 20;
    [UIView animateWithDuration:.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
