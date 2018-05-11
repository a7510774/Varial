//
//  SetEmailPopup.h
//  Varial
//
//  Created by Shanmuga priya on 3/8/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@protocol setEmailDelegate

-(void)onSaveClick;
-(void)onCancelClick;
@end

@interface SetEmailPopup : UIView
@property (assign) id<setEmailDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *emailID;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UILabel *header;





- (IBAction)doSave:(id)sender;
- (IBAction)doCancel:(id)sender;

@end
