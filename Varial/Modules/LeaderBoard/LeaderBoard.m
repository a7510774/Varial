//
//  LeaderBoard.m
//  Varial
//
//  Created by jagan on 11/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "LeaderBoard.h"
#import "SVPullToRefresh.h"
#import "PointsInformation.h"
#import "PlayersList.h"
#import "TeamList.h"
@interface LeaderBoard ()

@end

@implementation LeaderBoard
BOOL showPlayerLoader, showTeamLoader;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    showPlayerLoader = TRUE, showTeamLoader = TRUE;
    [self designTheView];
    [self createPopUpWindows];
    [self setInfiniteScrollForTableView];
    [self setInfiniteScrollForTeamTableView];
    leaders = [[NSMutableArray alloc] init];
    team=[[NSMutableArray alloc]init];
    page = previousPage = 1;
    teamPage = teamPreviousPage = 1;
    
    // If Current user is not an skater should show the Top sore list
    if ([[Util getFromDefaults:@"playerType"] isEqualToString:@"1"]) {
        [_leaderBoardHeaderView hideByHeight:NO];
        _leaderBoardTable.hidden = YES;
        [self getScorers];
    }
    else{
        _leaderBoardTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        [self getTopScorers];
        _leaderBoardTable.hidden = NO;
    }
    
    //Set point icon
    [Util setPointsIconText:_btnPoints withSize:18];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
}

- (void)designTheView{
    [_headerView setHeader:NSLocalizedString(LEADER_BOARD_TITLE, nil)];

    _leaderBoardTable.backgroundColor=[UIColor clearColor];
    _leaderBoardTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _leftView.layer.cornerRadius = _leftView.frame.size.height / 2 ;
    _leftView.clipsToBounds = true;
    
    _board.layer.cornerRadius = _board.frame.size.height / 2 ;
    _board.clipsToBounds = true;
    
    _searchButton.layer.cornerRadius = _searchButton.frame.size.width / 2;
    _searchButton.layer.masksToBounds = YES;
    [self.view addSubview:_searchButton];
    
    //Add zoom
    [[Util sharedInstance] addImageZoom:_myImage];
    
    [Util createBorder:_tabView withColor:UIColorFromHexCode(THEME_COLOR)];
    [Util createBorder:_teamHeaderView withColor:UIColorFromHexCode(THEME_COLOR)];

    self.TeamTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _TeamTableView.backgroundColor = [UIColor clearColor];
    [_TeamTableView setHidden:YES];
    
    selectedTab = 1;
    
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak LeaderBoard *weakSelf = self;
    // setup infinite scrolling
    [self.leaderBoardTable addInfiniteScrollingWithActionHandler:^{
        if ([[Util getFromDefaults:@"playerType"] isEqualToString:@"1"]) {
            [weakSelf insertRowAtBottom];
        }
        else{
            [weakSelf insertRowAtBottomForTopScores];
        }
        
    }];
    
    [self.leaderBoardTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak LeaderBoard *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getScorers];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.leaderBoardTable.infiniteScrollingView stopAnimating];
    }
}


//Add infinite scroll
- (void) setInfiniteScrollForTeamTableView;
{
    __weak LeaderBoard *weakSelf = self;
    // setup infinite scrolling
    [self.TeamTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottomTeam];
    }];
    
    [self.TeamTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottomTeam {
    if(teamPage > 0 && teamPage != teamPreviousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak LeaderBoard *weakSelf = self;
        [self.TeamTableView.infiniteScrollingView stopAnimating];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            teamPreviousPage = teamPage;
            [weakSelf getTeamInfo];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.TeamTableView.infiniteScrollingView stopAnimating];
    }
}

//Get search friends
-(void) getScorers
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [_leaderBoardTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LEADER_BOARD withCallBack:^(NSDictionary * response){
        
        [_leaderBoardTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            
            if (mediaBase == nil || [mediaBase isEqualToString:@""]) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            [leaders addObjectsFromArray: [[response objectForKey:@"leader_board"] mutableCopy]];
            [self.leaderBoardTable reloadData];
            page = [[response valueForKey:@"page"] intValue];
            if ([response objectForKey:@"player_detais"] != nil) {
                [self bindTheHeaderView:[response valueForKey:@"player_detais"]];
            }
            
            if(selectedTab == 1)
            {
                [_leaderBoardTable setHidden:NO];
            }
            showPlayerLoader = NO;
        }
        
    } isShowLoader:showPlayerLoader];
    
}

