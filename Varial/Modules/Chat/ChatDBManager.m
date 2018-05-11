//
//  ChatDBManager.m
//  EJabberChat
//
//  Created by jagan on 25/05/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "ChatDBManager.h"
#import "ChatHome.h"
#import "AGPushNoteView.h"
#import "ChatNotification.h"

#define CONVERSATION_LIMIT 100

@implementation ChatDBManager

+ (instancetype) sharedInstance{
    static ChatDBManager *chatDBManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatDBManager = [[self alloc] init];
        [chatDBManager registerForNotification];
        [chatDBManager setUnreadCount];
    });
    return chatDBManager;
}


//Register to listen the notification
- (void)registerForNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processIncomeMessage:) name:XMPPONMESSAGERECIEVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageStatus:) name:XMPPRECEIVEDACK object:nil];
    
    //Create avatar images memory allocation
    _avatarImages = [[NSMutableDictionary alloc] init];
}

//To process the type of the notification
- (void) processIncomeMessage:(NSNotification *) data{
    
    NSMutableDictionary *receivedMessage = [data.userInfo mutableCopy];
    XMPPMessage *message = [receivedMessage valueForKey:@"message"];
    
    //1. Save in DB
    if (([[message type]isEqualToString:@"chat"] && [message isChatMessageWithBody] && [message elementForName:@"active"] != nil) || ([[message type]isEqualToString:@"groupchat"] && [message isChatMessageWithBody] && [self isTeamMessageisAfterJoined:message])) {
        
        if ([message elementForName:@"teamstatus"] != nil) {
            [self saveMessageInDataBase:message isOutGoing:NO mediaURL:@""];
        }
        else
        {
            NSXMLElement *userData = [message elementForName:@"userdata"];
            NSXMLElement *messageType = [userData elementForName:@"messageType"];
            
            //Check message type
            if ([[messageType stringValue] intValue] == 1) {
                [self saveMessageInDataBase:message isOutGoing:NO mediaURL:@""];
            }
            else{
                NSXMLElement *attachment  = [userData elementForName:@"attachment"];
                NSString *mediaUrl = [attachment stringValue];
                [self saveMessageInDataBase:message isOutGoing:NO mediaURL:mediaUrl];
            }
        }
    }
    
    //2.Check message type
    if ([[message type] isEqualToString:@"chat"] || ([[message type] isEqualToString:@"groupchat"] && [self isTeamMessageisAfterJoined:message])) {
        
        //1. Show local notification
        UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        
        if (navigation != nil && [navigation isKindOfClass:[UINavigationController class]]) {
            UIViewController *controller = [[navigation viewControllers] lastObject];
            
            //Check current screen is chat window
            if ([controller isKindOfClass:[FriendsChat class]]) {
                
                FriendsChat *friendsChat = (FriendsChat *)controller;
                
                //Check message is no for current conversation
                NSArray *from = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
                
                if (![[from objectAtIndex:0] isEqualToString:friendsChat.receiverID]) {
                    
                    //Check is active message
                    if ([message elementForName:@"active"] != nil) {
                        //Show notification
                        [self showNotification:message];
                    }
                }
            }
            else{
                //Check is active message
                if ([message elementForName:@"active"] != nil) {
                    //Show notification
                    [self showNotification:message];
                }
            }
            
            //3. Re arrange the chat list if in chat menu screen
            //Check current screen is chat window
            if ([controller isKindOfClass:[ChatHome class]]) {
                
                ChatHome *chatMenu = (ChatHome *) controller;
                //1. Get message from db and re order
                [chatMenu getConversations];
            }
        }
        
    }
}

// 1. Checkteam message 2. check message is after joined. If before joined message should not save in DB
- (BOOL) isTeamMessageisAfterJoined :(XMPPMessage *)message
{
    // Team Chat
    if ([[message type] isEqualToString:@"groupchat"]) {
        long messageTimeStamp = [self getTimeFromMessage:message isOutGoing:NO];
        
        NSString *teamJabberId = [self getJID:message forKey:@"to"];
        if (teamJabberId != nil) {
            
            NSMutableArray *teamList = [[NSUserDefaults standardUserDefaults] objectForKey:@"team_details"];
            
            int index = [Util getMatchedObjectPosition:@"jabber_id" valueToMatch:teamJabberId from:teamList type:0];
            if (index != -1) {
                NSMutableDictionary *teamDetail = [teamList objectAtIndex:index];
                long teamJoinedAt = [[teamDetail objectForKey:@"created_at_timezone"] longValue];
                if (teamJoinedAt < messageTimeStamp) {
                    // Save Message in DB
                    return  YES;
                }
                else
                {
                    // before joined team messages
                    return NO;
                }
            }
            else
            {
                // Team not available
                return NO;
            }
        }
        
    }
    return YES; // Single Chat
}

