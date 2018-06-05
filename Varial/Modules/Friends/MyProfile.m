//
//  MyProfile.m
//  Varial
//
//  Created by Shanmuga priya on 2/13/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MyProfile.h"
#import "HeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "MyFriends.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "FeedsDesign.h"
#import "FeedCell.h"
#import "FriendCell.h"
#import "FeedsDesign.h"
#import "SettingsMenu.h"
#import "ProfileUpdateViewController.h"
#import "InviteFriends.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <ResponsiveLabel/ResponsiveLabel.h>
#import "BookmarkViewController.h"

@interface MyProfile ()
{
    FeedsDesign *feedsDesign;
    BOOL isShowProfileRemoveOption, myBoolIsMutePressed;
    NSInteger followCount, followingCount, myIntPhotoCount, myIntVideoCount;
}

@property (nonatomic, strong)NSString *myStrProfileImgId;

@end

@implementation MyProfile

//@synthesize imgViewProfile;
//@synthesize btnEdit,btnPoints,btnEditImage,btnMore;
//@synthesize viewLeft, ProfileHolder;
//@synthesize segment;

@synthesize myStrProfileImgId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    controller = [[UIImagePickerController alloc] init];
    
    _profileView.delegate = self;
    
//    _profileTable.tableHeaderView.frame = CGRectMake(0, 0, _profileView.frame.size.width, _profileView.frame.size.height);
    
    textFields = [[NSArray alloc] initWithObjects:_setEmail,_password,_confirmPassword,_otpCode,_country,_countryCode,_mobileNumber,_changeEmail,_oldCountryCode,_oldPhoneNumber,_neCountryCode,_nePhoneNumber,_changeCountry, nil];
    
    friendsPage = boardPage = 1;
    _needToReload = 1;
    friendsList = [[NSMutableArray alloc]init];
    feedList = [[NSMutableArray alloc]init];
    boardList = [[NSMutableArray alloc]init];
    countries = [[NSMutableArray alloc] init];
    // Profile Images
    profileImagesArr = [[NSMutableArray alloc]init];
//    [_profileTable setHidden:YES];
    [_profileView setHidden:YES];
    
    [self.profileTable registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    [self.profileTable registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
    [self.profileTable registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"FriendCell"];

    [self designTheView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
    
    [_changeEmail addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_txtName addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_confirmPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_mobileNumber addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_nePhoneNumber addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_otpCode addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [_locationField addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    
    CGSize size = CGSizeMake(600, 800 ); // size of view in popover
    self.preferredContentSize = size;
    
 //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageReload:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //Set point icon
//    [Util setPointsIconText:btnPoints withSize:18];
    
    refreshControl = [[UIRefreshControl alloc] init];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        self.profileTable.refreshControl = refreshControl;
    } else {
        [self.profileTable addSubview:refreshControl];
    }
    
    [refreshControl addTarget:self
                       action:@selector(reloadView)
             forControlEvents:UIControlEventValueChanged];

    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
    
//    CGRect aRectframe = self.ProfileHolder.frame;
//    aRectframe.size.height = 150;
//    self.ProfileHolder.frame = aRectframe;
//    self.profileView.constraiintStatsViewTop.constant = - 60;
//    self.profileView.btnFollow.hidden = YES;
    
    CGRect aRectframe = self.ProfileHolder.frame;
    aRectframe.size.height = 230;
    self.ProfileHolder.frame = aRectframe;
    
    self.profileView.constraiintStatsViewTop.constant = 20;
    self.constraintProfileViewHeaderHeight.constant = 230;
//    self.profileView.followBtnWidthConstraint.constant = 200;
//    [self.profileView.btnFollow setTitle:@"Following" forState:UIControlStateNormal];
    [self.profileView.btnFollow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.profileView.btnFollow setBackgroundImage:nil forState:UIControlStateNormal];
    self.profileView.btnFollow.backgroundColor = [UIColor colorWithRed:56/255.0 green:151/255.0 blue:207/255.0 alpha:1.0];
    [self.profileView.btnFollow addTarget:self action:@selector(followingBtntapped) forControlEvents:UIControlEventTouchUpInside];
    [HELPER roundCornerForView:self.profileView.btnFollow withRadius:5.0];
    
    self.profileTable.estimatedRowHeight = 999;
    self.profileTable.rowHeight = 999;
    
   // _profileTable.frame = CGRectMake(_profileTable.frame.origin.x,_collectionView.frame.size.height+_collectionView.frame.origin.y , _profileTable.frame.size.width, _profileTable.frame.size.height);
}
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return 15;
//}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    StoriesCollectionViewCell *cell=[_collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
//    
//    cell.BrandImage.image = [UIImage imageNamed:@"iTunesArtwork.png"];
//    cell.BrandName.text = @"test";
//    cell.BrandImage.clipsToBounds = YES;
//    cell.BrandImage.layer.cornerRadius = cell.BrandImage.bounds.size.width/2;
//
//    cell.BrandImage.layer.borderWidth = 2;
//    cell.BrandImage.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
//
//    
////    NSDictionary *list = [feedList objectAtIndex:indexPath.row];
////    
////    cell.BrandName.text = [list objectForKey:@"type"];
////    cell.BrandImage.tintColor = [UIColor darkGrayColor];
////    cell.BrandImage.image = [Util imageForFeed:[[list objectForKey:@"feed_type"] intValue] withType:@"list"];
//
//   
////    UIImageView *feedTypeImage = (UIImageView *) [cell viewWithTag:10];
////    UILabel *feedName = (UILabel *)[cell viewWithTag:11];
//
////    
////    cell.BrandName.textColor = UIColorFromHexCode(GREY_TEXT);
//    return cell;
//}


- (void)setHeaderVisible:(BOOL)visible {
    [_headerView hideByHeight:!visible];
}

- (void)pageReload:(NSNotification *) data{
    
    [self createPopUpWindows];
}

- (void)viewWillDisappear:(BOOL)animated{
    [feedsDesign stopAllVideos];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setInfiniteScrollForTableView];
    [self getProfileFeeds];
    [self getPlayerLoginStatus];

    if (_needToReload == 1) {
        friendsPage = friendsPrevious = 1;
        [friendsList removeAllObjects];
        [self getProfileInfo];
    }
    [_profileTable reloadData];
    
//    [_spinnerView stopAnimating];
//    [_spinnerView startAnimating];
    
    [self createPopUpWindows];
    
    [Util setStatusBar];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    appDelegate.shouldAllowRotation = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(PlayVideoOnAppForeground)
                                                name:UIApplicationWillEnterForegroundNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(PlayVideoOnAppForeground)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(StopVideoOnAppBackground)
                                                name:UIApplicationWillResignActiveNotification
                                              object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [feedsDesign playVideoConditionally];
    });
}

- (void)reloadView {
    [self getProfileFeeds];
    [self getProfileInfo];
}

- (void) startLoading {
    [refreshControl beginRefreshing];
}

// Stop loading if profile and feeds are done
- (void) stopLoading {
    if (!profileLoading && !feedsLoading) {
        [refreshControl endRefreshing];
    }
}

#pragma mark ProfileView Delegates

- (void)tappedPoints:(id)sender {
    NSLog(@"tapped some points");
    [KLCpointPopup show];
//    [self goToProfileUpdate];
}
- (void)tappedVideos:(id)sender {
    [self videosBtnTapped];
}
- (void)tappedUpdate:(id)sender {
//    [self goToProfileUpdate];
    [self followBtntapped];
}
- (void)tappedPhotos:(id)sender {
    [self photosBtnTapped];
}
- (void)tappedFriends:(id)sender {
    [self goToFriends];
}

- (void)tappedLocation:(id)sender {
    [self showOptions];
}
- (void)tappedName:(id)sender {
    [self showEditNamePopup];
}

- (void)tappedProfileImage:(id)sender {
    [self chooseProfileImage];
//    [self tappedProfileImage:sender];
}
- (void)tappedBoardImage:(id)sender {
    [self editBoard];
}

- (void)tappedMore:(id)sender {
    [self goToMenu];
}

- (void)goToProfileUpdate {
    ProfileUpdateViewController *profileUpdate = [[ProfileUpdateViewController alloc]initWithNibName:@"ProfileUpdateViewController" bundle:nil];
    profileUpdate.updateImages = [profileImagesArr mutableCopy];
    profileUpdate.delegate = self;
    [self.navigationController pushViewController:profileUpdate animated:YES];
}


#pragma mark Actions
-(void)doneAction:(UIBarButtonItem*)barButton
{
    if(visibleWindow==1)
        [self changeEmailRequest];
    if(visibleWindow==2)
        [self editNameRequest];
    if(visibleWindow==3)
        [self emailActionRequest];
    if(visibleWindow==4)
        [self submitOTPRequest];
    if(visibleWindow==5)
        [self phoneNumberRequest];
    if(visibleWindow==6)
        [self changePhoneNumberRequest];
    if(visibleWindow == 7) {
        [self setLocationRequest];
    }
    
}



-(void)PlayVideoOnAppForeground
{
    [feedsDesign checkWhichVideoToEnable:_profileTable];
}

-(void)StopVideoOnAppBackground
{
    [feedsDesign StopVideoOnAppBackground:_profileTable];
}
- (void)reloadFeeds{
    //[feedList removeAllObjects];
    //[self getProfileFeeds];
    
    for (int i=0; i<[feedList count]; i++) {
        NSMutableDictionary *feed = [feedList objectAtIndex:i];
        NSString * isShare = [feed[@"is_share"] stringValue];
        if (![isShare isEqualToString:@"1"]) {
            [feed setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_name"] forKey:@"name"];
            NSMutableDictionary *profileImage = [feed objectForKey:@"posters_profile_image"];
            [profileImage setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"player_image"] forKey:@"profile_image"];
        }
        
        else {
            
            NSMutableDictionary *shareProfileImage = [[feed objectForKey:@"share_details"] mutableCopy];

            NSMutableDictionary *updateProfileImage = [NSMutableDictionary new];
            
            updateProfileImage = [[shareProfileImage objectForKey:@"profile_image"]mutableCopy];

            updateProfileImage[@"profile_image"] = [[[NSUserDefaults standardUserDefaults] valueForKey:@"player_image"]mutableCopy];

            shareProfileImage[@"profile_image"] = updateProfileImage;

            feed[@"share_details"] = shareProfileImage;
            
            NSLog(@"%@", shareProfileImage);
            
            NSLog(@"%@", feed);

            //NSMutableDictionary *profileImage = [feed objectForKey:@"posters_profile_image"];
           // [profileImage setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"player_image"] forKey:@"profile_image"];
        }
    }
    [self getProfileInfo];
    [_profileTable reloadData];
}

