//
//  WebsocketClient.m
//  VelanCorpChat
//
//  Created by Velan Info Services on 2016-01-06.
//  Copyright © 2016 Velan Info Services. All rights reserved.
//

#import "WebsocketClient.h"
#import "Util.h"


@implementation WebsocketClient
BOOL isConnecting = FALSE, isConnectionOpened = FALSE;
+ (instancetype) sharedInstance{
    static WebsocketClient *socketClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketClient = [[self alloc] init];
    });
    return socketClient;
}

//Check app is in active mode
- (BOOL)isAppActive{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    return state == UIApplicationStateActive ? TRUE : FALSE;
}

//Connect to the server
- (void) connectAndRegister{
    _socketClient = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:SOCKET_URL]];
    _socketClient.delegate = self;
    if(_socketClient.readyState != 1 && [Util getFromDefaults:@"auth_token"] != nil && !isConnecting && [self isAppActive]){
        isConnecting = TRUE;
        NSLog(@"Connecting...");
        [_socketClient open];
    }
}

//Close the connection manually
- (void) closeConnection{
    isConnecting = FALSE;
    isConnectionOpened = FALSE;
    [_socketClient close];
}

#pragma mark - SRWebSocket delegate

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    NSLog(@"Connection Open %ld",(long)_socketClient.readyState);
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    
    NSString *playerId = [Util getFromDefaults:@"encrypted_id"];
    [body setValue:playerId forKey:@"ui"];
    [body setValue:[Util getFromDefaults:@"device_token"] forKey:@"di"];
    NSLog(@"Register Request %@:",[Util buildDataToSend:@"mr" withBody:body]);
    if (_socketClient.readyState == SR_OPEN) {
        [_socketClient send:[Util buildDataToSend:@"mr" withBody:body]];
    }
    isConnecting = FALSE;
    isConnectionOpened = TRUE;
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Connection Failed : %@",error);
    isConnecting = isConnectionOpened = FALSE;
    if ([[Util sharedInstance] getNetWorkStatus] && [self isAppActive]) {
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(connectAndRegister) userInfo:nil repeats: NO];
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Connection Closed");
    isConnecting = isConnectionOpened = FALSE;
    if ([[Util sharedInstance] getNetWorkStatus] && [self isAppActive]) {
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(connectAndRegister) userInfo:nil repeats: NO];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Message received : %@", message );
    
    NSMutableDictionary *receivedmessage = [Util convertStringToDictionary:message];
    isConnectionOpened = TRUE;

    if ([[receivedmessage valueForKey:@"t"] isEqualToString:@"mn"]) {
        //Mobile notification
        NSMutableDictionary *notification = [[receivedmessage valueForKey:@"d"] valueForKey:@"c"];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotification" object:nil userInfo:notification];
    }
    
}


@end
