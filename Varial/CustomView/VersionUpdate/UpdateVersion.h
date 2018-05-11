//
//  UpdateVersion.h
//  Varial
//
//  Created by vis-1674 on 03/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UpdateVersionDelegate

-(void)onUpdateClick;
-(void)onCancelClick;
@end

@interface UpdateVersion : UIView

@property (assign) id<UpdateVersionDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;

@end

