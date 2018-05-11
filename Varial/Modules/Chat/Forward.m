//
//  Forward.m
//  Varial
//
//  Created by vis-1674 on 05/07/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Forward.h"
#import "Util.h"
#import "SVPullToRefresh.h"
#import "FriendsCell.h"
#import "TeamCell.h"
#import "ChatCell.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "DBManager.h"
#import "ChatDBManager.h"

@interface Forward (){
    NSArray *titles,*activeImages,*inactiveImages,*menus;
}

@end

@implementation Forward

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    recentChats = [[NSMutableArray alloc] init];
    searchRecentChats  = [[NSMutableArray alloc] init];
    friends = [[NSMutableArray alloc] init];
    searchFriends = [[NSMutableArray alloc] init];
    teams = [[NSMutableArray alloc] init];
    page = previousPage = searchPage = searchPreviousPage = selectedTab = 1;
    titles = [[NSArray alloc] initWithObjects:@"", RECENT_CHAT, CHAT_FRIENDS,TEAM, nil];
    activeImages = [[NSArray alloc] initWithObjects:@"", @"watchAct.png", @"TeamAct.png",@"FriendsAct.png", nil];
    inactiveImages = [[NSArray alloc] initWithObjects:@"", @"watchWhite.png", @"TeamWhi.png", @"FriendsWhi.png", nil];
    menus = [[NSArray alloc] initWithObjects:@"", _recentChat, _friendsMenu, _teamMenu, nil];
    
    //Register the cell
    [_recentTable registerNib:[UINib nibWithNibName:@"ChatCell" bundle:nil] forCellReuseIdentifier:@"chatCell"];
    [_teamTable registerNib:[UINib nibWithNibName:@"TeamCell" bundle:nil] forCellReuseIdentifier:@"teamCell"];
    [_friendsTable registerNib:[UINib nibWithNibName:@"FriendsCell" bundle:nil] forCellReuseIdentifier:@"friendsCell"];
    
    [self designTheView];
    [self getConversations];
    [self getFriendsList];
    [self getTeamList];
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)designTheView
{
    //Set Title
    [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(titles[1], nil)]];
    //Set padding to text box
    [Util setPadding:_friendsSearch];
    [Util setPadding:_recentSearch];
    
    //Set transparent color to tableview
    [_friendsTable setBackgroundColor:[UIColor clearColor]];
    _friendsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_recentTable setBackgroundColor:[UIColor clearColor]];
    _recentTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_teamTable setBackgroundColor:[UIColor clearColor]];
    _teamTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /*[Util createRoundedCorener:_recentSearch withCorner:3];
    [Util createRoundedCorener:_recentClear withCorner:3];
    [Util createRoundedCorener:_recentSearch withCorner:3];
    [Util createRoundedCorener:_friendsSearch withCorner:3];
    [Util createRoundedCorener:_friendClear withCorner:3];
    [Util createRoundedCorener:_friendsSearch withCorner:3];*/
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_friendsSearch addTarget:self  action:@selector(searchFriends:)
           forControlEvents:UIControlEventEditingChanged];
    [_recentSearch addTarget:self  action:@selector(searchRecentChats:)
             forControlEvents:UIControlEventEditingChanged];
    
    [self setInfiniteScrollForTableView];
    
    [_recentSearch setValue:NSLocalizedString(SEARCH_BY_NAME, nil) forKeyPath:@"_placeholderLabel.text"];
    
    [_friendsSearch setValue:NSLocalizedString(SEARCH_NAME_EMAIL, nil) forKeyPath:@"_placeholderLabel.text"];
}


