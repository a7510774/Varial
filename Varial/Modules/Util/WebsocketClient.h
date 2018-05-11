//
//  WebsocketClient.h
//  VelanCorpChat
//
//  Created by Velan Info Services on 2016-01-06.
//  Copyright © 2016 Velan Info Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import <UIKit/UIKit.h>

@interface WebsocketClient : NSObject <SRWebSocketDelegate>
{
    
}

@property (strong,nonatomic) SRWebSocket *socketClient;
+ (instancetype) sharedInstance;
- (void) closeConnection;
- (void) connectAndRegister;

@end
