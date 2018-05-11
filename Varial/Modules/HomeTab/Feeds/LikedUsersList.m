//
//  LikedUsersList.m
//  Varial
//
//  Created by vis-1674 on 26/08/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "LikedUsersList.h"
#import "FriendCell.h"
#import "Util.h"
#import "FriendProfile.h"
#import "MyProfile.h"
#import "UserMessages.h"

@interface LikedUsersList ()

@end

@implementation LikedUsersList

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    likedUsersList = [[NSMutableArray alloc] init];
    [self setPushToRefreshForTableView];
    [self designTheView];
    
    _headerView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)backPressed {
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)designTheView {
    page = 1;
    
    
    if(_isShareList){
        [_headerView setHeader:NSLocalizedString(@"Social Media Share", nil)];
    }
    
    else {
        [_headerView setHeader:NSLocalizedString(@"", nil)];
    }
    
    [_headerView.logo setHidden:YES];
    
    _staredListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_staredListTable setBackgroundColor:[UIColor clearColor]];
    
    [self.staredListTable registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"FriendCell"];
    
    [self getStaredUsers];
}


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [likedUsersList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FriendCell";
    FriendCell *friendCell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (friendCell == nil)
    {
        friendCell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [friendCell setBackgroundColor:[UIColor clearColor]];
    friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([likedUsersList count] > indexPath.row) {
        
        NSMutableDictionary *userDetail = [likedUsersList objectAtIndex:indexPath.row];
        
        friendCell.name.text = [userDetail objectForKey:@"name"];
        friendCell.points.text = [NSString stringWithFormat:@"%@: %@",POINTS,[userDetail objectForKey:@"point"]];
        friendCell.rankLabel.text = [Util playerType:[[userDetail objectForKey:@"player_type_id"] intValue] playerRank:[userDetail objectForKey:@"rank"]];
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBaseUrl, [userDetail objectForKey:@"profile_image"]];
        NSString *boardImageUrl = [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[userDetail objectForKey:@"player_skate_pic"]];
        [friendCell.profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        friendCell.statusView.hidden = YES;
        [friendCell.board setImageWithURL:[NSURL URLWithString:boardImageUrl]];
    }
    
    return friendCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([likedUsersList count] > indexPath.row) {
        
        NSMutableDictionary *userDetail = [likedUsersList objectAtIndex:indexPath.row];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        // Show My Profile
        if ([[userDetail objectForKey:@"my_self"] intValue] == 1) {
            MyProfile *myProfile = [mainStoryboard instantiateViewControllerWithIdentifier:@"MyProfile"];
            [self.navigationController pushViewController:myProfile animated:YES];
        }
        else // Show Friend Profile
        {
            FriendProfile *profile = [mainStoryboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            profile.friendName = [userDetail objectForKey:@"name"];
            profile.friendId = [userDetail objectForKey:@"player_id"];
            [self.navigationController pushViewController:profile animated:YES];
        }
    }
}

// Get stared users list
-(void) getStaredUsers
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_postId  forKey:@"post_id"];
    [inputParams setValue:[NSNumber numberWithInt:page]  forKey:@"page"];
    
    [inputParams setValue:_isShareList ? @"1" : @"0"  forKey:@"is_share"];

    NSString *url = LIST_POST_STAR_MEMBERS;
    
    if (_isMediaPost) {
        [inputParams setValue:_mediaId  forKey:@"media_id"];
        url = LIST_POST_MEDIA_STAR_MEMBERS;
    }
    
    [_staredListTable.infiniteScrollingView startAnimating];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
        
        [_staredListTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue])
        {
            page = [[response objectForKey:@"page"] intValue];
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
            [likedUsersList addObjectsFromArray:[[response objectForKey:@"stared_player_details"] mutableCopy]];
            [_staredListTable reloadData];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"] withDuration:2];
        }
    } isShowLoader:NO];
    
}


//Add infinity scroll
- (void) setPushToRefreshForTableView;
{
    __weak LikedUsersList *weakSelf = self;

        // setup infinite scrolling
        [self.staredListTable addInfiniteScrollingWithActionHandler:^{
            [self getPreviousLikedUsers];
        }];
        
        [weakSelf.staredListTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
}

// Pull to get next 10 liked users
-(void)getPreviousLikedUsers
{
    if (page != -1) {
        [self getStaredUsers];
    }
    else{
        [_staredListTable.infiniteScrollingView stopAnimating];
    }
}


@end
