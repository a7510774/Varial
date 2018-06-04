//
//  CreatePostViewController.m
//  Varial
//
//  Created by jagan on 08/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "CreatePostViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GoogleAdMob.h"
#import "ChatHome.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>

#import "AddPostViewController.h"
#import "NameTagTableViewCell.h"

@interface CreatePostViewController ()
{
    BOOL isSelectNameTag,isShowCallouts;
    NSArray *oldArray;
    NSString *myStrCallOutText;
}
@end

@implementation CreatePostViewController

@synthesize autoCompleteArray;
@synthesize autoCompleteFilterArray;

NSMutableArray *recipients, *medias;
BOOL isCaptured,isMaxFileShown,isComposingDone;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
     autoCompleteArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"autocomplete"]];
    
    autoCompleteFilterArray = [[NSMutableArray alloc] init];
    _selectedArray = [[NSMutableArray alloc] init];
    
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.hidden =TRUE;
    
    _contentTableView.tableFooterView = [UIView new];
    
    [[_contentTableView layer] setMasksToBounds:NO];
    [[_contentTableView layer] setShadowColor:[UIColor blackColor].CGColor];
    [[_contentTableView layer] setShadowOffset:CGSizeMake(0.0f, 5.0f)];
    [[_contentTableView layer] setShadowOpacity:0.3f];
    
    [self.view bringSubviewToFront:_contentTableView];
    
    // [self savedata];
    
    [self getfriendsList];
    
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // this one is key
    self.requestOptions.synchronous = YES;
    
    // Do any additional setup after loading the view.
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
//    picker = [[UIImagePickerController alloc] init];
    recipients = [[NSMutableArray alloc] init];
    recipients = appDelegate.createPostRecepients;
    medias = [[NSMutableArray alloc] init];
    hasCheckin = isMaxFileShown = FALSE;
    isComposingDone = TRUE;
    
    self.dimView.hidden = YES;
    [self.spinnerView setLineWidth:2.0];
    [self.spinnerView setTintColor:UIColorFromHexCode(THEME_COLOR)];

    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
    
    //Build input params
    _inputParams = [[NSMutableDictionary alloc] init];
    [_inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
//    postTypeIcons = [[NSArray alloc] initWithObjects:@"",@"global.png",@"private.png",@"friendsfeed.png",@"teamfee.png", nil];
    postTypeIcons = [[NSArray alloc] initWithObjects:@"",@"publicFeedIcon",@"privateFeedIcon",@"friendsFeedIcon",@"teamfee.png", nil];
    _comment.delegate = self;
//    mediaPickerController = [[IQMediaPickerController alloc] init];
//    mediaPickerController.delegate = self;
    
    [self.contentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([NameTagTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([NameTagTableViewCell class])];

    isCaptured = FALSE;
    isEmojiKeyboard = FALSE;
    
    _headerView.delegate = self;
    
    [self designTheView];
    [self getMediaConfig];
    [self createCheckinParams];
    [self isBuzzardRunPost];
    
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
    
    [self startLocationUpdate:NO];
    if(![self isBuzzardRunPost]){
        if ([recipients count] != 0) {
            selectedIndex = 0;
            selectedRecepie = [recipients objectAtIndex:0];
            [recipientPopup dismiss:YES];
            [self displayToFilds:selectedRecepie];
        }
    }
    
    UIView *contentView = [UIView new];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    [contentView addSubview:imageView];
    [_scrollView addSubview:contentView];
    _imageView = imageView;
    
    //Set a black theme rather than a white one
    /*
     [[CLImageEditorTheme theme] setBackgroundColor:[UIColor blackColor]];
     [[CLImageEditorTheme theme] setToolbarColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
     [[CLImageEditorTheme theme] setToolbarTextColor:[UIColor whiteColor]];
     [[CLImageEditorTheme theme] setToolIconColor:@"white"];
     [[CLImageEditorTheme theme] setStatusBarStyle:UIStatusBarStyleLightContent];
     [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
     [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
     */
    [self refreshImageView];
    // Emoji keyboard
//    emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
//    emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    emojiKeyboardView.delegate = self;
    
    self.comment.placeholder = NSLocalizedString(Description, nil);
    
    [HELPER imageWithRenderingMode:@"cameraIcon" color:[UIColor lightGrayColor] imageView:self.imgViewCamera];
    
    UITapGestureRecognizer *tapRecognizerLibrary = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureLibraryHandlerMethod:)];
    [self.viewPhoto addGestureRecognizer:tapRecognizerLibrary];
    
    UITapGestureRecognizer *tapRecognizerCamera = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureCameraHandlerMethod:)];
    [self.viewCamera addGestureRecognizer:tapRecognizerCamera];
    
    UITapGestureRecognizer *tapRecognizerVideo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureVideoHandlerMethod:)];
    [self.viewVideo addGestureRecognizer:tapRecognizerVideo];
    
    UITapGestureRecognizer *tapRecognizerCheckIn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureCheckInHandlerMethod:)];
    [self.viewCheckIn addGestureRecognizer:tapRecognizerCheckIn];
}


- (void)startLocationUpdate:(BOOL)showLoader{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:@"LocationUpdated" object:nil];
    [[LocationManager sharedManager] startUpdateLocation];
    
    if (showLoader) {
        progressLoader = [Util showLoadingWithTitle:NSLocalizedString(DETECT_LOCATION, nil)];
        [progressLoader show:YES];
    }
}

- (void) updateLocation:(NSNotification *) data{
    [[LocationManager sharedManager] stopUpdateLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
    if (progressLoader != nil) {
        [Util hideLoading:progressLoader];
    }
}

- (void)backPressed {
    [self askBackConfirm: nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [Util createBottomLine:_toView withColor:UIColorFromHexCode(GREY_BORDER)];
}

- (void)viewWillAppear:(BOOL)animated{
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askBackConfirm:) name:@"BackPressed" object:nil];
    tappedChat = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discardPostOnChat:) name:@"DiscardPost" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUrlPreview) name:@"ShowURLPreview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePreview) name:@"HideURLPreview" object:nil];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self checkForCheckIn];
    mediaAttachment = FALSE;
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackPressed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DiscardPost" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowURLPreview" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideURLPreview" object:nil];
}

//- (void)textViewDidBeginEditing:(UITextView *)textView{
// if(_comment.text != nil ){

//}




- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
    }
   
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\\b");
    
    if (isBackSpace == -92) {
        
        
        
//        for(int i=0;i<_selectedArray.count;i++){
//        if([_selectedArray containsObject:text]){
//            [_selectedArray removeObject:_selectedArray[i]];
//             _comment.text = [_selectedArray componentsJoinedByString:@" "];
//            break;
//        }
//        }
//
       
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
        NSArray *matches = [regex matchesInString:_comment.text options:0 range:NSMakeRange(0, _comment.text.length)];
       
        [_selectedArray removeAllObjects];
        for (NSTextCheckingResult *match in matches) {
            NSRange wordRange = [match rangeAtIndex:1];
            NSString* word = [_comment.text substringWithRange:wordRange];
            NSLog(@"Found tag %@", word);
            
//            NSArray *arr =  [_comment.text componentsSeparatedByString:@" "];
//
//            if(_selectedArray.count > 0){
//
//                for (int i=0; i<arr.count; i++) {
//                    for (int f=0; f<autoCompleteArray.count; f++) {
//                        NSDictionary *values = autoCompleteArray[f];
//                        if(![arr[i] isEqualToString:[@"@" stringByAppendingString:values[@"name"]]]){
//                            // [_selectedArray addObject:[@"@" stringByAppendingString:values[@"name"]]];
//                            if([_selectedArray containsObject:arr[i]])
//                                [_selectedArray removeObject:arr[i]];
//                        }
//                    }
//                }
//            }
            
             [_selectedArray addObject:[@"@" stringByAppendingString:word]];
            
                }
        
        
    }else{
            if([text isEqualToString:@" "])
                [self checkForURL:_comment.text];
        
    }
    
//    autoCompleteFilterArray = [[NSArray alloc] init];
//
//    NSString *passcode = [_comment.text stringByReplacingCharactersInRange:range withString:text];
//
//    NSString *replaceAt = [passcode stringByReplacingOccurrencesOfString:@"@"
//                                                         withString:@""];
//
//  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@", replaceAt];
//
//    autoCompleteFilterArray = [autoCompleteArray filteredArrayUsingPredicate:predicate];
//
//    if ([autoCompleteFilterArray count]==0) {
//        _contentTableView.hidden = YES;
//    }else{
//        _contentTableView.hidden = NO;
//    }
//
//    }else{
//
//        autoCompleteFilterArray = autoCompleteArray;
//    }
//
//    [_contentTableView reloadData];
    
  //  }
    
    return YES;
}
//-(void)textViewDidChange:(UITextView *)textView{
//    if([_comment.text length] == 0 && !isUrlPreviewShown)
//        firstPreview = TRUE;
//    [self setRestrictChat];
//
//     _contentTableView.hidden = NO;
//
//}


- (void)textViewDidChange:(UITextView *)textView {
    
        if([_comment.text length] == 0 && !isUrlPreviewShown)
            firstPreview = TRUE;
        [self setRestrictChat];
    
    textView.scrollEnabled = YES;
    
    NSRange selectedRange = textView.selectedRange;
    
    NSString *text = textView.text;
    
    if (!text.length)
        
        _contentTableView.hidden = YES;
    
    // This will give me an attributedString with the base text-style
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSError *calloutError = nil;
    
    NSRegularExpression *regexCallout = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&calloutError];
    
    NSArray *matchesCallout = [regexCallout matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    if (matchesCallout.count > 0) {
        
        NSUInteger numberOfOccurrences = [[text componentsSeparatedByString:@"@"] count] - 1;
        
        if (numberOfOccurrences < 10) {
           
           // myStrCallOutText = textView.text;

            if (!matchesCallout.count) {
                myStrCallOutText = textView.text;
                
                if (isShowCallouts) {
                    
                    isShowCallouts = NO;
                    _contentTableView.hidden = YES;
                }
            }
            
           // [_selectedArray removeAllObjects];
            
            for (NSTextCheckingResult *match in matchesCallout) {
                
                NSRange matchRange = [match rangeAtIndex:0];
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:[UIColor orangeColor]
                                         range:matchRange];
                
                NSString *aStrText = [text substringWithRange:matchRange];
                aStrText = [aStrText substringFromIndex:1];
                
                [self getPredicataeCallOut:aStrText];
                
                if (autoCompleteFilterArray.count) {
                    
                    if (isShowCallouts) {
                        _contentTableView.hidden = NO;
                        [_contentTableView reloadData];
                    }
                    
                    else {
                        
                        isShowCallouts = YES;
                        _contentTableView.hidden = NO;
                        [_contentTableView reloadData];

//                        mPullupListView = [[XDPopupListView alloc] initWithBoundView:textView dataSource:self delegate:self popupType:XDPopupListViewCustomizationCenter];
//                        [mPullupListView show];
                        
                    }
                }
                else {
                    
                    isShowCallouts = NO;
                    _contentTableView.hidden = YES;
                }
            }
            
            [self addAttributeString:text textView:textView selectedRange:selectedRange];
            
        }
        
        else {
            
            [self addAttributeString:text textView:textView selectedRange:selectedRange];
        }
    }
    
    else {
        
        myStrCallOutText = textView.text;
        [self addAttributeString:text textView:textView selectedRange:selectedRange];
    }
}


