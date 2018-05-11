//
//  LocalStorageManager.m
//  Varial
//
//  Created by vis-1674 on 02/06/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "LocalStorageManager.h"
#import "ViewController.h"

@implementation LocalStorageManager


+ (instancetype) sharedInstance{
    static LocalStorageManager *localStorage = nil;
    @synchronized(self) {
        if (localStorage == nil) {
            localStorage = [[self alloc] init];
        }
    }
    return localStorage;
}

+(void)localStorage:(NSString *)keyType Response:(NSMutableArray *)currentArray feedType:(int)type
{
    int arrayCount = (int)[currentArray count];
    arrayCount = (arrayCount >= 10)? 10 : arrayCount ;
    
    NSMutableArray *finalArray = [[NSMutableArray alloc]init];
    for (int i=0; i < arrayCount; i++) {
        if ([[[currentArray objectAtIndex:i] valueForKey:@"is_local"] isEqualToString:@"false"]) {
            [finalArray addObject:[currentArray objectAtIndex:i]];
        }
    }
    
// GET PREVIOUS STORED RESPONSE FROM USER DEFAULTS
    NSMutableDictionary *response ;
    if ([keyType isEqualToString:@"FEED"]) {
        if (type == 1) {
            response = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PublicFeedsList"] mutableCopy];
        }
        else if (type == 2) {
            response = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateFeedsList"]mutableCopy];
        }
        else if (type == 3) {
            response = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TeamAFeedsList"]mutableCopy];
        }
        else if (type == 4) {
            response = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TeamBFeedsList"]mutableCopy];
        }
        else if (type == 6) {
            response = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PopularFeedsList"]mutableCopy];
        }
        
        [response setObject:finalArray forKey:@"feed_list"];
        NSDictionary *finalDict = [NSDictionary dictionaryWithDictionary:response];
        [self assignOfflineFeeds:finalDict Type:type];
    }
    else if([keyType isEqualToString:@"GLOBALNOTIFICATION"])
    {
        response = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralNotificationList"]mutableCopy];
        [response setObject:finalArray forKey:@"general_notification_details"];
        NSDictionary *finalDict = [NSDictionary dictionaryWithDictionary:response];
        [Util setInDefaults:finalDict withKey:@"GeneralNotificationList"];
    }
    else if([keyType isEqualToString:@"FRIENDNOTIFICATION"])
    {
        response = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FriendNotificationList"]mutableCopy];
        [response setObject:finalArray forKey:@"friend_notifications"];
        NSDictionary *finalDict = [NSDictionary dictionaryWithDictionary:response];
        [Util setInDefaults:finalDict withKey:@"FriendNotificationList"];
    }
    
}

+(void)assignOfflineFeeds:(NSDictionary *)response Type:(int)type
{
    if (type == 1 ) {
        [Util setInDefaults:response withKey:@"PublicFeedsList"];
    }
    else if (type == 2) {
        [Util setInDefaults:response withKey:@"PrivateFeedsList"];
    }
    else if (type == 3) {
        [Util setInDefaults:response withKey:@"TeamAFeedsList"];
    }
    else if (type == 4) {
        [Util setInDefaults:response withKey:@"TeamBFeedsList"];
    }
    else if (type == 6) {
        [Util setInDefaults:response withKey:@"PopularFeedsList"];
    }
}

@end
