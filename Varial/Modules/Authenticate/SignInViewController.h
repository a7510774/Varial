//
//  SignInViewController.h
//  Varial
//
//  Created by user on 25/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface SignInViewController : UIViewController
@property (weak, nonatomic) IBOutlet HeaderView *myViewHeader;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldUsername;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldPassword;
@property (weak, nonatomic) IBOutlet UIView *myViewLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *myBtnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *myBtnForgotPassword;

@property (weak, nonatomic) IBOutlet UILabel *myLabelAlreadyHavAcc;
@property (weak, nonatomic) IBOutlet UIButton *myBtnSignUp;




@end