- (void)getPredicataeCallOut :(NSString *)aStrFilterText {
    
    autoCompleteFilterArray = [NSMutableArray new];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@", aStrFilterText];
    
    NSArray *results = [autoCompleteArray filteredArrayUsingPredicate:predicate];
    [autoCompleteFilterArray addObjectsFromArray:results];
    

    
}

- (void)addAttributeString:(NSString *)aStrText textView:(UITextView *)aTextView selectedRange:(NSRange)aRange {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:aStrText];
    
    NSError *error = nil;
    
    NSRegularExpression *regexCallout = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    
    NSArray *matchesCallout = [regexCallout matchesInString:aStrText options:0
                               range:NSMakeRange(0, aStrText.length)];
    
    for (NSTextCheckingResult *match in matchesCallout) {
        
        NSRange matchRange = [match rangeAtIndex:0];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]
         range:matchRange];
    }
    
//    for (NSTextCheckingResult *match in hashTagMatches) {
//
//        NSRange matchRange = [match rangeAtIndex:0];
//
//        [attributedString addAttribute:NSForegroundColorAttributeName
//
//                                 value:[UIColor orangeColor]
//
//                                 range:matchRange];
//    }
    
    if (matchesCallout.count) {
        
        aTextView.attributedText = attributedString;
        aTextView.selectedRange = aRange;
        aTextView.scrollEnabled = YES;
    }
}

//- (void)textViewDidBeginEditing:(UITextView *)textView {
//
//  // _contentTableView.hidden = NO;
//}

- (void)textViewDidEndEditing:(UITextView *)textView {
   
 _contentTableView.hidden = YES;
    
}