//Show the notifcation locally
- (void)showNotification:(XMPPMessage *)message{
    
    // Check message is leave team
    [self isTeamRemovedFromCaptain:message];
    
    //1. Get message
    NSString *messageContent = [message valueForKey:@"body"];
    
    //2. Check app is in foreground
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = messageContent;
        //Build data for local handling
        NSMutableDictionary *messageData = [[NSMutableDictionary alloc] init];
        [messageData setObject:message.description forKey:@"message"];
        localNotification.userInfo = messageData;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    else{
        if ([message elementForName:@"delay"] == nil) {
            
            NSXMLElement *userData = [message elementForName:@"userdata"];
            NSXMLElement *messageType = [userData elementForName:@"messageType"];
            
            NSString *name = [[userData elementForName:@"senderName"] stringValue];
            NSString *image = [[userData elementForName:@"senderImage"] stringValue];
            
            int type = [[messageType stringValue] intValue];
            if (type == 1) {
                 if ([message elementForName:@"teamstatus"] == nil) {
                    [[ChatNotification sharedInstance] showNotification:image withTitle:name withSubtitle:messageContent];
                 }
            }
            else if (type == 2){
                
                [[ChatNotification sharedInstance] showNotification:image withTitle:name withSubtitle:NSLocalizedString(SENT_YOU_IMAGE, nil)];
            }
            else if (type == 3){
                
                [[ChatNotification sharedInstance] showNotification:image withTitle:name withSubtitle:NSLocalizedString(SENT_YOU_VIDEO, nil)];
            }
            [[ChatNotification sharedInstance] setMessageAction:message];
            
            AudioServicesPlaySystemSound(1002);
        }
    }
}

- (void)redirectMessage:(XMPPMessage *)message{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    NSXMLElement *userData = [message elementForName:@"userdata"];
    
    FriendsChat *friends = [storyBoard instantiateViewControllerWithIdentifier:@"FriendsChat"];
    NSString *receiverId = [self getJID:message forKey:@"from"];
    friends.receiverID = receiverId;
    
    NSXMLElement *senderName = [userData elementForName:@"senderName"];
    NSString *name = [senderName stringValue];
    NSXMLElement *senderImage = [userData elementForName:@"senderImage"];
    NSString *image = [senderImage stringValue];
    
    friends.receiverName = name;
    friends.receiverImage = image;
    friends.isSingleChat = @"TRUE";
    
    UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if ([navigation isKindOfClass:[UINavigationController class]]) {
        NSMutableArray *controllers = [[navigation viewControllers] mutableCopy];
        if ([[controllers lastObject] isKindOfClass:[FriendsChat class]]) {
            [controllers removeObjectAtIndex:[controllers count] - 1];
            navigation.viewControllers = controllers;
            [navigation pushViewController:friends animated:YES];
        }
        else{
            [navigation pushViewController:friends animated:YES];
        }
    }
}

//Change message status (Send,Deliverd,Seen)
- (void) updateMessageStatus:(NSNotification *) data{
    
    NSMutableDictionary *receivedMessage = [data.userInfo mutableCopy];
    XMPPMessage *message = [receivedMessage valueForKey:@"message"];
    
    NSString *messageId;
    int status = 1;
    
    //Get message id
    if ([message isChatMessageWithBody]) {
        messageId = [message attributeStringValueForName:@"id"];
    }
    else if ([message elementForName:@"received"] != nil){
        NSXMLElement *received = [message elementForName:@"received"];
        messageId = [received attributeStringValueForName:@"id"];
        status = 2;
    }
    else if ([message elementForName:@"seen"] != nil){
        NSXMLElement *received = [message elementForName:@"seen"];
        messageId = [received attributeStringValueForName:@"id"];
        status = 3;
    }
    
    //Update message status in db
    if (status == 1 || [[message type] isEqualToString:@"chat"]) {
        [self updateMessageStatus:messageId toStatus:status];
    }
}

