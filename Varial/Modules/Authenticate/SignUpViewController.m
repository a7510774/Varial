//
//  SignUpViewController.m
//  Varial
//
//  Created by user on 25/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignInViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "IQKeyboardManager.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
    [self setUpModel];
    [self loadModel];
}


// MARK:- View Initialize

- (void)setUpUI {
    
    [self.myViewHeader setHeader:NSLocalizedString(TITLE_SIGNUP, nil)];
    [Util createRoundedCorener:self.myViewSignUpBtn withCorner:5.0];
    [self changeLanguageForAllObjects];
    [self.myTxtFldConfirmPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

- (void)setUpModel {
    
    
}

- (void)loadModel {
    
    
}


-(void)signUpRequest{
    //Send signup request
    //Build Input Parameters
    if([self signupValidation]){
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:_myTxtFldName.text forKey:@"name"];
        [inputParams setValue:_myTxtFldEmail.text forKey:@"email"];
        [inputParams setValue:_myTxtFldPassword.text forKey:@"password"];
        [inputParams setValue:_myTxtFldConfirmPassword.text forKey:@"confirm_password"];
        
        [Util appendDeviceMeta:inputParams];
        
        [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:SIGNUP_API withCallBack:^(NSDictionary * response){
            
            
            if ([[response valueForKey:@"status"] boolValue]) {
                [Util setInDefaults:[response valueForKey:@"auth_token"] withKey:@"auth_token"];
                [self showPlayerTypeScreen:[response valueForKey:@"message"]];
                [_myTxtFldName resignFirstResponder];
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
    if(![Util validateTextField:_myTxtFldEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    //Validate password
    else if(![Util validatePasswordField:_myTxtFldPassword withValueToDisplay:@"Password" withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX]){
        return FALSE;
    }
    // Validation Password continue empty spaces
    if ([[_myTxtFldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_myTxtFldPassword withErrorMessage:NSLocalizedString(CONTINUE_WHITESPACES, nil)];
        return FALSE;
    }
    //Check confirm password is empty
    else if([_myTxtFldConfirmPassword.text length] == 0)
    {
        [Util showErrorMessage:_myTxtFldConfirmPassword withErrorMessage:NSLocalizedString(CONFIRM_EMPTY, nil)];
        return FALSE;
    }
    //Validation to match password
    if(![_myTxtFldConfirmPassword.text isEqualToString:_myTxtFldPassword.text]){
        
        //add border to validated fields
        [Util createBottomLine:_myTxtFldPassword withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util createBottomLine:_myTxtFldConfirmPassword withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util showErrorMessage:_myTxtFldConfirmPassword withErrorMessage:NSLocalizedString(CONFIRM_MISMATCH, nil)];
        return FALSE;
    }
    //Validate name
    if(![Util validateTextField:_myTxtFldName withValueToDisplay:NAME_TITLE withIsEmailType:FALSE withMinLength:NAME_MIN withMaxLength:NAME_MAX_LEN]){
        return FALSE;
    }
    if(![Util validCharacter:_myTxtFldName forString:_myTxtFldName.text withValueToDisplay:NAME_TITLE]){
        return FALSE;
    }
    if(![Util validateName:_myTxtFldName.text]){
        [Util showErrorMessage:_myTxtFldName withErrorMessage:NSLocalizedString(INVALID_NAME, nil)];
        return FALSE;
    }
    
    return YES;
}

//Reset the signup forms
- (void)resetSignUpForm{
    [Util createBottomLine:_myTxtFldEmail withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_myTxtFldPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_myTxtFldConfirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_myTxtFldName withColor:UIColorFromHexCode(TEXT_BORDER)];
}

// Language Conversion
-(void) changeLanguageForAllObjects {
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(TITLE_SIGNUP, nil)];
        _myTxtFldEmail.placeholder = @"Email";
        _myTxtFldName.placeholder = @"Username";
        _myTxtFldPassword.placeholder = @"Password";
        _myTxtFldConfirmPassword.placeholder = @"Confirm Password";
        [_myBtnSignUp setTitle:@"SIGN UP" forState:UIControlStateNormal];
        _myLabelAlreadyHavAcc.text = @"Do you have an account";
        [_myBtnLogin setTitle:@"Login" forState:UIControlStateNormal];
        
    }
    
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(@"注册", nil)];
        _myTxtFldEmail.placeholder = @"电子邮件";
        _myTxtFldName.placeholder = @"用戶名";
        _myTxtFldPassword.placeholder = @"密码";
        _myTxtFldConfirmPassword.placeholder = @"确认密码";
        [_myBtnSignUp setTitle:@"提交" forState:UIControlStateNormal];
        _myLabelAlreadyHavAcc.text = @"您有账户吗";
        [_myBtnLogin setTitle:@"登录" forState:UIControlStateNormal];
    }
}

- (void)showPlayerTypeScreen:(NSString *)welcomeMsg{
    PlayerType *playerTypeScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerType"];
    playerTypeScreen.welcomeMessage = welcomeMsg;
    [Util setInDefaults:@"NO" withKey:@"isPlayerTypeSet"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = playerTypeScreen;
}

// Hide Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// MARK:- Button Actions
- (IBAction)myBtnSignUpAction:(id)sender {
    
    [self signUpRequest];
}


- (IBAction)myBtnSignInAction:(id)sender {
    
   UIStoryboard* aMainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    
    SignInViewController *aSignIn = [aMainStoryboard instantiateViewControllerWithIdentifier:@"SignIn"];
    [self.navigationController pushViewController:aSignIn animated:YES];
}


/*! doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton {
    [self.myTxtFldConfirmPassword resignFirstResponder];
    [self signUpRequest];
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