//Create empty checkin fields
- (void)createCheckinParams{
    
    [_inputParams setValue:@"" forKey:@"check_in_name"];
    [_inputParams setValue:@"" forKey:@"check_in_latitude"];
    [_inputParams setValue:@"" forKey:@"check_in_longitude"];
    [_inputParams setValue:@"" forKey:@"check_in_state"];
    [_inputParams setValue:@"" forKey:@"check_in_city"];
    [_inputParams setValue:@"" forKey:@"check_in_country"];
    [self checkForCheckIn];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkForCheckIn{
    //Check checkin has made
    if (![[_inputParams valueForKey:@"check_in_name"] isEqualToString:@""]) {
        hasCheckin = TRUE;
        if(_checkinView.frame.size.height == 0)
            [self setHeaderForCheckIn:YES];
        _checkinTitle.text = [_inputParams valueForKey:@"check_in_name"];
        [_checkinView setConstraintConstant:30 forAttribute:NSLayoutAttributeHeight];
        [_clearCheckinButton setHidden:NO];
        [self changeCheckinButton:YES];
    }
}
-(void) askBackConfirm:(NSNotification *) data{
    //Check is there any changes made in post form
    if ([medias count] == 0 && [[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 && !hasCheckin && !isUrlPreviewShown) {
//        [self.navigationController popViewControllerAnimated:YES];
        if (task != nil) {
            [task cancel];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [yesNoPopup show];
    }
    [_comment resignFirstResponder];
}
-(void)discardPostOnChat:(NSNotification *) data{
    if(!tappedChat)
    {
        if ([medias count] != 0 || [[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0 || hasCheckin || isUrlPreviewShown) {
            [yesNoPopup show];
            tappedChat = YES;
        }
    }
     [_comment resignFirstResponder];
}
- (void)getMediaConfig{
    
    //Get configuration from the session
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"] != nil){
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        maxImage =  [[config valueForKey:@"default_image_file"] intValue];
        maxVideo =  [[config valueForKey:@"default_video_file"] intValue];
        maxImageFileSize = [[config valueForKey:@"default_image_size"] intValue];
        maxVideoFileSize = [[config valueForKey:@"default_video_size"] intValue];
    }
}

- (void)designTheView {
    
//    [_headerView setHeader:NSLocalizedString(POST_FEED, nil)];
    [_headerView setHeader:NSLocalizedString(@"", nil)];
    
    [_headerView.logo setHidden:YES];
//    _headerView.restrictBack = TRUE;
    
    [Util createRoundedCorener:_postButton withCorner:3];
    [Util createRoundedCorener:self.recipientView withCorner:5];
    
    //Table view design
    self.recipientTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.mediaTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_checkinView setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    [_clearCheckinButton setHidden:YES];
    
//    _comment.placeholder = NSLocalizedString(POST_COMMENT, nil);
    
    mediaExceed = [[NetworkAlert alloc] init];
    [mediaExceed setNetworkHeader:NSLocalizedString(MEDIA, nil)];
    [mediaExceed.button setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
    
    //[_checkinView hideByHeight:YES];
    
    [self createPopupView];
    if(![self isBuzzardRunPost])
    {
        [self getRecepies];
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    [self.comment setTextContainerInset:UIEdgeInsetsMake(5, 0, 0, 35)];
    [_comment becomeFirstResponder];
    _urlPreviewHeight.constant = 0;
    [_urlPreview setHidden:YES];
    isUrlPreviewShown = FALSE;
    _urlPreview.delegate = self;
    firstPreview = TRUE;
    [self setHeaderForCheckIn:YES];
    [self setHeaderForCheckIn:NO];
    mediaAttachment = FALSE;
    _cameraLabel.text = NSLocalizedString(CAMERA, nil);
    _imageLabel.text = NSLocalizedString(IMAGE, nil);
    _videoLabel.text = NSLocalizedString(VIDEO, nil);
    _checkInLabel.text = NSLocalizedString(CHECK_IN, nil);
    [_postButton setTitle:NSLocalizedString(POST_TITLE, nil) forState:UIControlStateNormal];
}
- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [Util createBottomLine:_toView withColor:UIColorFromHexCode(GREY_BORDER)];
}

//Create popup view
- (void)createPopupView{
    
    mediaCountPopup = [KLCPopup popupWithContentView:mediaExceed showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
    
    recipientPopup = [KLCPopup popupWithContentView:self.recipientView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    mediaPopupView = [[MediaPopup alloc] init];
    [mediaPopupView setDelegate:self];
    [mediaPopupView.okButton setTitle:NSLocalizedString(CANCEL, nil) forState:UIControlStateNormal];
    mediaPopup = [KLCPopup popupWithContentView:mediaPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    if([_postFromBuzzardRun isEqualToString:@"yes"])
        locationPopupView = [[LocationPopup alloc]initWithView:NO pin:YES use:YES];
    else
        locationPopupView = [[LocationPopup alloc]initWithView:YES pin:YES use:YES];
    
    [locationPopupView setDelegate:self];
    locationPopup = [KLCPopup popupWithContentView:locationPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    checkInPopupView = [[CheckInPopup alloc]init];
    [checkInPopupView setDelegate:self];
    checkInPopup = [KLCPopup popupWithContentView:checkInPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    checkInPopup.didFinishShowingCompletion = ^{
        [checkInPopupView.locationField becomeFirstResponder];
    };
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(DISCARD, nil)];
    popupView.message.text = NSLocalizedString(DISCARD_POST, nil);
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
}

// Populate this with previously created postInfo
- (void)reopenWithInfo:(NSDictionary *)postInfo fromFeed:(int)feedIndex {
    
}

- (IBAction)postFeed:(id)sender {
    
    [_comment resignFirstResponder];
    if ([self validatePostForm] && isComposingDone) {
        
        if([[Util sharedInstance] getNetWorkStatus])
        {
            NSString *content = [_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [_inputParams setValue:content forKey:@"text"];
            
            if ([self isBuzzardRunPost]) {
                
                [_inputParams setValue:_buzzardRunId forKey:@"buzzard_run_id"];
                [_inputParams setValue:_buzzardRunEventId forKey:@"buzzard_run_event_id"];
                NSMutableDictionary *input = [self buildParams:_inputParams];
                [input setValue:_inputParams forKey:@"new_post"];
                
                NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
                PostBuzzardRun *post = [[self.navigationController viewControllers] objectAtIndex:[navigationArray count] - 2];
                [post.feeds insertObject:input atIndex:0];
//                [self.navigationController popViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            // Feed Post
            else
            {
                NSMutableDictionary *input = [self buildParams:_inputParams];
                [input setValue:_inputParams forKey:@"new_post"];
                
                // Moved to ViewController
//                NSString *selectedType;
//                ViewController *viewController = [[self.navigationController viewControllers] firstObject];
//                // Public And Friends feeds
//                if (selectedIndex == 0 || selectedIndex == 2) {
//                    [viewController.publicFeeds insertObject:input atIndex:0];
//                    selectedType = @"1";
//                }
//                // Private Feeds
//                else if (selectedIndex == 1) {
//                    [viewController.privateFeeds insertObject:input atIndex:0];
//                    selectedType = @"2";
//                }
//                // Team A Feeds
//                else if (selectedIndex == 3){
//                    [viewController.teamAFeeds insertObject:input atIndex:0];
//                    selectedType = @"3";
//                }
//                // Team B Feeds
//                else if (selectedIndex == 4){
//                    [viewController.teamBFeeds insertObject:input atIndex:0];
//                    selectedType = @"4";
//                }
//                
//                viewController.selectedFeedType = selectedType;
//                [viewController setCurrentPage:0];
//                [viewController.tabBar setSelectedItem:[[viewController.tabBar items] objectAtIndex:0]];

                
                //                [self.navigationController popToRootViewControllerAnimated:YES];
                
//                if ([self.delegate respondsToSelector:@selector(newPost:forFeed:)]) {
//                    [self.delegate newPost:input forFeed:selectedIndex];
//                }
//                
//                [self dismissViewControllerAnimated:YES completion:nil];
//                [self uploadPost:postInfo Media:medias feedType:@"" getIndex:0];
                
                NSMutableArray *medias = [input objectForKey:@"is_media"];
                [self post:_inputParams Media:medias feedType:selectedIndex];
            }
        }
        else{
            [appDelegate.networkPopup show];
        }
    }
}

- (IBAction)showRecipes:(id)sender {
    
    if (![self isBuzzardRunPost]) {
        [self createPopupView];
        [_recipientView setHidden:NO];
        [_comment resignFirstResponder];
        [recipientPopup show];
    }
}

- (IBAction)removeCheckin:(id)sender {
    
    [self setRestrictChat];
    hasCheckin = FALSE;
    [_checkinView setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    [_clearCheckinButton setHidden:YES];
    [self setHeaderForCheckIn:YES];
    [self changeCheckinButton:NO];
    
    [_checkinIcon setImage:[UIImage imageNamed:@"addCheckinIcon"]];
    [_showCheckin setTitleColor:UIColorFromHexCode(GREY_TEXT) forState:UIControlStateNormal];
    [_inputParams setValue:@"" forKey:@"check_in_name"];
    
}

- (IBAction)addImage:(id)sender {
    
    [self.view endEditing:YES];
    
    AddPostViewController *aViewController = [AddPostViewController new];
    aViewController.gIsPresentVideoClick = NO;
    aViewController.myUpdateFilterBlock = ^void(BOOL isImageUpdate, UIImage* aImage, NSURL *videoUrl) {
        
        if (isImageUpdate) {
            
            [self loadCameraImageView:aImage];
        }
    };
    
    [self.navigationController pushViewController:aViewController animated:YES];
    
    //    isVideoTapped = NO;
    //    if ([medias count] < maxImage) {
    //        // Get rid of the gallery/camera choice
    ////        [self onGalleryClick];
    //        [self createPopupView];
    //        [mediaPopupView setHidden:NO];
    //        [mediaPopup show];
    //    }
    //    else if ([medias count] == maxImage) {
    //        mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(IMAGE_ALLOWED, nil),maxImage];
    //        [mediaCountPopup show];
    //    }
    //    [_comment resignFirstResponder];
}

- (IBAction)addCheckIn:(id)sender {
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"])
    {
        CheckInViewController *baiduMap = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"CheckInViewController"];
        [self.navigationController pushViewController:baiduMap animated:YES];
    }
    else
    {
        [locationPopup show];
    }
}

# pragma mark - Google Location Popup Methods

-(void)onSearchLocationClick{
    
    [locationPopup dismiss:YES];
    [_comment resignFirstResponder];
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    // IF ch or zh is an CHINA
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
        CheckInViewController *baiduMap = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"CheckInViewController"];
        [self.navigationController pushViewController:baiduMap animated:YES];
        
    }else{
        GoogleCheckin *googleMap = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"GoogleCheckin"];
        googleMap.isCheckinFromBuzzardRun = _postFromBuzzardRun;
        [self.navigationController pushViewController:googleMap animated:YES];
    }
    
}

-(void)onPinNearByLocationClick{
    [locationPopup dismiss:YES];
    [_comment resignFirstResponder];
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    // IF ch or zh is an CHINA
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
        CheckInViewController *baiduMap = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"CheckInViewController"];
        [self.navigationController pushViewController:baiduMap animated:YES];
        
    }else{
        GoogleCheckin *googleMap = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"GoogleCheckin"];
        googleMap.isCheckinFromBuzzardRun = _postFromBuzzardRun;
        googleMap.showPopup = TRUE;
        [self.navigationController pushViewController:googleMap animated:YES];
    }
    
}
-(void)onUseCurrentLocationClick{
    [locationPopup dismiss:YES];
    if([Util checkLocationIsEnabled]){
        checkInPopupView.locationField.text = @"";
        [Util createBottomLine:checkInPopupView.locationField withColor:[UIColor lightGrayColor]];
        [checkInPopup showWithLayout:layout];
    }
    else{
        [[Util sharedInstance] showLocationAlert];
    }
}

-(void)onCheckInClick{
    
    if([self validateLocation])
    {
        [_inputParams setValue:NSLocalizedString(checkInPopupView.locationField.text, nil) forKey:@"check_in_name"];
        [_inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].latitude] forKey:@"check_in_latitude"];
        [_inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].longitude] forKey:@"check_in_longitude"];
        [_inputParams setValue:@"" forKey:@"check_in_state"];
        [_inputParams setValue:@"" forKey:@"check_in_city"];
        [_inputParams setValue:@"" forKey:@"check_in_country"];
        [self checkForCheckIn];
        [checkInPopup dismiss:YES];
        //Get Location
        if ([LocationManager sharedManager].latitude == 0.0) {
            [self startLocationUpdate:YES];
        }
    }
}

-(void)onCheckInCancelClick{
    [checkInPopup dismiss:YES];
}

-(BOOL)validateLocation{
    //Validate location name
    if(![Util validateLocationField:checkInPopupView.locationField withValueToDisplay:@"Place Name" withIsEmailType:FALSE withMinLength:LOCATION_NAME_MIN withMaxLength:LOCATION_NAME_MAX]){
        return FALSE;
    }
    return TRUE;
}

- (IBAction)addVideo:(id)sender {
    
    [self.view endEditing:YES];
    
    AddPostViewController *aViewController = [AddPostViewController new];
    aViewController.gIsPresentVideoClick = YES;

    aViewController.myUpdateFilterBlock = ^void(BOOL isImageUpdate, UIImage* aImage, NSURL *videoUrl) {
    
        if (isImageUpdate) {
            [self loadCameraImageView:aImage];
        }
        else {
            
            isCaptured = YES;
            if ([Util isVideoMinimumtwoMins:videoUrl]) {
                
                [Util saveVideoToAlbum:videoUrl withCompletionBlock:^(PHAsset *asset) {
                    [self createMediaResource:@[videoUrl] forIndex:0 isPhoto:NO];
                }];
            }
            else{
                // Video should minimum 3sec
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(VIDEO_DURATION, nil) withDuration:2.0];
            }
        }
    };

    [self.navigationController pushViewController:aViewController animated:YES];
    
    //[self presentViewController:aViewController animated:YES completion:nil];
//
//        isVideoTapped = YES;
//        if ([medias count] == 0) {
//            [self createPopupView];
//            [mediaPopupView setHidden:NO];
//            [mediaPopup show];
//    //        [self onGalleryClick];
//        }
//        else {
//            mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(VIDEOS_ALLOWED, nil),1];
//            [mediaCountPopup show];
//        }
}

- (BOOL)validatePostForm{
    
    //Check post has recepient
    if (selectedRecepie == nil) {
        // Post From Feed Page
        if(![self isBuzzardRunPost])
        {
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(RECEPIE_EMPTY, nil)];
            return FALSE;
        }
        else // Post From Buzzard Run Page
        {
            // Checkin is mandatory, when post from buzzard Run
            if (!hasCheckin) {
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(CHECKIN_EMPTY, nil)];
                return FALSE;
            }
            else if([medias count] == 0)
            {
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(MEDIA_EMPTY, nil)];
                return FALSE;
            }
        }
    }
    //Check post content length
    if([[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0)
    {
        if([[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > POST_CONTENT_MAX)
        {
            [Util showErrorMessage:_comment withErrorMessage:[NSString stringWithFormat:NSLocalizedString(POST_CONTENT_DOES_MAX, nil),POST_CONTENT_MAX]];
            return FALSE;
        }
    }
    
    if ([medias count] == 0 && [[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 && !hasCheckin &&  !isUrlPreviewShown) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(BLANK_STATUS, nil)];
        return FALSE;
    }
    
    if ([medias count] != 0 && ![self ValidateFileSize]) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(MEDIA_SIZE_EXCEEDS, nil)];
        return FALSE;
    }
    
    //For voice input
    NSRange range = [_comment.text rangeOfString: @"\uFFFC"];
    if (range.location != NSNotFound) {
        return false;
    }
    
    return TRUE;
}


//Toggle the checkin button
-(void)changeCheckinButton:(BOOL)status{
    [self setRestrictChat];
    if (status) {
        [_checkinIcon setImage:[UIImage imageNamed:@"addCheckinIconActive"]];
        [_showCheckin setTitleColor:UIColorFromHexCode(THEME_COLOR) forState:UIControlStateNormal];
    }
    else{
        [_checkinIcon setImage:[UIImage imageNamed:@"addCheckinIcon"]];
        [_showCheckin setTitleColor:UIColorFromHexCode(GREY_TEXT) forState:UIControlStateNormal];
    }
}

//Toggle the image button
-(void)changeImageButton:(BOOL)status{
    
    if (status) {
        [_imageIcon setImage:[UIImage imageNamed:@"imageIconActive"]];
        [_showImageButton setTitleColor:UIColorFromHexCode(THEME_COLOR) forState:UIControlStateNormal];
    }
    else{
        [_imageIcon setImage:[UIImage imageNamed:@"imageIcon"]];
        [_showImageButton setTitleColor:UIColorFromHexCode(GREY_TEXT) forState:UIControlStateNormal];
    }
}

//Toggle the video button
-(void)changeVideoButton:(BOOL)status{
    
    if (status) {
        
        [_videoIcon setImage:[UIImage imageNamed:@"videoIconActive"]];
        [_showVideoIcon setTitleColor:UIColorFromHexCode(THEME_COLOR) forState:UIControlStateNormal];
    }
    else{
        [_videoIcon setImage:[UIImage imageNamed:@"videoIcon"]];
        [_showVideoIcon setTitleColor:UIColorFromHexCode(GREY_TEXT) forState:UIControlStateNormal];
    }
}

//Discard the post
- (void)discardPost{
    [yesNoPopup dismiss:YES];
//    UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
//    [navigation popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Remove media
- (void) askMediaDelete:(id)sender{
    
    CGPoint tapLocation = [sender convertPoint:CGPointZero toView:self.mediaTable];
    NSIndexPath *indexPath = [self.mediaTable indexPathForRowAtPoint:tapLocation];
    
    if([medias count] > indexPath.section)
    {
        [self.mediaTable beginUpdates];
        NSDictionary *media = [medias objectAtIndex:indexPath.section];
        [medias removeObjectAtIndex:indexPath.section];
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        [indexSet addIndex:indexPath.section];
        [self.mediaTable deleteSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
        [self.mediaTable endUpdates];
        
        //Check for button enabled/disabled
        
        if ([medias count] == 0) {
            [self changeImageButton:NO];
            [self changeVideoButton:NO];
            [_showVideoIcon setEnabled:YES];
            [_showImageButton setEnabled:YES];
        }
        
        if ([[media valueForKey:@"mediaType"] boolValue]) {
            if ([medias count] < maxImage){
                [_showImageButton setEnabled:YES];
            }
        }
        else{
            if ([medias count] < maxVideo){
                [_showVideoIcon setEnabled:YES];
            }
        }
    }
    [self setRestrictChat];
}

//Get Recepie list
- (void)getRecepies{
    
    //Send get recepie request
    //Build Input Parameters
    NSMutableDictionary *inputParam = [[NSMutableDictionary alloc] init];
    [inputParam setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParam setValue:[NSNumber numberWithInt:1] forKey:@"post_feed_type_list"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParam withRequestUrl:CREATE_POST_RECEPIENT withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            recipients = [response objectForKey:@"post_types"];
            [_recipientTable reloadData];
            [self changeTableViewHeight];
            appDelegate.createPostRecepients = recipients;
            
            // If changed feed type before get response should show selected value
            if(selectedIndex != 0)
            {
                int index = [Util getMatchedObjectPosition:@"id" valueToMatch:[NSString stringWithFormat:@"%d",selectedIndex] from:recipients type:0];
                
                // If selected index is team and team is not present should load the Public
                if (index == -1) {
                    selectedIndex = 0;
                }
                selectedRecepie = [recipients objectAtIndex:selectedIndex];
                [recipientPopup dismiss:YES];
                [self displayToFilds:selectedRecepie];
            }
            else
            {
                selectedIndex = 0;
                selectedRecepie = [recipients objectAtIndex:0];
                [recipientPopup dismiss:YES];
                [self displayToFilds:selectedRecepie];
            }
            
            
        }
        //feed type in post view
        else if ([[response valueForKey:@"error"] isEqualToString:@"time_out"])
       
        {
     // Time Out Error
     
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(FEED_TYPE_NOT_FOUND, nil)];
               [self.spinnerView stopAnimating];
        
            self.dimView.hidden = YES;
      
        }
        
        else{
         
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            
        }
    } isShowLoader:NO];
    
}

