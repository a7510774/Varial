//
//  NonMemberTeamViewController.m
//  Varial
//
//  Created by Shanmuga priya on 2/25/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "NonMemberTeamViewController.h"
#import "SVPullToRefresh.h"
#import "FeedsDesign.h"
#import "FeedCell.h"
#import "FriendCell.h"

@interface NonMemberTeamViewController ()
{
    FeedsDesign *feedsDesign;
}

@end

@implementation NonMemberTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    members = [[NSMutableArray alloc] init];
    teamDetailsToDonate = [[NSMutableDictionary alloc] init];
    feeds = [[NSMutableArray alloc] init];
    
    [self.nonMemberTable registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    [self.nonMemberTable registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
    [self.nonMemberTable registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"FriendCell"];
    [self.nonMemberTable registerNib:[UINib nibWithNibName:@"TeamFeedCell" bundle:nil] forCellReuseIdentifier:@"TeamFeedCell"];
    [self.nonMemberTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    [self designTheView];
    [self createPopUpWindows];
    [self getTeamDetails];
    [self getFeedsList];
    [self setInfiniteScrollForTableView];
    
    //Set point icon
    [Util setPointsIconText:_btnPoints withSize:16];
}

- (void)viewWillAppear:(BOOL)animated{
    [self reloadMembers];
    [Util setStatusBar];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    appDelegate.shouldAllowRotation = NO;
}
-(void)viewDidAppear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [feedsDesign playVideoConditionally];
    });
}
-(void)viewWillDisappear:(BOOL)animated{
    [feedsDesign stopAllVideos];
}
- (void)reloadMembers{
    page = previousPage = 1;
    [members removeAllObjects];
    [self getMembersList];
    [_nonMemberTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tappedSegment:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
        [feedsDesign playVideoConditionally];
        _btnSearch.hidden = YES;
    }
    else
    {
        [feedsDesign stopAllVideos];
        if ([members count] > 0) {
            _btnSearch.hidden = NO;
        }
        else{
            _btnSearch.hidden = YES;
        }
    }
    [self addEmptyMessageForTeamTable];
    [_nonMemberTable reloadData];
    
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak NonMemberTeamViewController *weakSelf = self;
    // setup infinite scrolling
    [self.nonMemberTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.nonMemberTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    
    if ((_segment.selectedSegmentIndex == 1 && page > 0 && page != previousPage) || _segment.selectedSegmentIndex == 0 ) {
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak NonMemberTeamViewController *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_segment.selectedSegmentIndex == 0) {
                // Feed list
                [weakSelf getFeedsList];
            }
            else{
                previousPage = page;
                [weakSelf getMembersList];
            }
            [_nonMemberTable.infiniteScrollingView stopAnimating];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [_nonMemberTable.infiniteScrollingView stopAnimating];
    }
}


//Add empty message in table background view
- (void)addEmptyMessageForTeamTable{
    if(_segment.selectedSegmentIndex == 1) {
        if ([members count] == 0) {
            [Util addEmptyMessageToTableWithHeader:self.nonMemberTable withMessage:NO_MEMBERS withColor:[UIColor whiteColor]];
        }
        else{
            [Util addEmptyMessageToTableWithHeader:self.nonMemberTable withMessage:@"" withColor:[UIColor whiteColor]];
        }
        
    }else{
        if ([feeds count] == 0) {
            [Util addEmptyMessageToTableWithHeader:_nonMemberTable withMessage:NO_FEEDS withColor:[UIColor whiteColor]];
        }
        else{
            _nonMemberTable.tableFooterView.hidden = YES;
        }
    }
}

