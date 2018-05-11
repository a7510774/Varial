//
//  BlockedUsers.m
//  Varial
//
//  Created by vis-1674 on 2016-02-06.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BlockedUsers.h"
#import "UIImageView+AFNetworking.h"
#import "XMPPServer.h"

@interface BlockedUsers ()

@end

@implementation BlockedUsers

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    blockedUsersList = [[NSMutableArray alloc]init];
    page = previousPage = 1;
    [self designTheView];
    [self setInfiniteScrollForTableView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)designTheView
{
    [self getBlockedUsersList];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_headerView setHeader:NSLocalizedString(BLOCKED_USERS, nil)];
    [_headerView.logo setHidden:YES];
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak BlockedUsers *weakSelf = self;
    // setup infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.tableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak BlockedUsers *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getBlockedUsersList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.tableView.infiniteScrollingView stopAnimating];
    }
}


#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [blockedUsersList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"blockedusercell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    //Read elements
    UIImageView *imgProfile = (UIImageView *) [cell viewWithTag:10];
    UILabel *lblname = (UILabel *)[cell viewWithTag:11];
    UILabel *lblpoints = (UILabel *)[cell viewWithTag:12];
    UILabel *lblrank = (UILabel *)[cell viewWithTag:13];
    UIButton *btnUnblock = (UIButton *)[cell viewWithTag:14];
    UIView *statusView = (UIView *)[cell viewWithTag:21];
    
    //Add rounded corner
    [Util createRoundedCorener:statusView withCorner:3];
    
    //Add zoom
    //[[Util sharedInstance] addImageZoom:imgProfile];
    
    if ([blockedUsersList count] > indexPath.row) {
        
        //Bind the contents
        NSDictionary *list = [blockedUsersList objectAtIndex:indexPath.row];
        lblname.text = [list objectForKey:@"name"];
        lblpoints.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[list objectForKey:@"point"]];
        lblrank.text = [Util playerType:[[list objectForKey:@"player_type_id"] intValue] playerRank:[list objectForKey:@"rank"]];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[[blockedUsersList objectAtIndex:indexPath.row]  objectForKey:@"profile_image"]];
        [imgProfile setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
        
        [btnUnblock addTarget:self action:@selector(unBlockUsers:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)unBlockUsers :(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
 
    if ([blockedUsersList count] > indexPath.row) {
        
        NSMutableDictionary *user = [[blockedUsersList objectAtIndex:indexPath.row] mutableCopy];
        NSString *friend_id = [NSString stringWithFormat:@"%@",[user objectForKey:@"friend_id"]];
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:friend_id forKey:@"friend_id"];
        [inputParams setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:UNBLOCKED_PLAYERS withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [_tableView beginUpdates];
                [blockedUsersList removeObjectAtIndex:indexPath.row];
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationLeft];
                [_tableView endUpdates];
                [self addEmptyMessageForBlockedListTable];
                
                //Unblock the user from chat server
                XMPPBlocking *block = [XMPPServer sharedInstance].xmppBlocking;
                [block unblockJID:[XMPPJID jidWithString:[user valueForKey:@"jabber_id"]]];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableArray *blockedUsers = [[defaults objectForKey:@"blockedUsers"] mutableCopy];
                [blockedUsers removeObject:[user valueForKey:@"jabber_id"]];
                [defaults setObject:blockedUsers forKey:@"blockedUsers"];
                 NSMutableArray *playersiBlocked = [[defaults objectForKey:@"players_i_blocked"] mutableCopy];
                [playersiBlocked removeObject:[user valueForKey:@"jabber_id"]];
                [defaults setObject:blockedUsers forKey:@"players_i_blocked"];
            }
            else
            {
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        } isShowLoader:YES];
    }

}

-(void) getBlockedUsersList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:VIEW_BLOCKED_PLAYERS withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            page = [[response valueForKey:@"page"]intValue];
            strMediaUrl = [response objectForKey:@"media_base_url"];
            [blockedUsersList addObjectsFromArray:[[response objectForKey:@"friend_list"] mutableCopy]];
            [_tableView reloadData];
            
            [self addEmptyMessageForBlockedListTable];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
        
    } isShowLoader:YES];
}

- (void)addEmptyMessageForBlockedListTable{
    
    if ([blockedUsersList count] == 0) {
        [Util addEmptyMessageToTable:self.tableView withMessage:NO_BLOCKED_USERS withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
    else{
        [Util addEmptyMessageToTable:self.tableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
    
}
@end