-(void) emailConfirmed:(NSNotification *) data{
    
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    [emailConfirmationPopup dismiss:YES];
    [self getPlayerLoginStatus];
    [[AlertMessage sharedInstance] showMessage:[[notificationContent objectForKey:@"data"] valueForKey:@"message"] withDuration:3];
}


#pragma mark - NetworkAlert delegates methods
-(void)onButtonClick{
    
    [emailConfirmationPopup dismiss:YES];

    /*
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"1" forKey:@"is_email"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CANCEL_EMAIL withCallBack:^(NSDictionary * response){
        
        [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        
        if([[response valueForKey:@"status"] boolValue]){
            [emailConfirmationPopup dismiss:YES];
        }
        
    } isShowLoader:YES];
    */
}


- (void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ConfirmEmailNotification" object:nil];
}

//Reset name after change in profile page
- (void)resetNames:(NSMutableArray *)source{
    for (int i=0; i<[source count]; i++) {
        NSMutableDictionary *feed = [source objectAtIndex:i];
        [feed setValue:_profileView.name.text forKey:@"name"];
        NSMutableDictionary *profileImage = [feed objectForKey:@"posters_profile_image"];
        [profileImage setValue:myProfile forKey:@"profile_image"];
    }
    [self.profileTable reloadData];
}

//Get countries list
-(void) getCountryList{
    
    //Send country list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:COUNTRY_LIST withCallBack:^(NSDictionary * response) {
        
        if([[response valueForKey:@"status"] boolValue]){
            [countries addObjectsFromArray:[response objectForKey:@"country_list"]];
        }
    } isShowLoader:YES];
    
}

//Add empty message in table background view
- (void)addEmptyMessageForBoardTable{
    
    if ([boardList count] == 0) {
        [Util addEmptyMessageToTable:self.boardTable withMessage:NO_BOARDS withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
    else{
        [Util addEmptyMessageToTable:self.boardTable withMessage:@"" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
}

//Get baord list
- (void) getBoardList {
    
    //Send board list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[NSNumber numberWithInt:boardPage] forKey:@"page"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [self.boardTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BOARD_LIST withCallBack:^(NSDictionary * response){
        [self.boardTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            boardPage = [[response valueForKey:@"page"] intValue];
            [boardList addObjectsFromArray:[response objectForKey:@"skate_board_image"]];
            [self addEmptyMessageForProfileTable];
            [_boardTable reloadData];
        }
    } isShowLoader:YES];
}

//Change the oldPhoneNumber placeholder
- (void) changePlaceHolder:(NSString *)oldNo andCountry:(NSString *) country{
    [_oldPhoneNumber setValue:oldNo forKeyPath:@"_placeholderLabel.text"];
    [_oldCountryCode setValue:country forKeyPath:@"_placeholderLabel.text"];
}

- (IBAction)setDefaultCountry:(id)sender
{
    if ([_country.text isEqualToString:@""] && [countries count] > 0) {
        [self pickerView:countryPicker didSelectRow:0 inComponent:0];
        [_country setTextColor:[UIColor blackColor]];
    }
}

- (void)designTheView{
    
    if(self.userName.length > 0){
        [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(FRIENDS_PROFILE, nil),_userName]];
    }
//    [_headerView setHeader:NSLocalizedString(VIEW_PROFILE, nil)];
//    [_headerView.logo setHidden:YES];
    
    [Util createRoundedCorener:_editNameView withCorner:5];
    [Util createRoundedCorener:_btnEditNameSave withCorner:3];
    [Util createRoundedCorener:_btnEditNameCancel withCorner:3];
    
    [Util createRoundedCorener:_editProfileView withCorner:5];
    [Util createRoundedCorener:_btnEditProfileCancel withCorner:3];
    
    [Util createRoundedCorener:_editDashboardView withCorner:5];
    
    [Util createRoundedCorener:_setEmailView withCorner:5];
    [Util createRoundedCorener:_saveEmailButton withCorner:3];
    [Util createRoundedCorener:_cancelEmailButton withCorner:3];
    
    [Util createRoundedCorener:_otpView withCorner:5];
    [Util createRoundedCorener:_otpSubmitButton withCorner:3];
    [Util createRoundedCorener:_otpResendButton withCorner:3];
    [Util createRoundedCorener:_otpCancelButton withCorner:3];
    
    [Util createRoundedCorener:_phoneNumberView withCorner:5];
    [Util createRoundedCorener:_savePhoneNumberButton withCorner:3];
    [Util createRoundedCorener:_cancelSetPhoneWindow withCorner:3];
    
    [Util createRoundedCorener:_changeEmailView withCorner:5];
    [Util createRoundedCorener:_closeEmailButton withCorner:3];
    [Util createRoundedCorener:_changeEmailButton withCorner:3];
    
    [Util createRoundedCorener:_changePhoneView withCorner:5];
    [Util createRoundedCorener:_changePhoneSaveButton withCorner:3];
    [Util createRoundedCorener:_closeChangePhoneButton withCorner:3];
    
    
    //Set country field input type to UIPickerview
    countryPicker = [[UIPickerView alloc] init];
    countryPicker.delegate = self;
    countryPicker.dataSource = self;
    countryPicker.showsSelectionIndicator = YES;
    countryPicker.frame = CGRectMake(0, self.view.frame.size.height-
                                     countryPicker.frame.size.height-50, self.view.frame.size.width, 230);
    _country.inputView = countryPicker;
    _changeCountry.inputView = countryPicker;
    
    _otpCode.delegate = self;
    
    
//    viewLeft.layer.cornerRadius = viewLeft.frame.size.height / 2 ;
//    viewLeft.clipsToBounds = true;
//    
//    _boardImage.layer.cornerRadius = _boardImage.frame.size.height / 2 ;
//    _boardImage.clipsToBounds = true;
    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont fontWithName:@"CenturyGothic" size:16], NSFontAttributeName,
//                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    
    _profileTable.backgroundColor = [UIColor clearColor];
    _profileTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _boardTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Design the spinner
    _spinnerView.lineWidth = 2.0f;
    // Optionally change the tint color
    _spinnerView.tintColor = UIColorFromHexCode(THEME_COLOR);
    
    [self addClickEventToImage];
    
//     Player_type_id 1 is an skater 2 is an Crew 3 is an Media
//    if (![[Util getFromDefaults:@"playerType"] isEqualToString:@"1"]){
//        [_starImage setHidden:YES];
//    }
    
    editInfo = [[EditInfoPopup alloc] init];
    [editInfo setDelegate:self];
    KLCEditInfoPopup = [KLCPopup popupWithContentView:editInfo showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    feedsDesign = [[FeedsDesign alloc] init];
}

- (void)tapProfileImage:(UITapGestureRecognizer *)tapRecognizer {
    UIImageView *imageView = (UIImageView *)tapRecognizer.view;
    [[Util sharedInstance] addImageZoom:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _otpCode) {
        return textField.text.length + (string.length - range.length) <= OTP_MAX;
    }
    return YES;
}

- (void) createPopUpWindows {
    
    __weak typeof(self) weakSelf = self;
    
    editNamePopup = [KLCPopup popupWithContentView:self.editNameView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    editNamePopup.didFinishShowingCompletion = ^{
        if (![weakSelf.profileView.name.text isEqualToString:@""]) {
            weakSelf.txtName.text = _profileView.name.text;
            [weakSelf.txtName becomeFirstResponder];
        }
    };
    
    editProfilePopup = [KLCPopup popupWithContentView:self.editProfileView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    editDashboardPopup = [KLCPopup popupWithContentView:self.editDashboardView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    editDashboardPopup.didFinishShowingCompletion = ^{
        [weakSelf.boardTable reloadData];
    };
    
    setEmailPopup = [KLCPopup popupWithContentView:self.setEmailView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    setEmailPopup.didFinishShowingCompletion = ^{
        [weakSelf.setEmail becomeFirstResponder];
    };
    
    setPhonePopup = [KLCPopup popupWithContentView:self.phoneNumberView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    setPhonePopup.didFinishShowingCompletion = ^{
        [countryPicker reloadAllComponents];
        [countryPicker selectRow:0 inComponent:0 animated:YES];
    };
    
    otpPopup = [KLCPopup popupWithContentView:self.otpView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    otpPopup.didFinishShowingCompletion = ^{
        [weakSelf.otpCode becomeFirstResponder];
    };
    
    changeEmailPopup = [KLCPopup popupWithContentView:self.changeEmailView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    changeEmailPopup.didFinishShowingCompletion = ^{
        [weakSelf.changeEmail becomeFirstResponder];
    };
    
    setLocationPopup = [KLCPopup popupWithContentView:self.setLocationView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    NSString *localCurrentLocation = currentLocation;
    setLocationPopup.didFinishShowingCompletion = ^{
        weakSelf.locationField.text = localCurrentLocation;
        [weakSelf.locationField becomeFirstResponder];
    };
    
    changePhonePopup = [KLCPopup popupWithContentView:self.changePhoneView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    changePhonePopup.didFinishShowingCompletion = ^{
        [weakSelf.oldPhoneNumber becomeFirstResponder];
        int index = [weakSelf findCountryIndexByCode:oldCounCode];
        if( index != -1)
        {
            if ([countries count] > index) {
                [self pickerView:countryPicker didSelectRow:index inComponent:0];
            }
        }
    };
    
    pointPopup = [[PointsPopup alloc] initWithViewsshowBuyPoints:TRUE showDonatePoints:TRUE showRedeemPoints:canRedeem showPointsActivityLog:TRUE];
    [pointPopup setDelegate:self];
    KLCpointPopup = [KLCPopup popupWithContentView:pointPopup showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];//FIXMEJEGAN
    
    mediaPopup=[[MediaPopup alloc]init];
    [mediaPopup setDelegate:self];
    KLCMediaPopup = [KLCPopup popupWithContentView:mediaPopup showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(FEED, nil)];
    popupView.message.text = NSLocalizedString(DELETE_FOR_SURE, nil);
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

//find country index
- (int) findCountryIndexByCode:(NSString *)code {
    
    for (int i=0; i<[countries count]; i++) {
        
        NSDictionary *country = [countries objectAtIndex:i];
        NSString *countryCode = [country valueForKey:@"country_pin_code"];
        if ([countryCode isEqualToString:code]) {
            return i;
        }
    }
    return -1;
}

//Move to post create page
- (IBAction)addPost:(id)sender {
    
    CreatePostViewController *postCreate = [self.storyboard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
    postCreate.postFromProfile = @"true";
    [self.navigationController pushViewController:postCreate animated:NO];
}

//Move friends search page
- (IBAction)moveToSearch:(id)sender {
    [self goToFriends];
}

- (void)goToFriends {

    MyFriends *myFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"MyFriends"];
//    myFriends.isFromFollowers = NO;
    [self.navigationController pushViewController:myFriends animated:YES];
}

// Delegate Call Back from Profile Update VC
-(void)sendDataToA
{
    isFromProfileUpdate = YES;
    //[self getProfileInfo];
    [self reloadFeeds];
    
//    [self getProfileFeeds];
}

//-(void)deleteProfileImageWithId:(NSInteger)index{
//    [profileImagesArr removeObjectAtIndex:index];
//    _profileView.profileImage.image = [UIImage imageNamed:IMAGE_HOLDER];
//}

- (IBAction)tappedSegment:(id)sender {
    [self setTint];
}

//Change the segment on click
-(void)setTint{
    
//    for (int i=0; i<[segment.subviews count]; i++)
//    {
//        if ([[segment.subviews objectAtIndex:i]isSelected] )
//        {
//            UIColor *themeColor = UIColorFromHexCode(THEME_COLOR);
//            [[segment.subviews objectAtIndex:i]setTintColor:themeColor];
//        }
//        else
//        {
//            UIColor *bckcolor=[UIColor blackColor];
//            [[segment.subviews objectAtIndex:i]setTintColor:bckcolor];
//        }
//    }
//    
//    //Hide/show the floating button
//    if(segment.selectedSegmentIndex == 0){
//        [_addPostButton setHidden:NO];
//        [_searchButton setHidden:YES];
//    }else{
//        [_addPostButton setHidden:YES];
//        [_searchButton setHidden:NO];
//    }
    
//    _profileTable.tableFooterView.hidden = YES;
//    [self addEmptyMessageForProfileTable];
//    [_profileTable reloadData];
}

//Show points popup
//- (IBAction)tappedPoints:(id)sender {
//    NSLog(@"Tapped Points");
//    [KLCpointPopup show];
//}


//Open image popup
- (void)addClickEventToImage
{
    UITapGestureRecognizer *clickEvent = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseProfileImage)];
    [clickEvent setNumberOfTapsRequired:1];
    [_profileImage setUserInteractionEnabled:YES];
    [_profileImage addGestureRecognizer:clickEvent];
}


//Create email confirmation popup
- (void)showEmailConfirmationPopup:(NSString *)message{
    
    emailConfirmation = [[NetworkAlert alloc] init];
    [emailConfirmation setNetworkHeader: NSLocalizedString(WAITING_FOR_CONFIRMATION, nil)];
    emailConfirmation.subTitle.text = message;
    [emailConfirmation.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    emailConfirmation.delegate = self;
    
    emailConfirmationPopup = [KLCPopup popupWithContentView:emailConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
}


//Step 1 - launching the actionsheet with a button action
- (void) chooseProfileImage
{
    
    [editProfilePopup dismiss:YES];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Profile Picture" message:@"Choose any one" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [KLCMediaPopup show];
        
        if(profileImagesArr.count > 0){
            mediaPopup.profileUpdateView.hidden = NO;
            [Util createBottomLine:mediaPopup.profileUpdateView withColor:[UIColor lightGrayColor]];
            mediaPopup.MyconstraintContainerHeight.constant = 210.0;
            [mediaPopup.myBtnProfileUpdate setTitle:[NSString stringWithFormat:@"Profile Update - %lu", (unsigned long)profileImagesArr.count] forState:UIControlStateNormal];
            //                     [_profileView.profileUpdateButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)profileImagesArr.count] forState:UIControlStateNormal];
        }else{
            mediaPopup.profileUpdateView.hidden = YES;
            [Util createBottomLine:mediaPopup.CameraView withColor:[UIColor lightGrayColor]];
            mediaPopup.MyconstraintContainerHeight.constant = 160.0;
            //                    [_profileView.profileUpdateButton setTitle:[NSString stringWithFormat:@"%d", 0] forState:UIControlStateNormal];
        }
    }]];
    
    if(isShowProfileRemoveOption){
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"View" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [[Util sharedInstance] zoomImageView:_profileView.profileImage];

    }]];
    
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            
            //Build Input Parameters
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            [inputParams setValue:@"1" forKey:@"default_flag"];
            [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:DELETE_PROFILE_IMAGE withCallBack:^(NSDictionary * response) {
                if([[response valueForKey:@"status"] boolValue]){
                    [Util setInDefaults:@"" withKey:@"player_image"];
                    _profileView.profileImage.image = [UIImage imageNamed:IMAGE_HOLDER];
                    isShowProfileRemoveOption = YES;
                    [[NSUserDefaults standardUserDefaults] setValue:@"/images/email_template_images/defaultPic.png" forKey:@"player_image"];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    [self reloadFeeds];
                }
            } isShowLoader:YES];
            
        }]];
        
    }
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}



#pragma mark - Picker View Data source
//set number of components to select
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//set number of rows for the picker
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [countries count];
}


#pragma mark- Picker View Delegate
//track the selected picker data
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSDictionary *country = [countries objectAtIndex:row];
    [_country setText:[country objectForKey:@"country_name"]];
    [_countryCode setText:[country valueForKey:@"country_pin_code"]];
    
    [_changeCountry setText:[country objectForKey:@"country_name"]];
    [_neCountryCode setText:[country valueForKey:@"country_pin_code"]];
    
    countryId = [country valueForKey:@"country_id"];
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSDictionary *country = [countries objectAtIndex:row];
    return [country objectForKey:@"country_name"];
    
}
//** End of Picker View Deleage **/


