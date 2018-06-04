//
//  Login.m
//  Varial
//
//  Created by jagan on 26/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Login.h"
#import "NetworkAlert.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import <Photos/Photos.h>
#import "ChatDBManager.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "ViewController.h"
#import "SignUpWithPhoneViewController.h"

@interface Login ()

@end

@implementation Login

NSArray *textFields;
NSTimer *countDown;
int secondsLeft, myIntLanguageCode;
NSString *countryId, *forgotMessage, *myStrCurrentLanguage, *myStrLanguage;
UIStoryboard *mainStoryboard;
NSMutableArray *myAryLanguages;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    textFields = [[NSArray alloc] initWithObjects:_emailField,_name,_password,_confirmPassword,_signinEmail,_signinPassword, _forgotEmail,_countryCode,_countryField,_phoneNumber,_phoneName,_otpCode, nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    countries = [defaults objectForKey:@"country_list"];
    [_signinEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    if([countries count] == 0)
        [self getCountryList];
    [self designTheView];    
    
    [_name addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_signinPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_phoneName addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_otpCode addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_forgotEmail addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
}

/*! doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton
{
    if(visibleWindow==1)
        [self signUpRequest];
    if(visibleWindow==2)
        [self signInRequest];
    if(visibleWindow==3)
        [self phoneSubmitRequest];
    if(visibleWindow==4)
        [self OTPRequest];
    if(visibleWindow==5)
        [self resetRequest];
}

-(void)viewDidAppear:(BOOL)animated{
    
//    [self createPopUpWindows];
    [self.loginBackImage.layer removeAllAnimations];
    [[Util sharedInstance] animateTheImage:self.loginBackImage withHeight:ANIMATION_HEIGHT];
    
    //Request photo access
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
    }];
}

-(void) viewWillAppear:(BOOL)animated{
    self.mainView.clipsToBounds = YES;
    [self changeLanguageFlag];
    [self changeLanguageForAllObjects];
    myAryLanguages = [[NSMutableArray alloc] initWithObjects:@{@"flag":@"usa.png",@"code":@"en-US",@"title":@"English"},@{@"flag":@"china.png",@"code":@"zh",@"title":@"中文"}, nil];
    
    // Set Corner Radius
    [Util createRoundedCorener:_myViewEmailSignUp withCorner:5.0];
    [Util createRoundedCorener:_myViewPhoneSignUp withCorner:5.0];
    [Util createRoundedCorener:_myViewSignIn withCorner:5.0];
    [Util createRoundedCorener:_myViewSignInWithMobile withCorner:5.0];
//    [self designTheView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) getCountryList{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:COUNTRY_LIST withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:[response objectForKey:@"country_list"] forKey:@"country_list"];
            countries = [defaults objectForKey:@"country_list"];
        }
    } isShowLoader:NO];
}

//Design the views
-(void) designTheView{
    
    [self.navigationController setNavigationBarHidden:YES];
    for (UITextField *field in textFields){
        [Util createBottomLine:field withColor:UIColorFromHexCode(TEXT_BORDER)];
    }
    
    [Util createRoundedCorener:_signupView withCorner:5];
    [Util createRoundedCorener:_signupButton withCorner:3];
    
    [Util createRoundedCorener:_signinView withCorner:5];
    [Util createRoundedCorener:_siginInButton withCorner:3];
    
    [Util createRoundedCorener:_forgotView withCorner:5];
    [Util createRoundedCorener:_forgotButton withCorner:3];
    
    
    [Util createRoundedCorener:_phoneView withCorner:5];
    [Util createRoundedCorener:_phoneSubmitButton withCorner:3];
    
    [Util createRoundedCorener:_otpView withCorner:5];
    [Util createRoundedCorener:_otpSubmitButton withCorner:3];
    [Util createRoundedCorener:_otpResendButton withCorner:3];
    [Util createRoundedCorener:_otpCancelBUtton withCorner:3];
    
    //Set country field input type to UIPickerview
    countryPicker = [[UIPickerView alloc] init];
    countryPicker.delegate = self;
    countryPicker.dataSource = self;
    [countryPicker selectRow:0 inComponent:0 animated:NO];
    countryPicker.showsSelectionIndicator = YES;
    countryPicker.frame = CGRectMake(0, self.view.frame.size.height-
                              countryPicker.frame.size.height-50, 320, 230);
    _countryField.inputView = countryPicker;
    
    _otpCode.delegate = self;
    _termsLabel.delegate = self;
    _FAQLabel.delegate = self;
    [self designTerms];
}

-(void)designTerms{
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        [Util setHyperlinkForLabel:_termsLabel forText:@"Terms of Service" destinationURL:@"https://www.varialskate.com/terms-and-conditions.php?lang_code=en-US" forColor:[UIColor lightGrayColor]];
        [Util setHyperlinkForLabel:_termsLabel forText:@"Privacy Policy" destinationURL:@"https://www.varialskate.com/privacy-policy.php?lang_code=en-US" forColor:[UIColor lightGrayColor]];
        [Util setHyperlinkForLabel:_termsLabel forText:@"FAQ" destinationURL:@"https://www.varialskate.com/faq.php?lang_code=en-US" forColor:[UIColor lightGrayColor]];
        
    }
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        
        [Util setHyperlinkForLabel:_termsLabel forText:@"使用条款" destinationURL:@"https://www.varialskate.com/terms-and-conditions.php?lang_code=zh" forColor:[UIColor lightGrayColor]];
        [Util setHyperlinkForLabel:_termsLabel forText:@"隐私政策" destinationURL:@"https://www.varialskate.com/privacy-policy.php?lang_code=zh" forColor:[UIColor lightGrayColor]];
        [Util setHyperlinkForLabel:_termsLabel forText:@"应用介绍" destinationURL:@"https://www.varialskate.com/faq.php?lang_code=zh" forColor:[UIColor lightGrayColor]];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _otpCode) {
       return textField.text.length + (string.length - range.length) <= OTP_MAX;
    }
    return YES;
}
-(void)textFieldDidChange :(UITextField *)theTextField{
    email = _signinEmail.text;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)chooseLanguage:(id)sender {
    [signupPopup setHidden:YES];
    [signinPopup setHidden:YES];
    [forgotPopup setHidden:YES];
    [phonePopup setHidden:YES];
    [otpPopup setHidden:YES];
    Language *language = [self.storyboard instantiateViewControllerWithIdentifier:@"Language"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = language;
}

- (void) createPopUpWindows{
    
    signupPopup = [KLCPopup popupWithContentView:self.signupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    signupPopup.didFinishShowingCompletion = ^{        
        [_emailField becomeFirstResponder];
    };
    
    signinPopup = [KLCPopup popupWithContentView:self.signinView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    signinPopup.didFinishShowingCompletion = ^{
        [_signinEmail becomeFirstResponder];
    };
    
    forgotPopup = [KLCPopup popupWithContentView:self.forgotView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    forgotPopup.didFinishShowingCompletion = ^{
        [_forgotEmail setText:email];
        [_forgotEmail becomeFirstResponder];
    };
    
    forgotPopup.didFinishDismissingCompletion = ^{
        email = @"";
        if(forgotMessage != nil){
            [[AlertMessage sharedInstance] showMessage:forgotMessage withDuration:3];
            forgotMessage = nil;
        }
    };
    
    phonePopup = [KLCPopup popupWithContentView:self.phoneView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    phonePopup.didFinishShowingCompletion = ^{
        [countryPicker reloadAllComponents];
        [countryPicker selectRow:0 inComponent:0 animated:YES];
    };
    
    otpPopup = [KLCPopup popupWithContentView:self.otpView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    otpPopup.didFinishShowingCompletion = ^{
        [_otpCode becomeFirstResponder];
    };

    
}

- (IBAction)showSignupWindow:(id)sender {
//    [self.signupView setHidden:NO];
//    [signupPopup showWithLayout:layout];
//    visibleWindow=1;

    mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    
    SignUpViewController *aSignUp = [mainStoryboard instantiateViewControllerWithIdentifier:@"SignUp"];
    [self.navigationController pushViewController:aSignUp animated:YES];
}

- (IBAction)showSigninWindow:(id)sender {
//    [self.signinView setHidden:NO];
//    [signinPopup showWithLayout:layout];
//    visibleWindow=2;
    
    mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    
    SignInViewController *aSignIn = [mainStoryboard instantiateViewControllerWithIdentifier:@"SignIn"];
    [self.navigationController pushViewController:aSignIn animated:YES];
}

- (IBAction)showPhonePopupWindow:(id)sender {
    
//    if ([countries count] == 0) {
//        [self getCountryList];
//    }
//    [self.phoneView setHidden:NO];
//    [phonePopup showWithLayout:layout];
//    visibleWindow=3;
//
//    // Auto populate the county picker
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [_countryField sendActionsForControlEvents:UIControlEventEditingDidBegin];
//        [_countryField becomeFirstResponder];
//    });
    
    mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    
    SignUpWithPhoneViewController *aSignUpWithPhone = [mainStoryboard instantiateViewControllerWithIdentifier:@"SignUpWithPhone"];
    [self.navigationController pushViewController:aSignUpWithPhone animated:YES];
    
}


//Change language flag based on language
- (void)changeLanguageFlag{
    
    myStrLanguage = [Util getFromDefaults:@"language"];
    if([myStrLanguage isEqualToString: @""]) {
        myIntLanguageCode = 0;
        [self.myBtnEnglishLanguage setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else if ([myStrLanguage  isEqualToString:@"en-US"]) {
        myIntLanguageCode = 0;
        [self.myBtnEnglishLanguage setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else if ([myStrLanguage  isEqualToString:@"zh"]) {
        myIntLanguageCode = 1;
        [self.myBtnChineseLanguage setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
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
    
        NSDictionary *country = [countries objectAtIndex:row];
        [_countryField setText:[country objectForKey:@"country_name"]];
        [_countryCode setText:[country valueForKey:@"country_pin_code"]];
        countryId = [country valueForKey:@"country_id"];
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSDictionary *country = [countries objectAtIndex:row];
    return [country objectForKey:@"country_name"];
    
}
//** End of Picker View Deleage **/

//Change the current screen
- (void)moveToHomeScreen{
    
    UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigation;
    [[ChatDBManager sharedInstance] createChatBadge];
}



// -----------------------> Signup with email  <---------------------

- (IBAction)doSignUp:(id)sender {
    [self signUpRequest];
}
  
-(void)signUpRequest{
    //Send signup request
    //Build Input Parameters
    if([self signupValidation]){
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:_name.text forKey:@"name"];
        [inputParams setValue:_emailField.text forKey:@"email"];
        [inputParams setValue:_password.text forKey:@"password"];
        [inputParams setValue:_confirmPassword.text forKey:@"confirm_password"];
        
        [Util appendDeviceMeta:inputParams];
        
        [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:SIGNUP_API withCallBack:^(NSDictionary * response){
            
            
            if ([[response valueForKey:@"status"] boolValue]) {
                [Util setInDefaults:[response valueForKey:@"auth_token"] withKey:@"auth_token"];
                [signupPopup dismiss:YES];
                [self showPlayerTypeScreen:[response valueForKey:@"message"]];
                [_name resignFirstResponder];
            }else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
            
        } isShowLoader:YES];
        
    }
}

//Form validations
- (BOOL)signupValidation{
    
    [self resetSignUpForm];
    
    //Validate email
    if(![Util validateTextField:_emailField withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    //Validate password
    else if(![Util validatePasswordField:_password withValueToDisplay:@"Password" withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX]){
        return FALSE;
    }
    // Validation Password continue empty spaces
    if ([[_password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_password withErrorMessage:NSLocalizedString(CONTINUE_WHITESPACES, nil)];
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
    //Validate name
    if(![Util validateTextField:_name withValueToDisplay:NAME_TITLE withIsEmailType:FALSE withMinLength:NAME_MIN withMaxLength:NAME_MAX_LEN]){
        return FALSE;
    }
    if(![Util validCharacter:_name forString:_name.text withValueToDisplay:NAME_TITLE]){
        return FALSE;
    }
    if(![Util validateName:_name.text]){
        [Util showErrorMessage:_name withErrorMessage:NSLocalizedString(INVALID_NAME, nil)];
        return FALSE;
    }    
    
    return YES;
}

//Reset the signup forms
- (void)resetSignUpForm{
    [Util createBottomLine:_emailField withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_password withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_confirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_name withColor:UIColorFromHexCode(TEXT_BORDER)];
}


// -----------------------> Signup with email ends  <---------------------



// -----------------------> Signin with email   <---------------------


- (IBAction)doSignin:(id)sender {
    [self signInRequest];
}
-(void)signInRequest{
    if([self signinValitation]){
        
        //Send signin request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:_signinEmail.text forKey:@"email"];
        [inputParams setValue:_signinPassword.text forKey:@"password"];
        
        [Util appendDeviceMeta:inputParams];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SIGNIN withCallBack:^(NSDictionary * response){
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            if ([[response valueForKey:@"status"] boolValue]) {
                [Util setInDefaults:[response valueForKey:@"auth_token"] withKey:@"auth_token"];
                //Hide the signin window
                [signinPopup dismiss:YES];
                [_signinPassword resignFirstResponder];
                [self controlThePalyerLevel:response];
                
                if ([[response valueForKey:@"player_type_id"]intValue] == 0) {
                    [self showPlayerTypeScreen:nil];
                }
                else{
                    [Util setInDefaults:@"YES" withKey:@"isPlayerTypeSet"];
                    [Util setInDefaults:[response valueForKey:@"player_type_id"] withKey:@"playerType"];
                    [self moveToHomeScreen];
                }
                
            }
            
        } isShowLoader:YES];
    }
}

- (IBAction)showForgotWindow:(id)sender {
    
    [_signinEmail resignFirstResponder];

    //Hide the signin window
    [signinPopup dismiss:YES];
    
    //Show forgot password
    [self.forgotView setHidden:NO];
    [forgotPopup showWithLayout:layout];
    visibleWindow=5;
}

- (BOOL)signinValitation{
    [self resetSignInForm];
    
    //sign up extra space
    
    _signinEmail.text = [_signinEmail.text stringByReplacingOccurrencesOfString:@" " withString:@""];

    //Check email is empty
    if([[_signinEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_signinEmail withErrorMessage:NSLocalizedString(EMAIL_EMPTY, nil)];
        return FALSE;
    }
    //Validate email
    if(![Util validateTextField:_signinEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    //Check password is empty
    if(![Util validatePasswordField:_signinPassword withValueToDisplay:PASSWORD withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX])
    {
        return FALSE;
    }
    return YES;
}

//Reset the signin forms
- (void)resetSignInForm{
    [Util createBottomLine:_signinEmail withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_signinPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}

// -----------------------> Signin with email ends  <---------------------



// -----------------------> Forgot password   <---------------------


- (IBAction)doResetAction:(id)sender {
    
    [self resetRequest];
}

-(void)resetRequest{
    if([self forgotFormValidation]){
        
        //Send forgot request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:_forgotEmail.text forKey:@"email"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FORGOT_PASSWORD withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                forgotMessage = [response valueForKey:@"message"];
                [forgotPopup dismiss:YES];
                [_forgotEmail resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
        } isShowLoader:YES];
        
    }
}

-(BOOL)forgotFormValidation{
    [self resetForgotForm];
    
    //Validate email
    if(![Util validateTextField:_forgotEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetForgotForm{
    [Util createBottomLine:_forgotEmail withColor:UIColorFromHexCode(TEXT_BORDER)];
}

// -----------------------> Forgot password  ends  <---------------------



// -----------------------> Phone number  <---------------------

- (IBAction)doTouchCountryField:(id)sender
{
    if ([_countryField.text isEqualToString:@""]) {
        
        if ([countries count] > 0) {            
            [self pickerView:countryPicker didSelectRow:0 inComponent:0];
            [_countryField setTextColor:[UIColor blackColor]];
        }
    }    
}

- (IBAction)doPhoneSubmit:(id)sender {
    [self phoneSubmitRequest];
}
-(void)phoneSubmitRequest{
    if([self phoneNumberFormValidation]){
        
        //Send phone signup request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:countryId forKey:@"country_id"];
        [inputParams setValue:_phoneName.text forKey:@"name"];
        [inputParams setValue:_phoneNumber.text forKey:@"phone_number"];
        
        [Util appendDeviceMeta:inputParams];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PHONE_NUMBER withCallBack:^(NSDictionary * response){
            
            //check for new user
            _isNewUser = [[response valueForKey:@"new_registeration"] boolValue];
            playerType = [[response valueForKey:@"player_type_id"] intValue];
            if (!_isNewUser) {
               [self controlThePalyerLevel:response];
            }
            
            if ([[response valueForKey:@"status"] boolValue]) {
                
                //Hide the phone window
                [phonePopup dismiss:YES];
                
                //Show otp window
                [self.otpView setHidden:NO];
                [otpPopup showWithLayout:layout];
                visibleWindow=4;
                
                //change timer and resend button visibitlity
                [_otpResendButton setHidden:YES];
                [_timerLabel setHidden:NO];
                
                //Set otp time limit
                secondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
                [countDown invalidate];
                countDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
                
                //Place the OTP as hint
                if(![[response valueForKey:@"view_otp"] boolValue])
                {
                    [_otpCode setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"OTP"] ] forKeyPath:@"_placeholderLabel.text"];
                }
                [_phoneName resignFirstResponder];
                
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }

}

-(BOOL)phoneNumberFormValidation{
    [self resetPhoneForm];
    
    //Check coutry is choosed
    if([[_countryField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_countryField withErrorMessage:NSLocalizedString(COUNTRY_EMPTY, nil)];
        return FALSE;
    }
    
    //Check phone number
//    if([[_phoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
//    {
//        [Util showErrorMessage:_countryField withErrorMessage:NSLocalizedString(PHONE_NUMBER_EMPTY, nil)];
//        return FALSE;
//    }
    
    if(![Util validateNumberField:_phoneNumber withValueToDisplay:PHONE_NO withMinLength:PHONE_MIN withMaxLength:PHONE_MAX])
    {
        return FALSE;
    }
    //Validate name
    if(![Util validateTextField:_phoneName withValueToDisplay:NAME_TITLE withIsEmailType:FALSE withMinLength:NAME_MIN withMaxLength:NAME_MAX_LEN]){
        return FALSE;
    }
    if(![Util validCharacter:_phoneName forString:_phoneName.text withValueToDisplay:NAME_TITLE]){
        return FALSE;
    }
    if(![Util validateName:_phoneName.text]){
        [Util showErrorMessage:_phoneName withErrorMessage:NSLocalizedString(INVALID_NAME, nil)];
        return FALSE;
    }
    
    return YES;
}

//Reset the phone form
- (void)resetPhoneForm{
    [Util createBottomLine:_countryField withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_phoneNumber withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_phoneName withColor:UIColorFromHexCode(TEXT_BORDER)];
    
}


// -----------------------> Phone number  ends  <---------------------



// -----------------------> OTP Window  <---------------------


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
        [_otpResendButton setHidden:NO];
        [_timerLabel setHidden:YES];
        [_otpSubmitButton setEnabled:NO];
    }
    _timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    if (minutes == 0 && seconds == 0) {
        _timerLabel.text = @"";
    }
}


- (IBAction)doOTPSubmit:(id)sender {
    [self OTPRequest];
}

-(void)OTPRequest{
    if([self otpFormValidation]){
        
        //Send OTP submit request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:countryId forKey:@"country_id"];
        [inputParams setValue:_phoneName.text forKey:@"name"];
        [inputParams setValue:_phoneNumber.text forKey:@"phone_number"];
        [inputParams setValue:_otpCode.text forKey:@"OTP"];
        
        [Util appendDeviceMeta:inputParams];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SUBMIT_OTP withCallBack:^(NSDictionary * response){
            
            if ([[response valueForKey:@"status"] boolValue]) {
                [Util setInDefaults:[response valueForKey:@"auth_token"] withKey:@"auth_token"];
                [otpPopup dismiss:YES];
                //Login success
                if ([[response valueForKey:@"player_type_id"] intValue ] == 0) {
                    [self showPlayerTypeScreen:[response valueForKey:@"message"]];
                }
                else{
                    [Util setInDefaults:@"YES" withKey:@"isPlayerTypeSet"];
                    [Util setInDefaults:[response valueForKey:@"player_type_id"] withKey:@"playerType"];
                    [self moveToHomeScreen];
                }
                [_otpCode resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }           
            
        } isShowLoader:YES];
    }
}

-(void)showProfilePage{
    ProfilePicture *profilePic = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfilePicture"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = profilePic;
}

- (void)showPlayerTypeScreen:(NSString *)welcomeMsg{
    PlayerType *playerTypeScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerType"];
    playerTypeScreen.welcomeMessage = welcomeMsg;
    [Util setInDefaults:@"NO" withKey:@"isPlayerTypeSet"];    
    [[UIApplication sharedApplication] delegate].window.rootViewController = playerTypeScreen;
}

- (IBAction)doOTPResendAction:(id)sender {
    
    //Send phone signup request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:countryId forKey:@"country_id"];
    [inputParams setValue:_phoneName.text forKey:@"name"];
    [inputParams setValue:_phoneNumber.text forKey:@"phone_number"];
    
    [Util appendDeviceMeta:inputParams];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PHONE_NUMBER withCallBack:^(NSDictionary * response){
        if ([[response valueForKey:@"status"] boolValue]) {
            
            
            [_otpResendButton setHidden:YES];
            [_timerLabel setHidden:NO];
            [_otpSubmitButton setEnabled:YES];
            
            //Set otp time limit
            secondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
            [countDown invalidate];
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
        
        
    } isShowLoader:YES];
}

- (IBAction)closeOTPWindow:(id)sender {
    [countDown invalidate];
    _timerLabel.text = @"";
    
    [otpPopup dismiss:YES];
    [_otpSubmitButton setEnabled:YES];
}


-(BOOL)otpFormValidation{
    [self resetOTPForm];
    
    //Check OTP code is empty
//    if([[_otpCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
//    {
//        [Util showErrorMessage:_otpCode withErrorMessage:NSLocalizedString(OTP_EMPTY, nil)];
//        return FALSE;
//    }
    //Validate name
    if(![Util validateNumberField:_otpCode withValueToDisplay:OTP_TITLE withMinLength:OTP_MIN withMaxLength:OTP_MAX]){
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetOTPForm{
    [Util createBottomLine:_otpCode withColor:UIColorFromHexCode(TEXT_BORDER)];
}


// -----------------------> OTP Window ends  <---------------------

-(void) viewWillDisappear:(BOOL)animated{

    [_signupView endEditing:YES];
    [_signinView endEditing:YES];
    [_forgotView endEditing:YES];
    [_phoneView endEditing:YES];
    [_otpView endEditing:YES];
    [_mainView endEditing:YES];
    
}


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

//Flags for control the skater/crew/media privileges
- (void)controlThePalyerLevel:(NSDictionary *)response{
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_bazzardrun"] boolValue] forKey:@"can_participate_in_bazzardrun"];
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_clubpromotion"] boolValue] forKey:@"can_participate_in_clubpromotion"];
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_shop_offers"] boolValue] forKey:@"can_show_shop_offers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Change Language Button Action
- (IBAction)myBtnEnglishLanguageAction:(id)sender {
    
    myIntLanguageCode = 0;
    [self.myBtnEnglishLanguage setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.myBtnChineseLanguage setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self setLanguageApiRequest:myIntLanguageCode];
}


- (IBAction)myBtnChinaLanguageAction:(id)sender {
    
    myIntLanguageCode = 1;
    [self.myBtnChineseLanguage setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.myBtnEnglishLanguage setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self setLanguageApiRequest:myIntLanguageCode];
}

-(void) setLanguageApiRequest:(int)languageCode {
    
    if (myAryLanguages != nil && [myAryLanguages count] > 0) {
        
        //Set current language in session
        NSDictionary *aDicLang = [myAryLanguages objectAtIndex:languageCode];
        [Util setInDefaults:[aDicLang valueForKey:@"code"] withKey:@"language"];
        
        //set current langugae
        myStrCurrentLanguage = [aDicLang valueForKey:@"code"];
        
        //Change the app language
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[aDicLang valueForKey:@"code"] , nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize] ;
        
        //Move to login screen
        [NSBundle setLanguage:[aDicLang valueForKey:@"code"]];
        
        [self changeLanguageForAllObjects];
        
    }
    
//        //Build Input Parameters
//        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
//        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
//        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_LANGUAGE withCallBack:^(NSDictionary * response)
//         {
//             if([[response valueForKey:@"status"] boolValue]){
//
//                [self changeLanguageForAllObjects];
//
//             }
//
//         } isShowLoader:YES];
    
}

- (IBAction)myBtnLoginWithMobileAction:(id)sender {
    
    mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    
    SignUpWithPhoneViewController *aSignUpWithPhone = [mainStoryboard instantiateViewControllerWithIdentifier:@"SignUpWithPhone"];
    aSignUpWithPhone.isLoginBtnTapped = YES;
    [self.navigationController pushViewController:aSignUpWithPhone animated:YES];
}


-(void) changeLanguageForAllObjects {
//    NSAttributedString * aAttributedEnglishStr = [[NSAttributedString alloc]initWithString:@"Terms of Service   |   Privacy Policy   |   FAQ"];
//    NSAttributedString * aAttributedChineseStr = [[NSAttributedString alloc]initWithString:@"使用条款   |   隐私政策   |   应用介绍"];
//    [_termsLabel setAttributedText:aAttributedEnglishStr];
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        [_myBtnSignUpWithEmail setTitle:@"SIGNUP WITH EMAIL" forState:UIControlStateNormal];
        [_myBtnSignUpWithPhone setTitle:@"SIGNUP WITH PHONE" forState:UIControlStateNormal];
        _myLabelDoUhaveAcc.text = @"Do you have an account";
        [_myBtnLogin setTitle:@"LOGIN WITH EMAIL" forState:UIControlStateNormal];
        [_myBtnLoginWithMobile setTitle:@"LOGIN WITH PHONE" forState:UIControlStateNormal];
//        myBtnLoginWithPhone
//        [_termsLabel setAttributedText:aAttributedEnglishStr];
        _termsLabel.text = @"Terms of Service   |   Privacy Policy   |   FAQ";
        [_myBtnChooseLanguage setTitle:@"Choose Language" forState:UIControlStateNormal];
        [_myBtnEnglishLanguage setTitle:@"English" forState:UIControlStateNormal];
        [_myBtnChineseLanguage setTitle:@"Chinese" forState:UIControlStateNormal];
    }
    
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        [_myBtnSignUpWithEmail setTitle:@"邮箱注册" forState:UIControlStateNormal];
        [_myBtnSignUpWithPhone setTitle:@"电话注册" forState:UIControlStateNormal];
        _myLabelDoUhaveAcc.text = @"您有账户吗";
        [_myBtnLogin setTitle:@"邮箱登陆" forState:UIControlStateNormal];
        [_myBtnLoginWithMobile setTitle:@"手机登陆" forState:UIControlStateNormal];
//        [_termsLabel setAttributedText:aAttributedChineseStr];
        _termsLabel.text = @"使用条款   |   隐私政策   |   应用介绍";
        [_myBtnChooseLanguage setTitle:@"选择语言" forState:UIControlStateNormal];
        [_myBtnEnglishLanguage setTitle:@"英文" forState:UIControlStateNormal];
        [_myBtnChineseLanguage setTitle:@"中文" forState:UIControlStateNormal];
    }
    [self designTerms];
}


@end
