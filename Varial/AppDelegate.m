//
//  AppDelegate.m
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//  Testing Commit

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import "IQKeyboardManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "ProfilePicture.h"
#import "GeneralNotification.h"
#import "FriendsNotification.h"
#import "JNKeychain.h"
#import "ChatDBManager.h"
#import "DBManager.h"
#import "LNNotificationsUI.h"
#import "Varial-Swift.h"

@interface AppDelegate ()
@property (nonatomic) NSUncaughtExceptionHandler* crashlyticsHandler;

@end
BMKMapManager* _mapManager;
@implementation AppDelegate
@synthesize navController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    _downloadingMessages = [[NSMutableArray alloc] init];
    _uploadingMessages = [[NSMutableArray alloc] init];
    _downloadingMessageTasks = [[NSMutableDictionary alloc] init];
    _videoIds = [[NSMutableDictionary alloc] init];
    _upDownProgress = [[NSMutableDictionary alloc] init];
    _uploadDownloadImage = [[NSMutableDictionary alloc] init];
    _moviePlayer = [[NSMutableDictionary alloc] init];
    _searchPlayer = [[NSMutableDictionary alloc] init];
    _videoUrls = [[NSMutableArray alloc] init];
    _playerViewController = [[AVPlayerViewController alloc] init];
    _postRequest = [[NSMutableArray alloc] init];
    _postRequest = NO;
    
    //Monitor the network
    [[Util sharedInstance] monitorNetwork];
    
    //Initialize the objects
    xmppStream = [XMPPServer sharedInstance].xmppStream;

    defaults = [NSUserDefaults standardUserDefaults];
    
    _countries = [[NSMutableArray alloc]init];
    _buzzardRunEventPost = [[NSMutableDictionary alloc] init];
    
    if([Util getFromDefaults:@"auth_token"] == nil)
        [self getCountryList];
    
    //Register for crash report
    [Fabric with:@[CrashlyticsKit]];
    
    //Register Google Map
    [GMSServices provideAPIKey:[Util getGoogleApiKey]];
    [GMSPlacesClient provideAPIKey:[Util getGoogleApiKey]];
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:[Util getBiaduApiKey] generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }    
    
    _shouldAllowRotation = FALSE;
    _outOfPlayer = FALSE;
    
    //Listen the screen orientation
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self createPopups];
    
    
    //register to handle push notification events
    [[Notifications sharedInstance] registerForNotification];
    
    //Choose corresponding view controller
    [self changeViewController];

    [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    //[self application:application didReceiveLocalNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    //Register for push notification
    //Set up Push Notification
    [self getDeviceTokenForNotification:application];
    //Enf of Push Notification setup
    
    if([defaults stringForKey:@"myJID"] != nil){
        [self connectToChatServer];
    }
    
    //Initialize chat classes
    [DBManager sharedInstance];
    [ChatDBManager sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    //Design the local notification
    [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"varial_app" name:@"Varial App" icon:[UIImage imageNamed:@"iTunesArtwork"] defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
    
    _crashlyticsHandler = NSGetUncaughtExceptionHandler();
    
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    //background music
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [[AVAudioSession sharedInstance] setActive: YES error: nil];
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
   
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    return YES;
}


static void onUncaughtException(NSException * exception)
{
    NSLog(@"app delegate, uncaught exception: %@", exception.description);
    
    // call Crashlytics handler
//    _crashlyticsHandler(exception);  // *** not possible since it's a static method ***
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(IPAD)
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        if(_shouldAllowRotation)
        {
            return UIInterfaceOrientationMaskAll;
        }
        else
            return UIInterfaceOrientationMaskPortrait;
    }
}

-(void)moviePlayBackStateChanged{
    _shouldAllowRotation = TRUE;
    if(_outOfPlayer){
        _shouldAllowRotation = FALSE;
        _outOfPlayer = FALSE;
    }
}

-(void)moviePlayBackDidFinish{
    _outOfPlayer = TRUE;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

//Get country list
-(void) getCountryList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    if ([Util getFromDefaults:@"language"] == nil) {
        [inputParams setValue:@"en-US" forKey:@"language_code"];
    }
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:COUNTRY_LIST withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [defaults setValue:[response objectForKey:@"country_list"] forKey:@"country_list"];
        }
    } isShowLoader:NO];
}