#pragma mark - MediaPopup delegates methods
-(void)onCameraClick{
    [KLCMediaPopup dismiss:YES];
    _needToReload = 0;
    [self showCamera];
}

-(void)onGalleryClick{
    [KLCMediaPopup dismiss:YES];
    _needToReload = 0;
    [self openPhotoAlbum];
}

-(void)onProfileUpdateClick{
    [KLCMediaPopup dismiss:YES];
    _needToReload = 0;
    [self goToProfileUpdate];
}

-(void)onOkClick{
    [KLCMediaPopup dismiss:YES];
}


#pragma mark - Private methods
//step 3.1 handle for camera action
- (void)showCamera
{
    //UIImagePickerController *controller = [[UIImagePickerController alloc] init];
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
    //UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
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
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //replace with user image
    profilePicture = image;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [picker dismissViewControllerAnimated:YES completion:^{
                [self openEditor:nil];
            }];
        }];
        
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor:nil];
        }];
    }
}


//step 5 - Crop the image after the user chosen
#pragma mark - Action methods
- (IBAction)openEditor:(id)sender
{
    PECropViewController *cropController = [[PECropViewController alloc] init];
    cropController.delegate = self;
    
    //replace with user image
    cropController.image = profilePicture;
    cropController.keepingCropAspectRatio = YES;
    
    CGFloat width = profilePicture.size.width;
    CGFloat height = profilePicture.size.height;
    CGFloat length = MIN(width, height);
    cropController.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cropController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - PECropViewControllerDelegate methods
//Step - 6 - Update the profile image after cropping
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    //replace with user image
    _profileView.profileImage.image = [Util resizeProfileImage:croppedImage];
    
    //Upload image
    [self uploadImage];
    
}

//Step - 7 - Perform action if the image is cancelled
- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [_spinnerView startAnimating];
    [controller dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"Cancelled...!");
}

- (void) uploadImage{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [_spinnerView setHidden:NO];
    
    NSData *imgData = UIImageJPEGRepresentation(_profileView.profileImage.image, 0.5);
    
    [[Util sharedInstance] sendHTTPPostRequestWithImage:inputParams withRequestUrl:PROFILE_IMAGE_API withImage:imgData  withFileName:@"profile_image" withCallBack:^(NSDictionary *response)  {
        
        [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        [_spinnerView setHidden:YES];
        [_spinnerView stopAnimating];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[response  objectForKey:@"image_url"]];
        myProfile = strURL;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:1] forKey:@"isImageChanged"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setValue:strURL forKey:@"player_image"];
        
        [self reloadFeeds];
        
        isShowProfileRemoveOption = YES;
        
    } onProgressView:nil withExtension:@"filename.jpg" ofType:@"image/jpeg"] ;
    
}

- (IBAction)showMore:(id)sender {
    // Hide already showing popover
//    [self.menuPopover dismissMenuPopover];
//    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(btnMore.frame.origin.x-105, 320 - _profileTable.contentOffset.y, 120, 42) menuItems:@[NSLocalizedString(SETTINGS_TITLE,nil)]];
//    self.menuPopover.menuPopoverDelegate = self;
//    self.menuPopover.tag = 100;
//    [self.menuPopover showInView:self.view];
    [self goToMenu];
}

- (void)goToMenu {
//    SettingsMenu *settingsMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsMenu"];
//    [self.navigationController pushViewController:settingsMenu animated:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle: nil];
    SettingsMenu *settingsMenu = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsMenu"];
    [self.navigationController pushViewController:settingsMenu animated:YES];
}


// Delegate method for MLKMenuPopover
- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    [self.menuPopover dismissMenuPopover];
    
    if([[Util sharedInstance] getNetWorkStatus])
    {
        if(menuPopover.tag == 100)
        {
            int clickedIndex = (int) selectedIndex;
            if (clickedIndex == 0) {
                NSString * isShare = [feedList[menuPosition.row][@"is_share"] stringValue];
                if ([isShare isEqualToString:@"1"]) {
                    [self deletePost];
                } else {
                    [self editPost];
                }
                //                movePostId = [[feeds objectAtIndex:menuPosition.row] objectForKey:@"post_id"];
            }
            else if (clickedIndex == 1) {
                [self deletePost];
            }
        }
    } else {
        [appDelegate.networkPopup show];
    }

}


