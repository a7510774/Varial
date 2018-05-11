//
//  PlayersList.m
//  Varial
//
//  Created by Shanmuga priya on 4/21/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "PlayersList.h"

@interface PlayersList ()

@end

@implementation PlayersList

@synthesize  playersTable;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    searchPage = searchPreviousPage = 1;
    searchResult=[[NSMutableArray alloc]init];
    [self designTheView];
    [self setInfiniteScrollForTableView];
}

- (void)viewWillAppear:(BOOL)animated{
    page = playersPreviousPage = 1;
    playerList=[[NSMutableArray alloc]init];
    [self getPlayersList];
}

- (void)designTheView
{
    
    [Util setPadding:_searchField];
   
    [_headerView setHeader: NSLocalizedString(PLAYER_LIST_TITLE, nil)];

    [_headerView.logo setHidden:YES];
    
    //Set transparent color to tableview
    [self.playersTable setBackgroundColor:[UIColor clearColor]];
    self.playersTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchTable setBackgroundColor:[UIColor clearColor]];
    self.searchTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_searchTable setHidden:YES];

    
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
    __weak PlayersList *weakSelf = self;
    // setup infinite scrolling
    [self.playersTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.searchTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreSearchResult];
    }];
    [self.playersTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.searchTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != playersPreviousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak PlayersList *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            playersPreviousPage = page;
            [weakSelf getPlayersList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.playersTable.infiniteScrollingView stopAnimating];
    }
}

//Add load more items
- (void)loadMoreSearchResult {
    if(searchPage > 0 && searchPreviousPage != searchPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak PlayersList *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            searchPreviousPage = searchPage;
            [weakSelf getSearchPlayersList];
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

- (void) textChangeListener :(UITextField *) searchBox
{
    if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        self.playersTable.hidden=YES;
        searchPage = 1;
        if (task != nil) {
            [task cancel];
        }
        [self getSearchPlayersList];
    }
    else{
        [_clearButton setHidden:YES];
        [self.searchTable setHidden:YES];
        self.playersTable.hidden=NO;
    }
    
    if ([_searchField.text length] > 0) {
        [_clearButton setHidden:NO];
    }
}


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.playersTable) {
        return [playerList count];
    }
    else
        return [searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"playersCell";
    cellIdentifier = tableView == _searchTable ? @"SearchCell" : @"playersCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
      NSDictionary *list = tableView == self.searchTable ? [searchResult objectAtIndex:indexPath.row] : [playerList objectAtIndex:indexPath.row];
    //Read elements
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:10];
    UIImageView *board = (UIImageView *)[cell viewWithTag:12];
    UILabel *name = [cell viewWithTag:11];
    UILabel *points = [cell viewWithTag:14];
    UILabel *rank = [cell viewWithTag:13];
    
    //Bind the contents
    name.text = [list valueForKey:@"player_name"];
    points.text = [NSString stringWithFormat:@"%@",[list valueForKey:@"live_leader_board_points"]];
    rank.text = [NSString stringWithFormat:@"#%@",[list valueForKey:@"Rank"]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"profile_image"]];
    [profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    NSString *boardURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"skate_board_image"]];
    [board setImageWithURL:[NSURL URLWithString:boardURL] placeholderImage:nil];
    
    //Add zoom
    //[[Util sharedInstance] addImageZoom:profileImage];
    
    return cell;

    }


//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array =  tableView == self.searchTable ? searchResult : playerList;
    if(indexPath.row < [array count])
    {
        NSDictionary *player =[array objectAtIndex:indexPath.row];
        if ([[player valueForKey:@"my_self"] boolValue])
        {
            MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
            [self.navigationController pushViewController:myProfile animated:YES];
        }
        else{
            FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            friendProfile.friendId = [player valueForKey:@"player_id"];
            friendProfile.friendName = [player valueForKey:@"player_name"];
            [self.navigationController pushViewController:friendProfile animated:YES];
        }
    }
}


- (IBAction)clearClick:(id)sender
{
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    [self.searchTable setHidden:YES];
    [self.playersTable setHidden:NO];
}

//Add empty message in table background view
- (void)addEmptyMessageForPlayersTable{
    
    if ([playerList count] == 0) {
        [Util addEmptyMessageToTable:self.playersTable withMessage:NO_PLAYERS_MESSAGE withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:self.playersTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}
- (void)addEmptyMessageForSearchTable{
    [self.searchTable setHidden:NO];
    if ([searchResult count] == 0) {
        [Util addEmptyMessageToTable:self.searchTable withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:self.searchTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}


//Get Players list
-(void) getPlayersList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
     [playersTable.infiniteScrollingView startAnimating];
    
    // 1. If Current user is an Scater should show players list("LEADER_BOARD").  2. Current user is an Crew or Media should show Topscorers lists
    //  _listType = 1 is an Leader board and 2 is an Top Score
    NSString *url = ([_listType intValue] == 1) ? LEADER_BOARD : TOP_SCORERS;
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
        
        [playersTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            if (strMediaUrl == nil) {
                strMediaUrl = [response objectForKey:@"media_base_url"];
            }
            page = [[response valueForKey:@"page"] intValue];
            [playerList addObjectsFromArray:[[response objectForKey:@"leader_board"] mutableCopy]];
            [self addEmptyMessageForPlayersTable];
            [playersTable reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}


//Get search player
-(void) getSearchPlayersList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchPage] forKey:@"page"];
    [inputParams setValue:_searchField.text forKey:@"player_name"];
    
    [_searchTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PLAYERS_LIST_SEARCH withCallBack:^(NSDictionary * response){
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
                
                [searchResult addObjectsFromArray: [[response objectForKey:@"leader_board"] mutableCopy]];
                [self.searchTable reloadData];
                
                searchPage = [[response valueForKey:@"page"] intValue];
                
                //Add no result message
                [self addEmptyMessageForSearchTable];
                
                //Scroll to top
                [Util scrollToTop:_searchTable  fromArrayList:searchResult];
            });
        }
        else{
            [_searchTable.infiniteScrollingView stopAnimating];
            [searchResult removeAllObjects];
            [self.searchTable reloadData];
            [self addEmptyMessageForSearchTable];
        }
        
    } isShowLoader:NO];
    
}




@end
