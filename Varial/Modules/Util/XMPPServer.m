//
//  XMPPServer.m
//  DemoChat
//
//  Created by jagan on 10/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "XMPPServer.h"
#import "DDLog.h"
#import <UIKit/UIKit.h>
#import "Config.h"
#import "Util.h"
#import "AppDelegate.h"
#import "ChatDBManager.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPMessage+XEP_0184.h"
#import "FriendsChat.h"

#define SERVER @"52.41.66.147"
//#define SERVER @"devchat.varialskate.com"

@implementation XMPPServer

+ (instancetype) sharedInstance{
    static XMPPServer *xmppServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmppServer = [[self alloc] init];
        [xmppServer initObjects];
    });
    return xmppServer;
}

- (void)initObjects{
    _arrayInvitation = [[NSMutableArray alloc] init];
    _onlineUsers = [[NSMutableArray alloc] init];
}

- (void)setupXMPPStream{
    
    NSAssert(_xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    _xmppStream = [[XMPPStream alloc] init];
    _xmppStream.hostName =  LIVE_CHAT_SERVER;
    //_xmppStream.hostName = @"52.39.150.105"; //Live IP
    //_xmppStream.hostName = @"52.41.66.147";
    
    //Group chat
    _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    _roomArray = [[NSMutableArray alloc] init];
    
    _xmppMUC = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [_xmppMUC   activate:_xmppStream];
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    _xmppReconnect = [[XMPPReconnect alloc] init];
    _xmppReconnect.reconnectDelay = 2;
    _xmppReconnect.autoReconnect = TRUE;
    
    //Setup lastseen activity
    _xmppLastActivity = [[XMPPLastActivity alloc]init];
    
    //Setup message delivery status
    _xmppMessageDeliveryReceipts = [[XMPPMessageDeliveryReceipts alloc] init];
    _xmppMessageDeliveryReceipts.autoSendMessageDeliveryRequests = TRUE;
    _xmppMessageDeliveryReceipts.autoSendMessageDeliveryReceipts = TRUE;
    
    //Setup Roster management
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    if (_xmppRosterStorage != nil) {
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
    }
    _xmppRoster.autoFetchRoster = TRUE;
    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    //Block/unblock
    _xmppBlocking = [[XMPPBlocking alloc] init];
    
    // Activate xmpp modulee
    [_xmppReconnect activate:_xmppStream];
    [_xmppLastActivity activate:_xmppStream];
    [_xmppMessageDeliveryReceipts activate:_xmppStream];
    [_xmppRoster activate:_xmppStream];
    [_xmppMUC activate:_xmppStream];
    [_xmppBlocking activate:_xmppStream];
    
    //Add module delegate methods
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppLastActivity addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppMUC  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppBlocking  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.xmppStream.enableBackgroundingOnSocket = YES;
    
    //Connect to the server
    [self connect];

}


//Disconnect from the server
- (void)teardownStream
{
    [self goOffline];
    [_xmppStream removeDelegate:self];
    [_xmppReconnect deactivate];
    [_xmppStream disconnect];
    
    _xmppStream = nil;
    _xmppReconnect = nil;
}

//Change the presence mode to available
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"]; // type="available" is implicit
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"1"];
    [presence addChild:priority];
    [[self xmppStream] sendElement:presence];
}

//Goto offline mode
- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"1"];
    [presence addChild:priority];
    [[self xmppStream] sendElement:presence];
}


#pragma mark Connect/disconnect
- (BOOL)connect
{
    if (![_xmppStream isDisconnected]) {
        return YES;
    }
    
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:@"myJID"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"myJPassword"];
    
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [_xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        NSLog(@"Error connecting: %@", error);
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    //[self goOffline];
    [_xmppStream disconnect];
}


