//
//  ViewController.m
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ViewController.h"
#import "GoogleAdMob.h"
#import "InviteFriends.h"
#import "FeedsDesign.h"
#import "FeedsViewController.h"
#import "BookmarkViewController.h"
#import "FeedSearchViewController.h"
#import <MIBadgeButton/MIBadgeButton.h>
#import <GoogleMaps/GMSGeometryUtils.h>

#import "Varial-Swift.h"

@interface ViewController ()
{
    FeedsDesign *feedsDesign;
    int currentPage;
}
@end

@implementation ViewController
@synthesize publicFeeds, privateFeeds, friendsFeeds, teamAFeeds, teamBFeeds, popularFeeds;

NSArray *storyBoardNames;
NSMutableDictionary *content;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    popularFeeds = [[NSMutableArray alloc]init];
    publicFeeds = [[NSMutableArray alloc]init];
    privateFeeds = [[NSMutableArray alloc]init];
    friendsFeeds = [[NSMutableArray alloc]init];
    teamAFeeds = [[NSMutableArray alloc]init];
    teamBFeeds = [[NSMutableArray alloc]init];
    _feedTypeList = [[NSMutableArray alloc]init];
    _uploadCancelArray = [[NSMutableArray alloc]init];
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _selectedFeedType = @"6";
    currentPage = 0;
    
    [self initiateTheWindow];
    [self showAddUser];

    //hide back
    [_headerView.logo setHidden:NO];
    [_headerView setBackHidden:YES];
    [_headerView setFeedTypeHidden:NO];
    _headerView.delegate = self;
    [_headerView setBookmarkHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateEmailWindow:) name:@"ActivateEmailAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:@"ChangeNotificationCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotificationCount:) name:@"TeamNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotificationCount:) name:@"GeneralNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotificationCount:) name:@"FriendNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBadge) name:@"RemoveBadge" object:nil];

    delegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    delegate.showLoaderOnAppEnter = YES;
//    [delegate refreshNotification];
    
    //[_tabBar setItemWidth:[Util getWindowSize].width/4];
    [_tabBar setItemWidth:[Util getWindowSize].width/5];
    [_tabBar setNeedsLayout];
//    [_tabBar setSelectionIndicatorImage:[Util convertColorToImage:UIColorFromHexCode(THEME_COLOR) byDivide:5 withHeight:49]];
//    self.tabBar.itemPositioning = UITabBarItemPositioningCentered;
    self.tabBar.itemPositioning = UITabBarItemPositioningFill;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
     feedsDesign = [[FeedsDesign alloc] init];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    if (IPAD) {
//        [_tabBar setSelectionIndicatorImage:[Util convertColorToImage:UIColorFromHexCode(THEME_COLOR) byDivide:5 withHeight:49]];
        self.tabBar.itemPositioning = UITabBarItemPositioningFill;
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tabBar invalidateIntrinsicContentSize];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [emailAlertPopup dismiss:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    delegate.shouldAllowRotation = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (screenSize.height == 812){
            NSLog(@"iPhone X");
            self.myConstraintTabBarHeight.constant = 70.0;
            self.myConstraintHeaderviewTop.constant = 25.0;
        }
        else {
            self.myConstraintTabBarHeight.constant = 40.0;
            self.myConstraintHeaderviewTop.constant = 20.0;
        }
    }
    
    
//    NSLog(@"%@",[[UIDevice currentDevice] identifierForVendor]);
    // Reload the notification count
    [delegate refreshNotification];
}

- (void) viewDidUnload{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ConfirmEmailNotification" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ActivateEmailAlert" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FriendNotification" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeneralNotification" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChangeNotificationCount" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TeamNotification" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemoveBadge" object:nil];
    
}

