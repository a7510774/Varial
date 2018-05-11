//
//  CheckInViewController.m
//  Varial
//
//  Created by vis-1674 on 2016-02-09.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "CheckInViewController.h"
#import "CreatePostViewController.h"

@interface CheckInViewController ()

@end

@implementation CheckInViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    stateList = [[NSMutableArray alloc] init];
    cityList = [[NSMutableArray alloc] init];
    textFields = [[NSArray alloc] initWithObjects:_txtState,_txtCheckinAddress, nil];
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
    
    [[LocationManager sharedManager] startUpdateLocation];
    [self designTheView];
    [self createPopUpWindows];
   // [self getStateList];
    
    _headerView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)designTheView
{
    [_headerView setHeader:NSLocalizedString(CHECK_IN_TITLE, nil)];

    [_headerView.logo setHidden:YES];
    
    _checkinView.hidden = YES;
    
    [self showBaiduMap];
    
    // Checkin Popup Design
    for (UITextField *field in textFields){
        [Util createBottomLine:field withColor:UIColorFromHexCode(TEXT_BORDER)];
    }
    [Util createRoundedCorener:_checkinView withCorner:5];
    [Util createRoundedCorener:_checkinSubmitButton withCorner:3];
    [Util createRoundedCorener:_checkinCancelButton withCorner:3];
    [Util createRoundedCorener:_checkinButton withCorner:3];
    
    
    // State Picker
    statePicker = [[UIPickerView alloc] init];
    statePicker.delegate = self;
    statePicker.dataSource = self;
    statePicker.showsSelectionIndicator = YES;
    statePicker.frame = CGRectMake(0, self.view.frame.size.height-
                                     statePicker.frame.size.height-50, self.view.frame.size.width, 150);
    _txtState.inputView = statePicker;
    
    // City Picker
    cityPicker = [[UIPickerView alloc] init];
    cityPicker.delegate = self;
    cityPicker.dataSource = self;
    cityPicker.showsSelectionIndicator = YES;
    cityPicker.frame = CGRectMake(0, self.view.frame.size.height-
                                   statePicker.frame.size.height-50, self.view.frame.size.width, 150);
    _txtCity.inputView = cityPicker;

}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _txtCity) {
        if ([_txtState.text isEqualToString:@""]) {
            [textField resignFirstResponder];
        }
        else
        {
            if ([cityList count] > 0) {
                [self pickerView:cityPicker didSelectRow:0 inComponent:0];
            }
        }
        
    }
    if (textField == _txtState) {
        if ([_txtState.text isEqualToString:@""]) {
            if ([stateList count] > 0) {
                [self pickerView:statePicker didSelectRow:0 inComponent:0];
            }
        }
    }
}

-(void)showBaiduMap
{
    // CUSTOM MAPVIEW
    baiduMap = [[BaiduMap alloc] initWithFrame:CGRectMake(2, 2, MapView.bounds.size.width - 4, MapView.bounds.size.height - 4)];
    baiduMap.delegate = self;
    baiduMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [MapView addSubview:baiduMap];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(getlocation)
                                   userInfo:nil
                                    repeats:NO];
    
}

-(void)getlocation
{
    // Show annotation Image
 //   UIImage *img = [UIImage imageNamed:@"checkinActive.png"];
 //   NSData *imagedata = UIImageJPEGRepresentation(img, 1); // annotation Image
    
    CLLocationCoordinate2D coor = [[LocationManager sharedManager] locationCoordinate];
    [baiduMap addAnnotation:coor Title:nil Subtitle:nil Image:nil];
    
    lattitude = coor.latitude;
    longitude = coor.longitude;
}

//Get State List
-(void) getStateList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setObject:@"2" forKey:@"country_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:STATE_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            [stateList addObjectsFromArray:[response objectForKey:@"state_details"]];
            selectedStateId = @"";
        }
    } isShowLoader:YES];
    
}

