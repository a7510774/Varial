//
//  OTPViewController.m
//  Varial
//
//  Created by user on 27/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "OTPViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "ChatDBManager.h"

@interface OTPViewController ()

@end

@implementation OTPViewController

NSTimer *myTimerCountDown;
int myIntSecondsRem;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUi];
    [self setUpModel];
    [self loadModel];
}

//MARK:- View Initialize

-(void)setUpUi {
    
    [self.myViewHeader setHeader:NSLocalizedString(TITLE_OTP_VALIDATION, nil)];
    [Util createRoundedCorener:self.myViewSubmit withCorner:5.0];
    [Util createRoundedCorener:self.myViewResendOTP withCorner:5.0];
    self.myViewResendOTP.hidden = YES;
    [self changeLanguageForAllObjects];
    [self.myTxtFldOTP addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    
    [myTimerCountDown invalidate];
    myTimerCountDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
}

-(void)setUpModel {
    
    
}

-(void)loadModel {
    
    
}

//MARK:- Api Call

-(void)OTPRequest{
    if([self otpFormValidation]){
        
        //Send OTP submit request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:_gStrcountryId forKey:@"country_id"];
        [inputParams setValue:_gStrPhoneNumber forKey:@"phone_number"];
        [inputParams setValue:_myTxtFldOTP.text forKey:@"OTP"];
        
        NSString * aUrl;
        if(_gIsLoginBtnTapped) {
            
            aUrl = SUBMIT_LOGIN_OTP;
        }
        else {
            
            [inputParams setValue:_gStrPhoneName forKey:@"name"];
            aUrl = SUBMIT_OTP;
        }
        
        [Util appendDeviceMeta:inputParams];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:aUrl withCallBack:^(NSDictionary * response){
            
            if ([[response valueForKey:@"status"] boolValue]) {
                [Util setInDefaults:[response valueForKey:@"auth_token"] withKey:@"auth_token"];
                
                if(_gIsLoginBtnTapped) {
                    [self moveToHomeScreen];
                }
                else {
                    
                    //Login success
                    if ([[response valueForKey:@"player_type_id"] intValue ] == 0) {
                        [self showPlayerTypeScreen:[response valueForKey:@"message"]];
                    }
                    else{
                        [Util setInDefaults:@"YES" withKey:@"isPlayerTypeSet"];
                        [Util setInDefaults:[response valueForKey:@"player_type_id"] withKey:@"playerType"];
                        [self moveToHomeScreen];
                    }
                }
                
                
                [_myTxtFldOTP resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
    }
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
    if(![Util validateNumberField:_myTxtFldOTP withValueToDisplay:OTP_TITLE withMinLength:OTP_MIN withMaxLength:OTP_MAX]){
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetOTPForm{
    [Util createBottomLine:_myTxtFldOTP withColor:UIColorFromHexCode(TEXT_BORDER)];
}

//Change the current screen
- (void)moveToHomeScreen{
    
    UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigation;
    [[ChatDBManager sharedInstance] createChatBadge];
}

-(void) changeLanguageForAllObjects {
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(TITLE_OTP_VALIDATION, nil)];
        _myLabelEnterOTPDescrptn.text = @"Please enter the OTP to verify your phone number";
        _myTxtFldOTP.placeholder = @"Enter OTP";
        [_myBtnReSendOTP setTitle:@"RESEND OTP" forState:UIControlStateNormal];
        [_myBtnValidateOTP setTitle:@"VALIDATE OTP" forState:UIControlStateNormal];
    }
    
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(@"OTP验证", nil)];
        _myLabelEnterOTPDescrptn.text = @"请输入OTP以验证您的电话号码";
        _myTxtFldOTP.placeholder = @"输入OTP";
        [_myBtnReSendOTP setTitle:@"重新发送OTP" forState:UIControlStateNormal];
        [_myBtnValidateOTP setTitle:@"验证OTP" forState:UIControlStateNormal];
    }
}

- (void)showPlayerTypeScreen:(NSString *)welcomeMsg{
    PlayerType *playerTypeScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerType"];
    playerTypeScreen.welcomeMessage = welcomeMsg;
    [Util setInDefaults:@"NO" withKey:@"isPlayerTypeSet"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = playerTypeScreen;
}

//MARK:- Private Functions

-(void) updateCountdown {
    
    int minutes, seconds;
    self.gIntSecondsLeft--;
    minutes = (self.gIntSecondsLeft % 3600) / 60;
    seconds = (self.gIntSecondsLeft %3600) % 60;
    if (minutes < 0 ) {
        minutes = 0;
    }
    if (seconds < 0) {
        seconds = 0;
    }
    if (minutes == 0 && seconds == 0) {
        [myTimerCountDown invalidate];
        [_myViewResendOTP setHidden:NO];
        [_myLabelTimer setHidden:YES];
    }
    _myLabelTimer.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    if (minutes == 0 && seconds == 0) {
        _myLabelTimer.text = @"";
    }
}

// Hide Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//MARK:- Button Actions

- (IBAction)myBtnResendOTPAction:(id)sender {
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:_gStrcountryId forKey:@"country_id"];
    [inputParams setValue:_gStrPhoneName forKey:@"name"];
    [inputParams setValue:_gStrPhoneNumber forKey:@"phone_number"];
    
    [Util appendDeviceMeta:inputParams];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PHONE_NUMBER withCallBack:^(NSDictionary * response){
        if ([[response valueForKey:@"status"] boolValue]) {
            
            
            [_myViewResendOTP setHidden:YES];
            [_myLabelTimer setHidden:NO];
            
            //Set otp time limit
            _gIntSecondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
            [myTimerCountDown invalidate];
            myTimerCountDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
            
            //Place the OTP as hint
            if(![[response valueForKey:@"view_otp"] boolValue])
            {
                [_myTxtFldOTP setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"OTP"] ] forKeyPath:@"_placeholderLabel.text"];
            }
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
        
    } isShowLoader:YES];
}

- (IBAction)myBtnValidateOTPAction:(id)sender {
    
    [self OTPRequest];
}

/*! doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton {
    [self.myTxtFldOTP resignFirstResponder];
    [self OTPRequest];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
