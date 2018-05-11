//
//  YesNoPopup.h
//  Varial
//
//  Created by jagan on 17/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YesNoPopDelegate

-(void)onYesClick;
-(void)onNoClick;

@end

@interface YesNoPopup : UIView
@property (assign) id<YesNoPopDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
- (IBAction)doYes:(id)sender;
- (IBAction)doNo:(id)sender;

- (void)setPopupHeader:(NSString*)title;

@end
