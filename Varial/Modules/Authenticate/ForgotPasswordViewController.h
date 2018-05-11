//
//  ForgotPasswordViewController.h
//  Varial
//
//  Created by user on 26/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface ForgotPasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *myTxtFldEmail;
@property (weak, nonatomic) IBOutlet UIView *myViewResetPassword;
@property (weak, nonatomic) IBOutlet HeaderView *myViewHeader;
@property (weak, nonatomic) IBOutlet UIButton *myBtnResetPassword;

@end
