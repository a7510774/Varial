//
//  ChatWindow.h
//  EJabberChat
//
//  Created by jagan on 24/05/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "XMPPServer.h"
#import "Util.h"
#import "Forward.h"

@interface ChatWindow : JSQMessagesViewController{
    NSMutableArray *messages;
    JSQMessagesBubbleImage *outgoingBubbleImageData, *incomingBubbleImageData, *leftBubbleImageData;
    JSQMessagesAvatarImage  *sender, *receiver;
    NSMutableArray *medias;
}

@property (strong) NSString *receiverId;

- (void) removeAllMessages;
- (NSMutableArray *)getMessages;
- (void) reloadTheCell:(int)index;
- (void) sendMessage:(XMPPMessage *)message mediaURL:(NSString *)mediaUrl;
- (void) sendMessageToReceipient:(XMPPMessage *)message;
- (void) addTextMessage:(XMPPMessage *)message isOutgoing:(BOOL)outGoing withStatus:(int)status withTime:(long)timeStamp;
- (void)addPhotoMediaMessage:(XMPPMessage *)message isOutgoing:(BOOL)outGoing withStatus:(int)status withTime:(long)timeStamp;
- (void)addVideoMediaMessage:(XMPPMessage *)message isOutgoing:(BOOL)outGoing withStatus:(int)status withTime:(long)timeStamp;
- (BOOL) canSend;

@end