//Get City List
-(void) getCityList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setObject:@"2" forKey:@"country_id"];
    [inputParams setObject:selectedStateId forKey:@"state_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CITY_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            //[cityList addObjectsFromArray:[response objectForKey:@""]];
            cityList = [response objectForKey:@"city_details"];
            [cityPicker reloadAllComponents];
            [cityPicker selectRow:0 inComponent:0 animated:YES];
        }
    } isShowLoader:YES];
    
}

- (void) createPopUpWindows
{
    checkInPopup = [KLCPopup popupWithContentView:self.checkinView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
}

#pragma mark - Picker View Data source
//set number of components to select
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//set number of rows for the picker
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
   
    if (pickerView == statePicker) {
        return [stateList count];
    }
    else if (pickerView == cityPicker){
        return [cityList count];
    }
    
    return 0;
}

#pragma mark- Picker View Delegate
//track the selected picker data
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView == statePicker) {
        NSDictionary *state = [stateList objectAtIndex:row];
       [_txtState setText:[state objectForKey:@"state_name"]];
        selectedStateId = [state objectForKey:@"id"];
       // [self getCityList];
        [_txtCity setValue:[NSString stringWithFormat:@"Select City"] forKeyPath:@"_placeholderLabel.text"];
    }
    else if (pickerView == cityPicker)
    {
        NSDictionary *city = [cityList objectAtIndex:row];
       [_txtCity setText:[city objectForKey:@"city_name"]];
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (pickerView == statePicker) {
        NSDictionary *state = [stateList objectAtIndex:row];
        return [state objectForKey:@"state_name"];
    }
    else if(pickerView == cityPicker) {
        NSDictionary *city = [cityList objectAtIndex:row];
        return [city objectForKey:@"city_name"];
    }
    return nil;
    
}
//** End of Picker View Deleage **/

- (IBAction)btnTouch_CheckIn:(id)sender
{
    [self.checkinView setHidden:NO];
    [checkInPopup showWithLayout:layout];
}

- (IBAction)submitCheckIn:(id)sender
{
    if ([self checkinValidation]) {
        // Parse data to server
        if (lattitude != 0.0 && longitude != 0.0) {
            
            CreatePostViewController *postCreate = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers]count] - 2 ];
            [postCreate.inputParams setValue:_txtCheckinAddress.text forKey:@"check_in_name"];
            [postCreate.inputParams setValue:[NSString stringWithFormat:@"%lf",lattitude] forKey:@"check_in_latitude"];
            [postCreate.inputParams setValue:[NSString stringWithFormat:@"%lf",longitude] forKey:@"check_in_longitude"];
            [postCreate.inputParams setValue:_txtState.text forKey:@"check_in_state"];
            [postCreate.inputParams setValue:_txtCity.text forKey:@"check_in_city"];
            [postCreate.inputParams setValue:@"China" forKey:@"check_in_country"];
            [self.navigationController popViewControllerAnimated:YES];
            
            [checkInPopup dismiss:YES];
        }
        else{
            if (lattitude == 0.0 && longitude == 0.0) {
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(COULD_NOT_ACCESS_CURRENT_LOCATION, nil)];
            }
        }
    }
}

- (IBAction)cancelCheckIn:(id)sender
{
    selectedStateId = @"";
    [checkInPopup dismiss:YES];
}

-(BOOL)checkinValidation
{
    
    if(![Util validateLocationField:_txtCheckinAddress withValueToDisplay:@"Place Name" withIsEmailType:FALSE withMinLength:LOCATION_NAME_MIN withMaxLength:LOCATION_NAME_MAX])
    {
        return FALSE;
    }
    
    return TRUE;
}

// Delegate method for Baidu map
- (void)SearchResults :(NSMutableArray *)name
{
    
}

// Delegate method for Baidu map
-(void)mapView:(BaiduMap *)didSelectAnnotaion
{
    NSLog(@"custom Annotation Cliked");
}

// Delegate method for Baidu map
-(void)mapViewbubble:(BaiduMap *)didSelectAnnotaionViewBubble
{
    NSLog(@"custom Annotation Popup Cliked");
}
@end
