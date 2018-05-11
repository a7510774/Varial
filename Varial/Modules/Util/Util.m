//
//  Util.m
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Util.h"
#import "KLCPopup.h"
#import "Comments.h"
#import "BuzzardRunComments.h"
#import "ChatDBManager.h"
#import "MediaGallery.h"
#import "ChatWindow.h"

@implementation Util
@synthesize dataTaskManager,httpFileTaskManager,httpMultiFileTaskManager;

+ (instancetype) sharedInstance{
    static Util *util = nil;
    @synchronized(self) {
        if (util == nil) {
            util = [[self alloc] init];
            [util configureNSURLSession];
        }
    }
    return util;
}

# pragma mark - API and Networking

//Configuration for API calls
- (void) configureNSURLSession{
    notYou = TRUE;
    dataTaskConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    dataTaskManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:dataTaskConfiguration];
    httpFileTaskManager =  [[AFURLSessionManager alloc] initWithSessionConfiguration:dataTaskConfiguration];
    httpMultiFileTaskManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:dataTaskConfiguration];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    _isNetworkShow = @"FALSE";
    _KLCPopupArray = [[NSMutableArray alloc]init];
}

- (void) monitorNetwork{    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
}

- (BOOL)getNetWorkStatus{
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    return remoteHostStatus != NotReachable ? TRUE : FALSE;
}

- (void) handleNetworkChange:(NSNotification *)notice
{
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    if(remoteHostStatus == NotReachable) {
        NSLog(@"no");
        //not available
        [appDelegate.networkPopup show];
        _isNetworkShow = @"TRUE";
    }
    else if (remoteHostStatus == ReachableViaWiFi || remoteHostStatus == ReachableViaWWAN) {
        NSLog(@"wifi");
        //available
        [appDelegate.networkPopup dismiss:YES];
        [appDelegate refreshNotification];
        [appDelegate connectToChatServer];
        [appDelegate getDeviceTokenForNotification:[UIApplication sharedApplication]];
    }
}

+ (void)monitorTheNetworkState{
    
    //Monitoring the nerwork status
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [appDelegate refreshNotification];
                //available
                [appDelegate.networkPopup dismiss:YES];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                //not available
                [appDelegate.networkPopup show];
                break;
            default:
                break;
        }
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        
    }];
    
    //Start monitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

}

# pragma mark - Alert utils

+ (UIAlertController *)createSettingsAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(title, nil)
                                message:NSLocalizedString(message, nil)
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* settingsButton = [UIAlertAction
                                     actionWithTitle:SETTINGS_TITLE
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                         [UIApplication.sharedApplication openURL:url];
                                     }];
    UIAlertAction* closeButton = [UIAlertAction
                                  actionWithTitle:CANCEL
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {

                                  }];
    [alert addAction:settingsButton];
    [alert addAction:closeButton];
    
    return alert;
}

# pragma mark - View Utils

//set leftpadding for textfield
+ (void) setPadding :(UITextField *) textField
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    @autoreleasepool {
    UIImage *image;
    if (size.width > 0) {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Begin a new image that will be the new image with the rounded corners
        // (here with the size of an UIImageView)
        UIGraphicsBeginImageContext(size);
        
        // Add a clip before drawing anything, in the shape of an rounded rect
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
        // Draw your image
        [image drawInRect:rect];
        
        // Get the image, here setting the UIImageView image
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        // Lets forget about that we were drawing
        UIGraphicsEndImageContext();
    }
    
    return image;
    }
}

//Convert color to image
+ (UIImage *)convertColorToImage:(UIColor *)color byDivide:(int)divider withHeight:(int)height {
    CGSize size = [Util getWindowSize];
    return [Util imageFromColor:color forSize:CGSizeMake(size.width/divider, height) withCornerRadius:0];
}

//Convert color to image
+ (UIImage *)convertColorToImageWithSize:(UIColor *)color width:(float)width height:(float)height {
    return [Util imageFromColor:color forSize:CGSizeMake(width, height) withCornerRadius:0];
}


//Check for window size
+ (CGSize) getWindowSize{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGSize windowSize = window.frame.size;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGSize size;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        size.width = windowSize.width;
        size.height = windowSize.height;
        return size;
    }
    else
    {
        if (UIDeviceOrientationIsLandscape(orientation))
        {
            size.width = windowSize.width;
            size.height = windowSize.height;
        }
        else
        {
            size.width = windowSize.width;
            size.height = windowSize.height;
        }
        return size;
    }
}


//Add rounded corner
+ (void) createRoundedCorener:(UIView *)view withCorner:(float)corner{
    view.layer.cornerRadius = corner;
    view.layer.masksToBounds = YES;
}

+ (void) makeCircularImage :(UIView *) view withBorderColor:(UIColor  *) color{
    
    view.layer.cornerRadius = view.frame.size.width / 2;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = color.CGColor;
    
}

//Animate the image view
- (void) animateTheImage:(UIImageView *)imageView withHeight:(float)height{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView transitionWithView:imageView
                          duration:20
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            CGRect frame = imageView.frame;
                            frame.origin.y = -60;
                            imageView.frame = frame;

                        }
                        completion:^(BOOL finished){
                            [UIView transitionWithView:imageView
                                              duration:20
                                               options:UIViewAnimationOptionCurveEaseIn
                                            animations:^{
                                                CGRect frame = imageView.frame;
                                                frame.origin.y = 0;
                                                imageView.frame = frame;

                                            }
                                            completion:^(BOOL finished){
                                                
                                            }];
                        }];

    });
   
}

# pragma mark - User Actions

- (void)LogoutTheUser{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LOGOUT_API withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            notYou = TRUE;
            [self resetTheViewController];
            [Util removeUserData];
        }
        
    } isShowLoader:YES];
}

- (void)resetTheViewController{
    [Util removeUserData];
    //Move to login page
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    Login *login = [storyBoard instantiateViewControllerWithIdentifier:@"Login"];
    UINavigationController * aNavi = [[UINavigationController alloc]initWithRootViewController:login];
    [[UIApplication sharedApplication] delegate].window.rootViewController = aNavi;
//    [[UIApplication sharedApplication] delegate].window.rootViewController = login;
}


///Remove all user data from session
+ (void)removeUserData{

    NSMutableArray *arrayUserDefaults = [[NSMutableArray alloc] initWithObjects:@"auth_token", @"ecommerce_token", @"lastUrl", @"PublicFeedsList", @"PrivateFeedsList", @"TeamAFeedsList", @"TeamBFeedsList", @"PopularFeedsList", @"FeedsTypeList", @"MyFriendsList", @"TeamList", @"MycheckInList", @"FriendNotificationList", @"GeneralNotificationList", @"myJPassword", @"user_name", @"player_image", @"player_id", @"isNameChanged", @"updated_build_version", @"encrypted_id", @"store_url", @"ProfileInfo", @"composing_message",@"blockedUsers",@"friends_jabber_ids",@"players_i_blocked",@"players_blocked_me"@"blockedUsers",@"friends_jabber_ids",@"players_blocked_me" , nil];
   
    for (int i=0; i<[arrayUserDefaults count]; i++) {
            [Util deleteFromDefaults:[arrayUserDefaults objectAtIndex:i]];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isEmailVerified"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Clear all notifications
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //Destroy user chat
    [[XMPPServer sharedInstance] goOffline];
    [[XMPPServer sharedInstance] teardownStream];
}

//Send Asynchronus request
- (NSURLSessionDataTask *) sendHTTPPostRequest:(NSMutableDictionary *) params withRequestUrl:(NSString *) url withCallBack:(CompletionBlock)callback isShowLoader:(BOOL) show {
    
    //Check network availability
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus != NotReachable)
    {
        url = [NSString stringWithFormat:@"%@%@",LIVE_API,url];
        NSLog(@"URL : %@", url);
        NSLog(@"Request Data: %@", [Util buildRequestData:params]);        
        
        MBProgressHUD *loader = nil;
        
        //Show loading
        if(show)
            loader = [Util showLoading];
                
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:@{@"data": [Util buildRequestData:params]} error:nil];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        [request setTimeoutInterval:60];
        
        NSURLSessionDataTask *dataTask = [dataTaskManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            
            if (error) {
                NSLog(@"Error: %@", error);                
                
                if(show)
                    [Util hideLoading:loader];
                
                if (error.code != -999) {
                    //show server time out alert
                    //AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
                    //[appDelegate.serverTimeOut show];
                }
                
            } else {
                
                NSDictionary *response = (NSDictionary *) responseObject;
//                NSLog(@"Response Data: %@", response);
                
//                if(show) {
//                    [Util hideLoading:loader];
//                }
                
                if (([response valueForKey:@"not_you"] != nil && [[response valueForKey:@"not_you"] intValue] == 1) || ([response valueForKey:@"logout"] != nil && [[response valueForKey:@"logout"] boolValue])) {
                    
                    if(show) {
                        [Util hideLoading:loader];
                    }
                    
                    if (notYou) {
                        notYou = FALSE;
                        
                        if ([_KLCPopupArray count] > 0) {
                            for (int i=0; i<[_KLCPopupArray count]; i++) {
                                
                                KLCPopup *popup = [_KLCPopupArray objectAtIndex:i];
                                [popup dismiss:YES];
                            }
                        }
                        
                       // NSString *aStrMessage = [[response valueForKey:@"message"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        
                        NSString *aStrMessage = [response valueForKey:@"message"];

                        if([aStrMessage isEqualToString:@"Invalid access"]){
                            
                            if ([response valueForKey:@"not_you"] != nil ) {
                                [self LogoutTheUser];
                            }
                            else{
                                [self resetTheViewController];
                            }
                        }
                        
                        else {
                            
                            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
                            dispatch_after(3, dispatch_get_main_queue(), ^(void){
                                if ([response valueForKey:@"not_you"] != nil ) {
                                    [self LogoutTheUser];
                                }
                                else{
                                    [self resetTheViewController];
                                }
                            });
                        }
                        
                        
                    }
                }
                else{
                    
//                    NSString * aGetValue = [Util getFromDefaults:@"LoginService"];
//
//                    if ([aGetValue isEqualToString:@""]) {
//
//                    }
                    
                    //Send response to callback
                    if(show) {
                        [Util hideLoading:loader];
                    }
                    callback(response);
                }
            }
        }];
        
        [dataTask resume];
        return  dataTask;
    }
    else{
        NSLog(@"Network in offline");
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        if ([_isNetworkShow isEqualToString:@"FALSE"]) {
            [appDelegate.networkPopup show];
        }
        
        return nil;
    }
    
}