- (void)designTheView{
    
    feedsDesign = [[FeedsDesign alloc] init];
    
    [_headerView setHeader:NSLocalizedString(TEAM_VIEW, nil)];

    [_headerView.logo setHidden:YES];
    
    _nonMemberTable.hidden = YES;
    _nonMemberTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"CenturyGothic" size:16], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [_segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [_segment setTitleTextAttributes:attributes forState:UIControlStateSelected];
    
    _btnSearch.layer.cornerRadius = _btnSearch.frame.size.height / 2;
    _btnSearch.layer.masksToBounds = YES;
    _btnSearch.hidden = YES;
    
    _nonMemberTable.backgroundColor=[UIColor clearColor];
    
    // Tab Captain Image
    UITapGestureRecognizer *tapCaptainImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCaptainProfile)];
    [_captainImage setUserInteractionEnabled:YES];
    [_captainImage addGestureRecognizer:tapCaptainImage];
    
    // Tab coCaptain Image
    UITapGestureRecognizer *tapCoCaptainImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCoCaptainProfile)];
    [_coCaptainImage setUserInteractionEnabled:YES];
    [_coCaptainImage addGestureRecognizer:tapCoCaptainImage];
    
    // Tab team Image
    UITapGestureRecognizer *tapTeamImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapZoomImage:)];
    [_teamImage setUserInteractionEnabled:YES];
    [_teamImage addGestureRecognizer:tapTeamImage];
    
    [Util makeAsLink:_coCapTainName withColor:[UIColor whiteColor] showUnderLine:NO range:NSMakeRange(0, [_coCapTainName.text length])];
    _captainName.delegate = self;
    _coCapTainName.delegate = self;
    
}

