//
//  BuzzardRunComments.m
//  Varial
//
//  Created by vis-1041 on 4/24/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BuzzardRunComments.h"
#import "UIImageView+AFNetworking.h"
#import "IQKeyboardManager.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "Config.h"

@interface BuzzardRunComments ()

@end

@implementation BuzzardRunComments

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    commentsList = [[NSMutableArray alloc] init];
    localComments = [[NSMutableArray alloc] init];
    currentSelection = menuIndex = -1;
    flag = isPostExpired = isManual = false ;
    _message.delegate = self;
    isShowBottom = TRUE;
    [self createPopUpWindows];
    [self designTheView];
    [self getCommentsOldList];
    [self setPushToRefreshForTableView];
    
    UIMenuItem* deleteMenu = [[UIMenuItem alloc] initWithTitle: @"Delete" action:@selector(deleteComment:)];
    UIMenuController* mc = [UIMenuController sharedMenuController];
    mc.menuItems = [NSArray arrayWithObjects: deleteMenu,nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askBackConfirm:) name:@"BackPressed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRecentComments:) name:@"GeneralNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetMenuIndex:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    isEmojiKeyboard = FALSE;
    // Emoji keyboard
    emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
    emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    emojiKeyboardView.delegate = self;

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

-(void)viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"BackPressed"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"GeneralNotification"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIMenuControllerDidHideMenuNotification ];
}

//Get latest comments
-(void) getRecentComments:(NSNotification *) data{
    
    if (!isPostExpired) {
        
        if ([commentsList count] == 0) {
            [self getCommentsOldList];
        }
        else{
            
            NSString *commentId = @"0";
            for (int i = (int)[commentsList count]-1; i>=0; i--) {
                NSMutableDictionary *comment = [commentsList objectAtIndex:i];
                if (![[comment valueForKey:@"is_local"] boolValue]) {
                    commentId = [comment valueForKey:@"comment_id"];
                    break;
                }
            }
            
            //Build Input Parameters
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            [inputParams setValue:@"true" forKey:@"recent"];
            [inputParams setValue:_postId  forKey:@"post_id"];
            [inputParams setValue:commentId  forKey:@"comment_id"];
            
            NSString *url = BUZZARD_RUN_COMMENTS_LIST_POST ;  // COMMENT_LIST_FOR_POST;
            
            if (_mediaId != nil) {
                [inputParams setValue:_mediaId  forKey:@"media_id"];
                url = BUZZARD_RUN_COMMENTS_LIST_MEDIA ;   //COMMENT_LIST_FOR_MEDIA;
            }
            
            [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
                if([[response valueForKey:@"status"] boolValue]){
                    mediaBase = [response valueForKey:@"media_base_url"];
                    if (_mediaId != nil) {
                        [self createCommentsList:[[response objectForKey:@"feed_comment_list_media"] mutableCopy] isBottom:FALSE];
                    }
                    else{
                        [self createCommentsList:[[response objectForKey:@"feed_list"] mutableCopy] isBottom:FALSE];
                    }
                }
                else
                {
                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                }
            } isShowLoader:NO];
        }
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    //Image zoom on click
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Check for name and image update
    BOOL isNameChanged = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isNameChanged"] boolValue];
    BOOL isImageChanged = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isImageChanged"] boolValue];
    if ((isNameChanged || isImageChanged) && isNeedUpdate) {
        [commentsList removeAllObjects];
        [localComments removeAllObjects];
        [self getCommentsOldList];
    }
}

//Check posting is going on
-(void) askBackConfirm:(NSNotification *) data{
    if ([[[Util sharedInstance].httpFileTaskManager uploadTasks] count] > 0) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(COMMENT_STILL_POSTING, nil)];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//Reset comment index
-(void) resetMenuIndex:(NSNotification *) data{
    if (!isManual) {
        menuIndex = -1;
    }
}

