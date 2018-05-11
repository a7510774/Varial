//
//  FriendsChat.m
//  EJabberChat
//
//  Created by Shanmuga priya on 5/13/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "FriendsChat.h"
#import "Util.h"
#import "ChatMenu.h"
#import "XMPPMessage.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPMessage+XEP_0184.h"
#import "IQKeyboardManager.h"
#import "ChatDBManager.h"
#import "DBManager.h"
#import "AlertMessage.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "FriendProfile.h"
#import "SAMTextView.h"
#import "JSQMessagesCollectionViewCell.h"
#import "MediaGallery.h"
@interface FriendsChat ()

@end

@implementation FriendsChat
AppDelegate *appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Initialize the objects
    xmppStream = [XMPPServer sharedInstance].xmppStream;
    
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[self class]];
    [[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[self class]];
    
    //Read child view controller
    UIViewController *childViewController = [[self childViewControllers] objectAtIndex:0];
    chatWindow = (ChatWindow *)childViewController;
    chatView = (JSQMessagesViewController *)childViewController;
    chatView.senderId = [[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"];
    chatWindow.receiverId = _receiverID;
    
    titleArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(IMAGE,nil) ,NSLocalizedString(VIDEO, nil), nil];
    imageArray = [[NSMutableArray alloc]initWithObjects:@"image.png", @"video.png" , @"cameraGrey.png" , nil];
    // Emoji keyboard
    emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
    emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    emojiKeyboardView.delegate = self;
    
    [self designTheView];
    [self sendContactRequest];
    [self getChatHistoryFromLocal];
    [self changeKeyboardTypeButtonImage];
    
    //Show set the user last composed messsage
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *messageDict = [[defaults objectForKey:@"composing_message"] mutableCopy];
    if([messageDict objectForKey:_receiverID] != nil)
        _messageText.text = [messageDict objectForKey:_receiverID];
    
    [self registerForKeyboardNotifications];
    _messageText.delegate = self;
    
    //Forward message
    if (_forwardMessage != nil) {
        [self forwardMessageToUser];
    }
    
    [self createBlockedStateView:0];
    [_addMediaButton setImage:[UIImage imageNamed:@"Plus.png"] forState:UIControlStateNormal];
   // _messageText.keyboardType = UIKeyboardTypeASCIICapable;
    
    // status = [ALAssetsLibrary authorizationStatus];
    
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [self unregisterNotification];
}

- (void)viewDidUnload:(BOOL)animated{
    [self unregisterNotification];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self registerForNotification];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate refreshNotification];
    
    [self resetUnreadCount];
    [self designTheViewBasedOnUserPriavacyStatus];
    [self sendMediaMessage];
    
    //Hide chat badge count in this page
    [[ChatDBManager sharedInstance] hideOrShowChatBadge:TRUE];
    
    //Get current friends status
    [self getFriendStatus];
    [_mediaMenu reloadData];
    
    //hide media menu
    _menuBottom.constant = -90;
    _marginBottom.constant = 0;
    
    [self hideAndShowSendButton];
    [self changeTextViewHeight:_messageText];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[ChatDBManager sharedInstance] hideOrShowChatBadge:FALSE];
}

- (IBAction)goBack:(id)sender {
    
    //Remove the friends screen
    if (_isFromFriends != nil) {
        NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];
        int count = (int) [viewControllers count];
        [viewControllers removeObjectAtIndex:count - 2];
        self.navigationController.viewControllers = viewControllers;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) changeKeyboardTypeButtonImage
{
    if (_isEmojiKeyboard) {
        
        [_keyboardButton setImage:[UIImage imageNamed:@"Keyboard.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_keyboardButton setImage:[UIImage imageNamed:@"Smily.png"] forState:UIControlStateNormal];
    }
    [_keyboardButton setTitle:@"" forState:UIControlStateNormal];
}

-(IBAction)changeKeyboardType:(id)sender
{
    if (_isEmojiKeyboard)
    {
        _isEmojiKeyboard = FALSE;
        [self showNormalKeyboard];
    }
    else
    {
        _isEmojiKeyboard = TRUE;
        [self showEmojiKeyboard];
    }
    
    [self changeKeyboardTypeButtonImage];
}

-(void)showEmojiKeyboard
{
    [self.messageText resignFirstResponder];
    self.messageText.inputView = emojiKeyboardView;
    [self.messageText becomeFirstResponder];
}

-(void)showNormalKeyboard
{
    [self.messageText resignFirstResponder];
    self.messageText.inputView = nil;
    [self.messageText becomeFirstResponder];
}

- (IBAction)openCamera:(id)sender {
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, (NSString *) kUTTypeImage, nil];
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        if([[Util sharedInstance].assetLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL])
        {
            //save video url to photos library
            [[Util sharedInstance].assetLibrary writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
                [[Util sharedInstance].assetLibrary addAssetURL:assetURL toAlbum:ALBUM_NAME withCompletionBlock:^(NSError *error, NSURL *mediaUrl) {
                    NSMutableArray *videos = [[NSMutableArray alloc] init];
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:mediaUrl forKey:IQMediaAssetURL];
                    [videos addObject:dict];
                    [self createMediaResource:videos ofType:FALSE];
                }];
            } ];
        }
    }
    else
    {
        UIImage *capturedImage = info[UIImagePickerControllerOriginalImage];
        
        //Save image in local
        [[Util sharedInstance].assetLibrary saveImage:capturedImage toAlbum:ALBUM_NAME withCompletionBlock:^(NSError *error, NSURL *assetUrl) {
            NSMutableArray *images = [[NSMutableArray alloc] init];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:assetUrl forKey:IQMediaImage];
            [images addObject:dict];
            [self createMediaResource:images ofType:TRUE];
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//Create mutable array of medias
- (void)createMediaResource:(NSMutableArray *)mediaData ofType:(BOOL) isPhotos
{
    
    NSString *mediaPath = isPhotos ? [[[mediaData objectAtIndex:0] valueForKey:@"IQMediaImage"] absoluteString] :  [[[mediaData objectAtIndex:0] valueForKey:@"IQMediaAssetURL"] absoluteString];
    
    int size =  maxImageFileSize;
    
    //2. Check media has valid size
    [[Util sharedInstance] checkMediaHasValidSize:isPhotos ofMediaUrl:mediaPath withCallBack:^(NSData * data, UIImage * thumbnail){
        
        if(data != nil){
            NSMutableDictionary *media = [[NSMutableDictionary alloc]init];
            [media setObject:thumbnail forKey:@"mediaThumb"];
            [media setObject:data forKey:@"assetData"];
            [media setValue:[NSNumber  numberWithBool:isPhotos] forKey:@"mediaType"];
            [media setObject:mediaPath forKey:@"mediaUrl"];
            [media setObject:[NSNumber numberWithBool:NO] forKey:@"isCaptured"];
            [_medias addObject:media];
            [self sendMediaMessage];
            [mediaData removeObjectAtIndex:0];
        }
        else{
            [mediaData removeObjectAtIndex:0];
            if (!isMaxFileShown) {
                mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(MEDIA_SIZE_SHOULD_BE, nil),size/1024];
                isMaxFileShown = TRUE;
            }
        }
    }];
}
- (IBAction)openMediaMenu:(id)sender {
    
    if([Util getBoolFromDefaults:@"is_chat_enabled"]){
        [_messageText resignFirstResponder];
        if(_menuBottom.constant != 0){
            _marginBottom.constant = 90.5;
            _menuBottom.constant = 0;
        }
        else{
            _marginBottom.constant = 0;
            _menuBottom.constant = -90;
        }
    }
    else{
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(GO_ONLINE, nil)];
    }
}