#pragma mark XMPPStream Delegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPDISCONNECTFROMSERVER object:nil userInfo:nil];
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [_xmppStream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation)
    {
        //settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        NSLog(@"Error authenticating: %@", error);
    }

}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPCONNECTIONSUCCESS object:nil userInfo:nil];
    [self goOnline];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate getTeamList];
    [self unBlockMyFriends];
    //[self getAllRegisteredUsers];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self teardownStream];
    [self setupXMPPStream];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    //NSLog(@"Status : %@",iq);
    
    NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"http://jabber.org/protocol/disco#items"];
    
    if (queryElement) {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        NSMutableArray *mArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[itemElements count]; i++) {
            NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
            //NSLog(@"Online users %@",jid);
        }
    }
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"%@: %@ ", THIS_FILE, THIS_METHOD);
        
    // A simple example of inbound message handling.
    if ([message isChatMessageWithBody] && [[message type] isEqualToString:@"chat"])
    {
        NSLog(@"Message %@", message);
        NSString *messageId = [message elementID];
        if (![[ChatDBManager sharedInstance] checkMessagePresence:messageId])
            [[NSNotificationCenter defaultCenter] postNotificationName:XMPPONMESSAGERECIEVE object:nil userInfo:@{@"message":message}];
    }
    else if ([message elementForName:@"composing"] != nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPONMESSAGERECIEVE object:nil userInfo:@{@"message":message}];
    }
    else{
        if ([[message type] isEqualToString:@"chat"]) {
            //NSLog(@"Message %@", message);
            if (![message isMessageWithBody] && [message elementForName:@"received"] != nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRECEIVEDACK object:nil userInfo:@{@"message":message}];
            }
            else if (![message isMessageWithBody] && [message elementForName:@"seen"] != nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRECEIVEDACK object:nil userInfo:@{@"message":message}];
            }
        }
    }
  
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    //NSLog(@"Message send : %@",message);
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRECEIVEDACK object:nil userInfo:@{@"message":message}];
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    //NSLog(@"Message send : %@",message);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    //NSLog(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    NSLog(@"Presence : %@", presence); 
    
    if ([presence elementForName:@"delay"] == nil) {
        NSString *jabberId = [[presence attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"][0];
        NSString *presenceType = [presence type];
        if ([presenceType isEqualToString:@"available"]) {
            [_onlineUsers addObject:jabberId];
        }
        else{
            [_onlineUsers removeObject:jabberId];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRECIEVEPRESENCE object:nil userInfo:@{@"message":presence}];
    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        NSLog(@"Unable to connect to server. Check xmppStream.hostName");
    }

}

#pragma mark XMPPReConnect Delegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPDISCONNECTFROMSERVER object:nil userInfo:nil];
    
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    return TRUE;
}

#pragma mark XMPPLastActivity Delegate
- (void)xmppLastActivity:(XMPPLastActivity *)sender didReceiveResponse:(XMPPIQ *)response
{
    //NSLog(@"Receive Lastactivity :%@", response);
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRECEIVEDLASTSEEN object:nil userInfo:@{@"message":response}];
    
    NSArray *from = [[response attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
    if (![[response attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
        long timestamp = [response lastActivitySeconds];
        if (timestamp == 0) { //Online
            [_onlineUsers addObject:from[0]];
        }
    }
}

#pragma mark XMPPRoster Delegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"%@: %@ : %@", THIS_FILE, THIS_METHOD, presence);
    
    NSString *presenceType = [presence type];
    if  ([presenceType isEqualToString:@"subscribe"])
    {
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
        //[self.xmppRoster rejectPresenceSubscriptionRequestFrom:[presence from]];
    }
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item{
    NSLog(@"%@: %@ : %@", THIS_FILE, THIS_METHOD, item);
}

#pragma mark XMPPMUC Delegate
- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message{
    NSLog(@"%@: %@ : %@", THIS_FILE, THIS_METHOD, message);
    
   // NSString *strJID = [NSString stringWithFormat:@"%@",roomJID];
   // [_arrayInvitation addObject:[strJID componentsSeparatedByString:@"_"][0]];
   // [self joinRoom:strJID];
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitationDecline:(XMPPMessage *)message{
    NSLog(@"%@: %@ : %@", THIS_FILE, THIS_METHOD, message);
}

- (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
{
    // Tell the socket to stay around if the app goes to the background (only works on apps with the VoIP background flag set)
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];
}

- (void)xmppBlocking:(XMPPBlocking *)sender didBlockJID:(XMPPJID*)xmppJID{
    NSLog(@"%@: %@ : %@", THIS_FILE, THIS_METHOD, xmppJID);
}

- (void)xmppBlocking:(XMPPBlocking *)sender didUnblockJID:(XMPPJID*)xmppJID{
    NSLog(@"%@: %@ : %@", THIS_FILE, THIS_METHOD, xmppJID);
}

- (void)xmppBlocking:(XMPPBlocking *)sender didReceivedBlockingList:(NSArray*)blockingList{
    NSLog(@"%@: %@ : %@", THIS_FILE, THIS_METHOD, blockingList);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:blockingList forKey:@"blockedUsers"];
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRECEIVEDBLOCKEDLIST object:nil userInfo:@{@"message":blockingList}];
}

- (void)joinRoom :(NSString *)roomName {
    
    int index = [Util getMatchedObjectPosition:@"roomJID" valueToMatch:roomName from:_roomArray type:0];
    
    //Check Room already joined or not
    if (index == -1) {
        
        XMPPRoomMemoryStorage *roomMemory = [[XMPPRoomMemoryStorage alloc]init];
        XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",roomName]];
        _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemory
                                                      jid:roomJID
                                            dispatchQueue:dispatch_get_main_queue()];
        [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_xmppRoom activate:_xmppStream];
        NSString *joinName = [[NSUUID UUID] UUIDString];
        [_xmppRoom joinRoomUsingNickname:joinName
                                 history:nil
                                password:nil];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:_xmppRoom forKey:@"xmppRoom"];
        [dict setValue:joinName forKey:@"roomName"];
        [dict setValue:roomName forKey:@"roomJID"];
        [_roomArray addObject:dict];
        NSLog(@"Rooms %@",_roomArray);
        
    }
}

