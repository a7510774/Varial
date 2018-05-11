//
//  TeamList.m
//  Varial
//
//  Created by Shanmuga priya on 4/21/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "TeamList.h"
#import "NonMemberTeamViewController.h"
#import "TeamViewController.h"
@interface TeamList ()

@end

@implementation TeamList

@synthesize  teamTable;
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
    page = teamPreviousPage = 1;
    teamList=[[NSMutableArray alloc]init];
    [self getTeamList];
    
}

- (void)designTheView
{
    
    [Util setPadding:_searchField];

    [_headerView setHeader:NSLocalizedString(TEAM_LIST_TITLE, nil)];
    [_headerView.logo setHidden:YES];
    
    //Set transparent color to tableview
    [self.teamTable setBackgroundColor:[UIColor clearColor]];
    self.teamTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    __weak TeamList *weakSelf = self;
    // setup infinite scrolling
    [self.teamTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.searchTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreSearchResult];
    }];
    [self.teamTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.searchTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != teamPreviousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak TeamList *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            teamPreviousPage = page;
            [weakSelf getTeamList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.teamTable.infiniteScrollingView stopAnimating];
    }
}

//Add load more items
- (void)loadMoreSearchResult {
    if(searchPage > 0 && searchPreviousPage != searchPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak TeamList *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            searchPreviousPage = searchPage;
            [weakSelf getSearchTeamList];
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
        self.teamTable.hidden=YES;
        searchPage = 1;
        if (task != nil) {
            [task cancel];
        }
        [self getSearchTeamList];
    }
    else{
        [_clearButton setHidden:YES];
        [self.searchTable setHidden:YES];
        self.teamTable.hidden=NO;
    }
    
    if ([_searchField.text length] > 0) {
        [_clearButton setHidden:NO];
    }
}
- (IBAction)clearClick:(id)sender
{
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    [self.searchTable setHidden:YES];
    [self.teamTable setHidden:NO];
}

//Add empty message in table background view
- (void)addEmptyMessageForTeamTable{
    
    if ([teamList count] == 0) {
        [Util addEmptyMessageToTable:self.teamTable withMessage:NO_TEAM_MESSAGE withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:self.teamTable withMessage:@"" withColor:[UIColor whiteColor]];
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


//Get Team list
-(void) getTeamList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [teamTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_LEADER_BOARD withCallBack:^(NSDictionary * response){
        
        [teamTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            if (strMediaUrl == nil) {
                strMediaUrl = [response objectForKey:@"media_base_url"];
            }
            page = [[response valueForKey:@"page"] intValue];
            [teamList addObjectsFromArray:[[response objectForKey:@"team_list"] mutableCopy]];
            [self addEmptyMessageForTeamTable];
            [teamTable reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}


//Get search Team
-(void) getSearchTeamList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchPage] forKey:@"page"];
    [inputParams setValue:_searchField.text forKey:@"team_name"];

    [_searchTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAMS_LIST_SEARCH withCallBack:^(NSDictionary * response){
        
        [_searchTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            
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
                
                [searchResult addObjectsFromArray: [[response objectForKey:@"team_list"] mutableCopy]];
                [self.searchTable reloadData];
                
                searchPage = [[response valueForKey:@"page"] intValue];
                
                //Add no result message
                [self addEmptyMessageForSearchTable];
                
                //Scroll to top
                [Util scrollToTop:_searchTable  fromArrayList:searchResult];

            });
        }
        else{
            [searchResult removeAllObjects];
            [self.searchTable reloadData];
            [self addEmptyMessageForSearchTable];
        }
        
    } isShowLoader:NO];
}



#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.teamTable) {
        return [teamList count];
    }
    else
        return [searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"teamCell";
    cellIdentifier = tableView == _searchTable ? @"searchCell" : @"teamCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *list = tableView == self.searchTable ? [searchResult objectAtIndex:indexPath.row] : [teamList objectAtIndex:indexPath.row];
    //Read elements
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:10];
    UILabel *name = [cell viewWithTag:11];
    UILabel *points = [cell viewWithTag:12];
    UILabel *rank = [cell viewWithTag:13];
    name.numberOfLines = 3;
    
    name.text = [list valueForKey:@"name"];
    points.text = [list valueForKey:@"team_points"];
    rank.text = [NSString stringWithFormat:@"#%@",[list valueForKey:@"rank"]];
    NSDictionary *dict = [list objectForKey:@"profile_image"];
    NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[dict objectForKey:@"profile_image"]];
    [profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    
    //Add zoom
  //  [[Util sharedInstance] addImageZoom:profileImage];
    
    return cell;
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array =  tableView == self.searchTable ? searchResult : teamList;
    if(indexPath.row < [array count])    {
        NSDictionary *team =[array objectAtIndex:indexPath.row];
        if ([[team valueForKey:@"player_relationship_status"] intValue] == 4) {
            NonMemberTeamViewController *nonMember = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
            nonMember.teamId = [team objectForKey:@"id"];
            [self.navigationController pushViewController:nonMember animated:YES];
        }
        else{
            TeamViewController *teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
            teamView.teamId = [team objectForKey:@"id"];
            [self.navigationController pushViewController:teamView animated:YES];
        }
    }
}




@end
