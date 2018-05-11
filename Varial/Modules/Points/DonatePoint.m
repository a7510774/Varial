//
//  DonatePoint.m
//  Varial
//
//  Created by jagan on 14/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "DonatePoint.h"
#import "SVPullToRefresh.h"
#import "Util.h"
#import "NonMemberTeamViewController.h"
#import "TeamViewController.h"

@interface DonatePoint ()

@property(nonatomic)BOOL iSLoadDonateMembers, iSLoadMembersFirstTimeOnScreen;

@end

@implementation DonatePoint

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self designTheView];
    [self setTint];
    
    //Set point icon
    [Util setPointsIconText:_btnPoints withSize:18];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    _iSLoadMembersFirstTimeOnScreen = YES;
    
    teams = [[NSMutableArray alloc] init];
    searchTeams = [[NSMutableArray alloc] init];
    members = [[NSMutableArray alloc] init];
    searchMembers = [[NSMutableArray alloc] init];
    teamSearchText = memberSearchText = @"";
    teamPage = teamPrevious = memberPage = memberPrevious = 1;
    teamSearch = teamSearchPrevious = memberSearch = memberSearchPrevious = 1;
    
    [_clearIcon setHidden:YES];
    _searchField.text = @"";
    
    if (_donationFrom == 1) {
        [self getPlayerDetails];
    }
    else{
        [self getTeamDetails];
    }
    [self setInfiniteScrollForTableView];
}

- (void)designTheView{
    
    [_headerView setHeader:NSLocalizedString(DONATE_POINTS, nil)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"CenturyGothic" size:15], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [_segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [_segment setTitleTextAttributes:attributes forState:UIControlStateSelected];
    _segment.layer.borderColor = UIColorFromHexCode(THEME_COLOR).CGColor;
    _segment.layer.borderWidth = 1;
    
    _donateTable.backgroundColor=[UIColor clearColor];
    _donateTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_donateTable setHidden:YES];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_searchField addTarget:self  action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    [Util setPadding:_searchField];
    
    // //Add zoom
    // [[Util sharedInstance] addImageZoom:_donaterImage];
}

//Change the segment on click
-(void)setTint{
    
    for (int i=0; i<[_segment.subviews count]; i++)
    {
        
        if ([_segment selectedSegmentIndex] == i )
        {
            if (![teamSearchText isEqualToString:@""]) {
                [_searchField setText:teamSearchText];
                [_clearIcon setHidden:NO];
            }
            else{
                _searchField.text = @"";
                [_clearIcon setHidden:YES];
            }
        }
        else
        {
            if (![memberSearchText isEqualToString:@""]) {
                [_searchField setText:memberSearchText];
                [_clearIcon setHidden:NO];
            }
            else{
                _searchField.text = @"";
                [_clearIcon setHidden:YES];
            }
        }
    }
    
    for (int i=0; i<[_segment.subviews count]; i++)    {
        
        if ([[_segment.subviews objectAtIndex:i] isSelected] )
        {
            UIColor *themeColor = UIColorFromHexCode(THEME_COLOR);
            [[_segment.subviews objectAtIndex:i] setTintColor:themeColor];
        }
        else
        {
            UIColor *bckcolor=[UIColor blackColor];
            [[_segment.subviews objectAtIndex:i] setTintColor:bckcolor];
        }
    }
    
    //change the place holder of search text
    if(_segment.selectedSegmentIndex == 1){
        [_searchField setValue:NSLocalizedString(SEARCH_BY_TEAM_NAME, nil) forKeyPath:@"_placeholderLabel.text"];
    }else{
        [_searchField setValue:NSLocalizedString(SEARCH_NAME_EMAIL, nil) forKeyPath:@"_placeholderLabel.text"];
    }
    
    //[_searchField setText:@""];
    
    _donateTable.tableFooterView.hidden = YES;
    [_donateTable reloadData];
    //[self addEmptyMessageForDonateTable];
}