//Send Asynchronus request
- (NSURLSessionDataTask *) sendHTTPPostRequestWithError:(NSMutableDictionary *) params withRequestUrl:(NSString *) url withCallBack:(CompletionBlockWithError)callback isShowLoader:(BOOL) show {
    
    //Check network availability
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus != NotReachable)
    {
        url = [NSString stringWithFormat:@"%@%@",LIVE_API,url];
        NSLog(@"URL : %@", url);
        NSLog(@"Request Data: %@", [Util buildRequestData:params]);
        
        MBProgressHUD *loader = nil;
        
        //Show loading
        if(show)
            loader = [Util showLoading];
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:@{@"data": [Util buildRequestData:params]} error:nil];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        [request setTimeoutInterval:60];
        
        NSURLSessionDataTask *dataTask = [dataTaskManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
                
                if(show)
                    [Util hideLoading:loader];
                
                if (error.code != -999) {
                    //show server time out alert
                    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
                    //[appDelegate.serverTimeOut show];
                }
                
                callback(nil,error);
                
            } else {
                
                NSDictionary *response = (NSDictionary *) responseObject;
//                NSLog(@"Response Data: %@", response);
                
                if(show)
                    [Util hideLoading:loader];
                
                if (([response valueForKey:@"not_you"] != nil && [[response valueForKey:@"not_you"] intValue] == 1) || ([response valueForKey:@"logout"] != nil && [[response valueForKey:@"logout"] boolValue])) {
                    
                    if (notYou) {
                        notYou = FALSE;
                        
                        if ([_KLCPopupArray count] > 0) {
                            for (int i=0; i<[_KLCPopupArray count]; i++) {
                                
                                KLCPopup *popup = [_KLCPopupArray objectAtIndex:i];
                                [popup dismiss:YES];
                            }
                        }
                        
                        [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
                        dispatch_after(3, dispatch_get_main_queue(), ^(void){
                            if ([response valueForKey:@"not_you"] != nil ) {
                                [self LogoutTheUser];
                            }
                            else{
                                [self resetTheViewController];
                            }
                        });
                    }
                }
                else{
                    //Send response to callback
                    callback(response, nil);
                }
            }
        }];
        
        [dataTask resume];
        return  dataTask;
    }
    else{
        NSLog(@"Network in offline");
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        if ([_isNetworkShow isEqualToString:@"FALSE"]) {
            [appDelegate.networkPopup show];
        }
        
        return nil;
    }
    
}

//Send Asynchronus request
- (NSURLSessionDataTask *) sendHTTPGetRequest:(NSString *)url withCallBack:(CompletionBlock)callback isShowLoader:(BOOL)show {
    
    //Check network availability
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus != NotReachable)
    {
        MBProgressHUD *loader = nil;
        
        //Show loading
        if(show)
            loader = [Util showLoading];
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
        
        [request setTimeoutInterval:30];
        
        NSURLSessionDataTask *dataTask = [dataTaskManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
                [error.userInfo valueForKey:@"NSLocalizedDescription"];
                
                NSLog(@"-------> %@",[error.userInfo valueForKey:@"NSLocalizedDescription"]);
                
                if(show)
                    [Util hideLoading:loader];
                
                if (error.code != -999) {
                    //show server time out alert
                    //AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
                    //[appDelegate.serverTimeOut show];
                }
                
            } else {
                
                NSDictionary *response = (NSDictionary *) responseObject;
//                NSLog(@"Response Data: %@", response);
                
                if(show)
                    [Util hideLoading:loader];
               //Send response to callback
                    callback(response);
               
                
            }
        }];
        
        [dataTask resume];
        return  dataTask;
    }
    else{
        NSLog(@"Network in offline");
        return nil;
    }
    
}


//Show location alert
- (void)showLocationAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(TURN_ON_LOCATION,nil) message:@"" delegate:self cancelButtonTitle:SETTINGS_TITLE otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [alert show];
}

//Show gallery alert
- (void)showGalleryAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(GALLERY_ALERT,nil) message:@"" delegate:self cancelButtonTitle:SETTINGS_TITLE otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [alert show];
}

//Show in-app alert
- (void)showInAppAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(TURN_ON_INAPP_PURCHASE,nil) message:SETTINGS_PATH delegate:self cancelButtonTitle:SETTINGS_TITLE otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [alert show];
}

# pragma mark - Upload Methods

//Image and Vedio upload task
- (NSURLSessionUploadTask *) sendHTTPPostRequestWithImage:(NSMutableDictionary *) params withRequestUrl:(NSString *) url withImage:(NSData *)imageFile  withFileName:(NSString *)fileName withCallBack:(CompletionBlock)callback  onProgressView:(UIProgressView *)progressView withExtension:(NSString *)extension ofType:(NSString *)type {
    
    //Check network availability
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus != NotReachable)
    {
        url = [NSString stringWithFormat:@"%@%@",LIVE_API,url];
        NSLog(@"URL : %@", url);
        NSLog(@"Request Data: %@", [Util buildRequestData: params]);
        
        //Append the langauge
        [params setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
        [params setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        
        //Create request
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageFile != nil) {
                [formData appendPartWithFileData:imageFile name:fileName fileName:extension  mimeType:type];
            }
        } error:nil];
        [request setTimeoutInterval:3600];
        
        //dataTaskManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSURLSessionUploadTask *uploadTask = [httpFileTaskManager
                      uploadTaskWithStreamedRequest:request
                      progress:^(NSProgress * _Nonnull uploadProgress) {
                          
                          // This is not called back on the main queue.
                          // You are responsible for dispatching to the main queue for UI updates
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (progressView != nil) {
                                  //Update the progress view
//                                  [progressView setProgress:uploadProgress.fractionCompleted];
                              }
                          });
                      }
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          
                          NSLog(@"sendHTTPPostRequestWithImage Done");
                          
                          if (error) {
                              NSLog(@"Error: %@", error);
                              
                              //show server time out alert
                              //AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
                              //[appDelegate.serverTimeOut show];
                              
                              callback(nil);
                              
                          } else {
                              
                              NSDictionary *response = (NSDictionary *) responseObject;
                              //NSString *myString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                              NSLog(@"Response Data: %@", response);
                              
                              if (([response valueForKey:@"not_you"] != nil && [[response valueForKey:@"not_you"] intValue] == 1) || ([response valueForKey:@"logout"] != nil && [[response valueForKey:@"logout"] boolValue])) {
                                  if (notYou) {
                                      notYou = FALSE;
                                      [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
                                      dispatch_after(3, dispatch_get_main_queue(), ^{
                                          if ([response valueForKey:@"not_you"] != nil ) {
                                              [self LogoutTheUser];
                                          }
                                          else{
                                              [self resetTheViewController];
                                          }
                                      });
                                  }
                              }
                              else{
                                  //Send response to callback
                                  callback(response);
                              }
                          }
                      }];
        
        [uploadTask resume];
        return uploadTask;
    }
    else{
        NSLog(@"Network in offline");
        return nil;
    }
}



//Multipart http request
- (NSURLSessionUploadTask *) sendHTTPPostRequestWithMultiPart:(NSMutableDictionary *) params withMultiPart:(NSMutableArray *)multiPart withRequestUrl:(NSString *) url withImage:(UIImageView *)imageFile withCallBack:(CompletionBlock)callback onProgressView:(UIProgressView *)progressView isFromBuzzardRun:(BOOL)isFromBuzzardRun{
    
    //Check network availability
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus != NotReachable)
    {
        url = [NSString stringWithFormat:@"%@%@",LIVE_API,url];
        
        NSLog(@"URL : %@", url);
        NSLog(@"Request Data: %@", [Util buildRequestData: params]);        
               
        //Append the langauge
        [params setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
        
        //Create request
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            NSLog(@"sendHTTPPostRequestWithMultiPart block");
            
            //Build the multipart data
            for (int i=0; i<[multiPart count]; i++) {
                
                NSDictionary *media = [multiPart objectAtIndex:i];
                //NSString *extension = [[media valueForKey:@"mediaUrl"] pathExtension];
                NSString *extension = @"";
//                if ([[media valueForKey:@"isCaptured"] boolValue]) {
//                    extension = [[media valueForKey:@"mediaUrl"] pathExtension];
//                }else{
//                    NSRange range = [[media valueForKey:@"mediaUrl"] rangeOfString:@"&ext="];
//                    extension = [[[media valueForKey:@"mediaUrl"]  substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                }
                extension = [[media valueForKey:@"mediaUrl"] pathExtension];
                
                if ([[media valueForKey:@"mediaType"] boolValue]) {
                    [formData appendPartWithFileData:[media objectForKey:@"assetData"] name:@"image[]" fileName:[NSString stringWithFormat:@"%@.%@",[Util randomStringWithLength:15],extension] mimeType:@"image/jpeg"];
                }
                else{
                    [formData appendPartWithFileData:[media objectForKey:@"assetData"] name:@"video[]" fileName:[NSString stringWithFormat:@"%@.%@",[Util randomStringWithLength:15],extension] mimeType:@"video/mp4"];
//                    video/mp4
//                    video/quicktime
                    NSLog(@"made form data, %@", formData);
                }
            }
        } error:nil];
        
        //[request setTimeoutInterval:3600];
        [request setTimeoutInterval:6000];
        AFURLSessionManager *taskManager = isFromBuzzardRun ? httpMultiFileTaskManager : dataTaskManager ;
        
//        NSLog(@"Request Object %@", request);
        
        //dataTaskManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSURLSessionUploadTask *uploadTask = [taskManager
                                              uploadTaskWithStreamedRequest:request
                                              progress:^(NSProgress * _Nonnull uploadProgress) {
                                                  NSLog(@"UploadProgress, %f", uploadProgress.fractionCompleted);
                                                  // This is not called back on the main queue.
                                                  // You are responsible for dispatching to the main queue for UI updates
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      if (progressView != nil) {
                                                          //Update the progress view
//                                                          NSLog(@"UploadProgress, %f", uploadProgress.fractionCompleted);
                                                          [progressView setProgress:uploadProgress.fractionCompleted];
                                                          
                                                      }
                                                  });
                                              }
                                              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//                                                  NSLog(@"Task Completion %@", response);
                                                  if (error) {
                                                      NSLog(@"Error: %@", error);
                                                    
                                                      if (![[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"cancelled"]) {
                                                          //show server time out alert
                                                          AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
                                                          
                                                          //[appDelegate.serverTimeOut show];
                                                          appDelegate.postInProgress = NO;
                                                          NSDictionary *errorMsg = [NSDictionary dictionaryWithObject:@"time_out" forKey:@"error"];
                                                          if (!isFromBuzzardRun) {
                                                            callback(errorMsg);
                                                          }
                                                          
                                                      }
                                                      //callback(nil);
                                                      
                                                  } else {
                                                      NSDictionary *response = (NSDictionary *) responseObject;
                                                      //NSString *myString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                                                      NSLog(@"Response Data: %@", response);
                                                      
                                                      if (([response valueForKey:@"not_you"] != nil && [[response valueForKey:@"not_you"] intValue] == 1) || ([response valueForKey:@"logout"] != nil && [[response valueForKey:@"logout"] boolValue])) {
                                                          if (notYou) {
                                                              notYou = FALSE;
                                                              [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
                                                              dispatch_after(3, dispatch_get_main_queue(), ^{
                                                                  if ([response valueForKey:@"not_you"] != nil ) {
                                                                      [self LogoutTheUser];
                                                                  }
                                                                  else{
                                                                      [self resetTheViewController];
                                                                  }
                                                              });
                                                          }
                                                      }
                                                      else{
                                                          //Send response to callback
                                                          callback(response);
                                                      }
                                                  }
                                              }];
        
        [uploadTask resume];
        return uploadTask;
    }
    else{
        NSLog(@"Network in offline");
        return nil;
    }
}