//Change the autocomplete table view height
- (void) changeTableViewHeight {
    
    CGFloat height = _recipientTable.rowHeight;
    height *= recipients.count;
    
    _feedTypesHeight.constant = height + 55;
    [_recipientView layoutIfNeeded];
}

//Create mutable array of medias
- (void)createMediaResource:(NSMutableArray *)mediaData ofType:(BOOL)isPhotos{

    @autoreleasepool {
    isComposingDone = FALSE;
    if([mediaData count] > 0) {
        NSString *mediaPath = isPhotos ? [[[mediaData objectAtIndex:0] valueForKey:@"IQMediaImage"] absoluteString]: [[[mediaData objectAtIndex:0] valueForKey:@"IQMediaAssetURL"] absoluteString];
        int count = isPhotos ? maxImage : maxVideo;
        int size = isPhotos ? maxImageFileSize : maxVideoFileSize;
        
        //1.Check media has valid Format
        if([[Util sharedInstance] checkMediaHasValidFormat:isPhotos ofMediaUrl:mediaPath]){
            
            //2.Check media has valid size
            [[Util sharedInstance] checkMediaHasValidSize:isPhotos ofMediaUrl:mediaPath withCallBack:^(NSData * data, UIImage * thumbnail){
                
                if(data != nil){
                    
                    //Check media exceed the length
                    if ([medias count] < count) {
                        
                        NSMutableDictionary *media = [[NSMutableDictionary alloc]init];
                        [media setObject:thumbnail forKey:@"mediaThumb"];
                        [media setObject:data forKey:@"assetData"];
                        [media setValue:[NSNumber  numberWithBool:isPhotos] forKey:@"mediaType"];
                        [media setObject:mediaPath forKey:@"mediaUrl"];
                        [media setObject:[NSNumber numberWithBool:NO] forKey:@"isCaptured"];
                        [medias addObject:media];
                        [self.mediaTable reloadData];
                        [mediaData removeObjectAtIndex:0];
                        [self createMediaResource:mediaData ofType:isPhotos];
                        
                    }
                    else{
                        if(isPhotos){
                            mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(IMAGE_ALLOWED, nil),count];
                            [mediaCountPopup show];
                        }
                        else{
                            mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(VIDEOS_ALLOWED, nil),count];
                            [mediaCountPopup show];
                        }
                        isComposingDone = TRUE;
                    }
                    
                    [self changeButtonStates:count mediaType:isPhotos];
                }
                else{
                    [mediaData removeObjectAtIndex:0];
                    if (!isMaxFileShown) {
                        mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(MEDIA_SIZE_SHOULD_BE, nil),size/1024];
                        [mediaCountPopup show];
                        isMaxFileShown = TRUE;
                    }
                    [self createMediaResource:mediaData ofType:isPhotos];
                }
            }];
            
        }
        else{
            [mediaData removeObjectAtIndex:0];
            [self createMediaResource:mediaData ofType:isPhotos];
        }
    }
    if ([mediaData count] == 0) {
        isComposingDone = TRUE;
    }
    }
}


//Create media based on source type
- (void) addCapturedMedia:(NSURL *)mediaURL ofType:(BOOL) isPhotos{
    
    int count = isPhotos ? maxImage : maxVideo;
    int size = isPhotos ? maxImageFileSize : maxVideoFileSize;
    
    
    //1.Check media has valid Format
    if([[Util sharedInstance] checkFileHasValidFormat:isPhotos ofMediaUrl:mediaURL.relativePath]){
        
        //2.Check media has valid size
        [[Util sharedInstance] checkFileHasValidSize:isPhotos ofMediaUrl:mediaURL.relativePath withCallBack:^(NSData * data, UIImage * thumbnail){
            
            if(data != nil){
                
                //Check media exceed the length
                if ([medias count] < count) {
                    
                    NSMutableDictionary *media = [[NSMutableDictionary alloc]init];
                    [media setObject:thumbnail forKey:@"mediaThumb"];
                    [media setObject:data forKey:@"assetData"];
                    [media setValue:[NSNumber  numberWithBool:isPhotos] forKey:@"mediaType"];
                    [media setObject:mediaURL forKey:@"mediaUrl"];
                    [media setObject:[NSNumber numberWithBool:YES] forKey:@"isCaptured"];
                    [medias addObject:media];
                    [self.mediaTable reloadData];
                }
                else{
                    mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(MEDIA_SIZE_ALLOWED, nil),count];
                    [mediaCountPopup show];
                }
                
                [self changeButtonStates:count mediaType:isPhotos];
                
            }
            else{
                if (!isMaxFileShown) {
                    mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(MEDIA_SIZE_SHOULD_BE, nil),size/1024];
                    [mediaCountPopup show];
                    isMaxFileShown = TRUE;
                }
            }
            
        }];
        
    }
    
}

- (void)changeButtonStates:(int)count mediaType:(BOOL)isPhotos{
    
    //Check button color
    if (count >= [medias count]) {
        
        //Disable add button
        if (isPhotos) {
            [self changeImageButton:YES];
            [_showVideoIcon setEnabled:NO];
        }
        else{
            [self changeVideoButton:YES];
            [_showImageButton setEnabled:NO];
        }
    }
    
}

#pragma mark - Tap Gesture

- (void)gestureLibraryHandlerMethod:(UITapGestureRecognizer*)sender {
    
    isVideoTapped = NO;

    [self onGalleryClick];
    
//    [self.view endEditing:YES];
//
//    AddPostViewController *aViewController = [AddPostViewController new];
//    aViewController.gIsPresentVideoClick = NO;
//    aViewController.gIsPresentLibrary = YES;
//
//    aViewController.myUpdateFilterBlock = ^void(BOOL isImageUpdate, UIImage* aImage, NSURL *videoUrl) {
//
//        if (isImageUpdate) {
//
//            [self loadCameraImageView:aImage];
//        }
//    };
//
//    [self.navigationController pushViewController:aViewController animated:YES];
}

- (void)gestureCameraHandlerMethod:(UITapGestureRecognizer*)sender {
    
    [self.view endEditing:YES];

    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusAuthorized) {
        
        AddPostViewController *aViewController = [AddPostViewController new];
        aViewController.gIsPresentVideoClick = NO;
        aViewController.gIsPresentLibrary = NO;
        
        aViewController.myUpdateFilterBlock = ^void(BOOL isImageUpdate, UIImage* aImage, NSURL *videoUrl) {
            
            if (isImageUpdate) {
                
                [self loadCameraImageView:aImage];
            }
            
            else {
                
                isCaptured = YES;
                if ([Util isVideoMinimumtwoMins:videoUrl]) {
                    [Util saveVideoToAlbum:videoUrl withCompletionBlock:^(PHAsset *asset) {
                        [self createMediaResource:@[videoUrl] forIndex:0 isPhoto:NO];
                    }];
                }
                else{
                    // Video should minimum 3sec
                    [[AlertMessage sharedInstance] showMessage:NSLocalizedString(VIDEO_DURATION, nil) withDuration:2.0];
                }
            }
        };
        
        [self.navigationController pushViewController:aViewController animated:YES];
        
        // do your logic
        //[self.navigationController pushViewController:aViewController animated:YES];
        
    } else if(authStatus == AVAuthorizationStatusDenied){
        
        // denied
        
        [[AlertMessage sharedInstance] showMessage:@"Please give Camera Access"];
        
    } else if(authStatus == AVAuthorizationStatusRestricted){
        
        // restricted, normally won't happen
        
        [[AlertMessage sharedInstance] showMessage:@"Please give Camera Access"];
        
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        
        // not determined?!
        
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            
            if(granted) {
                
//                AddPostViewController *aViewController = [AddPostViewController new];
//                aViewController.gIsPresentVideoClick = NO;
//                aViewController.gIsPresentLibrary = NO;
//                
//                aViewController.myUpdateFilterBlock = ^void(BOOL isImageUpdate, UIImage* aImage, NSURL *videoUrl) {
//                    
//                    if (isImageUpdate) {
//                        
//                        [self loadCameraImageView:aImage];
//                    }
//                    
//                    else {
//                        
//                        isCaptured = YES;
//                        if ([Util isVideoMinimumtwoMins:videoUrl]) {
//                            [Util saveVideoToAlbum:videoUrl withCompletionBlock:^(PHAsset *asset) {
//                                [self createMediaResource:@[videoUrl] forIndex:0 isPhoto:NO];
//                            }];
//                        }
//                        else{
//                            // Video should minimum 3sec
//                            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(VIDEO_DURATION, nil) withDuration:2.0];
//                        }
//                    }
//                };
//                
//                [self.navigationController pushViewController:aViewController animated:YES];
                
               // [self.navigationController pushViewController:aViewController animated:YES];
                
            } else {
                
                [[AlertMessage sharedInstance] showMessage:@"Please give Camera Access"];
            }
            
        }];
        
    } else {
        
        // impossible, unknown authorization status
    }
    
    
}

- (void)gestureVideoHandlerMethod:(UITapGestureRecognizer*)sender {
    
    [self.view endEditing:YES];
    
    isVideoTapped = YES;
    [self onGalleryClick];

//    AddPostViewController *aViewController = [AddPostViewController new];
//    aViewController.gIsPresentVideoClick = YES;
//    aViewController.gIsPresentLibrary = NO;
//
//    aViewController.myUpdateFilterBlock = ^void(BOOL isImageUpdate, UIImage* aImage, NSURL *videoUrl) {
//
//        if (isImageUpdate) {
//
//            [self loadCameraImageView:aImage];
//        }
//
//        else {
//
//            isCaptured = YES;
//            if ([Util isVideoMinimumtwoMins:videoUrl]) {
//
//                [Util saveVideoToAlbum:videoUrl withCompletionBlock:^(PHAsset *asset) {
//                    [self createMediaResource:@[videoUrl] forIndex:0 isPhoto:NO];
//                }];
//            }
//            else{
//                // Video should minimum 3sec
//                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(VIDEO_DURATION, nil) withDuration:2.0];
//            }
//        }
//    };
//
//    [self.navigationController pushViewController:aViewController animated:YES];
}