//Create query to retrive chat history
- (NSString *)getChatHistoryQuery:(NSString *)sender receiver:(NSString *)receiver{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM player_message WHERE ((from_id = '%@' AND to_id = '%@') OR (from_id = '%@' AND to_id = '%@')) and is_delete = 0 ",sender,receiver,receiver,sender];
    return query;
}

//Create a query to retrieve the team chat history
- (NSString *)getTeamChatHistoryQuery:(NSString *)receiver{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM player_message WHERE to_id = '%@' and is_delete = 0",receiver];
    return query;
}

//Check message existance
- (BOOL)checkMessagePresence:(NSString *)messageId{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM player_message WHERE message_id = '%@'",messageId];
    [[DBManager sharedInstance] recordCount:query];
    
    return [[DBManager sharedInstance] recordCount:query] > 0 ? TRUE : FALSE;
}



//Save message at local DB
- (void) saveMessageInDataBase:(XMPPMessage *)messageData isOutGoing:(BOOL) outGoing mediaURL:(NSString *)mediaURL{
    
    
    //1. Get receiver and sender
    NSString *senderId = [self getJID:messageData forKey:@"from"];
    NSString *receiverId = [self getJID:messageData forKey:@"to"];
    
    if (receiverId != nil && senderId != nil) {
        
        //2. Check chat is already made with his/her
        NSString *query = [[messageData type] isEqualToString:@"chat"] ? [self getChatHistoryQuery:senderId receiver:receiverId] : [self getTeamChatHistoryQuery:receiverId];
        
        NSArray *records = [[DBManager sharedInstance] findRecord:query];
        int recordCount = (int)[records count];
        if (recordCount > 0) {
            //1. Check conversation exceeds the limit
            if (CONVERSATION_LIMIT == recordCount) {
                //1. Get old recorde id
                NSString *messageId = [[records objectAtIndex:0] valueForKey:@"message_id"];
                //2. Delete the old record
                 if ([messageData isSingleChatMessage]) {
                    [self deleteMessage:messageId];
                 }
                 else
                 {
                     [self deleteTeamMessage:messageId];
                 }
                
            }
            //2. Insert record in player_message table
            [self addPlayerMessage:messageData isOutGoing:outGoing mediaURL:mediaURL];
            //3. Check for update the unread count
            if ([self needToUpdateUnreadCount:messageData isOutGoing:outGoing]) {
                [self updateUnreadCount:messageData isOutGoing:outGoing];
                [self setUnreadCount];
            }
        }
        else{
            //New chat started
            //1. Insert record in player table
            [self addPlayerInformation:messageData isOutGoing:outGoing];
            //2. Insert record in player_message table
            [self addPlayerMessage:messageData isOutGoing:outGoing mediaURL:mediaURL];
            //3. Check for update the unread count
            if ([self needToUpdateUnreadCount:messageData isOutGoing:outGoing]) {
                [self updateUnreadCount:messageData isOutGoing:outGoing];
                [self setUnreadCount];
            }
        }
    }
}

