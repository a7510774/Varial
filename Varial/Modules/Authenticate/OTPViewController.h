//
//  OTPViewController.h
//  Varial
//
//  Created by user on 27/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface OTPViewController : UIViewController

@property (nonatomic) int gIntSecondsLeft;
@property (assign) BOOL gIsLoginBtnTapped;
@property (strong) NSString *gStrcountryId, *gStrPhoneNumber, *gStrPhoneName, *gStrOTPCode;
@property (weak, nonatomic) IBOutlet HeaderView *myViewHeader;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldOTP;
@property (weak, nonatomic) IBOutlet UILabel *myLabelTimer;
@property (weak, nonatomic) IBOutlet UIView *myViewResendOTP;
@property (weak, nonatomic) IBOutlet UIView *myViewSubmit;
@property (weak, nonatomic) IBOutlet UILabel *myLabelEnterOTPDescrptn;
@property (weak, nonatomic) IBOutlet UIButton *myBtnReSendOTP;
@property (weak, nonatomic) IBOutlet UIButton *myBtnValidateOTP;



@end
