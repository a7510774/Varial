//
//  CheckInViewController.h
//  Varial
//
//  Created by vis-1674 on 2016-02-09.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduMap.h"
#import <CoreLocation/CoreLocation.h>
#import "Util.h"
#import "Config.h"
#import "HeaderView.h"
#import "LocationManager.h"
#import "AppDelegate.h"

@interface CheckInViewController : UIViewController<BaiduDelegate, HeaderViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    KLCPopup *checkInPopup;
    NSArray *textFields;
    UIPickerView *statePicker, *cityPicker;
    IBOutlet UIView *MapView;
    BaiduMap* baiduMap;
    float lattitude, longitude;
    CLLocationManager *locationManager;
    NSMutableArray *stateList, *cityList;
    NSString *selectedStateId;
    KLCPopupLayout layout;
    AppDelegate *appDelegate;
}


@property (weak, nonatomic) IBOutlet HeaderView *headerView;


//Checkin Window
@property (weak, nonatomic) IBOutlet UIView *checkinView;
@property (weak, nonatomic) IBOutlet UITextField *txtCheckinAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UIButton *checkinSubmitButton;
@property (weak, nonatomic) IBOutlet UIButton *checkinCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *checkinButton;

- (IBAction)submitCheckIn:(id)sender;
- (IBAction)cancelCheckIn:(id)sender;
- (IBAction)btnTouch_CheckIn:(id)sender;

@end
