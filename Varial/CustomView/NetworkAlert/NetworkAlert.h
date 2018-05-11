//
//  NetworkAlert.h
//  Varial
//
//  Created by jagan on 26/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NetworkDelegate

- (void)onButtonClick;

@end


@interface NetworkAlert : UIView

@property (assign) id<NetworkDelegate> delegate;
- (IBAction)triggered:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *view;
+ (id) sharedInstance;
- (void) hideShowAlert;
- (void)setNetworkHeader:(NSString*)title;
@end
