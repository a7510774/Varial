//
//  Notification.h
//  Varial
//
//  Created by Shanmuga priya on 3/4/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "NetworkAlert.h"
#import "KLCPopup.h"
#import "SetEmailPopup.h"
@interface Notification : UIViewController<NetworkDelegate,setEmailDelegate>{
    NetworkAlert *networkAlert;
    KLCPopup *KLCNetworkPopup,*KLCSetEmail,*emailConfirmationPopup;
    SetEmailPopup *setEmail;
    NSString *countryId;
    NetworkAlert *emailConfirmation;
    BOOL emailPop,pushStatus,emailStatus;
    KLCPopupLayout layout;
}

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UISwitch *emailSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pushSwitch;


- (IBAction)changeEmailSwitch:(id)sender;
- (IBAction)changePushSwitch:(id)sender;

@end
