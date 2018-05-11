//
//  TeamInvitiesViewController.m
//  Varial
//
//  Created by Shanmuga priya on 2/25/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "TeamInvitiesViewController.h"
#import "FriendsChat.h"
#import "XMPPServer.h"
#import "ViewController.h"

@interface TeamInvitiesViewController ()

@end

@implementation TeamInvitiesViewController

@synthesize TeamTableView, SearchTableView;

// ------ type = 1 is -> Set Co-Captain
// ------ type = 2 is -> Change Co-Captain
// ------ type = 3 is -> Add Member
// ------ type = 4 is -> View Invities
// ------ type = 5 is -> Select Captain

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    teamList = [[NSMutableArray alloc] init];
    searchList = [[NSMutableArray alloc] init];
    titleList = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(SET_CO_CAPTAIN, nil),NSLocalizedString(CHANGE_CO_CAPTAIN, nil),NSLocalizedString(ADD_MEMBERS, nil),NSLocalizedString(VIEW_INVITIES, nil),NSLocalizedString(SELECT_CAPTAIN_TITLE, nil), nil] ;
    page = previousPage = 1;
    searchpage = searchPreviousPage = 1;
    [self designTheView];
    [self setInfiniteScrollForTableView];
    if([_type intValue] == 1 || [_type intValue] == 2)
    {
        [self getCoCaptainList];
    }
    else if([_type intValue] == 3)
    {
        [self getMemberList];
    }
    else if([_type intValue] == 4)
    {
        [self getInvitiesList];
    }
    else if([_type intValue] == 5)
    {
        [self getAvailableCaptainList];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)designTheView
{
    
    [Util setPadding:_searchField];
    TeamTableView.backgroundColor=[UIColor clearColor];
    SearchTableView.backgroundColor=[UIColor clearColor];
    
    TeamTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    SearchTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [Util createRoundedCorener:_doneButton withCorner:3];
    
    if ([_type intValue] == 1) {
        [_headerView setHeader: NSLocalizedString([titleList objectAtIndex:0], nil)];
    }
    else if ([_type intValue] == 2) {
        [_headerView setHeader: NSLocalizedString([titleList objectAtIndex:1], nil)];
    }
    else if ([_type intValue] == 3) {
        [_headerView setHeader: NSLocalizedString([titleList objectAtIndex:2], nil)];
    }
    else if ([_type intValue] == 4) {
        [_headerView setHeader: NSLocalizedString([titleList objectAtIndex:3], nil)];
    }
    else if ([_type intValue] == 5) {
        [_headerView setHeader: NSLocalizedString([titleList objectAtIndex:4], nil)];
    }
   
    [_headerView.logo setHidden:YES];

    _headerView.backgroundColor=[UIColor blackColor];
    
    TeamTableView.hidden = YES;
    SearchTableView.hidden = YES;
    
    // Show the Done button if come from the create team page
    if ([_isCreateTeam isEqualToString:@"yes"]) {
        [_doneView setHidden:NO];
        [_headerView.back setHidden:YES];
        
        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
        [navigationArray removeObjectAtIndex: [navigationArray count] - 2];
        self.navigationController.viewControllers = navigationArray;

    }
    else{
        [_doneView hideByHeight:YES];
        [_doneView setHidden:YES];
    }
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader: NSLocalizedString(TEAM_INVITE, nil)];
    popupView.message.text = NSLocalizedString(CANCEL_FOR_SURE, nil);
    [popupView.yesButton setTitle:NSLocalizedString(YES_STRING, nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(NO_STRING, nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_searchField addTarget:self  action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak TeamInvitiesViewController *weakSelf = self;
    // setup infinite scrolling
    [self.TeamTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.TeamTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [self.SearchTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreSearchResult];
    }];
    [self.SearchTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];

}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak TeamInvitiesViewController *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            if([_type intValue] == 1 || [_type intValue] == 2)
            {
                [weakSelf getCoCaptainList];
            }
            else if([_type intValue] == 3)
            {
                [weakSelf getMemberList];
            }
            else if([_type intValue] == 4)
            {
                [weakSelf getInvitiesList];
            }
            else if([_type intValue] == 5)
            {
                [weakSelf getAvailableCaptainList];
            }
            
            [self.TeamTableView.infiniteScrollingView stopAnimating];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.TeamTableView.infiniteScrollingView stopAnimating];
    }
}

