//
//  InviteFriends.m
//  Varial
//
//  Created by jagan on 11/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "InviteFriends.h"
#import "HeaderView.h"
#import "UIImageView+AFNetworking.h"
#import "GoogleAdMob.h"
#import "InviteContactTableViewCell.h"
#import <Contacts/Contacts.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface InviteFriends () <MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) NSMutableArray *myContactAryInfo, *myContactAryInfoFilter;

@end

@implementation InviteFriends
@synthesize inviteFriendTableView;
@synthesize  inviteEmailView;
NSMutableArray *inviteFriendsList;
@synthesize myContactAryInfo, myContactAryInfoFilter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    page = previousPage = 1;
    inviteFriendsList = [[NSMutableArray alloc] init];
    myContactAryInfoFilter = [NSMutableArray new];
    emailInviteView = [[NetworkAlert alloc] init];
    emailInviteView.delegate = self;
    [self designTheView];
    [self setInfiniteScrollForTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisplayAd:) name:@"AdShown" object:nil];
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
    
    myContactAryInfo = [NSMutableArray new];
    
    self.segmentControlCategory.tintColor = [UIColor blackColor];
    
    // mySegmentControl.tintColor = HELPER.hexStringToUIColor(hex: COLOR_APP_PRIMARY)
    self.segmentControlCategory.selectedSegmentIndex = 0;
    
    [self.inviteFriendTableView registerNib:[UINib nibWithNibName:NSStringFromClass([InviteContactTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InviteContactTableViewCell class])];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    else { // r
        accessGranted = YES;
        [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        [self getContactsWithAddressBook:addressBook];
    }
    // Call from @ Text in Feeds
    if(self.getSearchString.length > 0){
        self.segmentControlCategory.hidden = YES;
        self.segmentControlHeightConstraint.constant = 0.0;
        self.searchField.text = self.getSearchString;
        search = YES;
        [self getSearchViaVarial];
    } else {
        self.segmentControlCategory.hidden = NO;
        self.segmentControlHeightConstraint.constant = 30.0;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [Util createBottomLine:_emailField withColor:UIColorFromHexCode(GREY_TEXT)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AdShown" object:nil];
}

- (void) didDisplayAd:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat height =[[userInfo objectForKey:@"height"] floatValue];
    _inviteFriendTableBottom.constant = height;
}

- (void)designTheView {
    [Util setPadding:_searchField];
    if(self.getSearchString.length > 0)
        [_headerView setHeader:NSLocalizedString(SEARCH_FRIEND, nil)];
    else
        [_headerView setHeader:NSLocalizedString(INVITE_FRIEND, nil)];
    
    [_headerView.logo setHidden:YES];
    
    inviteFriendTableView.hidden = YES;
    inviteEmailView.hidden = YES;
    [inviteFriendTableView sizeToFit];
    inviteFriendTableView.backgroundColor = [UIColor clearColor];
    inviteFriendTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_sendInviteButton withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_searchField addTarget:self  action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [Util createBottomLine:_emailField withColor:UIColorFromHexCode(GREY_TEXT)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak InviteFriends *weakSelf = self;
    // setup infinite scrolling
    [self.inviteFriendTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.inviteFriendTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak InviteFriends *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getSearchViaVarial];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.inviteFriendTableView.infiniteScrollingView stopAnimating];
    }
}

//Search box text change listener
- (void) textChangeListener :(UITextField *) searchBox {
    
    if (self.segmentControlCategory.selectedSegmentIndex == 1) {
        
        if (_searchField.text.length != 0) {
            
            NSMutableArray *aMArySearch = [NSMutableArray new];
            
            NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@",_searchField.text];
            
            NSArray *tempArray = [self.myContactAryInfo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@",_searchField.text]];
            
            aMArySearch = [NSMutableArray arrayWithArray:tempArray];
            
            [self updateContactFilterArray:aMArySearch];
            
            [inviteFriendTableView reloadData];
        }
        
        else {
            
            [self updateContactFilterArray:myContactAryInfo];
            [inviteFriendTableView reloadData];
        }
    }
    
    else {
        
        search = TRUE;
        if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        {
            inviteEmailView.hidden = YES;
            page = 1;
            if (task != nil) {
                [task cancel];
            }
            [self getSearchViaVarial];
        }
        else{
            [_clearButton setHidden:YES];
            [self.inviteFriendTableView setHidden:YES];
            inviteEmailView.hidden = YES;
        }
        
        if ([_searchField.text length] > 0) {
            
            [_clearButton setHidden:NO];
        }
    }
}


//Clear search field text
- (IBAction)tappedSearchClear:(id)sender
{
    if (self.segmentControlCategory.selectedSegmentIndex == 0) {
    
        search = FALSE;
        [_searchField setText:@""];
        [_clearButton setHidden:YES];
        [self.inviteFriendTableView setHidden:YES];
        inviteEmailView.hidden = YES;
    }
    
    else {
        [_searchField setText:@""];
        [_clearButton setHidden:YES];
    }
}

//---------------------------------------------------> Invite via varial <--------------------------------------------------//


// Check search result is empty
-(void)searchResultIsEmpty
{
    if ([inviteFriendsList count] == 0)
    {
        [Util addEmptyMessageToTableWithHeader:self.inviteFriendTableView withMessage:NO_RESULT_FOUND withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
    else
    {
        [Util addEmptyMessageToTableWithHeader:self.inviteFriendTableView withMessage:@"" withColor:[UIColor grayColor]];
    }
    
}

// API access for search via varial
-(void) getSearchViaVarial
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
//    if(self.getSearchString.length > 0)
//        [inputParams setValue:self.getSearchString forKey:@"key_search"];
//    else
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    if (search) {
        [inviteFriendTableView setHidden:NO];
    }
    else
    {
        [inviteFriendTableView setHidden:YES];
    }
    
    [Util addEmptyMessageToTableWithHeader:self.inviteFriendTableView withMessage:@"" withColor:[UIColor grayColor]];
    [self.inviteFriendTableView.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_VIA_VARIAL withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            [self.inviteFriendTableView.infiniteScrollingView stopAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [inviteFriendTableView setHidden:NO];
                //hide or show the search table
                if([_searchField.text isEqualToString:@""])
                    [inviteFriendTableView setHidden:YES];
                
                //Check to add or append the search result
                if (page == 1) {
                    [inviteFriendsList removeAllObjects];
                    strMediaUrl = [response objectForKey:@"media_url"];
                }
                
                // After pull to refresh if click the clear search box should hide the tableview
//                if (!search) {
//                    [inviteFriendTableView setHidden:YES];
//                }
                
                [inviteFriendsList addObjectsFromArray:[[response objectForKey:@"search_via_varial"] mutableCopy]];
                [inviteFriendTableView reloadData];
                
                page = [[response objectForKey:@"page"] intValue];
                
                [self searchResultIsEmpty];
                
                //Scroll to top
                [Util scrollToTop:inviteFriendTableView  fromArrayList:inviteFriendsList];
            });
        }
        
        
        else
        {
            // After pull to refresh if click the clear search box should hide the tableview
            if (!search) {
                [inviteFriendTableView setHidden:YES];
            }
        }
        
    } isShowLoader:NO];
}