//**Push Notification Code**//
/*- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification{
    NSLog(@"Local notification %@",notification.userInfo);

}*/

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        NSMutableDictionary *notificationContent = [[userInfo valueForKey:@"aps"] mutableCopy];
        NSMutableDictionary *receivedData = [[notificationContent valueForKey:@"notifications"] mutableCopy];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotification" object:nil userInfo:receivedData];
    }
    else{
        //Check user information is null
        //While click the notification from system notification list
        if(userInfo != nil){
            NSMutableDictionary *notificationContent = [[userInfo valueForKey:@"aps"] mutableCopy];
            NSMutableDictionary *receivedData = [[notificationContent valueForKey:@"notifications"] mutableCopy];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TappedNotification" object:nil userInfo:receivedData];
        }
    }
}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *devToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"My token is: %@", devToken);
    
    if([Util getFromDefaults:@"device_token"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:devToken forKey:@"device_token"];
        [self registerMyDevice];
    }
    else
        [[NSUserDefaults standardUserDefaults] setValue:devToken forKey:@"device_token"];
}

-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    // [utils showAlert:[NSString stringWithFormat:@" failed %@",error]];
    // NSLog(@"Failed to get device token, error: %@", error);
    [self getDeviceTokenForNotification:application];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"In Background");
    //[[WebsocketClient sharedInstance] closeConnection];
    [[XMPPServer sharedInstance] goOffline];
    [[XMPPServer sharedInstance].xmppStream disconnect];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _showLoaderOnAppEnter = YES;
    [self refreshNotification];
    [self reloadGeneralAndFriendNotifications];
    
    if([defaults stringForKey:@"myJID"] != nil){
        [self connectToChatServer];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    //NSURLCache * const urlCache = [NSURLCache sharedURLCache];
    //[urlCache removeAllCachedResponses];
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[ChatDBManager sharedInstance] updateMediaUploadStatusForAllUploads];
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.velan.Varial" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Varial" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Varial.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)orientationChanged:(NSNotification *)notification{
}

//Create network alert popups
- (void) createPopups{
    
    NetworkAlert *network = [[NetworkAlert alloc] init];
    [network setNetworkHeader:NSLocalizedString(NETWORK_TITLE, nil)];
    network.subTitle.text = NSLocalizedString(CHECK_NETWORK, nil);
    
    _networkPopup = [KLCPopup popupWithContentView:network showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
    _networkPopup.didFinishShowingCompletion = ^{
        [Util sharedInstance].isNetworkShow = @"TRUE";
    };
    
    _networkPopup.didFinishDismissingCompletion = ^{
        [Util sharedInstance].isNetworkShow = @"FALSE";
    };

    
    NetworkAlert *server = [[NetworkAlert alloc] init];
    [server setNetworkHeader:NSLocalizedString(@"Server", nil)];
    server.subTitle.text = NSLocalizedString(@"Please try again", nil);
    
    _serverTimeOut = [KLCPopup popupWithContentView:server showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
    
    
    updateVersion = [[UpdateVersion alloc]init];
    [updateVersion setDelegate:self];
    
    _updateVersionPopUp = [KLCPopup popupWithContentView:updateVersion showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
}

//Change view controller
- (void)changeViewController{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    
    //if not logged in
    if([Util getFromDefaults:@"auth_token"] == nil){
        
        if ([Util getFromDefaults:@"language"] == nil){
            //Language screen
            //[Util setDefaultLanguage];
            Language *language = [mainStoryboard instantiateViewControllerWithIdentifier:@"Language"];
            [[UIApplication sharedApplication] delegate].window.rootViewController = language;
        }
        else{
            
            Login *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
            UINavigationController * aNavi = [[UINavigationController alloc]initWithRootViewController:login];
            [[UIApplication sharedApplication] delegate].window.rootViewController = aNavi;
        }
    }
    else{
        //if logged in
        if ([[Util getFromDefaults:@"isPlayerTypeSet"] isEqualToString:@"NO"]) {
            PlayerType *playerType = [mainStoryboard instantiateViewControllerWithIdentifier:@"PlayerType"];
            [[UIApplication sharedApplication] delegate].window.rootViewController = playerType;
        }
        else {
            
            UINavigationController *navigation = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
            [[UIApplication sharedApplication] delegate].window.rootViewController = navigation;
            [[ChatDBManager sharedInstance] createChatBadge];
        }
    }
}

//Get notifications
- (void)refreshNotification{
    //Check if logged in
    if([Util getFromDefaults:@"auth_token"] != nil) {
        
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[Util getAppVersion] forKey:@"installed_version"];
        [inputParams setValue:[Util getBuildNumber] forKey:@"build_number"];
        NSString *version = [NSString stringWithFormat:@"version:%@, device_name:%@",[[UIDevice currentDevice] systemVersion],[Util getDeviceModel:[[UIDevice currentDevice] platform]]];
        [inputParams setValue:version forKey:@"os_version"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GENERAL_API withCallBack:^(NSDictionary * response){
            if ([[response valueForKey:@"status"] boolValue]) {
                
                //Store country code
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"player_country_code"] forKey:@"country_code"];
                #ifdef DEBUG
//                [[NSUserDefaults standardUserDefaults] setObject:@"cn" forKey:@"country_code"];
                #endif
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"name"] forKey:@"user_name"];
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:0] forKey:@"isNameChanged"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"player_id"] forKey:@"player_id"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"profile_image"] forKey:@"player_image"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"ios_version"] forKey:@"updated_build_version"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"ios_store_url"] forKey:@"store_url"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"friends_jabber_ids"] forKey:@"friends_jabber_ids"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"players_blocked_me"] forKey:@"players_blocked_me"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"players_i_blocked"] forKey:@"players_i_blocked"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"team_details"] forKey:@"team_details"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"chat_notification"] boolValue] forKey:@"is_chat_enabled"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"keep_more_feeds"] boolValue] forKey:@"keep_more_feeds"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRECEIVEDBLOCKEDLIST object:nil userInfo:@{@"message":[response objectForKey:@"players_i_blocked"]}];
                
