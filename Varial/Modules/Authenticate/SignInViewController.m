//
//  SignInViewController.m
//  Varial
//
//  Created by user on 25/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "SignInViewController.h"
#import "ChatDBManager.h"
#import "SignUpViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "ForgotPasswordViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

UIStoryboard *myMainStoryboard;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
    [self setUpModel];
    [self loadModel];
}


// MARK:- View Initialize

- (void)setUpUI {
    
    [self.myViewHeader setHeader:NSLocalizedString(TITLE_SIGNIN, nil)];
    [Util createRoundedCorener:_myViewLoginBtn withCorner:5.0];
    [self changeLanguageForAllObjects];
    [self.myTxtFldPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
}

- (void)setUpModel {
    
    
}

- (void)loadModel {
    
    
}

// MARK:- Api Request

-(void)signInRequest{
    
    if([self signinValitation]){
        
        //Send signin request
        
        //Build Input Parameters
        
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:_myTxtFldUsername.text forKey:@"email"];
        [inputParams setValue:_myTxtFldPassword.text forKey:@"password"];
        
        [Util appendDeviceMeta:inputParams];
        
        [Util setInDefaults:@"SignIn" withKey:@"ServiceName"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SIGNIN withCallBack:^(NSDictionary * response){
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            
            if ([[response valueForKey:@"status"] boolValue]) {
                
                [Util setInDefaults:[response valueForKey:@"auth_token"] withKey:@"auth_token"];
                
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

// MARK:- Private Functions

- (BOOL)signinValitation{
    
    [self resetSignInForm];
    //sign up extra space
    _myTxtFldUsername.text = [_myTxtFldUsername.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //Check email is empty
    
    if([[_myTxtFldUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
        
    {
        
        [Util showErrorMessage:_myTxtFldUsername withErrorMessage:NSLocalizedString(EMAIL_EMPTY, nil)];
        return FALSE;
    }
    
    //Validate email
    
    if(![Util validateTextField:_myTxtFldUsername withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        
        return FALSE;
    }
    
    //Check password is empty
    
    if(![Util validatePasswordField:_myTxtFldPassword withValueToDisplay:PASSWORD withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX])
        
    {
        return FALSE;
        
    }
    return YES;
}


//Reset the signin forms

- (void)resetSignInForm{
    
    [Util createBottomLine:_myTxtFldUsername withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_myTxtFldPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}

// Language Conversion
-(void) changeLanguageForAllObjects {
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(TITLE_SIGNIN, nil)];
        _myTxtFldUsername.placeholder = @"Username";
        _myTxtFldPassword.placeholder = @"Password";
        [_myBtnForgotPassword setTitle:@"Forgot Password" forState:UIControlStateNormal];
        [_myBtnSignIn setTitle:@"LOGIN" forState:UIControlStateNormal];
        _myLabelAlreadyHavAcc.text = @"Have you registered";
        [_myBtnSignUp setTitle:@"  Sign Up" forState:UIControlStateNormal];
    }
    
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(@"签到", nil)];
        _myTxtFldUsername.placeholder = @"用户名";
        _myTxtFldPassword.placeholder = @"密码";
        [_myBtnForgotPassword setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_myBtnSignIn setTitle:@"登录" forState:UIControlStateNormal];
        _myLabelAlreadyHavAcc.text = @"你有没有注册";
        [_myBtnSignUp setTitle:@"立即注册" forState:UIControlStateNormal];
        
    }
}

//Change the current screen
- (void)moveToHomeScreen{
    
    MBProgressHUD *loader = nil;
    
    [Util hideLoading:loader];
    UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigation;
    [[ChatDBManager sharedInstance] createChatBadge];
}

- (void)showPlayerTypeScreen:(NSString *)welcomeMsg{
    PlayerType *playerTypeScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerType"];
    playerTypeScreen.welcomeMessage = welcomeMsg;
    [Util setInDefaults:@"NO" withKey:@"isPlayerTypeSet"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = playerTypeScreen;
}

//Flags for control the skater/crew/media privileges
- (void)controlThePalyerLevel:(NSDictionary *)response{
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_bazzardrun"] boolValue] forKey:@"can_participate_in_bazzardrun"];
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_clubpromotion"] boolValue] forKey:@"can_participate_in_clubpromotion"];
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_shop_offers"] boolValue] forKey:@"can_show_shop_offers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Hide Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// MARK:- Button Actions

- (IBAction)myBtnForgotPasswordAction:(id)sender {
    
    myMainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    ForgotPasswordViewController *aForgotPassword = [myMainStoryboard instantiateViewControllerWithIdentifier:@"ForgotPassword"];
    [self.navigationController pushViewController:aForgotPassword animated:YES];
}

- (IBAction)myBtnSignUpAction:(id)sender {
    
    myMainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    SignUpViewController *aSignUp = [myMainStoryboard instantiateViewControllerWithIdentifier:@"SignUp"];
    [self.navigationController pushViewController:aSignUp animated:YES];
}

- (IBAction)myBtnLoginSubmitAction:(id)sender {
    [self signInRequest];
}

/*! doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton {
    [self.myTxtFldPassword resignFirstResponder];
//    [self signInRequest];
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