- (void) searchFriends :(UITextField *) searchBox
{
    if([[_friendsSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        searchPage = 1;
        if (task != nil) {
            [task cancel];
        }
        [self searchFriends];
    }
    else{
        [_friendClear setHidden:YES];
    }
    
    if ([_friendsSearch.text length] > 0) {
        [_friendClear setHidden:NO];
    }
}

- (void) searchRecentChats :(UITextField *) searchBox
{
    if([[_recentSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        NSString* filter = @"%K CONTAINS %@";
        NSPredicate* predicate = [NSPredicate predicateWithFormat:filter,@"name", _recentSearch.text];
        NSArray *result = [recentChats filteredArrayUsingPredicate:predicate];
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *conversation in recentChats) {
            NSString *name = [[conversation valueForKey:@"name"] lowercaseString];
            NSString *queryToMatch = [_recentSearch.text lowercaseString];           
            if ([name rangeOfString:queryToMatch].location != NSNotFound) {
                [searchResults addObject:conversation];
            }
        }
        searchRecentChats = searchResults;
        [_recentTable reloadData];
        [self addEmptyMessageForRecentTable];
        NSLog(@"Result %@",searchResults);
    }
    else{
        [_recentClear setHidden:YES];
        [_recentTable reloadData];
    }
    
    if ([_recentSearch.text length] > 0) {
        [_recentClear setHidden:NO];
    }
}


//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak Forward *weakSelf = self;
    // setup infinite scrolling
    [_friendsTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [_friendsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    
    NSLog(@"LOADING MORE CONTENTS...!");
    __weak Forward *weakSelf = self;
    int64_t delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if([[_friendsSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            if (searchPage > 0 && searchPage != searchPreviousPage) {
                searchPreviousPage = searchPage;
                [self searchFriends];
            }
        }
        else{
            if (page > 0 && page != previousPage) {
                previousPage = page;
                [self getFriendsList];
            }
        }
        
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showRecentChats:(id)sender {
    [self setCurrentTab:1];
    _recentView.hidden = NO;
    _friendsView.hidden = YES;
    _teamView.hidden = YES;
    [_recentTable reloadData];
}

- (IBAction)showTeams:(id)sender {
   [self setCurrentTab:3];
    _recentView.hidden = YES;
    _friendsView.hidden = YES;
    _teamView.hidden = NO;
     [_teamTable reloadData];
}

- (IBAction)showFriends:(id)sender {
    [self setCurrentTab:2];
    _recentView.hidden = YES;
    _friendsView.hidden = NO;
    _teamView.hidden = YES;
    [_friendsTable reloadData];
}

- (void)setCurrentTab:(int)index{
    [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(titles[index], nil)]];
    selectedTab = index;
    for (int i = 1 ; i <= 3; i++) {
        
        UIButton *button = (UIButton *)menus[i];
        if (i == index) {
            [button setImage:[UIImage imageNamed:activeImages[i]] forState:UIControlStateNormal];
        }
        else{
             [button setImage:[UIImage imageNamed:inactiveImages[i]] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)clearRecent:(id)sender {
    _recentSearch.text = @"";
    _recentClear.hidden = YES;
    [_recentTable reloadData];
    [_recentSearch resignFirstResponder];
    [Util addEmptyMessageToTableWithHeader:_recentTable withMessage:@"" withColor:[UIColor whiteColor]];
}

- (IBAction)clearFriends:(id)sender {
    _friendsSearch.text = @"";
    _friendClear.hidden = YES;
    [_friendsTable reloadData];
    [_friendsSearch resignFirstResponder];
    [self addEmptyMessageForFriendsTable];
}

//Add empty message in table background view
- (void)addEmptyMessageForFriendsTable{
    
    if ([friends count] == 0) {
        [Util addEmptyMessageToTableWithHeader:_friendsTable withMessage:NO_FRIENDS withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTableWithHeader:_friendsTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

- (void)addEmptyMessageForSearchTable{
    
    if ([searchFriends count] == 0) {
        [Util addEmptyMessageToTableWithHeader:_friendsTable withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTableWithHeader:_friendsTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

- (void)addEmptyMessageForRecentTable{
    
    if ([searchRecentChats count] == 0) {
        [Util addEmptyMessageToTableWithHeader:_recentTable withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTableWithHeader:_recentTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}
- (void)addEmptyMessageForTeamTable{
    
    if ([teams count] == 0) {
        [Util addEmptyMessageToTable:_teamTable withMessage:NO_TEAMS withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:_teamTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

//Get friends list
- (void) getFriendsList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:@"" forKey:@"friend_id"];
        
    [_friendsTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:MY_FRIENDS withCallBack:^(NSDictionary * response){
        
        [_friendsTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            
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
    
    [friends addObjectsFromArray:[[response objectForKey:@"friend_list"] mutableCopy]];
    [self addEmptyMessageForFriendsTable];
    [_friendsTable reloadData];
}


//Get search friends
-(void) searchFriends
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchPage] forKey:@"page"];
    [inputParams setValue:@"" forKey:@"friend_id"];
    [inputParams setValue:_friendsSearch.text forKey:@"key_search"];
    [_friendsTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_MY_FRIENDS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [_friendsTable.infiniteScrollingView stopAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
               
                if (searchPage == 1) {
                    [searchFriends removeAllObjects];
                    strMediaUrl = [response objectForKey:@"media_base_url"];
                }
                
                [searchFriends addObjectsFromArray: [[response objectForKey:@"search_via_varial"] mutableCopy]];
                [_friendsTable reloadData];
                
                searchPage = [[response valueForKey:@"page"] intValue];
                
                //Add no result message
                [self addEmptyMessageForSearchTable];
            });
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}

//Get message from XMPPMessage
- (NSString *)getMessage:(NSString *)message{
    XMPPMessage *xmppMessage = [[XMPPMessage alloc] initWithXMLString:message error:nil];
    return [xmppMessage valueForKey:@"body"];
}

- (void)getTeamList{
    
    //Send team list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_LIST withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [self showTeamList:response];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate updateTeamNameAndImage:response];
        }
        else{
            
        }
    } isShowLoader:NO];
}

-(void)showTeamList:(NSDictionary *)response
{
    if(strMediaUrl == nil)
        strMediaUrl = [response valueForKey:@"media_base_url"];
    teams = [[response objectForKey:@"team_details"] mutableCopy];
    [_teamTable reloadData];
    [self addEmptyMessageForTeamTable];
}


-(void)getConversations{
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM player"];
    recentChats = [[DBManager sharedInstance] findRecord:queryString];
    
    for (NSMutableDictionary *conversation in recentChats)
    {
        NSString *receiver = [conversation valueForKey:@"j_id"];
        NSString *messageQuery = [NSString stringWithFormat:@"%@ ORDER BY id DESC limit 0 , 1",[[ChatDBManager sharedInstance] getChatHistoryQuery:[[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"] receiver:receiver]];
        
        NSMutableArray *messages = [[DBManager sharedInstance] findRecord:messageQuery];
        if ([messages count] > 0) {
            NSMutableDictionary *messageData = messages[0];
            [messageData setValue:[messageData valueForKey:@"id"] forKey:@"messageId"];
            [messageData removeObjectForKey:@"id"];
            [conversation addEntriesFromDictionary:messageData];
        }
    }
    
    recentChats = [[recentChats sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSMutableDictionary *first = (NSMutableDictionary *)a;
        NSMutableDictionary *second = (NSMutableDictionary*)b;
        return [[first valueForKey:@"time"] longLongValue] < [[second valueForKey:@"time"] longLongValue];
    }] mutableCopy];
    
    [_recentTable reloadData];
}


//Forward message
- (void)forwardMessageToId:(NSString *)toJID withName:(NSString *)name withImageUrl:(NSString *) imageUrl isSingleChat:(NSString *)isSingleChat{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    FriendsChat *friendsChat = [storyBoard instantiateViewControllerWithIdentifier:@"FriendsChat"];
    friendsChat.receiverID = toJID;
    friendsChat.receiverName = name;
    friendsChat.receiverImage = imageUrl;
    friendsChat.isSingleChat = isSingleChat;
    friendsChat.forwardMessage = [_message mutableCopy];
    
    //Remove the last view controllers
    NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];
    [viewControllers removeLastObject];
    [viewControllers removeLastObject];
    [viewControllers addObject:friendsChat];
    self.navigationController.viewControllers = viewControllers;
}


#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectedTab == 1) {
        if([[_recentSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            return [searchRecentChats count];
        }
        else{
            return [recentChats count];
        }
    }
    else if(selectedTab == 2){
        if([[_friendsSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            return [searchFriends count];
        }
        else{
            return [friends count];
        }
    }
    else{
        return [teams count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedTab == 2) {
        
        NSMutableDictionary *friend;
        if([[_friendsSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            friend = [searchFriends objectAtIndex:indexPath.row];
        }
        else{
            friend = [friends objectAtIndex:indexPath.row];
        }
        
        FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:@"friendsCell"];
        if (cell == nil)
        {
            cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendsCell"];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        
        //Bind the information
        cell.statusView.hidden = YES;
        cell.name.text = [friend objectForKey:@"name"];
        cell.points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(POINTS, nil),[friend objectForKey:@"point"]];
        cell.rank.text = [Util playerType:[[friend objectForKey:@"player_type_id"] intValue] playerRank:[friend objectForKey:@"rank"]];
        NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[friend objectForKey:@"profile_image"]];
        [cell.profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[friend objectForKey:@"player_skate_pic"]];
        [cell.skateBoard setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
        
        //Add zoom
        //[[Util sharedInstance] addImageZoom:cell.profileImage];
        
        return  cell;
    }
    else if (selectedTab == 1) {
        
        NSMutableDictionary *chat;
        if([[_recentSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            chat = [searchRecentChats objectAtIndex:indexPath.row];
        }
        else{
            chat = [recentChats objectAtIndex:indexPath.row];
        }
        
        
        ChatCell *cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:@"chatCell"];
        if (cell == nil)
        {
            cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatCell"];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        //Design the cell
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
        cell.profileImage.clipsToBounds = YES;
        cell.profileImage.layer.borderWidth = 1.0f;
        cell.profileImage.layer.borderColor = [UIColor redColor].CGColor;
        cell.typingLabel.hidden = YES;
        cell.badge.hidden = YES;
        
        //Bind the information
        [cell.profileImage setImageWithURL:[NSURL URLWithString:[chat valueForKey:@"profile_image"]] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        cell.name.text = [chat valueForKey:@"name"];
        cell.time.text = [Util getChatHistoryDate:[chat valueForKey:@"time"]];
        if([[chat valueForKey:@"type"] intValue] == 1){
            [cell.chatImage hideByWidth:YES];
            cell.message.text = [self getMessage:[chat valueForKey:@"message"]];
        }
        else if([[chat valueForKey:@"type"] intValue] == 2){
            [cell.chatImage hideByWidth:NO];
            cell.message.text = NSLocalizedString(IMAGE, nil);
            cell.chatImage.image = [UIImage imageNamed:@"CameraRed.png"];
        }
        else if([[chat valueForKey:@"type"] intValue] == 3){
            [cell.chatImage hideByWidth:NO];
            cell.message.text = NSLocalizedString(VIDEO, nil);
            cell.chatImage.image = [UIImage imageNamed:@"PlayRed.png"];
        }
        cell.chatImage.backgroundColor = [UIColor clearColor];
        
        //Add zoom
        //[[Util sharedInstance] addImageZoom:cell.profileImage];

        
        return  cell;
    }
    else{
        
        TeamCell *cell = (TeamCell *)[tableView dequeueReusableCellWithIdentifier:@"teamCell"];
        if (cell == nil)
        {
            cell = [[TeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"teamCell"];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        NSMutableDictionary *team = [teams objectAtIndex:indexPath.row];
        
        NSDictionary *profileImage = [team objectForKey:@"profile_image"];
        NSString *profileUrl = [NSString stringWithFormat:@"%@%@",strMediaUrl,[profileImage valueForKey:@"profile_image"]];
        [cell.profileImage setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        
        cell.teamMame.text = [team valueForKey:@"team_name"];
        cell.rank.text = [NSString stringWithFormat:@"#%@",[team valueForKey:@"rank"]] ;
        cell.captainName.text = [team valueForKey:@"captain_name"];
        
        NSString *userType = [[team valueForKey:@"team_relation"] intValue] == 3 ? @"member.png" : @"captain.png";
        cell.captainSymbol.image = [UIImage imageNamed:userType];
        
        //Add zoom
        //[[Util sharedInstance] addImageZoom:cell.profileImage];
        
        return  cell;
    }
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedTab == 1) {
        NSMutableDictionary *chat;
        if([[_recentSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            chat = [searchRecentChats objectAtIndex:indexPath.row];
        }
        else{
            chat = [recentChats objectAtIndex:indexPath.row];
        }
        
        NSString *isSingleChat = [[chat valueForKey:@"chat_type"] intValue] == 1 ? @"TRUE" : @"FALSE";
        [self forwardMessageToId:[chat valueForKey:@"j_id"] withName:[chat valueForKey:@"name"] withImageUrl:[chat valueForKey:@"profile_image"] isSingleChat:isSingleChat];
    }
    else if(selectedTab == 2){
        NSMutableDictionary *friend;
        if([[_friendsSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            friend = [searchFriends objectAtIndex:indexPath.row];
        }
        else{
            friend = [friends objectAtIndex:indexPath.row];
        }
        NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[friend objectForKey:@"profile_image"]];
        [self forwardMessageToId:[friend valueForKey:@"jabber_id"] withName:[friend valueForKey:@"name"] withImageUrl:strURL isSingleChat:@"TRUE"];
    }
    else{
         NSMutableDictionary *team = [teams objectAtIndex:indexPath.row];
         NSMutableDictionary *picture = [team objectForKey:@"profile_image"];
         NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[picture objectForKey:@"profile_image"]];
         [self forwardMessageToId:[team valueForKey:@"jabber_id"] withName:[team valueForKey:@"team_name"] withImageUrl:strURL isSingleChat:@"FALSE"];
    }
}


@end
