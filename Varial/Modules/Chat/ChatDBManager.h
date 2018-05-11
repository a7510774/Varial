//
//  ChatDBManager.h
//  EJabberChat
//
//  Created by jagan on 25/05/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPServer.h"
#import "DBManager.h"
#import "FriendsChat.h"

@interface ChatDBManager : NSObject{
    UILabel *badgeCount, *badgeHide;
    UIView *windowViews;
}

@property (strong) NSMutableDictionary *avatarImages;

+ (instancetype) sharedInstance;
- (void)createChatBadge;
- (void)registerForNotification;
- (void) saveMessageInDataBase:(XMPPMessage *)messageData isOutGoing:(BOOL) outGoing mediaURL:(NSString *)mediaURL;
- (NSString *)getChatHistoryQuery:(NSString *)sender receiver:(NSString *)receiver;
- (NSString *)getTeamChatHistoryQuery:(NSString *)receiver;
- (long)getTimeFromMessage:(XMPPMessage *)message isOutGoing:(BOOL)outGoing;
- (NSMutableArray *)getNameAndImage:(XMPPMessage *)message isOutGoing:(BOOL)outGoing;
- (void)destroyUserChat;
- (void)resetUnreadCount:(NSString *)toId;
- (void)sendSeenACKToMessages:(NSString *)jID;
- (void)updateUserNameAndImage:(NSMutableDictionary *)users;
- (void)addPlayerInformation:(XMPPMessage *)message isOutGoing:(BOOL) outGoing;
- (void)updateMessageStatus:(NSString *)messageId toStatus:(int)status;
- (BOOL)deleteMessage:(NSString *)messageId;
- (BOOL)deleteTeamMessage:(NSString *)messageId;
- (void)updateImageSource:(NSString *)messageId withLocalUrl:(NSString *)mediaUrl;
- (void)destroyUserChat:(NSString *)userId;
- (void)setUnreadCount;
- (NSMutableArray *)getGalleryLog:(NSString *)jID;
- (NSMutableArray *)getTeamGalleryLog:(NSString *)jID;
- (void)sendSeenACK:(NSString *)receiverId toMessageId:(NSString *)messageId;
- (void)updateMediaUploadStatus:(NSString *)messageId withStatus:(int)status;
- (void)updateMediaUploadStatusForAllUploads;
- (void)hideOrShowChatBadge:(BOOL)status;
- (int)getChatHistoryCount;
- (void)destroyGroupUserChat:(NSString *)userId;
- (BOOL)checkMessagePresence:(NSString *)messageId;
- (void)updateUserNameAndImage:(NSString *)userName withImage:(NSString *)image toJID:(NSString *)jID;
-(NSString *)createTeamStatusBodyMessage :(XMPPMessage *)message;
- (BOOL) isTeamMessageisAfterJoined :(XMPPMessage *)message;

@end