//Save player message in DB
- (void)addPlayerMessage:(XMPPMessage *)message isOutGoing:(BOOL) outGoing mediaURL:(NSString *)mediaURL{
        
    NSString *from = [self getJID:message forKey:@"from"];
    NSString *to = [self getJID:message forKey:@"to"];

    if (from != nil && to != nil) {
        
        NSString *body = message.description;
        int messageType = [[message attributeStringValueForName:@"type"] isEqualToString:@"chat"] ? 1 : 2; //1. Private chat, 2. Group chat
        NSString *messageId = [message attributeStringValueForName:@"id"];
        NSXMLElement *userData = [message elementForName:@"userdata"];
        NSXMLElement *messageTypeNode = [userData elementForName:@"messageType"];
        int type = [[messageTypeNode stringValue] intValue];
        int status = 0;
        long timestamp =  [self getTimeFromMessage:message isOutGoing:outGoing];
        NSString *mediaUrl = outGoing ? mediaURL : mediaURL;
        
        NSString *query = @"INSERT INTO player_message (message_id, message, type, media_url, time, status, from_id, to_id, chat_type, is_outgoing, is_sent, is_local, is_delete) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        
        // 1. int/interger, 2. Text, 3. Blob, 4. Double
        [params addObject:@{@"type":[NSNumber numberWithInt:2], @"data":messageId}]; //message_id
        [params addObject:@{@"type":[NSNumber numberWithInt:3], @"data":body}]; //message
        [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:type]}]; // type
        [params addObject:@{@"type":[NSNumber numberWithInt:2], @"data":mediaUrl}]; // media_url
        [params addObject:@{@"type":[NSNumber numberWithInt:4], @"data":[NSNumber numberWithLong:timestamp]}];
        [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:status]}]; // status
        [params addObject:@{@"type":[NSNumber numberWithInt:2], @"data":from}]; // from_id
        [params addObject:@{@"type":[NSNumber numberWithInt:2], @"data":to}]; // to_id
        [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:messageType]}]; // chat_type
        [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:outGoing]}]; // is_outgoing
        [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:0]}]; // is_sent
        [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:0]}]; // is_local
        [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:0]}]; // is_deleted
        
        [[DBManager sharedInstance] saveRecord:query withParams:params];
        
        //2.Update the player name
        if ([message attributeForName:@"delay"] == nil && !outGoing && [[message type] isEqualToString:@"chat"]) {
            NSArray *nameAndImage = [self getNameAndImage:message isOutGoing:outGoing];
            [self updateUserNameAndImage:nameAndImage[0] withImage:nameAndImage[1] toJID:from];
        }
    }
}

//Save User information in DB
- (void)addPlayerInformation:(XMPPMessage *)message isOutGoing:(BOOL) outGoing{
    
    NSString *from = [self getJID:message forKey:@"from"];
    NSString *to = [self getJID:message forKey:@"to"];
    
     NSString *jID = outGoing ? to : from;
    
    if (![message isSingleChatMessage]) {
        jID = to;
    }
    
    //1.Check user already has account
    NSString *playerQuery = [NSString stringWithFormat:@"SELECT * FROM player WHERE j_id = '%@'", jID];
    NSArray *player = [[DBManager sharedInstance] findRecord:playerQuery];
    
    if([player count] == 0)
    {
        NSString *query = @"INSERT INTO player (j_id, name, profile_image, unread_count, is_player) VALUES (?, ?, ?, ?, ?)";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        int unreadCount = 0;        

        //Check current screen to set unread_count
        if ([self needToUpdateUnreadCount:message isOutGoing:outGoing]) {
            unreadCount = 1;
        }
        
        //Get player name and image
        NSXMLElement *userdata = [message elementForName:@"userdata"];
        NSString *name = [[userdata elementForName:@"senderName"] stringValue];
        NSString *image = [[userdata elementForName:@"senderImage"] stringValue];
        
        //1.Check its outgoing message
        if (outGoing || (!outGoing && [[message type] isEqualToString:@"groupchat"])) {
            name = [[userdata elementForName:@"receiverName"] stringValue];
            image = [[userdata elementForName:@"receiverImage"] stringValue];
        }
        
        // 1. int/integer, 2. Text, 3. Blob, 4. Double
        [params addObject:@{@"type":[NSNumber numberWithInt:2], @"data":jID}]; // j_id
        [params addObject:@{@"type":[NSNumber numberWithInt:2], @"data":name}]; // name
        [params addObject:@{@"type":[NSNumber numberWithInt:2], @"data":image}]; // profile_image
        [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:0]}]; // unread_count
        if ([message isSingleChatMessage]) {
            [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:1]}]; // is_player
        }
        else
        {
            [params addObject:@{@"type":[NSNumber numberWithInt:1], @"data":[NSNumber numberWithInt:2]}]; // is_player
        }
        
        [[DBManager sharedInstance] saveRecord:query withParams:params];
        [self setUnreadCount];
    }
}

//Delete message by mesage id
- (BOOL)deleteMessage:(NSString *)messageId{    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM player_message WHERE message_id = '%@'",messageId];
    return [[DBManager sharedInstance] deleteRecord:query];
}

// Delete Team Message
- (BOOL)deleteTeamMessage:(NSString *)messageId{
    
    NSString *query = [NSString stringWithFormat:@"UPDATE player_message SET is_delete = 1 WHERE message_id = '%@'", messageId];
    return [[DBManager sharedInstance] deleteRecord:query];
}