-(void)designTheView
{
    [_headerView setHeader:NSLocalizedString(COMMENTS, nil)];

    [_headerView.logo setHidden:YES];
   // _headerView.restrictBack = TRUE;
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.tableFooterView = footerView;
    
    _message.placeholder = NSLocalizedString(WRITE_COMMENT, nil);
    _message.autocorrectionType = UITextAutocorrectionTypeNo;
    _backImage.clipsToBounds = YES;
    
    name = [Util getFromDefaults:@"user_name"];
    profileImage = [Util getFromDefaults:@"player_image"];
    
    if (_canNotComment != nil) {
        [_composeView hideByHeight:YES];
    }
    [self.message  setTextContainerInset:UIEdgeInsetsMake(10,40, 0, 0)];
    [_message becomeFirstResponder];

}

- (void) createPopUpWindows{
    
    mediaPopupView = [[MediaPopup alloc] init];
    mediaPopupView.delegate = self;
    KLCMediaPopup = [KLCPopup popupWithContentView:mediaPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(COMMENTS, nil)];
    popupView.message.text = NSLocalizedString(DELETE_COMMENT, nil);
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
}


//Add push scroll
- (void) setPushToRefreshForTableView;
{
    __weak BuzzardRunComments *weakSelf = self;
    // setup pull-to-refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    weakSelf.tableView.pullToRefreshView.arrowColor = [UIColor whiteColor];
    weakSelf.tableView.pullToRefreshView.textColor = [UIColor whiteColor];
    [weakSelf.tableView.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    
}

- (void)insertRowAtTop {
    __weak BuzzardRunComments *weakSelf = self;
    int64_t delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        isShowBottom = FALSE;
        if ([commentsList count] > 1) {
            [self getCommentsOldList];
        }        
    });
    [weakSelf.tableView.pullToRefreshView stopAnimating];
}

-(IBAction)Camera:(id)sender
{
    [_message resignFirstResponder];
    if (!isPostExpired) {
        [self createPopUpWindows];
        [KLCMediaPopup show];
    }
}

-(IBAction)SendComments:(id)sender
{
    if ([self inputValidation] && !isPostExpired)
    {
        [self createTheLocalComment];
        [_message resignFirstResponder];
    }
}

//Create the local comment
- (void)createTheLocalComment{
    
    // Remove the multiple white spaces between two words
    NSString *message = [_message.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSCharacterSet *nonAsciiCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:message] invertedSet];
//    message = [[message componentsSeparatedByCharactersInSet:nonAsciiCharacterSet] componentsJoinedByString:@""];
    
    NSMutableDictionary *comment = [[NSMutableDictionary alloc] init];
    [comment setValue:@"" forKey:@"comment_id"];
    [comment setValue:[NSNumber numberWithBool:YES] forKey:@"isExpanded"];
    [comment setValue:[NSNumber numberWithBool:TRUE] forKey:@"is_local"];
    [comment setValue:name forKey:@"comment_owner_name"];
    [comment setValue:message forKey:@"comment"];
    [comment setValue:[self ContinueReading_LocalComment:message] forKey:@"continue_reading"];
    [comment setValue:[NSNumber numberWithInt:1] forKey:@"comment_owner_id"];
    [comment setValue:[NSNumber numberWithBool:TRUE] forKey:@"am_owner"];
    [comment setValue:@"" forKey:@"full_image_url"];
    [comment setValue:@"" forKey:@"image_thumb_url"];
    [comment setValue:profileImage forKey:@"profile_image"];
    
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    [comment setValue:timestamp forKey:@"time_stamp"];
    [comment setValue:pickedImage forKey:@"image"];
    
    if (pickedImage != nil) {
        [comment setValue:[NSNumber numberWithInt:2] forKey:@"media_type"];
    }
    else{
        [comment setValue:[NSNumber numberWithInt:1] forKey:@"media_type"];
    }
    
    NSString *randomNumber = [Util randomStringWithLength:10];
    [comment setValue:randomNumber forKey:@"commentNo"];
    
    //Add comment to the list
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[commentsList count] inSection:0];
    [self insertCommentWithAnimation:comment onThisIndexPath:indexPath];
    
    //Move to bottom
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[commentsList count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self createComment:randomNumber];
}