//---------------------------------------------------> Invite via email <--------------------------------------------------//


// API access for search via email
- (IBAction)sendInvite:(id)sender
{
    if([self emailInviteValitation])
    {
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:_emailField.text forKey:@"email_id"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_VIA_EMAIL withCallBack:^(NSDictionary * response){
            
            if([[response valueForKey:@"status"] boolValue]){
                
                //Message for invitation via email shown
                [emailInviteView setNetworkHeader:[response objectForKey:@"message"]];
                emailInviteView.subTitle.text = _emailField.text;
                [emailInviteView.button setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
                [self message];
                [_emailField setText:@""];
                [_emailField resignFirstResponder];
                
            }
            else
            {
                [_emailField setText:@""];
                [_emailField resignFirstResponder];
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
            
        } isShowLoader:YES];
    }
    
}


// validate email
- (BOOL)emailInviteValitation
{
    [Util createBottomLine:_emailField withColor:UIColorFromHexCode(TEXT_BORDER)];
    
    if(![Util validateTextField:_emailField withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX])
    {
        return FALSE;
    }
    return YES;
}


//Popup for invitation via email
-(void)message
{
    inviteEmailPopup = [KLCPopup popupWithContentView:emailInviteView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [inviteEmailPopup show];
}



//---------------------------------------------------> Send invite <--------------------------------------------------//


// Action for invite button in tableview
- (IBAction)tappedInviteButton:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.inviteFriendTableView];
    NSIndexPath *path = [self.inviteFriendTableView indexPathForRowAtPoint:buttonPosition];
    UITableViewCell *rowSelected = [inviteFriendTableView cellForRowAtIndexPath:path];
    UIButton *button = (UIButton *)[rowSelected viewWithTag:16];
    [button setTitle:NSLocalizedString(@"Inviting", nil) forState:UIControlStateNormal];
    [self sendInviteFriend:path];
}