//                [self needsUpdateWithCallback:^(BOOL needsUpdate) {
//                    if (needsUpdate) {
//                        UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
//                        NSString *className = NSStringFromClass([[[navigation viewControllers] lastObject] class]);
//                        
//                        if(!([className isEqualToString:@"ChatHome"] || [className isEqualToString:@"FriendsChat"]))
//                            [_updateVersionPopUp show];
//                    }
//                }];
                
                // Remove room from array if team is not present( If captain or co-captain removed me)
                [self removeRoomIfTeamNotPresent:[[response objectForKey:@"team_details"] mutableCopy]];
                
                // Update team Name and Image
                [self updateTeamNameAndImage:response];
                
                //Set encrypted player id
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"encrypted_id"] forKey:@"encrypted_id"];
                                
                //Store and intimate email activation status
                BOOL emailStatus = [[response valueForKey:@"email_verified_status"] boolValue];
                [[NSUserDefaults standardUserDefaults] setBool:emailStatus forKey:@"isEmailVerified"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ActivateEmailAlert" object:nil userInfo:nil];
                
                //Store default media config
                NSMutableDictionary *mediaConfig = [[response valueForKey:@"media_information"] mutableCopy];
                [[NSUserDefaults standardUserDefaults] setValue:mediaConfig forKey:@"mediaConfig"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeNotificationCount" object:nil userInfo:[response objectForKey:@"player_notification"]];
                
                //Flags for control the skater/crew/media privileges
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_bazzardrun"] boolValue] forKey:@"can_participate_in_bazzardrun"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_participate_in_clubpromotion"] boolValue] forKey:@"can_participate_in_clubpromotion"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_shop_offers"] boolValue] forKey:@"can_show_shop_offers"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_games"] boolValue] forKey:@"can_show_games"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_shoping"] boolValue] forKey:@"can_show_shoping"];
                
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_offers"] boolValue] forKey:@"can_show_offers"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_leaderboard"] boolValue] forKey:@"can_show_leaderboard"];
                [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"can_show_club_promotions"] boolValue] forKey:@"can_show_club_promotions"];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"feed_report_list"] forKey:@"report_Type"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //Connect socket
                if (SOCKET_ENABLE) {
                    [[WebsocketClient sharedInstance] connectAndRegister];
                }
                
                xmppStream = [XMPPServer sharedInstance].xmppStream;
                if(!xmppStream.isConnected)
                {
                    if ([response valueForKey:@"jabber_id"] != nil) {
                        
                        //Clear user history if account changed
                        NSString *oldJID = [Util getFromDefaults:@"myJID"];
                        if (oldJID != nil && ![oldJID isEqualToString:[response valueForKey:@"jabber_id"]]) {
                            [[ChatDBManager sharedInstance] destroyUserChat];
                        }
                        
                        [defaults setValue:[response valueForKey:@"jabber_id"] forKey:@"myJID"];
                    }
                    
                    if ([response valueForKey:@"jabber_password"] != nil) {
                        [defaults setValue:[response valueForKey:@"jabber_password"] forKey:@"myJPassword"];
                    }
                    
                    //Connect to server
                    [self connectToChatServer];
                }
                
                [[XMPPServer sharedInstance] unBlockMyFriends];
                
            }
            
        } isShowLoader:NO];
        
        _showLoaderOnAppEnter = NO;
        
        
    }
    
}

- (void)getTeamList{
    
    if([Util getFromDefaults:@"auth_token"] != nil)
    {
        //Send team list request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_LIST withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue])
            {
                [Util setInDefaults:response withKey:@"TeamList"];
                [self updateTeamNameAndImage:response];
                NSMutableArray *teamList = [[response objectForKey:@"team_details"] mutableCopy];
                //Save team details in session
                [[NSUserDefaults standardUserDefaults] setObject:teamList forKey:@"team_details"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //Join in the teams
                for (int i=0; i< [teamList count]; i++)
                {
                    if ([[teamList objectAtIndex:i] objectForKey:@"jabber_id"] != nil) {
                        [[XMPPServer sharedInstance] joinRoom:[[teamList objectAtIndex:i] objectForKey:@"jabber_id"]];
                    }
                }
            }
            else{
                
            }
            
        } isShowLoader:NO];
    }
}