//Return random string with specified length
+ (NSString *) randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

//Build NSDictionary content to JSON
+ (NSString *) buildRequestData :(NSMutableDictionary *) parameters{
    
    if ([Util getFromDefaults:@"language"] != nil) {        
        //Append the langauge
        [parameters setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
    }
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&err];
    NSString *requestParameters = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return requestParameters;
}

//Show the Loading View
+ (MBProgressHUD *)showLoading {
    return [Util showLoadingWithTitle:LOADING];
}

+ (MBProgressHUD *)showLoadingWithTitle:(NSString *)title {
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    MBProgressHUD *loadingObject = [MBProgressHUD showHUDAddedTo:window animated:YES];
    loadingObject.opacity = 0.3;
    loadingObject.dimBackground = NO;
    loadingObject.labelText = NSLocalizedString(title, nil);
    return loadingObject;
}

//Hide the Loading View
+ (void)hideLoading:(MBProgressHUD *)loader
{
    [loader hide:YES];
}

//get data from NSUser Defaults
+ (NSString *) getFromDefaults : (NSString *) keyValue
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyValue];   
}

+ (BOOL) getBoolFromDefaults:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

//Store data in session
+ (void) setInDefaults:(id)config withKey:(NSString *) key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:config forKey:key];
    [defaults synchronize];
}


//Set default language
+ (void) setDefaultLanguage{
    if([Util getFromDefaults:@"language"] == nil){
        [Util setInDefaults:@"en-US" withKey:@"language"];
    }
}

//delete the key from defaults
+ (void) deleteFromDefaults:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}


//Create bottom line
+ (void) createBottomLine:(UIView *) view withColor:(UIColor  *) color{
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, view.frame.size.height - 1, view.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = color.CGColor;
    [view.layer addSublayer:bottomBorder];
}

//Create bottom line
+ (void) createTopLine:(UIView *) view withColor:(UIColor  *) color{
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height);
    topBorder.backgroundColor = color.CGColor;
    [view.layer addSublayer:topBorder];
}

//Create bottom line
+ (void) createBorder:(UIView *)view withColor:(UIColor  *)color{    
    [view.layer setBorderColor: color.CGColor];
    [view.layer setBorderWidth:1.0f];
}

//Create border line
+ (void) createBorder:(UIView *)view withColor:(UIColor  *)color setBorderSize:(float)borderSize{
    [view.layer setBorderColor: color.CGColor];
    [view.layer setBorderWidth:borderSize];
}


//Show error message
+ (void) showErrorMessage:(UIView *)viewElement withErrorMessage:(NSString *)message{
    
    //Add red border
    [Util createBottomLine:viewElement withColor:UIColorFromHexCode(THEME_COLOR)];
    [[AlertMessage sharedInstance] showMessage:message];
    
}

//To get String from UITextField/UITextView
+ (NSString *) getTextFromInputField :(id) uiElement
{
    NSString *inputString;
    if([uiElement isKindOfClass:[UITextField class]]){
        UITextField *textField = (UITextField *)uiElement;
        inputString = textField.text;
    }
    else if([uiElement isKindOfClass:[UITextView class]]){
        UITextView *textView = (UITextView *)uiElement;
        inputString = [textView text];
    }
    return inputString;
}

//UI element validation
+ (BOOL) validateTextField:(id)uiElement withValueToDisplay:(NSString *)fieldName withIsEmailType:(BOOL)isEmail withMinLength:(int)minLength withMaxLength:(int)maxLength {
    
    NSString *inputString = [Util getTextFromInputField:uiElement];
   
    //Now check for validation
    if (isEmail) {
        
        //trim the spaces of a string
        //Validation for email field
        if([[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
        {
            NSString *string = [NSString stringWithFormat:@"%@ cannot be empty",fieldName];
            [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(string, nil)];
            return FALSE;
        }
        //Check field having minimum required length
        else if ([inputString length] < minLength)
        {
            NSString *string = [NSString stringWithFormat:@"%@ should have minimum ",fieldName];
            NSString *finalstring = [string stringByAppendingString:@"%d characters"];
            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), minLength]];
            return FALSE;
        }
        //Check field having not more than max length
        else if ([inputString length] > maxLength)
        {
            NSString *string = [NSString stringWithFormat:@"%@ cannot exceed ",fieldName];
            NSString *finalstring = [string stringByAppendingString:@"%d characters"];

            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), maxLength]];
            return FALSE;
        }
//        else if(whiteSpaceRange.location != NSNotFound) {
//            
//            NSString *string = [NSString stringWithFormat:@"%@ should not contain whitespaces",fieldName];
//            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(string, nil)]];
//            return FALSE;
//        }
        //Check for valid email
        else if (![Util validateEmail :inputString])
        {
            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"Enter valid email address",nil)]];
            return FALSE;
        }
        
    }
    else{
        
        //Validation for text field
        //Check field is empty
        if([[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
        {
            NSString *string = [NSString stringWithFormat:@"%@ cannot be empty",fieldName];
            [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(string, nil)];
            return FALSE;
        }
        //Check field having minimum required length
        else if ([[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] != 0 && [inputString length] < minLength)
        {
            NSString *string = [NSString stringWithFormat:@"%@ should contain at least ",fieldName];
            NSString *finalstring = [string stringByAppendingString:@"%d characters"];
            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), minLength]];
            return FALSE;
        }
        //Check field having not more than max length
        else if ([inputString length] > maxLength)
        {
            NSString *string = [NSString stringWithFormat:@"%@ should not exceed ",fieldName];
            NSString *finalstring;
            if([fieldName isEqualToString:NAME_TITLE])
                finalstring = [string stringByAppendingString:@"%d characters."];
            else
                finalstring = [string stringByAppendingString:@"%d characters"];
            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), maxLength]];
            return FALSE;
        }
                
    }
    return TRUE;
}

+ (BOOL) validateLocationField:(id)uiElement withValueToDisplay:(NSString *)fieldName withIsEmailType:(BOOL)isEmail withMinLength:(int)minLength withMaxLength:(int)maxLength
{
    
    NSString *inputString = [Util getTextFromInputField:uiElement];
    
    if([[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        NSString *string = [NSString stringWithFormat:@"Place Name should not be empty"];
        [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(string, nil)];
        return FALSE;
    }
    //Check field having minimum required length
    else if ([[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] != 0 && [inputString length] < minLength)
    {
        NSString *string = [NSString stringWithFormat:@"%@ should minimum ",fieldName];
        NSString *finalstring = [string stringByAppendingString:@"%d character"];
        [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), minLength]];
        return FALSE;
    }
    //Check field having not more than max length
    else if ([inputString length] > maxLength)
    {
        NSString *string = [NSString stringWithFormat:@"%@ should not more than ",fieldName];
        NSString *finalstring = [string stringByAppendingString:@"%d character"];
        [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), maxLength]];
        return FALSE;
    }
    return TRUE;
}

+ (BOOL) checkLanguageIsEnglish{
    NSString *language = [Util getFromDefaults:@"language"];
    return [language isEqualToString:@"zh"] ? FALSE : TRUE;
}


//Perform Validateion for password field
+ (BOOL) validatePasswordField:(id)uiElement withValueToDisplay:(NSString *)fieldName withMinLength:(int)minLength withMaxLength:(int)maxLength {
    
    
    UITextField *fieldElement;
    //Check element type
    if([uiElement isKindOfClass:[UITextField class]]){
        
        fieldElement = (UITextField *)uiElement;
        
        //Validation for text field
        //Check field is empty
        
        
        if([fieldElement.text length] == 0)
        {
            NSString *string = [NSString stringWithFormat:@"%@ cannot be empty",fieldName];
            [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(string, nil)];
            return FALSE;
        }
        else if([[fieldElement.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
        {
            NSString *string = [NSString stringWithFormat:@"%@ cannot contain blank spaces alone",fieldName];
            [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(string, nil)];
            return FALSE;
        }
        //Check field having minimum required length
        else if ([fieldElement.text length] != 0 && [[fieldElement text] length] < minLength)
        {
            NSString *string = [NSString stringWithFormat:@"%@ should contain at least ",fieldName];
            NSString *finalstring = [string stringByAppendingString:@"%d characters."];
            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), minLength]];
            return FALSE;
        }
        //Check field having not more than max length
        else if ([[fieldElement text] length] > maxLength)
        {
            NSString *string = [NSString stringWithFormat:@"%@ should contain maximum ",fieldName];
            NSString *finalstring = [string stringByAppendingString:@"%d characters"];
            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), maxLength]];
            return FALSE;
        }
    }
    
    return TRUE;
}

//Perform Validateion for password field
+ (BOOL) validateNumberField:(id)uiElement withValueToDisplay:(NSString *)fieldName withMinLength:(int)minLength withMaxLength:(int)maxLength {
    
    UITextField *fieldElement;
    //Check element type
    if([uiElement isKindOfClass:[UITextField class]]){
        
        fieldElement = (UITextField *)uiElement;
        
        //Validation for text field
        //Check field is empty`
        if([fieldElement.text length] == 0)
        {
            NSString *string;
            if([fieldName isEqualToString:OTP_TITLE])
                string  = [NSString stringWithFormat:@"Enter %@",fieldName];
            else if([fieldName isEqualToString:NEW_NUMBER] || [fieldName isEqualToString:PHONE_NO])
                string = [NSString stringWithFormat:@"%@ cannot be empty",fieldName];
            else if([fieldName isEqualToString:INVITE_CODE])
                string = [NSString stringWithFormat:@"Enter %@",fieldName];
            else
                string = [NSString stringWithFormat:@"Enter the %@",fieldName];
            [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(string, nil)];
            return FALSE;
        }
        
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([fieldElement.text rangeOfCharacterFromSet:notDigits].location != NSNotFound)
        {
             [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(@"Special characters are not allowed.", nil)];
            return  FALSE;
        }
        
        //Check field having minimum required length
        else if ([fieldElement.text length] != 0 && [[fieldElement text] length] < minLength)
        {
            NSString *string = [NSString stringWithFormat:@"%@ should contain minimum ",fieldName];
            NSString *finalstring = [string stringByAppendingString:@"%d characters"];
            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), minLength]];
            return FALSE;
        }
        //Check field having not more than max length
        else if ([[fieldElement text] length] > maxLength)
        {
            NSString *string = [NSString stringWithFormat:@"%@ can contain maximum ",fieldName];
            NSString *finalstring = [string stringByAppendingString:@"%d characters"];
            [Util showErrorMessage:uiElement withErrorMessage:[NSString stringWithFormat:NSLocalizedString(finalstring, nil), maxLength]];
            return FALSE;
        }
    }
    
    return TRUE;
}