#pragma argu - tableView delegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == _boardTable) {
        return [boardList count];
    }else{
        return [feedList count];
//        return segment.selectedSegmentIndex == 0 ? [feedList count] : [friendsList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    FeedCell *fcell;
    
    if (tableView == _profileTable) {
        
//        if (segment.selectedSegmentIndex == 0) {
        
            static NSString *cellIdentifier = nil;
            cellIdentifier= ([[[feedList objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feedList objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"FeedCell" : @"MessagesCell";
            
            fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (fcell == nil)
            {
                fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
        
            // Mute Button Actions
            [fcell.gBtnMuteUnMute addTarget:self action:@selector(muteUnmutePressed:) forControlEvents:UIControlEventTouchUpInside];
            fcell.gBtnMuteUnMute.tag = indexPath.row;
            
            feedsDesign.feeds = feedList;
            feedsDesign.feedTable = tableView;
            feedsDesign.mediaBaseUrl= strMediaUrl;
            feedsDesign.viewController = self;
            feedsDesign.isVolumeClicked = NO;
//            feedsDesign.isNoNeedNameRedirection = TRUE;
//            feedsDesign.isNoNeedProfileRedirection = TRUE;
            [feedsDesign designTheContainerView:fcell forFeedData:[feedList objectAtIndex:indexPath.row] mediaBase:strMediaUrl forDelegate:self tableView:tableView];
            
            fcell.backgroundColor = [UIColor clearColor];
            fcell.shareView.hidden = YES;
            fcell.shareViewHeightConstraint.constant = 0.0;
            NSString * isShare = [feedList[indexPath.row][@"is_share"] stringValue];
            if ([isShare isEqualToString:@"1"]) {
            fcell.shareView.hidden = NO;
            fcell.shareViewHeightConstraint.constant = 70.0;
                NSString * sharedPerson = feedList[indexPath.row][@"share_details"][@"name"];
//                NSString * postOwnerName = feedList[indexPath.row][@"name"];
                NSString * postOwnerName = [NSString stringWithFormat:@"%@'s ",feedList[indexPath.row][@"name"]];
                
                NSString * sharedPersonImgUrl = feedList[indexPath.row][@"share_details"][@"profile_image"][@"profile_image"];
                NSString * downloadUrl = [NSString stringWithFormat:@"https://dqloq8l38fi51.cloudfront.net%@",sharedPersonImgUrl];
                [fcell.sharedPersonImage sd_setImageWithURL:[NSURL URLWithString:downloadUrl]
                                           placeholderImage:nil
                                                    options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
                UIColor *color = [UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:1.0];
                //            UIFont * font = [UIFont systemFontOfSize:14.0];
                NSDictionary *attrs = @{ NSForegroundColorAttributeName : color};
                NSMutableAttributedString * combinedStr = [[NSMutableAttributedString alloc]init];
                NSAttributedString *attrStr2;
                NSAttributedString *attrStr4;
                NSAttributedString * attrStr1 = [[NSAttributedString alloc]initWithString:sharedPerson attributes:nil];
                if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
                {
                    attrStr2 = [[NSAttributedString alloc] initWithString:@" shared " attributes:attrs];
                    attrStr4 = [[NSAttributedString alloc] initWithString:@"post" attributes:attrs];
                    
                }
                
                else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
                {
                    attrStr2 = [[NSAttributedString alloc] initWithString:@" 分享了 " attributes:attrs];
                    attrStr4 = [[NSAttributedString alloc] initWithString:@"的帖子" attributes:attrs];
                }
                
                NSAttributedString * attrStr3 = [[NSAttributedString alloc]initWithString:postOwnerName attributes:nil];
                [combinedStr appendAttributedString:attrStr1];
                [combinedStr appendAttributedString:attrStr2];
                [combinedStr appendAttributedString:attrStr3];
                [combinedStr appendAttributedString:attrStr4];
                fcell.gLblShareDescription.attributedText = combinedStr;
                fcell.gLblShareDescription.userInteractionEnabled = YES;
                
                PatternTapResponder stringTapAction = ^(NSString *tappedString) {
                    if([tappedString isEqualToString: sharedPerson]){
                        
                        [self goToSharedPersonProfile:indexPath isSharedPersonName:YES];
                    }
                    
                    else {
                        
                        [self goToSharedPersonProfile:indexPath isSharedPersonName:NO];
                    }
                    
                };
                [fcell.gLblShareDescription enableDetectionForStrings:@[sharedPerson,postOwnerName] withAttributes:@{RLTapResponderAttributeName:stringTapAction}];
                
                [fcell.sharedTime setText:[Util timeStamp: [feedList[indexPath.row][@"share_details"][@"share_time"] intValue]]];
                
                
            } else {
                fcell.shareView.hidden = YES;
                fcell.shareViewHeightConstraint.constant = 0.0;
            }
        return fcell;
//        }
//        else{
//            FriendCell *frndCell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
//            if (frndCell == nil)
//            {
//                frndCell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"];
//            }
//            
//            
//            frndCell.backgroundColor = [UIColor clearColor];
//            NSDictionary *list = [friendsList objectAtIndex:indexPath.row];
//            
//            frndCell.name.text = [list objectForKey:@"name"];
//            frndCell.points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[list objectForKey:@"point"]];
//            frndCell.rankLabel.text = [Util playerType:[[list objectForKey:@"player_type_id"] intValue] playerRank:[list objectForKey:@"rank"]];
//            
//            NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"profile_image"]];
//            [frndCell.profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
//            
//            strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"player_skate_pic"]];
//            [frndCell.board setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
//            
//            return  frndCell;
//            
//        }
        
    }
    else{
        
        static NSString *cellIdentifier = @"boardCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        //Read elements
        Board  *board = (Board *)[cell viewWithTag:10];
        board.layer.cornerRadius = board.frame.size.height / 2;
        board.layer.masksToBounds = YES;
//        board.contentMode = UIViewContentModeScaleToFill;
        board.contentMode = UIViewContentModeScaleAspectFill;
        
        NSDictionary *list = [boardList objectAtIndex:indexPath.row];
        NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[list objectForKey:@"skate_board_image"]];
        [board setImage:nil];
        [board setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:nil];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == _profileTable) {
        
        NSNumber *key = @(indexPath.row);
        NSNumber *height = [cellHeightsDictionary objectForKey:key];
        
        if (height)
        {
            return height.doubleValue;
        }
        return UITableViewAutomaticDimension;
    }
    else {
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == _profileTable) {
        
        NSNumber *key = @(indexPath.row);
        NSNumber *height = @(cell.frame.size.height);
        
        [cellHeightsDictionary setObject:height forKey:key];
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _profileTable) {
        
        NSNumber *key = @(indexPath.row);
        NSNumber *height = [cellHeightsDictionary objectForKey:key];
        
        if (height)
        {
            return height.doubleValue;
        }
        return UITableViewAutomaticDimension;
    }
    else {
        return UITableViewAutomaticDimension;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
//    if (tableView == _boardTable) {
//        return 90.0f;
//    }
//    else{
//        return UITableViewAutomaticDimension;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (tableView == _boardTable) {
//        return 90.0f;
//    }
//    else{
//        return UITableViewAutomaticDimension;
//    }
//}

//-(void)doActionForSharedPerson:(id)sender{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_profileTable];
//    NSIndexPath *path = [_profileTable indexPathForRowAtPoint:buttonPosition];
//    [self goToSharedPersonProfile:path isSharedPersonName:YES];
//}
//
//-(void)doActionForShareOwner:(id)sender{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_profileTable];
//    NSIndexPath *path = [_profileTable indexPathForRowAtPoint:buttonPosition];
//    [self goToSharedPersonProfile:path isSharedPersonName:NO];
//}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _boardTable) {
        //assign board
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        NSDictionary *board = [boardList objectAtIndex:indexPath.row];
        [inputParams setValue:[board valueForKey:@"id"] forKey:@"skate_board_id"];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:UPDATE_BAORD withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [editDashboardPopup dismiss:YES];
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@",strMediaUrl,[board valueForKey:@"skate_board_image"]] ;
                [_profileView.boardImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:_profileView.boardImage.image];
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
        } isShowLoader:YES];
    }
//    else{
//        if(segment.selectedSegmentIndex == 1) {
//            _needToReload = 1;
//            NSDictionary *friend = [friendsList objectAtIndex:indexPath.row];
//            FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
//            friendProfile.friendId = [friend valueForKey:@"friend_id"];
//            friendProfile.friendName = [friend valueForKey:@"name"];
//            [self.navigationController pushViewController:friendProfile animated:YES];
//        }
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [feedsDesign stopAllVideos];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    [feedsDesign checkWhichVideoToEnable:_profileTable];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [feedsDesign checkWhichVideoToEnable:_profileTable];
}

-(void)goToSharedPersonProfile:(NSIndexPath *)indexpath isSharedPersonName:(BOOL)isSharedPerson{
    if ([feedList count] > indexpath.row) {
        if (![[[feedList objectAtIndex:indexpath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            if (isSharedPerson) {
                profile.friendId = [feedList objectAtIndex:indexpath.row][@"share_details"][@"player_id"];
                profile.friendName = [feedList objectAtIndex:indexpath.row][@"share_details"][@"name"];
            } else {
                profile.friendId = [feedList objectAtIndex:indexpath.row][@"post_owner_id"];
                profile.friendName = [feedList objectAtIndex:indexpath.row][@"name"];
            }
            [self.navigationController pushViewController:profile animated:YES];
        }
    }
}

#pragma argu - KLCPointpopup delegate
- (void)onBuyPointsClick{
    [KLCpointPopup dismiss:YES];
    _needToReload = 1;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

    BuyPointsViewController *buyPoints = [mainStoryboard instantiateViewControllerWithIdentifier:@"BuyPointsViewController"];
    buyPoints.isTeamBuy = FALSE;
    [self.navigationController pushViewController:buyPoints animated:YES];
}
-(void)onDonatePointsClick{
    [KLCpointPopup dismiss:YES];
    _needToReload = 1;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

    DonatePoint *donatePoint = [mainStoryboard instantiateViewControllerWithIdentifier:@"DonatePoint"];
    donatePoint.donationFrom = 1;
    [self.navigationController pushViewController:donatePoint animated:YES];
}
-(void)onRedeemPointsClick{
    [KLCpointPopup dismiss:YES];
    _needToReload = 1;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

    ShoppingHome *shoppingHome = [mainStoryboard instantiateViewControllerWithIdentifier:@"ShoppingHome"];
    [self.navigationController pushViewController:shoppingHome animated:YES];
}
-(void)onPointsActivityLog{
    [KLCpointPopup dismiss:YES];
    _needToReload = 0;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];

    PointsActivityLog *points = [mainStoryboard instantiateViewControllerWithIdentifier:@"PointsActivityLog"];
    points.friendId = @"";
    [self.navigationController pushViewController:points animated:YES];
}


//Get user details
- (void)getProfileInfo {
    //Build Input Parameters
    profileLoading = YES;
//    [self startLoading];
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:GET_PLAYER_INFORMATION withCallBack:^(NSDictionary * response)
     {
         profileLoading = NO;
         [self stopLoading];
         [_profileView setHidden:NO];

         if ([[response valueForKey:@"status"] boolValue]) {
           
             strMediaUrl = [response objectForKey:@"media_base_url"];
             NSDictionary *details = [[NSDictionary alloc] init];
             details = [response objectForKey:@"player_details"];
             
             //myStrProfileImgId = details[@"profile_id"];
             
             _profileView.name.text = [details objectForKey:@"name"];
//             NSRange range = NSMakeRange(0, [_name.text length]);
//             [Util makeAsLink:_name withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR) showUnderLine:NO range:range];
//             _name.delegate = self;
//             
//             _profileView.points.text = [NSString stringWithFormat:@"%@",[details objectForKey:@"leader_board_points"]];
             
//             _profileView.pointsButtons set [NSString stringWithFormat:@"%@",[details objectForKey:@"leader_board_points"]];
             
             [_profileView.pointsButton setTitle:[NSString stringWithFormat:@"%@", [details objectForKey:@"leader_board_points"]] forState:UIControlStateNormal];
             
             _profileView.rank.text = [Util playerTypeInProfilePage:[[details objectForKey:@"player_type_id"] intValue] playerRank:[details objectForKey:@"rank"]];
             myIntPhotoCount = [[details objectForKey:@"photo_count"] intValue];
             myIntVideoCount = [[details objectForKey:@"video_count"] intValue];
             [_profileView.friendsButton setTitle:[NSString stringWithFormat:@"%@", [details objectForKey:@"friends_count"]] forState:UIControlStateNormal];
             [_profileView.photosButton setTitle:[NSString stringWithFormat:@"%d", [[details objectForKey:@"photo_count"] intValue]] forState:UIControlStateNormal];
             [_profileView.videosButton setTitle:[NSString stringWithFormat:@"%d", [[details objectForKey:@"video_count"] intValue]] forState:UIControlStateNormal];
             [self.profileView.btnFollow setTitle:[NSString stringWithFormat:@"%@ %@",[details objectForKey:@"following"] ,NSLocalizedString(FOLLOWING, nil)] forState:UIControlStateNormal];
             if(![[details objectForKey:@"follow"] isEqualToString:@""]){
                 [_profileView.profileUpdateButton setTitle:[NSString stringWithFormat:@"%@",[details objectForKey:@"follow"]] forState:UIControlStateNormal];
             }
             
             followingCount = [[details objectForKey:@"following"] integerValue];
             followCount = [[details objectForKey:@"follow"] integerValue];

             
             if ([details objectForKey:@"location"] == [NSNull null] || [[details objectForKey:@"location"] isEqualToString:@""]) {
                 
                 _profileView.location.text = NSLocalizedString(SET_LOCATION, nil);
                 [_profileView.location setTextColor:UIColorFromHexCode(THEME_COLOR)];
                 currentLocation = @"";
             } else {
                 _profileView.location.text = [details objectForKey:@"location"];
                 [_profileView.location setTextColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
                 currentLocation = [details objectForKey:@"location"];
             }
             
             NSDictionary *proImage = [details objectForKey:@"player_image_detail"];
             NSString *strURL = [NSString stringWithFormat:@"%@%@", strMediaUrl, [proImage  objectForKey:@"profile_image"]];
             // Set Updated Profile Image to all Feeds and Reload data
             if(isFromProfileUpdate){
                 NSMutableDictionary *updatedProfileImage = [[NSMutableDictionary alloc]init];
                 [updatedProfileImage setObject:strURL forKey:@"profile_image"];
                 [updatedProfileImage setObject:[proImage objectForKey:@"profile_image_thumb"] forKey:@"profile_image_thumb"];
                
                 for(NSMutableDictionary* sampleDic in feedList){
                     
                     if ([[sampleDic[@"is_share"] stringValue] isEqualToString:@"1"]) {
                         NSMutableDictionary * testDic = [[NSMutableDictionary alloc]init];
                         testDic = [sampleDic[@"share_details"] mutableCopy];
                         testDic[@"profile_image"] = updatedProfileImage;
                         sampleDic[@"share_details"] = testDic;
                    }
                     else
                         sampleDic[@"posters_profile_image"] = updatedProfileImage;

                 }
                 [_profileTable reloadData];
             }
            [_profileView.profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
             
             // Profile Image set to Array
             profileImagesArr = [details objectForKey:@"profile_images"];
                if(profileImagesArr.count > 0){
                    mediaPopup.profileUpdateView.hidden = NO;
                    [Util createBottomLine:mediaPopup.profileUpdateView withColor:[UIColor lightGrayColor]];
                    mediaPopup.MyconstraintContainerHeight.constant = 210.0;
                    [mediaPopup.myBtnProfileUpdate setTitle:[NSString stringWithFormat:@"Profile Update - %lu", (unsigned long)profileImagesArr.count] forState:UIControlStateNormal];
//                     [_profileView.profileUpdateButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)profileImagesArr.count] forState:UIControlStateNormal];
                }else{
                    mediaPopup.profileUpdateView.hidden = YES;
                    [Util createBottomLine:mediaPopup.CameraView withColor:[UIColor lightGrayColor]];
                    mediaPopup.MyconstraintContainerHeight.constant = 150.0;
//                    [_profileView.profileUpdateButton setTitle:[NSString stringWithFormat:@"%d", 0] forState:UIControlStateNormal];
                }
             
                isShowProfileRemoveOption = [@"/images/email_template_images/defaultPic.png" isEqualToString:[details valueForKeyPath:@"player_image_detail.profile_image"]] ? NO : YES;
             
//             [_profileView.profileUpdateButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)profileImagesArr.count] forState:UIControlStateNormal];
//             NSString *fullImageUrl = [Util getOriginalImageUrl:strURL];
//             if (fullImageUrl != nil) {
//                 [_profileView.profileImage setImageWithURL:[NSURL URLWithString:fullImageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
                 myProfile = strURL;
//             }
//             else{
//                 _profileView.profileImage.image = [UIImage imageNamed:IMAGE_HOLDER];
//             }
             
             NSString *board = [NSString stringWithFormat:@"%@%@",strMediaUrl, [details valueForKey:@"skate_board_image"]];
             
//             [_profileView.boardImage setImageWithURL:[NSURL URLWithString:board] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
             [_profileView.boardImage setImageWithURL:[NSURL URLWithString:board]];
             _profileView.boardImage.layer.cornerRadius = _profileView.boardImage.frame.size.height / 2;
             
             canRedeem = [[details valueForKey:@"can_redeem"] boolValue] && [Util getBoolFromDefaults:@"can_show_shoping"];
             [self createPopUpWindows];
//             [self getFriendsList];
             
         }
         
     } isShowLoader:NO];
}


//Get user login status
-(void)getPlayerLoginStatus{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:PLAYER_LOGIN_STATUS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            NSDictionary *status = [response objectForKey:@"player_login_status"];
            
            havingEmail = [[status valueForKey:@"email_status"] boolValue];
            havingPhoneNumber = [[status valueForKey:@"phone_status"] boolValue];
            
            //Change email button title
            if(havingEmail){
                [editInfo.emailButton setTitle:NSLocalizedString(CHANGE_EMAIL_ID, nil) forState:UIControlStateNormal];
                editInfo.emailButton.tag = 1;
                editInfo.email.text=[status valueForKey:@"email_id"];
            }
            else{
                
                [editInfo.emailButton setTitle:NSLocalizedString(SET_EMAILID_STRING, nil) forState:UIControlStateNormal];
                editInfo.emailButton.tag = 0;
                [editInfo.email hideByHeight:YES];
                
            }
            
            //Change phone button title
            if(havingPhoneNumber){
                [editInfo.phoneButton setTitle:NSLocalizedString(CHANGE_NUMBER, nil) forState:UIControlStateNormal];
                oldCounCode = [status valueForKey:@"country_code_pin"];
                oldPhNo = [status valueForKey:@"format_phone_number"];
                oldCountryId = [status valueForKey:@"country_code"];
                [self changePlaceHolder:oldPhNo andCountry:oldCounCode];
                editInfo.phoneButton.tag = 1;
                editInfo.phoneNumber.text=[NSString stringWithFormat:@"%@-%@",oldCounCode,oldPhNo];
            }
            else{
                [editInfo.phoneButton setTitle:NSLocalizedString(SET_NUMBER, nil) forState:UIControlStateNormal];
                editInfo.phoneButton.tag = 0;
                
            }
        }
    } isShowLoader:NO];
    
}

//---------- Edit profile image -----------------

- (IBAction)tappedEditProfile:(id)sender {
        [KLCMediaPopup show];
}


- (IBAction)tappedEditProfileCancel:(id)sender {
    [editProfilePopup dismiss:YES];
}

//---------- Edit profile image ends -----------------


//---------- Edit name  -----------------
#pragma mark Edit Name

- (IBAction)tappedEditNameCancel:(id)sender {
    [editNamePopup dismiss:YES];
}

- (IBAction)tappedEditName:(id)sender {
//    [self showEditNamePopup];
}

- (void)showEditNamePopup{
    _txtName.text = _profileView.name.text;
    [_editNameView setHidden:NO];
    [editNamePopup showWithLayout:layout];
    visibleWindow = 2;
}

- (IBAction)tappedEditNameSave:(id)sender {
    [self editNameRequest];
}

-(void)editNameRequest{
    
    if([self validateName])
    {
        [editNamePopup dismiss:YES];
        NSString *oldName = _profileView.name.text;
        _profileView.name.text = _txtName.text;
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_txtName.text forKey:@"name"];
        [[Util sharedInstance]  sendHTTPPostRequestWithError:inputParams withRequestUrl:EDIT_NAME withCallBack:^(NSDictionary * response, NSError *error)
         {
             if (error != nil) {
                 // Revert the title
                 if(![oldName isEqualToString:@""])
                   _profileView.name.text = oldName;
             }
             else
             {
                 if([[response valueForKey:@"status"] boolValue])
                 {
                     [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                     if (![_txtName.text isEqualToString:@""]) {
                         _profileView.name.text = _txtName.text;
                     }
//                     NSRange range = NSMakeRange(0, [_name.text length]);
//                     [Util makeAsLink:_name withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR) showUnderLine:NO range:range];
                     [[NSUserDefaults standardUserDefaults] setValue:_txtName.text forKey:@"user_name"];
                     [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:1] forKey:@"isNameChanged"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     [self reloadFeeds];
                     [_txtName resignFirstResponder];
                     
                 }
                 else
                 {
                     if(![oldName isEqualToString:@""])
                         _profileView.name.text = oldName;
                     [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                 }
             }
             
         } isShowLoader:NO];
    }
}

-(BOOL)validateName{
    
    [self resetEditNameForm];
    
    //Validate name
    if(![Util validateTextField:_txtName withValueToDisplay:NAME_TITLE withIsEmailType:FALSE withMinLength:NAME_MIN withMaxLength:NAME_MAX_LEN]){
        return FALSE;
    }
    if(![Util validCharacter:_txtName forString:_txtName.text withValueToDisplay:NAME_TITLE]){
        return FALSE;
    }
    if(![Util validateName:_txtName.text]){
        [Util showErrorMessage:_txtName withErrorMessage:NSLocalizedString(INVALID_NAME, nil)];
        return FALSE;
    }
    
    return YES;
}

- (void)resetEditNameForm{
    [Util createBottomLine:_txtName withColor:UIColorFromHexCode(GREY_BORDER)];
}

//---------- Edit name ends -----------------




//-------- Edit board --------------
#pragma mark Edit Board


- (IBAction)tappedEditDashboard:(id)sender {
    
    
}

- (void)editBoard {
    if ([boardList count] == 0) {
        [self getBoardList];
    }
    [_editDashboardView setHidden:NO];
    [editDashboardPopup show];
}

//-------- Edit board ends --------------




//---------- Edit info ----------------
- (IBAction)tappedOption:(id)sender {
    [self showOptions];
}

- (void)showOptions {
    if ([countries count] == 0) {
        [self getCountryList];
    }
    [KLCEditInfoPopup show];
}

#pragma args Edit Info delegates
- (void)onChangeEmailClick{
    [KLCEditInfoPopup dismiss:YES];
    if (editInfo.emailButton.tag == 1) {
        [_changeEmailView setHidden:NO];
        [changeEmailPopup showWithLayout:layout];
        visibleWindow=1;
    }
    else{
        [_setEmailView setHidden:NO];
        [setEmailPopup showWithLayout:layout];
        visibleWindow=3;
    }
}
- (void)onChangePhoneNoClick{
    [KLCEditInfoPopup dismiss:YES];
    if (editInfo.phoneButton.tag == 1) {
        [_changePhoneView setHidden:NO];
        [changePhonePopup showWithLayout:layout];
        visibleWindow=6;
    }
    else{
        [_phoneNumberView setHidden:NO];
        [setPhonePopup showWithLayout:layout];
        visibleWindow=5;
        
        // Auto populate the county picker
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_country sendActionsForControlEvents:UIControlEventEditingDidBegin];
            [_country becomeFirstResponder];
        });
    }
    
}

- (void)onChangeLocationClick {
    [KLCEditInfoPopup dismiss:YES];
    [_setLocationView setHidden:NO];
    [setLocationPopup showWithLayout:layout];
    visibleWindow = 7;
}

//---------- Edit info ends ----------------




//------------> Change Phone number <----------------
#pragma mark Change Phone Number
- (IBAction)changePhoneNumber:(id)sender {
    [self changePhoneNumberRequest];
}

-(void)changePhoneNumberRequest{
    if ([self changePhoneNumberFormValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_oldPhoneNumber.text forKey:@"old_phone_number"];
        [inputParams setValue:_nePhoneNumber.text forKey:@"new_phone_number"];
        [inputParams setValue:oldCountryId forKey:@"old_country_code_id"];
        [inputParams setValue:countryId forKey:@"new_country_code_id"];
        
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CHANE_PHONE_NUMBER withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                
                [changePhonePopup dismiss:YES];
                
                //Show otp window
                [self.otpView setHidden:NO];
                [otpPopup showWithLayout:layout];
                visibleWindow=4;
                
                //change timer and resend button visibitlity
                [_otpResendButton setHidden:YES];
                [_countdownLabel setHidden:NO];
                
                //Set otp time limit
                secondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
                countDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
                
                //Place the OTP as hint
                if(![[response valueForKey:@"view_otp"] boolValue])
                {
                    [_otpCode setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"OTP"] ] forKeyPath:@"_placeholderLabel.text"];
                }
                [_nePhoneNumber resignFirstResponder];
                
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
    
}

