//
//  PlayerType.m
//  Varial
//
//  Created by jagan on 19/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "PlayerType.h"
#import "HeaderView.h"
#import "Util.h"
#import "ProfilePicture.h"
#import "ViewController.h"

@interface PlayerType ()

@end

@implementation PlayerType
int selectedIndex, popupType;
BOOL isManualTrigger;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    playerTypes = [[NSMutableArray alloc] init];
    selectedIndex = -1;
    isManualTrigger = FALSE;
    [self designTheView];
    [self getPlayerTypes];
    [self createPopupWindows];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askBackConfirm:) name:@"BackPressed" object:nil];

}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:@"BackPressed" ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) askBackConfirm:(NSNotification *) data{
    popupType = 1;
    [backPopup show];
}

- (void)designTheView{
    
    _headerView.restrictBack = TRUE;
    [_headerView setHeader: NSLocalizedString(SIGN_UP_AS, nil)];

    _headerView.chatBadge.hidden = TRUE;
    _headerView.chatIcon.hidden = TRUE;
    
    //Set transparent color to tableview
    [self.playerTable setBackgroundColor:[UIColor clearColor]];
    self.playerTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void)viewDidAppear:(BOOL)animated{
    if (_welcomeMessage != nil) {        
        [[AlertMessage sharedInstance] showMessage:_welcomeMessage withDuration:2];
    }
}

- (void)createPopupWindows{
    
    //Alert popup
    backPopupView = [[YesNoPopup alloc] init];
    backPopupView.delegate = self;
    [backPopupView setPopupHeader:NSLocalizedString(SIGN_UP_AS, nil)];
    backPopupView.message.text = NSLocalizedString(CANCEL_FOR_SURE, nil);
    [backPopupView.yesButton setTitle:NSLocalizedString(YES_STRING, nil) forState:UIControlStateNormal];
    [backPopupView.noButton setTitle:NSLocalizedString(NO_STRING, nil) forState:UIControlStateNormal];
    
    backPopup = [KLCPopup popupWithContentView:backPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    backPopup.didFinishDismissingCompletion = ^{
        if (isManualTrigger) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
            Login *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
            UINavigationController * aNavi = [[UINavigationController alloc]initWithRootViewController:login];
            [[UIApplication sharedApplication] delegate].window.rootViewController = aNavi;
//            [[UIApplication sharedApplication] delegate].window.rootViewController = login;
        }
    };
    
    //Alert popup
    confirmView = [[YesNoPopup alloc] init];
    confirmView.delegate = self;
    [confirmView setPopupHeader:NSLocalizedString(MEMBER_ALERT, nil)];
    confirmView.message.text = NSLocalizedString(CANCEL_FOR_SURE, nil);
    [confirmView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [confirmView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    confirmPopup = [KLCPopup popupWithContentView:confirmView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}


//Get login status to check for email
-(void) getPlayerTypes{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PLAYER_TYPE_LIST withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [playerTypes addObjectsFromArray:[response objectForKey:@"post_types"]];
            _noteLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Note", nil),[response valueForKey:@"note"]] ;
            [_playerTable reloadData];
        }
    } isShowLoader:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [playerTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"playerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    //Read elements
    UIImageView *flag = [cell viewWithTag:10];
    UILabel *title = [cell viewWithTag:11];
    UILabel *description = [cell viewWithTag:12];
    
    //Bind the contents
    NSDictionary *player = [playerTypes objectAtIndex:indexPath.row];
    [flag setImage:[UIImage imageNamed:[player valueForKey:@"flag"]]];
    title.text = [player valueForKey:@"type"];
    description.text = [player valueForKey:@"description"];
    
    
    if(selectedIndex == (int)indexPath.row){
        [flag setImage:[UIImage imageNamed:@"checkboxCheckedIcon"]];
    }
    else{
        [flag setImage:[UIImage imageNamed:@"checkboxIcon"]];
    }
    
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex =  (int) indexPath.row;
    NSDictionary *playerType = [playerTypes objectAtIndex:selectedIndex];
    
    if ([[playerType valueForKey:@"id"] intValue] == 1) {
        confirmView.message.text = NSLocalizedString(SIGNUP_AS_SKATER, nil);
    }
    else if ([[playerType valueForKey:@"id"] intValue] == 2) {
        confirmView.message.text = NSLocalizedString(SIGNUP_AS_CREW, nil);
    }
    else if ([[playerType valueForKey:@"id"] intValue] == 3) {
        confirmView.message.text = NSLocalizedString(SIGNUP_AS_MEDIA, nil);
    }
    
    [tableView reloadData];
    popupType = 2;
    [confirmPopup show];
}

#pragma args - YesNoPopup Delegates
- (void)onYesClick{
    
    if (popupType == 1) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LOGOUT_API withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                isManualTrigger = TRUE;
                [backPopup dismiss:YES];
                [Util removeUserData];
            }
        } isShowLoader:YES];
    }
    else if (popupType == 2){
        
        NSDictionary *playerType = [playerTypes objectAtIndex:selectedIndex];
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[playerType valueForKey:@"id"] forKey:@"player_type_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_PLAYER_TYPE withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [confirmPopup dismiss:YES];
                [Util setInDefaults:@"YES" withKey:@"isPlayerTypeSet"];
                [Util setInDefaults:[playerType valueForKey:@"id"] withKey:@"playerType"];
                //Flags for control the skater/crew/media privileges
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_bazzardrun"] boolValue] forKey:@"can_participate_in_bazzardrun"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_clubpromotion"] boolValue] forKey:@"can_participate_in_clubpromotion"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_shop_offers"] boolValue] forKey:@"can_show_shop_offers"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                ProfilePicture *profilePicture = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfilePicture"];
//                profilePicture.inviteMessage = [response valueForKey:@"invite_code_message"];
                [UIApplication sharedApplication].delegate.window.rootViewController=profilePicture;
            }
            else{
                
                if([[response valueForKey:@"is_selected"] boolValue])
                {
                    [confirmPopup dismiss:YES];
                    [Util setInDefaults:@"YES" withKey:@"isPlayerTypeSet"];
                    [Util setInDefaults:[playerType valueForKey:@"id"] withKey:@"playerType"];
                    //Flags for control the skater/crew/media privileges
                    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_bazzardrun"] boolValue] forKey:@"can_participate_in_bazzardrun"];
                    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_clubpromotion"] boolValue] forKey:@"can_participate_in_clubpromotion"];
                    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_shop_offers"] boolValue] forKey:@"can_show_shop_offers"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                    [UIApplication sharedApplication].delegate.window.rootViewController=viewController;
                    [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
                }
                else{
                    [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
                }
            }            
        } isShowLoader:YES];
    }
}

- (void)onNoClick{
    [backPopup dismiss:YES];
    [confirmPopup dismiss:YES];
}


@end