//Check for special characters
+ (BOOL)validCharacter:(id)uiElement forString:(NSString *)inputString withValueToDisplay:(NSString *)fieldName
{
        //For Special chars
        NSString *regExPattern = @"\\p{L}";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:inputString options:0 range:NSMakeRange(0, [inputString length])];
        NSLog(@"Is Character Numeric : %lu %@",(unsigned long)regExMatches,fieldName);
        NSLog(@"%lu", (unsigned long)regExMatches);
    
        inputString = [inputString stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([inputString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound)
        {
            NSString *string =[NSString stringWithFormat:@"%@ should not contain numeric values",fieldName];
            [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(string, nil)];
            return FALSE;
        }
        else if ([regEx numberOfMatchesInString:inputString options:0 range:NSMakeRange(0, [inputString length])] != [inputString length]) {
            if([fieldName isEqualToString:@"Name"])
            {
            [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(@"Special characters are not allowed.", nil)];
            }
            else
            {
                NSString *string =[NSString stringWithFormat:@"%@ should not contain special characters",fieldName];
                [Util showErrorMessage:uiElement withErrorMessage:NSLocalizedString(string, nil)];
            }
            return FALSE;
        }
        else
            return YES;
    
}


//Validate email
+(BOOL) validateEmail:(NSString*) emailString
{
    
    //NSString *regExPattern = @"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
   // NSString *pattern = isEnglish ? EMAIL_PATTERN : CHINA_EMAIL_PATTERN;
    NSString *pattern = EMAIL_PATTERN;
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    NSLog(@"%lu", (unsigned long)regExMatches);
    
    if (regExMatches == 0) {
        return NO;
    }
    else
        return YES;
}

//Validate name
+(BOOL) validateName:(NSString *) name{
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:NAME_PATTERN options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:name options:0 range:NSMakeRange(0, [name length])];
    NSLog(@"%lu", (unsigned long)regExMatches);
    if (regExMatches == 0) {
        return YES;
    }
    else
        return NO;
}


//Resize the profile image to reduce the storage space
+ (UIImage*)resizeProfileImage:(UIImage*)image
{
    @autoreleasepool {
    UIGraphicsBeginImageContext( CGSizeMake(PROFILE_IMAGE, PROFILE_IMAGE) );
    [image drawInRect:CGRectMake(0,0,PROFILE_IMAGE,PROFILE_IMAGE)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    }
}

//Create shadow effect for uiview
+ (void)createDropShadow:(UIView *) view {
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 5);
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowRadius = 1.0;
}

//resend email
- (void)resentEmail
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_EMAIL_API withCallBack:^(NSDictionary * response){
        //success case
        if([[response valueForKey:@"status"] boolValue]){
            
            
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:@""];
        }
    } isShowLoader:YES];
}

+ (PHAssetCollection *)createAlbum {
    
    __block PHAssetCollection *collection;
    __block PHObjectPlaceholder *placeholder;
    
    // Find the album
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", ALBUM_NAME];
    collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                          subtype:PHAssetCollectionSubtypeAny
                                                          options:fetchOptions].firstObject;
    // Create the album
    if (!collection)
    {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *createAlbum = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:ALBUM_NAME];
            placeholder = [createAlbum placeholderForCreatedAssetCollection];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success)
            {
                PHFetchResult *collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[placeholder.localIdentifier]
                                                                                                            options:nil];
                collection = collectionFetchResult.firstObject;
            }
        }];
    }
    
    return collection;
}

# pragma mark - Media Methods
+ (void)saveVideoToAlbum:(NSURL *)url withCompletionBlock:(CompletionBlockWithAsset)callback {
    NSLog(@"Saving to %@", ALBUM_NAME);
    __block PHFetchResult *videoAsset;
    __block PHAssetCollection *collection = [self createAlbum];
    __block PHObjectPlaceholder *placeholder;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        placeholder = [assetRequest placeholderForCreatedAsset];
        videoAsset = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection                                                                           assets:videoAsset];
        [albumChangeRequest addAssets:@[placeholder]];
        
        

    } completionHandler:^(BOOL success, NSError *error) {
        if (success)
        {
            NSString *localId = [placeholder localIdentifier];
            NSLog(@"success? %@", localId);
            
            PHFetchResult *assetResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
            PHAsset *asset = [assetResult firstObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(asset);
            });
            //            NSString *UUID = [placeholder.localIdentifier substringToIndex:36];
            //            self.photo.assetURL = [NSString stringWithFormat:@"assets-library://asset/asset.PNG?id=%@&ext=JPG", UUID];
            //            [self savePhoto];
        }
        else
        {
            NSLog(@"ERROR: %@", error);
        }
    }];
}
+ (void)saveImageToAlbum:(UIImage *)image withCompletionBlock:(CompletionBlockWithAsset)callback {
    NSLog(@"Saving to %@", ALBUM_NAME);
    __block PHFetchResult *photosAsset;
    __block PHAssetCollection *collection = [self createAlbum];
    __block PHObjectPlaceholder *placeholder;
    
    // Save to the album
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
//        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest changeRequestForAsset:asset];
        placeholder = [assetRequest placeholderForCreatedAsset];
        photosAsset = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection                                                                           assets:photosAsset];
        [albumChangeRequest addAssets:@[placeholder]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
//            NSString *UUID = [placeholder.localIdentifier substringToIndex:36];
//            self.photo.assetURL = [NSString stringWithFormat:@"assets-library://asset/asset.PNG?id=%@&ext=JPG", UUID];
//            [self savePhoto];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];
}

//Media related functions
- (BOOL)checkMediaHasValidFormat:(BOOL)isPhoto ofMediaUrl:(NSString *)mediaUrl{
    
    NSMutableArray *formats;
    
    //Get configuration from the session
     if([[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"] != nil){
         
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        formats = isPhoto ? [config objectForKey:@"default_image_format"] : [config objectForKey:@"default_video_format"];
        
        //Check image has valid format
        NSRange range = [mediaUrl rangeOfString:@"&ext="];
        NSString *extension = [[mediaUrl substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //NSLog(@"Formats :%@",formats);
        if ([formats indexOfObject:[extension lowercaseString]] == NSNotFound) {
            return  FALSE;
        }
        else
            return TRUE;
    }
    else
        return FALSE;
}


//Media related functions
- (BOOL)checkFileHasValidFormat:(BOOL)isPhoto ofMediaUrl:(NSString *)mediaUrl{
    
    NSMutableArray *formats;
    
    //Get configuration from the session
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"] != nil){
        
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        formats = isPhoto ? [config objectForKey:@"default_image_format"] : [config objectForKey:@"default_video_format"];
        
        //Check image has valid format        
        NSString *extension = [mediaUrl pathExtension];
        //NSLog(@"Formats :%@",formats);
        if ([formats indexOfObject:[extension lowercaseString]] == NSNotFound) {
            return  FALSE;
        }
        else
            return TRUE;
    }
    else
        return FALSE;
}

//Return asset if it has a valid length or else nil
- (void)checkMediaHasValidSize:(BOOL)isPhoto ofMediaUrl:(NSString *)mediaUrl withCallBack:(getAssetFromUrl)callback{
    
    @autoreleasepool {
    //Get configuration from the session
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"] != nil){        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Get image from asset library
            [_assetLibrary assetForURL:[NSURL URLWithString:mediaUrl] resultBlock:^(ALAsset *asset)
             {
                 if (asset != nil) {
                     NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
                     NSNumber *mediaSize = isPhoto ? [config objectForKey:@"default_image_size"] : [config objectForKey:@"default_video_size"];
                     
                     //Get asset thumbnail
                     CGImageRef thumbRef = [asset aspectRatioThumbnail];
                     UIImage *thumbImage = [UIImage imageWithCGImage:thumbRef];
                     
                     if(isPhoto){
                         
                         // Retrieve the image orientation from the ALAsset
                         UIImageOrientation orientation = UIImageOrientationUp;
                         NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
                         if (orientationValue != nil) {
                             orientation = [orientationValue intValue];
                         }
                         
//                         CGFloat scale  = 1;
                         UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:0 orientation:UIImageOrientationUp];
                         
//                         UIImage *resizedImage = [self resizeTheImage:thumbImage];
                         UIImage *resizedImage = [Util resizeTheImage:image];
                         
                         //Compress image to send
                         NSData *mediaData = UIImageJPEGRepresentation(resizedImage, 0.75);
                         
                         //Check media validation
                         NSLog(@"Orignal Size : %lu KB   Allowed  Size : %ld KB",[mediaData length]/1024,(long)[mediaSize integerValue]);
                         if((([mediaData length]/1024) <= [mediaSize integerValue])){
                             //Return asset
                             callback(mediaData,thumbImage);
                         }
                         else
                         {
                             //Return asset
                             callback(nil,nil);
                         }
                     }
                     else{
                         //Check media validation
                         ALAssetRepresentation *rep = [asset defaultRepresentation];
                         long videoSize = (long)rep.size;
                         
                         NSDate *now = [NSDate date];
                         
                         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                         dateFormatter.dateFormat = @"hh:mm:ss";
                         [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                         NSLog(@"Before compression Time is %@",[dateFormatter stringFromDate:now]);
                         //NSData *mediaData = [Util getNSDataFromAsset:asset];
                         NSLog(@"Before Compression : %ld KB", videoSize/1024);
                         
                         //Check media validation
                         //NSLog(@"media : %d   allowed  %d",[mediaData length]/1024,[mediaSize integerValue]);
                         
                         if((videoSize/1024) <= 307200 ){ //300 Mb
                             //Compress video
//                             [self compressVideo:mediaUrl isCaptured:NO toPass:callback withSize:mediaSize withImage:thumbImage];
                             
                             //Client New change
                             //Return asset
                             callback([mediaUrl dataUsingEncoding:NSUTF8StringEncoding],thumbImage);
                         }
                         else
                         {
                             //Return asset
                             callback(nil,nil);
                         }
                     }
                 }
                 else{
                     callback(nil,nil);
                 }
                 
             }
                         failureBlock:^(NSError *err) {
                             callback(nil,nil);
                             NSLog(@"Asset Error: %@",[err localizedDescription]);
                         }];
        });
        
    }
    }
}

//Resize the image if needed
+ (UIImage *) resizeTheImage:(UIImage *)originalImage {
    
    //Get Image dimension
    CGSize originalSize = originalImage.size;
    
    NSLog(@"original size %@", NSStringFromCGSize(originalSize));

//    if (originalSize.width > 1000 && originalSize.width <= 4000) {
//        return [Util imageWithImage:originalImage scaledToWidth:720];
//    }
//    else if(originalSize.width > 4000 && originalSize.width <= 8000){
////        return [Util imageWithImage:originalImage scaledToWidth:RESIZE_LEVEL_ONE];
//        return [Util imageWithImage:originalImage scaledToWidth:RESIZE_LEVEL_TWO];
//    }
//    else if(originalSize.width > 8000){
//        return [Util imageWithImage:originalImage scaledToWidth:RESIZE_LEVEL_TWO];
//    }
    float largeSize = MAX(originalImage.size.width, originalImage.size.height);
    float resizeWidth = RESIZE_LEVEL_TWO * (originalImage.size.width / largeSize);
    return [Util imageWithImage:originalImage scaledToWidth:resizeWidth];
    
//    return originalImage;
}