-(NSNumber *)ContinueReading_LocalComment :(NSString *)message
{
    if([message length] > 256)
    {
        return [NSNumber numberWithInt:1];
    }
    return [NSNumber numberWithInt:0];
}


//Add row at specific position of table view
-(void) insertCommentWithAnimation :(NSMutableDictionary *) comment onThisIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    [commentsList insertObject:comment atIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

//validate comment input
-(BOOL)inputValidation
{
    // Validation Password continue empty spaces
    if ([[_message.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        return FALSE;
    }
    if ([[_message.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 1000)
    {
        [Util showErrorMessage:_message withErrorMessage:NSLocalizedString(COMMENTS_EXCEED, nil)];
        return FALSE;
    }
    
    //For voice input
    NSRange range = [_message.text rangeOfString: @"\uFFFC"];
    if (range.location != NSNotFound) {
        return false;
    }
    
    return TRUE;
}


//Get comments old list
-(void)getCommentsOldList
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"false" forKey:@"recent"];
    [inputParams setValue:_postId  forKey:@"post_id"];
    
    if ([commentsList count] > 0) {
        NSMutableDictionary *comment = [commentsList firstObject];
        [inputParams setValue:[comment valueForKey:@"comment_id"]  forKey:@"comment_id"];
        [inputParams setValue:[comment valueForKey:@"time_stamp"]  forKey:@"time_stamp"];
    }else{
        [inputParams setValue:@""  forKey:@"comment_id"];
        [inputParams setValue:@"0"  forKey:@"time_stamp"];
    }
    
    NSString *url = BUZZARD_RUN_COMMENTS_LIST_POST ;  // COMMENT_LIST_FOR_POST;
    
    if (_mediaId != nil) {
        [inputParams setValue:_mediaId  forKey:@"media_id"];
        url = BUZZARD_RUN_COMMENTS_LIST_MEDIA ;   // COMMENT_LIST_FOR_MEDIA;
    }
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            mediaBase = [response valueForKey:@"media_base_url"];
            if (_mediaId != nil) {
                [self createCommentsList:[[response objectForKey:@"comment_list"] mutableCopy] isBottom:TRUE];
            }
            else{
                [self createCommentsList:[[response objectForKey:@"comment_list"] mutableCopy] isBottom:TRUE];
            }
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"] withDuration:2];
            _message.editable = FALSE;
            [Util addEmptyMessageToTable:self.tableView withMessage:[response objectForKey:@"message"] withColor:[UIColor whiteColor]];
            [_composeView setHidden:YES];
            isPostExpired = [[response valueForKey:@"action_expired"] boolValue];
        }
    } isShowLoader:NO];
}