//Design the view
-(void)designTheView
{
    [self designTheStatusViews];
    
    typingIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallPulse tintColor:UIColorFromHexCode(THEME_COLOR) size:20.0f];
    typingIndicator.frame = CGRectMake(_statusLabel.frame.origin.x, wifiImage.frame.origin.y, 45, 30);
    [_profileView addSubview:typingIndicator];
    
    //Adjust the profile name frame
    CGRect frame = _profileName.frame;
    frame.size.width -= 20;
    _profileName.frame = frame;
    
    [_profileName setTextAlignment:NSTextAlignmentCenter];
    
    [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(CHAT_FRIENDS, nil)]];
    [_headerView.logo setHidden:YES];
    _headerView.restrictBack = TRUE;
    
    if ([chatWindow canSend]) {
        [self changeStatus:SEE_PROFILE_INFO];
    }
    else{
        [self changeStatus:CONNECTING];
        if (![[Util sharedInstance] getNetWorkStatus]) {
            [self changeStatus:WAITING_FOR_NETWORK];
        }
    }
    
    //Set back button image insets
    _backButton.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 15);
    
    //Add marquee to status label
    _statusLabel.marqueeType = MLLeftRight;
    _statusLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    
    //Set receiver profile image and name
    _profileName.text = _receiverName;
    [_profileThumb setImageWithURL:[NSURL URLWithString:_receiverImage] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    receiverJID = [XMPPJID jidWithString:_receiverID];
    
    //Add zoom
    //[[Util sharedInstance] addImageZoom:_profileThumb];
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPress:)];
    [_profileThumb setUserInteractionEnabled:YES];
    [_profileThumb addGestureRecognizer:imageTap];
    
    _messageText.placeholder = NSLocalizedString(WRITE_MESSAGE, nil);
    
    //Add tap recognizer
    UITapGestureRecognizer *lpgr = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(handleTapPress:)];
    lpgr.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleTapPress:)];
    tap.delegate = self;
    [_profileName setUserInteractionEnabled:YES];
    [_statusLabel setUserInteractionEnabled:YES];
    [_statusLabel addGestureRecognizer:lpgr];
    [_profileName addGestureRecognizer:tap];
    
    _medias = [[NSMutableArray alloc]init];
    mediaDict = [[NSMutableDictionary alloc]init];
    mediaExceed = [[NetworkAlert alloc] init];
    [mediaExceed setNetworkHeader:NSLocalizedString(MEDIA, nil)];
    [mediaExceed.button setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
    
    [self.messageText  setTextContainerInset:UIEdgeInsetsMake(10,10, 0, 0)];
}

//Design the wifi, animating wifi, online status view
-(void)designTheStatusViews{
    
    _statusLabel.hidden = YES;
    wifiImage = [[UIImageView alloc]initWithFrame:CGRectMake(_statusLabel.frame.origin.x, _statusLabel.frame.origin.y, 20, 20)];
    
    [_profileView addSubview:wifiImage];
    
    onlineStatus = [[UIView alloc]initWithFrame:CGRectMake(0,0, 10, 10)];
    if([Util getBoolFromDefaults:@"is_chat_enabled"])
        [onlineStatus setBackgroundColor:[UIColor grayColor]];
    else
        [onlineStatus setBackgroundColor:[UIColor blackColor]];
    onlineStatus.layer.cornerRadius = 5;
    [self.view addSubview:onlineStatus];
    [self changeStatus:_statusLabel.text];
    
    //Add auto layout to online status view
    [onlineStatus setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (onlineStatus);
    NSString *verticalConstraint = [NSString stringWithFormat:@"V:|-45-[onlineStatus(10)]"];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:verticalConstraint
                               options:NSLayoutFormatAlignAllBottom metrics:nil
                               views:viewsDictionary]];
    
    NSString *horizontalConstraint = [NSString stringWithFormat:@"H:[onlineStatus(10)]-55-|"];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:horizontalConstraint
                               options:NSLayoutFormatAlignAllCenterY metrics:nil
                               views:viewsDictionary]];
    
    [self.view layoutIfNeeded];
    
    //Hide the status view if group chat
    if (![_isSingleChat isEqualToString:@"TRUE"]) {
        [onlineStatus setHidden:YES];
    }
}

//Change header view status
-(void)changeStatus:(NSString*)status{
    
    if ([Util getBoolFromDefaults:@"is_chat_enabled"]) {
        _statusLabel.text = NSLocalizedString(status, nil);
        _statusLabel.hidden = YES;
        [typingIndicator stopAnimating];
        
        if([status isEqualToString:WAITING_FOR_NETWORK])
        {
            [wifiImage stopAnimating];
            wifiImage.image = [UIImage imageNamed:@"wifiDisabled.png"];
            [wifiImage setHidden:NO];
        }
        else if([status isEqualToString:CONNECTING])
        {
            [self animateImages];
        }
        else if ([status isEqualToString:NSLocalizedString(ONLINE, nil)])
        {
            [wifiImage stopAnimating];
            [wifiImage setHidden:YES];
            [onlineStatus setBackgroundColor:[UIColor greenColor]];
        }
        else if([status isEqualToString:TYPING])
        {
            [wifiImage stopAnimating];
            [wifiImage setHidden:YES];
            [typingIndicator setHidden:NO];
            [typingIndicator startAnimating];
        }
        else if ([status containsString:NSLocalizedString(LAST_SEEN, nil)])
        {
            [wifiImage stopAnimating];
            [wifiImage setHidden:YES];
            [onlineStatus setBackgroundColor:[UIColor grayColor]];
        }
        else if ([status isEqualToString:NSLocalizedString(SEE_PROFILE_INFO, nil)])
        {
            [wifiImage stopAnimating];
            [wifiImage setHidden:YES];
        }
    }
}


//Show animating wifi
-(void)animateImages{
    NSArray *animationArray = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"1.png"],
                               [UIImage imageNamed:@"2.png"],
                               [UIImage imageNamed:@"3.png"],
                               [UIImage imageNamed:@"4.png"],
                               [UIImage imageNamed:@"5.png"],
                               nil];
    wifiImage.animationImages      = animationArray;
    wifiImage.animationDuration    = 1.5;
    wifiImage.animationRepeatCount = 0;
    wifiImage.hidden = NO;
    [wifiImage startAnimating];
}

//Move to friend profile
-(void)handleTapPress:(UITapGestureRecognizer *)gestureRecognizer
{
    [self showFriendProfile:nil];
}

//Update offline status
- (IBAction)chaneOfflineStatus:(id)sender {
    
    BOOL status = ![Util getBoolFromDefaults:@"is_chat_enabled"];
    
    //Update chat notification
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithBool:status] forKey:@"chat_notification_status"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:UPDATE_CHAT_STATUS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            BOOL status = [Util getBoolFromDefaults:@"is_chat_enabled"];
            
            //Set chat enabled status in session
            [[NSUserDefaults standardUserDefaults] setBool:!status forKey:@"is_chat_enabled"];
            
            //Remove all online users
            [[XMPPServer sharedInstance].onlineUsers removeAllObjects];
            
            //Connect the server
            [appDelegate connectToChatServer];
            
        }
        else{
        }
    } isShowLoader:YES];
}

