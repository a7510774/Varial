//
//  EmailAlert.h
//  Varial
//
//  Created by jagan on 05/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"

@interface EmailAlert : UIView
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *message;
- (IBAction)resendEmail:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *resendLabel;

@end
