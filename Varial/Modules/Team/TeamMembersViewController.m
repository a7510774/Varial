//
//  TeamMembersViewController.m
//  Varial
//
//  Created by Shanmuga priya on 2/25/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "TeamMembersViewController.h"
#import "UIImageView+AFNetworking.h"
@interface TeamMembersViewController ()

@end

@implementation TeamMembersViewController
NSIndexPath *selectedIndexPath;
@synthesize  TeamMembersTableView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    TeamMembersList=[[NSMutableArray alloc]init];
    searchResult=[[NSMutableArray alloc]init];
    page = searchPage = 1;
    
    [self designTheView];
    
    [self getTeamMemberList];
    [self setInfiniteScrollForTableView];
}


- (void)designTheView
{
    [Util setPadding:_searchField];
    
    [_headerView setHeader:NSLocalizedString(TEAM_MEMBERS, nil)];
    [_headerView.logo setHidden:YES];
    
    //Set transparent color to tableview
    [self.TeamMembersTableView setBackgroundColor:[UIColor clearColor]];
    self.TeamMembersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchTable setBackgroundColor:[UIColor clearColor]];
    self.searchTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_searchTable setHidden:YES];
    
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    _headerView.backgroundColor=[UIColor blackColor];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_searchField addTarget:self  action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    
    
    if ([_ableToRemove isEqualToString:@"YES"]) {
        
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(handleLongPress:)];
        longpress.minimumPressDuration = 1.0; //seconds
        longpress.delegate = self;
        [_searchTable addGestureRecognizer:longpress];
        [TeamMembersTableView addGestureRecognizer:longpress];

    }
    
    //Alert popup
    removeConfirmation = [[YesNoPopup alloc] init];
    removeConfirmation.delegate = self;
    [removeConfirmation setPopupHeader:NSLocalizedString(TEAM, nil)];
    removeConfirmation.message.text = NSLocalizedString(SURE_TO_REMOVE, nil);
    [removeConfirmation.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [removeConfirmation.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    removeConfirmationPopup = [KLCPopup popupWithContentView:removeConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = [_searchField.text length] > 0 ? _searchTable : TeamMembersTableView;
    CGPoint p = [gestureRecognizer locationInView:tableView];
    selectedIndexPath = [tableView indexPathForRowAtPoint:p];
    [removeConfirmationPopup show];
}


//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak TeamMembersViewController *weakSelf = self;
    // setup infinite scrolling
    [self.TeamMembersTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.searchTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreSearchResult];
    }];
    [self.TeamMembersTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.searchTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak TeamMembersViewController *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getTeamMemberList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.TeamMembersTableView.infiniteScrollingView stopAnimating];
    }
}

//Add load more items
- (void)loadMoreSearchResult {
    if(searchPage > 0 && searchPage != searchPreviousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak TeamMembersViewController *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            searchPreviousPage = searchPage;
            [weakSelf getSearchTeamMemberList];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void) textChangeListener :(UITextField *) searchBox
{
    if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        self.TeamMembersTableView.hidden=YES;
        searchPage = 1;
        if (task != nil) {
            [task cancel];
        }
        [self getSearchTeamMemberList];
    }
    else{
        [_clearButton setHidden:YES];
        [self.searchTable setHidden:YES];
        self.TeamMembersTableView.hidden=NO;
    }
    
    if ([_searchField.text length] > 0) {
        [_clearButton setHidden:NO];
    }
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.TeamMembersTableView) {
        return [TeamMembersList count];
    }
    else
        return [searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    cellIdentifier = tableView == _searchTable ? @"TeamSearchCell" : @"TeamCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //Read elements
    
    UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
    UILabel *name =  (UILabel *)[cell viewWithTag:11];
    UILabel *points = (UILabel *) [cell viewWithTag:12];
    UILabel *rank = (UILabel *) [cell viewWithTag:13];
    UIImageView *board = (UIImageView *)[cell viewWithTag:14];
    
    NSDictionary *list = tableView == self.searchTable ? [searchResult objectAtIndex:indexPath.row] : [TeamMembersList objectAtIndex:indexPath.row];
    
    name.text = [list objectForKey:@"name"];
    points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[list objectForKey:@"point"]];
    
    NSString *rankLabel = [Util playerType:[[list valueForKey:@"player_type_id"] intValue] playerRank:[list objectForKey:@"rank"]];
    rank.text = rankLabel;
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[[TeamMembersList objectAtIndex:indexPath.row]  objectForKey:@"profile_image"]];
    [profile setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[[TeamMembersList objectAtIndex:indexPath.row]  objectForKey:@"player_skate_pic"]];
    [board setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:nil];
    
    return cell;
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *friend = tableView == self.searchTable ? [searchResult objectAtIndex:indexPath.row] : [TeamMembersList objectAtIndex:indexPath.row];
    
    if ([[friend valueForKey:@"my_self"] boolValue]) {
        MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
        [self.navigationController pushViewController:myProfile animated:YES];
    }
    else{
        FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        friendProfile.friendId = [friend valueForKey:@"team_member_id"];
        friendProfile.friendName = [friend valueForKey:@"name"];
        [self.navigationController pushViewController:friendProfile animated:YES];
    }

}


