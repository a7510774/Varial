//
//  Login.h
//  Varial
//
//  Created by jagan on 26/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AlertMessage.h"
#import "Util.h"
#import "Config.h"
#import "Language.h"
#import "KLCPopup.h"
#import "Language.h"
#import "ProfilePicture.h"
#import "TTTAttributedLabel.h"
#import "AppDelegate.h"

@interface Login : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,TTTAttributedLabelDelegate>{
    KLCPopup *signupPopup, *signinPopup, *forgotPopup, *phonePopup, *otpPopup;
    NSMutableArray *countries;
    UIPickerView *countryPicker;
    int visibleWindow,playerType;
    KLCPopupLayout layout;
    __block NSString *email;
}

//Signup Views
@property (assign) BOOL isNewUser;
@property (weak, nonatomic) IBOutlet UIView *signupView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
- (IBAction)doSignUp:(id)sender;

//Signin Views
@property (weak, nonatomic) IBOutlet UIView *signinView;
@property (weak, nonatomic) IBOutlet UITextField *signinEmail;
@property (weak, nonatomic) IBOutlet UITextField *signinPassword;
@property (weak, nonatomic) IBOutlet UIButton *siginInButton;
- (IBAction)doSignin:(id)sender;
- (IBAction)showForgotWindow:(id)sender;

//Forgot Password
@property (weak, nonatomic) IBOutlet UIView *forgotView;
@property (weak, nonatomic) IBOutlet UITextField *forgotEmail;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIView *myViewEmailSignUp;
@property (weak, nonatomic) IBOutlet UIView *myViewPhoneSignUp;
- (IBAction)doResetAction:(id)sender;

//Phone number view
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UITextField *countryField;
@property (weak, nonatomic) IBOutlet UITextField *countryCode;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *phoneName;
@property (weak, nonatomic) IBOutlet UIButton *phoneSubmitButton;
- (IBAction)doPhoneSubmit:(id)sender;
- (IBAction)doTouchCountryField:(id)sender;

//OTP Window
@property (weak, nonatomic) IBOutlet UIView *otpView;
@property (weak, nonatomic) IBOutlet UITextField *otpCode;
@property (weak, nonatomic) IBOutlet UIButton *otpSubmitButton;
@property (weak, nonatomic) IBOutlet UIButton *otpCancelBUtton;
@property (weak, nonatomic) IBOutlet UIButton *otpResendButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
- (IBAction)doOTPSubmit:(id)sender;
- (IBAction)doOTPResendAction:(id)sender;
- (IBAction)closeOTPWindow:(id)sender;


@property (weak, nonatomic) IBOutlet TTTAttributedLabel *FAQLabel;

//Main screens
@property (weak, nonatomic) IBOutlet UIButton *languageButton;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *loginBackImage;
@property (weak, nonatomic) IBOutlet UIButton *myBtnEnglishLanguage;
@property (weak, nonatomic) IBOutlet UIButton *myBtnChineseLanguage;
@property (weak, nonatomic) IBOutlet UILabel *myLabelDoUhaveAcc;
@property (weak, nonatomic) IBOutlet UIButton *myBtnSignUpWithEmail;
@property (weak, nonatomic) IBOutlet UIButton *myBtnSignUpWithPhone;

@property (weak, nonatomic) IBOutlet UIButton *myBtnLogin;
@property (weak, nonatomic) IBOutlet UIButton *myBtnChooseLanguage;
@property (weak, nonatomic) IBOutlet UIView *myViewSignIn;


@end