//Show friend profile
- (IBAction)showFriendProfile:(id)sender {
    
    if ([_isSingleChat isEqualToString:@"TRUE"]) {
        
        FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        friendProfile.friendId = [_receiverID componentsSeparatedByString:@"_"][0];
        friendProfile.friendName = _receiverName;
        [self.navigationController pushViewController:friendProfile animated:YES];
    }
    else
    {
        if ([Util isTeamPresent:_receiverID]) {
            TeamViewController *teamDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
            teamDetails.teamId = [_receiverID componentsSeparatedByString:@"_"][0];
            teamDetails.roomId = _receiverID;
            [self.navigationController pushViewController:teamDetails animated:YES];
        }
        else
        {
            NonMemberTeamViewController *nonMember = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
            nonMember.teamId = [_receiverID componentsSeparatedByString:@"_"][0];
            [self.navigationController pushViewController:nonMember animated:YES];
        }
        
    }
}

//Show the blocked user state
- (void)designTheViewBasedOnUserPriavacyStatus{
    
    if ([_isSingleChat isEqualToString:@"TRUE"]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *blockedUsers = [[defaults objectForKey:@"players_i_blocked"] mutableCopy];
        NSMutableArray *friendsList = [[defaults objectForKey:@"friends_jabber_ids"] mutableCopy];
        NSMutableArray *usersBlockedMe = [[defaults objectForKey:@"players_blocked_me"] mutableCopy];
        
        if ([usersBlockedMe count] != 0 && [usersBlockedMe indexOfObject:_receiverID] != NSNotFound){
            [_profileView hideByHeight:NO];
            //   [self createBlockedStateView:3];
            UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
            [navigation popViewControllerAnimated:YES];
        }
        else if ([blockedUsers count] != 0 && [blockedUsers indexOfObject:_receiverID] != NSNotFound){
            [_profileView hideByHeight:NO];
            //   [self createBlockedStateView:1];
            UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
            [navigation popViewControllerAnimated:YES];
        }
        else if ([friendsList count] == 0 || ([friendsList count] != 0 && [friendsList indexOfObject:_receiverID] == NSNotFound)) {
            [_profileView hideByHeight:NO];
            [self createBlockedStateView:2];
        }
        else{
            [_profileView hideByHeight:NO];
            if (blockView != nil && [Util getBoolFromDefaults:@"is_chat_enabled"]) {
                [blockView setHidden:YES];
            }
            [self getFriendStatus];
            _optionButton.hidden = NO;
        }
    }
    else
    {
        if (![Util isTeamPresent:_receiverID]) {
            [self createBlockedStateView:4];
        }
        else
        {
            [blockView setHidden:YES];
        }
    }
}

- (void)forwardMessageToUser{
    
    NSString *message = [_forwardMessage valueForKey:@"body"];
    NSError *error;
    XMPPMessage *xmppMessage = [[XMPPMessage alloc] initWithXMLString:message error:&error];
    if (error == nil) {
        if ([[_forwardMessage valueForKey:@"type"] intValue] == 1) { //Text Message
            //Create message body
            XMPPMessage* msg = [self prepareTheMessageStanza:[xmppMessage body] type:1];
            [chatWindow sendMessage:msg mediaURL:@""];
        }
        else if ([chatWindow canSend]) {
            
            //1.Get media type
            int type = [[_forwardMessage valueForKey:@"type"] intValue];
            NSString *message = type == 2 ? @"Image message" : @"Video Message";
            
            //2. Append message in list
            XMPPMessage *msg = [self prepareTheMessageStanza:message type:type];
            
            //3. Upload Media
            [[Util sharedInstance] checkMediaHasValidSize:YES ofMediaUrl:[_forwardMessage valueForKey:@"mediaUrl"] withCallBack:^(NSData * data, UIImage * thumbnail){
                
                if(data != nil){
                    
                    //[self appendTheMediaSize:msg fromData:data];
                    [chatWindow sendMessage:msg mediaURL:[_forwardMessage valueForKey:@"mediaUrl"]];
                    
                    NSMutableDictionary *media = [[NSMutableDictionary alloc]init];
                    [media setObject:thumbnail forKey:@"mediaThumb"];
                    [media setObject:data forKey:@"assetData"];
                    [media setObject:[_forwardMessage valueForKey:@"mediaUrl"] forKey:@"mediaUrl"];
                    
                    if (type == 2) { //Upload image
                        [self uploadImage:media withMessage:msg];
                    }
                    else{
                        //Upload Video
                        [self uploadVideo:media withMessage:msg];
                    }
                }
            }];
        }
    }
}

- (void)createBlockedStateView:(int)status{
    
    [_messageText resignFirstResponder];
    
    //disabled the more icon at top right corner if user
    if(status != 0){
        _isBlocked = TRUE;
        _optionButton.hidden = YES;
    }
    
    //Set message
    NSArray *messages = [[NSArray alloc] initWithObjects:@"",YOU_HAVE_BLOCKED_THIS_USER,YOU_NEED_FRIEND_TO_CHAT,YOU_CAN_NOT_MESSAGE,[NSString stringWithFormat:NSLocalizedString(YOU_NO_LONGER_MEMBER, nil),_receiverName], nil];
    
    //Create block status label
    if (status == 0) {
        blockView = [[UIView alloc] init];
        [blockView setHidden:YES];
        [self.view addSubview:blockView];
    }
    else{
        [blockView setHidden:NO];
        // Remove all subview before addsubview
        [blockView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    }
    
    blockView.backgroundColor = UIColorFromHexCode(THEME_COLOR);
    blockLabel = [[UILabel alloc] init];
    blockLabel.font = [UIFont fontWithName:@"CenturyGothic" size:15];
    blockLabel.numberOfLines = 2;
    blockLabel.textColor = [UIColor whiteColor];
    blockLabel.textAlignment = NSTextAlignmentCenter;
    [blockView addSubview:blockLabel];
    
    blockLabel.hidden = YES;
    
    //Create add friend button
    addFriendButton = [[UIButton alloc] init];
    [addFriendButton setTitle:NSLocalizedString(ADD_FRIEND_BUTTON, nil) forState:UIControlStateNormal];
    [addFriendButton setImage:[UIImage imageNamed:@"adduser.png"] forState:UIControlStateNormal];
    addFriendButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16];
    [addFriendButton addTarget:self action:@selector(showFriendProfile:) forControlEvents:UIControlEventTouchUpInside];
    [blockView addSubview:addFriendButton];
    addFriendButton.hidden = YES;
    if (status != 2 && status != 0) {
        blockLabel.hidden = NO;
    }
    else if (status == 2){
        addFriendButton.hidden = NO;
    }
    
    //Go online button
    goOfflineButton = [[UIButton alloc] init];
    [goOfflineButton setTitle:NSLocalizedString(GO_ONLINE, nil) forState:UIControlStateNormal];
    [goOfflineButton setImage:[UIImage imageNamed:@"chat.png"] forState:UIControlStateNormal];
    goOfflineButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16];
    [goOfflineButton addTarget:self action:@selector(chaneOfflineStatus:) forControlEvents:UIControlEventTouchUpInside];
    [blockView addSubview:goOfflineButton];
    goOfflineButton.hidden = YES;
    
    if (![Util getBoolFromDefaults:@"is_chat_enabled"]) {
        goOfflineButton.hidden = NO;
        addFriendButton.hidden = YES;
        [blockView setHidden:NO];
    }
    
    [blockView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [blockLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addFriendButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [goOfflineButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //Add auto layout constrains for the block
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (blockView,blockLabel,addFriendButton,goOfflineButton);
    
    NSString *verticalConstraint = [NSString stringWithFormat:@"V:[blockView(45)]-0-|"];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:verticalConstraint
                               options:NSLayoutFormatAlignAllBottom metrics:nil
                               views:viewsDictionary]];
    
    NSString *horizontalConstraint = [NSString stringWithFormat:@"H:|-0-[blockView]-0-|"];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:horizontalConstraint
                               options:NSLayoutFormatAlignAllCenterY metrics:nil
                               views:viewsDictionary]];
    
    NSString *finalView = status != 2 ? @"blockLabel" : @"addFriendButton";
    
    verticalConstraint = [NSString stringWithFormat:@"V:|-2-[%@]-2-|",finalView];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:verticalConstraint
                               options:NSLayoutFormatAlignAllBottom metrics:nil
                               views:viewsDictionary]];
    
    horizontalConstraint = [NSString stringWithFormat:@"H:|-10-[%@]-10-|",finalView];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:horizontalConstraint
                               options:NSLayoutFormatAlignAllCenterY metrics:nil
                               views:viewsDictionary]];
    
    verticalConstraint = [NSString stringWithFormat:@"V:|-5-[goOfflineButton]-5-|"];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:verticalConstraint
                               options:NSLayoutFormatAlignAllBottom metrics:nil
                               views:viewsDictionary]];
    
    horizontalConstraint = [NSString stringWithFormat:@"H:|-10-[goOfflineButton]-10-|"];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:horizontalConstraint
                               options:NSLayoutFormatAlignAllCenterY metrics:nil
                               views:viewsDictionary]];
    
    [self.view layoutIfNeeded];
    
    blockLabel.text = NSLocalizedString(messages[status], nil);
    
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    _marginBottom.constant = kbSize.height;
    [self.view layoutIfNeeded];
    [chatView finishSendingMessage];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    _marginBottom.constant = 0;
    _menuBottom.constant = -90;
    [chatView finishSendingMessage];
}

