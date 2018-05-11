//
//  ChangePassword.m
//  Varial
//
//  Created by jagan on 30/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ChangePassword.h"
#import "IQUIView+IQKeyboardToolbar.h"
@interface ChangePassword ()

@end

@implementation ChangePassword
KLCPopupLayout layout;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    textFields = [[NSArray alloc] initWithObjects:_setEmail,_password,_setConfirmPassword,_oldPassword,_nePassword, _confirmPassword, nil];
    [self designTheView];
    [self createPopUpWindows];
    [self getLoginStatus];
    
    //Register for set email notifacation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setEmailNotification:) name:@"SetEmailNotification" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
    
    [_confirmPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_setConfirmPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    visibleWindow=1;
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SetEmailNotification" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ConfirmEmailNotification" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self resetChangePasswordForm];
}

/*! doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton
{
    if(visibleWindow==1)
        [self changePasswordRequest];
    if(visibleWindow==2)
        [self emailActionRequest];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Need to show setEmail popup
- (void)setEmailNotification:(NSNotification*)note {

    [emailNotification dismiss:YES];
    [_setEmailView setHidden:NO];
    [setEmailPopup showWithLayout:layout];
    visibleWindow=2;
}

-(void) emailConfirmed:(NSNotification *) data{
       
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    [emailConfirmationPopup dismiss:YES];
    [self getLoginStatus];
    [[AlertMessage sharedInstance] showMessage:[[notificationContent objectForKey:@"data"] valueForKey:@"message"] withDuration:3];
}

- (void) viewDidUnload{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ConfirmEmailNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CancelEmailNotification" object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//Get login status to check for email 
-(void) getLoginStatus{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PLAYER_LOGIN_STATUS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            NSDictionary *status = [response objectForKey:@"player_login_status"];
            
            //Ask for email to set first
            if(![[status valueForKey:@"email_status"] boolValue]){
                [emailNotification show];
            }
            else{
                [Util setInDefaults:[status valueForKey:@"email_status"] withKey:@"havingEmail"];
            }
        }
    } isShowLoader:YES];
}


-(void) designTheView{
    
    for (UITextField *field in textFields){
        [Util createBottomLine:field withColor:UIColorFromHexCode(TEXT_BORDER)];
    }
    [Util createRoundedCorener:_setEmailView withCorner:5];
    [Util createRoundedCorener:_saveEmailButton withCorner:3];
    [Util createRoundedCorener:_cancelEmailButton withCorner:3];
    [Util createRoundedCorener:_changePasswordButton withCorner:3];
    
    [_header.logo setHidden:YES];
    [_header setHeader:NSLocalizedString(PASSWORD, nil)];
}


- (void) createPopUpWindows{
    
    setEmailPopup = [KLCPopup popupWithContentView:self.setEmailView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    setEmailPopup.didFinishShowingCompletion = ^{
        [_setEmail becomeFirstResponder];
    };
    
    //Email set confirmation popup
    NetworkAlert *notification = [[NetworkAlert alloc] init];
    [notification setNetworkHeader:NSLocalizedString(NOTIFICATION, nil)];
    notification.subTitle.text = NSLocalizedString(SET_EMAIL_TO_CHANGE_PASSWORD, nil);
    [notification.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    notification.button.tag = 100;
    
     emailNotification = [KLCPopup popupWithContentView:notification showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    
}



//create an alert notification
-(void) createAlertNotification: (NSString *) message{
    
    NetworkAlert *emailConfirmation = [[NetworkAlert alloc] init];
    [emailConfirmation setNetworkHeader:NSLocalizedString(WAITING_FOR_CONFIRMATION, nil)];
    emailConfirmation.subTitle.text = message;
    [emailConfirmation.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    emailConfirmation.button.tag = 102;
    
    emailConfirmationPopup = [KLCPopup popupWithContentView:emailConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];

    [setEmailPopup dismiss:YES];
    [emailConfirmationPopup show];
    
}

//Cancel the email change request
- (void)cancelEmailNotification:(NSNotification*)note {
    
    [emailConfirmationPopup dismiss:YES];
    //Build Input Parameters
    /*NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"1" forKey:@"is_email"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CANCEL_EMAIL withCallBack:^(NSDictionary * response){
        
        [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        
        if([[response valueForKey:@"status"] boolValue]){
            [emailConfirmationPopup dismiss:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } isShowLoader:YES];
    */
}

