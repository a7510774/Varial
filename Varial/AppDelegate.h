//
//  AppDelegate.h
//  
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Util.h"
#import "Config.h"
#import "KLCPopup.h"
#import "Login.h"
#import "PlayerType.h"
#import "Language.h"
#import "Notifications.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "WebsocketClient.h"
#import "UpdateVersion.h"
#import "Notifications.h"
#import "XMPPServer.h"
#import <AVFoundation/AVFoundation.h>
#import "SRGMediaPlayer.h"
#import "UIDevice-Hardware.h"
#import "GoogleMap.h"

@import GoogleMaps;
@class TRMosaicLayout;
@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate,UpdateVersionDelegate,UINavigationControllerDelegate,RTSMediaPlayerControllerDataSource>{
    WebsocketClient *socketClient;
    UpdateVersion *updateVersion;    
    NSUserDefaults *defaults;
    XMPPStream *xmppStream;
    BOOL isTestFairyPaused;
}

@property (nonatomic) BOOL shouldAllowRotation, outOfPlayer, postInProgress, showLoaderOnAppEnter;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSMutableArray *countries, *downloadingMessages, *uploadingMessages, *createPostRecepients, *videoUrls, *postRequest;
@property (nonatomic) NSMutableDictionary *downloadingMessageTasks, *upDownProgress, *uploadDownloadImage, *videoIds;
@property (nonatomic) NSMutableDictionary *buzzardRunEventPost;
@property (nonatomic) NSMutableDictionary *moviePlayer,*searchPlayer;
@property (nonatomic) NSString *currentVideoUrl;
//@property (strong, nonatomic) RTSMediaPlayerController *currentPlayer;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) KLCPopup *networkPopup, *serverTimeOut, *updateVersionPopUp;
@property (retain, nonatomic) UINavigationController *navController;
@property (nonatomic) AVPlayerViewController *playerViewController;

@property (strong, nonatomic) AVPlayer *videoPlayer;
@property (strong, nonatomic) AVPlayer *currentPlayer;
@property (strong, nonatomic) UITableViewCell *currentCell;

typedef void (^BoolBlock)(BOOL);

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)refreshNotification;
- (void)connectToChatServer;
- (void)getDeviceTokenForNotification:(UIApplication *)application;
- (NSString *)getDeviceUniqueId;
- (void)createPopups;
- (void)needsUpdateWithCallback:(BoolBlock)callback;
- (void)getTeamList;
- (void)updateTeamNameAndImage:(NSDictionary *)response;

@end