- (IBAction)closeChangePhoneWindow:(id)sender {
    [changePhonePopup dismiss:YES];
}


//Set phone number validation
-(BOOL)changePhoneNumberFormValidation{
    [self resetChangePhoneForm];
    
    //Check old phone number is empty
    if([[_oldPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_oldPhoneNumber withErrorMessage:NSLocalizedString(OLD_PHONE_EMPTY, nil)];
        return FALSE;
    }
    //Check coutry is choosed
    if([[_changeCountry.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_changeCountry withErrorMessage:NSLocalizedString(COUNTRY_EMPTY, nil)];
        return FALSE;
    }
    
    if(![Util validateNumberField:_nePhoneNumber withValueToDisplay:NEW_NUMBER withMinLength:PHONE_MIN withMaxLength:PHONE_MAX])
    {
        return FALSE;
    }
    
    return YES;
}

//Reset the phone form
- (void)resetChangePhoneForm{
    [Util createBottomLine:_changeCountry withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_oldPhoneNumber withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_nePhoneNumber withColor:UIColorFromHexCode(TEXT_BORDER)];
    
}

//------------> Change Phone number ends <----------------



//------------> Set email  <----------------
#pragma mark Set Email

- (IBAction)setEmailAction:(id)sender {
    [self emailActionRequest];
}

-(void)emailActionRequest{
    if ([self setEmailValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_setEmail.text forKey:@"email"];
        [inputParams setValue:_password.text forKey:@"password"];
        [inputParams setValue:_confirmPassword.text forKey:@"confirm_password"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_EMAIL_API withCallBack:^(NSDictionary * response){
            //success case
            if([[response valueForKey:@"status"] boolValue]){
                
                [setEmailPopup dismiss:YES];
                [self showEmailConfirmationPopup:[response valueForKey:@"message"]];
                [emailConfirmationPopup show];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
                [_confirmPassword resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
    
}

- (IBAction)cancelSetEmail:(id)sender {
    [setEmailPopup dismiss:YES];
}

//set Email validation
-(BOOL) setEmailValidation{
    [self resetSetEmailWindow];
    
    [NSCharacterSet symbolCharacterSet];
    
    //Validate email
    if(![Util validateTextField:_setEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    //Validate password
    else if(![Util validatePasswordField:_password withValueToDisplay:PASSWORD withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX]){
        return FALSE;
    }
    // Validation Password continue empty spaces
    if ([[_password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_confirmPassword withErrorMessage:NSLocalizedString(CONTINUE_WHITESPACES, nil)];
        
        return FALSE;
    }
    //Check confirm password is empty
    else if([_confirmPassword.text length] == 0)
    {
        [Util showErrorMessage:_confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_EMPTY, nil)];
        return FALSE;
    }
    //Validation to match password
    if(![_confirmPassword.text isEqualToString:_password.text]){
        
        //add border to validated fields
        [Util createBottomLine:_password withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util createBottomLine:_confirmPassword withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util showErrorMessage:_confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_MISMATCH, nil)];
        return FALSE;
    }
    
    return YES;
}
-(void) resetSetEmailWindow{
    [Util createBottomLine:_setEmail withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_password withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_confirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}


//------------> Set email ends <----------------

//------------> Change email <----------------

#pragma mark Change Email

- (IBAction)changeEmail:(id)sender {
    [self changeEmailRequest];
    
}
-(void)changeEmailRequest{
    if ([self changeEmailFormValidation]) {
        
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_changeEmail.text forKey:@"email"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CHANGE_EMAIL withCallBack:^(NSDictionary * response){
            
            
            if([[response valueForKey:@"status"] boolValue]){
                
                [changeEmailPopup dismiss:YES];
                [self showEmailConfirmationPopup:[response valueForKey:@"message"]];
                [emailConfirmationPopup show];
                [_changeEmail resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
    
}

- (IBAction)closeChangeEmail:(id)sender {
    [changeEmailPopup dismiss:YES];
}


-(BOOL)changeEmailFormValidation{
    [self resetChangeEmailForm];
    
    //Validate email
    if(![Util validateTextField:_changeEmail withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetChangeEmailForm{
    [Util createBottomLine:_changeEmail withColor:UIColorFromHexCode(TEXT_BORDER)];
}

- (IBAction)doTouchCountryField:(id)sender
{
    if ([_country.text isEqualToString:@""]) {
        if ([countries count] > 0) {
            [self pickerView:countryPicker didSelectRow:0 inComponent:0];
        }
        [_country setTextColor:[UIColor blackColor]];
    }
}


//------------> Change location <----------------

#pragma mark Change Location

- (IBAction)setLocation:(id)sender {
    [self setLocationRequest];
}

- (IBAction)cancelSetLocation:(id)sender {
    [setLocationPopup dismiss:YES];
}

- (void)setLocationRequest {
    if ([self validateLocation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_locationField.text forKey:@"location"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:EDIT_LOCATION withCallBack:^(NSDictionary * response){
            //success case
            if([[response valueForKey:@"status"] boolValue]){
                
                [setLocationPopup dismiss:YES];
//                [self showEmailConfirmationPopup:[response valueForKey:@"message"]];
//                [emailConfirmationPopup show];
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
                [_locationField resignFirstResponder];
                _profileView.location.text = _locationField.text;
                [_profileView.location setTextColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
    }
}

- (BOOL)validateLocation{
    
//    [self resetEditNameForm];
    
    //Validate name
    if(![Util validateTextField:_locationField withValueToDisplay:LOCATION_TITLE withIsEmailType:FALSE withMinLength:LOCATION_NAME_MIN withMaxLength:LOCATION_NAME_MAX]){
        return NO;
    }
//    if(![Util validCharacter:_locationField forString:_locationField.text withValueToDisplay:LOCATION_TITLE]){
//        return NO;
//    }
//    if(![Util validateName:_locationField.text]){
//        [Util showErrorMessage:_locationField withErrorMessage:NSLocalizedString(INVALID_NAME, nil)];
//        return NO;
//    }
    
    return YES;
}

//------------> Change location ends <----------------


//------------> Set phone number <----------------

#pragma mark Set Phone Number

- (IBAction)setPhoneNumber:(id)sender {
    [self phoneNumberRequest];
    
}

-(void)phoneNumberRequest{
    if ([self phoneNumberFormValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_mobileNumber.text forKey:@"set_phone_number"];
        [inputParams setValue:countryId forKey:@"country_code_id"];
        
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_PHONE_NUMBER withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                
                //Hide the phone popup
                [setPhonePopup dismiss:YES];
                
                //Show OTP popup
                [self.otpView setHidden:NO];
                [otpPopup showWithLayout:layout];
                visibleWindow=4;
                
                //change timer and resend button visibitlity
                [_otpResendButton setHidden:YES];
                [_countdownLabel setHidden:NO];
                
                //Set otp time limit
                secondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
                countDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
                
                //Place the OTP as hint
                if(![[response valueForKey:@"view_otp"] boolValue])
                {
                    [_otpCode setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"OTP"] ] forKeyPath:@"_placeholderLabel.text"];
                }
                [_mobileNumber resignFirstResponder];
                
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
    
}
- (IBAction)cancelPhoneWindow:(id)sender {
    [setPhonePopup dismiss:YES];
}


//Set phone number validation
-(BOOL)phoneNumberFormValidation{
    [self resetPhoneForm];
    
    
    //Check coutry is choosed
    if([[_country.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:_country withErrorMessage:NSLocalizedString(COUNTRY_EMPTY, nil)];
        return FALSE;
    }
    //Check phone number
    if(![Util validateNumberField:_mobileNumber withValueToDisplay:PHONE_NO withMinLength:PHONE_MIN withMaxLength:PHONE_MAX])
    {
        return FALSE;
    }
    
    return YES;
}

//Reset the phone form
- (void)resetPhoneForm{
    [Util createBottomLine:_country withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_countryCode withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:_mobileNumber withColor:UIColorFromHexCode(TEXT_BORDER)];
    
}

//------------> Set phone number ends <----------------



//------------> OTP window  <----------------

-(void) updateCountdown {
    
    int minutes, seconds;
    secondsLeft--;
    minutes = (secondsLeft % 3600) / 60;
    seconds = (secondsLeft %3600) % 60;
    if (minutes < 0 ) {
        minutes = 0;
    }
    if (seconds < 0) {
        seconds = 0;
    }
    if (minutes == 0 && seconds == 0) {
        [countDown invalidate];
        countDown = nil;
        [_otpResendButton setHidden:NO];
        [_countdownLabel setHidden:YES];
        [_otpSubmitButton setEnabled:NO];
    }
    _countdownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    if (minutes == 0 && seconds == 0) {
        _countdownLabel.text = @"";
    }
}

- (IBAction)submitOTP:(id)sender {
    [self submitOTPRequest];
}
-(void)submitOTPRequest{
    if ([self otpFormValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_otpCode.text forKey:@"otp_number"];
        [inputParams setValue:countryId forKey:@"country_code_id"];
        
        if (havingPhoneNumber) {
            [inputParams setValue:_nePhoneNumber.text forKey:@"new_phone_number"];
        }
        else{
            [inputParams setValue:_mobileNumber.text forKey:@"new_phone_number"];
        }
        
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:VERIFY_OTP withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                //Hide the phone popup
                [otpPopup dismiss:YES];
                
                havingPhoneNumber = TRUE;
                
                [countDown invalidate];
                countDown = nil;
                
                [self getPlayerLoginStatus];
                [_otpCode resignFirstResponder];
            }
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            
            
        } isShowLoader:YES];
    }
    
}

- (IBAction)resendOTP:(id)sender {
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    NSString *url;
    if (havingPhoneNumber) {
        [inputParams setValue:_oldPhoneNumber.text forKey:@"old_phone_number"];
        [inputParams setValue:_nePhoneNumber.text forKey:@"new_phone_number"];
        [inputParams setValue:oldCountryId forKey:@"old_country_code_id"];
        [inputParams setValue:countryId forKey:@"new_country_code_id"];
        url = CHANE_PHONE_NUMBER;
    }else{
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_mobileNumber.text forKey:@"set_phone_number"];
        [inputParams setValue:countryId forKey:@"country_code_id"];
        url = SET_PHONE_NUMBER;
    }
    
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [_otpResendButton setHidden:YES];
            [_countdownLabel setHidden:NO];
            [_otpSubmitButton setEnabled:YES];
            
            //Set otp time limit
            secondsLeft = (int) [[response valueForKey:@"timer"] integerValue];
            [countDown invalidate];
            countDown = nil;
            countDown = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
            
            //Place the OTP as hint
            if(![[response valueForKey:@"view_otp"] boolValue])
            {
                [_otpCode setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"OTP"] ] forKeyPath:@"_placeholderLabel.text"];
            }
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:YES];
}

- (IBAction)cancelOTP:(id)sender {
    [countDown invalidate];
    _countdownLabel.text = @"";
    
    [otpPopup dismiss:YES];
    [countDown invalidate];
    [_otpSubmitButton setEnabled:YES];
}


//OTP forma validation
-(BOOL)otpFormValidation{
    [self resetOTPForm];
    
    //Check OTP code is empty
    if(![Util validateNumberField:_otpCode withValueToDisplay:OTP_TITLE withMinLength:OTP_MIN withMaxLength:OTP_MAX]){
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetOTPForm{
    [Util createBottomLine:_otpCode withColor:UIColorFromHexCode(TEXT_BORDER)];
}


//------------> OTP window ends  <----------------


//------------> Friends related code <------------

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak MyProfile *weakSelf = self;
    // setup infinite scrolling
    [self.profileTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [self.profileTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    // setup infinite scrolling for board
    [self.boardTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottomForBoard];
    }];
    
}

//Add load more items
- (void)insertRowAtBottom {
    
//    if((friendsPage > 0 && friendsPage != friendsPrevious && segment.selectedSegmentIndex == 1) || segment.selectedSegmentIndex == 0){
        __weak MyProfile *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            if (segment.selectedSegmentIndex == 0) {
            [weakSelf getProfileFeeds];
//            }
//            else{
//                [weakSelf getFriendsList];
//            }
        });
//    }
//    else{
//        NSLog(@"NO MORE CONTENTS...!");
//        [self.profileTable.infiniteScrollingView stopAnimating];
//    }
}

// Navigate to Photo List Page
-(void) photosBtnTapped {
    if (myIntPhotoCount > 0) {
        BookmarkViewController *aViewController = [BookmarkViewController new];
        aViewController.gStrSource = @"Images";
        aViewController.gStrFriendId = @"";
        [self.navigationController pushViewController:aViewController animated:YES];
    }
}

// Navigate to Video List Page
-(void) videosBtnTapped {
    if (myIntVideoCount > 0) {
        BookmarkViewController *aViewController = [BookmarkViewController new];
        aViewController.gStrSource = @"Videos";
        aViewController.gStrFriendId = @"";
        [self.navigationController pushViewController:aViewController animated:YES];
    }
    
}

//Navigate to Followers List Page
- (void)followBtntapped {
    
    MyFriends *myFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"MyFriends"];
    myFriends.isFromFollowers = YES;
    if (followCount > 0) {
        [self.navigationController pushViewController:myFriends animated:YES];
    }
}

//Navigate to Followers List Page
- (void)followingBtntapped {
    
    MyFriends *myFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"MyFriends"];
    myFriends.isFromFollowing = YES;
    if (followingCount > 0) {
        [self.navigationController pushViewController:myFriends animated:YES];
    }
}



//Add load more items
- (void)insertRowAtBottomForBoard {
    if(boardPage > 0){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak MyProfile *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf getBoardList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.boardTable.infiniteScrollingView stopAnimating];
    }
}


//Add empty message in table background view
- (void)addEmptyMessageForProfileTable{
    
//    if ([segment selectedSegmentIndex] == 1) {
//        if ([friendsList count] == 0) {
//            [Util addEmptyMessageToTableWithHeader:self.profileTable withMessage:NO_FRIENDS withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
//        }
//        else{
////            _profileTable.tableFooterView.hidden = YES;
//            _profileTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//        }
//    }
//    else{
        if ([feedList count] == 0) {
            [Util addEmptyMessageToTableWithHeader:self.profileTable withMessage:NO_FEEDS withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
        }
        else{
//            _profileTable.tableFooterView.hidden = YES;
            _profileTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
//    }
}


//Get friends list
-(void) getFriendsList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:friendsPage] forKey:@"page"];
    [inputParams setValue:@"" forKey:@"friend_id"];
    
    [_profileTable.infiniteScrollingView stopAnimating];
    
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:MY_FRIENDS withCallBack:^(NSDictionary * response){
        
        [_profileTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            if (strMediaUrl == nil) {
                strMediaUrl = [response objectForKey:@"media_base_url"];
            }
            friendsPage = [[response valueForKey:@"page"] intValue];
            [friendsList addObjectsFromArray:[[response objectForKey:@"friend_list"] mutableCopy]];
            [self addEmptyMessageForProfileTable];
            [_profileTable reloadData];
        }
        
    } isShowLoader:NO];
    
}

//----------------> friends code ends <------------------


#pragma mark - Attributed Label delegate
//- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
//    NSString *tag = [[label.text substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
//    [searchViewController searchFor:tag];
//    [self.navigationController pushViewController:searchViewController animated:YES];
//}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSString *tag = [[label.text substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([tag containsString:@"#"]) {
        SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
        [searchViewController searchFor:tag];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
    else if ([tag containsString:@"@"]) {
        InviteFriends *inviteFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
        NSString *stringWithoutSpecialChar = [tag stringByReplacingOccurrencesOfString:@"@" withString:@""];
        inviteFriends.getSearchString = stringWithoutSpecialChar;
        [self.navigationController pushViewController:inviteFriends animated:YES];
    }
//        CGPoint hitPoint = [label convertPoint:CGPointZero toView:self.profileTable];
//        NSIndexPath *indexpath = [self.profileTable indexPathForRowAtPoint:hitPoint];
//        if (![[[feedList objectAtIndex:indexpath.row] objectForKey:@"is_local"] isEqualToString:@"true"]) {
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//            FriendProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
//
//            //            profile.friendId = [feeds objectAtIndex:indexpath.row][@"post_owner_id"];
//            //            profile.friendName = [feeds objectAtIndex:indexpath.row][@"name"];
//            //profile.friendName = [feeds objectAtIndex:indexpath.row][@"name"];
//
//            profile.friendId = @"";
//            profile.friendName = @"";
//            profile.strNameTag = [tag stringByReplacingOccurrencesOfString:@"@" withString:@""];
//            [self.navigationController pushViewController:profile animated:YES];
//        }
//    }
//    else {
//        InviteFriends *inviteFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
//        NSString *stringWithoutSpecialChar = [tag stringByReplacingOccurrencesOfString:@"@" withString:@""];
//        inviteFriends.getSearchString = stringWithoutSpecialChar;
//        [self.navigationController pushViewController:inviteFriends animated:YES];
//    }
}

//Common Delegate for TTTAttributed Label
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
//    if (_profileView.name == label) {
//        [self showEditNamePopup];
//    }
//    else
    if (url != nil && ![[url absoluteString] isEqualToString:@""]){
        //Open Url
        [[UIApplication sharedApplication] openURL:url];
    }
    else if (label.tag != 2) {
        
        CGPoint position = [label convertPoint:CGPointZero toView:self.profileTable];
        NSIndexPath *indexPath = [self.profileTable indexPathForRowAtPoint:position];
        NSMutableDictionary *feed = [feedList objectAtIndex:indexPath.row];
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[feed valueForKey:@"post_id"] forKey:@"post_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [feed setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                [feed setValue:[NSNumber numberWithBool:FALSE] forKey:@"continue_reading_flag"];
                [_profileTable reloadData];
            }else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        } isShowLoader:NO];
    }
}

//- (void)moveToPostDetails:(UIImageView *)imageView index:(int)index{
//    _needToReload = 0;
//    [[FeedsDesign sharedInstance] moveToPostDetails:imageView index:index fromTable:_profileTable fromController:self fromSource:feedList mediaBase:feedImageUrl];
//}

-(void)ShowMenu:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:_profileTable];
    NSIndexPath *indexPath = [_profileTable indexPathForRowAtPoint:buttonPosition];
    menuPosition = indexPath;
    NSString * isShare = [feedList[indexPath.row][@"is_share"] stringValue];
    if ([isShare isEqualToString:@"1"]) {
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - _profileTable.contentOffset.y + _profileTable.frame.origin.y, 140, 40) menuItems:
                            @[NSLocalizedString(DELETE_MENU,nil)]];
    } else {
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(buttonPosition.x - 105, buttonPosition.y + 22 - _profileTable.contentOffset.y + _profileTable.frame.origin.y, 140, 90) menuItems:
                            @[NSLocalizedString(EDIT_MENU,nil),
                              NSLocalizedString(DELETE_MENU,nil)]];
    }
    
    self.menuPopover.menuPopoverDelegate = self;
    self.menuPopover.tag = 100;
    [self.menuPopover showInView:self.view];

    