//Update the unread count to user
- (void)updateUnreadCount:(XMPPMessage *)message isOutGoing:(BOOL)outGoing{
    
    NSString *from = [self getJID:message forKey:@"from"];
    NSString *to = [self getJID:message forKey:@"to"];
    NSString *jID = outGoing ? to : from;
    
    if ([[message type] isEqualToString:@"groupchat"]) {
        jID = to;
    }
    
    if (jID != nil) {
        //Get old count
        NSString *query = [NSString stringWithFormat:@"UPDATE player SET unread_count = unread_count + 1 WHERE j_id = '%@'",jID];
        [[DBManager sharedInstance] updateRecord:query];

    }
}

//Returne the Jabber id that read from XMPP Message
- (NSString *)getJID:(XMPPMessage *)message forKey:(NSString *)key{
    
    NSXMLElement *userdata = [message elementForName:@"userdata"];
    NSXMLElement *JIDNode = [userdata elementForName:key];
    if (JIDNode != nil) {
        
        return [JIDNode stringValue];
    }
    return  nil;
}

//Update the message status like Sent/Delivered/Seen
- (void)updateMessageStatus:(NSString *)messageId toStatus:(int)status{
    
    //Get message details
    NSString *messageQuery = [NSString stringWithFormat:@"SELECT status from player_message WHERE message_id = '%@'", messageId];
    NSString *query = [NSString stringWithFormat:@"UPDATE player_message SET status = %d WHERE message_id = '%@'",status, messageId];
    
    if (status == 2) {
        NSMutableArray *messageDetails = [[DBManager sharedInstance] findRecord:messageQuery];
        if ([messageDetails count] > 0) {
            int oldStatus = [[[messageDetails objectAtIndex:0] valueForKey:@"status"] intValue];
            if (oldStatus != 3) {
                [[DBManager sharedInstance] updateRecord:query];
            }
        }
    }
    else{
        [[DBManager sharedInstance] updateRecord:query];
    }
}

//Reset the Unread Count
- (void)resetUnreadCount:(NSString *)toId {
    
    NSString *query = [NSString stringWithFormat:@"UPDATE player SET unread_count = 0 WHERE j_id = '%@'",toId];
    [[DBManager sharedInstance] updateRecord:query];
    [self setUnreadCount];
}


//Check whether need to update a unread count or not
- (BOOL)needToUpdateUnreadCount:(XMPPMessage *)message isOutGoing:(BOOL)outGoing{
    
    NSString *from = [self getJID:message forKey:@"from"];
    NSString *to = [self getJID:message forKey:@"to"];
    
    NSString *jID = outGoing ? to : from;
    
    if ([[message type] isEqualToString:@"groupchat"]) {
        jID = to;
    }
    
    //Check current screen
    UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if ([navigation isKindOfClass:[UINavigationController class]]) {
        
        UIViewController *controller = [[navigation viewControllers] lastObject];
        
        //Check current screen is chat window
        if ([controller isKindOfClass:[FriendsChat class]]) {
            
            FriendsChat *friendsChat = (FriendsChat *)controller;            
            
            if (!outGoing) {
                
                if (![jID isEqualToString:friendsChat.receiverID]) {
                   return TRUE;
                }
                else{
                    return FALSE;
                }
            }
        }
        else{
            return TRUE;
        }
    }
    
    return FALSE;
}