- (void) createPopUpWindows{
    
    pointsPopupView = [[PointsPopup alloc] initWithViewsshowBuyPoints:FALSE showDonatePoints:TRUE showRedeemPoints:[Util getBoolFromDefaults:@"can_show_shoping"] showPointsActivityLog:FALSE];
    [pointsPopupView setDelegate:self];
    
    pointPopup = [KLCPopup popupWithContentView:pointsPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(CONFIRMATION, nil)];
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    teamPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    //Alert popup
    blockConfirmation = [[YesNoPopup alloc] init];
    blockConfirmation.delegate = self;
    [blockConfirmation setPopupHeader:NSLocalizedString(BLOCK_PERSON, nil)];
    blockConfirmation.message.text = NSLocalizedString(SURE_TO_BLOCK, nil);
    [blockConfirmation.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [blockConfirmation.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    blockPopUp = [KLCPopup popupWithContentView:blockConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    //Alert popup
    deleteConfirmation = [[YesNoPopup alloc] init];
    deleteConfirmation.delegate = self;
    [deleteConfirmation setPopupHeader:NSLocalizedString(FEED, nil)];
    deleteConfirmation.message.text = NSLocalizedString(DELETE_FOR_SURE, nil);
    [deleteConfirmation.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [deleteConfirmation.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    deletePopup = [KLCPopup popupWithContentView:deleteConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    if(selectedPopup == 1){
        [self acceptTeamInvite];
    }
    else if(selectedPopup == 2){
        [self deleteFeedPost];
    }
    else if(selectedPopup == 3){
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[reportFeed objectForKey:@"post_owner_id"] forKey:@"friend_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BLOCKFRIEND withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [blockPopUp dismiss:YES];
                [self getFeedsList];
                [_nonMemberTable reloadData];
                [[AlertMessage sharedInstance]showMessage:[response valueForKey:@"message"] withDuration:3];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
            }
        } isShowLoader:YES];
    }
}

- (void)onNoClick{
    [teamPopup dismiss:YES];
    [blockPopUp dismiss:YES];
    [deletePopup dismiss:YES];
}

- (IBAction)showPoints:(id)sender {
    [pointPopup show];
}

- (void)showCoCaptainProfile {
    
    if (![[teamDetails objectForKey:@"co_captain_present_id"] isEqualToString:@""]) {
        
        [self moveToFriendProfile:[teamDetails objectForKey:@"co_captain_name"] friendId:[teamDetails objectForKey:@"co_captain_present_id"]];
    }
    else
    {
        [[AlertMessage sharedInstance] showMessage:COCAPTAIN_NOT_PRESENT];
    }
}

- (void)showCaptainProfile {
    
    [self moveToFriendProfile:[teamDetails objectForKey:@"captain_name"] friendId:[teamDetails objectForKey:@"captain_id"]];
}

-(void)moveToFriendProfile:(NSString *)FrinendName friendId:(NSString *)fId
{
    FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    friendProfile.friendId = fId;
    friendProfile.friendName = FrinendName;
    [self.navigationController pushViewController:friendProfile animated:YES];
}

- (void)tapZoomImage:(UITapGestureRecognizer *)tapRecognizer {
    UIImageView *imageView = (UIImageView *)tapRecognizer.view;
    [[Util sharedInstance] addImageZoom:imageView];
}

- (void)tapCoCaptainImage:(UITapGestureRecognizer *)tapRecognizer {
    
    if ([[teamDetails objectForKey:@"co_captain_present_id"] isEqualToString:@""])
    {
        UIImageView *imageView = (UIImageView *)tapRecognizer.view;
        [[Util sharedInstance] addImageZoom:imageView];
    }
    else
    {
        [[AlertMessage sharedInstance] showMessage:COCAPTAIN_NOT_PRESENT];
    }
}


- (void)getMembersList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [_nonMemberTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LIST_TEAM_MEMBERS withCallBack:^(NSDictionary * response){
        
        [_nonMemberTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            page = [[response valueForKey:@"page"] intValue];
            [members addObjectsFromArray:[[response objectForKey:@"team_member_list"] mutableCopy]];
            [self addEmptyMessageForTeamTable];
            [_nonMemberTable reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}



//Get team details
-(void)getTeamDetails{
    // Build Parameter
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_DETAILS withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            _nonMemberTable.hidden = NO;
            
            teamMediaBase = [response objectForKey:@"media_base_url"];
            teamDetails = [[response objectForKey:@"team_details"] mutableCopy];
            is_Invite = [[teamDetails objectForKey:@"has_invite"] boolValue];
            joinMinimumPoints = [teamDetails objectForKey:@"team_join__minimum_point"];
            
            if (is_Invite) {
                popupView.message.text = [NSString stringWithFormat:NSLocalizedString(JOIN_TEAM, nil),[teamDetails objectForKey:@"team_name"],joinMinimumPoints];
                selectedPopup = 1;
                [teamPopup show];
            }
            
            _teamName.text = [teamDetails objectForKey:@"team_name"];
            _captainName.text = [teamDetails objectForKey:@"captain_name"];
            [Util makeAsLink:_captainName withColor:[UIColor whiteColor] showUnderLine:NO range:NSMakeRange(0, [_captainName.text length])];
            
            _points.text = [teamDetails objectForKey:@"points"];
            _rank.text = [teamDetails valueForKey:@"rank"];
            
            NSString *urlTeamImage = [NSString stringWithFormat:@"%@%@",teamMediaBase,[[teamDetails objectForKey:@"team_profile_image"] objectForKey:@"profile_image"]];
            NSString *urlCaptainImage = [NSString stringWithFormat:@"%@%@",teamMediaBase,[[teamDetails objectForKey:@"captain_profile_image"] objectForKey:@"profile_image"]];
            
            [_teamImage setImageWithURL:[NSURL URLWithString:urlTeamImage] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            [_captainImage setImageWithURL:[NSURL URLWithString:urlCaptainImage] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            if ([[teamDetails objectForKey:@"co_captain_present"] intValue] == 0) {
                _coCaptainImage.image =  [UIImage imageNamed:@"cocaptain.png"];
            }
            
            // IF Co-Captain present should display the co-captain Image
            if([[teamDetails objectForKey:@"co_captain_present"] boolValue])
            {
                NSString *urlCoCaptainImage = [NSString stringWithFormat:@"%@%@",teamMediaBase,[[teamDetails objectForKey:@"co_captain_profile_image"] objectForKey:@"profile_image"]];
                [_coCaptainImage setImageWithURL:[NSURL URLWithString:urlCoCaptainImage] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
                [_coCapTainName setText:[teamDetails objectForKey:@"co_captain_name"]];
                [Util makeAsLink:_coCapTainName withColor:[UIColor whiteColor] showUnderLine:NO range:NSMakeRange(0, [_coCapTainName.text length])];
                
            }
            
            //Prepare data for donate
            [teamDetailsToDonate setValue:_captainName.text forKey:@"captain_name"];
            [teamDetailsToDonate setValue:[[teamDetails objectForKey:@"team_profile_image"] objectForKey:@"profile_image"] forKey:@"image_url"];
            [teamDetailsToDonate setValue:_teamName.text forKey:@"name"];
            [teamDetailsToDonate setValue:_points.text forKey:@"team_points"];
            [teamDetailsToDonate setValue:_teamId forKey:@"id"];
            
            //Access level
            _canLike = [[teamDetails valueForKey:@"can_like"] boolValue];
            _canComment = [[teamDetails valueForKey:@"can_comment"] boolValue];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:YES];
    
}

- (IBAction)searchMembers:(id)sender {
    TeamMembersViewController *membersList = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamMembersViewController"];
    membersList.teamId = _teamId;
    membersList.ableToRemove = @"NO";
    [self.navigationController pushViewController:membersList animated:YES];
}

#pragma marks UITableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _segment.selectedSegmentIndex == 0 ? [feeds count] : [members count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    NSString *cellIdentifier = @"";
    
    if (_segment.selectedSegmentIndex == 0) // Feed List
    {
        FeedCell *fcell;

        if ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"is_team_activity"] boolValue]) {
            cellIdentifier = @"TeamFeedCell";
            fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(fcell == nil){
                fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            fcell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            fcell.name.delegate = self;
            NSDictionary *Values = [[feeds objectAtIndex:indexPath.row] objectForKey:@"activity"] ;
            [Util createTeamActivityLabel:fcell.name fromValues:Values];
            fcell.date.text = [Util timeStamp:[[[feeds objectAtIndex:indexPath.row] objectForKey:@"time_stamp"] longValue]];
        }
        else
        {
            if([feeds count] > 0){
                
                cellIdentifier= ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feeds objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"FeedCell" : @"MessagesCell";
                fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if(fcell == nil){
                    fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                
                feedsDesign.feeds = feeds;
                feedsDesign.feedTable = tableView;
                feedsDesign.mediaBaseUrl= mediaBase;
                feedsDesign.viewController = self;
                
                [feedsDesign designTheContainerView:fcell forFeedData:[feeds objectAtIndex:indexPath.row] mediaBase:mediaBase forDelegate:self tableView:tableView];
            }
        }
        
        fcell.backgroundColor = [UIColor clearColor];
        return fcell;
    }
    else  // Member List
    {
        cellIdentifier = @"FriendCell";
        FriendCell *frndcell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
        if(frndcell == nil){
            frndcell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        frndcell.backgroundColor = [UIColor clearColor];
        frndcell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //Read elements
        
        
        NSDictionary *member =[members objectAtIndex:indexPath.row];
        
        frndcell.name.text = [member objectForKey:@"name"];
        frndcell.points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[member objectForKey:@"point"]];
        
        NSString *rankLabel = [Util playerType:[[member valueForKey:@"player_type_id"] intValue] playerRank:[member objectForKey:@"rank"]];
        frndcell.rankLabel.text = rankLabel;
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[member objectForKey:@"profile_image"]];
        [frndcell.profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        
        
        strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[member objectForKey:@"player_skate_pic"]];
        [frndcell.board setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:nil];
        
        return frndcell;
    }
    
    return cell;
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_segment.selectedSegmentIndex == 0) {
        // Feed list
    }
    else{
        if ([members count] > indexPath.row) {
            NSDictionary *friend = [members objectAtIndex:indexPath.row];
            FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            friendProfile.friendId = [friend valueForKey:@"team_member_id"];
            friendProfile.friendName = [friend valueForKey:@"name"];
            [self.navigationController pushViewController:friendProfile animated:YES];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return _segment.selectedSegmentIndex ==  0 ? UITableViewAutomaticDimension : 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _segment.selectedSegmentIndex ==  0 ? UITableViewAutomaticDimension : 90;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (_segment.selectedSegmentIndex == 0){
//        
//        FeedCell *feedCell = (FeedCell *) cell;
//        
//        if([cell isKindOfClass:[FeedCell class]] && feedCell.videoPlayer != nil)
//        {
//            [feedCell.avLayer setFrame:feedCell.videoView.layer.bounds];
//            
//            NSLog(@"Player %f", feedCell.videoPlayer.rate);
//            if ((feedCell.videoPlayer.rate != 0) && (feedCell.videoPlayer.error == nil)) {
//                // player is playing
//            }
//            else
//            {
//                [feedCell.videoPlayer play];
//            }
//        }
//        
//        [feedsDesign stopAllVideos];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [feedsDesign playVideoConditionally];
//        });
//    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
//    [feedsDesign stopTheVideo:cell];
//    
////    NSArray *visibleCells = [_nonMemberTable visibleCells];
////    for(UITableViewCell *visibleCell in visibleCells){
////        if(visibleCell == cell)
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [feedsDesign playVideoConditionally];
//            });
////    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [feedsDesign checkWhichVideoToEnable:_nonMemberTable];
}
#pragma argu - KLCPointpopup delegate
- (void)onBuyPointsClick{
    [pointPopup dismiss:YES];
    BuyPointsViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"BuyPointsViewController"];
    [self.navigationController pushViewController:profile animated:YES];
}

-(void)onDonatePointsClick{
    
    [pointPopup dismiss:YES];
    
    //Directly move to donate form
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

    DonateForm *donateForm = [mainStoryboard instantiateViewControllerWithIdentifier:@"DonateForm"];
    donateForm.donateTo = teamDetailsToDonate;
    donateForm.donationType = 1; //For Team
    donateForm.mediaBase = mediaBase;
    donateForm.donatedFrom = 1; //From Player
    donateForm.donatorId = _teamId;
    [self.navigationController pushViewController:donateForm animated:YES];
}

-(void)onRedeemPointsClick{
    [pointPopup dismiss:YES];
}

-(void)onPointsActivityLog{
    [pointPopup dismiss:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];

    PointsActivityLog *points = [mainStoryboard instantiateViewControllerWithIdentifier:@"PointsActivityLog"];
    points.friendId = _teamId;
    [self.navigationController pushViewController:points animated:YES];
}

#pragma mark - Attributed Label delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSString *tag = [[label.text substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
    [searchViewController searchFor:tag];
    [self.navigationController pushViewController:searchViewController animated:YES];
}
//Common Delegate for TTTAttributed Label
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    NSString *strUrl = [url absoluteString];
    if (label == _captainName){
        [self showCaptainProfile];
    }
    else if (label == _coCapTainName){
        [self showCoCaptainProfile];
    }
    else if (![strUrl isEqualToString:@""]) {
        
        NSArray *array = [strUrl componentsSeparatedByString:@"/"];
        if ([array count] == 4 && [[array objectAtIndex:0] isEqualToString:@"VarialLink"]) {
            if ([[array objectAtIndex:1] intValue] == 0) {
                if ([[Util getFromDefaults:@"player_id"] isEqualToString:[array objectAtIndex:2]]) {
                    MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
                    [self.navigationController pushViewController:myProfile animated:YES];
                }
                else{
                    FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
                    friendProfile.friendId = [array objectAtIndex:2];
                    friendProfile.friendName =  friendProfile.friendName = [[array objectAtIndex:3] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    [self.navigationController pushViewController:friendProfile animated:YES];
                }
            }
            else
            {
                TeamViewController  *teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
                if ([[array objectAtIndex:3] isEqualToString:@"4"]) {
                    teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
                }
                teamView.teamId = [array objectAtIndex:2];
                if (![[array objectAtIndex:2] isEqualToString:_teamId]) { //check current team
                    [self.navigationController pushViewController:teamView animated:YES];
                }
            }
        }
        else{
            //Open Url
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else{
        
        CGPoint position = [label convertPoint:CGPointZero toView:_nonMemberTable];
        NSIndexPath *indexPath = [_nonMemberTable indexPathForRowAtPoint:position];
        NSMutableDictionary *feed = [feeds objectAtIndex:indexPath.row];
        if ([[feed objectForKey:@"is_local"] isEqualToString:@"false"]) {
            
            //Build Input Parameters
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            [inputParams setValue:[feed valueForKey:@"post_id"] forKey:@"post_id"];
            
            [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
                if([[response valueForKey:@"status"] boolValue]){
                    [feed setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                    [feed setValue:[NSNumber numberWithBool:FALSE] forKey:@"continue_reading_flag"];
                    [_nonMemberTable reloadData];
                }else{
                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                }
            } isShowLoader:NO];
        }
    }
}


-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer
{
    // Get selected Index
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:_nonMemberTable];
    NSIndexPath *indexPath = [_nonMemberTable indexPathForRowAtPoint:buttonPosition];
    if ([feeds count] > indexPath.row) {
        FriendProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        profile.friendId = [[feeds objectAtIndex:indexPath.row] objectForKey:@"post_owner_id"];
        profile.friendName = [[feeds objectAtIndex:indexPath.row] objectForKey:@"name"];
        [self.navigationController pushViewController:profile animated:YES];
    }
}


// Click Star & Unstar
- (IBAction)Star:(id)sender
{
    if(_canLike){
        [feedsDesign addStar:_nonMemberTable fromArray:feeds forControl:sender];
    }
    else{
        [[AlertMessage sharedInstance] showMessage:CANNOT_LIKE_COMMENT];
    }
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender
{
    [feedsDesign addBookmark:_nonMemberTable fromArray:feeds forControl:sender];
}

-(void)designTheStarView:(id)sender Status:(NSString *)status Count:(NSString *)count
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_nonMemberTable];
    NSIndexPath *indexPath = [_nonMemberTable indexPathForRowAtPoint:buttonPosition];
    FeedCell *cell = [_nonMemberTable cellForRowAtIndexPath:indexPath];
    
    // Update Stat Status
    long sCount = [count longLongValue];
    NSString *star = sCount > 1 ? @"%@ Stars" : @"%@ Star";
    NSString *strCount = (sCount == 0 ) ? @"Star" : [NSString stringWithFormat:star,count];
    [cell.starCount setText:[NSString stringWithFormat:NSLocalizedString(strCount, nil)]];
    cell.starCount.textColor = ([status intValue] == 1)? UIColorFromHexCode(THEME_COLOR) : [UIColor darkGrayColor];
    cell.starImage.image = ([status intValue] == 1)? [UIImage imageNamed:@"starActive"] : [UIImage imageNamed:@"star"];
}

// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_nonMemberTable];
        NSIndexPath *path = [_nonMemberTable indexPathForRowAtPoint:buttonPosition];
        NSString *star_post_id = [[feeds objectAtIndex:path.row] objectForKey:@"post_id"];
        Comments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
        NSDictionary *imageInfo = [feeds objectAtIndex:path.row];
        comment.postId = star_post_id;
        comment.mediaId = [imageInfo valueForKey:@"image_id"];
        comment.postDetails = [feeds objectAtIndex:path.row];
        comment.canNotComment = _canComment ? nil : @"YES";
        [self.navigationController pushViewController:comment animated:YES];
    }
    else
    {
        [appDelegate.networkPopup show];
    }
}

// Get Feeds List
-(void)getFeedsList
{
    NSString *strPostId = @"0";
    NSString *timeStamp = @"0";
    
    if ([feeds count] != 0) {
        NSMutableDictionary *lastIndex = [feeds lastObject];
        strPostId = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"post_id"]];
        timeStamp = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"time_stamp"]];
    }
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:strPostId forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"1" forKey:@"team_post"];
    [inputParams setValue:_teamId forKey:@"post_type_id"];
    [inputParams setValue:@"0"  forKey:@"recent"];
    [inputParams setValue:timeStamp  forKey:@"time_stamp"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            mediaBase = [response objectForKey:@"media_base_url"];
            [self alterTheMediaList:response];
            //show empty message
            [self addEmptyMessageForTeamTable];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:NO];
}