//Create comment list in ascending order
-(void)createCommentsList:(NSMutableArray *)list isBottom:(BOOL)isBottom{
    
    for (int i = 0 ; i < [list count]; i++){
        
        NSMutableDictionary *comment = [[list objectAtIndex:i] mutableCopy];
        NSString *serverCommentId = [comment valueForKey:@"comment_id"];
        if ([localComments indexOfObject:serverCommentId] == NSNotFound ) {
            
            [comment setValue:[NSNumber numberWithBool:NO] forKey:@"isExpanded"];
            [comment setValue:[NSNumber numberWithBool:FALSE] forKey:@"is_local"];
            [comment setValue:@"" forKey:@"commentNo"];
            
            NSString *timeStamp = [NSString stringWithFormat:@"%ld",[[comment valueForKey:@"time_zone"] longValue]];
            [comment setValue:timeStamp forKey:@"time_zone"];
            
            //Merge the media url
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[comment valueForKey:@"full_image_url"]];
            [comment setValue:imageUrl forKey:@"full_image_url"];
            
            NSString *imageThumbUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[comment valueForKey:@"image_thumb_url"]];
            [comment setValue:imageThumbUrl forKey:@"image_thumb_url"];
            
            NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[comment valueForKey:@"comment_owner_image"]];
            [comment setValue:profileUrl forKey:@"profile_image"];
            
            if (isBottom) {
                [commentsList insertObject:comment atIndex:0];
            }
            else{
                [commentsList addObject:comment];
            }
            NSString *commentId = [comment valueForKey:@"comment_id"];
            [localComments addObject:commentId];
        }
    }
    [_tableView reloadData];
    [self addEmptyMessageForCommentsTable];
    
    //Move to bottom
    if ([commentsList count]>0 && isShowBottom) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[commentsList count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

//Add empty message in table background view
- (void)addEmptyMessageForCommentsTable{
    
    if ([commentsList count] == 0) {
        [Util addEmptyMessageToTable:self.tableView withMessage:NO_COMMENTS withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:self.tableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

// Perform action when send comment button is clicked
-(void)createComment:(NSString *)randomNumber{
    
    NSString *message = [_message.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSCharacterSet *nonAsciiCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:message] invertedSet];
//    message = [[message componentsSeparatedByCharactersInSet:nonAsciiCharacterSet] componentsJoinedByString:@""];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
    [inputParams setValue:_postId  forKey:@"post_id"];
    [inputParams setValue:@"0"  forKey:@"time_stamp"];
    [inputParams setValue:[NSNumber numberWithBool:flag] forKey:@"image_flag"];
    [inputParams setValue:message forKey:@"comment"];
    NSString *url = COMMENT_FOR_POST;
    
    if (_mediaId != nil) {
        [inputParams setValue:_mediaId  forKey:@"media_id"];
        [inputParams setValue:_buzzardRunId  forKey:@"buzzard_run_id"];
        [inputParams setValue:_buzzardRunEventId  forKey:@"buzzard_run_event_id"];
        url = BUZZARD_RUN_COMMRNTS_CREATE_MEDIA;
    }
    
    [[Util sharedInstance] sendHTTPPostRequestWithImage:inputParams withRequestUrl:url withImage:imgData  withFileName:@"image" withCallBack:^(NSDictionary *response) {
        if(response != nil && [[response valueForKey:@"status"] boolValue]){
            [self updateTheLocalComment:randomNumber withData:response];
            [self updateTheCommentInFeedAndPostDetails:response];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"] withDuration:2];
            _message.editable = FALSE;
            [Util addEmptyMessageToTable:self.tableView withMessage:[response objectForKey:@"message"] withColor:[UIColor whiteColor]];
            [commentsList removeAllObjects];
            [_tableView reloadData];
            [_composeView setHidden:YES];
            isPostExpired = [[response valueForKey:@"action_expired"] boolValue];
        }
        
    } onProgressView:nil withExtension:@"filename.jpg" ofType:@"image/jpeg"] ;
    
    flag = false;
    imgData = nil;
    pickedImage = nil;
    _message.text = @"";
    _btnCamera.hidden = NO;
    [self addEmptyMessageForCommentsTable];
}

//Update the local comment after updating
- (void)updateTheLocalComment:(NSString *)number withData:(NSDictionary *)data{
    
    int index = [Util getMatchedObjectPosition:@"commentNo" valueToMatch:number from:commentsList type:0];
    
    if (index != -1) {
        
        NSMutableDictionary *comment = [[commentsList objectAtIndex:index] mutableCopy];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];;
        
        NSString *baseUrl = [data valueForKey:@"media_base_url"];
        
        //Combine the url
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",baseUrl,[data valueForKey:@"full_image_url"]];
        [comment setValue:imageUrl forKey:@"full_image_url"];
        NSString *imageThumbUrl = [NSString stringWithFormat:@"%@%@",baseUrl,[data valueForKey:@"image_thumb_url"]];
        [comment setValue:imageThumbUrl forKey:@"image_thumb_url"];
        [comment setValue:[NSString stringWithFormat:@"%@",[data valueForKey:@"comment_id"]] forKey:@"comment_id"];
        [comment setValue:[NSNumber numberWithBool:FALSE] forKey:@"is_local"];
        NSString *commentId = [data valueForKey:@"comment_id"];
        [comment setValue:nil forKey:@"image"];
        [localComments addObject:commentId];
        
        [commentsList replaceObjectAtIndex:indexPath.row withObject:comment];
        
        //Update the table view
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

//Update the count in feed list/post details
-(void)updateTheCommentInFeedAndPostDetails:(NSDictionary *)responseData{
    if (_postDetails != nil) {
        [_postDetails setValue:[responseData valueForKey:@"comment_count"] forKey:@"comments_count"];
    }
    if (_mediaDetails != nil) {
        [_mediaDetails setValue:[responseData valueForKey:@"comment_count"] forKey:@"comments_count"];
    }
}

//Show or hide the context menu
- (void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    isManual = false;
    // Get index from the table
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    menuIndex = (int)indexPath.row;
    [_message resignFirstResponder];
    //Show menu
    if (![[[commentsList objectAtIndex:indexPath.row] valueForKey:@"comment_id"] isEqualToString:@""]) {
        [tapRecognizer.view becomeFirstResponder];
        UIMenuController* mc = [UIMenuController sharedMenuController];
        [mc setTargetRect: tapRecognizer.view.frame inView: tapRecognizer.view];
        [mc setMenuVisible: YES animated: YES];
    }
}

//Delete comment
- (void)deleteComment: (UIMenuController*) sender
{
    isManual = true; //To prevent
    [self createPopUpWindows];
    [yesNoPopup show];
}

-(void)commentDelete
{
    [yesNoPopup dismiss:YES];
    NSLog(@"Delete clicked");
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:_postId  forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[[commentsList objectAtIndex:menuIndex] valueForKey:@"comment_id"] forKey:@"comment_id"];
    
    NSString *URL = BUZZARD_RUN_COMMENTS_DELETE_POST ;  //DELETE_COMMENT_FOR_POST;
    if (_mediaId != nil) {
        URL = BUZZARD_RUN_COMMENTS_DELETE_MEDIA;
        [inputParams setValue:_mediaId  forKey:@"media_id"];
    }
    
    // Remove comment from list before api call
    [self.tableView beginUpdates];
    [commentsList removeObjectAtIndex:menuIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:menuIndex inSection:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:URL withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue])
        {
            [self addEmptyMessageForCommentsTable];
            [self updateTheCommentInFeedAndPostDetails:response];
            menuIndex = -1;
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"] withDuration:2];
        }else{
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"] withDuration:2];
            if ([[response objectForKey:@"comment_expired"] boolValue]) {
                // Comment already deleted from owner/user
            }
            else
            {
                _message.editable = FALSE;
                [Util addEmptyMessageToTable:self.tableView withMessage:[response objectForKey:@"message"] withColor:[UIColor whiteColor]];
                [commentsList removeAllObjects];
                [_tableView reloadData];
                [_composeView setHidden:YES];
                isPostExpired = [[response valueForKey:@"action_expired"] boolValue];
            }
        }
    } isShowLoader:NO];
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    [self commentDelete];
}