//Search box text change listener
- (void) textChangeListener :(UITextField *) searchBox
{
    
    if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        if (task != nil) {
            [task cancel];
        }
        if(_segment.selectedSegmentIndex == 1){
            teamSearch = teamSearchPrevious = 1;
            teamSearchText = _searchField.text;
            [self getSearchTeamList];
        }
        else{
            memberSearch = memberSearchPrevious = 1;
            memberSearchText = _searchField.text;
            [self getSearchMembersList];
        }
    }
    else{
        [_clearIcon setHidden:YES];
    }
    
    if ([_searchField.text length] > 0) {
        [_clearIcon setHidden:NO];
    }
}


//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak DonatePoint *weakSelf = self;
    // setup infinite scrolling
    [self.donateTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [self.donateTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    
    NSLog(@"LOADING MORE CONTENTS...!");
    __weak DonatePoint *weakSelf = self;
    int64_t delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    [self.donateTable.infiniteScrollingView stopAnimating];
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (_segment.selectedSegmentIndex == 0) {
            if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
            {
                if (memberSearch > 0 && memberSearch != memberSearchPrevious) {
                    memberPrevious = memberPage;
                    [self getSearchMembersList];
                }
            }
            else{
                if (memberPage > 0 && memberPage != memberPrevious) {
                    memberPrevious = memberPage;
                    [self getMembersList];
                }
            }
            
        }
        else{
            if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
            {
                if (teamSearch > 0 && teamSearch != teamSearchPrevious) {
                    teamSearchPrevious = teamSearch;
                    [self getSearchTeamList];
                }
            }
            else{
                if (teamPage > 0 && teamPage != teamPrevious) {
                    teamPrevious = teamPage;
                    [self getTeamsList];
                }
            }
        }
    });
}



//Add empty message in table background view
- (void)addEmptyMessageForDonateTable{
    
    if(_segment.selectedSegmentIndex == 0) {
        if ([_searchField.text length] > 0) {
            if ([searchMembers count] == 0) {
                [Util addEmptyMessageToTableWithHeader:_donateTable withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
            }
            else{
                [Util addEmptyMessageToTableWithHeader:_donateTable withMessage:@"" withColor:[UIColor whiteColor]];
                _donateTable.tableFooterView.hidden = YES;
            }
        }
        else{
            
            if (_iSLoadDonateMembers) {
                _iSLoadDonateMembers = NO;
                if ([members count] == 0){
                    
                    [Util addEmptyMessageToTableWithHeader:_donateTable withMessage:NO_MEMBERS withColor:[UIColor whiteColor]];
                }
                else{
                    _donateTable.tableFooterView.hidden = YES;
                }
            }
        }
    }else{
        if ([_searchField.text length] > 0) {
            if ([searchTeams count] == 0) {
                [Util addEmptyMessageToTableWithHeader:_donateTable withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
            }
            else{
                [Util addEmptyMessageToTableWithHeader:_donateTable withMessage:@"" withColor:[UIColor whiteColor]];
                _donateTable.tableFooterView.hidden = YES;
            }
        }
        else{
            if ([teams count] == 0){
                [Util addEmptyMessageToTableWithHeader:_donateTable withMessage:NO_TEAMS withColor:[UIColor whiteColor]];
            }
            else{
                _donateTable.tableFooterView.hidden = YES;
            }
        }
    }
}

- (IBAction)clearSearch:(id)sender {
    [_clearIcon setHidden:YES];
    if ([_segment selectedSegmentIndex] == 0) {
        memberSearchText = @"";
    }
    else{
        teamSearchText = @"";
    }
    _searchField.text = @"";
    [_donateTable reloadData];
}

- (IBAction)optionChanged:(id)sender {
    [self setTint];
}

//Get player details
- (void)getPlayerDetails{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_PLAYER_INFORMATION withCallBack:^(NSDictionary * response)
     {
         
         if([[response valueForKey:@"status"] boolValue]){
             
             mediaBase = [response objectForKey:@"media_base_url"];
             NSDictionary *details=[[NSDictionary alloc]init];
             
             details = [response objectForKey:@"player_details"];
             
             _donaterName.text= [details objectForKey:@"name"];
             _donaterPoints.text = [NSString stringWithFormat:@"%@",[details objectForKey:@"leader_board_points"]];
             _donaterRank.text =  [Util playerType:[[details objectForKey:@"player_type_id"] intValue] playerRank:[details objectForKey:@"rank"]];
             
             NSDictionary *proImage=[details objectForKey:@"player_image_detail"];
             NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[proImage  objectForKey:@"profile_image"]];
             
             [_donaterImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
             
             [_donateTable setHidden:NO];
             
             [self getMembersList];
             [self getTeamsList];
         }
         
     } isShowLoader:NO];
    
}

//Get player details
- (void)getTeamDetails{
    
    // Build Parameter
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_donatorId forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_DETAILS withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]) {
            
            mediaBase = [response objectForKey:@"media_base_url"];
            NSDictionary *teamDetails = [[response objectForKey:@"team_details"] mutableCopy];
            
            _donaterName.text = [teamDetails objectForKey:@"team_name"];
            _donaterPoints.text = [teamDetails objectForKey:@"points"];
            _donaterRank.text = [NSString stringWithFormat: NSLocalizedString(@"Rank: %@", nil),[teamDetails objectForKey:@"rank"]];
            
            NSString *urlTeamImage = [NSString stringWithFormat:@"%@%@",mediaBase,[[teamDetails objectForKey:@"team_profile_image"] objectForKey:@"profile_image"]];
            
            [_donaterImage setImageWithURL:[NSURL URLWithString:urlTeamImage] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            [_donateTable setHidden:NO];
            [self getMembersList];
            [self getTeamsList];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:YES];
}