//Action for menu button
- (IBAction)tappedOption:(id)sender {
    if([Util getBoolFromDefaults:@"is_chat_enabled"]){
        [_messageText resignFirstResponder];
        ChatMenu *chatMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatMenu"];
        chatMenu.receiverID = _receiverID;
        chatMenu.receiverName = _receiverName;
        if (![_isSingleChat isEqualToString:@"TRUE"] && ![Util isTeamPresent:_receiverID]) {
            chatMenu.teamRelationID = @"4"; // Nonmemberviewcontroller
            _teamRelationID = @"4";
        }
        [chatMenu setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self.navigationController presentViewController:chatMenu animated:YES completion:NULL];
    }
    else{
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(GO_ONLINE, nil)];
    }
}


//Send message
- (IBAction)sendMessage:(id)sender {
    
    NSLog(@"message content %@",_messageText.text);
    if ([[_messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(CHAT_MESSAGE_EMPTY, nil)];
    }
    else if ([[_messageText.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > POST_CONTENT_MAX)
    {
        [Util showErrorMessage:_messageText withErrorMessage:NSLocalizedString(COMMENTS_EXCEED, nil)];
    }
    else if ([[_messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0 && [chatWindow canSend])
    {
        // Cancel typing request
        hasSentComposing = FALSE;
        
        // Cancel typing request
        hasSentComposing = FALSE;
        
        
        NSString *message = [_messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //Create message body
        XMPPMessage* msg = [self prepareTheMessageStanza:message type:1];
        [chatWindow sendMessage:msg mediaURL:@""];
        
        //Reset the compose view
        _messageText.text = @"";
        _sendButton.hidden = YES;
        _addMediaButton.hidden = NO;
        
        //Update composing message for user
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *messageDict = [[defaults objectForKey:@"composing_message"] mutableCopy];
        [messageDict setObject:@"" forKey:_receiverID];
        [defaults setObject:messageDict forKey:@"composing_message"];
        
        if ([_isSingleChat isEqualToString:@"TRUE"])
        {
            [self getFriendStatus];
        }
        [self hideAndShowSendButton];
        [self changeTextViewHeight:_messageText];
    }
    
    if (![[Util sharedInstance] getNetWorkStatus]) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_INTERNET_CONNECTION, nil)];
    }
}

//Send Media Message
- (void)sendMediaMessage{
    
    if (_medias != nil ) {
        
        for(NSMutableDictionary *media in _medias){
            
            if ([chatWindow canSend]) {
                
                //1.Get media type
                int type = [[media valueForKey:@"mediaType"] boolValue] ? 2 : 3;
                NSString *message = type == 2 ? @"Image message" : @"Video Message";
                
                //2. Append message in list
                XMPPMessage *msg = [self prepareTheMessageStanza:message type:type];
                //[self appendTheMediaSize:msg fromData:[media valueForKey:@"assetData"]];
                [chatWindow sendMessage:msg mediaURL:[media valueForKey:@"mediaUrl"]];
                
                //3. Upload Media
                if (type == 2) { //Upload image
                    [self uploadImage:media withMessage:msg];
                }
                else{
                    //Upload Video
                    [self uploadVideo:media withMessage:msg];
                }
            }
        }
        
        if ([chatWindow canSend])
            [_medias removeAllObjects];
        
        if (![[Util sharedInstance] getNetWorkStatus]) {
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_INTERNET_CONNECTION, nil)];
        }
    }
}


//Append media size
- (void)appendTheMediaSize:(XMPPMessage *)message fromData:(NSData *)data{
    NSXMLElement *userData = [message elementForName:@"userdata"];
    NSString *fileSize = @"";
    float kb = [data length] / 1024;
    fileSize = kb < 1024 ? [NSString stringWithFormat:@"%d KB", (int)kb] : [NSString stringWithFormat:@"%d MB", (int)(kb/1024)];
    [self addChildeNodes:userData withKey:@"filesize" withValue:fileSize];
}

//Upload the image in background
- (void)uploadImage:(NSMutableDictionary *)media withMessage:(XMPPMessage *)msg{
    
    NSString *messageId = [msg attributeStringValueForName:@"id"];
    
    //Uploading messages
    [appDelegate.uploadingMessages addObject:messageId];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:messageId forKey:@"message_id"];
    
    //Image to send
    NSData *assetData = [media valueForKey:@"assetData"];
    
    NSMutableArray *messages = [chatWindow getMessages];
    int index = [Util getMatchedObjectPosition:@"id" valueToMatch:messageId from:messages type:0];
    
    if(index != -1)
    {
        
        //Get message from messages at index
        NSMutableDictionary *messageData = [messages objectAtIndex:index];
        
        NSURLSessionUploadTask *uploadTask = [[Util sharedInstance] sendHTTPPostRequestWithImage:inputParams withRequestUrl:UPLOAD_CHAT_MEDIA withImage:assetData  withFileName:@"image" withCallBack:^(NSDictionary *response)  {
            
            if ( response != nil && [[response valueForKey:@"status"] boolValue]) {
                
                //1.Resize/Crop center image
                UIImage *originalImage = [media objectForKey:@"mediaThumb"];
                UIImage *compressedImage = [Util imageWithImage:originalImage scaledToWidth:originalImage.size.width/8];
                
                //2.Convert image to base64
                NSString *image64 = [Util imageToNSString:compressedImage];
                NSLog(@"Image String %@",image64);
                [msg removeElementForName:@"body"];
                [msg addBody:[NSString stringWithFormat:@"%@%@",IMAGE_KEY,image64]];
                
                //3.Append the document url
                NSXMLElement *userdata = [msg elementForName:@"userdata"];
                [userdata elementForName:@"attachment"] != nil ? [userdata removeElementForName:@"attachment"] : "";
                NSXMLElement *attachment = [NSXMLElement elementWithName:@"attachment" stringValue:[response valueForKey:@"media_path"]];
                [userdata addChild:attachment];
                [self addChildeNodes:userdata withKey:@"filesize" withValue:[response valueForKey:@"media_size"]];
                
                //4.Send message
                XMPPStream *xmppCon = [XMPPServer sharedInstance].xmppStream;
                if ([[Util sharedInstance] getNetWorkStatus] && xmppCon.isAuthenticated && xmppCon.isConnected) {
                    [chatWindow sendMessageToReceipient:msg];
                }
                
                //5.Remove uploading messages array
                [appDelegate.uploadingMessages removeObject:messageId];
                [appDelegate.downloadingMessageTasks removeObjectForKey:messageId];
                
                //6. Update status in database
                [[ChatDBManager sharedInstance] updateMediaUploadStatus:messageId withStatus:0];
            }
            else{
                //Upload cancel due to network issue
                //Retry
                //1. Update status in database
                [[ChatDBManager sharedInstance] updateMediaUploadStatus:messageId withStatus:1];
                
                //2. Remove uploading messages array
                [appDelegate.uploadingMessages removeObject:messageId];
                [appDelegate.downloadingMessageTasks removeObjectForKey:messageId];
                
                //3. Reload the list
                NSMutableArray *messages = [chatWindow getMessages];
                int index = [Util getMatchedObjectPosition:@"id" valueToMatch:messageId from:messages type:0];
                if ([messages count] > index && index != -1) {
                    NSMutableDictionary *message = [messages objectAtIndex:index];
                    [message setValue:[NSNumber numberWithInt:1] forKey:@"is_sent"];
                    [chatWindow.collectionView reloadData];
                }
                
                if (![[Util sharedInstance] getNetWorkStatus]) {
                    [[AlertMessage sharedInstance] showMessage:@"Sending Failed. No Internet Connection"];
                }
            }
            
        } onProgressView:nil withExtension:@"filename.jpg" ofType:@"image/jpeg"];
        
        [appDelegate.downloadingMessageTasks setObject:uploadTask forKey:messageId];
        NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)uploadTask.taskIdentifier];
        [messageData setObject:taskIdentifier forKey:@"task_identifier"];
    }
    
}