//change notification count
-(void) processNotificationCount:(NSNotification *) data{
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    NSMutableDictionary *body = [[notificationContent objectForKey:@"data"] mutableCopy];
    if ([[notificationContent objectForKey:@"type"] isEqualToString:@"general_notification"] || [[notificationContent objectForKey:@"type"] isEqualToString:@"team_notification"]) {
             [[NSUserDefaults standardUserDefaults] setObject:[body valueForKey:@"general_notification_count"] forKey:@"globalNotificationCount"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:[body valueForKey:@"friend_notification_count"] forKey:@"friendNotificationCount"];
    }
        int count = [[body valueForKey:@"general_notification_count"] intValue] + [[body valueForKey:@"friend_notification_count"] intValue];
        NSString *countString = [self getFormatedCount: count];
    
    if(count == 0) {
        UIImage * aImage = [UIImage imageNamed:@"icon_notification"];
//        [_headerView.btnSearchIcon setBackgroundImage:aImage forState:UIControlStateNormal];
        [_headerView.btnSearchIcon setImage:aImage forState:UIControlStateNormal];
        [_headerView.btnSearchIcon setBackgroundColor:[UIColor clearColor]];
    }
    
    else {
        UIImage * aImage = [UIImage imageNamed:@""];
        [_headerView.btnSearchIcon setImage:aImage forState:UIControlStateNormal];
//        [_headerView.btnSearchIcon setBackgroundImage:aImage forState:UIControlStateNormal];

        //        [_headerView.btnSearchIcon setImage:nil forState:UIControlStateNormal];
        //        [self changeTabBarBadge:1 toDisplay:countString];
        [_headerView.btnSearchIcon setTitle:countString forState:UIControlStateNormal];
        [_headerView.btnSearchIcon setBackgroundColor:[UIColor redColor]];
        //    [_headerView setNotificationBtnCount:countString];
        [_headerView.btnSearchIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    
}

//change notification count after receiving data from api
-(void) processNotification:(NSNotification *) data{
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    if(_tabBar.selectedItem.tag != 1)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[notificationContent valueForKey:@"friend_notification_count"] forKey:@"friendNotificationCount"];
        [[NSUserDefaults standardUserDefaults] setObject:[notificationContent valueForKey:@"general_notification_count"] forKey:@"globalNotificationCount"];
    }
    [self setNotificationCount];

}

//Convert the count
-(NSString *)getFormatedCount:(int)count{
    NSString *countString = count > 9 ? @"9+" : [NSString stringWithFormat:@"%d",count];
    return [countString isEqualToString:@"0"] ? @"0" : countString;
}


//Hide icon after email verified
-(void) emailConfirmed:(NSNotification *) data{

    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    [emailAlertPopup dismiss:YES];
    [_emailAlertIcon setHidden:YES];
    [[AlertMessage sharedInstance] showMessage:[[notificationContent objectForKey:@"data"] valueForKey:@"message"] withDuration:3];

}

//Show email alert icon if email is not verified
-(void) activateEmailWindow:(NSNotification *) data{
    
    //check for email confirmation
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isEmailVerified"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
        [_emailAlertIcon setHidden:NO];
    }
}

- (void)initiateTheWindow{
    
//    storyBoardNames = [[NSArray alloc] initWithObjects:@"Feeds",@"FriendsNotification",@"GeneralNotification",@"MainMenu",@"CreatePostViewController", nil];
//    storyBoardNames = [[NSArray alloc] initWithObjects:@"Feeds",@"FriendsNotification",@"GeneralNotification",@"MainMenu", nil];
   
    
    storyBoardNames = [[NSArray alloc] initWithObjects:@"Feeds",@"FeedSearchViewController",@"GeneralNotification",@"MyProfile", nil];
    
//    NSString * aGetValue = [storyBoardNames objectAtIndex:4];
    //Hided @"FriendsNotification",@"GeneralNotification"
    // FSearchViewController  changed 21-4-2017 Hided
    
   //storyBoardNames = [[NSArray alloc] initWithObjects:@"FeedsViewControllerId",@"FriendsNotification",@"GeneralNotification",@"MyProfile", nil];

    [self setUpTabItems];
    [self setUpHomeInterface];
    [self.view bringSubviewToFront:_emailAlertIcon];
    
    [self createEmailAlertView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEmailAlert:)];
    [_emailAlertIcon setUserInteractionEnabled:YES];
    [_emailAlertIcon addGestureRecognizer:tap];
}

- (void)createEmailAlertView{
    EmailAlert *emailAlert = [[EmailAlert alloc] init];
    emailAlert.message.text = NSLocalizedString(EMAIL_VERIFICATION, nil);
    
    emailAlertPopup = [KLCPopup popupWithContentView:emailAlert showType:KLCPopupShowTypeBounceInFromLeft dismissType:KLCPopupDismissTypeBounceOutToRight maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutTop);
}



