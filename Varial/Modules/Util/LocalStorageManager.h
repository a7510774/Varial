//
//  LocalStorageManager.h
//  Varial
//
//  Created by vis-1674 on 02/06/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalStorageManager : NSObject


+ (instancetype)sharedInstance;
+(void)localStorage:(NSString *)keyType Response:(NSMutableArray *)currentArray feedType:(int)type;
+(void)assignOfflineFeeds:(NSDictionary *)response Type:(int)type;

@end