//Upload the video in background
- (void)uploadVideo:(NSMutableDictionary *)media withMessage:(XMPPMessage *)msg{
    
    NSString *messageId = [msg attributeStringValueForName:@"id"];
    
    //Uploading messages
    [appDelegate.uploadingMessages addObject:messageId];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:messageId forKey:@"message_id"];
    
    //Set compression start time and filesize before compression
    [inputParams setValue:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"compression_starts"];
    [[Util sharedInstance].assetLibrary assetForURL:[NSURL URLWithString:[media valueForKey:@"mediaUrl"]] resultBlock:^(ALAsset *asset) {
        if (asset != nil) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            long videoSize = (long)rep.size;
            [inputParams setValue:[NSString stringWithFormat:@"%ld",videoSize/1024] forKey:@"actual_size"];
        }
    } failureBlock:^(NSError *error) {
        
    }];
    
    //Get extension
    NSRange range = [[media valueForKey:@"mediaUrl"] rangeOfString:@"&ext="];
    NSString *extension = [[[media valueForKey:@"mediaUrl"]  substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //Get video limit
    NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
    NSNumber *mediaSize = [config objectForKey:@"default_video_size"];
    
    //Compress the video
    [[Util sharedInstance] compressVideo:[media valueForKey:@"mediaUrl"] isCaptured:NO toPass:^(NSData * assetData, UIImage * thumbnail) {
        
        if (assetData != nil) {
            
            //Set compression end time and compressed size
            [inputParams setValue:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"compression_ends"];
            [inputParams setValue:[NSString stringWithFormat:@"%u",assetData.length/1024] forKey:@"compressed_size"];
            
            //Upload the video
            //Get current cell object
            NSMutableArray *messages = [chatWindow getMessages];
            int index = [Util getMatchedObjectPosition:@"id" valueToMatch:messageId from:messages type:0];
            
            if(index != -1)
            {
                //Get message from messages at index
                NSMutableDictionary *messageData = [messages objectAtIndex:index];
                
                NSURLSessionUploadTask *uploadTask = [[Util sharedInstance] sendHTTPPostRequestWithImage:inputParams withRequestUrl:UPLOAD_CHAT_MEDIA withImage:assetData  withFileName:@"video" withCallBack:^(NSDictionary *response)  {
                    
                    if ( response != nil && [[response valueForKey:@"status"] boolValue]) {
                        
                        //1.Resize/Crop center image
                        UIImage *originalImage = [media objectForKey:@"mediaThumb"];
                        UIImage *compressedImage = [Util imageWithImage:originalImage scaledToWidth:originalImage.size.width/8];
                        
                        //2.Convert image to base64
                        NSString *image64 = [Util imageToNSString:compressedImage];
                        NSLog(@"Image String %@",image64);
                        [msg removeElementForName:@"body"];
                        [msg addBody:[NSString stringWithFormat:@"%@%@",VIDEO_KEY,image64]];
                        
                        //3.Append the document url
                        NSXMLElement *userdata = [msg elementForName:@"userdata"];
                        [userdata elementForName:@"attachment"] != nil ? [userdata removeElementForName:@"attachment"] : "";
                        NSXMLElement *attachment = [NSXMLElement elementWithName:@"attachment" stringValue:[response valueForKey:@"media_path"]];
                        [userdata addChild:attachment];
                        
                        [self addChildeNodes:userdata withKey:@"filesize" withValue:[response valueForKey:@"media_size"]];
                        
                        //Remove the old file size and add new one
                        //[userdata elementForName:@"filesize"] != nil ? [userdata removeElementForName:@"filesize"] : "";
                        //[self appendTheMediaSize:msg fromData:assetData];
                        
                        //4.Send message
                        XMPPStream *xmppCon = [XMPPServer sharedInstance].xmppStream;
                        if ([[Util sharedInstance] getNetWorkStatus] && xmppCon.isAuthenticated && xmppCon.isConnected) {
                            [chatWindow sendMessageToReceipient:msg];
                        }
                        
                        //5.Remove uploading messages array
                        [appDelegate.uploadingMessages removeObject:messageId];
                        [appDelegate.downloadingMessageTasks removeObjectForKey:messageId];
                        
                        //6. Update status in database
                        [[ChatDBManager sharedInstance] updateMediaUploadStatus:messageId withStatus:0];
                        
                    }
                    else{
                        //Upload cancel due to network issue
                        //Retry
                        //1. Update status in database
                        [[ChatDBManager sharedInstance] updateMediaUploadStatus:messageId withStatus:1];
                        
                        //2. Remove uploading messages array
                        [appDelegate.uploadingMessages removeObject:messageId];
                        [appDelegate.downloadingMessageTasks removeObjectForKey:messageId];
                        
                        //3. Reload the list
                        NSMutableArray *messages = [chatWindow getMessages];
                        int index = [Util getMatchedObjectPosition:@"id" valueToMatch:messageId from:messages type:0];
                        
                        
                        if ([messages count] > index && index != -1) {
                            NSMutableDictionary *message = [messages objectAtIndex:index];
                            [message setValue:[NSNumber numberWithInt:1] forKey:@"is_sent"];
                            [chatWindow.collectionView reloadData];
                        }
                        
                        if (![[Util sharedInstance] getNetWorkStatus]) {
                            [[AlertMessage sharedInstance] showMessage:@"Sending Failed. No Internet Connection"];
                        }
                    }
                    
                } onProgressView:nil withExtension:[NSString stringWithFormat:@"videoFile.%@",extension] ofType:@"video/quicktime"];
                
                //upadte the message with task indentifier in task_indentifier
                //uploadTask.taskIdentifier;
                [appDelegate.downloadingMessageTasks setObject:uploadTask forKey:messageId];
                NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)uploadTask.taskIdentifier];
                [messageData setObject:taskIdentifier forKey:@"task_identifier"];
            }
        }
        else{
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(DELETED_MEDIA, nil)];
        }
        
    } withSize:mediaSize withImage:nil];
}