//Append the media url with base
- (void)alterTheMediaList:(NSDictionary *)response{
    
    
    for (int i=0; i< [[response objectForKey:@"feed_list"] count]; i++) {
        NSMutableDictionary *dict = [[[response objectForKey:@"feed_list"] objectAtIndex:i] mutableCopy];
        
        [dict setValue:@"false" forKey:@"is_local"];
        [dict setValue:@"false" forKey:@"is_upload"];
        [dict setValue:@"" forKey:@"task_identifier"];
        [dict setValue:@"" forKey:@"task"];
        
        int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[dict valueForKey:@"post_id"] from:feeds type:1];
        
        if (![[dict objectForKey:@"is_team_activity"] boolValue] && postIndex == -1) {
            
            if (![[dict objectForKey:@"is_team_activity"] boolValue]) {
                
                NSMutableDictionary *profileImage = [[dict objectForKey:@"posters_profile_image"] mutableCopy];
                [profileImage setValue: [NSString stringWithFormat:@"%@%@",mediaBase,[profileImage  valueForKey:@"profile_image"]] forKey:@"profile_image"];
                [dict setObject:profileImage forKey:@"posters_profile_image"];
                
                NSMutableArray *mediaList = [[dict valueForKey:@"image_present"] boolValue] ? [[dict objectForKey:@"image"] mutableCopy] : [[dict objectForKey:@"video"] mutableCopy];
                for (int i=0; i<[mediaList count]; i++) {
                    NSMutableDictionary *media = [[mediaList objectAtIndex:i] mutableCopy];
                    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[media valueForKey:@"media_url"]];
                    [media setValue:imageUrl forKey:@"media_url"];
                    [media setValue:@"true" forKey:@"isEnabled"];
                    [mediaList replaceObjectAtIndex:i withObject:media];
                }
                
                if ([[dict valueForKey:@"image_present"] boolValue]) {
                    [dict setObject:mediaList forKey:@"image"];
                }
                else{
                    [dict setObject:mediaList forKey:@"video"];
                }
            }
            
            // Add response array to the selected feed type
            [feeds addObject:dict];
        }
        else if([[dict objectForKey:@"is_team_activity"] boolValue]){
            // Add response array to the selected feed type
            [feeds addObject:dict];
        }
        
    }
    [_nonMemberTable reloadData];
    
}
// Feed list desgin ends


