//
//  EditInfoPopup.h
//  Varial
//
//  Created by Shanmuga priya on 2/29/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EditInfoPopupDelegate


-(void)onChangePhoneNoClick;
-(void)onChangeEmailClick;
-(void)onChangeLocationClick;

@end



@interface EditInfoPopup : UIView
@property (assign) id<EditInfoPopupDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UILabel *header;


- (IBAction)doChangePhoneNumber:(id)sender;
- (IBAction)doChangeEmail:(id)sender;
- (IBAction)doChangeLocation:(id)sender;

@end
