//
//  ForgotPasswordViewController.m
//  Varial
//
//  Created by user on 26/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
    [self setUpModel];
    [self loadModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//MARK:- View Initialize

- (void)setUpUI {
    
    [self.myViewHeader setHeader:NSLocalizedString(TITLE_FORGOT_PASSWORD, nil)];
    [Util createRoundedCorener:self.myViewResetPassword withCorner:5.0];
    [self changeLanguageForAllObjects];
    [self.myTxtFldEmail addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
}

- (void)setUpModel {
    
    
}

- (void)loadModel {
    
    
}


//MARK:- Private Functions

-(void)resetRequest{
    if([self forgotFormValidation]){
        
        //Send forgot request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:_myTxtFldEmail.text forKey:@"email"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FORGOT_PASSWORD withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
//                myStrForgotMessage = [response valueForKey:@"message"];
                [_myTxtFldEmail resignFirstResponder];
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
                [self.navigationController popViewControllerAnimated:YES];
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
    if(![Util validateTextField:_myTxtFldEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetForgotForm{
    [Util createBottomLine:_myTxtFldEmail withColor:UIColorFromHexCode(TEXT_BORDER)];
}

// Language Conversion
-(void) changeLanguageForAllObjects {
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(TITLE_FORGOT_PASSWORD, nil)];
        _myTxtFldEmail.placeholder = @"Email";
        [_myBtnResetPassword setTitle:@"RESET PASSWORD" forState:UIControlStateNormal];
        
    }
    
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(@"忘记密码", nil)];
        _myTxtFldEmail.placeholder = @"电子邮件";
        [_myBtnResetPassword setTitle:@"重设密码" forState:UIControlStateNormal];
    }
}

// Hide Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//MARK:- Button Actions
- (IBAction)myBtnResetAction:(id)sender {
    
    [self resetRequest];
}

/*! doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton {
    [self.myTxtFldEmail resignFirstResponder];
    [self resetRequest];
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
