//
//  Team.m
//  Varial
//
//  Created by Shanmuga priya on 3/3/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Team.h"
#import "TeamViewController.h"
#import "GoogleAdMob.h"
#import "XMPPServer.h"
#import "FriendsChat.h"

@interface Team ()

@end

@implementation Team
BOOL teamStatus = FALSE;
int teamMinimumPoint;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    teamList = [[NSMutableArray alloc] init];
    [self designTheView];    
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSDictionary *response = [[NSUserDefaults standardUserDefaults] objectForKey:@"TeamList"];
    if (response != nil) {
        [self showTeamList:response];
    }
    [self getTeamList];
}

- (void)designTheView
{
    [_headerView setHeader: NSLocalizedString(TEAM, nil)];
    [_headerView.logo setHidden:YES];
    
    [Util createRoundedCorener:_createButton withCorner:3];
    
    //Set transparent color to tableview
    [self.teamTable setBackgroundColor:[UIColor clearColor]];
    self.teamTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Long Press to Leave From Team
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(handleLongPress:)];
    longpress.minimumPressDuration = 1.0; //seconds
    longpress.delegate = self;
    [_teamTable addGestureRecognizer:longpress];
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(LEAVE_TEAM, nil)];
    popupView.message.text = NSLocalizedString(SELECT_CAPTAIN_TO_LEAVE, nil);
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
}

