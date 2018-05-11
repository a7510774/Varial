//
//  SignUpWithPhoneViewController.h
//  Varial
//
//  Created by user on 26/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface SignUpWithPhoneViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    
    NSMutableArray *myAryCountries;
    UIPickerView *myCountryPicker;
    int playerType;
}
@property (assign) BOOL isNewUser;
@property (weak, nonatomic) IBOutlet HeaderView *myViewHeader;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldCountry;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldMobileCode;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *myTxtFldName;
@property (weak, nonatomic) IBOutlet UIButton *myBtnSubmit;
@property (weak, nonatomic) IBOutlet UIView *myViewSubmitBtn;



@end