- (IBAction)clearClick:(id)sender
{
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    [self.searchTable setHidden:YES];
    [self.TeamMembersTableView setHidden:NO];
}

//Add empty message in table background view
- (void)addEmptyMessageForTeamMembersList{
    
    if ([TeamMembersList count] == 0) {
        [Util addEmptyMessageToTable:self.TeamMembersTableView withMessage:NO_MEMBERS_PRESENT withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:self.TeamMembersTableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
}
- (void)addEmptyMessageForSearchTable{
    
    if ([searchResult count] == 0) {
        [Util addEmptyMessageToTable:self.searchTable withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:self.searchTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}


//Get friends list
-(void)getTeamMemberList {
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [TeamMembersTableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LIST_TEAM_MEMBERS withCallBack:^(NSDictionary * response){
        [TeamMembersTableView.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            if (strMediaUrl == nil) {
                strMediaUrl = [response objectForKey:@"media_base_url"];
            }
            page = [[response valueForKey:@"page"] intValue];
            [TeamMembersList addObjectsFromArray:[[response objectForKey:@"team_member_list"] mutableCopy]];
            [self addEmptyMessageForTeamMembersList];
            [TeamMembersTableView reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}


//Get search friends
-(void) getSearchTeamMemberList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchPage] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_TEAM_MEMBER withCallBack:^(NSDictionary * response){
        [_searchTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            
            //Hide or show the search table
            [self.searchTable setHidden:NO];
            if([_searchField.text isEqualToString:@""]){
                [self.searchTable setHidden:YES];
            }
            
            if (searchPage == 1) {
                [searchResult removeAllObjects];
                strMediaUrl = [response objectForKey:@"media_base_url"];
            }
            
            [searchResult addObjectsFromArray: [[response objectForKey:@"team_member_search_details"] mutableCopy]];
            [self.searchTable reloadData];
            
            searchPage = [[response valueForKey:@"page"] intValue];
            
            //Add no result message
            [self addEmptyMessageForSearchTable];
            
            //Scroll to top
            [Util scrollToTop:_searchTable  fromArrayList:searchResult];
            
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}

#pragma args YesNoPopup deleagates
- (void)onYesClick{
    if (selectedIndexPath != nil) {
        [self removeMember];
    }
}
- (void)onNoClick{
     [removeConfirmationPopup dismiss:YES];
}


// Remove Member
-(void)removeMember
{
    NSMutableDictionary *member = [[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 ? [searchResult objectAtIndex:selectedIndexPath.row] : [TeamMembersList objectAtIndex:selectedIndexPath.row];
    
    NSString *memberId = [member objectForKey:@"team_member_id"];
    
    // Build Parameter
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    [inputParams setValue:memberId forKey:@"team_member_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:REMOVE_TEAM_MEMBER withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            if ([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 ) {
                [_searchTable beginUpdates];
                [searchResult removeObjectAtIndex:selectedIndexPath.row];
                [_searchTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation: UITableViewRowAnimationLeft];
                [_searchTable endUpdates];
            }
            else{
                [TeamMembersTableView beginUpdates];
                [TeamMembersList removeObjectAtIndex:selectedIndexPath.row];
                [TeamMembersTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation: UITableViewRowAnimationLeft];
                [TeamMembersTableView endUpdates];
            }
            [removeConfirmationPopup dismiss:YES];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] ];
        }
    } isShowLoader:YES];
}


@end
