//
//  LoginOptions.m
//  Varial
//
//  Created by jagan on 30/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "LoginOptions.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "Util.h"

@interface LoginOptions ()


@end

@implementation LoginOptions

- (void)viewWillAppear:(BOOL)animated {
    
    if (_gIsPresentSettingsScreen) {
        
        _gIsPresentSettingsScreen = NO;
        [_emailButton setTitle:NSLocalizedString(CHANGE_EMAIL_ID, nil) forState:UIControlStateNormal];
        [_phoneButton setTitle:NSLocalizedString(SET_NUMBER, nil) forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    textFields = [[NSArray alloc] initWithObjects:_setEmail,_password,_confirmPassword,_otpCode,_country,_countryCode,_mobileNumber,_changeEmail,_oldCountryCode,_oldPhoneNumber,_neCountryCode,_nePhoneNumber,_changeCountry, nil];
    
    countries = [[NSMutableArray alloc] init];
    
    [self designTheView];
    [self createPopUpWindows];
    [self getCountryList];
    [self getLoginStatus];
    
    [_header.logo setHidden:YES];
    [_header setHeader:NSLocalizedString(LOGIN_OPTIONS, nil)];
    
    havingEmail = FALSE;
    havingPhoneNumber = FALSE;
    
    //Register for set email notifacation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelEmailNotification:) name:@"CancelEmailNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
    [_confirmPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_changeEmail addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_mobileNumber addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_nePhoneNumber addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_otpCode addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
}

-(void)doneAction:(UIBarButtonItem*)barButton
{
    if(visibleWindow==1)
        [self setEmailRequest];
    if(visibleWindow==2)
        [self changeEmailRequest];
    if(visibleWindow==3)
        [self setPhoneNumberRequest];
    if(visibleWindow==4)
        [self changePhoneNumberRequest];
    if(visibleWindow==5)
        [self submitOTPRequest];
    
}


-(void) emailConfirmed:(NSNotification *) data{
    
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    [emailConfirmationPopup dismiss:YES];
    [self getLoginStatus];
    [[AlertMessage sharedInstance] showMessage:[[notificationContent objectForKey:@"data"] valueForKey:@"message"] withDuration:3];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ConfirmEmailNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CancelEmailNotification" object:nil];
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
     }
     
     } isShowLoader:YES];*/
    
}


//Get countries list
-(void) getCountryList{
    
    //Send forgot request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:COUNTRY_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            [countries addObjectsFromArray:[response objectForKey:@"country_list"]];
        }
    } isShowLoader:YES];
    
}

//Change the oldPhoneNumber placeholder
- (void) changePlaceHolder:(NSString *)oldNo andCountry:(NSString *) country{
    [_oldPhoneNumber setValue:oldNo forKeyPath:@"_placeholderLabel.text"];
    [_oldCountryCode setValue:country forKeyPath:@"_placeholderLabel.text"];
    
}