- (void)gestureCheckInHandlerMethod:(UITapGestureRecognizer*)sender {
    
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"])
    {
        CheckInViewController *baiduMap = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"CheckInViewController"];
        [self.navigationController pushViewController:baiduMap animated:YES];
    }
    else
    {
        [locationPopup show];
    }
}

#pragma mark HeaderViewDelegate
//- (void)backPressed {
//    [self discardPost];
//}

#pragma mark -  UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (isVideoTapped == YES) {

        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        if ([Util isVideoMinimumtwoMins:videoURL]) {

            [Util saveVideoToAlbum:videoURL withCompletionBlock:^(PHAsset *asset) {
                [self createMediaResource:@[videoURL] forIndex:0 isPhoto:NO];
            }];
        }
        else{
            // Video should minimum 3sec
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(VIDEO_DURATION, nil) withDuration:2.0];
        }
         [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
        editor.delegate = self;
        
        
        NSLog(@"%@", editor.toolInfo);
        NSLog(@"%@", editor.toolInfo.toolTreeDescription);
        
        //        CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:NO];
        //        tool.available = NO;
        
        CLImageToolInfo * tool = [editor.toolInfo subToolInfoWithToolName:@"CLSplashTool" recursive:YES];
        tool.available = NO;
        // tool.dockedNumber = -1;
        
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLFilterTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -12;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLStickerTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -11;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLEmoticonTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -10;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLTextTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -9;
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLDrawTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -8;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLAdjustmentTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -7;
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLEffectTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -6;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLBlurTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -5;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLRotateTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -4;
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLClippingTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -3;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLResizeTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -2;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:YES];
        tool.available = YES;
        tool.dockedNumber = -1;
        
        //[self presentViewController:editor animated:YES completion:nil];
        [picker pushViewController:editor animated:YES];

//        UIImage *capturedImage = info[UIImagePickerControllerOriginalImage];
//
//        //Save image in local
//        [Util saveImageToAlbum:capturedImage withCompletionBlock:^(PHAsset *asset) {
//            NSMutableArray *images = [[NSMutableArray alloc] init];
//            [images addObject:capturedImage];
//            [self createMediaResource:images forIndex:0 isPhoto:YES];
//        }];
    }

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark IQMediaPickerController

//Revceived the choosen assets from media library
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)mediaInfo;
{
    mediaAttachment = TRUE;
    [self setHeaderForCheckIn:YES];
    if (mediaInfo != nil && [[mediaInfo allKeys] count] > 0) {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:0];
        
        //Check image asset
        if([key isEqualToString:@"IQMediaTypeImage"]){
            
            //Assign images to array
            if (isCaptured) {
                [self createMediaResource:[mediaInfo objectForKey:key] ofType:TRUE];
            }
            else{
                isMaxFileShown = FALSE;
                [self createMediaResource:[mediaInfo objectForKey:key] ofType:TRUE];
            }
        }
        if([key isEqualToString:@"IQMediaTypeVideo"]){
            //Assign videos to array
           NSURL *selectedVideoUrl = [NSURL URLWithString:[[[[mediaInfo objectForKey:key] objectAtIndex:0] valueForKey:@"IQMediaAssetURL"] absoluteString]];
            
            if ([Util isVideoMinimumtwoMins:selectedVideoUrl]) {
                isMaxFileShown = FALSE;
                [self createMediaResource:[mediaInfo objectForKey:key] ofType:FALSE];
            }
            else
            {
                // Video should minimum 3sec
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(VIDEO_DURATION, nil) withDuration:2.0];
            }
        }
    }
    else{
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(IMAGE_NOT_CAPTURED, nil) withDuration:3.0];
    }
    
}

//


//- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller{
//
//     [self dismissViewControllerAnimated:YES completion:nil];
//
//}

- (IBAction)playVideo:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_mediaTable];
    NSIndexPath *path = [_mediaTable indexPathForRowAtPoint:buttonPosition];
    if([medias count] > path.section)
    {
//        NSDictionary *media = [medias objectAtIndex:path.section];
//        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[media valueForKey:@"mediaUrl"]]];
//        [self presentMoviePlayerViewControllerAnimated:player];
        
        NSDictionary *media = [medias objectAtIndex:path.section];
        PHAsset *asset = [media objectForKey:@"asset"];
        if (asset != nil) {
            [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
                    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
                    [controller setPlayer:player];
                    [self presentViewController:controller animated:YES completion:nil];
                });
            }];
        } else {
            NSURL *url = [NSURL URLWithString:[media objectForKey:@"mediaUrl"]];
            if (url != nil) {
                AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
                AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
                [controller setPlayer:player];
                [self presentViewController:controller animated:YES completion:nil];
            }
            
        }
    }
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    if(!tappedChat)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackPressed" object:nil];
        [self discardPost];
    }
    else{
//        [yesNoPopup dismiss:YES];
//        UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
//        
//        ViewController *viewController =[self.navigationController.viewControllers firstObject];
//        ChatHome *chatHome = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatHome"];
//        [navigation setViewControllers:@[viewController,chatHome]];
//        [UIApplication sharedApplication].delegate.window.rootViewController = navigation;
//        tappedChat = NO;
    }
}

- (void)onNoClick{
    tappedChat = NO;
    [yesNoPopup dismiss:YES];
}

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _mediaTable) {
        return [medias count];
    }else if(tableView == _contentTableView){
        return 1;
    }
    else{
        return 1;
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _mediaTable) {
        return 1;
    }else if(tableView == _contentTableView){
        return [autoCompleteFilterArray count];
    }
    else{
        return [recipients count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"recipientCell";
    cellIdentifier = tableView == _mediaTable ? @"mediaCell" : @"recipientCell";
        
//    if(tableView == _contentTableView){
//        cellIdentifier =  @"recipientCell";
//    }
//
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
//    cell.backgroundColor = [UIColor clearColor];
    
    if (tableView == _mediaTable) {
        
        //Media Cell
        UIImageView *image = (UIImageView *)[cell viewWithTag:10];
        UIButton *delete = (UIButton *)[cell viewWithTag:11];
        UIButton *play = (UIButton *)[cell viewWithTag:12];
        
        [self setRestrictChat];
        
        if([medias count] > indexPath.section)
        {
            NSDictionary *media = [medias objectAtIndex:indexPath.section];
            [play setHidden:YES];
           //  Image
            if([[media valueForKey:@"mediaType"] boolValue]){

                [[Util sharedInstance] addImageZoom:image];
                [_comment resignFirstResponder];
            }
            // Video
            else{
                [play setHidden:NO];
                [play addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            UIImage *img = [media objectForKey:@"mediaThumb"];
            NSString *dimen = [NSString stringWithFormat:@"%fX%f",img.size.width,img.size.height];
            CGSize size = [Util getAspectRatio:dimen ofParentWidth:self.view.frame.size.width - 20];
            image.image = img;
            image.clipsToBounds = YES;
            image.contentMode = UIViewContentModeScaleAspectFill;
            CGRect frame = image.frame;
            frame.size = size;
            image.frame = frame;
            
            [delete addTarget:self
                       action:@selector(askMediaDelete:)
             forControlEvents:UIControlEventTouchUpInside];
            
            [cell setNeedsLayout];
        }
        
    }else if(tableView == _contentTableView){
        
        NameTagTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([NameTagTableViewCell class])];

        if( autoCompleteFilterArray.count > 0){
        
        NSDictionary * value = [autoCompleteFilterArray objectAtIndex:indexPath.row];
        
     //   UIImageView *icon = (UIImageView *)[cell viewWithTag:10];
    //    UILabel *name =  (UILabel *)[cell viewWithTag:11];
        
     //  name.text = [NSString stringWithFormat:@"%@",value[@"name"]];
          aCell.lblName.text = [NSString stringWithFormat:@"%@",value[@"name"]];
        
//        cell.contentView.backgroundColor = [UIColor whiteColor];
//        cell.backgroundColor = [UIColor clearColor];
        
        [aCell.profileImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://dqloq8l38fi51.cloudfront.net%@",value[@"profile_image"]]] placeholderImage:nil];
        
      //  UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 20)];/// change size as you need.
       // separatorLineView.backgroundColor = [UIColor clearColor];// you can also put image here
       // [cell.contentView addSubview:separatorLineView];
        }
        
        return aCell;
        
    }else{
        //Reciepients cell
        //Read elements
        UIImageView *icon = (UIImageView *)[cell viewWithTag:10];
        UILabel *name =  (UILabel *)[cell viewWithTag:11];
        
        if([recipients count] > indexPath.row)
        {
            NSDictionary *recepient = [recipients objectAtIndex:indexPath.row];
            int postType = (int)[[recepient valueForKey:@"feed_type"] integerValue];
            
            [icon setImage:[UIImage imageNamed:[postTypeIcons objectAtIndex:postType]]];
            name.text = [recepient valueForKey:@"type"];
        }
    }
        
    return cell;
    
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    @autoreleasepool {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

//Add space betweem cell
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}




//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _mediaTable) {
        
    }else if(tableView == _contentTableView){
        
        isSelectNameTag = YES;
         NSDictionary * value = [autoCompleteFilterArray objectAtIndex:indexPath.row];
        
//         NSString *trimString = [value[@"name"] stringByReplacingOccurrencesOfString:@" " withString:@""];
//        _comment.text =  [NSString stringWithFormat:@"%@%@",_comment.text,trimString];
         [self.view endEditing:YES];
        
        NSString *aStrCallOuts = [value[@"name"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [_selectedArray addObject:[NSString stringWithFormat:@"%@%@", myStrCallOutText, aStrCallOuts]];
        //_comment.text = [_selectedArray componentsJoinedByString:@" "];
        
       // _temp = [_selectedArray componentsJoinedByString:@" "];
        
       // [_selectedArray removeAllObjects];
        
     
        
        _comment.text = [_selectedArray componentsJoinedByString:@" "];
        
        // [_selectedArray addObject:[NSString stringWithFormat:@"%@%@", myStrCallOutText, aStrCallOuts]];
        
      //  if([autoCompleteFilterArray containsObject:aStrCallOuts]){
       // [_selectedArray addObject:[NSString stringWithFormat:@"%@%@", myStrCallOutText, aStrCallOuts]];
       // }
        
        
       // _comment.text = [NSString stringWithFormat:@"%@%@", myStrCallOutText, aStrCallOuts];
        NSString *text = _comment.text;
        
        NSRange selectedRange = _comment.selectedRange;
        
        // This will give me an attributedString with the base text-style
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        
        NSError *error = nil;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
        
        NSArray *matches = [regex matchesInString:text
                                          options:0
                                            range:NSMakeRange(0, text.length)];
        
        for (NSTextCheckingResult *match in matches)
        {
            
            NSRange matchRange = [match rangeAtIndex:0];
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor redColor]
                                     range:matchRange];
            
           
        }
        
       
        
        _comment.attributedText = attributedString;
        _comment.selectedRange = selectedRange;
        _comment.scrollEnabled = YES;
    }
    else{
        selectedIndex = (int) indexPath.row;
        if([recipients count] > indexPath.row)
        {
            selectedRecepie = [recipients objectAtIndex:indexPath.row];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [recipientPopup dismiss:YES];
            [self displayToFilds:selectedRecepie];
        }
    }
}

#pragma mark - GMImagePicker delegates

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu %@", (unsigned long)assetArray.count, assetArray);
    
    mediaAttachment = TRUE;
    [self setHeaderForCheckIn:YES];
    
    if (assetArray.count > 0) {
        PHAsset *asset = [assetArray firstObject];
        // if image type
        if (asset.mediaType == PHAssetMediaTypeImage) {
            [self createMediaResource:assetArray forIndex:0 isPhoto:YES];
        }
        else if (asset.mediaType == PHAssetMediaTypeVideo) {
            
            // Check duration
            if (asset.duration > 2) {
                isMaxFileShown = NO;
                // Go ahead get the asset url instead
                [self createMediaResource:assetArray forIndex:0 isPhoto:NO];
            } else {
                // Video should minimum 3sec
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(VIDEO_DURATION, nil) withDuration:2.0];
            }
        }
    }
    else {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(IMAGE_NOT_CAPTURED, nil) withDuration:3.0];
    }
}

