//
//  ClubPromotionsDetails.h
//  Varial
//
//  Created by jagan on 29/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "YesNoPopup.h"
#import "NetworkAlert.h"
#import "GetDirections.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@interface ClubPromotionsDetails : UIViewController<YesNoPopDelegate,NetworkDelegate>{
    
    NSString *mediaBase, *instructions, *registrationToken;
    YesNoPopup *registerConfirm;
    NetworkAlert *activationCode, *freeBies;
    KLCPopup *registerConfirmPopup, *activationCodePopup,*freeBiesPopup;
    NSMutableDictionary *shopLocation;
  //  BOOL isRegistered;
    int registeredStatus;
}

@property (strong) NSString *promotionId;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

// Club promotion detail header page
@property(nonatomic, strong)IBOutlet UIImageView *profileImage;
@property(nonatomic, strong)IBOutlet UILabel *name;
@property(nonatomic, strong)IBOutlet UILabel *subName;
@property(nonatomic, strong)IBOutlet UILabel *address;
@property(nonatomic, strong)IBOutlet UILabel *points;
- (IBAction)registerBuzzardRun:(id)sender;
- (IBAction)getDirection:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *registerLabel;
@property (weak, nonatomic) IBOutlet UIButton *generalButton;
@property (weak, nonatomic) IBOutlet UITextView *generalInformation;
- (IBAction)showFreeBies:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *informationView;

@end
    