// Accept Team Invite
-(void)acceptTeamInvite
{
    [teamPopup dismiss:YES];
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:1] forKey:@"accept_flag"];
    [inputParams setValue:_teamId forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ACCEPT_REJECT_TEAM withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue])
        {
            //Reload Team list api for Team chat
            [[XMPPServer sharedInstance].arrayInvitation addObject:_teamId];
            [appDelegate getTeamList];
            
            [self changeViewController];
            
            Feeds *feed = [[Feeds alloc] init];
            [feed getFeedsTypesList];
            
            [self changeViewController];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:YES];
}

//Move to team view controller
-(void)changeViewController
{
    //Remove the current view controller
    NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];
    [viewControllers removeLastObject];
    
    TeamViewController *teamView = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
    teamView.teamId = _teamId;
    //Add the new view controller
    [viewControllers addObject:teamView];
    
    //Reset the navigation views
    self.navigationController.viewControllers = viewControllers;

}

-(void)reportButtonAction:(UITapGestureRecognizer *)tapRecognizer{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.nonMemberTable];
        NSIndexPath *indexPath = [self.nonMemberTable indexPathForRowAtPoint:buttonPosition];
        reportFeed = [feeds objectAtIndex:indexPath.row];
        
        [self.reportPopover dismissMenuPopover];
        
        self.reportPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 65 - _nonMemberTable.contentOffset.y, 140, 84) menuItems:@[NSLocalizedString(REPORT_THE_POST,nil),NSLocalizedString(BLOCK_THE_USER, nil)]];
        self.reportPopover.menuPopoverDelegate = self;
        self.reportPopover.tag = 101;
        [self.reportPopover showInView:self.view];
    }
}