- (BOOL)checkMediaCount:(BOOL)isPhoto {
    
    int maxCount = isPhoto ? maxImage : maxVideo;
    int maxSize = isPhoto ? maxImageFileSize : maxVideoFileSize;

    if ([medias count] < maxCount) {
        return YES;
    } else {
        if(isPhoto){
            mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(IMAGE_ALLOWED, nil), maxCount];
            [mediaCountPopup show];
        }
        else{
            mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(VIDEOS_ALLOWED, nil), maxCount];
            [mediaCountPopup show];
        }
        isComposingDone = YES;
        
        return NO;
    }
}

- (NSMutableDictionary *)handleImageAsset:(UIImage *)image isCaptured:(BOOL)isCaptured {
    
    if ([self checkMediaCount:YES]) {
        
        NSMutableDictionary *media = [[NSMutableDictionary alloc] init];
        
        UIImage *resizedImage = [Util resizeTheImage:image];
        NSData *mediaData = UIImageJPEGRepresentation(resizedImage, 0.75);
        UIImage *thumbnail = [Util imageWithImage:image scaledToWidth:self.view.frame.size.width];
        [media setObject:mediaData forKey:@"assetData"];
        //                NSString *mediaPath = [[info objectForKey:@"PHImageFileURLKey"] lastPathComponent];
        [media setObject:@"capturedImage.jpg" forKey:@"mediaUrl"];
        
        [media setObject:thumbnail forKey:@"mediaThumb"];
        [media setValue:[NSNumber numberWithBool:YES] forKey:@"mediaType"];
        [media setObject:[NSNumber numberWithBool:isCaptured] forKey:@"isCaptured"];
        [medias addObject:media];
        
        return media;
    }
    
    return nil;
}

- (void)handleVideoURL:(NSURL *)url isCaptured:(BOOL)isCaptured {
    if ([self checkMediaCount:YES]) {
        NSMutableDictionary *media = [[NSMutableDictionary alloc] init];
        UIImage *thumbnail = [[Util sharedInstance] getThumbFromVideo:[url absoluteString]];
        [media setObject:[url dataRepresentation] forKey:@"mediaData"];
        [media setObject:[url absoluteString] forKey:@"mediaUrl"];
//        [mediaUrl dataUsingEncoding:NSUTF8StringEncoding];
        [media setObject:thumbnail forKey:@"mediaThumb"];
        [media setValue:[NSNumber numberWithBool:NO] forKey:@"mediaType"];
        [media setObject:[NSNumber numberWithBool:isCaptured] forKey:@"isCaptured"];
        [medias addObject:media];
    }
}

- (void)createMediaResource:(NSArray *)mediaAssets forIndex:(int)index isPhoto:(BOOL)isPhoto {
    isComposingDone = NO;
    if (mediaAssets.count > 0) {
        int maxCount = isPhoto ? maxImage : maxVideo;
        int maxSize = isPhoto ? maxImageFileSize : maxVideoFileSize;
        
        // Check size and format, then get data
        // Thumbnail or Fullsize
        int imageSize = isPhoto ? RESIZE_LEVEL_TWO : self.view.frame.size.width;
        
        if (isCaptured) {
            if (isPhoto) {
                UIImage *result = [mediaAssets objectAtIndex:index];
                [self handleImageAsset:result isCaptured:YES];
            }
            else {
                NSURL *assetUrl = [mediaAssets objectAtIndex:index];
                [self handleVideoURL:assetUrl isCaptured:YES];
            }
        
            if ([mediaAssets count] > index + 1) {
                [self createMediaResource:mediaAssets forIndex:index + 1 isPhoto:isPhoto];
            } else {
                [self.mediaTable reloadData];
                isComposingDone = YES;
            }
        } else {
            
            PHAsset *asset = [mediaAssets objectAtIndex:index];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.networkAccessAllowed = YES;
            
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(imageSize, imageSize) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                if (result != nil || !isPhoto) {
                    // Check number of assets
                    if ([self checkMediaCount:isPhoto]) {
                        
//                        NSMutableDictionary *media;

                        if (isPhoto) {
                            NSMutableDictionary *media = [self handleImageAsset:result isCaptured:NO];
                            
//                            NSData *mediaData = UIImageJPEGRepresentation(result, 0.75);
//                            thumbnail = [Util imageWithImage:result scaledToWidth:self.view.frame.size.width];
//                            [media setObject:mediaData forKey:@"assetData"];
                            if (media) {
                                NSString *mediaPath = [[info objectForKey:@"PHImageFileURLKey"] lastPathComponent];
                                [media setObject:mediaPath forKey:@"mediaUrl"];
                            }
                        }
                        else {
//                            if (result == nil) {
//                                NSURL *url = (NSURL *)[(AVURLAsset *)asset URL];
//                                result = [[Util sharedInstance] getThumbFromVideo:[url absoluteString]];
//                            }
                            // Add the PHAsset to the dict, to be used later
                            NSMutableDictionary *media = [[NSMutableDictionary alloc] init];
                            if (result != nil) {
                                UIImage *thumbnail = result;
                                [media setObject:thumbnail forKey:@"mediaThumb"];
                            }
                            [media setObject:asset forKey:@"asset"];
                            [media setValue:[NSNumber numberWithBool:isPhoto] forKey:@"mediaType"];
                            [media setObject:[NSNumber numberWithBool:NO] forKey:@"isCaptured"];
                            [medias addObject:media];
                        }

                        [self changeButtonStates:maxCount mediaType:isPhoto];
                    }
                }
                
                //                    // Check filesize
                //                    if (!isMaxFileShown) {
                //                        mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(MEDIA_SIZE_SHOULD_BE, nil), maxSize/1024];
                //                        [mediaCountPopup show];
                //                        isMaxFileShown = YES;
                //                    }

                if ([mediaAssets count] > index + 1) {
                    [self createMediaResource:mediaAssets forIndex:index + 1 isPhoto:isPhoto];
                } else {
                    [self.mediaTable reloadData];
                    isComposingDone = YES;
                }
            }];
        }
    }
}

#pragma mark - MediaPopup delegates
-(void)onCameraClick{
    
    isCaptured = YES;
    
    [mediaPopupView setHidden:YES];
    [mediaPopup dismiss:YES];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (isVideoTapped == YES)
    {
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    } else {
    }
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    /*[mediaPickerController setMediaType:IQMediaPickerControllerMediaTypePhoto];
    mediaPickerController.allowsPickingMultipleItems = TRUE;
    [self presentViewController:mediaPickerController animated:YES completion:nil];*/
}

-(void)onGalleryClick{
    GMImagePickerController *imagePicker = [[GMImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.autoSelectCameraImages = YES;

    [mediaPopup dismiss:YES];
    if (isVideoTapped == YES) {
        imagePicker.mediaTypes = @[@(PHAssetMediaTypeVideo)];
        imagePicker.allowsMultipleSelection = NO;
        isPhotoFilter = NO;
//        IQMediaPickerController *mediaPickerController = [[IQMediaPickerController alloc] init];
//        mediaPickerController.delegate = self;
//        [mediaPickerController setMediaType:IQMediaPickerControllerMediaTypeVideoLibrary];
//        mediaPickerController.allowsPickingMultipleItems = FALSE;
//        [self presentViewController:mediaPickerController animated:YES completion:nil];
//        isCaptured = NO;
//        return;
    }
    else
    {
        imagePicker.mediaTypes = @[@(PHAssetMediaTypeImage)];
        imagePicker.allowsMultipleSelection = YES;
        imagePicker.showCameraButton = YES;
        isPhotoFilter = YES;
    }
    isCaptured = NO;
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        if (isPhotoFilter == true)
        {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.allowsEditing = NO;
                picker.delegate   = self;
            
                [self presentViewController:picker animated:YES completion:nil];
            
        }
        else
        {
        [self presentViewController:imagePicker animated:YES completion:nil];
        }
       

    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) {
        UIAlertController *alert = [Util createSettingsAlertWithTitle:SETTINGS_TITLE andMessage:GALLERY_ALERT];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
       //         [self presentViewController:imagePicker animated:YES completion:nil];
                if (isPhotoFilter == true)
                {
                    
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.allowsEditing = NO;
                        picker.delegate   = self;
                    
                        [self presentViewController:picker animated:YES completion:nil];
                }
                else
                {
                    [self presentViewController:imagePicker animated:YES completion:nil];
                }
            }
        }];
    }
    
}



- (void)onOkClick{
    [mediaPopup dismiss:YES];
}


