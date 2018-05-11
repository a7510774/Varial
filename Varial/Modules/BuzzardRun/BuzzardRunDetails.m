//
//  BuzzardRunDetails.m
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BuzzardRunDetails.h"
#import "Util.h"
#import "Config.h"
#import "OpenInGoogleMapsController.h"

@interface BuzzardRunDetails ()

@end

@implementation BuzzardRunDetails

NSArray *buzzardRunStatusTitle,*buzzardRunStatusIcon;
BOOL isRegistered;
int buzzardRunStatus;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    buzzardRunStatusIcon = [[NSArray alloc] initWithObjects:@"",@"Register.png",@"invitedTick.png",@"friendsIcon.png",@"friendsIcon.png",@"friendsIcon.png",  nil];
    buzzardRunStatusTitle = [[NSArray alloc] initWithObjects:@"",
                         NSLocalizedString(REGISTER, nil),
                         NSLocalizedString(REGISTERED, nil),
                         NSLocalizedString(APPROVED, nil),
                         NSLocalizedString(REWARDED, nil),
                         NSLocalizedString(EXPIRED, nil),nil];
    isRegistered = FALSE;
    [self designTheView];
    [self createPopupWindows];
    
    //Register for the notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBuzzardRunStatus:) name:@"GeneralNotification" object:nil];
}

- (void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeneralNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    eventList = [[NSMutableArray alloc] init];
    shopLocation = [[NSMutableDictionary alloc] init];
    [self getBuzzardRunDetails:TRUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Change Buzzard run status
-(void) changeBuzzardRunStatus:(NSNotification *) data{
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    NSDictionary *body = [notificationContent objectForKey:@"data"];
    if ([[notificationContent objectForKey:@"type"] isEqualToString:@"general_notification"]) {
        if ([[body valueForKey:@"redirection_type"] intValue] == 7 || [[body valueForKey:@"redirection_type"] intValue] == 9) {
            [activationCodePopup dismiss:YES];
            //Reload the view
            eventList = [[NSMutableArray alloc] init];
            shopLocation = [[NSMutableDictionary alloc] init];
            [self getBuzzardRunDetails:TRUE];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"isBuzzardRunStatusChanged"];
        }
    }
}

- (void)designTheView
{
    [_headerView setHeader:NSLocalizedString(BUZZARD_RUN_DETAILS, nil)];

    
    //Hide the register button if can_participate_in_bazzardrun is false
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"can_participate_in_bazzardrun"]){
        _registerButton.hidden = YES;
        _registerLabel.hidden = YES;
    }
    [_tabView.layer setBorderColor: UIColorFromHexCode(THEME_COLOR).CGColor];
    [_tabView.layer setBorderWidth:.5f];
    
    self.eventsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _eventsTable.backgroundColor = [UIColor clearColor];
    [_eventsTable setHidden:YES];
    
    selectedTab = 1;
    [self changeTabColor:selectedTab];
}

//Get buzzard run details
- (void)getBuzzardRunDetails:(BOOL)showLoader{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:_buzzardRunId forKey:@"buzzardrun_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BUZZARD_RUN_DETAIL withCallBack:^(NSDictionary * response){        
        if([[response valueForKey:@"status"] boolValue]){
            mediaBase = [response objectForKey:@"media_base_url"];
            [self bindTheDetails:[[response objectForKey:@"buzzardrun_details"] mutableCopy]];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            [_eventsTable setHidden:YES];
        }
        
    } isShowLoader:showLoader];
}