//Get members list
- (void)getMembersList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:memberPage] forKey:@"page"];
    if (_donationFrom == 1) {
        [inputParams setValue:@"0" forKey:@"is_team_donate"];
        [inputParams setValue:@"" forKey:@"team_id"];
    }
    else{
        [inputParams setValue:@"1" forKey:@"is_team_donate"];
        [inputParams setValue:_donatorId forKey:@"team_id"];
    }
    [self.donateTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DONATE_MEMBER_LIST withCallBack:^(NSDictionary * response){
        
        _iSLoadDonateMembers = YES;
        _iSLoadMembersFirstTimeOnScreen = NO;
        
        [self.donateTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            
            [members addObjectsFromArray:[[response objectForKey:@"player_infomation"] mutableCopy]];
            [_donateTable reloadData];
            [self addEmptyMessageForDonateTable];
            
            memberPage = [[response objectForKey:@"page"] intValue];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:_iSLoadMembersFirstTimeOnScreen?YES:NO];
}


//Get search members list
- (void)getSearchMembersList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    [inputParams setValue:[NSNumber numberWithInt:memberSearch] forKey:@"page"];
    if (_donationFrom == 1) {
        [inputParams setValue:@"0" forKey:@"is_team_donate"];
        [inputParams setValue:@"" forKey:@"team_id"];
    }
    else{
        [inputParams setValue:@"1" forKey:@"is_team_donate"];
        [inputParams setValue:_donatorId forKey:@"team_id"];
    }
    
    [self.donateTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DONATE_MEMBER_SEARCH withCallBack:^(NSDictionary * response){
        
        [self.donateTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_url"];
            }
            
            //Check to add or append the search result
            if (memberSearch == 1) {
                [searchMembers removeAllObjects];
            }
            
            [searchMembers addObjectsFromArray:[[response objectForKey:@"search_via_varial"] mutableCopy]];
            [_donateTable reloadData];
            [self addEmptyMessageForDonateTable];
            
            memberSearch = [[response objectForKey:@"page"] intValue];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            [_donateTable reloadData];
        }
        
    } isShowLoader:NO];
}