//Set unread count at top
-(void)setUnreadCount{
    int unread = 0;
    NSString *query = [NSString stringWithFormat:@"SELECT SUM(unread_count) as unread_count FROM player"];
    NSMutableArray *chats = [[DBManager sharedInstance] findRecord:query];
    if([chats count] > 0){
        unread = [[[chats objectAtIndex:0]valueForKey:@"unread_count"]intValue];
    }
    if (unread > 0) {
        badgeCount.hidden = NO;
        if (unread > 9) {
            badgeCount.text = @"9+";
        }else{
            badgeCount.text = [NSString stringWithFormat:@"%d",unread];
        }
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: unread];
        [[NSUserDefaults standardUserDefaults] setInteger:unread forKey:@"badgeCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        badgeCount.hidden = YES;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    }
}

- (void)setAppBadgeCount{
    
}

//Get time stamp based in message receives/send/offline message
- (long)getTimeFromMessage:(XMPPMessage *)message isOutGoing:(BOOL)outGoing{
    
    if (outGoing) {
        return [[NSDate date] timeIntervalSince1970];
    }
    else{
        //Check is offline message
        if ([message elementForName:@"data"] != nil) {
            NSXMLElement *delay = [message elementForName:@"data"];
            NSString *stamp = [delay attributeStringValueForName:@"timestamp"];
            NSLog(@"Before Convert Message Time Stamp %@",stamp);
            long timestamp = [stamp longLongValue]/1000000 ;
            NSLog(@"After Convert Message Time Stamp %ld",timestamp);
            return timestamp;
        }
        else{
            return [[NSDate date] timeIntervalSince1970];
        }
    }
    return 0;
}


//Get name and image from local data or from XMPPMessage
- (NSMutableArray *)getNameAndImage:(XMPPMessage *)messageStanza isOutGoing:(BOOL)outGoing{
    
    NSString *from = [self getJID:messageStanza forKey:@"from"];
    NSString *to = [self getJID:messageStanza forKey:@"to"];
    NSString *jID = outGoing ? to : from;
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyFriendsList"];
    NSArray *result = [[NSMutableArray alloc] init];
    NSMutableArray *nameAndImage = [[NSMutableArray alloc] init];
    
    if (array != nil) {
        
        NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"%K like %@",
                                    @"jabber_id", jID];
        //result = [array filteredArrayUsingPredicate:predicate];
    }
    
    NSXMLElement *message = [messageStanza elementForName:@"userdata"];
    NSString *senderName = [[message elementForName:@"senderName"] stringValue];
    NSString *senderImage = [[message elementForName:@"senderImage"] stringValue];
    
    //1.Check its outgoing message
    if (outGoing) {
        [nameAndImage addObject:[[message elementForName:@"senderName"] stringValue]];
        [nameAndImage addObject:[[message elementForName:@"senderImage"] stringValue]];
    }
    else{
        //Check its offline message
        // if not get username from message itself
        if ([message elementForName:@"delay"] == nil) {
            [nameAndImage addObject:senderName];
            [nameAndImage addObject:senderImage];
        }
        else{
            //other wise get it from friends list
            if ([result count] > 0) {
                NSMutableDictionary *user = result[0];
                [nameAndImage addObject:[user valueForKey:@"name"]];
                [nameAndImage addObject:[user valueForKey:@"player_profile_image"]];
            }
            else{
                [nameAndImage addObject:senderName];
                [nameAndImage addObject:senderImage];
            }
        }
    }
    
    return nameAndImage;
}

//Clean the DB for a current user
- (void)destroyUserChat{
    NSString *playerQuery = @"DELETE FROM player WHERE id > 0";
    NSString *playerMessageQuery = @"DELETE FROM player_message WHERE id > 0";
    [[DBManager sharedInstance] deleteRecord:playerQuery];
    [[DBManager sharedInstance] deleteRecord:playerMessageQuery];
}

//Update the User Name and Image
- (void)updateUserNameAndImage:(NSMutableDictionary *)users{
    
    NSMutableArray *friends = [users objectForKey:@"friend_list"];
    NSString *mediaBase = [users valueForKey:@"media_base_url"];
   
    for (NSMutableDictionary *friend in friends) {
        NSString *name = [friend valueForKey:@"name"];
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[friend valueForKey:@"name"]];
        NSString *jID = [friend valueForKey:@"jabber_id"];
        [self updateUserNameAndImage:name withImage:imageUrl toJID:jID];
    }
}

//Update the username to jabber id
- (void)updateUserName:(NSString *)userName toJID:(NSString *)jID{
    
    NSString *query = [NSString stringWithFormat:@"UPDATE player SET name = '%@' WHERE j_id = '%@'",userName,jID];
    [[DBManager sharedInstance] updateRecord:query];
}

//Update the user name image
- (void)updateUserNameAndImage:(NSString *)userName withImage:(NSString *)image toJID:(NSString *)jID{
     NSString *query = [NSString stringWithFormat:@"UPDATE player SET name = '%@', profile_image = '%@' WHERE j_id = '%@'",userName,image,jID];
    [[DBManager sharedInstance] updateRecord:query];

}