- (IBAction)setEmailAction:(id)sender {
    [self emailActionRequest];
}
-(void)emailActionRequest{
    if ([self setEmailValidation]) {
        NSLog(@"Success");
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_setEmail.text forKey:@"email"];
        [inputParams setValue:_password.text forKey:@"password"];
        [inputParams setValue:_setConfirmPassword.text forKey:@"confirm_password"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_EMAIL_API withCallBack:^(NSDictionary * response){
            //success case
            if([[response valueForKey:@"status"] boolValue]){
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelEmailNotification:) name:@"CancelEmailNotification" object:nil];
                
                //clear the email contents
                [self clearSetEmailView];
                [self createAlertNotification:[response valueForKey:@"message"]];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
                [_setConfirmPassword resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }

}

- (IBAction)cancelSetEmail:(id)sender {
    [setEmailPopup dismiss:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

//Change password API Access
- (IBAction)changePassword:(id)sender {
    [self changePasswordRequest];

}
-(void)changePasswordRequest{
    if ([self changpasswordValidation]) {
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_oldPassword.text forKey:@"old_password"];
        [inputParams setValue:_nePassword.text forKey:@"new_password"];
        [inputParams setValue:_confirmPassword.text forKey:@"confirm_password"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CHANGE_PASSWORD_API withCallBack:^(NSDictionary * response){
            //success case
            if([[response valueForKey:@"status"] boolValue]){
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
                [self clearPasswordResetView];
                [self resetChangePasswordForm];
                [_confirmPassword resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
    }
}

//Reset Password Reset screen
- (void) clearPasswordResetView {
    _oldPassword.text = @"";
    _nePassword.text = @"";
    _confirmPassword.text = @"";
}

- (void) clearSetEmailView {
    _setEmail.text = @"";
    _password.text = @"";
    _setConfirmPassword.text = @"";
}


//Form validations
//set Email validation
-(BOOL) setEmailValidation{
    [self resetSetEmailWindow];
    
    //Validate email
    if(![Util validateTextField:_setEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    //Validate password
    else if(![Util validatePasswordField:_password withValueToDisplay:PASSWORD withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX]){
        return FALSE;
    }
    // Validation Password continue empty spaces
    if ([[_password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_password withErrorMessage:NSLocalizedString(CONTINUE_WHITESPACES, nil)];
        return FALSE;
    }
    //Check confirm password is empty
    else if([_setConfirmPassword.text length] == 0)
    {
        [Util showErrorMessage:_setConfirmPassword withErrorMessage:NSLocalizedString(CONFIRM_EMPTY, nil)];
        return FALSE;
    }
    //Validation to match password
    if(![_setConfirmPassword.text isEqualToString:_password.text]){
        
        //add border to validated fields
        [Util createBottomLine:_password withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util createBottomLine:_confirmPassword withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util showErrorMessage:_confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_MISMATCH, nil)];
        return FALSE;
    }    
    return YES;
}

-(void) resetSetEmailWindow{
    [Util createBottomLine:_setEmail withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_password withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_setConfirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}

//Change paassword validations
-(BOOL)changpasswordValidation{
    //Check old password is empty
    [self resetChangePasswordForm];
    if([_oldPassword.text length] == 0)
    {
        [Util showErrorMessage:_oldPassword withErrorMessage:NSLocalizedString(OLD_PASSWORD_EMPTY, nil)];
        return FALSE;
    }
    //Validate password
    else if(![Util validatePasswordField:_nePassword withValueToDisplay:NEW_PASSWORD withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX]){
        return FALSE;
    }   
    // Validation Password continue empty spaces
    if ([[_nePassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_nePassword withErrorMessage:NSLocalizedString(CONTINUE_WHITESPACES, nil)];
        return FALSE;
    }
    //Check confirm password is empty
    else if([_confirmPassword.text length] == 0)
    {
        [Util showErrorMessage:_confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_EMPTY, nil)];
        return FALSE;
    }
    //Validation to match password
    if(![_confirmPassword.text isEqualToString:_nePassword.text]){
        
        //add border to validated fields
        [Util createBottomLine:_nePassword withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util createBottomLine:_confirmPassword withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util showErrorMessage:_confirmPassword withErrorMessage:NSLocalizedString(NEW_CONFIRM_MISMATCH, nil)];
        return FALSE;
    }
    return YES;
}

-(void)resetChangePasswordForm{
    [Util createBottomLine:_oldPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_nePassword withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_confirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}



@end
