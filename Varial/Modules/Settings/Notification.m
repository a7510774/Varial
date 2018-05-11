//
//  Notification.m
//  Varial
//
//  Created by Shanmuga priya on 3/4/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Notification.h"
#import "IQUIView+IQKeyboardToolbar.h"
@interface Notification ()

@end

@implementation Notification

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self designTheView];
    [self createPopUpWindows];
    [self getNotificationStatus];
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)designTheView{
    
    [_headerView setHeader:NSLocalizedString(NOTIFICATIONS, nil)];

    [_headerView.logo setHidden:YES];
}

- (void) createPopUpWindows{
    
    networkAlert=[[NetworkAlert alloc]init];
    [networkAlert setDelegate:self];
    [networkAlert.button setTitle:@"OK" forState:UIControlStateNormal];
    [networkAlert setNetworkHeader:NSLocalizedString(EMAIL_NOT_FOUND, nil)];
    networkAlert.subTitle.text = NSLocalizedString(SET_EMAIL,nil);
    KLCNetworkPopup = [KLCPopup popupWithContentView:networkAlert showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    setEmail=[[SetEmailPopup alloc]init];
    [setEmail.confirmPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [setEmail setDelegate:self];
    KLCSetEmail = [KLCPopup popupWithContentView:setEmail showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    KLCSetEmail.didFinishShowingCompletion = ^{
        [setEmail.emailID becomeFirstResponder];
    };
}

-(void)doneAction:(UIBarButtonItem*)barButton
{
    [self saveRequest];
}

-(void)getNotificationStatus{
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:VIEW_NOTIFICATION withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            NSDictionary *details=[[NSDictionary alloc]init];
            details = [response objectForKey:@"player_notification_status"];
            if([[details valueForKey:@"push_notification"] boolValue])
                [_pushSwitch setOn:YES animated:YES];
            if([[details valueForKey:@"email_notification"] boolValue])
                [_emailSwitch setOn:YES animated:YES];
            pushStatus=[[details valueForKey:@"push_notification"] boolValue];
            emailStatus=[[details valueForKey:@"email_notification"] boolValue];
            
        }
    } isShowLoader:YES];
}

-(void)onButtonClick{
    
    if(!emailPop){
        [KLCNetworkPopup dismiss:YES];
        [KLCSetEmail showWithLayout:layout];
    }
    else
    {
        [_emailSwitch setOn:NO animated:YES];
        
        [emailConfirmationPopup dismiss:YES];

        //Build Input Parameters
        /*NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:@"1" forKey:@"is_email"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CANCEL_EMAIL withCallBack:^(NSDictionary * response){
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            
            if([[response valueForKey:@"status"] boolValue]){
                [emailConfirmationPopup dismiss:YES];
            }
            
        } isShowLoader:YES];*/
    }
    
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
//---------------> Update Notification <-------------------//
- (IBAction)changeEmailSwitch:(id)sender {
    
    if([sender isOn]){
        emailStatus=TRUE;
        [self getPlayerLoginStatus];
    }
    else{
        emailStatus=FALSE;
        [self updateNotificationStatus];
    }
}

- (IBAction)changePushSwitch:(id)sender {
    if([sender isOn])
        pushStatus=TRUE;
    else
        pushStatus=FALSE;
     [self updateNotificationStatus];
}

//change notification status
-(void)updateNotificationStatus{
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:pushStatus ? @"1" : @"0" forKey:@"push_notification_status"];
    [inputParams setValue:emailStatus ? @"1" : @"0"  forKey:@"email_notification_status"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:UPDATE_NOTIFICATION withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:NO];
    
}
//----------------> Update Notification ends<---------------//

//------------> Set email  <----------------
//check for email in player login status
-(void)getPlayerLoginStatus{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PLAYER_LOGIN_STATUS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            NSDictionary *details=[[NSDictionary alloc]init];
            details = [response objectForKey:@"player_login_status"];
            
            if(![[details objectForKey:@"email_status"] boolValue]){
                
                [KLCNetworkPopup show];
            }
            else{
                [self updateNotificationStatus];
            }
        }
    } isShowLoader:YES];
}

- (void)onSaveClick{
    [self saveRequest];
}

//set email for player
-(void)saveRequest{
    emailPop=TRUE;
    if ([self setEmailValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:setEmail.emailID.text forKey:@"email"];
        [inputParams setValue:setEmail.password.text forKey:@"password"];
        [inputParams setValue:setEmail.confirmPassword.text forKey:@"confirm_password"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_EMAIL_API withCallBack:^(NSDictionary * response){
            //success case
            if([[response valueForKey:@"status"] boolValue]){
                [KLCSetEmail dismiss:YES];
                [self showEmailConfirmationPopup:[response valueForKey:@"message"]];
                [emailConfirmationPopup show];
                [self updateNotificationStatus];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
                
                [setEmail.confirmPassword resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
}

//set Email validation
-(BOOL) setEmailValidation{
    [self resetSetEmailWindow];
    
    //Validate email
    if(![Util validateTextField:setEmail.emailID withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    //Validate password
    else if(![Util validatePasswordField:setEmail.password withValueToDisplay:@"Password" withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX]){
        return FALSE;
    }
    // Validation Password continue empty spaces
    if ([[setEmail.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:setEmail.confirmPassword withErrorMessage:NSLocalizedString(CONTINUE_WHITESPACES, nil)];
        
        return FALSE;
    }
    //Check confirm password is empty
    else if([setEmail.confirmPassword.text length] == 0)
    {
        [Util showErrorMessage:setEmail.confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_EMPTY, nil)];
        return FALSE;
    }
    //Validation to match password
    if(![setEmail.confirmPassword.text isEqualToString:setEmail.password.text]){
        
        //add border to validated fields
        [Util createBottomLine:setEmail.password withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util createBottomLine:setEmail.confirmPassword withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util showErrorMessage:setEmail.confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_MISMATCH, nil)];
        return FALSE;
    }
    
    return YES;
}
-(void) resetSetEmailWindow{
    [Util createBottomLine:setEmail.emailID withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:setEmail.password withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:setEmail.confirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}

-(void)onCancelClick{
    [KLCSetEmail dismiss:YES];
    [_emailSwitch setOn:NO animated:YES];
}

- (void)showEmailConfirmationPopup:(NSString *)message{
    
    emailConfirmation = [[NetworkAlert alloc] init];
    [emailConfirmation setNetworkHeader:NSLocalizedString(WAITING_FOR_CONFIRMATION, nil)];
    emailConfirmation.subTitle.text = message;
    [emailConfirmation.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    emailConfirmation.delegate = self;
    
    emailConfirmationPopup = [KLCPopup popupWithContentView:emailConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
}

-(void) emailConfirmed:(NSNotification *) data{
    
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    [emailConfirmationPopup dismiss:YES];
    [self getPlayerLoginStatus];
    [[AlertMessage sharedInstance] showMessage:[[notificationContent objectForKey:@"data"] valueForKey:@"message"] withDuration:3];
}
//------------> Set email ends <----------------

@end