//Get login status to check for email
-(void) getLoginStatus{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PLAYER_LOGIN_STATUS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            NSDictionary *status = [response objectForKey:@"player_login_status"];
            
            havingEmail = [[status valueForKey:@"email_status"] boolValue];
            havingPhoneNumber = [[status valueForKey:@"phone_status"] boolValue];
            
            //Change email button title
            if(havingEmail){
                [_emailButton setTitle:NSLocalizedString(CHANGE_EMAIL_ID, nil) forState:UIControlStateNormal];
            }
            else{
                [_emailButton setTitle:NSLocalizedString(SET_EMAILID_STRING, nil) forState:UIControlStateNormal];
            }
            
            //Change phone button title
            if(havingPhoneNumber){
                [_phoneButton setTitle:NSLocalizedString(CHANGE_NUMBER, nil) forState:UIControlStateNormal];
                oldCounCode = [status valueForKey:@"country_code_pin"];
                oldPhNo = [status valueForKey:@"format_phone_number"];
                oldCountryId = [status valueForKey:@"country_code"];
                [self changePlaceHolder:oldPhNo andCountry:oldCounCode];
            }
            else{
                [_phoneButton setTitle:NSLocalizedString(SET_NUMBER, nil) forState:UIControlStateNormal];
            }
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

-(void) designTheView{
    
    for (UITextField *field in textFields){
        [Util createBottomLine:field withColor:UIColorFromHexCode(TEXT_BORDER)];
    }
    [Util createRoundedCorener:_setEmailView withCorner:5];
    [Util createRoundedCorener:_saveEmailButton withCorner:3];
    [Util createRoundedCorener:_cancelEmailButton withCorner:3];
    
    [Util createRoundedCorener:_otpView withCorner:5];
    [Util createRoundedCorener:_otpSubmitButton withCorner:3];
    [Util createRoundedCorener:_otpResendButton withCorner:3];
    [Util createRoundedCorener:_otpCancelButton withCorner:3];
    
    [Util createRoundedCorener:_phoneNumberView withCorner:5];
    [Util createRoundedCorener:_savePhoneNumberButton withCorner:3];
    [Util createRoundedCorener:_cancelSetPhoneWindow withCorner:3];
    
    [Util createRoundedCorener:_changeEmailView withCorner:5];
    [Util createRoundedCorener:_closeEmailButton withCorner:3];
    [Util createRoundedCorener:_changeEmailButton withCorner:3];
    
    
    [Util createRoundedCorener:_changePhoneView withCorner:5];
    [Util createRoundedCorener:_changePhoneSaveButton withCorner:3];
    [Util createRoundedCorener:_closeChangePhoneButton withCorner:3];
    
    
    //Set country field input type to UIPickerview
    countryPicker = [[UIPickerView alloc] init];
    countryPicker.delegate = self;
    countryPicker.dataSource = self;
    countryPicker.showsSelectionIndicator = YES;
    countryPicker.frame = CGRectMake(0, self.view.frame.size.height-
                                     countryPicker.frame.size.height-50, 320, 230);
    _country.inputView = countryPicker;
    _changeCountry.inputView = countryPicker;
    
    _otpCode.delegate = self;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _otpCode) {
        return textField.text.length + (string.length - range.length) <= OTP_MAX;
    }
    return YES;
}


