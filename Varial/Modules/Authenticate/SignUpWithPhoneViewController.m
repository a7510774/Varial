//
//  SignUpWithPhoneViewController.m
//  Varial
//
//  Created by user on 26/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "SignUpWithPhoneViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "OTPViewController.h"

@interface SignUpWithPhoneViewController ()

@end

@implementation SignUpWithPhoneViewController

NSString *myStrCountryId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
    [self setUpModel];
    [self loadModel];
}


//MARK:- View Initialize

- (void)setUpUI {

    [self.myViewHeader setHeader:NSLocalizedString(TITLE_SIGNUP_WITH_MOBILE, nil)];
    [Util createRoundedCorener:self.myViewSubmitBtn withCorner:5.0];
    [self.myTxtFldName addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    myAryCountries = [defaults objectForKey:@"country_list"];

    if([myAryCountries count] == 0)
        [self getCountryList];

    // Auto populate the county picker
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_myTxtFldCountry sendActionsForControlEvents:UIControlEventEditingDidBegin];
        [_myTxtFldCountry becomeFirstResponder];
    });
    
    [self changeLanguageForAllObjects];
    //Set country field input type to UIPickerview
    myCountryPicker = [[UIPickerView alloc] init];
    myCountryPicker.delegate = self;
    myCountryPicker.dataSource = self;
    [myCountryPicker selectRow:0 inComponent:0 animated:NO];
    myCountryPicker.showsSelectionIndicator = YES;
    myCountryPicker.frame = CGRectMake(0, self.view.frame.size.height-
                                       myCountryPicker.frame.size.height-50, 320, 230);
    _myTxtFldCountry.inputView = myCountryPicker;
}

- (void)setUpModel {
    
}

- (void)loadModel {


}

//MARK:- Picker View Delegate
#pragma mark - Picker View Data source
//set number of components to select
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//set number of rows for the picker
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [myAryCountries count];
}


#pragma mark- Picker View Delegate
//track the selected picker data
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

    NSDictionary *country = [myAryCountries objectAtIndex:row];
    [_myTxtFldCountry setText:[country objectForKey:@"country_name"]];
    [_myTxtFldMobileCode setText:[country valueForKey:@"country_pin_code"]];
    myStrCountryId = [country valueForKey:@"country_id"];

}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    NSDictionary *country = [myAryCountries objectAtIndex:row];
    return [country objectForKey:@"country_name"];

}
//
////MARK:- Api Call

-(void)phoneSubmitRequest{
    if([self phoneNumberFormValidation]){

        //Send phone signup request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:myStrCountryId forKey:@"country_id"];
        [inputParams setValue:_myTxtFldName.text forKey:@"name"];
        [inputParams setValue:_myTxtFldPhoneNumber.text forKey:@"phone_number"];

        [Util appendDeviceMeta:inputParams];

        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PHONE_NUMBER withCallBack:^(NSDictionary * response){

            //check for new user
            _isNewUser = [[response valueForKey:@"new_registeration"] boolValue];
            playerType = [[response valueForKey:@"player_type_id"] intValue];
            if (!_isNewUser) {
                [self controlThePalyerLevel:response];
            }

            if ([[response valueForKey:@"status"] boolValue]) {
                
//                myIntSecondsRem = (int) [[response valueForKey:@"timer"] integerValue];
                UIStoryboard* aMainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
                
                OTPViewController *aOTP = [aMainStoryboard instantiateViewControllerWithIdentifier:@"OTP"];
                
                if(![[response valueForKey:@"view_otp"] boolValue])
                {
                    aOTP.gStrOTPCode =  [response valueForKey:@"OTP"];
                }
                aOTP.gIntSecondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
                aOTP.gStrcountryId = myStrCountryId;
                aOTP.gStrPhoneName = _myTxtFldName.text;
                aOTP.gStrPhoneNumber = _myTxtFldPhoneNumber.text;
                [self.navigationController pushViewController:aOTP animated:YES];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }

        } isShowLoader:YES];

    }

}
//
////MARK:- Private Functions

-(BOOL)phoneNumberFormValidation{
    [self resetPhoneForm];

    //Check coutry is choosed
    if([[_myTxtFldCountry.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_myTxtFldCountry withErrorMessage:NSLocalizedString(COUNTRY_EMPTY, nil)];
        return FALSE;
    }

    //Check phone number
    //    if([[_phoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    //    {
    //        [Util showErrorMessage:_countryField withErrorMessage:NSLocalizedString(PHONE_NUMBER_EMPTY, nil)];
    //        return FALSE;
    //    }

    if(![Util validateNumberField:_myTxtFldPhoneNumber withValueToDisplay:PHONE_NO withMinLength:PHONE_MIN withMaxLength:PHONE_MAX])
    {
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

//Reset the phone form
- (void)resetPhoneForm{
    [Util createBottomLine:_myTxtFldCountry withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_myTxtFldPhoneNumber withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_myTxtFldName withColor:UIColorFromHexCode(TEXT_BORDER)];

}

// Language Conversion
-(void) changeLanguageForAllObjects {
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(TITLE_SIGNUP_WITH_MOBILE, nil)];
        _myTxtFldCountry.placeholder = @"Country";
        _myTxtFldPhoneNumber.placeholder = @"Enter your phone number";
        _myTxtFldName.placeholder = @"Name";
        [_myBtnSubmit setTitle:@"SUBMIT" forState:UIControlStateNormal];
    }
    
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        [self.myViewHeader setHeader:NSLocalizedString(@"与电话的注册", nil)];
        _myTxtFldCountry.placeholder = @"国家";
        _myTxtFldPhoneNumber.placeholder = @"输入你的电话号码";
        _myTxtFldName.placeholder = @"名称";
        [_myBtnSubmit setTitle:@"提交" forState:UIControlStateNormal];
    }
}

//Flags for control the skater/crew/media privileges
- (void)controlThePalyerLevel:(NSDictionary *)response{
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_bazzardrun"] boolValue] forKey:@"can_participate_in_bazzardrun"];
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_clubpromotion"] boolValue] forKey:@"can_participate_in_clubpromotion"];
    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_shop_offers"] boolValue] forKey:@"can_show_shop_offers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void) getCountryList{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];

    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:COUNTRY_LIST withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:[response objectForKey:@"country_list"] forKey:@"country_list"];
            myAryCountries = [defaults objectForKey:@"country_list"];
        }
    } isShowLoader:NO];
}

// Hide Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//MARK:- Buttons Action
- (IBAction)myBtnSubmitAction:(id)sender {
    
    [self phoneSubmitRequest];
}

- (IBAction)myTxtFldCountryEditBegin:(id)sender {
    
    if ([_myTxtFldCountry.text isEqualToString:@""]) {
        
        if ([myAryCountries count] > 0) {
            [self pickerView:myCountryPicker didSelectRow:0 inComponent:0];
            [_myTxtFldCountry setTextColor:[UIColor blackColor]];
        }
    }
}


//
/*! doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton {
    [self.myTxtFldName resignFirstResponder];
    [self phoneSubmitRequest];
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