//Return asset if it has a valid length or else nil
- (void)checkFileHasValidSize:(BOOL)isPhoto ofMediaUrl:(NSString *)mediaUrl withCallBack:(getAssetFromUrl)callback{
    
    //Get configuration from the session
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"] != nil){
        
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        NSNumber *mediaSize = isPhoto ? [config objectForKey:@"default_image_size"] : [config objectForKey:@"default_video_size"];

        NSData *mediaData = [[NSFileManager defaultManager] contentsAtPath:mediaUrl];
        
        //Save in gallery
        if (FALSE) {
            self.library = [[ALAssetsLibrary alloc] init];
            if (mediaData != nil) {
                [self.library saveImage:[UIImage imageWithData:mediaData] toAlbum:@"Varial" withCompletionBlock:^(NSError *error , NSURL *mediaUrl) {
                }];
            }
        }
      
        UIImage *thumbImage = nil;
        
        if(isPhoto){
            
            thumbImage = [UIImage imageWithContentsOfFile:mediaUrl];
            
            //Resize the image
            thumbImage = [Util resizeTheImage:thumbImage];
            
            //Compress image to send
            mediaData = UIImageJPEGRepresentation(thumbImage, .75);
            
        }
        else{
            thumbImage = [self getThumbFromVideo:mediaUrl];
        }
        
        //Check media validation
        NSLog(@"media : %lu   allowed  %ld",[mediaData length]/1024,(long)[mediaSize integerValue]);
        if((([mediaData length]/1024) <= [mediaSize integerValue])){
            //Return asset
            callback(mediaData,thumbImage);
        }
        else
        {
            //Return asset
            callback(nil,nil);
        }
    }
}

//Get thumbnail image from video url
- (UIImage *)getThumbFromVideo:(NSString *)url{
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:url]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    return thumbnail;
}

+ (void)compressVideo:(AVAsset *)video withMaxSize:(NSNumber *)mediaSize andCallback:(getAssetData)callback {
    
    NSURL *url = (NSURL *)[(AVURLAsset *)video URL];
    NSString *extension = [url pathExtension];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/%@.%@", [paths objectAtIndex:0], [Util randomStringWithLength:10], extension];
    NSURL *outputURL = [NSURL fileURLWithPath:documentsDirectory];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:video presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = outputURL;

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSData *mediaData = [NSData dataWithContentsOfURL:outputURL];
        NSLog(@"Video compressed %ld", [mediaData length]);
        if ([mediaData length] / 1024 <= [mediaSize integerValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(mediaData);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

+ (CGSize)calculateVideoSize:(CGSize)resolution {
    if (MAX(resolution.width, resolution.height) > MAX_VIDEO_RESOLUTION) {
//        CGSizeMake
        float scale = MAX_VIDEO_RESOLUTION / MAX(resolution.width, resolution.height);
        return CGSizeMake((int)(round(resolution.width * scale / 2) * 2), (int)(round(resolution.height * scale / 2) * 2));
    }
    return resolution;
}

//+ (float)calculateVideoBitrateForSize:(CGSize)oldResolution scaledSize:(CGSize)resolution andBitrate:(float)bitrate {
+ (float)calculateVideoBitrateForSize:(CGSize)resolution andFrameRate:(float)frameRate {

//    float scale = resolution.width / oldResolution.width;
    // Cut bitrate by resolution scale divided by 2
    
    return resolution.width * resolution.height * frameRate * 0.1;
}

+ (void)compressVideo:(NSURL *)url withCallback:(CompletionBlockWithAssetUrl)callback {
    
//    NSString *extension = [[url absoluteString] pathExtension];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/%@.%@",[paths objectAtIndex:0],[Util randomStringWithLength:10], @"mp4"];
    NSURL *outputURL = [NSURL fileURLWithPath:documentsDirectory];

    
    AVAsset *asset = [AVAsset assetWithURL:url];

    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    size = CGSizeMake(ABS(size.width), ABS(size.height));
//    float bitrate = [videoTrack estimatedDataRate];
//    NSLog(@"size: %@ datarate: %f", NSStringFromCGSize(size), bitrate);
    
    float fr = [videoTrack nominalFrameRate];
    CGSize outputSize = [Util calculateVideoSize:size];
//    float outputBitrate = [Util calculateVideoBitrateForSize:size scaledSize:outputSize andBitrate:bps];
    float outputBitrate = [Util calculateVideoBitrateForSize:outputSize andFrameRate:fr];
    
//    NSLog(@"VIDEO OUTPUTS: %@ %@ %f",NSStringFromCGSize(size), NSStringFromCGSize(outputSize), outputBitrate);
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = outputURL;
    encoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @(outputSize.width),
    AVVideoHeightKey: @(outputSize.height),
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @(outputBitrate),
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    NSLog(@"exporting ...");
    [encoder exportAsynchronouslyWithCompletionHandler:^
    {
        if (encoder.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"Video export succeeded");
            NSData *mediaData = [NSData dataWithContentsOfURL:outputURL];
            NSLog(@"After compression : %lu KB", [mediaData length]/1024);
            
            NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"hh:mm:ss";
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            NSLog(@"After compression Time is %@",[dateFormatter stringFromDate:now]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(outputURL);
            });
        }
        else if (encoder.status == AVAssetExportSessionStatusCancelled)
        {
            NSLog(@"Video export cancelled");
        }
        else
        {
            NSLog(@"Video export failed with error: %@ (%d)", encoder.error.localizedDescription, (int)encoder.error.code);
        }
    }];
}

- (void)compressVideo:(NSString *)videoURL isCaptured:(BOOL)isCaptured toPass:(getAssetFromUrl)callback withSize:(NSNumber *)mediaSize withImage:(UIImage *)thumbImage {
    
    MBProgressHUD *loader = [Util showLoading];
    
    //Get extension
    NSString *extension = @"";
    if (isCaptured) {
        extension = [videoURL pathExtension];
    }else{
        NSRange range = [videoURL rangeOfString:@"&ext="];
        extension = [[videoURL  substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/%@.%@",[paths objectAtIndex:0],[Util randomStringWithLength:10],extension];
    NSURL *outputURL = [NSURL fileURLWithPath:documentsDirectory];
    
    //compressing code
    AVAsset *video = [AVAsset assetWithURL:[NSURL URLWithString:videoURL]];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:video presetName:AVAssetExportPresetMediumQuality];
//    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:video presetName:AVAssetExportPreset640x480];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = outputURL;
    //MBProgressHUD *loader = [Util showLoadingWithTitle:VIDEO_COMPRESSING];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"Video compressed");
        
        NSData *mediaData = [NSData dataWithContentsOfURL:outputURL];
        
        NSDate *now = [NSDate date];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"hh:mm:ss";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSLog(@"After compression Time is %@",[dateFormatter stringFromDate:now]);
        
        //Check media validation
        NSLog(@"After compression : %lu KB and allowed  %ld",[mediaData length]/1024,(long)[mediaSize integerValue]);
        if((([mediaData length]/1024) <= [mediaSize integerValue])){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [loader hide:YES];
                //Return asset
                callback(mediaData,thumbImage);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loader hide:YES];
                //Return asset
                callback(nil,nil);
            });
        }
    }];
}

//Get NSData from Asset
+ (NSData *) getNSDataFromAsset:(ALAsset *) asset{
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    return data;
}


#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - Text Methods

+ (void)highlightHashtagsInLabel:(TTTAttributedLabel *)attributedLabel {
    UIColor *color = UIColorFromHexCode(THEME_COLOR);
    NSString *text = attributedLabel.text;
  //  NSRegularExpression *hashtagExpression = [NSRegularExpression regularExpressionWithPattern:@"(?:^|\\s)(#\\w+)" options:NO error:nil];
    
//    NSRegularExpression *namaetagExpression = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:nil];

    NSRegularExpression *hashtagExpression = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)|@(\\w+)" options:0 error:nil];

    NSArray *matches = [hashtagExpression matchesInString:text
                                                  options:0
                                                    range:NSMakeRange(0, [text length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
        NSArray *objects = [[NSArray alloc] initWithObjects:color,[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
        NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        [attributedLabel addLinkWithTextCheckingResult:match attributes:linkAttributes];
    }
}

//Set read more text for the UILabel
+ (void) setAddMoreTextForLabel :(TTTAttributedLabel *) forLabel endsWithString:(NSString *) endString forlength:(int) charLength forColor:(UIColor *) textColor{
    
    forLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    NSString *continueString = NSLocalizedString(endString, nil);
    //Add continue reading to the text field
    NSString *croppedContent = [NSString stringWithFormat:@"%@ %@",[self getNCharacters:charLength forString:forLabel.text],continueString];
    [forLabel setText:croppedContent];
    [self setHyperlinkForLabel:forLabel forText:continueString destinationURL:@"" forColor:textColor];
    
    //Note : add the delegate method inside your class
}

//set hyperlink for the given label
+ (void) setHyperlinkForLabel :(TTTAttributedLabel *) forLabel forText:(NSString *) hyperLinkText destinationURL:(NSString *) URL forColor:(UIColor *) textColor{

    //set the link color properties
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:textColor,[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    forLabel.linkAttributes = linkAttributes;
    //convert the given text into hyper link text
    NSRange range = [forLabel.text rangeOfString:hyperLinkText];
    [forLabel addLinkToURL:[NSURL URLWithString:URL] withRange:range];
    //Note : add the delegate method inside your class
}
+ (void) setHyperlinkForLabelWithUnderline :(TTTAttributedLabel *) forLabel forText:(NSString *) hyperLinkText destinationURL:(NSString *) URL forColor:(UIColor *) textColor {
    
    //set the link color properties
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:textColor,[NSNumber numberWithInt:kCTUnderlineStyleSingle], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    forLabel.linkAttributes = linkAttributes;
    //convert the given text into hyper link text
    NSRange range = [forLabel.text rangeOfString:hyperLinkText];
    [forLabel addLinkToURL:[NSURL URLWithString:URL] withRange:range];
    //Note : add the delegate method inside your class
    
}



//Create team activity label with redirection link
+ (void) createTeamActivityLabel:(TTTAttributedLabel *) forLabel fromValues:(NSDictionary *)activityData{
    
    //set the link color properties
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:[UIColor blackColor],[NSNumber numberWithInt:kCTUnderlineStyleSingle], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    forLabel.linkAttributes = linkAttributes;
    
    //Get message
    NSString *message = [activityData valueForKey:@"message"];
    
    NSMutableArray *ranges = [[NSMutableArray alloc] init];
    NSMutableArray *redirections = [[NSMutableArray alloc] init];
    
    //Iterate through values and get range
    NSMutableArray *values = [[activityData objectForKey:@"values"] mutableCopy];
    NSRange offset = NSMakeRange(0, message.length - 1);
    for (int i=0; i<[values count]; i++) {
        
        NSDictionary *singleValue = [values objectAtIndex:i];
        NSString *name = [singleValue valueForKey:@"value"];
        
        //convert the given text into hyper link text
        NSRange range = [message  rangeOfString:[NSString stringWithFormat:@"@%@",name] options:0 range:offset];
        NSString *redirection = [NSString stringWithFormat:@"VarialLink/%@/%@/%@",[singleValue valueForKey:@"type"],[singleValue valueForKey:@"redirection_id"],[singleValue valueForKey:@"value"]];
        
        if ([[singleValue valueForKey:@"type"] intValue] == 1) {
            redirection = [NSString stringWithFormat:@"VarialLink/%@/%@/%@",[singleValue valueForKey:@"type"],[singleValue valueForKey:@"redirection_id"],[singleValue valueForKey:@"member_relation"]];
        }
        
        if (range.length != 0) {
            
            range.length = range.length - 1;
            [ranges addObject:[NSValue valueWithRange:range]];
            [redirections addObject:redirection];
            
            //Replace the string
            message = [message stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",name]
                                                         withString:name];
            
            offset = NSMakeRange(range.length, message.length - range.length);
        }
        
    }
    
    forLabel.text = message;
    for (int i=0; i<[redirections count]; i++) {
        [redirections replaceObjectAtIndex:i withObject:[[redirections objectAtIndex:i] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
        [forLabel addLinkToURL:[NSURL URLWithString:[redirections objectAtIndex:i]] withRange:[[ranges objectAtIndex:i] rangeValue]];
    }
    
    forLabel.textColor = [UIColor darkGrayColor];
    
}

//Change label as link
+ (void) makeAsLink:(TTTAttributedLabel *)label withColor:(UIColor *)linkColor showUnderLine:(BOOL) underLine range:(NSRange )range{
    //set the link color properties
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects;
    if (underLine) {
         objects = [[NSArray alloc] initWithObjects:linkColor,[NSNumber numberWithInt:kCTUnderlineStyleSingle], nil];
    }else{
         objects = [[NSArray alloc] initWithObjects:linkColor,[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    }
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    label.linkAttributes = linkAttributes;
    [label addLinkToURL:[NSURL URLWithString:@""] withRange:range];
}

//Get N characters from the given string
+ (NSString *) getNCharacters :(int) length forString:(NSString*) inputString{
    
    if([inputString length] > 0)
        return [inputString substringToIndex:length];
    else
        return @"";
}

+ (NSString *)timeStamp :(long)getTime
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:getTime];
    
    NSString *localizedDateTime = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    return localizedDateTime;
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"dd-MMM-yyyy, hh:mm a";
//    NSString *datetime = [dateFormatter stringFromDate:date];
//    return datetime;

}

+ (NSString *)getTime :(NSString *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *datetime = [dateFormatter stringFromDate:date];
    
    return datetime;
}


+ (NSString *)getDate :(long)getTime
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:getTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MMM-yyyy";
    NSString *datetime = [dateFormatter stringFromDate:date];
    
    return datetime;
}

+ (void)addEmptyMessageToTable:(UITableView *)tableView withMessage:(NSString *)message withColor:(UIColor *)color{
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
    
    messageLabel.text = NSLocalizedString(message, nil);
    messageLabel.textColor = color;
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    messageLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16];
    [messageLabel sizeToFit];
    
    tableView.backgroundView = messageLabel;
}

+ (void)addEmptyMessageToCollection:(UICollectionView *)collectionView withMessage:(NSString *)message withColor:(UIColor *)color{
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, collectionView.bounds.size.width, collectionView.bounds.size.height)];
    
    messageLabel.text = NSLocalizedString(message, nil);
    messageLabel.textColor = color;
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    messageLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16];
    [messageLabel sizeToFit];
    
    collectionView.backgroundView = messageLabel;
}

+ (void)addEmptyMessageToTableWithHeader:(UITableView *)tableView withMessage:(NSString *)message withColor:(UIColor *)color{
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, tableView.bounds.size.width, 100)];
    
    messageLabel.text = NSLocalizedString(message, nil);
    messageLabel.textColor = color;
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    messageLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16];
    [tableView setTableFooterView:messageLabel];
    tableView.tableFooterView.hidden = NO;
}

