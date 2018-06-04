//
//  SignUpViewController.h
//  Varial
//
//  Created by user on 25/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface SignUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet HeaderView *myViewHeader;

@property (weak, nonatomic) IBOutlet UITextField *myTxtFldEmail;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldName;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldPassword;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldConfirmPassword;
@property (weak, nonatomic) IBOutlet UIView *myViewSignUpBtn;
@property (weak, nonatomic) IBOutlet UIButton *myBtnSignUp;
@property (weak, nonatomic) IBOutlet UILabel *myLabelAlreadyHavAcc;
@property (weak, nonatomic) IBOutlet UIButton *myBtnLogin;



@end