- (void)onNoClick{
    menuIndex = -1;
    [yesNoPopup dismiss:YES];
}

- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(deleteComment:) && menuIndex != -1) {
        return YES;
    }
    return NO;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

#pragma mark - MediaPopupDelegate methods

-(void)onCameraClick{
    
    isNeedUpdate = FALSE;
    [KLCMediaPopup dismiss:YES];
    [self showCamera];
}

-(void)onGalleryClick{
    isNeedUpdate = FALSE;
    [KLCMediaPopup dismiss:YES];
    [self openPhotoAlbum];
}

-(void)onOkClick{
    [KLCMediaPopup dismiss:YES];
}


#pragma mark - Private methods
//step 3.1 handle for camera action
- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Place image picker on the screen
            [self presentViewController:controller animated:YES completion:NULL];
        }];
        
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

//step 3.2 handle for photot action
- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Place image picker on the screen
            [self presentViewController:controller animated:YES completion:NULL];
        }];
        
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

// step 4 - Receive the image from the gallery/camera Open PECropViewController automattically when image selected
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    pickedImage = info[UIImagePickerControllerOriginalImage];
    
    //retrive data from the image
    imgData= UIImageJPEGRepresentation(pickedImage,0.5);
    flag=true;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [picker dismissViewControllerAnimated:YES completion:^{
                [self createTheLocalComment];
            }];
        }];
        
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self createTheLocalComment];
        }];
    }
}