//Set up the tab bar items
- (void) setUpTabItems{
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    for (UITabBarItem *item in self.tabBar.items){
        item.imageInsets = UIEdgeInsetsMake(6,0, -6, 0);
//        item.imageInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        item.title = nil;
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
//    [self.tabBar.items objectAtIndex:2].image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    [self.tabBar setShadowImage:[Util imageFromColor:[UIColor colorWithWhite:0.1 alpha:1.0] forSize:CGSizeMake(1, 1) withCornerRadius:0]];
}

//Setup the tab bar with swipe
- (void) setUpHomeInterface{
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPager"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Change the size of page view controller
    float headerHeight = self.headerView.frame.size.height;
    float offset = self.headerView.frame.origin.y;
    
    self.pageViewController.view.frame = CGRectMake(0, headerHeight + offset, self.view.frame.size.width, self.view.frame.size.height - (self.tabBar.frame.size.height + headerHeight + offset));

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
//    [self.view sendSubviewToBack:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.view sendSubviewToBack:self.tabBar];
    [self.view sendSubviewToBack:self.pageViewController.view];
    
    //Set current page
    [self setCurrentPage:0];

}

//Set current page in pager
- (void) setCurrentPage:(int)index{
    
//    MyProfile *vc = [[UIStoryboard storyboardWithName:@"Temp" bundle:nil] instantiateViewControllerWithIdentifier:@"MyProfile"];
////    FriendProfile *vc = [[UIStoryboard storyboardWithName:@"Temp" bundle:nil] instantiateViewControllerWithIdentifier:@"FriendProfile"];
////    [vc setFriendId:@"147"];
//    
//    [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//    
//    [vc setHeaderVisible:NO];
//    
//    return;
    
    UIViewController* viewController = [self viewControllerAtIndex:index];
    NSArray *viewControllers = @[viewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [_headerView setHeader:@""];
    currentPage = index;
    
//    if ([viewController respondsToSelector:@selector(setHeaderVisible:)] {
    if ([viewController isKindOfClass:[MyProfile class]]) {
        [(MyProfile *)viewController setHeaderVisible:NO];
    }
}

//Change tabbar badge count
- (void)changeTabBarBadge:(int)index toDisplay:(NSString *)count
{
    // Hided changes search icon to badge icon
//      UITabBarItem *itemToBadge = self.tabBar.items[index];
//    if ([count isEqualToString:@""] || [count isEqualToString:@"0"]) {
//        itemToBadge.badgeValue = nil;
//    }
//    else{
//        itemToBadge.badgeValue = count;
//    }
    
    [_headerView setNotificationBtnCount:count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{    
    if ([viewController isKindOfClass:[Feeds class]]) {
        return nil;
    }
    else if([viewController isKindOfClass:[FriendsNotification class]]) {
        return [self viewControllerAtIndex:0];
    }
    else if([viewController isKindOfClass:[GeneralNotification class]]) {
        return [self viewControllerAtIndex:1];
    }
    else {
        return [self viewControllerAtIndex:2];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[Feeds class]]) {
        [self needToScroll:YES];
        return [self viewControllerAtIndex:1];
    }
    else if([viewController isKindOfClass:[FeedSearchViewController class]]) { //FriendsNotification
        [self needToScroll:YES];
        return [self viewControllerAtIndex:2];
    }
    else if([viewController isKindOfClass:[GeneralNotification class]]) { //hided for need to show search in tabbar 21-4-2017
        [self needToScroll:NO];
        return [self viewControllerAtIndex:3];
    }
    else  {
        [self needToScroll:YES];
        return nil;
    }
}

- (void) needToScroll :(BOOL) scroll
{
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            if (scroll) {
                view.scrollEnabled = YES;
            }
            else
            {
                view.scrollEnabled = NO;
            }
        }
    }
    
    
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create a new view controller and pass suitable data.
    UIViewController *contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardNames[index]];
   
    if(index == 0){
        [self.headerView setBookmarkHidden:YES];
        [self.headerView setSearchIconHidden:NO];
    } else if(index == 1){
        [self.headerView setBookmarkHidden:YES];
        [self.headerView setSearchIconHidden:YES];
    } else if(index == 3){
        [self.headerView setBookmarkHidden:NO];
        [self.headerView setSearchIconHidden:YES];
    }
//    [_headerView setBookmarkHidden:index == 3 ? NO : YES];
//    [_headerView setSearchIconHidden:index == 0 ? NO : YES];
//    [_headerView setSearchIconHidden:index == 1 ? NO : NO];
    
    return contentViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    NSLog(@"pageViewController transition complete");
    [feedsDesign stopAllVideos];
    [self showFeedTypeSelector:NO];
    UIViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    if ([currentViewController isKindOfClass:[Feeds class]]) {
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
        [feedsDesign playVideoConditionally];
        [self showFeedTypeSelector:YES];
    }
    else if([currentViewController isKindOfClass:[FeedSearchViewController class]]) { //FriendsNotification Changed 21-4-18 Hided
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:1]];
        if(_tabBar.selectedItem.tag == 1)
        [self setNotificationCount];
    }
    else if([currentViewController isKindOfClass:[GeneralNotification class]]) {
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:3]];
    }
    else  {
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:4]];
    }
    _tabBar.userInteractionEnabled = YES;
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    _tabBar.userInteractionEnabled = NO;
    
}