//Change to filed
- (void)displayToFilds:(NSMutableDictionary *)to{
    UIImage *icon = [UIImage imageNamed:[postTypeIcons objectAtIndex:[[to valueForKey:@"feed_type"] integerValue]]];
    _toIcon.tintColor = [UIColor darkGrayColor];
    [_toIcon setImage:[icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];

    _toLabel.text = [to valueForKey:@"type"];
    
    //Set privacy type
    [_inputParams setValue:[NSNumber numberWithInt:[[to valueForKey:@"id"] intValue]] forKey:@"post_type_id"];
    if ([[to valueForKey:@"feed_type"] integerValue] == 4) {
        [_inputParams setValue:[NSNumber numberWithBool:YES] forKey:@"team_post"];
    }
    else{
        [_inputParams setValue:[NSNumber numberWithBool:false] forKey:@"team_post"];
    }
}

// Build Input Params for Local
-(NSMutableDictionary *)buildParams :(NSMutableDictionary *)values
{
    NSMutableDictionary *checkinDetails = [[NSMutableDictionary alloc]init];
    NSMutableArray * checkin = [[NSMutableArray alloc]init];
    NSMutableArray *image = [[NSMutableArray alloc]init];
    NSMutableArray *video = [[NSMutableArray alloc]init];
    NSMutableArray *linkArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *linkDict = [[NSMutableDictionary alloc] init];
    NSString *userName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"]];
    
    NSMutableDictionary *posterProfileImage = [[NSMutableDictionary alloc]init];
    [posterProfileImage setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"player_image"] forKey:@"profile_image"];
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    
    if ([medias count] > 0) {
        
        // assign videos and images
        for (int i = 0; i <[medias count]; i++) {
            NSMutableDictionary *mediaDict = [[NSMutableDictionary alloc]init];
            [mediaDict setValue:@"0" forKey:@"comments_count"];
            [mediaDict setValue:@"" forKey:@"image_id"];
            if(i == 0){
                UIImage *postImage = [[medias objectAtIndex:0] valueForKey:@"mediaThumb"];
                NSString *dimension = [NSString stringWithFormat:@"%fX%f",postImage.size.width,postImage.size.height];
                [mediaDict setValue:dimension forKey:@"media_dimension"];
            }
            [mediaDict setValue:@"" forKey:@"media_url"];
            [mediaDict setValue:@"0" forKey:@"star_status"];
            [mediaDict setValue:@"0" forKey:@"stars_count"];
            // If image
            if ([[[medias objectAtIndex:i] objectForKey:@"mediaType"] boolValue]) {
                [image addObject:mediaDict];
            }
            else{
                [video addObject:mediaDict];
            }
        }
    }
    NSString *imageCount = [NSString stringWithFormat:@"%lu",(unsigned long)[image count]];
    NSString *videoCount = [NSString stringWithFormat:@"%lu",(unsigned long)[video count]];
    NSString *videoPresent = ([videoCount intValue] == 0)? @"0" : @"1";
    NSString *imagePresent = ([imageCount intValue] == 0)? @"0" : @"1";
    
    // Check checkin present
    if (![[_inputParams valueForKey:@"check_in_name"] isEqualToString:@""]) {
        [checkinDetails setValue:[values objectForKey:@"check_in_city"] forKey:@"city"];
        [checkinDetails setValue:[values objectForKey:@"check_in_country"] forKey:@"country"];
        [checkinDetails setValue:[values objectForKey:@"check_in_latitude"] forKey:@"latitude"];
        [checkinDetails setValue:[values objectForKey:@"check_in_longitude"] forKey:@"longitude"];
        [checkinDetails setValue:[values objectForKey:@"check_in_name"] forKey:@"name"];
        [checkinDetails setValue:[values objectForKey:@"check_in_state"] forKey:@"state"];
        [checkin addObject:checkinDetails];
    }
    
    NSString *strContinueRading = ([[values objectForKey:@"text"] length] > 256)? @"1"  :  @"0";
    
    // Build Input params
    NSMutableDictionary *inputparams = [[NSMutableDictionary alloc]init];
    [inputparams setValue:@"1" forKey:@"am_owner"];
    [inputparams setValue:checkin forKey:@"check_in_details"];
    [inputparams setValue:@"0" forKey:@"comments_count"];
    [inputparams setValue:strContinueRading forKey:@"continue_reading_flag"];
    [inputparams setValue:image forKey:@"image"];
    [inputparams setValue:imageCount forKey:@"image_count"];
    [inputparams setValue:imagePresent forKey:@"image_present"];
    [inputparams setValue:userName forKey:@"name"];
    [inputparams setValue:[values objectForKey:@"text"] forKey:@"post_content"];
    [inputparams setValue:@"" forKey:@"post_description"];
    [inputparams setValue:@"" forKey:@"post_id"];
    [inputparams setValue:posterProfileImage forKey:@"posters_profile_image"];
    [inputparams setValue:[values objectForKey:@"post_type_id"] forKey:@"privacy_type"];
    [inputparams setValue:@"0" forKey:@"star_status"];
    [inputparams setValue:@"0" forKey:@"stars_count"];
    [inputparams setValue:timestamp forKey:@"time_stamp"];
    [inputparams setValue:video forKey:@"video"];
    [inputparams setValue:videoCount forKey:@"video_count"];
    [inputparams setValue:videoPresent forKey:@"video_present"];
    
    [inputparams setValue:medias forKey:@"is_media"];
    [inputparams setValue:@"true" forKey:@"is_local"];
    [inputparams setValue:@"false" forKey:@"is_upload"];
    
    if(isUrlPreviewShown){
        [linkDict setValue:previewURL forKey:@"link"];
        [linkDict setValue:_urlPreview.title.text forKey:@"link_title"];
        [linkDict setValue:_urlPreview.siteDescription.text forKey:@"link_description"];
        [linkDict setValue:_urlPreview.imageUrl forKey:@"link_image_url"];
        [linkDict setValue:_urlPreview.siteName.text forKey:@"link_sitename"];
        [linkArray addObject:linkDict];
        [inputparams setValue:linkArray forKey:@"link_details"];
    }
    else{
        [inputparams setValue:linkArray forKey:@"link_details"];
    }
    
    return inputparams;
}

// Validate Image and Video is an less than 13 MB
-(BOOL)ValidateFileSize
{
   return TRUE;
}

// If feed post from Buzzard Run Page add teo params -> 1. buzzard_run_event_id 2. buzzard_run_id
-(BOOL)isBuzzardRunPost
{
    if ([_postFromBuzzardRun isEqualToString:@"yes"]) {
        
        _toLabel.text = _buzzardRunName;
        _dropDownIcon.hidden = YES;
        
        return TRUE;
    }
    return FALSE;
}

-(void)isPostFromTeamPage
{
    if (_isPostFromTeam != nil) {
        
        int getIndex = [Util getMatchedObjectPosition:@"type" valueToMatch:_isPostFromTeam from:recipients type:0];
        if (getIndex != -1) {
            selectedIndex = getIndex;
            selectedRecepie = [recipients objectAtIndex:getIndex];
            [recipientPopup dismiss:YES];
            [self displayToFilds:selectedRecepie];
        }
        
    }
}

-(void)isPostFromFeedPage
{
    if(_isPostFromFeeds != nil)
    {
        int getIndex;
        if ([_isPostFromFeeds intValue] == 1) {
            getIndex = 2;
        }
        else if ([_isPostFromFeeds intValue] == 2) {
            getIndex = 1;
        }
        else if ([_isPostFromFeeds intValue] == 6) {
            getIndex = 0;
        }
        else{
            getIndex = [Util getMatchedObjectPosition:@"type" valueToMatch:_isPostFromFeeds from:recipients type:0];
        }
        
        selectedIndex = getIndex;
        selectedRecepie = [recipients objectAtIndex:getIndex];
        [recipientPopup dismiss:YES];
        [self displayToFilds:selectedRecepie];
        
    }
}
-(void)setRestrictChat{
     if ([medias count] != 0 || [[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0 || hasCheckin || isUrlPreviewShown)
     {
         _headerView.restrictChat = TRUE;
     }
    else
    {
        _headerView.restrictChat = FALSE;
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
//    [self.comment resignFirstResponder];
//    self.comment.inputView = emojiKeyboardView;
//    [self.comment becomeFirstResponder];
}

-(void)showNormalKeyboard
{
    [self.comment resignFirstResponder];
    self.comment.inputView = nil;
    [self.comment becomeFirstResponder];
}

// Emoji Delegate

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    if ([self.comment.text length] < 1000 && [self.comment.text length] != 999) {
        //self.comment.text = [self.comment.text stringByAppendingString:emoji];
        [self.comment replaceRange:self.comment.selectedTextRange withText:emoji];
    }
}

// Clear text from Emoji keyboard
- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.comment deleteBackward];
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
-(void)checkForURL:(NSString*)string{
    if(!isUrlPreviewShown && firstPreview){
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [linkDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];
                previewURL = [url absoluteString];
                [_urlPreview loadWithUrl:[url absoluteString]];
                _urlPreviewHeight.constant = 70;
                isUrlPreviewShown = TRUE;
                [_urlPreview setHidden:NO];
                [self setHeaderForCheckIn:NO];
                
                break;
            }
        }
    }
}
-(void)setUrlPreview{
    firstPreview = FALSE;
    [_inputParams setValue:previewURL forKey:@"link"];
    [_inputParams setValue:_urlPreview.title.text forKey:@"link_title"];
    [_inputParams setValue:_urlPreview.siteDescription.text forKey:@"link_description"];
    [_inputParams setValue:_urlPreview.imageUrl forKey:@"link_image_url"];
    [_inputParams setValue:_urlPreview.siteName.text forKey:@"link_sitename"];
}
-(void)hidePreview{
    if([_comment.text length] == 0)
        firstPreview = TRUE;
    _urlPreviewHeight.constant = 0;
    isUrlPreviewShown = FALSE;
    [_urlPreview setHidden:YES];
    [self setHeaderForCheckIn:NO];
}

-(void)tappedClosePreview{
    if([_comment.text length] == 0)
        firstPreview = TRUE;
    [_inputParams setValue:@"" forKey:@"link"];
    [_inputParams setValue:@"" forKey:@"link_title"];
    [_inputParams setValue:@"" forKey:@"link_description"];
    [_inputParams setValue:@"" forKey:@"link_image_url"];
    [_inputParams setValue:@"" forKey:@"link_sitename"];
    _urlPreviewHeight.constant = 0;
    isUrlPreviewShown = FALSE;
    [_urlPreview setHidden:YES];
    [self setHeaderForCheckIn:NO];
}

-(void)setHeaderForCheckIn:(BOOL)forCheckIn{
    float height  = 0;
    
    if(forCheckIn)
        height = (hasCheckin)? height + 40  : height - 40;
    else
        height = (isUrlPreviewShown)? height+ 70 : height - 70;
    if(mediaAttachment)
        height = (hasCheckin)? height - 40 : height + 40;

    CGRect rect = _composeView.frame;
    rect.size.height = rect.size.height + height;
    _composeView.frame = rect;
    [_mediaTable setTableHeaderView:_composeView];
    [_mediaTable reloadData];
}

#pragma mark - Upload methods

