//
//  SetPhoneNumberPopup.h
//  Varial
//
//  Created by Shanmuga priya on 3/8/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"


@protocol SetPhoneNumberDelegate

-(void)onSaveClick;
-(void)onCancelClick;
@end

@interface SetPhoneNumberPopup : UIView

@property (assign) id<SetPhoneNumberDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *country;
@property (weak, nonatomic) IBOutlet UITextField *countryCode;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *header;

- (IBAction)doSave:(id)sender;
- (IBAction)doCancel:(id)sender;

@end