-(void)getTeamInfo{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:teamPage] forKey:@"page"];
    [_leaderBoardTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_LEADER_BOARD withCallBack:^(NSDictionary * response){
        [_leaderBoardTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            [team addObjectsFromArray: [[response objectForKey:@"team_list"] mutableCopy]];
            [self.TeamTableView reloadData];
            teamPage = [[response valueForKey:@"page"] intValue];
          
        }
        showTeamLoader = FALSE;
    } isShowLoader:showTeamLoader];

}

- (void)bindTheHeaderView:(NSDictionary *)profileData{
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[profileData objectForKey:@"profile_image"]];
    [_myImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    NSString *boardURL = [NSString stringWithFormat:@"%@%@",mediaBase,[profileData objectForKey:@"skate_board_image"]];
    [_board setImageWithURL:[NSURL URLWithString:boardURL] placeholderImage:nil];
    _rank.text = [NSString stringWithFormat:NSLocalizedString(@"Rank %@", nil),[profileData valueForKey:@"rank"]];
    _name.text = [profileData valueForKey:@"name"];
    _points.text = [profileData valueForKey:@"points"];

}

- (void) createPopUpWindows{
    
    pointsPopupView = [[PointsPopup alloc] initWithViewsshowBuyPoints:TRUE showDonatePoints:TRUE showRedeemPoints:[Util getBoolFromDefaults:@"can_show_shoping"] showPointsActivityLog:TRUE];
    [pointsPopupView setDelegate:self];
    
    pointPopup = [KLCPopup popupWithContentView:pointsPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

- (IBAction)openPointsPopup:(id)sender {
    [pointPopup show];
}

- (IBAction)openPointsInformation:(id)sender {
    PointsInformation *pointsInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"PointsInformation"];
    pointsInfo.pointsFlag=@"1";
    [self.navigationController pushViewController:pointsInfo animated:YES];
   
}

- (IBAction)openTeampoints:(id)sender {
    PointsInformation *pointsInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"PointsInformation"];
    pointsInfo.pointsFlag=@"2";
    [self.navigationController pushViewController:pointsInfo animated:YES];
}

- (IBAction)searchList:(id)sender {
    if(selectedTab == 1)
    {
        PlayersList *playerList = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayersList"];
        NSString *listType =  ([[Util getFromDefaults:@"playerType"] intValue] == 1) ? @"1" : @"2";
        playerList.listType = listType;
        [self.navigationController pushViewController:playerList animated:YES];
    }
    else
    {
        TeamList *teamList = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamList"];
        [self.navigationController pushViewController:teamList animated:YES];
    }
}

