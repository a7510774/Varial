//
//  ChatNotification.h
//  Tagging
//
//  Created by Velan Info Services on 2016-07-13.
//  Copyright © 2016 Velan Info Services. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPMessage.h"

@interface ChatNotification : UIView{
    NSTimer *timer;
}
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *subHeader;
+ (id) sharedInstance;
- (void) showNotification :(NSString *) imageUrl withTitle:(NSString *)title withSubtitle:(NSString *)subTitle;
- (void) setMessageAction:(XMPPMessage *)message;
- (IBAction)openChatWindow:(id)sender;
@property (strong, nonatomic) XMPPMessage *message;
@property (weak, nonatomic) IBOutlet UIButton *clickView;

@property (strong, nonatomic) void (^messageTapAction)(NSString *message);
@end