#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [commentsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"commentscell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView *imgProfile = (UIImageView *) [cell viewWithTag:10];
    UILabel *lblName = (UILabel *) [cell viewWithTag:11];
    UILabel *lblDateTime = (UILabel *) [cell viewWithTag:12];
    TTTAttributedLabel *lblComments = (TTTAttributedLabel *) [cell viewWithTag:13];
    UIImageView *commentImage = (UIImageView *) [cell viewWithTag:15];
    UIButton *moreButton = (UIButton *) [cell viewWithTag:50];
    UIView *overlay = (UIView *)[cell viewWithTag:101];
    
    UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
    [lblName setUserInteractionEnabled:YES];
    [lblName addGestureRecognizer:tapName];
    
    NSDictionary *comment = [commentsList objectAtIndex:indexPath.row];
    
    //Hide or show overlay
    if (![[comment valueForKey:@"comment_id"] isEqualToString:@""]) {
        [overlay setHidden:YES];
        lblDateTime.text = [Util timeAgo:[comment valueForKey:@"time_stamp"]];
    }else{
        lblDateTime.text = NSLocalizedString(POSTING, nil);
        [overlay setHidden:NO];
    }
    
    // player_comment_flag  -> when click the profile name if player comment flag is 1 should not redirect
    
    //Bind the comment
    if ([[comment valueForKey:@"continue_reading_flag"] boolValue] && ![[comment valueForKey:@"isExpanded"] boolValue]) {
        NSString *mystring =[comment valueForKey:@"comment"];
        lblComments.text = mystring;
        [Util setAddMoreTextForLabel:lblComments endsWithString:NSLocalizedString(ENDS_WITH_STRING, nil) forlength:256 forColor:UIColorFromHexCode(THEME_COLOR)];
        lblComments.delegate = self;
    }else{
        lblComments.text = [comment valueForKey:@"comment"];
    }
    [lblComments sizeToFit];
    
    
    lblName.text = [comment valueForKey:@"comment_owner_name"];
    //lblDateTime.text = [Util timeAgo:[comment valueForKey:@"time_zone"]];
    [imgProfile setImageWithURL:[NSURL URLWithString:[comment valueForKey:@"profile_image"]] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    commentImage.hidden = YES;
    [commentImage hideByHeight:YES];
    //Get image from server
    if ([[comment valueForKey:@"media_type"] intValue] == 2 && ![[comment valueForKey:@"is_local"] boolValue]) {
        [commentImage setImageWithURL:[NSURL URLWithString:[comment valueForKey:@"image_thumb_url"]] placeholderImage:nil];
        commentImage.clipsToBounds = YES;
        commentImage.hidden = NO;
        [commentImage hideByHeight:NO];
    }
    
    //Append local image
    if ([[comment valueForKey:@"is_local"] boolValue]) {
        [commentImage setImage:[comment objectForKey:@"image"]];
        commentImage.hidden = NO;
        commentImage.clipsToBounds = YES;
        [commentImage hideByHeight:NO];
    }
    
    //Hide or show the option button
    if (![[comment valueForKey:@"am_owner"] boolValue]) {
        [moreButton setHidden:YES];
    }
    else{
        //option click listner
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ShowMenu:)];
        [moreButton setUserInteractionEnabled:YES];
        [moreButton addGestureRecognizer:tap];
        [moreButton setHidden:NO];
    }
    
    // Separator Line for cells
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.window.frame.size.width, 5)];
    separatorLineView.backgroundColor = [UIColor blackColor];
    [cell.contentView addSubview:separatorLineView];
    
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FriendProfile:)];
    [imgProfile setUserInteractionEnabled:YES];
    [imgProfile addGestureRecognizer:tapImage];
    
    //Add zoom for Profile Image
    //[[Util sharedInstance] addImageZoom:imgProfile];
    
    //Add zoom for Comments Image
    [[Util sharedInstance] addImageZoom:commentImage];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