- (void) createPopUpWindows{
    
    setEmailPopup = [KLCPopup popupWithContentView:self.setEmailView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    setEmailPopup.didFinishShowingCompletion = ^{
        [_setEmail becomeFirstResponder];
    };
    
    setPhonePopup = [KLCPopup popupWithContentView:self.phoneNumberView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    
    otpPopup = [KLCPopup popupWithContentView:self.otpView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    otpPopup.didFinishShowingCompletion = ^{
        [_otpCode becomeFirstResponder];
    };

    
    changeEmailPopup = [KLCPopup popupWithContentView:self.changeEmailView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    changeEmailPopup.didFinishShowingCompletion = ^{
        [_changeEmail becomeFirstResponder];
    };

    
    changePhonePopup = [KLCPopup popupWithContentView:self.changePhoneView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    changePhonePopup.didFinishShowingCompletion = ^{
        [_oldPhoneNumber becomeFirstResponder];

        int index = [self findCountryIndexByCode:oldCounCode];
        if( index != -1)
        {
            if ([countries count] > index) {
                [self pickerView:countryPicker didSelectRow:index inComponent:0];
            }
        }
    };
    
}


- (IBAction)openPhoneWindow:(id)sender {
    
    if (havingPhoneNumber) {
        [self.changePhoneView setHidden:NO];
        [changePhonePopup showWithLayout:layout];
        visibleWindow=4;
        
    }else{
        [self.phoneNumberView setHidden:NO];
        [setPhonePopup showWithLayout:layout];
        visibleWindow=3;
        
        // Auto populate the county picker
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_country sendActionsForControlEvents:UIControlEventEditingDidBegin];
            [_country becomeFirstResponder];
        });
        
    }
}

- (IBAction)openEmailWindow:(id)sender {
    
        if (havingEmail) {
            [self.changeEmailView setHidden:NO];
            [changeEmailPopup showWithLayout:layout];
            visibleWindow=2;
        }else{
            [self.setEmailView setHidden:NO];
            [setEmailPopup showWithLayout:layout];
            visibleWindow=1;
        }

}

//Create email confirmation popup
- (void)showEmailConfirmationPopup:(NSString *)message{
    
    emailConfirmation = [[NetworkAlert alloc] init];
    [emailConfirmation setNetworkHeader:NSLocalizedString(WAITING_FOR_CONFIRMATION, nil)];
    emailConfirmation.subTitle.text = message;
    [emailConfirmation.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    emailConfirmation.button.tag = 102;
    
    emailConfirmationPopup = [KLCPopup popupWithContentView:emailConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
}


#pragma mark - Picker View Data source
//set number of components to select
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//set number of rows for the picker
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [countries count];
}


#pragma mark- Picker View Delegate
//track the selected picker data
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if ([countries count] > row) {
        NSDictionary *country = [countries objectAtIndex:row];
        [_country setText:[country objectForKey:@"country_name"]];
        [_countryCode setText:[country valueForKey:@"country_pin_code"]];
        
        [_changeCountry setText:[country objectForKey:@"country_name"]];
        [_neCountryCode setText:[country valueForKey:@"country_pin_code"]];
        
        countryId = [country valueForKey:@"country_id"];
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *country;
    if ([countries count] > row) {
        country = [countries objectAtIndex:row];
    }
    return [country objectForKey:@"country_name"];
    
}
//** End of Picker View Deleage **/

//Change the current screen
- (void)moveToHomeScreen{
    
    UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigation;
}



//------------> Change Phone number <----------------

- (IBAction)changePhoneNumber:(id)sender {
    [self changePhoneNumberRequest];
}

-(void)changePhoneNumberRequest{
    if ([self changePhoneNumberFormValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_oldPhoneNumber.text forKey:@"old_phone_number"];
        [inputParams setValue:_nePhoneNumber.text forKey:@"new_phone_number"];
        [inputParams setValue:oldCountryId forKey:@"old_country_code_id"];
        [inputParams setValue:countryId forKey:@"new_country_code_id"];
        
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CHANE_PHONE_NUMBER withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                
                [changePhonePopup dismiss:YES];
                
                //Show otp window
                [self.otpView setHidden:NO];
                [otpPopup showWithLayout:layout];
                visibleWindow=5;
                
                //change timer and resend button visibitlity
                [_otpResendButton setHidden:YES];
                [_countdownLabel setHidden:NO];
                
                //Set otp time limit
                secondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
                countDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
                
                //Place the OTP as hint
                if(![[response valueForKey:@"view_otp"] boolValue])
                {
                    [_otpCode setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"OTP"] ] forKeyPath:@"_placeholderLabel.text"];
                }
                [_nePhoneNumber resignFirstResponder];
                
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
    
}

- (IBAction)closeChangePhoneWindow:(id)sender {
    [changePhonePopup dismiss:YES];
}

//Set phone number validation
-(BOOL)changePhoneNumberFormValidation{
    [self resetChangePhoneForm];
    
    
    //Check old phone number is empty
    if([[_oldPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_oldPhoneNumber withErrorMessage:NSLocalizedString(OLD_PHONE_EMPTY, nil)];
        return FALSE;
    }
    //Check coutry is choosed
    if([[_changeCountry.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_changeCountry withErrorMessage:NSLocalizedString(COUNTRY_EMPTY, nil)];
        return FALSE;
    }
    //Check new phone number
    //    if([[_nePhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    //    {
    //        [Util showErrorMessage:_nePhoneNumber withErrorMessage:NSLocalizedString(NEW_PHONE_NUMBER_EMPTY, nil)];
    //        return FALSE;
    //    }
    
    if(![Util validateNumberField:_nePhoneNumber withValueToDisplay:NEW_NUMBER withMinLength:PHONE_MIN withMaxLength:PHONE_MAX])
    {
        return FALSE;
    }
    
    return YES;
}

//Reset the phone form
- (void)resetChangePhoneForm{
    [Util createBottomLine:_changeCountry withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_oldPhoneNumber withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_nePhoneNumber withColor:UIColorFromHexCode(TEXT_BORDER)];
    
}

//------------> Change Phone number ends <----------------



//------------> Set email  <----------------

- (IBAction)setEmailAction:(id)sender {
    
    [self setEmailRequest];
}
-(void)setEmailRequest{
    if ([self setEmailValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_setEmail.text forKey:@"email"];
        [inputParams setValue:_password.text forKey:@"password"];
        [inputParams setValue:_confirmPassword.text forKey:@"confirm_password"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_EMAIL_API withCallBack:^(NSDictionary * response){
            //success case
            if([[response valueForKey:@"status"] boolValue]){
                
                [setEmailPopup dismiss:YES];
                [self showEmailConfirmationPopup:[response valueForKey:@"message"]];
                [emailConfirmationPopup show];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
                [_confirmPassword resignFirstResponder];
                
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
}

- (IBAction)cancelSetEmail:(id)sender {
    [setEmailPopup dismiss:YES];
}

//set Email validation
-(BOOL) setEmailValidation{
    [self resetSetEmailWindow];
    
    //Validate email
    if(![Util validateTextField:_setEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    //Validate password
    else if(![Util validatePasswordField:_password withValueToDisplay:@"Password" withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX]){
        return FALSE;
    }
    // Validation Password continue empty spaces
    if ([[_password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_confirmPassword withErrorMessage:NSLocalizedString(CONTINUE_WHITESPACES, nil)];
        
        return FALSE;
    }
    //Check confirm password is empty
    else if([_confirmPassword.text length] == 0)
    {
        [Util showErrorMessage:_confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_EMPTY, nil)];
        return FALSE;
    }
    //Validation to match password
    if(![_confirmPassword.text isEqualToString:_password.text]){
        
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
    [Util createBottomLine:_confirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}


//------------> Set email ends <----------------


//------------> Change email <----------------

- (IBAction)changeEmail:(id)sender {
    [self changeEmailRequest];
}

-(void)changeEmailRequest{
    if ([self changeEmailFormValidation]) {
        
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_changeEmail.text forKey:@"email"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CHANGE_EMAIL withCallBack:^(NSDictionary * response){
            
            
            if([[response valueForKey:@"status"] boolValue]){
                
                [changeEmailPopup dismiss:YES];
                [self showEmailConfirmationPopup:[response valueForKey:@"message"]];
                [emailConfirmationPopup show];
                [_changeEmail resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
}

- (IBAction)closeChangeEmail:(id)sender {
    [changeEmailPopup dismiss:YES];
}


-(BOOL)changeEmailFormValidation{
    [self resetChangeEmailForm];
    
    //Validate email
    if(![Util validateTextField:_changeEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetChangeEmailForm{
    [Util createBottomLine:_changeEmail withColor:UIColorFromHexCode(TEXT_BORDER)];
}


- (IBAction)doTouchCountryField:(id)sender
{
    if ([_country.text isEqualToString:@""]) {
        if ([countries count] > 0) {
            [self pickerView:countryPicker didSelectRow:0 inComponent:0];
        }
        [_country setTextColor:[UIColor blackColor]];
    }
}

//------------> Set phone number <----------------

- (IBAction)setPhoneNumber:(id)sender {
    
    [self setPhoneNumberRequest];
}

-(void)setPhoneNumberRequest{
    if ([self phoneNumberFormValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_mobileNumber.text forKey:@"set_phone_number"];
        [inputParams setValue:countryId forKey:@"country_code_id"];
        
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_PHONE_NUMBER withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                
                
                //Hide the phone popup
                [setPhonePopup dismiss:YES];
                
                //Show OTP popup
                [self.otpView setHidden:NO];
                [otpPopup showWithLayout:layout];
                visibleWindow=5;
                
                //change timer and resend button visibitlity
                [_otpResendButton setHidden:YES];
                [_countdownLabel setHidden:NO];
                
                //Set otp time limit
                secondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
                countDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
                
                //Place the OTP as hint
                if(![[response valueForKey:@"view_otp"] boolValue])
                {
                    [_otpCode setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"OTP"] ] forKeyPath:@"_placeholderLabel.text"];
                }
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            [_mobileNumber resignFirstResponder];
            
        } isShowLoader:YES];
        
    }
    
}
- (IBAction)cancelPhoneWindow:(id)sender {
    [setPhonePopup dismiss:YES];
}


//Set phone number validation
-(BOOL)phoneNumberFormValidation{
    [self resetPhoneForm];
    
    
    //Check coutry is choosed
    if([[_country.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_country withErrorMessage:NSLocalizedString(COUNTRY_EMPTY, nil)];
        return FALSE;
    }
    //Check phone number
    if(![Util validateNumberField:_mobileNumber withValueToDisplay:PHONE_NO withMinLength:PHONE_MIN withMaxLength:PHONE_MAX])
    {
        return FALSE;
    }
    
    //    if([[_mobileNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    //    {
    //        [Util showErrorMessage:_mobileNumber withErrorMessage:NSLocalizedString(PHONE_NUMBER_EMPTY, nil)];
    //        return FALSE;
    //    }
    return YES;
}

//Reset the phone form
- (void)resetPhoneForm{
    [Util createBottomLine:_country withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_countryCode withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_mobileNumber withColor:UIColorFromHexCode(TEXT_BORDER)];
    
}

//------------> Set phone number ends <----------------



//------------> OTP window  <----------------

-(void) updateCountdown {
    
    int minutes, seconds;
    secondsLeft--;
    minutes = (secondsLeft % 3600) / 60;
    seconds = (secondsLeft %3600) % 60;
    if (minutes < 0 ) {
        minutes = 0;
    }
    if (seconds < 0) {
        seconds = 0;
    }
    if (minutes == 0 && seconds == 0) {
        [countDown invalidate];
        countDown = nil;
        [_otpResendButton setHidden:NO];
        [_countdownLabel setHidden:YES];
        [_otpSubmitButton setEnabled:NO];
    }
    _countdownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    if (minutes == 0 && seconds == 0) {
        _countdownLabel.text = @"";
    }
}

- (IBAction)submitOTP:(id)sender {
    [self submitOTPRequest];
}

-(void)submitOTPRequest{
    if ([self otpFormValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_otpCode.text forKey:@"otp_number"];
        [inputParams setValue:countryId forKey:@"country_code_id"];
        
        if (havingPhoneNumber) {
            [inputParams setValue:_nePhoneNumber.text forKey:@"new_phone_number"];
            [_otpCode resignFirstResponder];
        }
        else{
            [inputParams setValue:_mobileNumber.text forKey:@"new_phone_number"];
        }
        
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:VERIFY_OTP withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                //Hide the phone popup
                [otpPopup dismiss:YES];
                
                havingPhoneNumber = TRUE;
                
                [countDown invalidate];
                countDown = nil;
                [_phoneButton setTitle:NSLocalizedString(CHANGE_NUMBER, nil) forState:UIControlStateNormal];
                
                [self getLoginStatus];
            }
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            
            
        } isShowLoader:YES];
    }
    
}

- (IBAction)resendOTP:(id)sender {
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    NSString *url;
    if (havingPhoneNumber) {
        [inputParams setValue:_oldPhoneNumber.text forKey:@"old_phone_number"];
        [inputParams setValue:_nePhoneNumber.text forKey:@"new_phone_number"];
        [inputParams setValue:oldCountryId forKey:@"old_country_code_id"];
        [inputParams setValue:countryId forKey:@"new_country_code_id"];
        url = CHANE_PHONE_NUMBER;
    }else{
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_mobileNumber.text forKey:@"set_phone_number"];
        [inputParams setValue:countryId forKey:@"country_code_id"];
        url = SET_PHONE_NUMBER;
    }
    
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [_otpResendButton setHidden:YES];
            [_countdownLabel setHidden:NO];
            [_otpSubmitButton setEnabled:YES];
            
            //Set otp time limit
            secondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
            [countDown invalidate];
            countDown = nil;
            countDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
            
            //Place the OTP as hint
            if(![[response valueForKey:@"view_otp"] boolValue])
            {
                [_otpCode setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"OTP"] ] forKeyPath:@"_placeholderLabel.text"];
            }
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:YES];
}

- (IBAction)cancelOTP:(id)sender {
    [countDown invalidate];
    _countdownLabel.text = @"";
    
    [otpPopup dismiss:YES];
    [countDown invalidate];
    [_otpSubmitButton setEnabled:YES];
}


//OTP forma validation
-(BOOL)otpFormValidation{
    [self resetOTPForm];
    
    //Check OTP code is empty
    //    if([[_otpCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    //    {
    //        [Util showErrorMessage:_otpCode withErrorMessage:NSLocalizedString(OTP_EMPTY, nil)];
    //        return FALSE;
    //    }
    if(![Util validateNumberField:_otpCode withValueToDisplay:OTP_TITLE withMinLength:OTP_MIN withMaxLength:OTP_MAX]){
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetOTPForm{
    [Util createBottomLine:_otpCode withColor:UIColorFromHexCode(TEXT_BORDER)];
}


//------------> OTP window ends  <----------------

//find country index
- (int) findCountryIndexByCode:(NSString *)code{
    for (int i=0; i<[countries count]; i++) {
        NSDictionary *country = [countries objectAtIndex:i];
        NSString *countryCode = [country valueForKey:@"country_pin_code"];
        if ([countryCode isEqualToString:code]) {
            return i;
        }
    }
    return -1;
}

@end