+ (void)addEmptyMessageToCollectionWithHeader:(UICollectionView *)collectionView withMessage:(NSString *)message withColor:(UIColor *)color{
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, collectionView.bounds.size.width, 100)];
    
    messageLabel.text = NSLocalizedString(message, nil);
    messageLabel.textColor = color;
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    messageLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16];
    [collectionView addSubview:messageLabel];
//    collectionView.tableFooterView.hidden = NO;
}

//Return image based on privacy
+ (UIImage *)getImageForPrivacyType:(int)type{
    NSArray *images = [[NSArray alloc] initWithObjects:@"",@"globalFeed.png",@"privateFeed.png",@"",@"teamFeed.png", nil];
    if ([images count] > type) {
        return [UIImage imageNamed:[images objectAtIndex:type]];
    }    
    return nil;
}

+ (void)setUpFloatIcon:(UIButton *)button{
    
    button.layer.cornerRadius = button.frame.size.height / 2 ;
    button.clipsToBounds = NO;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 5);
    button.layer.shadowOpacity = 0.2;
    button.layer.shadowRadius = 1.0;

}

//Get matched object index from array
+ (int)getMatchedObjectPosition:(NSString *)keyString valueToMatch:(NSString *)value from:(NSMutableArray *)source type:(int)type{
    
    for (int i=0; i<[source count]; i++) {
        if (type == 0) {
            NSString * strIndex = [NSString stringWithFormat:@"%@",[[source objectAtIndex:i] objectForKey:keyString]];
            if ([strIndex isEqualToString:value]) {
                return i;
            }
        }else{
            if ([[[source objectAtIndex:i] objectForKey:keyString] intValue] == [value intValue]) {
                return i;
            }
        }
    }
    return -1;
}


+ (NSString *)timeAgo :(NSString *) timeStamp
{
    /*NSDate *today = [NSDate date];
    
    NSTimeZone* CurrentTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [CurrentTimeZone secondsFromGMTForDate:today];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:today];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    NSDate *now = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:today] ;

    
    NSDate *notificationDate = [NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue]];
    
    double deltaSeconds = ([now timeIntervalSinceDate:notificationDate]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int minutes;*/
    
    NSDate *now = [NSDate date];
    NSDate *notificationDate = [NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue]];
    
    double deltaSeconds = ([now timeIntervalSinceDate:notificationDate]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int minutes;
    
    if(deltaSeconds < 5)
    {
        return NSLocalizedString(JUST_NOW, nil);
    }
    else if(deltaSeconds < 60)
    {
        return [NSString stringWithFormat:NSLocalizedString(SECONDS_AGO, nil),(int)deltaSeconds];
    }
    else if(deltaSeconds < 120)
    {
        return NSLocalizedString(A_MINUTE_AGO, nil);
    }
    else if (deltaMinutes < 60)
    {
        return [NSString stringWithFormat:NSLocalizedString(MINUTE_AGO, nil),(int)deltaMinutes];
    }
    else if (deltaMinutes < 120)
    {
        return NSLocalizedString(AN_HOUR_AGO, nil);
    }
    else if (deltaMinutes < (24 * 60))
    {
        minutes = (int)floor(deltaMinutes/60);
        return [NSString stringWithFormat:NSLocalizedString(HOURS_AGO, nil),minutes];
    }
    else if (deltaMinutes < (24 * 60 * 2))
    {
        return NSLocalizedString(YESTERDAY, nil);
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24));
        return [NSString stringWithFormat:NSLocalizedString(DAYS_AGO, nil),minutes];
    }
    else if (deltaMinutes < (24 * 60 * 14))
    {
        return NSLocalizedString(LAST_WEEK, nil);
    }
    else if (deltaMinutes < (24 * 60 * 31))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7));
        return [NSString stringWithFormat:NSLocalizedString(WEEKS_AGO, nil),minutes];
    }
    else if (deltaMinutes < (24 * 60 * 61))
    {
        return NSLocalizedString(LAST_MONTH, nil);
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 30));
        return [NSString stringWithFormat:NSLocalizedString(MONTHS_AGO, nil),minutes];
    }
    else if (deltaMinutes < (24 * 60 * 731))
    {
        return NSLocalizedString(LAST_YEAR, nil);
    }
    
    minutes = (int)floor(deltaMinutes/(60 * 24 * 365));
    return [NSString stringWithFormat:NSLocalizedString(YEARS_AGO, nil), minutes];
}

//Prepare image slider
+ (void)showSlider:(UIViewController *)controller forImage:(NSMutableArray *)imageData atIndex:(NSUInteger)index{
    [Util showSliderForChat:controller forImage:imageData atIndex:index withTitle:@""];
}

+ (void)showSliderForChat:(UIViewController *)controller forImage:(NSMutableArray *)imageData atIndex:(NSUInteger)index withTitle:(NSString *)name{
    
    ImageSlider *slider = [controller.storyboard instantiateViewControllerWithIdentifier:@"ImageSlider"];
    slider.images = imageData;
    slider.startPosition = index;
    if (![name isEqualToString:@""]) {
        slider.isFromChat = @"TRUE";
        slider.titleName = name;
    }
    [controller presentViewController:slider animated:YES completion:NULL];
}


//Prepare for playview controller
+ (void)playVideo:(UIViewController *)controller forUrl:(NSString *)url{
    
    VideoPlayer *player = [[VideoPlayer alloc] init];
    player.videoUrl = url;
    [controller presentViewController:player animated:YES completion:NULL];
}