- (void)didReceiveMemoryWarning {
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

//Add empty message in table background view
- (void)addEmptyMessage{
    
    if ([teamList count] == 0) {
        [Util addEmptyMessageToTable:_teamTable withMessage:NO_TEAM withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:_teamTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}


- (IBAction)creatTeam:(id)sender {
    CreateTeam *createTeam = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeam"];
    createTeam.minimumPoints = teamMinimumPoint;
    [self.navigationController pushViewController:createTeam animated:YES];
}

- (void)getTeamList{
    
    //Send team list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [Util setInDefaults:response withKey:@"TeamList"];
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
    if(mediaBase == nil)
        mediaBase = [response valueForKey:@"media_base_url"];
    teamStatus = [[response valueForKey:@"team_create_status"] boolValue];
    teamMinimumPoint = [[response valueForKey:@"team_creation_minimum_point"] intValue];
    teamList = [[response objectForKey:@"team_details"] mutableCopy];
    [_teamTable reloadData];
    if (teamStatus) {
        [_createView setHidden:NO];
    }
    else{
        [_createView setHidden:YES];
        [self addEmptyMessage];
    }
    
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [teamList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"teamCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    //Read elements
    UIImageView *teamImage = [cell viewWithTag:10];
    UIImageView *flag = [cell viewWithTag:12];
    UILabel *teamName = [cell viewWithTag:11];
    UILabel *teamCaptain = [cell viewWithTag:13];
    UILabel *rank = [cell viewWithTag:14];

    
    //Bind the contents
    NSDictionary *team = [teamList objectAtIndex:indexPath.row];
    NSDictionary *profileImage = [team objectForKey:@"profile_image"];
    
    NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[profileImage valueForKey:@"profile_image"]];
    [teamImage setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    teamName.text = [team valueForKey:@"team_name"];
    rank.text = [NSString stringWithFormat:@"#%@",[team valueForKey:@"rank"]] ;
    teamCaptain.text = [team valueForKey:@"captain_name"];
    
    NSString *userType = [[team valueForKey:@"team_relation"] intValue] == 3 ? @"member.png" : @"captain.png";
    flag.image = [UIImage imageNamed:userType];
    
    //Add zoom
    //[[Util sharedInstance] addImageZoom:teamImage];
    
    return cell;
    
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([teamList count] > indexPath.row) {
        NSDictionary *team = [teamList objectAtIndex:indexPath.row];
        TeamViewController *teamDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
        teamDetails.teamId = [team valueForKey:@"team_id"];
        teamDetails.roomId = [team valueForKey:@"jabber_id"];
        [self.navigationController pushViewController:teamDetails animated:YES];
    }
   
    
}
// CoCaptain And Member Can Leave From Team
-(void)coCaptainAndMemberLeftTeam
{
    NSString *team_Id = [[teamList objectAtIndex:selecetedIndexPath.row] objectForKey:@"team_id"];
    NSString *roomID = [[teamList objectAtIndex:selecetedIndexPath.row] objectForKey:@"jabber_id"];
    NSString *teamName = [[teamList objectAtIndex:selecetedIndexPath.row] objectForKey:@"team_name"];
    NSString *teamImageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[[[teamList objectAtIndex:selecetedIndexPath.row] objectForKey:@"profile_image"] objectForKey:@"profile_image"]];
    
    // Build Parameter
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:team_Id forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LEAVE_MEMBER_COCAPTAIN withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            FriendsChat *friendsChat = [[FriendsChat alloc] init];
            friendsChat.receiverName = teamName;
            friendsChat.receiverImage = teamImageUrl;
            friendsChat.receiverID = roomID;
            [friendsChat sendMessageIfUserLeft:roomID name1:[Util getFromDefaults:@"user_name"] name2:@" " type:@"5"];
            
          //  [[XMPPServer sharedInstance] sendMessageforLeaveTeam:roomID receiverName:teamName image:teamImageUrl type:@"5"];
            
            [_teamTable beginUpdates];
            [teamList removeObjectAtIndex:selecetedIndexPath.row];
            [_teamTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:selecetedIndexPath] withRowAnimation: UITableViewRowAnimationLeft];
            [_teamTable endUpdates];
            
            // After leave from team should reload the team list api for team chat
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate getTeamList];
            
            Feeds *feed = [[Feeds alloc] init];
            [feed getFeedsTypesList];
            // If no team list availabe should show the Create Team View
            if ([teamList count] == 0 && teamStatus) {
                [_createView setHidden:NO];
            }
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] ];
        }
    } isShowLoader:YES];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:_teamTable];
    
    selecetedIndexPath = [_teamTable indexPathForRowAtPoint:p];
    if (selecetedIndexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on table view at row %ld", (long)selecetedIndexPath.row);
        if ([[[teamList objectAtIndex:selecetedIndexPath.row] objectForKey:@"team_relation"] intValue] == 1) {
            // Levae Captain
             popupView.message.text = NSLocalizedString(SELECT_CAPTAIN_TO_LEAVE, nil);
             selectedPopup = 1;
        }
        else
        {
            // Leave Member or Co-Captain
             popupView.message.text = NSLocalizedString(SURE_TO_LEAVE_TEAM, nil);
             selectedPopup = 2;
        }
        [yesNoPopup show];
        
    } else {
        NSLog(@"gestureRecognizer.state = %ld", (long)gestureRecognizer.state);
    }
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    // Selected popup 1 is an remove captain, so navigate to list page
    // Selected popup 2 is an remove co-captain
    
    if (selectedPopup == 1)
    {
       // Navigate to list page
        NSMutableDictionary *teamDetails = [teamList objectAtIndex:selecetedIndexPath.row];
        NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[[teamDetails objectForKey:@"profile_image"] objectForKey:@"profile_image"]];
        
        NSString *team_Id = [teamDetails objectForKey:@"team_id"];
        NSString *pageType = @"5" ;
        NSString *roomId = [teamDetails objectForKey:@"jabber_id"];
        NSString *teamName = [teamDetails objectForKey:@"team_name"];
        NSString *teamImage = profileUrl;
        [self nextViewController:pageType teamId:team_Id roomId:roomId teamName:teamName teamImage:teamImage];
        
    }
    else if(selectedPopup == 2){
        [self coCaptainAndMemberLeftTeam];
    }
    [yesNoPopup dismiss:YES];
    
    if([[Util getFromDefaults:@"playerType"] intValue] != 1)
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)onNoClick{
    [yesNoPopup dismiss:YES];
}

// Select Captain
-(void)nextViewController:(NSString *)pageType teamId:(NSString *)teamid roomId:(NSString *)roomId teamName:(NSString *)teamName teamImage:(NSString *)teamImage
{
    TeamInvitiesViewController *teaminvities = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamInvitiesViewController"];
    teaminvities.teamId = teamid;
    teaminvities.type = pageType;
    teaminvities.teamName = teamName;
    teaminvities.teamImage = teamImage;
    teaminvities.roomId = roomId;
    teaminvities.selectCaptainFromListPage = @"yes";
    [self.navigationController pushViewController:teaminvities animated:YES];
}

@end