//Prepare the message stanza
- (XMPPMessage *)prepareTheMessageStanza:(NSString *)messageToSend type:(int)messageType{
    
    //Create message body
    XMPPMessage* msg ;
    if ([_isSingleChat isEqualToString:@"TRUE"])
    {
        msg = [[XMPPMessage alloc] initWithType:@"chat" to:receiverJID];
    }
    else
    {
        msg = [[XMPPMessage alloc] initWithType:@"groupchat" to:receiverJID];
    }
    [msg addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
    [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"]];
    [msg addBody:messageToSend];
    [msg addActiveChatState];
    [msg addReceiptRequest];
    [self appendUserInformation:msg type:messageType];
    return msg;
}

//Append User information Stanzas
- (void) appendUserInformation:(XMPPMessage *)message type:(int)messageType{
    
    NSXMLElement *userData = [NSXMLElement elementWithName:@"userdata" xmlns:@"com:user:data"];
    [self addChildeNodes:userData withKey:@"receiverName" withValue:_receiverName];
    [self addChildeNodes:userData withKey:@"receiverImage" withValue:_receiverImage];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self addChildeNodes:userData withKey:@"senderName" withValue:[defaults valueForKey:@"user_name"]];
    [self addChildeNodes:userData withKey:@"senderImage" withValue:[defaults valueForKey:@"player_image"]];
    [self addChildeNodes:userData withKey:@"messageType" withValue:[NSString stringWithFormat:@"%d",messageType]];
    [self addChildeNodes:userData withKey:@"id" withValue:[message attributeStringValueForName:@"id"]];
    [self addChildeNodes:userData withKey:@"to" withValue:[message attributeStringValueForName:@"to"]];
    [self addChildeNodes:userData withKey:@"from" withValue:[message attributeStringValueForName:@"from"]];
    [self addChildeNodes:userData withKey:@"type" withValue:[message attributeStringValueForName:@"type"]];
    
    [message addChild:userData];
}

- (void)addChildeNodes:(NSXMLElement *)parent withKey:(NSString *)key withValue:(NSString *)value{
    NSXMLElement *child = [NSXMLElement elementWithName:key stringValue:value];
    [parent addChild:child];
}

//Send Typing... ack to user
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    [self hideAndShowSendButton];
    [self changeTextViewHeight:textView];
    
    //Send composing message
    if (!hasSentComposing) {
        hasSentComposing = TRUE;
        [self sendComposingState];
        [self performSelector:@selector(resetComposingState) withObject:nil afterDelay:1.0];
    }
    
    NSString *trimmedText = [_messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedText length] == 0) {
        [self sendPauseState];
    }
    
    return YES;
}

//Update composing message for user
-(void)updateComposingMessageForUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *messageDict;
    if ([defaults objectForKey:@"composing_message"] != nil) {
        messageDict = [[defaults objectForKey:@"composing_message"] mutableCopy];
    }
    else
        messageDict = [[NSMutableDictionary alloc] init];
    NSLog(@"Message %@",_messageText.text);
    [messageDict setObject:_messageText.text forKey:_receiverID];
    [defaults setObject:messageDict forKey:@"composing_message"];
}

-(void)textViewDidChange:(UITextView *)textView{
    [self hideAndShowSendButton];
    [self changeTextViewHeight:textView];
    
    //Update composing message for user
    [self updateComposingMessageForUser];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    [self hideAndShowSendButton];
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    
    [self hideAndShowSendButton];
}

-(void)hideAndShowSendButton{
    NSString *trimmedText = [_messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange range = [_messageText.text rangeOfString: @"\uFFFC"];
    if ([trimmedText length] != 0 && ![trimmedText isEqualToString:@""] && range.location == NSNotFound) {
        [_addMediaButton setHidden:YES];
        [_sendButton setHidden:NO];
        [_cameraButton setHidden:YES];
    }
    else
    {
        [_addMediaButton setHidden:NO];
        [_sendButton setHidden:YES];
        [_cameraButton setHidden:NO];
    }
}

-(void)changeTextViewHeight:(UITextView *)textView{
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    
    if(newSize.height < 150)
    {
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        textView.frame = newFrame;
        
        _composeViewHeight.constant = newSize.height+17;
        [_composeView setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), 150);
        _composeViewHeight.constant = 150+17;
        [_composeView setBackgroundColor:[UIColor whiteColor]];
        [self.view layoutIfNeeded];
    }
}
- (void)sendPauseState{
    
    //Create message body
    XMPPMessage* msg = [[XMPPMessage alloc] initWithType:@"chat" to:receiverJID];
    [msg addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
    [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"]];
    NSXMLElement *noStore = [NSXMLElement elementWithName:@"no-store" xmlns:@"urn:xmpp:hints"];
    [msg addChild:noStore];
    [msg addPausedChatState];
    [chatWindow sendMessageToReceipient:msg];
}

- (void)sendComposingState{
    
    //Create message body
    XMPPMessage* msg = [[XMPPMessage alloc] initWithType:@"chat" to:receiverJID];
    
    [msg addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
    [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"]];
    if (![_isSingleChat isEqualToString:@"TRUE"]) {
        msg = [[XMPPMessage alloc] initWithType:@"groupchat" to:receiverJID];
        [msg addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
        [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"myJID"]];
        [self appendUserInformation:msg type:1];
    }
    NSXMLElement *noStore = [NSXMLElement elementWithName:@"no-store" xmlns:@"urn:xmpp:hints"];
    [msg addChild:noStore];
    [msg addComposingChatState];
    
    if ([chatWindow canSend]) {
        [chatWindow sendMessageToReceipient:msg];
    }
}

//Reset composing state

-(void)resetComposingState
{
    hasSentComposing = FALSE;
}


//Get Friends Status
- (void)getFriendStatus{
    if ([_isSingleChat isEqualToString:@"TRUE"]) {
        //Get last seen (if seconds is 0 he/she is online)
        [[[XMPPServer sharedInstance] xmppLastActivity] sendLastActivityQueryToJID:receiverJID];
    }
}

//Send buddy request
- (void)sendContactRequest{
    [[[XMPPServer sharedInstance] xmppRoster] addUser:receiverJID withNickname:[_receiverID componentsSeparatedByString:@"@"][0]];
}


///////// Handle the stanzas received from server //////////////

//Register for the Notification
- (void) registerForNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLastStatus:) name:XMPPRECEIVEDLASTSEEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePresenceState:) name:XMPPRECIEVEPRESENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processIncomeMessage:) name:XMPPONMESSAGERECIEVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDisconnect) name:XMPPDISCONNECTFROMSERVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionEstablished) name:XMPPCONNECTIONSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(designTheViewBasedOnUserPriavacyStatus) name:XMPPRECEIVEDBLOCKEDLIST object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageReload:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