-(NSString *)createUUID {
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    
    NSString *messageId = [message elementID];
    if ([message isChatMessageWithBody])
    {
        if (![[ChatDBManager sharedInstance] checkMessagePresence:messageId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:XMPPONMESSAGERECIEVE object:nil userInfo:@{@"message":message}];
            
        }
    }
    else if ([message elementForName:@"composing"] != nil){
        if (![[ChatDBManager sharedInstance] checkMessagePresence:messageId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:XMPPONMESSAGERECIEVE object:nil userInfo:@{@"message":message}];
        }
    }
    else if ([message elementForName:@"teamstatus"] != nil)
    {
        if (![[ChatDBManager sharedInstance] checkMessagePresence:messageId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:XMPPONMESSAGERECIEVE object:nil userInfo:@{@"message":message}];
        }
    }
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"Did Create");
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"Joined in the team %@",[sender roomJID]);
    NSString *roomId = [NSString stringWithFormat:@"%@",[sender roomJID]];
    NSLog(@"Invitation Array %@",_arrayInvitation);
    
    if ([_arrayInvitation containsObject:[roomId componentsSeparatedByString:@"_"][0]]) {
        
        NSLog(@"Joined stanza sent");
        NSMutableDictionary *teamDetails = [[NSUserDefaults standardUserDefaults] objectForKey:@"TeamList"];
        NSMutableArray *teamList = [[teamDetails objectForKey:@"team_details"] mutableCopy];
        
        int index = [Util getMatchedObjectPosition:@"jabber_id" valueToMatch:roomId from:teamList type:0];
        if (index != -1) {
              NSLog(@"Joined stanza sent");
            NSMutableDictionary *details = [teamList objectAtIndex:index];
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@",[teamDetails valueForKey:@"media_base_url"],[[details objectForKey:@"profile_image"] objectForKey:@"profile_image"]];
            
            // After left team send chat to team
            FriendsChat *friendsChat = [[FriendsChat alloc] init];
            friendsChat.receiverName = [details objectForKey:@"team_name"];
            friendsChat.receiverImage = imageUrl;
            friendsChat.receiverID = roomId;
            [friendsChat sendMessageIfUserLeft:roomId name1:[Util getFromDefaults:@"user_name"] name2:@"" type:@"2"];
            [_arrayInvitation removeObject:[roomId componentsSeparatedByString:@"_"][0]];
        }
    }
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    
    NSLog(@"members %@",items);
}

-(void)leaveRoomFromMe :(NSString *)roomName
{
    int index = [Util getMatchedObjectPosition:@"roomJID" valueToMatch:roomName from:_roomArray type:0];
    
    if (index != -1) {
        
        XMPPRoom *room = [[_roomArray objectAtIndex:index] objectForKey:@"xmppRoom"];
        dispatch_after(1, dispatch_get_main_queue(), ^{
            [room leaveRoom];
        });
        
        [_roomArray removeObjectAtIndex:index];
    }
}

-(void)sendMessageforLeaveTeam :(NSString *)roomID receiverName:(NSString *)receiverName image:(NSString *)image type:(NSString *)type
{
    FriendsChat *friendsChat = [[FriendsChat alloc] init];
    friendsChat.receiverName = receiverName;
    friendsChat.receiverImage = image;
    friendsChat.receiverID = roomID;
    [friendsChat sendMessageIfUserLeft:roomID name1:[Util getFromDefaults:@"user_name"] name2:@" " type:type];
}

//Unblock our friends
- (void)unBlockMyFriends{
    //Unblock my firends
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *friendsList = [[defaults objectForKey:@"friends_jabber_ids"] mutableCopy];
    for (NSString *userJID in friendsList) {
        [_xmppBlocking unblockJID:[XMPPJID jidWithString:userJID]];
        [_xmppLastActivity sendLastActivityQueryToJID:[XMPPJID jidWithString:userJID]];
    }
}

@end
