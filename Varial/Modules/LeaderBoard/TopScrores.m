//
//  TopScrores.m
//  Varial
//
//  Created by jagan on 11/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "TopScrores.h"
#import "SVPullToRefresh.h"
#import "FriendProfile.h"
#import "GoogleAdMob.h"
#import "PlayersList.h"

@interface TopScrores ()

@end

@implementation TopScrores

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    leaders = [[NSMutableArray alloc] init];
    page = previousPage = 1;
    [self setInfiniteScrollForTableView];
    [self getScorers];
    [self designTheView];
    
    //Show Ad
    //[[GoogleAdMob sharedInstance] addAdInViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{

}

- (void)designTheView{
    [_headerView setHeader:NSLocalizedString(TOP_SCORER, nil)];
    _leaderBoardTable.backgroundColor=[UIColor clearColor];
    _leaderBoardTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _searchButton.layer.cornerRadius = _searchButton.frame.size.width / 2;
    _searchButton.layer.masksToBounds = YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)searchPlayer:(id)sender
{
    PlayersList *playerList = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayersList"];
    playerList.listType = @"2"; // listType 2 is an top score search
    [self.navigationController pushViewController:playerList animated:YES];
}


//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak TopScrores *weakSelf = self;
    // setup infinite scrolling
    [self.leaderBoardTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [self.leaderBoardTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak TopScrores *weakSelf = self;
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
-(void) getScorers
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [_leaderBoardTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TOP_SCORERS withCallBack:^(NSDictionary * response){
        [_leaderBoardTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            [leaders addObjectsFromArray: [[response objectForKey:@"leader_board"] mutableCopy]];
            [self.leaderBoardTable reloadData];
            page = [[response valueForKey:@"page"] intValue];
        }
        
    } isShowLoader:NO];
    
}


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [leaders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    return cell;
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *leader = [leaders objectAtIndex:indexPath.row];    
    
    if ([[leader valueForKey:@"my_self"] boolValue]) {
        MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
        [self.navigationController pushViewController:myProfile animated:YES];
    }
    else{
        FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        friendProfile.friendId = [leader valueForKey:@"player_id"];
        friendProfile.friendName = [leader valueForKey:@"player_name"];
        [self.navigationController pushViewController:friendProfile animated:YES];
    }
}

@end