- (IBAction)showProfile:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.inviteFriendTableView];
    NSIndexPath *path = [self.inviteFriendTableView indexPathForRowAtPoint:buttonPosition];
    if([inviteFriendsList count] > path.row)
    {
        [sender setUserInteractionEnabled:NO];
        NSDictionary *friend = [inviteFriendsList objectAtIndex:path.row];
        FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        friendProfile.friendId = [friend valueForKey:@"friend_id"];
        friendProfile.friendName = [friend valueForKey:@"name"];
        [self.navigationController pushViewController:friendProfile animated:YES];
        [sender setUserInteractionEnabled:YES];
    }
}


// API access for send invite
-(void) sendInviteFriend:(NSIndexPath *)path
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    if([inviteFriendsList count] > path.row)
    {
        NSMutableDictionary *dic=[[inviteFriendsList objectAtIndex:path.row]mutableCopy];
        
        [inputParams setValue: [dic objectForKey:@"friend_id"] forKey:@"friend_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ADD_FRIEND withCallBack:^(NSDictionary * response){
            
            UITableViewCell *rowSelected = [inviteFriendTableView cellForRowAtIndexPath:path];
            UIImageView *plus=(UIImageView *)[rowSelected viewWithTag:15];
            UIButton *status=(UIButton *)[rowSelected viewWithTag:16];
            UIView *statusView =(UIView *)[rowSelected viewWithTag:17];
            
            if([[response valueForKey:@"status"] boolValue]){
                //invitation send
                [status setTitle:NSLocalizedString(@"Invited", nil) forState:UIControlStateNormal];
                [statusView setBackgroundColor:[UIColor grayColor]];
                [plus setImage:[UIImage imageNamed: @"invited.png"]];
                [dic setObject:@"1" forKey:@"relationship_status"];
                [inviteFriendsList replaceObjectAtIndex:path.row withObject:dic];
                [status removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            }else{
                [status setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
            }
            
        } isShowLoader:NO];
    }
}


#pragma mark - UITableViewDelegate method
//set number of rows in tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.segmentControlCategory.selectedSegmentIndex == 0 ? inviteFriendsList.count :myContactAryInfoFilter.count;
}