//Send seen ACK to messages that not seen yet
- (void)sendSeenACKToMessages:(NSString *)jID{
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM player_message WHERE from_id = '%@' AND status < 3", jID];
    NSMutableArray *chats = [[DBManager sharedInstance] findRecord:query];
    
    for (NSMutableDictionary *messages in chats) {
        NSString *messageId = [messages valueForKey:@"message_id"];
        XMPPStream *xmppStream = [XMPPServer sharedInstance].xmppStream;
        if ([[Util sharedInstance] getNetWorkStatus] && xmppStream.isAuthenticated && xmppStream.isConnected) {
            [self sendSeenACK:jID toMessageId:messageId];
            [self updateMessageStatus:messageId toStatus:3];
        }
    }
}

//Send seen ACK to user
- (void)sendSeenACK:(NSString *)receiverId toMessageId:(NSString *)messageId{
    
    /* Example Format
     <message xmlns="jabber:client" from="jegan@192.168.1.240/6494740232009641852102898" to="divya@192.168.1.240/6856190732968098820103362" type="chat"><seen xmlns="urn:xmpp:receipts" id="9E991399-C54D-4569-9A9D-0B713C99CB4A"/></message>
     */
    
    NSXMLElement *seen = [NSXMLElement elementWithName:@"seen" xmlns:@"urn:xmpp:receipts"];
    [seen addAttributeWithName:@"id" stringValue:messageId];
    XMPPMessage* message = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:receiverId]];
    [message addAttributeWithName:@"from" stringValue:[Util getFromDefaults:@"myJID"]];
    [message addChild:seen];
    [[XMPPServer sharedInstance].xmppStream sendElement:message];
    
}


//Create chat count badge
- (void)createChatBadge{
    
    if (CHAT_ENABLED) {        
        //Create new  UILabel
        badgeCount = [[UILabel alloc] init];
        badgeCount.backgroundColor = UIColorFromHexCode(THEME_COLOR);
        badgeCount.layer.cornerRadius = 20 / 2;
        badgeCount.layer.masksToBounds = YES;
        badgeCount.font = [UIFont fontWithName:@"CenturyGothic" size:12];
        badgeCount.textColor = [UIColor whiteColor];
        badgeCount.textAlignment = NSTextAlignmentCenter;
        [badgeCount setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        //Get window object from delegate
        UIView *windowView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
        [windowView addSubview:badgeCount];
        
        //Add auto layout constrains for the banner
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (badgeCount);
        
        NSString *verticalConstraint = [NSString stringWithFormat:@"V:|-20-[badgeCount(20)]"];
        [windowView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:verticalConstraint
                                    options:NSLayoutFormatAlignAllTop metrics:nil
                                    views:viewsDictionary]];
        
        NSString *horizontalConstraint = [NSString stringWithFormat:@"H:[badgeCount(20)]-10-|"];
        [windowView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:horizontalConstraint
                                    options:NSLayoutFormatAlignAllRight metrics:nil
                                    views:viewsDictionary]];
        
        [windowView layoutIfNeeded];
        [self setUnreadCount];
    }
}

//Update the image source as local
- (void)updateImageSource:(NSString *)messageId withLocalUrl:(NSString *)mediaUrl{
    NSString *query = [NSString stringWithFormat:@"UPDATE player_message SET is_local = 1, media_url = '%@' WHERE message_id = '%@'", mediaUrl, messageId];
    [[DBManager sharedInstance]updateRecord:query];
}

//Clean the DB for a current user
- (void)destroyUserChat:(NSString *)userId{
    NSString *playerQuery = [NSString stringWithFormat:@"DELETE FROM player WHERE j_id = '%@'",userId];
    
    NSString *playerMessageQuery = [NSString stringWithFormat:@"UPDATE player_message SET is_delete = 1 WHERE from_id = '%@' OR to_id = '%@'", userId, userId];
    [[DBManager sharedInstance] deleteRecord:playerQuery];
    [[DBManager sharedInstance] deleteRecord:playerMessageQuery];
}

//Clean the DB for a current user group chat
- (void)destroyGroupUserChat:(NSString *)userId{
    NSString *playerQuery = [NSString stringWithFormat:@"DELETE FROM player WHERE j_id = '%@'",userId];
    NSString *playerMessageQuery = [NSString stringWithFormat:@"UPDATE player_message SET is_delete = 1 WHERE to_id = '%@'", userId];
    [[DBManager sharedInstance] deleteRecord:playerQuery];
    [[DBManager sharedInstance] updateRecord:playerMessageQuery];
}