// Page reload when application will enter foreground
- (void)pageReload:(NSNotification *) data{
    [chatWindow.collectionView reloadData];
}

- (void)unregisterNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XMPPRECEIVEDBLOCKEDLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

//To process the type of the notification
- (void) processIncomeMessage:(NSNotification *) data{
    
    NSMutableDictionary *receivedMessage = [data.userInfo mutableCopy];
    XMPPMessage *message = [receivedMessage valueForKey:@"message"];
    
    //1.Check message type
    
    if ([[message attributeStringValueForName:@"type"] isEqualToString:@"chat"]) {
        
        //Check message for current conversation
        NSArray *from = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
        if ([[from objectAtIndex:0] isEqualToString:_receiverID]) {
            
            //Check is composing
            if ([message elementForName:@"composing"] != nil && [message elementForName:@"delay"] == nil) {
                
                [self changeStatus:TYPING];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTyping) object:nil];
                [self performSelector:@selector(hideTyping) withObject:nil afterDelay:2.0];
            }
        }
    }
    else  if ([[message attributeStringValueForName:@"type"] isEqualToString:@"groupchat"]) {
        //Check is composing
        if ([message elementForName:@"composing"] != nil && [message elementForName:@"delay"] == nil) {
            
            //Check message for current conversation
            NSArray *from = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
            NSString *senderJabberID = from[0];
            NSXMLElement *userData = [message elementForName:@"userdata"];
            NSXMLElement *fromElement = [userData elementForName:@"from"];
            NSString *fromID = [fromElement stringValue];
            NSString *myJID = [[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"];
            if (![fromID isEqualToString:myJID] && [senderJabberID isEqualToString:_receiverID]) {
                //[self changeStatus:[NSString stringWithFormat:NSLocalizedString(USER_TYPING, nil), senderName]];
                [self changeStatus:TYPING];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTyping) object:nil];
                [self performSelector:@selector(hideTyping) withObject:nil afterDelay:2.0];
            }
        }
        else if([message elementForName:@"teamstatus"] != nil)
        {
            if ([self teamRemovedFromCaptain:message]) {
                //[self createBlockedStateView:4];
                [appDelegate refreshNotification];
            }
        }
    }
}

-(BOOL)teamRemovedFromCaptain:(XMPPMessage *)message
{
    NSXMLElement *teamstatus = [message elementForName:@"teamstatus"];
    NSString *type = [[teamstatus elementForName:@"type"] stringValue];
    
    if ([type intValue] == 1) {
        return TRUE;
    }
    
    return FALSE;
}

//Hide the type indicator
-(void)hideTyping
{
    [typingIndicator setHidden:YES];
    if ([_isSingleChat isEqualToString:@"TRUE"]) {
        [self changeStatus:ONLINE];
    }
    else
    {
        [self changeStatus:SEE_PROFILE_INFO];
    }
}