//    UIMenuController *menucontroller=[UIMenuController sharedMenuController];
//    UIMenuItem *MenuitemA=[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) action:@selector(DeletePost:)];
//    [menucontroller setMenuItems:[NSArray arrayWithObjects:MenuitemA,nil]];
//    //menucontroller.arrowDirection = UIMenuControllerArrowDown;
//    
//    
//    menuPosition = indexPath;
//    //It's mandatory
//    [self becomeFirstResponder];
//    //It's also mandatory ...remeber we've added a mehod on view class
//    if([self canBecomeFirstResponder])
//    {
//        [menucontroller setTargetRect:CGRectMake(10,10, 0, 200) inView:tapRecognizer.view];
//        [menucontroller setMenuVisible:YES animated:YES];
//    }
}
-(void)ShowSharedMenu:(UITapGestureRecognizer *)tapRecognizer
{
    [self ShowMenu:tapRecognizer];
}

- (void) copy:(id) sender {
    // called when copy clicked in menu
}
- (void) menuItemClicked:(id) sender {
    // called when Item clicked in menu
}
- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(DeletePost:) /*|| selector == @selector(copy:)*/ /**<enable that if you want the copy item */) {
        return YES;
    }
    return NO;
}
- (BOOL) canBecomeFirstResponder {
    return YES;
}

