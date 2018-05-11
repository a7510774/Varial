//
//  ClubPromotionsDetails.m
//  Varial
//
//  Created by jagan on 29/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ClubPromotionsDetails.h"
#import "OpenInGoogleMapsController.h"

@interface ClubPromotionsDetails ()

@end

@implementation ClubPromotionsDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    shopLocation = [[NSMutableDictionary alloc] init];
    [self designTheView];
 //   isRegistered = FALSE;
    [self getClubPromotionsDetails:TRUE];
    [self createPopupWindows];
    //Register for the notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeClubPromotionStatus:) name:@"GeneralNotification" object:nil];
}

- (void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeneralNotification" object:nil];
}

//change notification count
-(void) changeClubPromotionStatus:(NSNotification *) data{
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    NSDictionary *body = [notificationContent objectForKey:@"data"];
    if ([[notificationContent objectForKey:@"type"] isEqualToString:@"general_notification"]) {
        if ([[body valueForKey:@"redirection_type"] intValue] == 16) {
            [activationCodePopup dismiss:YES];
            [_registerButton setBackgroundImage:[UIImage imageNamed:@"invitedTick.png"] forState:UIControlStateNormal];
            _registerLabel.text = NSLocalizedString(COMPLETED, nil);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView
{
    [_headerView setHeader:NSLocalizedString(CLUB_PROMOTION_DETAILS, nil)];

    [_headerView.logo setHidden:YES];
    
    //Hide the register button if can_participate_in_clubpromotion is false
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"can_participate_in_clubpromotion"]){
        _registerButton.hidden = YES;
        _registerLabel.hidden = YES;
    }
    
    [Util createBorder:_generalButton withColor:UIColorFromHexCode(THEME_COLOR)];    
   
}

//Get club promotion details
- (void)getClubPromotionsDetails:(BOOL)showLoader{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:_promotionId forKey:@"club_promotion_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CLUB_PROMOTIONS_DETAILS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            mediaBase = [response objectForKey:@"media_base_url"];
            [self bindTheDetails:[[response objectForKey:@"club_promotion_details"] mutableCopy]];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            [self hideView];
        }
        
    } isShowLoader:showLoader];
}
-(void)hideView
{
     NSArray *subviews = [self.view subviews];
    NSLog(@"Array Views: %@",subviews);
    
    for (int i=0; i<[subviews count]; i++) {
        if (i== 1 || i== 6 || i== 7)  {
            
        }
        else{
          [[subviews objectAtIndex:i] removeFromSuperview];
        }
    }
}

//Create popup windows
- (void)createPopupWindows{
    
    //Alert popup
    registerConfirm = [[YesNoPopup alloc] init];
    registerConfirm.delegate = self;
    [registerConfirm setPopupHeader:NSLocalizedString(CLUB_PROMOTION, nil)];
    registerConfirm.message.text = NSLocalizedString(WANT_TO_REGISTER, nil);
    [registerConfirm.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [registerConfirm.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    registerConfirmPopup = [KLCPopup popupWithContentView:registerConfirm showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    //Activation code popup
    activationCode = [[NetworkAlert alloc] init];
    [activationCode setNetworkHeader:NSLocalizedString(ACTIVATION_CODE, nil)];
    [activationCode.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    activationCode.delegate = self;
    
    activationCodePopup = [KLCPopup popupWithContentView:activationCode showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    //Free Bies popup
    freeBies = [[NetworkAlert alloc] init];
    [freeBies setNetworkHeader:NSLocalizedString(@"FreeBies", nil)];
    [freeBies.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    freeBies.delegate = self;
    
    [freeBies.title hideByHeight:YES];
    
    freeBiesPopup = [KLCPopup popupWithContentView:freeBies showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];

}

//Bind the buzzard details
- (void)bindTheDetails:(NSMutableDictionary *)details{
    
    //Bind The Image
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[details valueForKey:@"shop_image"]];
    [_profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
    [[Util sharedInstance] addImageZoom:_profileImage];
    
    _name.text = [details valueForKey:@"club_promotion_name"];
    _subName.text = [details valueForKey:@"shop_name"];
    _address.text = [details valueForKey:@"club_promotion_address"];
    [_subName sizeToFit];
    [_address sizeToFit];
    
    //Assign the co-ordinate
    [shopLocation setValue:[details valueForKey:@"latitude"]  forKey:@"latitude"];
    [shopLocation setValue:[details valueForKey:@"longitude"]  forKey:@"longitude"];
    [shopLocation setValue:[details valueForKey:@"shop_name"]  forKey:@"name"];
    [shopLocation setValue:[details valueForKey:@"club_promotion_address"]  forKey:@"subTitle"];
    
    _points.text = NSLocalizedString(@"FreeBies", nil);
   // _generalInformation.text = [details valueForKey:@"instructions"];
    //isRegistered = [[details valueForKey:@"is_registered"] boolValue];
    registeredStatus = [[details valueForKey:@"player_club_promotion_status"] intValue];
    registrationToken = [NSString stringWithFormat:@"%@",[details valueForKey:@"registration_token"]];
    freeBies.subTitle.text = [details valueForKey:@"free_bies"];
    [_informationView loadHTMLString:[details valueForKey:@"instructions"] baseURL:nil];
    _informationView.backgroundColor = [UIColor blackColor];
    [self changeRegisterStatus];
    
}

//Change register button status after register the buzzardRun
- (void)changeRegisterStatus{
    if (registeredStatus == 1) {
        [_registerButton setBackgroundImage:[UIImage imageNamed:@"Register.png"] forState:UIControlStateNormal];
        _registerLabel.text = NSLocalizedString(REGISTER, nil);
    }
    else if (registeredStatus == 2) {
        [_registerButton setBackgroundImage:[UIImage imageNamed:@"invitedTick.png"] forState:UIControlStateNormal];
        _registerLabel.text = NSLocalizedString(REGISTERED, nil);
    }
    else{
        [_registerButton setBackgroundImage:[UIImage imageNamed:@"friendsIcon.png"] forState:UIControlStateNormal];
        _registerLabel.text = NSLocalizedString(COMPLETED, nil);
    }
}


//Show registration token or send confirm registration popup
- (IBAction)registerBuzzardRun:(id)sender {
    if (registeredStatus == 1) {
        //Need to register
        [registerConfirmPopup show];
    }
    else if (registeredStatus == 2){
        //Show registration token
        [self showActivationCode];
    }
}

//Get direction between current location and shop location
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
        getDirections.isFrom = @"ClubPromotions";
        [self.navigationController pushViewController:getDirections animated:YES];
    }
}

//Register for buzzard if not registered
- (void)registerForBuzzardRun{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:_promotionId forKey:@"club_promotion_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:REGISTER_CLUB_PROMOTION withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
           // isRegistered = TRUE;
            registeredStatus = 2;
            registrationToken = [NSString stringWithFormat:@"%ld",[[response valueForKey:@"registration_token"] longValue]];
            [self showActivationCode];
            [self changeRegisterStatus];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}

//Show activate code popup
- (void)showActivationCode{
    [registerConfirmPopup dismiss:YES];
    activationCode.subTitle.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(SHOW_ACTIVATION_CODE_CLUB_PROMOTIONS,nil),registrationToken];
    [activationCodePopup show];
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
    [freeBiesPopup dismiss:YES];
    //Check user has denied the notifications
    if (![Util checkoutNotificationStatus]) {
        [self getClubPromotionsDetails:FALSE];
    }
}

//Show free bies
- (IBAction)showFreeBies:(id)sender {
    [freeBiesPopup show];
}

@end