//Get members list
- (void)getTeamsList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:teamPage] forKey:@"page"];
    if (_donationFrom == 1) {
        [inputParams setValue:@"0" forKey:@"is_team_donate"];
        [inputParams setValue:@"" forKey:@"team_id"];
    }
    else{
        [inputParams setValue:@"1" forKey:@"is_team_donate"];
        [inputParams setValue:_donatorId forKey:@"team_id"];
    }
    [self.donateTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DONATE_TEAM_LIST withCallBack:^(NSDictionary * response){
        
        [self.donateTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            
            [teams addObjectsFromArray:[[response objectForKey:@"team_list"] mutableCopy]];
            [_donateTable reloadData];
            [self addEmptyMessageForDonateTable];
            
            teamPage = [[response objectForKey:@"page"] intValue];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}


//Get search members list
- (void)getSearchTeamList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_searchField.text forKey:@"team_name"];
    [inputParams setValue:[NSNumber numberWithInt:teamSearch] forKey:@"page"];
    if (_donationFrom == 1) {
        [inputParams setValue:@"0" forKey:@"is_team_donate"];
        [inputParams setValue:@"" forKey:@"team_id"];
    }
    else{
        [inputParams setValue:@"1" forKey:@"is_team_donate"];
        [inputParams setValue:_donatorId forKey:@"team_id"];
    }
    [self.donateTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DONATE_TEAM_SEARCH withCallBack:^(NSDictionary * response){
        
        [self.donateTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            
            //Check to add or append the search result
            if (teamSearch == 1) {
                [searchTeams removeAllObjects];
            }
            
            [searchTeams addObjectsFromArray:[[response objectForKey:@"team_search"] mutableCopy]];
            [_donateTable reloadData];
            [self addEmptyMessageForDonateTable];
            
            teamSearch = [[response objectForKey:@"page"] intValue];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - UITableViewDelegate method
//set number of rows in tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_segment.selectedSegmentIndex == 0) {
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            return [searchMembers count];
        }
        else{
            return [members count];
        }
    }
    else{
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            return [searchTeams count];
        }
        else{
            return [teams count];
        }
    }
}

//set tableview content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (_segment.selectedSegmentIndex == 1) {
        
        static NSString *cellIdentifier = nil;
        cellIdentifier= @"teamCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        //Read elements
        UIImageView *teamImage = (UIImageView *)[cell viewWithTag:10];
        UILabel *teamName =  (UILabel *)[cell viewWithTag:11];
        UILabel *teamCaptain = (UILabel *) [cell viewWithTag:12];
        UILabel *points = (UILabel *) [cell viewWithTag:13];
        
        
        NSDictionary *team;
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            team = [searchTeams count] > indexPath.row ? [searchTeams objectAtIndex:indexPath.row] : nil;
        }
        else{
            team = [teams count] > indexPath.row ? [teams objectAtIndex:indexPath.row] : nil;
        }
        
        if (team != nil) {
            NSDictionary *teamImageObj = [team objectForKey:@"image_path"];
            NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[teamImageObj valueForKey:@"profile_image"]];
            [teamImage setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            teamName.text = [team valueForKey:@"name"];
            teamCaptain.text = [team valueForKey:@"captain_name"];
            points.text = [team valueForKey:@"team_points"];
            
//            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
//            [teamImage setUserInteractionEnabled:YES];
//            [teamImage addGestureRecognizer:tapProfileImage];
            
        }
        
    }else{
        static NSString *cellIdentifier = @"membersCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        //Read elements
        UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
        UILabel *name =  (UILabel *)[cell viewWithTag:11];
        UILabel *points = (UILabel *) [cell viewWithTag:12];
        UILabel *rank = (UILabel *) [cell viewWithTag:13];
        UIImageView *skateBaord =(UIImageView *)[cell viewWithTag:15];
      //  UIButton *status = (UIButton *)[cell viewWithTag:16];
      //  UIView *statusView = (UIView *)[cell viewWithTag:17];
        
        NSDictionary *member;
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            member = [searchMembers count] > indexPath.row ? [searchMembers objectAtIndex:indexPath.row] : nil;
        }
        else{
            member = [members count] > indexPath.row ? [members objectAtIndex:indexPath.row] : nil;
        }
        
        if (member != nil) {
            NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[member  valueForKey:@"profile_image"]];
            [profile setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            name.text = [member valueForKey:@"player_name"];
            rank.text =  [Util playerType:[[member objectForKey:@"player_type_id"] intValue] playerRank:[member objectForKey:@"rank"]];
            points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[member valueForKey:@"point"]];
            
            NSString *skateUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[member  valueForKey:@"player_skate_pic"]];
            [skateBaord setImageWithURL:[NSURL URLWithString:skateUrl] placeholderImage:nil];
            
