//
//  Notifications.m
//  Varial
//
//  Created by vis-1041 on 2/5/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Notifications.h"
#import "RedirectNotification.h"
#import "AGPushNoteView.h"
#import "LNNotificationsUI.h"

@implementation Notifications{
    
}

//register Notification
+ (id) sharedInstance{

    static Notifications *notification = nil;
    @synchronized(self) {
        if(notification == nil){
            notification = [[Notifications alloc] init];
            [notification buildNotificationTypes];
        }
    }
    return notification;
    
}

//types of notifications
- (void) buildNotificationTypes{
    
    notificationTypes = [[NSMutableDictionary alloc] init];
    [notificationTypes setValue:[NSNumber numberWithInt:1] forKey:@"email_notification"];
    [notificationTypes setValue:[NSNumber numberWithInt:2] forKey:@"general_notification"];
    [notificationTypes setValue:[NSNumber numberWithInt:3] forKey:@"friend_notification"];
    [notificationTypes setValue:[NSNumber numberWithInt:4] forKey:@"team_notification"];
    [notificationTypes setValue:[NSNumber numberWithInt:5] forKey:@"chat_notification"];

}

//Register for the Notification
- (void) registerForNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processPushNotification:) name:@"PushNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processTappedNotification:) name:@"TappedNotification" object:nil];
}

//To process the type of the notification
- (void) processPushNotification:(NSNotification *) data{
    
    NSMutableDictionary *notification = [data.userInfo mutableCopy];
    NSLog(@"Notification received data: %@",notification);
    //check for the notification type
    switch ([[notificationTypes valueForKey:[notification objectForKey:@"type"]] integerValue]) {
        case 1:
            //set the default value
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isEmailVerified"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"Notification Data: %@",notification);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ConfirmEmailNotification" object:nil userInfo:notification];
            break;
        case 2:
            [self showLocalNotification:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GeneralNotification" object:nil userInfo:notification];
            break;
        case 3:
            [self showLocalNotification:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendNotification" object:nil userInfo:notification];            
            break;
        case 4:
            [self showLocalNotification:notification];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"TeamNotification" object:nil userInfo:notification];
            break;
        default:
            NSLog(@"Received Notification Type : %@",[notification objectForKey:@"type"]);
            break;
    }
}

//Show local notification
- (void) showLocalNotification:(NSMutableDictionary *)messageBody{
    
    UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
    // UIViewController *currentView = [navigation topViewController];
    
    //Not showing notificatoin while not in navigation mode
    if ([[notificationTypes valueForKey:[messageBody objectForKey:@"type"]] integerValue] == 3) {
        if ([navigation isKindOfClass:[UINavigationController class]]) {
            [self showNotification:messageBody];
        } 
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate refreshNotification];
    }
    else {
        NSDictionary *notificationBody = [messageBody objectForKey:@"data"];
        if ([[notificationBody valueForKey:@"redirection_type"] intValue] == 17) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate refreshNotification];
        }
        [self showNotification:messageBody];
    }
    
}

- (void)showNotification:(NSMutableDictionary *)messageBody{
    
     UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    NSDictionary *notificationBody = [messageBody objectForKey:@"data"];
    if (notificationBody[@"message"] && [notificationBody valueForKey:@"message"] != nil)
    {
        AudioServicesPlaySystemSound(1002);
        LNNotification* notification = [LNNotification notificationWithMessage:[notificationBody valueForKey:@"message"]];
        notification.title = @"Varial";
        
        //Check user in navigation mode
        if ([navigation isKindOfClass:[UINavigationController class]]) {
            notification.defaultAction = [LNNotificationAction actionWithTitle:@"Varial" handler:^(LNNotificationAction *action) {
                 [self redirect:messageBody];
            }];
        }
        
        //Add the notification to noticication center
        [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"varial_app"];
        
        if ([navigation isKindOfClass:[ProfilePicture class]] || [navigation isKindOfClass:[PlayerType class]]) {
            NSMutableDictionary *data = [messageBody objectForKey:@"data"];
            NSString *count = [NSString stringWithFormat:@"%@",[data objectForKey:@"general_notification_count"]];
            [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"NotificationCount"];
        }
    }
}

//To process the type of the notification
- (void) processTappedNotification:(NSNotification *) data{
    NSMutableDictionary *notification = [data.userInfo mutableCopy];
    [self redirect:notification];
}


//Redirects to pages
- (void)redirect:(NSMutableDictionary *)notification{
    
    NSDictionary *notificationBody = [notification objectForKey:@"data"];    
    
    //check for the notification type
    switch ([[notificationTypes valueForKey:[notification objectForKey:@"type"]] integerValue]) {
        case 2:
            if (notificationBody[@"redirection_type"]){
                //General notification
                [[RedirectNotification sharedInstance] redirectGeneralNotificationTo:[[notificationBody valueForKey:@"redirection_type"] intValue] withObject:notificationBody];
            }
            break;
        case 3:
            //Friends notification
            [[RedirectNotification sharedInstance] redirectFriendsNotification:notification];
            break;
        case 4:
            if (notificationBody[@"redirection_type"]){
                //Team notification
                [[RedirectNotification sharedInstance] redirectGeneralNotificationTo:[[notificationBody valueForKey:@"redirection_type"] intValue] withObject:notificationBody];
            }
            break;
        case 5:
            //Chat notification
            [[RedirectNotification sharedInstance] redirectChatNotification:notification];
            break;
        default:
            NSLog(@"Received Notification Type : %@",[notification objectForKey:@"type"]);
            break;
    }
    
}

@end