//Return dynamic height for tableview cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    float height = 90;
    
    NSDictionary *comment = [commentsList objectAtIndex:indexPath.row];
    
    TTTAttributedLabel *lblComments = (TTTAttributedLabel *) [cell viewWithTag:13];
    height = height + lblComments.frame.size.height;
    if ([[comment valueForKey:@"media_type"] intValue] == 2) {
        height = height + 130;
    }
    
    return height;
}


#pragma mark TTTAttributedLabel delegate

//Common Delegate for TTTAttributed Label
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    NSLog(@"Perform action for continue Text : %@",url);
    CGPoint buttonPosition = [label convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSDictionary *comment = [commentsList objectAtIndex:indexPath.row];
    [comment setValue:[NSNumber numberWithBool:YES] forKey:@"isExpanded"];
    [commentsList replaceObjectAtIndex:indexPath.row withObject:comment];
    
    //Update the table view
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
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
    
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
        
        //Move to bottom
        if ([commentsList count]>0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[commentsList count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    _marginBottom.constant = 0;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}


-(void)FriendProfile:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    NSString *playerId = [[commentsList objectAtIndex:indexPath.row] objectForKey:@"comment_owner_id"];
    if ( [[Util getFromDefaults:@"player_id"] isEqualToString:playerId]) {
        isNeedUpdate = TRUE;
        MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
        [self.navigationController pushViewController:myProfile animated:YES];
    }
    else{
//        FriendProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
//        profile.friendName = [[commentsList objectAtIndex:indexPath.row] objectForKey:@"player_name"];
//        profile.friendId = [[commentsList objectAtIndex:indexPath.row] objectForKey:@"comment_owner_id"];
//        [self.navigationController pushViewController:profile animated:YES];
    }
}


- (IBAction)openEmoji:(id)sender {
    if (isEmojiKeyboard)
    {
        isEmojiKeyboard = FALSE;
        [self showNormalKeyboard];
    }
    else
    {
        isEmojiKeyboard = TRUE;
        [self showEmojiKeyboard];
    }
    
    [self changeKeyboardTypeButtonImage];
}

-(void) changeKeyboardTypeButtonImage
{
    if (isEmojiKeyboard) {
        
        [_keyboardButton setImage:[UIImage imageNamed:@"Keyboard.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_keyboardButton setImage:[UIImage imageNamed:@"Smily.png"] forState:UIControlStateNormal];
    }
    [_keyboardButton setTitle:@"" forState:UIControlStateNormal];
}

-(void)showEmojiKeyboard
{
    [self.message resignFirstResponder];
    self.message.inputView = emojiKeyboardView;
    [self.message becomeFirstResponder];
}

-(void)showNormalKeyboard
{
    [self.message resignFirstResponder];
    self.message.inputView = nil;
    [self.message becomeFirstResponder];
}

// Emoji Delegate

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    if ([self.message.text length] < 1000 && [self.message.text length] != 999) {
        //self.message.text = [self.message.text stringByAppendingString:emoji];
        [self.message replaceRange:self.message.selectedTextRange withText:emoji];
    }
}

// Clear text from Emoji keyboard
- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.message deleteBackward];
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    @autoreleasepool {
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