//            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
//            [profile setUserInteractionEnabled:YES];
//            [profile addGestureRecognizer:tapProfileImage];
        }
    }
    
    return cell;
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *donateTo;
    NSUInteger type;
    if (_segment.selectedSegmentIndex == 0) {
        
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            if ([searchMembers count] > indexPath.row) {
                donateTo = [searchMembers objectAtIndex:indexPath.row];
            }
        }
        else{
            if ([members count] > indexPath.row) {
                donateTo = [members objectAtIndex:indexPath.row];
            }
        }
        type = 2;
        
    }
    else{
        
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            if ([searchTeams count] > indexPath.row) {
                donateTo = [searchTeams objectAtIndex:indexPath.row];
            }
        }
        else{
            if ([teams count] > indexPath.row) {
                donateTo = [teams objectAtIndex:indexPath.row];
            }
        }
        type = 1;
    }
    
    if (donateTo != nil) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

        DonateForm *donateForm = [mainStoryboard instantiateViewControllerWithIdentifier:@"DonateForm"];
        donateForm.donateTo = donateTo;
        donateForm.donationType = type;
        donateForm.mediaBase = mediaBase;
        donateForm.donatedFrom = _donationFrom;
        donateForm.donatorId = _donatorId;
        [_searchField resignFirstResponder];
        [self.navigationController pushViewController:donateForm animated:YES];
    }
}

//Show friend profile
-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.donateTable];
    NSIndexPath *indexPath = [self.donateTable indexPathForRowAtPoint:buttonPosition];
    
    NSMutableDictionary *conversation;
    
    if (_segment.selectedSegmentIndex == 1) {
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            conversation = [searchTeams objectAtIndex:indexPath.row];
        }
        else
        {
            conversation = [teams objectAtIndex:indexPath.row];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *teamList = [[defaults objectForKey:@"team_details"] mutableCopy];
        
        int index = [Util getMatchedObjectPosition:@"team_id" valueToMatch:[conversation valueForKey:@"id"] from:teamList type:0];
        if (index != -1) {
            TeamViewController *teamDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
            teamDetails.teamId = [conversation valueForKey:@"id"];
            [self.navigationController pushViewController:teamDetails animated:YES];
        }
        else
        {
            NonMemberTeamViewController *nonMember = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
            nonMember.teamId = [conversation valueForKey:@"id"];
            [self.navigationController pushViewController:nonMember animated:YES];
        }
        
    }
    else
    {
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            conversation = [searchMembers objectAtIndex:indexPath.row] ;
        }
        else{
            conversation = [members objectAtIndex:indexPath.row] ;
        }
        
        FriendProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        profile.friendName = [conversation valueForKey:@"player_name"];
        profile.friendId = [conversation valueForKey:@"player_id"];
        [self.navigationController pushViewController:profile animated:YES];
    }
    
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
        
    }
}


@end