//Triggered when tabbar item clicked
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 2) { // This is the map view
        [self needToScroll:NO];
    }
    else{
        [self needToScroll:YES];
        // Clear Mail when switch the tab for memory management
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveMapDelegate" object:nil];
    }
    
    //Set current page
    if ((int)item.tag == 4) {
        [self newPost];
//        return;
    } else {
        [self setCurrentPage:(int)item.tag];
    }
    
    if(item.tag == 1) {
        [self setNotificationCount];
    }
    
    if(item.tag == 0) {
        [self showFeedTypeSelector:YES];
        [feedsDesign playVideoConditionally];
    } else {
        [self showFeedTypeSelector:NO];
        [feedsDesign stopAllVideos];
    }
    
//    [_tabBar setSelectionIndicatorImage:[Util convertColorToImage:UIColorFromHexCode(THEME_COLOR) byDivide:5 withHeight:49]];
}

- (void)newPost {
    if([[Util sharedInstance] getNetWorkStatus])
    {
//        CreatePostViewController *createPostViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
    
    
        UINavigationController *createPostNavController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateInitialViewController];
        // Post storyboard initializes with the CreatePostViewController
        CreatePostViewController *rootViewController = [createPostNavController.viewControllers firstObject];
        rootViewController.delegate = self;
    
//        createPostViewController.isPostFromFeeds = feedTypeId;
//        if([self teamPost])
//        {
//            createPostViewController.isPostFromFeeds = nil;
//            createPostViewController.isPostFromTeam = selectedFeedTypeName;
//        }
//        
//        [self.navigationController pushViewController:createPostViewController animated:YES];
        int index = currentPage < 2 ? currentPage : currentPage + 1;
        [_tabBar setSelectedItem:[_tabBar.items objectAtIndex:index]];
    
        [self.navigationController presentViewController:createPostNavController animated:YES completion:nil];
    
    }
    else{
        [delegate.networkPopup show];
    }
}