//Get user image log
- (NSMutableArray *)getGalleryLog:(NSString *)jID{
    NSString *query = [self getChatHistoryQuery:[[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"] receiver:jID];
    query = [NSString stringWithFormat:@"%@ AND type > 1",query];
    return [[DBManager sharedInstance] findRecord:query];
}

//Get user image log
- (NSMutableArray *)getTeamGalleryLog:(NSString *)jID{
    NSString *query = [self getTeamChatHistoryQuery:jID];
    query = [NSString stringWithFormat:@"%@ AND type > 1",query];
    return [[DBManager sharedInstance] findRecord:query];
}


//Update media upload status
- (void)updateMediaUploadStatus:(NSString *)messageId withStatus:(int)status{
    NSString *query = [NSString stringWithFormat:@"UPDATE player_message SET is_sent = %d WHERE message_id = '%@'", status, messageId];
    [[DBManager sharedInstance]updateRecord:query];
}

//Update failed status for all uploadings while close the app
- (void)updateMediaUploadStatusForAllUploads{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableArray *uploads = delegate.uploadingMessages;
    for (NSString *messageId in uploads) {
        [self updateMediaUploadStatus:messageId withStatus:1];
    }
}


- (void)hideOrShowChatBadge:(BOOL)status{
    if (status) {
        badgeCount.backgroundColor = [UIColor clearColor];
        badgeCount.textColor = [UIColor clearColor];
    }
    else{
        badgeCount.backgroundColor = UIColorFromHexCode(THEME_COLOR);
        badgeCount.textColor = [UIColor whiteColor];
    }
}

//Returns the chat history record count
- (int)getChatHistoryCount{
    NSString *query = @"SELECT * FROM player";
    return [[DBManager sharedInstance] recordCount:query];
}

-(void)isTeamRemovedFromCaptain:(XMPPMessage *)message
{
    NSXMLElement *teamstatus = [message elementForName:@"teamstatus"];
    
    if (teamstatus != nil) {
        NSString *type = [[teamstatus elementForName:@"type"] stringValue];
        
        if ([type intValue] == 1) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate refreshNotification];
        }
    }
}

-(NSString *)createTeamStatusBodyMessage :(XMPPMessage *)message
{
    NSString *bodyMsg = nil;
    if ([message elementForName:@"teamstatus"] != nil) {
        
        NSXMLElement *userDatas = [message elementForName:@"userdata"];
        NSString *fromId = [[userDatas elementForName:@"from"] stringValue];
        
        NSXMLElement *teamstatus = [message elementForName:@"teamstatus"];
        NSString *name1 = [[teamstatus elementForName:@"name1"] stringValue];
        NSString *name2 = [[teamstatus elementForName:@"name2"] stringValue];
        NSString *type = [[teamstatus elementForName:@"type"] stringValue];
        
        // Type 1 -> If Captain or CoCaptain remove the members from team
        // Type 2 -> If a new member join in the team
        // Type 3 -> If a captain remove the Cocaptain
        // Type 4 -> If a captain set the Cocaptain
        // Type 5 -> member left from team
        // Type 6 -> set Captain before leaving
        
        if ([fromId isEqualToString:[Util getFromDefaults:@"myJID"]] && [type intValue] != 6)
        {
            name1 = NSLocalizedString(YOU, nil);
        }
        
        if ([type intValue] == 1) {
            bodyMsg = [NSString stringWithFormat:NSLocalizedString(CAPTAIN_REMOVE_MEMBER, nil),name1, name2];
        }
        else if([type intValue] == 2)
        {
            bodyMsg = [NSString stringWithFormat:NSLocalizedString(NEW_MEMBER_JOIN, nil),name1];
        }
        else if([type intValue] == 3)
        {
            bodyMsg = [NSString stringWithFormat:NSLocalizedString(REMOVE_COCAPTAIN_STATUS, nil),name1, name2];
        }
        else if([type intValue] == 4)
        {
            bodyMsg = [NSString stringWithFormat:NSLocalizedString(SET_COCAPTAIN_STATUS, nil),name1, name2];
        }
        else if([type intValue] == 5)
        {
            bodyMsg = [NSString stringWithFormat:NSLocalizedString(NO_LONGER_MEMBER, nil),name1];
        }
        else if([type intValue] == 6)
        {
            bodyMsg = [NSString stringWithFormat:NSLocalizedString(CHANGE_CAPTAIN, nil),name1, name2];
        }
        
    }
    return bodyMsg;
}



@end