//set tableview content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentControlCategory.selectedSegmentIndex == 0) {
        
        static NSString *cellIdentifier = @"friendsCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        //Read elements
        UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
        UILabel *name =  (UILabel *)[cell viewWithTag:11];
        UILabel *points = (UILabel *) [cell viewWithTag:12];
        UILabel *rank = (UILabel *) [cell viewWithTag:13];
        UIImageView *plus=(UIImageView *)[cell viewWithTag:15];
        UIButton *status=(UIButton *)[cell viewWithTag:16];
        UIView *statusView =(UIView *)[cell viewWithTag:17];
        
        [Util createRoundedCorener:statusView withCorner:3];
        
        if([inviteFriendsList count] > indexPath.row)
        {
            NSDictionary *list = [inviteFriendsList objectAtIndex:indexPath.row];
            name.text = [list objectForKey:@"name"];
            points.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Points", nil),[list objectForKey:@"point"]];
            rank.text = [Util playerType:[[list objectForKey:@"player_type_id"] intValue] playerRank:[list objectForKey:@"rank"]]; //[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Rank", nil),[list objectForKey:@"rank"]];
            
            NSString *strURL = [NSString stringWithFormat:@"%@%@",strMediaUrl,[[inviteFriendsList objectAtIndex:indexPath.row]  objectForKey:@"profile_image"]];
            [profile setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
            
            [status removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            
            //Check Relationship status
            if([[list objectForKey:@"relationship_status"] integerValue]==0)
            {
                [status setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
                [statusView setBackgroundColor:[UIColor redColor]];
                [plus setImage:[UIImage imageNamed: @"invite.png"]];
                [status addTarget:self action:@selector(tappedInviteButton:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [status addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            if([[list objectForKey:@"relationship_status"] integerValue]==1)
            {
                [status setTitle:NSLocalizedString(@"Invited", nil) forState:UIControlStateNormal];
                [statusView setBackgroundColor:[UIColor grayColor]];
                [plus setImage:[UIImage imageNamed: @"invited.png"]];
            }
            
            else if([[list objectForKey:@"relationship_status"] integerValue]==2)
            {
                [status setTitle:NSLocalizedString(@"Accept", nil) forState:UIControlStateNormal];
                [statusView setBackgroundColor:[UIColor redColor]];
                [plus setImage:[UIImage imageNamed: @"accept.png"]];
            }
            
            else if([[list objectForKey:@"relationship_status"] integerValue]==4)
            {
                [status setTitle:NSLocalizedString(@"Friends", nil) forState:UIControlStateNormal];
                [statusView setBackgroundColor:[UIColor blackColor]];
                [plus setImage:[UIImage imageNamed: @"friendsTick.png"]];
            }
            
            //Add zoom
            //[[Util sharedInstance] addImageZoom:profile];
        }
        return cell;
    }
    
    else {
        
        InviteContactTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([InviteContactTableViewCell class])];

        aCell.gLblName.text = myContactAryInfoFilter[indexPath.row][@"name"];
        
        [HELPER roundCornerForView:aCell.gBtnInviteContact withRadius:5];
        
        aCell.gBtnInviteContact.tag = indexPath.row;
        
        [aCell.gBtnInviteContact addTarget:self action:@selector(inviteViaContactBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        return aCell;
    }

}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([inviteFriendsList count] > indexPath.row)
    {
        NSDictionary *friend = [inviteFriendsList objectAtIndex:indexPath.row];
        FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        friendProfile.friendId = [friend valueForKey:@"friend_id"];
        friendProfile.friendName = [friend valueForKey:@"name"];
        [self.navigationController pushViewController:friendProfile animated:YES];
    }
}

#pragma mark - Network delegate
- (void)onButtonClick {
    
    [inviteEmailPopup dismiss:YES];
}

- (IBAction)searchClick:(id)sender {
    
}

- (IBAction)segmentControlValueChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        
        _searchField.text = @"";
        
        _searchField.placeholder = SEARCH_NAME_EMAIL;

        self.constraintTblViewY.constant = 0;
        self.searchField.hidden = NO;
        self.searchButton.hidden = NO;
        [_clearButton setHidden:YES];

        if (inviteFriendsList.count == 0) {
            
            [inviteFriendTableView setHidden:YES];
        }
    }
    
    else if (sender.selectedSegmentIndex == 1) {
        
       // [self fetchContactsandAuthorization];
        
        _searchField.text = @"";

        _searchField.placeholder = SEARCH_BY_NAME;
        
        self.constraintTblViewY.constant = 0;
        self.searchField.hidden = NO;
        self.searchButton.hidden = NO;
        [_clearButton setHidden:YES];

        [inviteFriendTableView setHidden:NO];
    }
    
    [self.inviteFriendTableView reloadData];
}

- (void)inviteViaContactBtnTapped:(UIButton *)sender {

    [HELPER tapAnimationFor:sender withCallBack:^{

        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            NSString *iTunesLink = @"itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8";
            controller.body = [NSString stringWithFormat:@"Click the link and use Varial app - %@",iTunesLink];
            controller.recipients = [NSArray arrayWithObjects:myContactAryInfoFilter[sender.tag][@"phone"], nil];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//
//-(void)fetchContactsandAuthorization
//{
////    // Request authorization to Contacts
////    CNContactStore *store = [[CNContactStore alloc] init];
////    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
////        if (granted == YES)
////        {
////            //keys with fetching properties
////            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
////            NSString *containerId = store.defaultContainerIdentifier;
////            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
////            NSError *error;
////            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
////            if (error)
////            {
////                NSLog(@"error fetching contacts %@", error);
////            }
////            else
////            {
////                NSString *phone;
////                NSString *fullName;
////                NSString *firstName;
////                NSString *lastName;
////                UIImage *profileImage;
////                NSMutableArray *contactNumbersArray = [[NSMutableArray alloc]init];
////                for (CNContact *contact in cnContacts) {
////                    // copy data to my custom Contacts class.
////                    firstName = contact.givenName;
////                    lastName = contact.familyName;
////                    if (lastName == nil) {
////                        fullName=[NSString stringWithFormat:@"%@",firstName];
////                    }else if (firstName == nil){
////                        fullName=[NSString stringWithFormat:@"%@",lastName];
////                    }
////                    else{
////                        fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
////                    }
////                    UIImage *image = [UIImage imageWithData:contact.imageData];
////                    if (image != nil) {
////                        profileImage = image;
////                    }else{
////                        profileImage = [UIImage imageNamed:@"person-icon.png"];
////                    }
////                    for (CNLabeledValue *label in contact.phoneNumbers) {
////                        phone = [label.value stringValue];
////                        if ([phone length] > 0) {
////                            [contactNumbersArray addObject:phone];
////                        }
////                    }
////                    NSDictionary* personDict = [[NSDictionary alloc] initWithObjectsAndKeys: fullName,@"fullName",profileImage,@"userImage",phone,@"PhoneNumbers", nil];
////                    [myContactAryInfo addObject:personDict];
////
////                }
////            }
////        }
////    }];
//
//    CNContactStore *store = [[CNContactStore alloc] init];
//    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if (granted == YES) {
//            //keys with fetching properties
//            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
//            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
//            NSError *error;
//            BOOL success = [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop) {
//                if (error) {
//                    NSLog(@"error fetching contacts %@", error);
//                } else {
//
//                    NSMutableDictionary *aMDict = [NSMutableDictionary new];
//                    aMDict[@"fullName"] = [NSString stringWithFormat:@"%@ %@", contact.givenName, contact.givenName]
//                    aMDict[@"PhoneNumbers"] = contact.phoneNumbers;
//
//                    [self.myContactAryInfo addObject:aMDict];
//                }
//            }];
//        }
//    }];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        [self.inviteFriendTableView reloadData];
//
//    });
//}

// Get the contacts.
- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
//        NSString * checkStrLen = (__bridge NSString *)lastName;
    
        if(((__bridge NSString *)lastName).length > 0){
            [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        } else {
            [dOfPerson setObject:[NSString stringWithFormat:@"%@", firstName] forKey:@"name"];
        }
        
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        
        if(ABMultiValueGetCount(eMail) > 0) {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
        }
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, j);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
                break ;
            }
            
            else {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
                break ;
            }
        }
        [myContactAryInfo addObject:dOfPerson];
    }
    
    [self updateContactFilterArray:myContactAryInfo];

    NSLog(@"Contacts = %@",myContactAryInfo);
}


- (void)updateContactFilterArray:(NSMutableArray *)aContactArray {

    myContactAryInfoFilter = aContactArray;
}

@end
