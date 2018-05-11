//
//  DonateForm.h
//  Varial
//
//  Created by jagan on 14/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "YesNoPopup.h"
#import "KLCPopup.h"

@interface DonateForm : UIViewController<UITableViewDataSource,UITableViewDelegate,YesNoPopDelegate>{
    YesNoPopup *donateConfirm;
    KLCPopup *donateConfirmPopup;
}


@property (nonatomic) NSUInteger donationType,donatedFrom;
@property (strong) NSDictionary *donateTo;
@property (strong) NSString *mediaBase, *donatorId;
@property (weak, nonatomic) IBOutlet UITableView *donateTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

//Donate form
@property (weak, nonatomic) IBOutlet UIView *donateForm;
@property (weak, nonatomic) IBOutlet UITextField *pointsToDonate;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *donateButton;
- (IBAction)cancelDonate:(id)sender;
- (IBAction)donate:(id)sender;

//Donate Success
@property (weak, nonatomic) IBOutlet UIView *donateSuccess;
@property (weak, nonatomic) IBOutlet UILabel *successMessage;
@property (weak, nonatomic) IBOutlet UILabel *remainingPoints;
@property (weak, nonatomic) IBOutlet UIView *successInnerView;

@end