//Update the player status
- (void) updateLastStatus:(NSNotification *) data{
    
    NSMutableDictionary *receivedMessage = [data.userInfo mutableCopy];
    XMPPIQ *message = [receivedMessage valueForKey:@"message"];
    
    //Check status for current user
    NSArray *from = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
    if ([[from objectAtIndex:0] isEqualToString:_receiverID] && ![[message attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
        long timestamp = [message lastActivitySeconds];
        //long currentTime = [[NSDate date] timeIntervalSince1970];
        if (timestamp == 0) { //Online
            
            if ([_isSingleChat isEqualToString:@"TRUE"]) {
                [self changeStatus:ONLINE];
                [[ChatDBManager sharedInstance] sendSeenACKToMessages:_receiverID];
                
                if ([[[XMPPServer sharedInstance] onlineUsers] indexOfObject:_receiverID] == NSNotFound) {
                    [[XMPPServer sharedInstance] .onlineUsers addObject:_receiverID];
                }
            }
        }
        else{
            if ([_isSingleChat isEqualToString:@"TRUE"]) {
                
                // UPdate Offline Status
                [[XMPPServer sharedInstance] .onlineUsers removeObject:_receiverID];
                //[self changeStatus:[NSString stringWithFormat:NSLocalizedString(LAST_SEEN_TIME, nil),[Util timeStamp: (currentTime - timestamp)]]];
            }
        }
    }
}


//Update the player status
- (void) updatePresenceState:(NSNotification *) data{
    
    NSMutableDictionary *receivedMessage = [data.userInfo mutableCopy];
    XMPPPresence *presence = [receivedMessage valueForKey:@"message"];
    NSString *myJID = [Util getFromDefaults:@"myJID"];
    NSString *senderJID = [presence attributeStringValueForName:@"from"];
    senderJID = [senderJID componentsSeparatedByString:@"/"][0];
    NSString *presenceState = [presence type];
    if ([presenceState isEqualToString:@"available"] && [presence elementForName:@"delay"] == nil && ![senderJID isEqualToString:myJID]) {
        if ([_isSingleChat isEqualToString:@"TRUE"]) {
            [self changeStatus:ONLINE];
            [[ChatDBManager sharedInstance] sendSeenACKToMessages:_receiverID];
        }
        // Update Online Status
        if ([[[XMPPServer sharedInstance] onlineUsers] indexOfObject:_receiverID] == NSNotFound) {
            [[XMPPServer sharedInstance] .onlineUsers addObject:_receiverID];
        }
    }
    else{
        long currentTime = [[NSDate date] timeIntervalSince1970];
        if ([_isSingleChat isEqualToString:@"TRUE"]) {
            [self changeStatus:[NSString stringWithFormat:NSLocalizedString(LAST_SEEN_TIME, nil),[Util timeStamp:currentTime]]];
            // Update Offline Status
            [[XMPPServer sharedInstance] .onlineUsers removeObject:_receiverID];
        }
    }
}

-(void)connectionDisconnect{
    //_sendButton.enabled = FALSE;
    [self changeStatus:CONNECTING];
    
    if (![[Util sharedInstance] getNetWorkStatus]) {
        [self changeStatus:WAITING_FOR_NETWORK];
    }
}

-(void)connectionEstablished
{
    //_sendButton.enabled = TRUE;
    if ([_isSingleChat isEqualToString:@"TRUE"]) {
        [self changeStatus:SEE_PROFILE_INFO];
        [self getFriendStatus];
    }
    else{
        [self changeStatus:SEE_PROFILE_INFO];
    }
}

///////// Handle the stanzas received from server ends //////////////



/////// DB Related functions ///////////

//Get history from local DB
- (void)getChatHistoryFromLocal{
    
    NSString *query;
    if ([_isSingleChat isEqualToString:@"TRUE"]) {
        query = [[ChatDBManager sharedInstance] getChatHistoryQuery:[[NSUserDefaults standardUserDefaults] valueForKey:@"myJID"] receiver:_receiverID];
    }
    else {
        query = [[ChatDBManager sharedInstance] getTeamChatHistoryQuery:_receiverID];
    }
    
    NSMutableArray *chats = [[DBManager sharedInstance] findRecord:query];
    [self loadHistoryIntoChatList:chats];
}

//Load messages in view
- (void)loadHistoryIntoChatList:(NSMutableArray *)chats{
    for (NSMutableDictionary *message in chats) {
        
        NSString *messageContent = [message objectForKey:@"message"];
        XMPPMessage *xmppMessage = [[XMPPMessage alloc] initWithXMLString:messageContent error:nil];
        if ([[message valueForKey:@"type"] intValue] == 1) {
            [chatWindow addTextMessage:xmppMessage isOutgoing:[[message valueForKey:@"is_outgoing"] boolValue] withStatus:[[message valueForKey:@"status"] intValue] withTime:[[message valueForKey:@"time"] longLongValue]];
        }
        else if ([[message valueForKey:@"type"] intValue] == 2) {
            [chatWindow addPhotoMediaMessage:xmppMessage isOutgoing:[[message valueForKey:@"is_outgoing"] boolValue] withStatus:[[message valueForKey:@"status"] intValue] withTime:[[message valueForKey:@"time"] longLongValue]];
        }
        else if ([[message valueForKey:@"type"] intValue] == 3) {
            [chatWindow addVideoMediaMessage:xmppMessage isOutgoing:[[message valueForKey:@"is_outgoing"] boolValue] withStatus:[[message valueForKey:@"status"] intValue] withTime:[[message valueForKey:@"time"] longLongValue]];
        }
    }
}

//Reset the unread count to 0
- (void)resetUnreadCount{
    [[ChatDBManager sharedInstance] resetUnreadCount:_receiverID];
}
/////// DB Related functions ends ///////////


// Type 1 -> If Captain or CoCaptain remove the members from team
// Type 2 -> If a new member join in the team
// Type 3 -> If a captain remove the Cocaptain
// Type 4 -> If a captain set the Cocaptain
// Type 5 -> Member left from team
// Type 6 -> Captain left team
-(void)sendMessageIfUserLeft :(NSString *)roomName name1:(NSString *)name1 name2:(NSString *)name2 type:(NSString *)type
{
    int index = [Util getMatchedObjectPosition:@"roomJID" valueToMatch:roomName from:[XMPPServer sharedInstance].roomArray type:0];
    if (index != -1)
    {
        _isSingleChat = @"FALSE";
        NSLog(@"ROOM Array %@", [XMPPServer sharedInstance].roomArray);
        NSMutableDictionary *teamDict = [[XMPPServer sharedInstance].roomArray objectAtIndex:index];
        NSLog(@"Room %@", [teamDict objectForKey:@"xmppRoom"]);
        [XMPPServer sharedInstance].xmppRoom = [teamDict objectForKey:@"xmppRoom"];
        
        receiverJID = [XMPPJID jidWithString:_receiverID];
        XMPPMessage* msg = [self prepareTheMessageStanza:@"leave or join room" type:1];
        
        NSXMLElement *teamStatus = [NSXMLElement elementWithName:@"teamstatus" xmlns:@"com:user:teamdata"];
        [self addChildeNodes:teamStatus withKey:@"name1" withValue:name1];
        [self addChildeNodes:teamStatus withKey:@"name2" withValue:name2];
        [self addChildeNodes:teamStatus withKey:@"type" withValue:type];
        [msg addChild:teamStatus];
        
        //   [[XMPPServer sharedInstance].xmppRoom sendMessage:msg];
        
        // Leve From Room After Leave from team
        if ([type intValue] == 5) {
            //      [[XMPPServer sharedInstance] leaveRoomFromMe:roomName];
        }
        
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [titleArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width/2.2 , 80);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"optionCell" forIndexPath:indexPath];
    if(cell==nil)
        cell=[[[NSBundle mainBundle] loadNibNamed:@"optionCell" owner:self options:nil] objectAtIndex:0];
    
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *imag = (UIImageView *)[cell viewWithTag:10];
    UILabel *label = (UILabel *)[cell viewWithTag:11];
    
    UIImage *optionImage = [[UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    imag.image = optionImage;
    label.text = [titleArray objectAtIndex:indexPath.row];
    
    [imag setTintColor:[UIColor lightGrayColor]];
    [label setTextColor:[UIColor lightGrayColor]];
    
    return  cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *imag = (UIImageView *)[cell viewWithTag:10];
    UILabel *label = (UILabel *)[cell viewWithTag:11];
    
    UIImage *optionImage = [[UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imag.image = optionImage;
    [imag setTintColor:[UIColor redColor]];
    [label setTextColor:[UIColor redColor]];
    
    //    if (indexPath.row == 2)
    //    {
    //            MediaGallery *media = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaGallery"];
    //            media.receiverID = _receiverID;
    //            media.receiverName = _receiverName;
    //            media.receiverImage = _receiverImage;
    //            media.isSingleChat = _isSingleChat;
    //            [self.navigationController pushViewController:media animated:YES];
    //    }
    if(indexPath.row != 4)
    {
        if (!_isBlocked) {
            MediaComposing *photo = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaComposing"];
            photo.type = indexPath.row;
            UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
            [navigation pushViewController:photo animated:YES];
        }
        else
        {
            [imag setTintColor:[UIColor grayColor]];
            [label setTextColor:[UIColor grayColor]];
        }
    }
    else if(indexPath.row == 4)
    {
        if ([_isSingleChat isEqualToString:@"TRUE"]) {
            [self showFriendProfile:nil];
        }
        else
        {
            // Nonmemberview Controller
            if ([_teamRelationID isEqualToString:@"4"]) {
                
                NonMemberTeamViewController *nonMember = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
                
                NSArray *teamIds = [_receiverID componentsSeparatedByString:@"_"];
                if ([teamIds count] > 0) {
                    NSString *teamId = teamIds[0];
                    nonMember.teamId = teamId;
                    [self.navigationController pushViewController:nonMember animated:YES];
                }
            }
            else
            {
                TeamViewController *teamDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
                NSArray *teamIds = [_receiverID componentsSeparatedByString:@"_"];
                if ([teamIds count] > 0) {
                    NSString *teamId = teamIds[0];
                    teamDetails.teamId = teamId;
                    teamDetails.roomId = _receiverID;
                    [self.navigationController pushViewController:teamDetails animated:YES];
                }
            }
        }
    }
}


// Emoji Delegate

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    
    if ([self.messageText.text length] < 1000 && [self.messageText.text length] != 999) {
        // self.messageText.text = [self.messageText.text stringByAppendingString:emoji];
        [self.messageText replaceRange:self.messageText.selectedTextRange withText:emoji];
        
        // Send Composing for show typing
        [self sendComposingState];
        [self performSelector:@selector(resetComposingState) withObject:nil afterDelay:1.0];
    }
    [self hideAndShowSendButton];
    [self changeTextViewHeight:_messageText];
}

// Clear text from Emoji keyboard
- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.messageText deleteBackward];
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    CGSize size = CGSizeMake(30, 10);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGFloat xxx = 3;
    rect = CGRectMake(xxx, xxx, size.width - 2 * xxx, size.height - 2 * xxx);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}


@end
