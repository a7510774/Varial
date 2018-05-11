//
//  XMPPServer.h
//  DemoChat
//
//  Created by jagan on 10/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPFramework.h"
#import "XMPPMessageDeliveryReceipts.h"
#import "XMPPStreamManagement.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPOutgoingFileTransfer.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoom.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMUC.h"
#import "XMPPBlocking.h"


//Notification names
///While XMPP try to connect with server
#define XMPPONCONNECTING @"XMPPONCONNECTING"
///While XMPP failed to connect with server
#define  XMPPCONNECTIONFAILED @"XMPPCONNECTIONFAILED"
///While XMPP successfully to connect with server
#define  XMPPCONNECTIONSUCCESS @"XMPPCONNECTIONSUCCESS"
///While message received from server
#define  XMPPONMESSAGERECIEVE @"XMPPONMESSAGERECIEVE"
///Authentication failed
#define  XMPPAUTHENTICATIONFAILED @"XMPPAUTHENTICATIONFAILED"
///Authentication Success
#define  XMPPAUTHENTICATIONSUCCEED @"XMPPAUTHENTICATIONSUCCEED"
///Recieve online/offline of roaster
#define  XMPPRECIEVEPRESENCE @"XMPPRECIEVEPRESENCE"
///Accidently disconnect from server
#define  XMPPDISCONNECTFROMSERVER @"XMPPDISCONNECTFROMSERVER"
///Message received ack from receiver
#define  XMPPRECEIVEDACK @"XMPPRECEIVEDACK"
///Message seen ack from receiver
#define  XMPPSEENACK @"XMPPSEENACK"
///Received last activity for user
#define XMPPRECEIVEDLASTSEEN @"XMPPRECEIVEDLASTSEEN"
///Received blocked users list
#define XMPPRECEIVEDBLOCKEDLIST @"XMPPRECEIVEDBLOCKEDLIST"
///Received team status (join or leave)
#define XMPPRECEIVEDTEAMSTATUS @"XMPPRECEIVEDTEAMSTATUS"

@interface XMPPServer : NSObject<XMPPStreamDelegate,XMPPOutgoingFileTransferDelegate>{
    NSString *password;
    BOOL isXmppConnected;
    BOOL customCertEvaluation;
}
@property (nonatomic, strong) NSMutableArray *arrayInvitation;
@property (nonatomic, strong) XMPPRoom *xmppRoom;
@property (nonatomic) XMPPRoomMemoryStorage *roomMemory;
@property (nonatomic, strong, readonly) XMPPMUC *xmppMUC;
@property (nonatomic, strong, readonly) XMPPBlocking *xmppBlocking;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPLastActivity *xmppLastActivity;
@property (nonatomic, strong, readonly) XMPPMessageDeliveryReceipts *xmppMessageDeliveryReceipts;

@property (nonatomic,strong) NSMutableArray *roomArray, *onlineUsers;

+ (instancetype) sharedInstance;
- (void)setupXMPPStream;
- (void)teardownStream;
- (void)goOffline;
- (void)joinRoom :(NSString *)roomName;
-(void)leaveRoomFromMe :(NSString *)roomName;
-(void)sendMessageforLeaveTeam :(NSString *)roomID receiverName:(NSString *)receiverName image:(NSString *)image type:(NSString *)type;
- (void)unBlockMyFriends;

@end
