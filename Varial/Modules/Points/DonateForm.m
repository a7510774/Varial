//
//  DonateForm.m
//  Varial
//
//  Created by jagan on 14/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "DonateForm.h"
#import "AlertMessage.h"

@interface DonateForm ()

@end

@implementation DonateForm

// donatedFrom - 1 -> Player 2 -> Team
// donationType - 0 -> Player 1 -> Team
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self designTheView];
    [_donateTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [Util createBottomLine:_pointsToDonate withColor:UIColorFromHexCode(TEXT_BORDER)];
}

- (IBAction)cancelDonate:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)donate:(id)sender {
    if ([self validateDonateForm]) {
        [donateConfirmPopup show];
        [_pointsToDonate resignFirstResponder];
    }
}

- (BOOL)validateDonateForm{
    
    [Util createBottomLine:_pointsToDonate withColor:UIColorFromHexCode(TEXT_BORDER)];
    
    if([[_pointsToDonate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [[AlertMessage sharedInstance] showMessage:[NSString stringWithFormat:NSLocalizedString(ENTER_POINTS_TO_DONATE, nil)]];
        [Util createBottomLine:_pointsToDonate withColor:UIColorFromHexCode(THEME_COLOR)];
        return FALSE;
    }
    if(![Util validateNumberField:_pointsToDonate withValueToDisplay:POINTS withMinLength:1 withMaxLength:POINTS_MAX])
    {
        [Util createBottomLine:_pointsToDonate withColor:UIColorFromHexCode(THEME_COLOR)];
        return FALSE;
    }
    
    if ([_pointsToDonate.text intValue] == 0) {
        [[AlertMessage sharedInstance] showMessage:[NSString stringWithFormat:NSLocalizedString(POINTS_ZERO, nil)]];
        [Util createBottomLine:_pointsToDonate withColor:UIColorFromHexCode(THEME_COLOR)];
        return FALSE;
    }
    
    return TRUE;
}


- (void)designTheView{
    
    [_headerView setHeader:NSLocalizedString(DONATE_POINTS, nil)];

    
    _donateTable.backgroundColor=[UIColor clearColor];
    _donateTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [Util createRoundedCorener:_donateButton withCorner:3];
    [Util createRoundedCorener:_cancelButton withCorner:3];
    
    _successInnerView.layer.cornerRadius = _successInnerView.frame.size.height / 2;
    _successInnerView.clipsToBounds = YES;
    _successInnerView.layer.borderColor = [UIColor whiteColor].CGColor;
    _successInnerView.layer.borderWidth = 1;
    
    //Alert popup
    donateConfirm = [[YesNoPopup alloc] init];
    donateConfirm.delegate = self;
    [donateConfirm setPopupHeader: NSLocalizedString(DONATE, nil)];
    donateConfirm.message.text = NSLocalizedString(SURE_TO_DONATE, nil);
    [donateConfirm.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [donateConfirm.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    donateConfirmPopup = [KLCPopup popupWithContentView:donateConfirm showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}



//Donate from player to player/team
- (void)donateFromMember{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_pointsToDonate.text forKey:@"points"];
    NSString *isMember = @"true";
    NSString *donatorToId;
    
    if (_donationType == 1){
        isMember = @"false";
        donatorToId = [_donateTo valueForKey:@"id"];
    }
    else{
        isMember = @"true";
        donatorToId = [_donateTo valueForKey:@"player_id"];
    }
    [inputParams setValue:_pointsToDonate.text forKey:@"points"];
    [inputParams setValue:isMember forKey:@"is_player"];
    [inputParams setValue:donatorToId forKey:@"acceptors"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DONATE_FROM_MEMBER withCallBack:^(NSDictionary * response)
     {
        [donateConfirmPopup dismiss:YES];
         if([[response valueForKey:@"status"] boolValue]){
             [_donateForm setHidden:YES];
             [_donateSuccess setHidden:NO];
             _remainingPoints.text = [response valueForKey:@"remaining_points"];
             _successMessage.text = [response valueForKey:@"message"];
             if([isMember isEqualToString:@"true"])
             {
                 _donateTo = [_donateTo mutableCopy];
                 if ([response valueForKey:@"receiver_points"] != nil) {
                     [_donateTo setValue:[response valueForKey:@"receiver_points"] forKey:@"point"];
                 }
             }
             else {
                 _donateTo = [_donateTo mutableCopy];
                 if ([response valueForKey:@"receiver_points"] != nil) {
                     [_donateTo setValue:[response valueForKey:@"receiver_points"] forKey:@"team_points"];
                 }
             }
             
             [_donateTable reloadData];
         }
         else{
             [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
         }
         
     } isShowLoader:YES];
}



//Donate from player to player/team
- (void)donateFromTeam{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_pointsToDonate.text forKey:@"points"];
    NSString *isMember = @"true";
    NSString *donatorToId;
    
    if (_donationType == 1){
        isMember = @"false";
        donatorToId = [_donateTo valueForKey:@"id"];
    }
    else{
        isMember = @"true";
        donatorToId = [_donateTo valueForKey:@"player_id"];
    }
    [inputParams setValue:_pointsToDonate.text forKey:@"points"];
    [inputParams setValue:isMember forKey:@"is_player"];
    [inputParams setValue:donatorToId forKey:@"acceptors"];
    [inputParams setValue:_donatorId forKey:@"team_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:DONATE_FROM_TEAM withCallBack:^(NSDictionary * response)
     {
         [donateConfirmPopup dismiss:YES];
         if([[response valueForKey:@"status"] boolValue]){
             [_donateForm setHidden:YES];
             [_donateSuccess setHidden:NO];
             _remainingPoints.text = [response valueForKey:@"remaining_points"];
             _successMessage.text = [response valueForKey:@"message"];
             
             if([isMember isEqualToString:@"true"])
             {
                 NSInteger oldpoints = [[_donateTo objectForKey:@"point"] integerValue];
                 NSInteger donatepoints = [_pointsToDonate.text integerValue];
                 NSInteger newPoints = oldpoints + donatepoints;
                 _donateTo = [_donateTo mutableCopy];
                 [_donateTo setValue:[NSNumber numberWithInteger:newPoints] forKey:@"point"];
             }
             else {
                 NSInteger oldpoints = [[_donateTo objectForKey:@"team_points"] integerValue];
                 NSInteger donatepoints = [_pointsToDonate.text integerValue];
                 NSInteger newPoints = oldpoints + donatepoints;
                 _donateTo = [_donateTo mutableCopy];
                 [_donateTo setValue:[NSNumber numberWithInteger:newPoints] forKey:@"team_points"];
             }
             
             [_donateTable reloadData];
         
         }
         else{
             [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
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


#pragma args YesNoPopup
- (void)onYesClick{
    
    [_pointsToDonate resignFirstResponder];
    
    if (_donatedFrom == 1) {
        [self donateFromMember];
    }else{
        [self donateFromTeam];
    }
}
- (void)onNoClick{
    [donateConfirmPopup dismiss:YES];
}

#pragma mark - UITableViewDelegate method
//set number of rows in tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//set tableview content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    
    if (_donationType == 1) {
        
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
        
        NSDictionary *team = _donateTo;
        
        NSDictionary *teamImageObj = [team objectForKey:@"image_path"];
        NSString *profileUrl = [NSString stringWithFormat:@"%@%@",_mediaBase,[teamImageObj valueForKey:@"profile_image"]];
        [teamImage setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        
        teamName.text = [team valueForKey:@"name"];
        teamCaptain.text = [team valueForKey:@"captain_name"];
        points.text = [NSString stringWithFormat:@"%@",[team valueForKey:@"team_points"]];
        
        //Add zoom
        //[[Util sharedInstance] addImageZoom:teamImage];
        
        
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
     //   UIButton *status = (UIButton *)[cell viewWithTag:16];
     //   UIView *statusView = (UIView *)[cell viewWithTag:17];
        
        NSDictionary *member = _donateTo;
        
        NSString *profileUrl = [NSString stringWithFormat:@"%@%@",_mediaBase,[member  valueForKey:@"profile_image"]];
        [profile setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
        
        name.text = [member valueForKey:@"player_name"];
        rank.text =  [Util playerType:[[member objectForKey:@"player_type_id"] intValue] playerRank:[member objectForKey:@"rank"]];
        points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[member valueForKey:@"point"]];
        
        
        NSString *skateUrl = [NSString stringWithFormat:@"%@%@",_mediaBase,[member  valueForKey:@"player_skate_pic"]];
        [skateBaord setImageWithURL:[NSURL URLWithString:skateUrl] placeholderImage:nil];
        
        //Add zoom
        //[[Util sharedInstance] addImageZoom:profile];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
