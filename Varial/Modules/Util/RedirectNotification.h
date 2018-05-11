//
//  RedirectNotification.h
//  Varial
//
//  Created by jagan on 18/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AlertMessage.h"
#import "FriendProfile.h"

@interface RedirectNotification : NSObject{
    UINavigationController *navigation;
    UIStoryboard *storyBoard;
    
}

//class methods
+ (id) sharedInstance;

//Instance methods
- (void)redirectGeneralNotificationTo:(int)index withObject:(NSDictionary *)information;
- (void)redirectFriendsNotification:(NSDictionary *)information;
- (void)redirectChatNotification:(NSMutableDictionary *)information;
@end
