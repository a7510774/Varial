//
//  CheckInPopup.h
//  Varial
//
//  Created by jagan on 07/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckInPopupDelegate
-(void)onCheckInClick;
-(void)onCheckInCancelClick;

@end

@interface CheckInPopup : UIView

@property (assign) id<CheckInPopupDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *header;

- (id)init;
- (IBAction)doCheckIn:(id)sender;
- (IBAction)doCancel:(id)sender;

@end
