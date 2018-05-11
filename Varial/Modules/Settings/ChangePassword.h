//
//  ChangePassword.h
//  Varial
//
//  Created by jagan on 30/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLCPopup.h"
#import "Util.h"
#import "HeaderView.h"

@interface ChangePassword : UIViewController{
    KLCPopup *setEmailPopup, *emailNotification, *emailConfirmationPopup;
    NSArray *textFields;
    int visibleWindow;
}

//Main view
@property (weak, nonatomic) IBOutlet HeaderView *header;
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *nePassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
- (IBAction)changePassword:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *passwordView;

//Set email id
@property (weak, nonatomic) IBOutlet UIView *setEmailView;
@property (weak, nonatomic) IBOutlet UITextField *setEmail;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *setConfirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *saveEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelEmailButton;
- (IBAction)setEmailAction:(id)sender;
- (IBAction)cancelSetEmail:(id)sender;

@end