- (void)newPostWasPosted:(int)feedId {
    [self showFeedTypeSelector:YES];
    
    NSString *selectedType;
    // Public And Friends feeds
    if (feedId == 0 || feedId == 2) {
        selectedType = @"1";
    }
    // Private Feeds
    else if (feedId == 1) {
        selectedType = @"2";
    }
    // Team A Feeds
    else if (feedId == 3){
        selectedType = @"3";
    }
    // Team B Feeds
    else if (feedId == 4){
        selectedType = @"4";
    }
    
    self.selectedFeedType = selectedType;
    [self setCurrentPage:0];
    [self.tabBar setSelectedItem:[[self.tabBar items] objectAtIndex:0]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Add post info to feed for display and upload
- (void)newPost:(NSDictionary *)postInfo forFeed:(int)feedId {
    [self showFeedTypeSelector:YES];
    
    NSString *selectedType;
    // Public And Friends feeds
    if (feedId == 0 || feedId == 2) {
        [self.publicFeeds insertObject:postInfo atIndex:0];
        selectedType = @"1";
    }
    // Private Feeds
    else if (feedId == 1) {
        [self.privateFeeds insertObject:postInfo atIndex:0];
        selectedType = @"2";
    }
    // Team A Feeds
    else if (feedId == 3){
        [self.teamAFeeds insertObject:postInfo atIndex:0];
        selectedType = @"3";
    }
    // Team B Feeds
    else if (feedId == 4){
        [self.teamBFeeds insertObject:postInfo atIndex:0];
        selectedType = @"4";
    }

    self.selectedFeedType = selectedType;
    [self setCurrentPage:0];
    [self.tabBar setSelectedItem:[[self.tabBar items] objectAtIndex:0]];
}

-(void)removeBadge{
    [self setNotificationCount];
}

//Show email activation alert
- (void)showEmailAlert:(UITapGestureRecognizer *)tapRecognizerr {
    [emailAlertPopup showWithLayout:layout];
}
-(void)setNotificationCount{
    int count = [[Util getFromDefaults:@"globalNotificationCount"] intValue] + [[Util getFromDefaults:@"friendNotificationCount"] intValue];
    
    NSString *countString = [self getFormatedCount: count];
    
    if(count == 0) {
        UIImage * aImage = [UIImage imageNamed:@"icon_notification"];
        
//        [_headerView.btnSearchIcon setBackgroundImage:aImage forState:UIControlStateNormal];

        [_headerView.btnSearchIcon setImage:aImage forState:UIControlStateNormal];
        [_headerView.btnSearchIcon setBackgroundColor:[UIColor clearColor]];
    }
    
    else {
        UIImage * aImage = [UIImage imageNamed:@""];
        [_headerView.btnSearchIcon setImage:aImage forState:UIControlStateNormal];
//        [_headerView.btnSearchIcon setBackgroundImage:aImage forState:UIControlStateNormal];

//        [_headerView.btnSearchIcon setImage:nil forState:UIControlStateNormal];
//        [self changeTabBarBadge:1 toDisplay:countString];
        [_headerView.btnSearchIcon setTitle:countString forState:UIControlStateNormal];
        [_headerView.btnSearchIcon setBackgroundColor:[UIColor redColor]];
        //    [_headerView setNotificationBtnCount:countString];
        [_headerView.btnSearchIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
}

-(void)reloadGeneralNotification
{
    FriendsNotification *general = [[FriendsNotification alloc] init];
    general.isFriendNotification = FALSE;
    general.generalPage = 1;
    [general getNotificationListToSave];
}

-(void)reloadFriendNotification
{
    FriendsNotification *friend = [[FriendsNotification alloc] init];
    friend.isFriendNotification = TRUE;
    friend.page = 1;
    [friend getNotificationListToSave];
}

#pragma mark - HeaderViewDelegate methods
- (void)feedTypeSelectorShouldOpen:(id)sender {
    if (currentPage == 0) {
        UIViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        if ([currentViewController isKindOfClass:[Feeds class]]) {
            [(Feeds *)currentViewController showFeedTypes];
        }
    }
}

- (void)optionPressed {
    [self moveToAddFriends:nil];
}

- (void)bookmarkBtnTapped {
//    FeedSearchViewController *aViewController = [FeedSearchViewController new];
    BookmarkViewController *aViewController = [BookmarkViewController new];
    aViewController.gStrSource = @"";
//    UINavigationController *aNavi = [[UINavigationController alloc]initWithRootViewController:aViewController];
    [self.navigationController pushViewController:aViewController animated:YES];
//    [self.navigationController presentViewController:aNavi animated:YES completion:nil];
}

- (void)searchBtnTapped {
    
    FriendsNotification *notification = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsNotification"];
    [self.navigationController pushViewController:notification animated:YES];
    
   
}

- (void)showFeedTypeSelector:(BOOL)show {
    [_headerView setFeedTypeHidden:!show];
}

- (void)setFeedType:(int)type {
    [_headerView setFeedType:type];
}

-(void)showAddUser
{
    [_headerView setOptionHidden:NO];
    [_headerView setOptionImage:[UIImage imageNamed:@"addFriendIcon"] forState:UIControlStateNormal];
    [_headerView setBookmarkHidden:NO];

//    UIButton *addUser = [[UIButton alloc] init];
//    [addUser setBackgroundImage:[UIImage imageNamed:@"adduser.png"] forState:UIControlStateNormal];
//    UIButton *addUser = [UIButton buttonWithType:UIButtonTypeSystem];
//    addUser.layer.masksToBounds = YES;
//    [addUser setTranslatesAutoresizingMaskIntoConstraints:NO];
//    
//    
//    [addUser setImage:[UIImage imageNamed:@"addFriendIcon"] forState:UIControlStateNormal];
//    [addUser setTintColor:[UIColor blackColor]];
//    
//    [addUser addTarget:self action:@selector(moveToAddFriends:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:addUser];
//    
//    //Add auto layout constrains for the banner
//    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (addUser);
//    
//    NSString *verticalConstraint = [NSString stringWithFormat:@"V:|-20-[addUser(50)]"];
//    [self.view addConstraints:[NSLayoutConstraint
//                                constraintsWithVisualFormat:verticalConstraint
//                                options:NSLayoutFormatAlignAllTop metrics:nil
//                                views:viewsDictionary]];
//    
//    int intent = CHAT_ENABLED ? 50 : 5;
//    NSString *horizontalConstraint = [NSString stringWithFormat:@"H:[addUser(50)]-%d-|",intent];
//    [self.view addConstraints:[NSLayoutConstraint
//                                constraintsWithVisualFormat:horizontalConstraint
//                                options:NSLayoutFormatAlignAllRight metrics:nil
//                                views:viewsDictionary]];
//
//    [self.view layoutIfNeeded];
    
}

-(IBAction)moveToAddFriends:(id)sender
{
    InviteFriends *inviteFriends = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
    [self.navigationController pushViewController:inviteFriends animated:YES];
}
@end