//Add load more items
- (void)loadMoreSearchResult {
    if(searchpage > 0 && searchpage != searchPreviousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
       __weak TeamInvitiesViewController *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            searchPreviousPage = searchpage;
            if([_type intValue] == 1 || [_type intValue] == 2)
            {
                [weakSelf searchCoCaptainList];
            }
            else if([_type intValue] == 3)
            {
                [weakSelf searchMemberList];
            }
            else if([_type intValue] == 4)
            {
                [weakSelf searchInvitiesList];
            }
            else if([_type intValue] == 5)
            {
                [weakSelf searchAvailableCaptainList];
            }
            
            [self.SearchTableView.infiniteScrollingView stopAnimating];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.SearchTableView.infiniteScrollingView stopAnimating];
    }
}


//Search box text change listener
- (void) textChangeListener :(UITextField *) searchBox
{
    if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        searchpage = 1;
        if (task != nil) {
            [task cancel];
        }
        // Search Team member for set co-captain
        if([_type intValue] == 1 || [_type intValue] == 2)
        {
            [self searchCoCaptainList];
        }
        else if([_type intValue] == 3)
        {
            [self searchMemberList];
        }
        else if([_type intValue] == 4)
        {
            [self searchInvitiesList];
        }
        else if([_type intValue] == 5)
        {
            [self searchAvailableCaptainList];
        }
    }
    else{
        [_clearButton setHidden:YES];
        [self.TeamTableView setHidden:NO];
        [self.SearchTableView setHidden:YES];
      
    }
    
    if ([_searchField.text length] > 0) {
        [_clearButton setHidden:NO];
        [self.TeamTableView setHidden:YES];
        [self.SearchTableView setHidden:NO];
    }
    
}

//Clear search field text
- (IBAction)tappedSearchClear:(id)sender
{
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    [self.TeamTableView setHidden:NO];
    [self.SearchTableView setHidden:YES];
    
}

- (IBAction)tappedDone:(id)sender
{
    TeamViewController *teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
    teamView.teamId = _teamId;
    [self.navigationController pushViewController:teamView animated:YES];
    
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    [navigationArray removeObjectAtIndex: [navigationArray count] - 2];
    self.navigationController.viewControllers = navigationArray;
    
}

//---------------------------------------------------> Invite via varial <--------------------------------------------------//



#pragma mark - UITableViewDelegate method

//set number of rows in tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self selectedArray:tableView] count];
}