-(void)leaderIsEmpty
{
    if ([leaders count] == 0)
    {
        [Util addEmptyMessageToTable:self.leaderBoardTable withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.leaderBoardTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
    
}

-(void)teamIsEmpty
{
    if ([team count] == 0)
    {
        [Util addEmptyMessageToTable:self.TeamTableView withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.TeamTableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
    
}

#pragma mark UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(selectedTab == 1)
    {
        return [leaders count];
    }
    else
    {
        return [team count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedTab == 1){
        
        static NSString *cellIdentifier = @"memberCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        //Read elements
        UIImageView *profileImage = (UIImageView *)[cell viewWithTag:10];
        UIImageView *board = (UIImageView *)[cell viewWithTag:12];
        UILabel *name = [cell viewWithTag:11];
        UILabel *points = [cell viewWithTag:14];
        UILabel *rank = [cell viewWithTag:13];
        
        if ([leaders count] > indexPath.row) {
            
            //Bind the contents
            NSDictionary *leader = [leaders objectAtIndex:indexPath.row];
            name.text = [leader valueForKey:@"player_name"];
            points.text = [NSString stringWithFormat:@"%@",[leader valueForKey:@"live_leader_board_points"]];
            rank.text = [NSString stringWithFormat:@"#%@",[leader valueForKey:@"Rank"]];
            
            NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[leader objectForKey:@"profile_image"]];
            [profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            NSString *boardURL = [NSString stringWithFormat:@"%@%@",mediaBase,[leader objectForKey:@"skate_board_image"]];
            [board setImageWithURL:[NSURL URLWithString:boardURL] placeholderImage:nil];
            
            //Add zoom
            //[[Util sharedInstance] addImageZoom:profileImage];
        }
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"teamCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        //Read elements
        UIImageView *profileImage = (UIImageView *)[cell viewWithTag:10];
        UILabel *name = [cell viewWithTag:11];
        UILabel *points = [cell viewWithTag:12];
        UILabel *rank = [cell viewWithTag:13];
        name.numberOfLines=0;
        //Bind the contents
        if ([team count] > indexPath.row)
        {
            NSDictionary *teamDetail = [team objectAtIndex:indexPath.row];
            name.text = [teamDetail valueForKey:@"name"];
            points.text = [teamDetail valueForKey:@"team_points"];
            rank.text = [NSString stringWithFormat:@"#%@",[teamDetail valueForKey:@"rank"]];
            NSDictionary *dict=[teamDetail objectForKey:@"profile_image"];
            NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[dict objectForKey:@"profile_image"]];
            [profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        }
        
//        //Add zoom
//        [[Util sharedInstance] addImageZoom:profileImage];
        
        return  cell;
    }
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(selectedTab == 1)
    {
        if([leaders count] > indexPath.row){
            NSDictionary *leader = [leaders objectAtIndex:indexPath.row];
            FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            friendProfile.friendId = [leader valueForKey:@"player_id"];
            friendProfile.friendName = [leader valueForKey:@"player_name"];
            [self.navigationController pushViewController:friendProfile animated:YES];
        }
    }
    else
    {
        if([team count] > indexPath.row){
            NSDictionary *teamDetail = [team objectAtIndex:indexPath.row];
            if ([[teamDetail valueForKey:@"player_relationship_status"] intValue] == 4) {
                NonMemberTeamViewController *nonMember = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
                nonMember.teamId = [teamDetail objectForKey:@"id"];
                [self.navigationController pushViewController:nonMember animated:YES];
            }
            else{
                TeamViewController *teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
                teamView.teamId = [teamDetail objectForKey:@"id"];
                [self.navigationController pushViewController:teamView animated:YES];
            }
        }        
        
    }
}


#pragma argu - KLCPointpopup delegate
- (void)onBuyPointsClick{
    [pointPopup dismiss:YES];
    BuyPointsViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"BuyPointsViewController"];
    [self.navigationController pushViewController:profile animated:YES];
}
-(void)onDonatePointsClick{
    [pointPopup dismiss:YES];
    DonatePoint *donatePoint = [self.storyboard instantiateViewControllerWithIdentifier:@"DonatePoint"];
    donatePoint.donationFrom = 1;
    [self.navigationController pushViewController:donatePoint animated:YES];
}
-(void)onRedeemPointsClick{
    [pointPopup dismiss:YES];
    ShoppingHome *shoppingHome = [self.storyboard instantiateViewControllerWithIdentifier:@"ShoppingHome"];
    [self.navigationController pushViewController:shoppingHome animated:YES];
}
-(void)onPointsActivityLog{
    [pointPopup dismiss:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

    PointsActivityLog *points = [mainStoryboard instantiateViewControllerWithIdentifier:@"PointsActivityLog"];
    points.friendId = @"";
    [self.navigationController pushViewController:points animated:YES];
}


-(IBAction)generalButton:(id)sender
{
    selectedTab = 1;
    [self changeTabColor:selectedTab];
}

-(IBAction)eventsButton:(id)sender
{
    selectedTab = 2;
    [self changeTabColor:selectedTab];
}

-(void)changeTabColor:(int)tab
{
    if (tab == 1) {
        _playerTab.backgroundColor = UIColorFromHexCode(THEME_COLOR);
        _teamTab.backgroundColor = [UIColor clearColor];
        [_leaderBoardTable setHidden:NO];
        [_TeamTableView setHidden:YES];
        [_leaderBoardTable reloadData];
    }
    else{
        _teamTab.backgroundColor = UIColorFromHexCode(THEME_COLOR);
        _playerTab.backgroundColor = [UIColor clearColor];
        [_leaderBoardTable setHidden:YES];
        [_TeamTableView setHidden:NO];
         [self getTeamInfo];
        [_TeamTableView reloadData];
    }
}





//------------------  STRAT TOP SCORES -------------------------


//Add load more items
- (void)insertRowAtBottomForTopScores {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak LeaderBoard *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getScorers];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.leaderBoardTable.infiniteScrollingView stopAnimating];
    }
}

//Get search friends
-(void) getTopScorers
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [_leaderBoardTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TOP_SCORERS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [_leaderBoardTable.infiniteScrollingView stopAnimating];
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            [leaders addObjectsFromArray: [[response objectForKey:@"leader_board"] mutableCopy]];
            [self.leaderBoardTable reloadData];
            page = [[response valueForKey:@"page"] intValue];
        }
        
    } isShowLoader:NO];
    
}

@end
