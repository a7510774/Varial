//
//  AlertMessage.h
//  Varial
//
//  Created by jagan on 25/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface AlertMessage : UIView{
    float height;
}

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *subview;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
+ (id) sharedInstance;
- (void) showMessage :(NSString *) message;
- (void) showMessage :(NSString *) message withDuration:(float)duration;
@end
