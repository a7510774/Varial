//
//  Notifications.h
//  Varial
//
//  Created by vis-1041 on 2/5/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Util.h"



@interface Notifications : NSObject{
    NSMutableDictionary *notificationTypes;
}

//class methods
+ (id) sharedInstance;

//instance methods
- (void) registerForNotification;
@end