- (void)post:(NSMutableDictionary *)inputparams Media:(NSMutableArray *)medias feedType:(int)type {
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [inputparams setObject:UUID forKey:@"unique_id"];
    
    self.dimView.hidden = NO;
    self.spinnerView.hidden = NO;
    [self.spinnerView startAnimating];
    self.spinnerProgressView.hidden = YES;
    
    //Check is the video request
    //If so, compress the video, else send the request
    if ([medias count] > 0 && ![[[medias objectAtIndex:0] valueForKey:@"isCaptured"] boolValue] && ![[[medias objectAtIndex:0] valueForKey:@"mediaType"] boolValue]) {
        NSMutableDictionary *media = [medias objectAtIndex:0];
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        NSNumber *mediaSize = [config objectForKey:@"default_video_size"];
        
        // Using Photos library
        PHAsset *asset = [media valueForKey:@"asset"];
        if (asset != nil) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.deliveryMode = PHVideoRequestOptionsVersionCurrent;
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
                if (asset != nil) {
                    NSURL *url = (NSURL *)[(AVURLAsset *)asset URL];
                    [Util compressVideo:url withCallback:^(NSURL * outputURL) {
                        NSData *mediaData = [NSData dataWithContentsOfURL:outputURL];
                        NSLog(@"Video compressed %ld url: %@", [mediaData length], outputURL);
                        [media setObject:[outputURL absoluteString] forKey:@"mediaUrl"];
                        [media setObject:mediaData forKey:@"assetData"];
                        [self uploadPost:inputparams Media:medias feedType:type];
                    }];
                } else {
                    NSLog(@"No Asset %@", info);
                }
            }];
        }
        
        // Captured media is a url
    } else if ([medias count] > 0 && [[[medias objectAtIndex:0] valueForKey:@"isCaptured"] boolValue] && ![[[medias objectAtIndex:0] valueForKey:@"mediaType"] boolValue]) {
        NSMutableDictionary *media = [medias objectAtIndex:0];
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
//        NSNumber *mediaSize = [config objectForKey:@"default_video_size"];
        NSURL *url = [NSURL URLWithString:[media valueForKey:@"mediaUrl"]];
//        NSLog(@"NSURL %@", url);
        [Util compressVideo:url withCallback:^(NSURL *outputURL) {
            NSData *assetData = [NSData dataWithContentsOfURL:outputURL];
            [media setObject:assetData forKey:@"assetData"];
            [media setObject:[outputURL absoluteString] forKey:@"mediaUrl"];
            [self uploadPost:inputparams Media:medias feedType:type];
        }];
    }
    else{
        [self uploadPost:inputparams Media:medias feedType:type];
    }
}

- (void)uploadPost:(NSMutableDictionary *)inputparams Media:(NSMutableArray *)medias feedType:(int)type {
    if(!appDelegate.postInProgress){
        appDelegate.postInProgress = YES;
        NSLog(@"post format %@", inputparams);
        
        task = [[Util sharedInstance] sendHTTPPostRequestWithMultiPart:inputparams withMultiPart:medias withRequestUrl:POST_CREATE withImage:nil withCallBack:^(NSDictionary  *response) {

            appDelegate.postInProgress = NO;
            if([[response valueForKey:@"status"] boolValue]){
                if ([self.delegate respondsToSelector:@selector(newPostWasPosted:)]) {
                    [self.delegate newPostWasPosted:type];
                }
            }
            else if([[response valueForKey:@"error"] isEqualToString:@"time_out"])
            {
                NSLog(@"Posting failed %d", type);
                // Time Out Error
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(TRY_AGAIN_STRING, nil)];
                
                [self.spinnerView stopAnimating];
                self.dimView.hidden = YES;

            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }

        } onProgressView:nil isFromBuzzardRun:FALSE];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.spinnerView.hidden = YES;
            [self.spinnerView stopAnimating];
            self.spinnerProgressView.hidden = NO;
        });
        
        // Showing progrss while uploading feeds
        [[Util sharedInstance].dataTaskManager setTaskDidSendBodyDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                double percentDone = (totalBytesSent / (totalBytesExpectedToSend * 1.0f));
                
                if (percentDone == 1) {
                    self.spinnerView.hidden = NO;
                    [self.spinnerView startAnimating];
                    self.spinnerProgressView.hidden = YES;
                } else {
                    self.spinnerProgressView.value = percentDone;
                }
                
            });
        }];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)pushedNewBtn
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view.window];
}

- (void)pushedEditBtn
{
    if(_imageView.image){
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:_imageView.image delegate:self];
        //CLImageEditor *editor = [[CLImageEditor alloc] initWithDelegate:self];
        
        /*
         NSLog(@"%@", editor.toolInfo);
         NSLog(@"%@", editor.toolInfo.toolTreeDescription);
         
         CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:NO];
         tool.available = NO;
         
         tool = [editor.toolInfo subToolInfoWithToolName:@"CLRotateTool" recursive:YES];
         tool.available = NO;
         
         tool = [editor.toolInfo subToolInfoWithToolName:@"CLHueEffect" recursive:YES];
         tool.available = NO;
         */
        
        [self presentViewController:editor animated:YES completion:nil];
        //[editor showInViewController:self withImageView:_imageView];
    }
    else{
        [self pushedNewBtn];
    }
}

- (void)pushedSaveBtn
{
    if(_imageView.image){
        NSArray *excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage];
        
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[_imageView.image] applicationActivities:nil];
        
        activityView.excludedActivityTypes = excludedActivityTypes;
        activityView.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if(completed && [activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Saved successfully" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        };
        
        [self presentViewController:activityView animated:YES completion:nil];
    }
    else{
        [self pushedNewBtn];
    }
}

#pragma mark- ImagePicker delegate

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//
//    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
//    editor.delegate = self;
//
//    [picker pushViewController:editor animated:YES];
//}
/*
 - (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
 {
 if([navigationController isKindOfClass:[UIImagePickerController class]] && [viewController isKindOfClass:[CLImageEditor class]]){
 viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonDidPush:)];
 }
 }
 
 - (void)cancelButtonDidPush:(id)sender
 {
 [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
 }
 */
#pragma mark- CLImageEditor delegate
-(void) getPHAssetWithIdentifier:(NSString *) localIdentifier andSuccessBlock:(void (^)(id asset))successBlock failure:(void (^)(NSError *))failureBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *identifiers = [[NSArray alloc] initWithObjects:localIdentifier, nil];
        PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
        if(savedAssets.count>0)
        {
            successBlock(savedAssets[0]);
        }
        else
        {
            NSError *error;
            failureBlock(error);
        }
    });
}

- (void)imageEditor:(CLImageEditor *)editor didFinishEditingWithImage:(UIImage *)image
{
    _imageView.image = image;
    [self refreshImageView];
    
//    self.assets = [NSMutableArray arrayWithArray:assets];
//    PHImageManager *manager = [PHImageManager defaultManager];
//    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[assets count]];
//    
//    // assets contains PHAsset objects.
//    __block UIImage *ima;
//    
//    for (PHAsset *asset in self.assets) {
//        // Do something with the asset
//        
//        [manager requestImageForAsset:asset
//                           targetSize:PHImageManagerMaximumSize
//                          contentMode:PHImageContentModeDefault
//                              options:self.requestOptions
//                        resultHandler:^void(UIImage *image, NSDictionary *info) {
//                            ima = image;
//                            
//                            [images addObject:ima];
//                        }];
//        
//        
//    }
  //  [self createMediaResource:assetArray forIndex:0 isPhoto:YES];
    NSMutableDictionary *media = [[NSMutableDictionary alloc] init];

    UIImage *resizedImage = [Util resizeTheImage:image];
    NSData *mediaData = UIImageJPEGRepresentation(resizedImage, 0.75);
    UIImage *thumbnail = [Util imageWithImage:image scaledToWidth:self.view.frame.size.width];
    [media setObject:mediaData forKey:@"assetData"];
    //                NSString *mediaPath = [[info objectForKey:@"PHImageFileURLKey"] lastPathComponent];
    [media setObject:@"capturedImage.jpg" forKey:@"mediaUrl"];
    
    [media setObject:thumbnail forKey:@"mediaThumb"];
    [media setValue:[NSNumber numberWithBool:YES] forKey:@"mediaType"];
    [media setObject:[NSNumber numberWithBool:isCaptured] forKey:@"isCaptured"];
    
    [medias addObject:media];
    [self.mediaTable reloadData];
    
    [editor.navigationController popViewControllerAnimated:YES];
    
    //self.navigationController.navigationItem.hidesBackButton = NO;
    
//    [editor dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
//        /* do something when the animation is completed */
//
//    }];
}

- (void)imageEditor:(CLImageEditor *)editor willDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled
{
    [self refreshImageView];
}

#pragma mark- Tapbar delegate

- (void)deselectTabBarItem:(UITabBar*)tabBar
{
    tabBar.selectedItem = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self performSelector:@selector(deselectTabBarItem:) withObject:tabBar afterDelay:0.2];
    
    switch (item.tag) {
        case 0:
            [self pushedNewBtn];
            break;
        case 1:
            [self pushedEditBtn];
            break;
        case 2:
            [self pushedSaveBtn];
            break;
        default:
            break;
    }
}

#pragma mark- Actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==actionSheet.cancelButtonIndex){
        return;
    }
    
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:type]){
        if(buttonIndex==0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            type = UIImagePickerControllerSourceTypeCamera;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = NO;
        picker.delegate   = self;
        picker.sourceType = type;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark- ScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView.superview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.superview.frame.size.width;
    CGFloat H = _imageView.superview.frame.size.height;
    
    CGRect rct = _imageView.superview.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.superview.frame = rct;
}

- (void)resetImageViewFrame
{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    _imageView.frame = CGRectMake(0, 0, W, H);
    _imageView.superview.bounds = _imageView.bounds;
}

- (void)resetZoomScaleWithAnimate:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
}

- (void)refreshImageView
{
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimate:NO];
}

- (void)loadCameraImageView:(UIImage *)aImage {
    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:aImage];
    editor.delegate = self;
    

    
    //        CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:NO];
    //        tool.available = NO;
    
    CLImageToolInfo * tool = [editor.toolInfo subToolInfoWithToolName:@"CLSplashTool" recursive:YES];
    tool.available = NO;
    // tool.dockedNumber = -1;
    
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLFilterTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -12;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLStickerTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -11;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLEmoticonTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -10;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLTextTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -9;
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLDrawTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -8;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLAdjustmentTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -7;
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLEffectTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -6;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLBlurTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -5;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLRotateTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -4;
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLClippingTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -3;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLResizeTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -2;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:YES];
    tool.available = YES;
    tool.dockedNumber = -1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        for (UIViewController *vc in [self.navigationController viewControllers]) {
            
            if ([vc isKindOfClass: [CreatePostViewController class]]) {
                
                if(vc.isViewLoaded){
                    
                    [vc presentViewController:editor animated:YES completion:nil];
                    //[vc.navigationController pushViewController:editor animated:YES];
                    
                    NSLog(@"Yes");
                }
            }
        }
    });
    
    
    //[self presentViewController:editor animated:YES completion:nil];
    //[self.navigationController pushViewController:editor animated:YES];
    
   // [APPDELEGATE.window.rootViewController presentViewController:editor animated:true completion:nil];
}

-(void)getfriendsList{
    
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    
        task = [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:FRIENDS_LIST withCallBack:^(NSDictionary * response){
            
        //    [firendsTable.infiniteScrollingView stopAnimating];
            
            if([[response valueForKey:@"status"] boolValue]){
                NSLog(@"response %d",response);
                
                [autoCompleteArray addObjectsFromArray:[[response objectForKey:@"friend_list"] mutableCopy]];
                
                autoCompleteFilterArray = autoCompleteArray;
                
                [_contentTableView reloadData];
                
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:NO];
}

@end
