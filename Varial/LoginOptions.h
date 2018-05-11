//
//  LoginOptions.h
//  Varial
//
//  Created by jagan on 30/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "KLCPopup.h"
#import "NetworkAlert.h"

@interface LoginOptions : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    KLCPopup *setEmailPopup, *setPhonePopup, *otpPopup, *emailConfirmationPopup, *changeEmailPopup, *changePhonePopup;
    NSArray *textFields;
    NSMutableArray *countries;
    UIPickerView *countryPicker;
    NetworkAlert *emailConfirmation;
    NSTimer *countDown;
    int secondsLeft;
    NSString *countryId,*oldCountryId,*oldCounCode, *oldPhNo;
    BOOL havingEmail, havingPhoneNumber ,emailStatus;
    int visibleWindow;
    KLCPopupLayout layout;   
    
}

@property (nonatomic) BOOL gIsPresentSettingsScreen;

//Set email id
@property (weak, nonatomic) IBOutlet UIView *setEmailView;
@property (weak, nonatomic) IBOutlet UITextField *setEmail;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *saveEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelEmailButton;
- (IBAction)setEmailAction:(id)sender;
- (IBAction)cancelSetEmail:(id)sender;


//OTP window
@property (weak, nonatomic) IBOutlet UILabel *otpMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *otpView;
@property (weak, nonatomic) IBOutlet UITextField *otpCode;
@property (weak, nonatomic) IBOutlet UIButton *otpSubmitButton;
@property (weak, nonatomic) IBOutlet UIButton *otpResendButton;
- (IBAction)submitOTP:(id)sender;
- (IBAction)resendOTP:(id)sender;
- (IBAction)cancelOTP:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *otpCancelButton;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;


//Set Phone number
@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UITextField *country;

@property (weak, nonatomic) IBOutlet UITextField *countryCode;
@property (weak, nonatomic) IBOutlet UIButton *savePhoneNumberButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelSetPhoneWindow;
- (IBAction)setPhoneNumber:(id)sender;
- (IBAction)cancelPhoneWindow:(id)sender;
- (IBAction)doTouchCountryField:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumber;


//Change email window
@property (weak, nonatomic) IBOutlet UIView *changeEmailView;
@property (weak, nonatomic) IBOutlet UITextField *changeEmail;
@property (weak, nonatomic) IBOutlet UIButton *changeEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *closeEmailButton;
- (IBAction)changeEmail:(id)sender;
- (IBAction)closeChangeEmail:(id)sender;

//Change phone number
@property (weak, nonatomic) IBOutlet UIView *changePhoneView;
@property (weak, nonatomic) IBOutlet UITextField *oldCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *oldPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *changeCountry;
@property (weak, nonatomic) IBOutlet UITextField *neCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *nePhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *changePhoneSaveButton;
@property (weak, nonatomic) IBOutlet UIButton *closeChangePhoneButton;
- (IBAction)changePhoneNumber:(id)sender;
- (IBAction)closeChangePhoneWindow:(id)sender;


//Main view
@property (weak, nonatomic) IBOutlet HeaderView *header;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
- (IBAction)openPhoneWindow:(id)sender;
- (IBAction)openEmailWindow:(id)sender;

@end