//Create popup windows
- (void)createPopupWindows{
    
    //Alert popup
    registerConfirm = [[YesNoPopup alloc] init];
    registerConfirm.delegate = self;
    [registerConfirm setPopupHeader:NSLocalizedString(BUZZARD_RUN, nil)];
    registerConfirm.message.text = NSLocalizedString(WANT_TO_REGISTER, nil);
    [registerConfirm.yesButton setTitle:NSLocalizedString(YES_STRING, nil) forState:UIControlStateNormal];
    [registerConfirm.noButton setTitle:NSLocalizedString(NO_STRING, nil) forState:UIControlStateNormal];
    
    registerConfirmPopup = [KLCPopup popupWithContentView:registerConfirm showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    //Email set confirmation popup
    activationCode = [[NetworkAlert alloc] init];
    [activationCode setNetworkHeader:NSLocalizedString(ACTIVATION_CODE, nil)];
    [activationCode.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    activationCode.delegate = self;
    
    activationCodePopup = [KLCPopup popupWithContentView:activationCode showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
}

//Bind the buzzard details
- (void)bindTheDetails:(NSMutableDictionary *)details{
    
    //Bind The Image
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[details valueForKey:@"buzzardrun_image"]];
    [_profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
    [[Util sharedInstance] addImageZoom:_profileImage];
    
    buzzardRunName = [details valueForKey:@"buzzardrun_name"];
    
    _name.text = buzzardRunName;
    _subName.text = [details valueForKey:@"shop_name"];
    _address.text = [details valueForKey:@"buzzardrun_address"];
    [_subName sizeToFit];
    [_address sizeToFit];
    
    //Adjust the table header view height
    CGRect frame = _tableViewHeaderView.frame;
    frame.size.height = 220 + _address.frame.size.height +  _subName.frame.size.height;
    _tableViewHeaderView.frame = frame;
    [_eventsTable setTableHeaderView:_tableViewHeaderView];
    
    //Assign the co-ordinate
    [shopLocation setValue:[details valueForKey:@"latitude"]  forKey:@"latitude"];
    [shopLocation setValue:[details valueForKey:@"longitude"]  forKey:@"longitude"];
    [shopLocation setValue:[details valueForKey:@"shop_name"]  forKey:@"name"];
    [shopLocation setValue:[details valueForKey:@"buzzardrun_address"]  forKey:@"subTitle"];
    
    _points.text = [details valueForKey:@"prize_points"];
    instructions = [details valueForKey:@"instructions"];
    isRegistered = [[details valueForKey:@"is_registered"] boolValue];
    buzzardRunStatus = [[details valueForKey:@"buzzard_run_status"] intValue];
    registrationToken = [NSString stringWithFormat:@"%@",[details valueForKey:@"registration_token"]];
    [self changeRegisterStatus];

    [eventList addObjectsFromArray:[[details objectForKey:@"event_list"] mutableCopy]];
    
    if(buzzardRunStatus==1){
        [self changeTabColor:1];
        selectedTab = 1;
    }
    else{
        [self changeTabColor:2];
        selectedTab = 2;
        
    }
    
    [_eventsTable setHidden:NO];
    [_eventsTable reloadData];

    //[self addEmptyMessageForEventList];
}

//Change register button status after register the buzzardRun
- (void)changeRegisterStatus{
    [_registerButton setBackgroundImage:[UIImage imageNamed:[buzzardRunStatusIcon objectAtIndex:buzzardRunStatus]] forState:UIControlStateNormal];
    _registerLabel.text = [buzzardRunStatusTitle objectAtIndex:buzzardRunStatus];
}

-(IBAction)generalButton:(id)sender
{
    selectedTab = 1;
    [self changeTabColor:selectedTab];
}

-(IBAction)eventsButton:(id)sender
{
    selectedTab = 2;
    [self changeTabColor:selectedTab];
}

- (IBAction)registerBuzzardRun:(id)sender {
    if (!isRegistered) {
        //Need to register
        [registerConfirmPopup show];
    }
    else{
        if (buzzardRunStatus == 2) { //Show until the buzzard complete
            //Show registration token
            [self showActivationCode];
        }
    }
}

- (IBAction)getDirection:(id)sender {
    
    BOOL isGoogleMapsInstalled = [OpenInGoogleMapsController sharedInstance].isGoogleMapsInstalled;
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    // IF ch or zh is an CHINA
    if(!([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]) && isGoogleMapsInstalled){
        GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
        definition.startingPoint = nil; // Default user current location
        GoogleDirectionsWaypoint *destination = [[GoogleDirectionsWaypoint alloc] init];
        destination.location = CLLocationCoordinate2DMake([[shopLocation valueForKey:@"latitude"] doubleValue], [[shopLocation valueForKey:@"longitude"] doubleValue]);
        definition.destinationPoint = destination;
        [[OpenInGoogleMapsController sharedInstance] openDirections:definition];
    }
    else{
        GetDirections *getDirections = [self.storyboard instantiateViewControllerWithIdentifier:@"GetDirections"];
        getDirections.destination = shopLocation;
        getDirections.isFrom = @"BuzzardRun";
        [self.navigationController pushViewController:getDirections animated:YES];
    }
}

//Register for buzzard if not registered
- (void)registerForBuzzardRun{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:_buzzardRunId forKey:@"buzzardrun_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:REGISTER_BUZZARD_RUN withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            isRegistered = TRUE;
            registrationToken = [NSString stringWithFormat:@"%@",[response valueForKey:@"registration_token"]];
            [self showActivationCode];
            buzzardRunStatus = 2;
            [self changeRegisterStatus];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:YES];
}

//Show activate code popup
- (void)showActivationCode{
    [registerConfirmPopup dismiss:YES];
    activationCode.subTitle.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(SHOW_ACTIVATION_CODE,nil), registrationToken];
    [activationCodePopup show];
}

-(void)changeTabColor:(int)tab
{
    if (tab == 1) {
        _generalTab.backgroundColor = UIColorFromHexCode(THEME_COLOR);
        _eventsTab.backgroundColor = [UIColor clearColor];
    }
    else{
         _eventsTab.backgroundColor = UIColorFromHexCode(THEME_COLOR);
        _generalTab.backgroundColor = [UIColor clearColor];
    }
    
    [_eventsTable reloadData];
    [self addEmptyMessageForEventList:tab];
}

//Add empty message in table background view
- (void)addEmptyMessageForEventList:(int)tab{
    if (tab == 1) {
        _eventsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else{
        if ([eventList count] == 0) {
            [Util addEmptyMessageToTableWithHeader:_eventsTable withMessage:NO_EVENTS_AVAILABLE withColor:[UIColor whiteColor]];
        }
        else{
            [_eventsTable.tableFooterView removeFromSuperview];
            [Util addEmptyMessageToTableWithHeader:_eventsTable withMessage:@"" withColor:[UIColor whiteColor]];
        }
    }
}

#pragma args UITableView Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (selectedTab == 1)
    {
        return 1;
    }
    else
    {
        return [eventList count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;    
    
    if (selectedTab == 1)
    {
        static NSString *cellIdentifier = @"generalCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.backgroundColor = [UIColor clearColor];
    
        //UILabel *description = (UILabel *) [cell viewWithTag:10];
        UITextView *instructionsView = (UITextView *) [cell viewWithTag:15];
        UIWebView *instructionsWebView = (UIWebView *) [cell viewWithTag:16];
        
        if (instructions != nil) {
            
            NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithData:[instructions dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"CenturyGothic" size:15], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName, nil];            
            [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString.string length] - 1)];
            instructionsView.attributedText = attributedString;
            instructionsView.editable = NO;
            CGRect newFrame = instructionsView.frame;
            newFrame.size.height = 250;
            instructionsView.frame = newFrame;            
            [instructionsWebView loadHTMLString:instructions baseURL:nil];
            instructionsWebView.backgroundColor = [UIColor blackColor];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"eventsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UILabel *sno = (UILabel *) [cell viewWithTag:1];
        UILabel *name =  (UILabel *)[cell viewWithTag:10];
        UIView *statusView = (UIView *) [cell viewWithTag:11];
        UIImageView *plus = (UIImageView *) [cell viewWithTag:12];
        UIButton *status = (UIButton *) [cell viewWithTag:13];
        
        [Util createRoundedCorener:statusView withCorner:3.0];
        
        NSDictionary *event  = [eventList objectAtIndex:indexPath.row];
        
        sno.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
        name.text = [event valueForKey:@"name"];
        
        //Hide the status view if can_participate_in_bazzardrun is false
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"can_participate_in_bazzardrun"]){
            statusView.hidden = YES;
        }
        
        status.userInteractionEnabled = FALSE;        
        
        int statusFlag = [[event valueForKey:@"event_status"] intValue];
        if (statusFlag == 1) { //New
            [status setTitle:NSLocalizedString(NEW, nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor blackColor]];
            [plus setImage:[UIImage imageNamed: @"buzzardrun.png"]];
            [Util createBorder:statusView withColor:UIColorFromHexCode(THEME_COLOR)];
        }
        else if(statusFlag == 2){ //In Progress
            [status setTitle:NSLocalizedString(IN_PROGRESS, nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:[UIColor grayColor]];
            [plus setImage:[UIImage imageNamed: @"inprogress.png"]];
            [Util createBorder:statusView withColor:[UIColor grayColor]];
        }
        else if(statusFlag == 3){ //Submitted
            [status setTitle:NSLocalizedString(SUBMITTED, nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:UIColorFromHexCode(THEME_COLOR)];
            [plus setImage:[UIImage imageNamed: @"invited.png"]];
        }
        else if(statusFlag == 4){ ///Completed
            [status setTitle:NSLocalizedString(COMPLETED, nil) forState:UIControlStateNormal];
            [statusView setBackgroundColor:UIColorFromHexCode(THEME_COLOR)];
            [plus setImage:[UIImage imageNamed: @"friendsTick.png"]];
        }
        
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (selectedTab == 1) {
        
    }
    else
    {
        NSDictionary *event  = [eventList objectAtIndex:indexPath.row];
        int statusFlag = [[event valueForKey:@"event_status"] intValue];

        PostBuzzardRun *post = [self.storyboard instantiateViewControllerWithIdentifier:@"PostBuzzardRun"];
        post.buzzardRunEventId = [NSString stringWithFormat:@"%@",[event objectForKey:@"id"]];
        post.buzzardRunName = buzzardRunName;
        post.buzzardRunId = _buzzardRunId;
        post.shopName = [event objectForKey:@"shop_name"];
        post.eventName = [event valueForKey:@"name"];
        post.canShowPost = statusFlag > 1 ? @"YES" : @"NO";
        [self.navigationController pushViewController:post animated:YES];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    if (selectedTab == 1)
    {
        return 400;
    }
    else{
        return UITableViewAutomaticDimension;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedTab == 1)
    {
        return 400;
    }
    else{
        return UITableViewAutomaticDimension;
    }
}

#pragma args - YesNoPopup delegates
- (void)onYesClick{
    [self registerForBuzzardRun];
}
- (void)onNoClick{
    [registerConfirmPopup dismiss:YES];
}
- (void)onButtonClick{
    
    [activationCodePopup dismiss:YES];
    
    //Check user has denied the notifications
    if (![Util checkoutNotificationStatus]) {
        
        //Reload the view
        eventList = [[NSMutableArray alloc] init];
        shopLocation = [[NSMutableDictionary alloc] init];
        [self getBuzzardRunDetails:FALSE];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"isBuzzardRunStatusChanged"];
    }
    
}

@end