// Delegate method for MLKMenuPopover
- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    [self.reportPopover dismissMenuPopover];
    if([[Util sharedInstance] getNetWorkStatus])
    {
       // int clickedIndex = selectedIndex;
        if(selectedIndex == 0){
            [self reportPost];
        }
        else{
            selectedPopup = 3;
            [blockPopUp show];
        }
    }
    else{
        [appDelegate.networkPopup show];
    }
}
-(void)reportPost{
    NSMutableArray *menuArray = [[NSMutableArray alloc] init];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"report_Type"] != nil)
    {
        reportType = [[NSUserDefaults standardUserDefaults] objectForKey:@"report_Type"];
        if([reportType count] > 0){
            for(NSDictionary *dictionary in reportType){
                [menuArray addObject:[dictionary objectForKey:@"type"]];
            }
            if([menuArray count] != 0){
                menu = [[Menu alloc]initWithViews:NSLocalizedString(REPORT_POST, nil) buttonTitle:menuArray withImage:nil];
                menu.delegate = self;
                menuPopup = [KLCPopup popupWithContentView:menu showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
                [menuPopup show];
            }
        }
    }
}
-(void)menuActionForIndex:(int)tag{
    [menuPopup dismiss:YES];
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[reportFeed objectForKey:@"post_id"] forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
    [inputParams setValue:[[reportType objectAtIndex:tag-1] objectForKey:@"id"] forKey:@"report_type_id"];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEND_REPORT withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            int row = (int)[feeds indexOfObject:reportFeed];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [_nonMemberTable beginUpdates];
            [feeds removeObject:reportFeed];
            [_nonMemberTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [_nonMemberTable endUpdates];
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
        }
    } isShowLoader:YES];
}