//Resize the image with aspect ratio
+ (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) widthToResize
{
    @autoreleasepool {
        float oldWidth = sourceImage.size.width;
        float scaleFactor = widthToResize / oldWidth;
        
        float newHeight = sourceImage.size.height * scaleFactor;
        float newWidth = oldWidth * scaleFactor;
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}

+ (CGSize)getAspectRatio:(NSString *)dimension ofParentWidth:(float)parentWidth{
    

    dimension = [dimension stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([dimension isEqualToString:@"X"] || [dimension isEqualToString:@""] || dimension == nil) {
        
        float oldWidth = parentWidth;
        float scaleFactor =  parentWidth / oldWidth;
        
        float newHeight = 460 * scaleFactor;
        float newWidth = oldWidth * scaleFactor;
        CGSize size = CGSizeMake(newWidth, newHeight);
        
        return size;
    }
    else
    {
        NSArray *dimen = [dimension componentsSeparatedByString:@"X"];
        if([dimen count] != 2){
            dimen = [dimension componentsSeparatedByString:@"x"];
        }
        if([dimen count] == 2){
            float oldWidth = [[dimen objectAtIndex:0] floatValue];
            float scaleFactor =  parentWidth / oldWidth;
            
            float newHeight = [[dimen objectAtIndex:1] floatValue] * scaleFactor;
            float newWidth = oldWidth * scaleFactor;
            CGSize size = CGSizeMake(newWidth, newHeight);
            
            //NSLog(@"Dimension %@ converted to %fX%f",dimension,newWidth,newHeight);
            return size;
        }
    }
    
    CGSize size = CGSizeMake(180, 180);
    return size;
}

+ (UIImage *)imageForFeed:(int)feedId withType:(NSString *)imageType
{
    UIImage *image = [[UIImage alloc] init];
    
    if (feedId == 1) { // public feed
        if ([imageType isEqual:@"title"])
            image = [UIImage imageNamed:@"friendsFeedIcon"];
        else if ([imageType isEqual:@"privacy"])
            image = [UIImage imageNamed:@"publicIcon"];
        else
            image = [[UIImage imageNamed:@"friendsFeedIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else if(feedId == 2) { // private feed
        if ([imageType isEqual:@"title"])
            image = [UIImage imageNamed:@"privateFeedIcon"];
        else if ([imageType isEqual:@"privacy"])
            image = [UIImage imageNamed:@"privateIcon"];
        else
            image = [[UIImage imageNamed:@"privateFeedIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else if(feedId == 4 || feedId == 3) { // team feed
        if ([imageType isEqual:@"title"])
            image = [UIImage imageNamed:@"teamFeedIcon"];
        else if ([imageType isEqual:@"privacy"])
            image = [UIImage imageNamed:@"teamIcon"];
        else
            image = [[UIImage imageNamed:@"teamFeedIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else if(feedId == 6) // Popular feed
    {
        if ([imageType isEqual:@"title"])
            image = [UIImage imageNamed:@"popularFeedIcon"];
        else if ([imageType isEqual:@"privacy"])
            image = nil ; // [UIImage imageNamed:@"globalFeed.png"];
        else
            image = [[UIImage imageNamed:@"popularFeedIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    return image;
}

- (void)addImageZoom:(UIImageView *)imageView{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:tap];
}

- (void)zoomImageView:(UIImageView *)imageView {
    CGRect frame = imageView.frame;
    //Create overlay
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    
    [UIView animateWithDuration:1 animations:^{ [imageView addSubview:overlay]; } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{ }  completion:^(BOOL finished) {
            [overlay removeFromSuperview];
        }];
        [[ZoomImage sharedInstance] showBigImage:imageView];
    }];
    
    UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *controller = [[navigation viewControllers] lastObject];
    [controller.view resignFirstResponder];
    if([controller isKindOfClass:[Comments class]]){
        Comments *comments = (Comments *)controller;
        [comments.message resignFirstResponder];
    }
    if([controller isKindOfClass:[BuzzardRunComments class]]){
        BuzzardRunComments *comments = (BuzzardRunComments *)controller;
        [comments.message resignFirstResponder];
    }
    if([controller isKindOfClass:[FriendsChat class]]){
        FriendsChat *chat = (FriendsChat *)controller;
        [chat.messageText resignFirstResponder];
    }
}

//Tap gesture recognizer for image
- (void) zoomImage:(UITapGestureRecognizer *)tapRecognizer {
    
    //Convert view to imageview
    UIImageView *imageView = (UIImageView *)tapRecognizer.view;
    [self zoomImageView:imageView];
}

//Return the label based on the type of user
+(NSString *)playerType :(int)typeId playerRank:(NSString *)rank
{
    NSString *strType = @"";
    if (typeId == 1) {
        strType = [NSString stringWithFormat:NSLocalizedString(RANK, nil), rank];
    }
    else if(typeId == 2)
    {
        strType = NSLocalizedString(CREW, nil);
    }
    else if (typeId == 3)
    {
        strType = NSLocalizedString(MEDIA, nil);
    }
    return strType;
}


//Return the label based on the type of user
+(NSString *)playerTypeInProfilePage :(int)typeId playerRank:(NSString *)rank
{
    NSString *strType = @"";
    if (typeId == 1) {
        strType = [NSString stringWithFormat:NSLocalizedString(RANKVAL, nil), rank];
    }
    else if(typeId == 2)
    {
        strType = NSLocalizedString(CREW, nil);
    }
    else if (typeId == 3)
    {
        strType = NSLocalizedString(MEDIA, nil);
    }
    return strType;
}

+ (NSString *)getOriginalImageUrl:(NSString *)imageThumbUrl{
    
    NSString *imageThumbFileName = [imageThumbUrl lastPathComponent];
    NSArray *imageFileNames = [imageThumbFileName componentsSeparatedByString:@"_"];
    NSString *fileName;    
    if ([imageFileNames count] == 2) {
        fileName = imageFileNames[1];
        NSRange range = [imageThumbUrl rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *base = [imageThumbUrl substringToIndex:range.location];
        NSString *fullImageUrl = [NSString stringWithFormat:@"%@/%@",base,fileName];
        NSLog(@"Filename :%@",fullImageUrl);
        return fullImageUrl;
    }
    return nil;
}


+ (void) addImageBlurEffect:(UIImageView *)imageView{
    
   /* imageView.alpha = .2;
    [UIView transitionWithView:imageView
                      duration:.5
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        imageView.alpha = 1;
                    }
                    completion:^(BOOL finished){
                        
                        
                    }];*/

}

// Web Socket

+ (NSString *) buildRequestDataForSocket :(NSDictionary *) parameters{
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&err];
    NSString *requestParameters = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return requestParameters;
}

+ (NSMutableDictionary *)convertStringToDictionary:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [json mutableCopy];
}

+ (NSString *)buildDataToSend:(NSString *)type withBody:(NSMutableDictionary *)body {
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    [message setValue:type forKey:@"t"];
    [message setObject:body forKey:@"d"];
    return [Util buildRequestDataForSocket:message];
}

+ (NSMutableAttributedString *)feedsHeaderName:(NSString *)nameValue desc:(NSString *)postDescription {
    NSMutableAttributedString *PostUserName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",nameValue,postDescription]];
    [PostUserName addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"CenturyGothic" size:15]
                         range:NSMakeRange(0, [nameValue length])];
    
    [PostUserName addAttribute: NSForegroundColorAttributeName
                         value: UIColorFromHexCode(GREY_TEXT)
                         range: NSMakeRange([nameValue length]+1,[postDescription length])];
    
    [PostUserName addAttribute: NSFontAttributeName
                         value:  [UIFont fontWithName:@"CenturyGothic" size:13]
                         range: NSMakeRange([nameValue length]+1,[postDescription length])];
    
    return PostUserName;
}


+ (void)setProgressWithAnimation:(UIProgressView *)progressView withDuration:(int)duration {
    
    for (int i = 1; i <= duration; i++) {
        double delayInSeconds = i;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //NSLog(@"PRoo %f", i/(100 * 1.0f));
            if (progressView.progress < .15) {
                [progressView setProgress:i/(100 * 1.0f) animated:YES];
            }            
        });
    }
}

-(UIView *)drawArrowwithxCord:(float)xCord yCord:(float)yCord
{
    UIView *arrowView = [[UIView alloc]init];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xCord, yCord)];
    [path addCurveToPoint: CGPointMake(xCord+50, yCord+220) controlPoint1: CGPointMake(xCord, yCord) controlPoint2: CGPointMake(xCord-70, yCord+120)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.lineWidth = 4.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [arrowView.layer addSublayer:shapeLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xCord+50, yCord+220)];
    [path addLineToPoint:CGPointMake(xCord+30, yCord+220)];
    [path addLineToPoint:CGPointMake(xCord+60, yCord+230)];
    [path addLineToPoint:CGPointMake(xCord+50, yCord+200)];
    [path addLineToPoint:CGPointMake(xCord+50, yCord+220)];
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor redColor] CGColor];
    [arrowView.layer addSublayer:shapeLayer];
    
    pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.0f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:2.0f];
    [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xCord+0.5, yCord-1)];
    [path addCurveToPoint: CGPointMake(xCord+30, yCord+210) controlPoint1: CGPointMake(xCord+0.5, yCord-1) controlPoint2: CGPointMake(xCord-70, yCord+120)];
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    shapeLayer.strokeColor = background.CGColor;
    shapeLayer.lineWidth = 5.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [arrowView.layer addSublayer:shapeLayer];
    
    pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    return arrowView;
    
}


+ (NSString *)getChatHistoryDate :(NSString *) timeStamp
{
    NSDate *now = [NSDate date];
    NSDate *notificationDate = [NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue]];
    
    double deltaSeconds = ([now timeIntervalSinceDate:notificationDate]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    if (deltaMinutes < (12 * 60))
    {
        return [Util formatNSDateToString:notificationDate toFormat:@"hh:mm a"];
    }
    else if (deltaMinutes < (24 * 60 * 2))
    {
        return NSLocalizedString(YESTERDAY, nil);
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        return [Util formatNSDateToString:notificationDate toFormat:@"EEEE"];
    }
    else
    {
        return [Util formatNSDateToString:notificationDate toFormat:@"dd/MM/yy"];
    }
}

+ (NSString *)formatNSDateToString:(NSDate *)date toFormat:(NSString *)format{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    NSString *datetime = [dateFormatter stringFromDate:date];
    return  datetime;
}


+ (NSString *)getChatHistoryTime :(NSString *) timeStamp
{
    NSDate *now = [NSDate date];
    NSDate *notificationDate = [NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue]];
    
    double deltaSeconds = ([now timeIntervalSinceDate:notificationDate]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    if (deltaMinutes < (12 * 60))
    {
        return NSLocalizedString(TODAY, nil);
    }
    else if (deltaMinutes < (24 * 60 * 2))
    {
        return NSLocalizedString(YESTERDAY, nil);
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        return [Util formatNSDateToString:notificationDate toFormat:@"EEEE"];
    }
    else
    {
        return [Util formatNSDateToString:notificationDate toFormat:@"dd/MM/yy"];
    }
}

+ (BOOL)checkLocationIsEnabled{
    
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            return  FALSE;
        }
        return TRUE;
    }
    else{
        return FALSE;
    }
}

- (void)resetNotificationCount:(int)type{
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:type] forKey:@"notification_type"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:RESET_NOTIFICATION withCallBack:^(NSDictionary * response){
        
    } isShowLoader:NO];
}

+ (NSString *)getGoogleApiKey{
    //return ISLIVE ? LIVE_GOOGLE_KEY : DEV_GOOGLE_KEY;
        return LIVE_GOOGLE_KEY;
}

+ (NSString *)getBiaduApiKey{
    //return ISLIVE ? LIVE_BAIDU_KEY : DEV_BAIDU_KEY;
        return LIVE_BAIDU_KEY;
}

//Append device information
+ (void)appendDeviceMeta:(NSMutableDictionary *)params{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    //setting the deviceId
    [params setValue:[appDelegate getDeviceUniqueId] forKey:@"device_id"];
    [params setValue:DEVICE_TYPE forKey:@"device_type"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil) {
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
        [params setValue:deviceToken forKey:@"device_token"];
    }
    else{
        [params setValue:[appDelegate getDeviceUniqueId] forKey:@"device_token"];
    }
}

+ (BOOL)checkoutNotificationStatus{
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){ // Check it's iOS 8 and above
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (grantedSettings.types == UIUserNotificationTypeNone) {
            return FALSE;
        }
        else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
            NSLog(@"Sound and alert permissions ");
            return TRUE;
        }
        else if (grantedSettings.types  & UIUserNotificationTypeAlert){
            NSLog(@"Alert Permission Granted");
            return TRUE;
        }
    }    
    return FALSE;
}

+ (NSString *)imageToNSString:(UIImage *)image
{
    NSData *data = UIImagePNGRepresentation(image);
    
    return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

+ (UIImage *)stringToUIImage:(NSString *)string
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return [UIImage imageWithData:data];
}

+ (UIImage *)addBlurEffect:(UIImage *)originalImage{
    
    CIImage *imageToBlur = [CIImage imageWithCGImage:originalImage.CGImage];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 1] forKey: @"inputRadius"]; //change number to increase/decrease blur
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImg = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[imageToBlur extent]];
    UIImage *outputImg = [UIImage imageWithCGImage:cgImg];
    
    return outputImg;
}