// ------------- Edit post Start -----------------

- (void)editPost {
    if([[Util sharedInstance] getNetWorkStatus])
    {
        if ([feedList count] > menuPosition.row) {
            
            NSMutableDictionary *postInfo = [feedList objectAtIndex:menuPosition.row];

            EditPostViewController *editPostController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"EditViewController"];
            
            [editPostController setPostInfo:postInfo];
            
            [self.navigationController presentViewController:editPostController animated:YES completion:nil];
        }
    }
}

// ------------- Delete post Start ---------------

- (void)deletePost
{
    [yesNoPopup show];
}

- (void)DeletePost:(UIMenuController *)sender
{
    [yesNoPopup show];
}

-(void)deleteFeedPost
{
    [yesNoPopup dismiss:YES];
    
    NSString *strPostId = [NSString stringWithFormat:@"%@",[[feedList objectAtIndex:menuPosition.row] objectForKey:@"post_id"]];
    
    
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:strPostId  forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    NSString * isShare = [feedList[menuPosition.row][@"is_share"] stringValue];
    NSString * urlString;
    if ([isShare isEqualToString:@"1"]) {
        urlString = DELETE_SHARE_POST;
    } else {
        urlString = DELETE_POST;
    }
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:urlString withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            if ([isShare isEqualToString:@"1"]) {
                
                feedList = [NSMutableArray new];
                [self getProfileFeeds];
//                [_profileTable beginUpdates];
//                FeedCell *fCell = [_profileTable cellForRowAtIndexPath:menuPosition];
//                fCell.shareView.hidden = YES;
//                fCell.shareViewHeightConstraint.constant = 0.0;
//                [_profileTable endUpdates];
//                [_profileTable reloadData];
            } else {
                
                [_profileTable beginUpdates];
                [feedList removeObjectAtIndex:menuPosition.row];
                [_profileTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:menuPosition] withRowAnimation: UITableViewRowAnimationLeft];
                [_profileTable endUpdates];
            }
            
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
        else
        {
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}