-(void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    UIMenuController *menucontroller=[UIMenuController sharedMenuController];
    UIMenuItem *MenuitemA=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) action:@selector(DeletePost:)];
    [menucontroller setMenuItems:[NSArray arrayWithObjects:MenuitemA,nil]];
    //menucontroller.arrowDirection = UIMenuControllerArrowDown;
    
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:_nonMemberTable];
    NSIndexPath *indexPath = [_nonMemberTable indexPathForRowAtPoint:buttonPosition];
    
    menuPosition = indexPath;
    //It's mandatory
    [self becomeFirstResponder];
    //It's also mandatory ...remeber we've added a mehod on view class
    if([self canBecomeFirstResponder])
    {
        [menucontroller setTargetRect:CGRectMake(10,10, 0, 200) inView:tapRecognizer.view];
        [menucontroller setMenuVisible:YES animated:YES];
    }
}

- (void) copy:(id) sender {
    // called when copy clicked in menu
}
- (void) menuItemClicked:(id) sender {
    // called when Item clicked in menu
}
- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(DeletePost:) /*|| selector == @selector(copy:)*/ /**<enable that if you want the copy item */) {
        return YES;
    }
    return NO;
}
- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void)DeletePost:(UIMenuController *)sender
{
    selectedPopup = 2;
    [deletePopup show];
}

-(void)deleteFeedPost
{
    [deletePopup dismiss:YES];
    
    NSString *strPostId = [NSString stringWithFormat:@"%@",[[feeds objectAtIndex:menuPosition.row] objectForKey:@"post_id"]];
    
    [_nonMemberTable beginUpdates];
    [feeds removeObjectAtIndex:menuPosition.row];
    [_nonMemberTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
    [_nonMemberTable endUpdates];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:strPostId  forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DELETE_POST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}


@end
