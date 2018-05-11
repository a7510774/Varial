//
//  ShoppingHome.h
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "SetEmailPopup.h"
#import "KLCPopup.h"
#import "NetworkAlert.h"

@interface ShoppingHome : UIViewController<UIWebViewDelegate,setEmailDelegate,NetworkDelegate>{
    SetEmailPopup *emailPopup;
    KLCPopup *KLCSetEmail,*KLCNetworkPopup,*emailConfirmationPopup;
    NetworkAlert *networkAlert,*emailConfirmation;
    BOOL isSetEmailAlert;
    KLCPopupLayout layout;
}

@property (strong) NSString *isOrderPurchasingUrl;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIButton *homeMenu;
- (IBAction)showHome:(id)sender;

@end