#pragma mark YesNoPopDelegate
- (void)onYesClick{
    [self deleteFeedPost];
}

- (void)onNoClick{
    [yesNoPopup dismiss:YES];
}

// ------------- Delete post End  ----------------

// Click Star & Unstar
- (IBAction)Star:(id)sender
{
    [feedsDesign addStar:_profileTable fromArray:feedList forControl:sender];    
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender {
    
    [HELPER tapAnimationFor:sender withCallBack:^{
        
        [feedsDesign addBookmark:_profileTable fromArray:feedList forControl:sender];
    }];

}
// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_profileTable];
        NSIndexPath *path = [_profileTable indexPathForRowAtPoint:buttonPosition];
        NSString *star_post_id = [[feedList objectAtIndex:path.row] objectForKey:@"post_id"];
        selectedPostIndex = (int) path.row;
        Comments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
        NSDictionary *imageInfo = [feedList objectAtIndex:path.row];
        comment.postId = star_post_id;
        comment.mediaId = [imageInfo valueForKey:@"image_id"];
        comment.postDetails = [feedList objectAtIndex:path.row];
        [self.navigationController pushViewController:comment animated:YES];
    }
    else{
        [appDelegate.networkPopup show];
    }
}

//Append the media url with base
- (void)alterTheMediaList:(NSDictionary *)response{
    
    if([[response objectForKey:@"feed_list"] count] > 0) {
        for (int i=0; i< [[response objectForKey:@"feed_list"] count]; i++) {
            NSMutableDictionary *dict = [[[response objectForKey:@"feed_list"] objectAtIndex:i] mutableCopy];
            
            int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[dict valueForKey:@"post_id"] from:feedList type:1];
            
            if (postIndex == -1) {
                
                NSMutableDictionary *profileImage = [[dict objectForKey:@"posters_profile_image"] mutableCopy];
                [profileImage setValue: [NSString stringWithFormat:@"%@%@",feedImageUrl,[profileImage  valueForKey:@"profile_image"]] forKey:@"profile_image"];
                [dict setObject:profileImage forKey:@"posters_profile_image"];
                
                NSMutableArray *mediaList = [[dict valueForKey:@"image_present"] boolValue] ? [[dict objectForKey:@"image"] mutableCopy] : [[dict objectForKey:@"video"] mutableCopy];
                for (int i=0; i<[mediaList count]; i++) {
                    NSMutableDictionary *media = [[mediaList objectAtIndex:i] mutableCopy];
                    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",feedImageUrl,[media valueForKey:@"media_url"]];
                    [media setValue:imageUrl forKey:@"media_url"];
                    [media setValue:@"true" forKey:@"isEnabled"];
                    [mediaList replaceObjectAtIndex:i withObject:media];
                }
                
                if ([[dict valueForKey:@"image_present"] boolValue]) {
                    [dict setObject:mediaList forKey:@"image"];
                }
                else{
                    [dict setObject:mediaList forKey:@"video"];
                }
                
                [dict setValue:@"true" forKey:@"isEnabled"];
                
                // Add response array to the selected feed type
                [feedList addObject:dict];
            }
        }
        if ([[response objectForKey:@"feed_list"] count] != 0) {
            [_profileTable reloadData];
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [feedsDesign checkWhichVideoToEnable:_profileTable];
            });
        }
    }
//    else {
//        [_profileTable reloadData];
//    }
}

//Get user feeds
-(void) getProfileFeeds
{
    feedsLoading = YES;
    [self startLoading];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"" forKey:@"friend_id"];
    [inputParams setValue:@"0" forKey:@"recent"];
    
    if ([feedList count] == 0) {
        [inputParams setValue:@"0" forKey:@"post_id"];
    }
    else{
        [inputParams setValue:[[feedList lastObject] valueForKey:@"post_id"] forKey:@"post_id"];
    }
    
//    [self.profileTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:PROFILE_FEEDS withCallBack:^(NSDictionary * response)
     {
         feedsLoading = NO;
         [self stopLoading];
         [self.profileTable.infiniteScrollingView stopAnimating];
         if([[response valueForKey:@"status"] boolValue]){
             
             if (feedImageUrl == nil) {
                 feedImageUrl = [response objectForKey:@"media_base_url"];
             }
             [self alterTheMediaList:response];
             [self addEmptyMessageForProfileTable];
         }
         
     } isShowLoader:NO];
    
}

- (void)createMutableCopyForFeedsList:(NSMutableArray *)list{
    for (int i=0;i<[list count];i++) {
        NSMutableDictionary *feed = [[list objectAtIndex:i] mutableCopy];
        NSMutableDictionary *profileImage = [[feed objectForKey:@"posters_profile_image"] mutableCopy];
        [feed setObject:profileImage forKey:@"posters_profile_image"];
        [feedList addObject:feed];
    }
}

// Mute/Unmute Pressed

// Mute/Unmute Pressed

-(void)muteUnmutePressed:(UIButton*)sender {
    
    UIButton *btn = sender;
    //    btn.selected = !btn.selected;
    NSDictionary* userInfo;
    UIImage * aImgMute = [UIImage imageNamed:@"icon_mute"];
    UIImage * aImgUnMute = [UIImage imageNamed:@"icon_unmute"];
    
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    FeedCell *cell = (FeedCell*)[_profileTable cellForRowAtIndexPath:myIP];
    
    if (myBoolIsMutePressed) {
        myBoolIsMutePressed = false;
        userInfo = @{@"IsMuted": @"false"};
        [btn setImage:aImgUnMute forState:UIControlStateNormal];
        
    }
    
    else {
        myBoolIsMutePressed = true;
        userInfo = @{@"IsMuted": @"true"};
        [btn setImage:aImgMute forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MuteUnMuteNotification"
     object:self userInfo:userInfo];
    
    if ([feedList count] > sender.tag) {
        
        feedsDesign.feeds = feedList;
        feedsDesign.feedTable = _profileTable;
        feedsDesign.mediaBaseUrl= strMediaUrl;
        feedsDesign.viewController = self;
        feedsDesign.isVolumeClicked = YES;
        
        [feedsDesign designTheContainerView:cell forFeedData:[feedList objectAtIndex:sender.tag] mediaBase:strMediaUrl forDelegate:self tableView:_profileTable];
    }
}


@end