+ (void)setPointsIconText:(UIButton *)button withSize:(int)size{
    
    //1.Add rounded red corner
    button.layer.cornerRadius = button.frame.size.height / 2 ;
    button.clipsToBounds = true;
    [button.layer setBorderColor: UIColorFromHexCode(THEME_COLOR).CGColor];
    [button.layer setBorderWidth:1.5f];
    
    //2.Remove old images
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    button.titleLabel.textColor = [UIColor whiteColor];
    
    //3.Set Font
    if (isEnglish) {
        [button setTitle:@"P" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:size+4];
    }
    else{
        [button setTitle:@"分数" forState:UIControlStateNormal ];
        button.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:size];
    }

}

//Scrolls to top of the table view
+(void)scrollToTop:(UITableView *)tableView fromArrayList:(NSMutableArray *)array{
    int count = (int)[array count];
    if (count > 0 && count <= 10) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

+ (NSString *)getAppVersion{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
    return currentVersion;
}

+ (NSString *)getBuildNumber{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* currentVersion = infoDictionary[@"CFBundleVersion"];
    return currentVersion;
}

// Check Team is available or not
+(BOOL) isTeamPresent:(NSString *)teamId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *teamList = [[defaults objectForKey:@"team_details"] mutableCopy];
    
    int index = [Util getMatchedObjectPosition:@"jabber_id" valueToMatch:teamId from:teamList type:0];
    if (index != -1) {
        return TRUE;
    }
    
    return FALSE;
}

+(NSString *)getStarString:(long)sCount
{
    NSString *starString;
    if(sCount >= 1000)
    {
        starString = [NSString stringWithFormat:NSLocalizedString(@"%@ Stars", nil),[self abbreviateNumber: sCount]];
    }
    else
    {
        NSString *strCnt = [NSString stringWithFormat:@"%ld",sCount];
        NSString *star = sCount > 1 ? @"%@ Stars" : @"%@ Star";
        NSString *starCount = (sCount == 0 ) ? @"Star" : star;
        starString = [NSString stringWithFormat:NSLocalizedString(starCount, nil),strCnt];
    }
    return starString;
}

+(NSString *)getCommentsString:(long)cComment
{
    NSString *commentString;
    if(cComment >= 1000)
    {
        commentString = [NSString stringWithFormat:NSLocalizedString(@"%@ Comments", nil),[self abbreviateNumber: cComment]];
    }
    else
    {
        NSString *cmtCount = [NSString stringWithFormat:@"%ld",cComment];
        NSString *comment = cComment > 1 ? @"%@ Comments" : @"%@ Comment";
        NSString *cmdCount = (cComment == 0 ) ? @"Comment" : comment;
        commentString = [NSString stringWithFormat:NSLocalizedString(cmdCount, nil),cmtCount];
    }
    return commentString;
}

+(NSString *)getViewsString:(long)viewCount
{
    NSString *viewString;
    if(viewCount >= 1000)
    {
        if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
        {
            viewString = [NSString stringWithFormat:NSLocalizedString(@"%@ Views", nil),[self abbreviateNumber: viewCount]];
        }
        
        else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
        {
            viewString = [NSString stringWithFormat:NSLocalizedString(@"%@ 意見", nil),[self abbreviateNumber: viewCount]];
        }
        
    }
    else
    {
        NSString *vCount = [NSString stringWithFormat:@"%ld",viewCount];
        NSString *views;
        if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
        {
            views = @"%@ Views";
        }
        
        else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
        {
            views = @"%@ 意見";
        }
        
        viewString = [NSString stringWithFormat:NSLocalizedString(views, nil),vCount];
    }
    return viewString;
}

+(NSString *) suffixValue : (double) number
{
   number = 1000;
    NSString *result;
    NSArray *suffix = [NSArray arrayWithObjects:@"K",@"M",@"B",@"T",@"P",@"E",@"Z",@"Y" , nil];
    
    for (int j=(int)[suffix count]; j>0; j--) {
        long  unit = 1000;
        for(int i=0; i<=j; i++)
        {
            unit = unit * 1000;
        }
        
        if (number >= unit){
            result = [NSString stringWithFormat:@"%f %@",(number / unit),[suffix objectAtIndex:--j]];
            NSArray *array = [result componentsSeparatedByString:@"."];
            if ([array count] == 2) {
                result = [NSString stringWithFormat:@"%@.%@%@",[array objectAtIndex:0], [[array objectAtIndex:1] substringToIndex:1],[suffix objectAtIndex:j]];
            }
            return  result;
        }
    }
    return result;
}

+ (NSString *)abbreviateNumber:(long)count {
    
    double cousant = 0.0,reminder = 0.0;
    NSString *symbol, *finalValue, *secondValue = @"";
    NSArray *symbols = [[NSArray alloc] initWithObjects:@"B", @"M", @"K", nil];
    NSArray *metrics = [[NSArray alloc] initWithObjects:@"1000000000", @"1000000", @"1000", nil];
    
    if (count > 999) {
        for (int i=0; i < [symbols count]; i++) {
            long metric = [[metrics objectAtIndex:i] longLongValue];
            if (count >= metric){
                cousant = count / metric;
                reminder = count % metric;
                symbol = [symbols objectAtIndex:i];
                if (reminder <= (metric/10 - 1)) {
                    reminder = 0;
                }
                if (reminder != 0) {
                    NSString *rem = [NSString stringWithFormat:@"%d", (int)reminder];
                    secondValue = [NSString stringWithFormat:@".%@",[rem substringToIndex:1]];
                }
                finalValue = [NSString stringWithFormat:@"%d%@ %@",(int)cousant,secondValue,symbol];
                break;
            }
        }
    }
    else{
        finalValue = [NSString stringWithFormat:@"%ld", count];
    }
    
    return finalValue;
}

+(MBCircularProgressBarView *)designdownloadProgress :(MBCircularProgressBarView *)downloadProgress
{
    downloadProgress.progressColor = UIColorFromHexCode(THEME_COLOR);
    downloadProgress.progressStrokeColor = UIColorFromHexCode(THEME_COLOR);
    downloadProgress.showValueString = FALSE;
    downloadProgress.progressLineWidth = 1.5;
    downloadProgress.maxValue = 1;
    downloadProgress.value = .05;
    downloadProgress.backgroundColor = [UIColor clearColor];
    downloadProgress.progressAngle = 100;
    
    return downloadProgress;
}


+(UIImage *) deletedImages :(NSString *)mediaUrl
{
    UIImage *image;
    NSString *image64 = [[NSUserDefaults standardUserDefaults] objectForKey:mediaUrl];
    if (image64 != nil) {
        NSRange range = [image64 rangeOfString:IMAGE_KEY];
        NSString  *originalImage = [image64 substringFromIndex:range.length];
        image = [Util stringToUIImage:originalImage];
        image = [Util addBlurEffect:image];
    }
    
    return image;
}

// Get base url
+(NSString *)getBaseUrl
{
    NSString *Environment;
    
    if (ENVIRONMENT == 1)
        Environment = DEV_BASE_URL;
    else if(ENVIRONMENT == 2)
        Environment = STAGING_BASE_URL;
    else if (ENVIRONMENT == 3)
        Environment = LIVE_BASE_URL;
        
    return Environment;
}

// Get shopping url
+(NSString *)getShopUrl
{
    NSString *url;
    
    if (ENVIRONMENT == 1)
        url = DEV_SHOP;
    else if(ENVIRONMENT == 2)
        url = STAGING_SHOP;
    else if (ENVIRONMENT == 3)
        url = LIVE_SHOP;
   
    return url;
}

// Get shop host name
+(NSString *)getShopHost
{
    NSString *url;
    
    if (ENVIRONMENT == 1)
        url = DEV_SHOP_HOST;
    else if(ENVIRONMENT == 2)
        url = STAGING_SHOP_HOST;
    else if (ENVIRONMENT == 3)
        url = LIVE_SHOP_HOST;
    
    return url;
}

// Get Chat URL
+(NSString *)getChatUrl
{
    NSString *url;
    
    if (ENVIRONMENT == 1)
        url = DEV_CHAT;
    else if(ENVIRONMENT == 2)
        url = STAGING_CHAT;
    else if (ENVIRONMENT == 3)
        url = LIVE_CHAT;
    
    return url;
}

+ (void)preloadImageFromUrl:(NSString *)url{
    //Load image previously
    __strong UIImageView *imageView = [[UIImageView alloc] init];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:300];
    [imageView setImageWithURLRequest:req placeholderImage:nil  success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
}
+(void)setStatusBar{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}


//Play video
- (AVPlayer *)playVideo:(NSString *)mediaUrl withThumb:(UIImage *)thumbImg fromController:(UIViewController *)controller withUrl:(NSString *)thumbUrl{
    
    //Allow landscape orientation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.shouldAllowRotation = TRUE;
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:mediaUrl]];
    
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
    
    //Create player view controller
    //playerViewController = [[AVPlayerViewController alloc] init];
    appDelegate.playerViewController.player = player;
    
    //Assign the thumbimage in player view controller
    //It shows untill the player gets ready
    UIImageView *thumbImage = [[UIImageView alloc] initWithFrame:appDelegate.playerViewController.view.frame];
   //kp
    [appDelegate.playerViewController.view willRemoveSubview:thumbImage];

    if (thumbImg != nil) {
        [thumbImage setImage:thumbImg];
    }
    
    if (thumbUrl != nil) {
        
        [thumbImage setImageWithURL:[NSURL URLWithString:thumbUrl]];
    }
    
    thumbImage.contentMode = UIViewContentModeScaleAspectFit;
    thumbImage.center = appDelegate.playerViewController.view.center;
    thumbImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [appDelegate.playerViewController.view insertSubview:thumbImage atIndex:0];
    //Launch the player
    [controller presentViewController:appDelegate.playerViewController animated:YES completion:NULL];
    
    return player;
}

// Will be called when AVPlayer finishes playing playerItem
-(void)itemDidFinishPlaying:(NSNotification *) notification {
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    [appDelegate.playerViewController dismissViewControllerAnimated:YES completion:nil];
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
//    appDelegate.shouldAllowRotation = NO;
    

    
    [self increaseViewCount:_playedMediaId];
    
}

//Increase the video view count
- (void)increaseViewCount:(NSString *)mediaId{
    
    //Increase the video view count
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:mediaId forKey:@"media_id"];
    
    [self sendHTTPPostRequest:inputParams withRequestUrl:ADD_VIDEO_COUNT withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
        }
        else{
            
        }
    } isShowLoader:NO];
}

+ (BOOL) isVideoMinimumtwoMins :(NSURL *)videoUrl
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    NSTimeInterval durationInSeconds = 0.0;
    if (asset)
    {
        durationInSeconds = CMTimeGetSeconds(asset.duration);
        
        if (durationInSeconds > 2.0) {
            return true;
        }
    }
    
    NSLog(@"duration: %.2f", durationInSeconds);
    
    return false;
}

+(NSString*)getDeviceModel:(NSString *)platform{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch (6 Gen)";
    
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return  @"";
}

@end