// Delegate Method for UpdateVersionPopup
-(void)onUpdateClick
{
    NSString *storeUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"store_url"];
    [_updateVersionPopUp dismiss:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeUrl]];
}

-(void)onCancelClick
{
    [_updateVersionPopUp dismiss:YES];
}

// When view will enter foreground should load the general and friend notification api
-(void)reloadGeneralAndFriendNotifications
{
    FriendsNotification *general = [[FriendsNotification alloc] init];
    general.generalPage = 1;
    [general getGeneralNotificationList];

    FriendsNotification *friend = [[FriendsNotification alloc] init];
    friend.page = 1;
    [friend getFriendNotificationList];
}


//Login to chat server
- (void)connectToChatServer{
    
    if([defaults stringForKey:@"myJID"] != nil && CHAT_ENABLED && [Util getBoolFromDefaults:@"is_chat_enabled"])
    {
        [[XMPPServer sharedInstance] teardownStream];
        
        //Check already connected
        if (!xmppStream.isConnected && !xmppStream.isConnecting) {
            [[XMPPServer sharedInstance] setupXMPPStream];
        }
    }
    
}

- (void)getDeviceTokenForNotification:(UIApplication *)application{
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

}

- (void)registerMyDevice{
    
    //Check if logged in
    if([Util getFromDefaults:@"auth_token"] != nil) {
        
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [Util appendDeviceMeta:inputParams];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:UPDATE_DEVICE_TOKEN withCallBack:^(NSDictionary * response){            
           
            if ([[response valueForKey:@"status"] boolValue]) {
                
            }
        } isShowLoader:NO];
    }
}

//Get device Unique id
- (NSString *)getDeviceUniqueId{
    
    NSString *strID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if ([JNKeychain loadValueForKey:@"VARIAL_APP_ID"]) {
        strID = [JNKeychain loadValueForKey:@"VARIAL_APP_ID"];
    }
    else{
        NSLog(@"NOT FOUND");
        [JNKeychain saveValue:strID forKey:@"VARIAL_APP_ID"];
    }    
    NSLog(@"Device ID : %@",strID);
    return strID;
}

- (void)needsUpdateWithCallback:(BoolBlock)callback
{
    NSString* appID = @"com.llc.varial"; //infoDictionary[@"CFBundleIdentifier"];
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID];
    [[Util sharedInstance] sendHTTPGetRequest:url withCallBack:^(NSDictionary *response) {
        if (response != nil) {
            if ([response[@"resultCount"] integerValue] == 1){
                NSString* appStoreVersion = response[@"results"][0][@"version"];
                NSString* currentVersion = [Util getAppVersion];
                NSArray *currentArray = [currentVersion componentsSeparatedByString:@"."];
                NSArray *appStoreArray = [appStoreVersion componentsSeparatedByString:@"."];
                int current, updated;

                for (int i=0; i<[appStoreArray count]; i++)
                {
                    current = [[currentArray objectAtIndex:i] intValue];
                    updated = [[appStoreArray objectAtIndex:i] intValue];
                    if (current < updated)
                    {
                        callback(YES);
                        return;
                    }
                }
            }
        } else {
            callback(NO);
        }
        
    } isShowLoader:NO];
}

-(void)updateTeamNameAndImage:(NSDictionary *)response
{
    NSMutableArray *teamList = [[response objectForKey:@"team_details"] mutableCopy];
    for (int i=0; i< [teamList count]; i++) {
        
        NSMutableDictionary *teamDetails = [teamList objectAtIndex:i];
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",[response valueForKey:@"media_base_url"],[[teamDetails objectForKey:@"profile_image"] objectForKey:@"profile_image"]];
        [[ChatDBManager sharedInstance] updateUserNameAndImage:[teamDetails objectForKey:@"team_name"] withImage:imageUrl toJID:[teamDetails objectForKey:@"jabber_id"]];
    }
}

// Remove unwanted room if present
-(void)removeRoomIfTeamNotPresent:(NSMutableArray *)teamList
{
    // check if leaved team room is present, to remove the room
    for (int i=0; i<[[XMPPServer sharedInstance].roomArray count]; i++) {
        NSDictionary *room = [[XMPPServer sharedInstance].roomArray objectAtIndex:i];
        
        int index = [Util getMatchedObjectPosition:@"jabber_id" valueToMatch:[room objectForKey:@"roomJID"] from:teamList type:0];
        if (index == -1) {
            [[XMPPServer sharedInstance] leaveRoomFromMe:[room objectForKey:@"roomJID"]];
            i--;
        }
    }
}

@end