//set tableview content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"TeamCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //Read elements
    UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
    UILabel *name = (UILabel *)[cell viewWithTag:11];
    UILabel *points = (UILabel *) [cell viewWithTag:12];
    UILabel *rank = (UILabel *) [cell viewWithTag:13];
    UIImageView *plus = (UIImageView *)[cell viewWithTag:15];
    UIButton *status = (UIButton *)[cell viewWithTag:16];
    UIView *statusView = (UIView *)[cell viewWithTag:17];
    
    [Util createRoundedCorener:statusView withCorner:3];
    
    //[[Util sharedInstance] addImageZoom:profile];
    
    NSDictionary *list = [[self selectedArray:tableView] objectAtIndex:indexPath.row];
    name.text = [list objectForKey:@"name"];
    points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[list objectForKey:@"point"]];    
    NSString *rankLabel = [Util playerType:[[list valueForKey:@"player_type_id"] intValue] playerRank:[list objectForKey:@"rank"]];
    rank.text = rankLabel;
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[[[self selectedArray:tableView] objectAtIndex:indexPath.row]  objectForKey:@"profile_image"]];
    [profile setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
    
    [status removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    //Check Relationship status
    
    if([_type intValue] == 1 || [_type intValue] == 2)
    {
        [status setTitle:NSLocalizedString(SELECT, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:[UIColor redColor]];
        [plus setImage:[UIImage imageNamed: @"invite.png"]];
        row = (int) indexPath.row;
        [status addTarget:self action:@selector(tappedInviteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if([_type intValue] == 3)
    {
        if([[list objectForKey:@"invite_status_flag"] integerValue]==0)
        {
            [status setTitle:NSLocalizedString(INVITE, nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor redColor]];
            [plus setImage:[UIImage imageNamed: @"invite.png"]];
            row = (int) indexPath.row;
            [status addTarget:self action:@selector(tappedInviteButton:) forControlEvents:UIControlEventTouchUpInside];
        }

        else if([[list objectForKey:@"invite_status_flag"] integerValue]==1)
        {
            [status setTitle:NSLocalizedString(CANCEL, nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor grayColor]];
            [plus setImage:[UIImage imageNamed: @"close.png"]];
            [status addTarget:self action:@selector(tappedInviteButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if([_type intValue] == 4)
    {
        [status setTitle:NSLocalizedString(CANCEL, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:[UIColor grayColor]];
        [plus setImage:[UIImage imageNamed: @"close.png"]];
        row = (int) indexPath.row;
        [status addTarget:self action:@selector(tappedInviteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if([_type intValue] == 5)
    {
        [status setTitle:NSLocalizedString(SELECT, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:[UIColor redColor]];
        [plus setImage:[UIImage imageNamed: @"invite.png"]];
        row = (int) indexPath.row;
        [status addTarget:self action:@selector(tappedInviteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SearchTableView.hidden == NO)
    {
        [self showProfileScreen:[searchList objectAtIndex:indexPath.row]];
    }
    else
    {
        [self showProfileScreen:[teamList objectAtIndex:indexPath.row]];
    }
    
}

// Check search result is empty
-(void)searchResultIsEmpty
{
    if ([searchList count] == 0)
    {
        [Util addEmptyMessageToTable:self.SearchTableView withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.SearchTableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
    
}

// Check team table is empty
-(void)teamTableIsEmpty
{
    if ([teamList count] == 0)
    {
        if ([_type intValue] == 1 || [_type intValue] == 2)
        {
            [Util addEmptyMessageToTable:self.TeamTableView withMessage:NSLocalizedString(NO_MEMBERS_IN_TEAM, nil) withColor:[UIColor whiteColor]];
        }
        else if([_type intValue] == 3)
        {
            [Util addEmptyMessageToTable:self.TeamTableView withMessage:NSLocalizedString(NO_MEMBERS_TO_INVITE, nil) withColor:[UIColor whiteColor]];
        }
        else if([_type intValue] == 4)
        {
            [Util addEmptyMessageToTable:self.TeamTableView withMessage:NSLocalizedString(NO_INVITED_MEMBERS, nil) withColor:[UIColor whiteColor]];
        }
        else if([_type intValue] == 5)
        {
            [Util addEmptyMessageToTable:self.TeamTableView withMessage:NSLocalizedString(NO_MEMBERS_TO_SELECT_CAPTAIN, nil) withColor:[UIColor whiteColor]];
        }
    }
    else
    {
        [Util addEmptyMessageToTable:self.TeamTableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
    
}



//---------------------------------------------------> Send invite <--------------------------------------------------//

// Action for invite button in tableview
- (IBAction)tappedInviteButton:(id)sender
{
    CGPoint buttonPosition;
    UITableViewCell *rowSelected;
    NSIndexPath *path;
    NSMutableDictionary *Values = [[NSMutableDictionary alloc] init];
    int searchTable;
    
    if (SearchTableView.hidden == YES) {
        buttonPosition = [sender convertPoint:CGPointZero toView:self.TeamTableView];
        path = [self.TeamTableView indexPathForRowAtPoint:buttonPosition];
        rowSelected = [TeamTableView cellForRowAtIndexPath:path];
        Values = [teamList objectAtIndex:path.row];
        searchTable = 0;
    }
    else{
        buttonPosition = [sender convertPoint:CGPointZero toView:self.SearchTableView];
        path = [self.SearchTableView indexPathForRowAtPoint:buttonPosition];
        rowSelected = [SearchTableView cellForRowAtIndexPath:path];
        Values = [searchList objectAtIndex:path.row];
        searchTable = 1;
    }
    // For Cancel Invities
    viewInvitiesIndexPath = path;
    viewInvitiesRowSelected = rowSelected;
    viewInvitiesSearchTable = searchTable;
    viewInvitiesSelectedValues = Values;
    
    UIButton *button = (UIButton *)[rowSelected viewWithTag:16];
    
    if([_type intValue] == 1 || [_type intValue] == 2)
    {
        [button setTitle:NSLocalizedString(INVITING, nil) forState:UIControlStateNormal];
        [self setCoCaptain:path selectedValues:Values forButton:button];
    }
    else if([_type intValue] == 3)
    {
        if ([[Values objectForKey:@"invite_status_flag"] integerValue] == 0) {
            [button setTitle:NSLocalizedString(INVITING, nil) forState:UIControlStateNormal];
            [self AddMember:path Cell:rowSelected isSearchTable:searchTable selectedValues:Values];
        }
        else{
            [yesNoPopup show];
           // [self cancelInvities:path Cell:rowSelected isSearchTable:searchTable selectedValues:Values isAddMember:1];
        }
        
    }
    else if([_type intValue] == 4)
    {
        [yesNoPopup show];
    }
    else if([_type intValue] == 5)
    {
        [self selectCaptain:path selectedValues:Values];
    }
    
}


// ------------------- START - VIEW INVITIES ----------------------


// API access for  Cancel Invities
-(void)cancelInvities:(NSIndexPath *)path Cell:(UITableViewCell *)cell isSearchTable:(int)searchTable selectedValues:(NSMutableDictionary *)response isAddMember:(int)addmember
{
    
    NSMutableDictionary *dic=[response mutableCopy];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:[response objectForKey:@"team_member_id"] forKey:@"team_member_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CANCEL_INVITIES withCallBack:^(NSDictionary * response){

        UIImageView *plus=(UIImageView *)[cell viewWithTag:15];
        UIButton *status=(UIButton *)[cell viewWithTag:16];
        UIView *statusView =(UIView *)[cell viewWithTag:17];
        
        if([[response valueForKey:@"status"] boolValue]){
            
            // Cancel from Addmember page
            if (addmember == 1)
            {
                [status setTitle:NSLocalizedString(INVITE, nil) forState:UIControlStateNormal];
                [statusView setBackgroundColor:[UIColor redColor]];
                [plus setImage:[UIImage imageNamed: @"invite.png"]];
                // Is invite from the search table
                if (searchTable == 1) {
                    
                    [dic setObject:@"0" forKey:@"invite_status_flag"];
                    [searchList replaceObjectAtIndex:path.row withObject:dic];
                    
                    // If Invite from the search table should reload the data to team table also
                    int index = [Util getMatchedObjectPosition:@"team_member_id" valueToMatch:[dic objectForKey:@"team_member_id"] from:teamList type:1];
                    
                    if (index != -1) {
                        [TeamTableView beginUpdates];
                        [teamList replaceObjectAtIndex:index withObject:dic];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        [TeamTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                        [TeamTableView endUpdates];
                    }
                }
                // Is invote from the Team Table
                else{
                    [dic setObject:@"0" forKey:@"invite_status_flag"];
                    [teamList replaceObjectAtIndex:path.row withObject:dic];
                }
            }
            else // Cancel from Invities page
            {
                // Is invite from the search table
                if (searchTable == 1) {
                    [SearchTableView beginUpdates];
                    [searchList removeObjectAtIndex:path.row];
                    [SearchTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation: UITableViewRowAnimationLeft];
                    [SearchTableView endUpdates];
                    
                    // If Cancel from the search table should remove the data to team table also
                    int index = [Util getMatchedObjectPosition:@"team_member_id" valueToMatch:[dic objectForKey:@"team_member_id"] from:teamList type:1];
                    
                    if (index != -1) {
                        [TeamTableView beginUpdates];
                        [teamList removeObjectAtIndex:path.row];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        [TeamTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationLeft];
                        [TeamTableView endUpdates];
                    }
                    [self teamTableIsEmpty];
                }
                // Is Cancel from the Team Table
                else{
                    [TeamTableView beginUpdates];
                    [teamList removeObjectAtIndex:path.row];
                    [TeamTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation: UITableViewRowAnimationLeft];
                    [TeamTableView endUpdates];
                    [self teamTableIsEmpty];
                }
            }
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}



// API access for get Invities List
-(void)getInvitiesList
{
    TeamTableView.hidden = NO;
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [self.TeamTableView.infiniteScrollingView startAnimating];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:VIEW_INVITIES_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue])
        {
            [teamList addObjectsFromArray:[[response objectForKey:@"view_all_pending_invites"] mutableCopy]];
            [self teamTableIsEmpty];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        page = [[response valueForKey:@"page"] intValue];
        strMediaUrl = [response valueForKey:@"media_base_url"];
        [self.TeamTableView reloadData];
        [self.TeamTableView.infiniteScrollingView stopAnimating];
        
    } isShowLoader:NO];
}

// Search Invities List
-(void)searchInvitiesList
{
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchpage] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    
    [self.SearchTableView.infiniteScrollingView startAnimating];
    
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_INVITIES_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            if (searchpage == 1) {
                [searchList removeAllObjects];
            }
            [searchList addObjectsFromArray: [[response objectForKey:@"view_all_pending_invites"] mutableCopy]];
            [self.SearchTableView reloadData];
            
            searchpage = [[response valueForKey:@"page"] intValue];
            strMediaUrl = [response valueForKey:@"media_base_url"];
            
            [self searchResultIsEmpty];
            
            //Scroll to top
            [Util scrollToTop:self.SearchTableView  fromArrayList:searchList];
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
        [self.SearchTableView.infiniteScrollingView stopAnimating];
        
    } isShowLoader:NO];
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    
    if ([_type intValue] == 4) {
        [self cancelInvities:viewInvitiesIndexPath Cell:viewInvitiesRowSelected isSearchTable:viewInvitiesSearchTable selectedValues:viewInvitiesSelectedValues isAddMember:0];
    }
    else{
        [self cancelInvities:viewInvitiesIndexPath Cell:viewInvitiesRowSelected isSearchTable:viewInvitiesSearchTable selectedValues:viewInvitiesSelectedValues isAddMember:1];
    }
    
    [yesNoPopup dismiss:YES];
}

- (void)onNoClick{
    [yesNoPopup dismiss:YES];
}

// ------------------- END - VIEW INVITIES ----------------------

// ------------------- START - ADD MEMBER ----------------------


// API access for Add team Member
-(void)AddMember:(NSIndexPath *)path Cell:(UITableViewCell *)cell isSearchTable:(int)searchTable selectedValues:(NSMutableDictionary *)response
{
    
     NSMutableDictionary *dic=[response mutableCopy];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:[response objectForKey:@"team_member_id"] forKey:@"team_member_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ADD_MEMBER withCallBack:^(NSDictionary * response){
        
        UIImageView *plus=(UIImageView *)[cell viewWithTag:15];
        UIButton *status=(UIButton *)[cell viewWithTag:16];
        UIView *statusView =(UIView *)[cell viewWithTag:17];
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [status setTitle:NSLocalizedString(CANCEL, nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor grayColor]];
            [plus setImage:[UIImage imageNamed: @"close.png"]];
            // Is invite from the search table
            if (searchTable == 1) {
                
                [dic setObject:@"1" forKey:@"invite_status_flag"];
                [searchList replaceObjectAtIndex:path.row withObject:dic];
                
                // If Invite from the search table should reload the data to team table also
                int index = [Util getMatchedObjectPosition:@"team_member_id" valueToMatch:[dic objectForKey:@"team_member_id"] from:teamList type:1];
                
                if (index != -1) {
                    [TeamTableView beginUpdates];
                    [teamList replaceObjectAtIndex:index withObject:dic];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [TeamTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                    [TeamTableView endUpdates];
                }
            }
            // Is invote from the Team Table
            else{
                [dic setObject:@"1" forKey:@"invite_status_flag"];
                [teamList replaceObjectAtIndex:path.row withObject:dic];
            }
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            [status setTitle:NSLocalizedString(INVITE, nil) forState:UIControlStateNormal];
        }
        
    } isShowLoader:NO];
}


// API access for get Invite Members List
-(void)getMemberList
{
    TeamTableView.hidden = NO;
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [self.TeamTableView.infiniteScrollingView startAnimating];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:INVITE_MEMBER_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [teamList addObjectsFromArray:[[response objectForKey:@"team_search_details"] mutableCopy]];
            [self teamTableIsEmpty];
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        page = [[response valueForKey:@"page"] intValue];
        strMediaUrl = [response valueForKey:@"media_base_url"];
        [self.TeamTableView reloadData];
        
        [self.TeamTableView.infiniteScrollingView stopAnimating];
        
    } isShowLoader:NO];
}

// Search Invite Member List
-(void)searchMemberList
{
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchpage] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    
    [self.SearchTableView.infiniteScrollingView startAnimating];
    
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_INVITE_MEMBER_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            if (searchpage == 1) {
                [searchList removeAllObjects];
            }
            [searchList addObjectsFromArray: [[response objectForKey:@"team_search_details"] mutableCopy]];
            [self.SearchTableView reloadData];
            
            searchpage = [[response valueForKey:@"page"] intValue];
            strMediaUrl = [response valueForKey:@"media_base_url"];
            
            [self searchResultIsEmpty];
            
            //Scroll to top
            [Util scrollToTop:self.SearchTableView  fromArrayList:searchList];
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
        [self.SearchTableView.infiniteScrollingView stopAnimating];
        
    } isShowLoader:NO];
}




// ------------------- END - ADD MEMBER ----------------------


// ------------------- START - SET AND CHANGE CO-CAPTAIN ----------------------

// API access for set Co-Captain
-(void)setCoCaptain:(NSIndexPath *)path selectedValues:(NSMutableDictionary *)response forButton:(UIButton *)button
{
    NSString *name2 = [response objectForKey:@"name"];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[response objectForKey:@"team_member_id"] forKey:@"new_co_captain_id"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_COCAPTAIN withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){

            FriendsChat *friendsChat = [[FriendsChat alloc] init];
            friendsChat.receiverName = _teamName;
            friendsChat.receiverImage = _teamImage;
            friendsChat.receiverID = _roomId;
            
            if ([_type intValue] == 1) // Set Co-Captain
            {
                [friendsChat sendMessageIfUserLeft:_roomId name1:[Util getFromDefaults:@"user_name"] name2:name2 type:@"4"];
            }
            else if ([_type intValue] == 2) // Change CoCaptain
            {
             //   [friendsChat sendMessageIfUserLeft:_roomId name1:[Util getFromDefaults:@"user_name"] name2:_coCaptainName type:@"3"];
                
                [friendsChat sendMessageIfUserLeft:_roomId name1:[Util getFromDefaults:@"user_name"] name2:name2 type:@"4"];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [button setTitle:NSLocalizedString(SELECT, nil) forState:UIControlStateNormal];
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:YES];
}

// API access for get CoCaptain List
-(void)getCoCaptainList
{
    TeamTableView.hidden = NO;
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [self.TeamTableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_COCAPTAIN_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [teamList addObjectsFromArray:[[response objectForKey:@"team_member_list"] mutableCopy]];
            [self teamTableIsEmpty];
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        page = [[response valueForKey:@"page"] intValue];
        strMediaUrl = [response valueForKey:@"media_base_url"];
        [self.TeamTableView reloadData];
        
        [self.TeamTableView.infiniteScrollingView stopAnimating];
    } isShowLoader:NO];
}

// API access for get Search CoCaptain List
-(void)searchCoCaptainList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchpage] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    
    [self.SearchTableView.infiniteScrollingView startAnimating];
    
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_COCAPTAIN_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            if (searchpage == 1) {
                [searchList removeAllObjects];
            }
            
            [searchList addObjectsFromArray: [[response objectForKey:@"team_member_search_details"] mutableCopy]];
            
            [self.SearchTableView reloadData];
            
            searchpage = [[response valueForKey:@"page"] intValue];
            strMediaUrl = [response valueForKey:@"media_base_url"];

            [self searchResultIsEmpty];
            
            //Scroll to top
            [Util scrollToTop:self.SearchTableView  fromArrayList:searchList];
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        [self.SearchTableView.infiniteScrollingView stopAnimating];
        
    } isShowLoader:NO];
}


// ------------------- END - SET AND CHANGE CO-CAPTAIN ----------------------

// ------------------- START - SELECT CAPTAIN ----------------------

// API access for select Captain
-(void)selectCaptain:(NSIndexPath *)path selectedValues:(NSMutableDictionary *)response
{
    NSString *selectedCaptainName = [response objectForKey:@"name"];
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[response objectForKey:@"team_member_id"] forKey:@"new_captain_id"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SELECT_CAPTAIN withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue])
        {
            FriendsChat *friendsChat = [[FriendsChat alloc] init];
            friendsChat.receiverName = _teamName;
            friendsChat.receiverImage = _teamImage;
            friendsChat.receiverID = _roomId;
            [friendsChat sendMessageIfUserLeft:_roomId name1:[Util getFromDefaults:@"user_name"] name2:selectedCaptainName type:@"6"];
            [friendsChat sendMessageIfUserLeft:_roomId name1:[Util getFromDefaults:@"user_name"] name2:@"" type:@"5"];
            
            ViewController *viewController = [[self.navigationController viewControllers] firstObject];
            [viewController.feedTypeList removeAllObjects];
            
            // Select captain From List Page
            if([_selectCaptainFromListPage isEqualToString:@"yes"])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            // Select Captain From TeamDetail Page
            else
            {
                NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
                [navigationArray removeObjectAtIndex: [navigationArray count]-1];
                [navigationArray removeObjectAtIndex: [navigationArray count]-1];
                self.navigationController.viewControllers = navigationArray;
            }
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:YES];
}

// API access for get available Captain List
-(void)getAvailableCaptainList
{
    TeamTableView.hidden = NO;
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [self.TeamTableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LIST_AVAILABLE_CAPTAIN withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [teamList addObjectsFromArray:[[response objectForKey:@"team_member_list"] mutableCopy]];
            [self teamTableIsEmpty];
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        page = [[response valueForKey:@"page"] intValue];
        strMediaUrl = [response valueForKey:@"media_base_url"];
        [self.TeamTableView reloadData];
        
        [self.TeamTableView.infiniteScrollingView stopAnimating];
    } isShowLoader:NO];
}

// API access for get Search Availabe Captain List
-(void)searchAvailableCaptainList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchpage] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    
    [self.SearchTableView.infiniteScrollingView startAnimating];
    
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_AVAILABLE_CAPTAIN withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            if (searchpage == 1) {
                [searchList removeAllObjects];
            }
            [searchList addObjectsFromArray: [[response objectForKey:@"team_member_search_details"] mutableCopy]];
            [self.SearchTableView reloadData];
            
            searchpage = [[response valueForKey:@"page"] intValue];
            strMediaUrl = [response valueForKey:@"media_base_url"];
            
            [self searchResultIsEmpty];
            
            //Scroll to top
            [Util scrollToTop:self.SearchTableView  fromArrayList:searchList];
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        [self.SearchTableView.infiniteScrollingView stopAnimating];
        
    } isShowLoader:NO];
}


// ------------------- END - SELECT CAPTAIN ----------------------

-(NSMutableArray *)selectedArray :(UITableView *)tableView
{
    if (tableView == SearchTableView) {
        return searchList;
    }
    else if(tableView == TeamTableView)
    {
        return teamList;
    }
    return nil;
}

-(void)showProfileScreen :(NSMutableDictionary *)selectedValues
{
    FriendProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    profile.friendName = [selectedValues objectForKey:@"name"];
    profile.friendId = [selectedValues objectForKey:@"team_member_id"];
    [self.navigationController pushViewController:profile animated:YES];
}


@end
