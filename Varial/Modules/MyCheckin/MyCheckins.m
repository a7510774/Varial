//
//  MyCheckins.m
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MyCheckins.h"
#import "MyCheckinDetails.h"
#import "CreatePostViewController.h"
#import "BaiduPopularCheckin.h"

@interface MyCheckins (){
    int pageNumber;
}

@end

@implementation MyCheckins

NSMutableArray *myCheckins;

- (void)viewDidLoad {
    [super viewDidLoad];
    _googleMap.delegate = self;
    // Do any additional setup after loading the view.
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    myCheckins = [[NSMutableArray alloc] init];
    placesList = [[NSMutableArray alloc] init];
    poweredView = [[UIView alloc] init];
    
    baiduMap = [[BaiduMap alloc] init];
    baiduMap.delegate = self;
    
    page = previousPage = 1;
    [_allCheckInBaidu setHidden:YES];
    [_allCheckInView setHidden:YES];
    [self designTheView];
    [self setInfiniteScrollForTableView];
    [self reloadList];
    [self getAllPopularCheckins];
    [self addPoweredBy];
    
    //Add poweredBy google
    [self addPoweredBy:_placesAutoComplete];
    
}

//Add poweredBy google in autocomplete table view
- (void)addPoweredBy:(UITableView *)tableView{
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 300, 20)];
    footer.backgroundColor = [UIColor whiteColor];
    UIImageView *powerdBy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poweredby.png"]];
    powerdBy.backgroundColor = [UIColor whiteColor];
    powerdBy.frame = CGRectMake(10, 0, 300, 20);
    powerdBy.contentMode = UIViewContentModeLeft;
    [footer addSubview:powerdBy];
    tableView.tableFooterView = footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askBackConfirm:) name:@"BackPressed" object:nil];
    [[LocationManager sharedManager] startUpdateLocation];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [Util createBottomLine:_cityField withColor:[UIColor darkGrayColor]];
    [Util createBottomLine:_categeoriesField withColor:[UIColor darkGrayColor]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackPressed" object:nil];
}

//Check posting is going on
-(void) askBackConfirm:(NSNotification *) data{
    
    // if Current page = 0 is an GOOGLE MAP
    // IF current page = 1 is an BAIDU Search page -> if click back navigate to Menu page
    // IF current page = 2 is an BAIDU List page -> if click back navigate to Search page
    // IF current page = 3 is an BAIDU Map page -> if click back navigate to List page
    if (selectedTabBar == 1 || currentPage == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if (currentPage == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if(currentPage == 2)
        {
            [self showSearchPage];
            currentPage = 1;
        }
        else if (currentPage == 3)
        {
            [self showListPage];
            currentPage = 2;
        }
    }
}


//Add powered By logo
- (void)addPoweredBy{
    
    UIImageView *poweredBy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered_by_google_on_non_white.png"]];
    poweredBy.frame = CGRectMake(10, 5, 150, 40);
    poweredView.backgroundColor = [UIColor blackColor];
    poweredBy.contentMode = UIViewContentModeScaleAspectFit;
    
    [poweredView addSubview:poweredBy];
    [self.view addSubview:poweredView];
    
    [poweredView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //Add auto layout constrains for the banner
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (poweredView);
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[poweredView(50)]-20-|"
                               options:NSLayoutFormatAlignAllBottom metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-20-[poweredView(170)]"
                               options:NSLayoutFormatAlignAllCenterY metrics:nil
                               views:viewsDictionary]];
}

- (void)viewDidUnload{
    [[LocationManager sharedManager] stopUpdateLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
}

- (void)designTheView{
    
    selectedTabBar = 1;
    currentPage = 1;
    
    [_headerView setHeader:NSLocalizedString(MY_CHECKINS, nil)];
    
    _headerView.restrictBack = TRUE;
    
    //Set transparent color to tableview
    [self.checkinTable setBackgroundColor:[UIColor clearColor]];
    _placesAutoComplete.backgroundColor = [UIColor clearColor];
    self.checkinTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.placesAutoComplete.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.placeSearchTableBiadu.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _addCheckin.layer.cornerRadius = _addCheckin.frame.size.height / 2 ;
    _addCheckin.clipsToBounds = YES;
    
    [self setTabBarColor];
    _tabBar.delegate = self;
    _tabBar.layer.borderColor = UIColorFromHexCode(THEME_COLOR).CGColor;
    _tabBar.layer.borderWidth = 0.5;
    [_tabBar setSelectedItem:_tabOne];
    
    // All Checkin Google Map
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    [Util createRoundedCorener:_nearByPinButton withCorner:3];
    
    [Util createRoundedCorener:_searchFieldBaidu withCorner:3];
    [Util createRoundedCorener:_searchButtonBaidu withCorner:3];
    [Util createRoundedCorener:_clearButtonBaidu withCorner:3];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [Util setPadding:_searchField];
    [Util setPadding:_searchFieldBaidu];
    [_searchField addTarget:self
                     action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    [_searchFieldBaidu addTarget:self
                          action:@selector(textChangeListenerBaidu:)
                forControlEvents:UIControlEventEditingChanged];
    [Util setPadding:_searchField];
    [Util setPadding:_searchFieldBaidu];
    
    [Util createRoundedCorener:_baiduLocationSearchButon withCorner:3];
    
    [_myCheckinView setHidden:NO];
    [_allCheckInView setHidden:YES];
    [self showPopularCheckinView];
    
    NSString *countrycode = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    if(([countrycode isEqualToString:@"cn"] || [countrycode isEqualToString:@"zh"]))
    {
        [poweredView setHidden:YES];
    }
}

//Hide or show the views based on tab click
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if(item.tag==1)
    {
        selectedTabBar = 1;
        [poweredView setHidden:NO];
    }
    else{
        selectedTabBar = 2;
        [poweredView setHidden:YES];
    }
    [self showPopularCheckinView];
    
}

// Switch the View Based on the Language selection
-(void)showPopularCheckinView{
    
    if (selectedTabBar == 2)
    {
        [_myCheckinView setHidden:YES];
        NSString *country_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
        
        if([country_code isEqualToString:@"cn"] || [country_code isEqualToString:@"zh"])  // is china show Baidu Map
        {
            _popularCheckin_Baidu_SearchPage.hidden = YES;
            _popularCheckin_Baidu_ListPage.hidden = YES;
            _popularCheckin_Baidu_MapPage.hidden = YES;
            
            [_allCheckInBaidu setHidden:NO];
            [_allCheckInView setHidden:YES];
            _allCheckInBaidu.backgroundColor = [UIColor grayColor];
            
            //Load baidu map view
            BaiduPopularCheckin *checkin = [[BaiduPopularCheckin alloc] initWithNibName:@"BaiduPopularCheckin" bundle:nil];
            checkin.homePage = NO;
            [self addChildViewController:checkin];                 // 1
            [checkin.view setFrame:CGRectMake(0,0,_allCheckInBaidu.frame.size.width,_allCheckInBaidu.frame.size.height)];
            [_allCheckInBaidu addSubview:checkin.view];
            [checkin.checkInButton setHidden:YES];
            [checkin didMoveToParentViewController:self];          // 3
            
        }
        else  // is english show google map
        {
            [_allCheckInView setHidden:NO];
            [_allCheckInBaidu setHidden:YES];
            currentPage = 0;
        }
    }
    else
    {
        [_myCheckinView setHidden:NO];
        [_allCheckInBaidu setHidden:YES];
        [_allCheckInView setHidden:YES];
    }
}

-(void)setTabBarColor
{
    // Tab Bar
    [_tabBar setTintColor:[UIColor whiteColor]];
    [_tabBar setSelectionIndicatorImage:[Util convertColorToImage:UIColorFromHexCode(THEME_COLOR) byDivide:2 withHeight:60]];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"CenturyGothic" size:13], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
}


//Reload the list while receiving a notification
- (void) reloadList{
    //reload the page once we back to this page
    page = previousPage = 1;
    [myCheckins removeAllObjects];
    
    NSDictionary *Mycheckinlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"MycheckInList"];
    if (Mycheckinlist != nil) {
        [self showMyCheckIn:Mycheckinlist];
    }
    
    [self getMyCheckinList];
}

// ---------------- START ALL CHECKIN GOOGLE MAP ---------------------

//Search box text change listener
- (void) textChangeListener :(UITextField *) searchBox{
    
    if([[searchBox text] length ] > 0){
        [self getSearchResult:[searchBox text]];
    }
    else{
        [_placesAutoComplete setHidden:YES];
    }
    //hide/show clear text
    if([[searchBox text] length] > 0)
        [self.clearButton setHidden:NO];
    else
        [self.clearButton setHidden:YES];
}

//Search with Auto Complete search from the place search API
- (void) getSearchResult :(NSString *) searchText
{
    placesList = [[NSMutableArray alloc] init];
    //autoCompleteSearch
    NSLog(@"Auto Complete search for : %@",searchText);
    [_googleMap autoCompleteSearch:searchText withCallBack:^(NSMutableArray *autoCompleteResponse) {
        
        NSLog(@"Auto Complete Response : %@",autoCompleteResponse);
        if([[_searchField text] length] > 0){
            placesList = autoCompleteResponse;
            if ([placesList count] > 0) {
                [_placesAutoComplete reloadData];//Refresh the table view
                [_placesAutoComplete setUserInteractionEnabled:YES];
                [_placesAutoComplete setHidden:NO]; //Show the result
                [self changeTableViewHeight]; //Change table view height
            }
            else
            {
                placesList = [[NSMutableArray alloc]init];
                NSMutableDictionary *placeInfo = [[NSMutableDictionary alloc]init];
                [placeInfo setObject:NSLocalizedString(@"No results found", nil) forKey:@"place"];
                [placeInfo setObject:@"" forKey:@"id"];
                [placesList addObject:placeInfo];
                [_placesAutoComplete reloadData];
                [_placesAutoComplete setUserInteractionEnabled:NO];
            }
        }
    }];
}

//Change the autocomplete table view height
- (void) changeTableViewHeight {
    
    CGFloat rowHeight = self.placesAutoComplete.rowHeight;
    rowHeight = 40.0f;
    float tableHeight = 40 * placesList.count + 20;
    
    CGRect tableFrame = self.placesAutoComplete.frame;
    tableFrame.size.height = tableHeight;
    self.placesAutoComplete.frame = tableFrame;
}

//Clear search
- (IBAction)clearClick:(id)sender {
    
    [self clearSearchField];
}

-(void)clearSearchField
{
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    
    //hide tableview
    [_searchField resignFirstResponder]; //Hide keyboard
    [_placesAutoComplete setHidden:YES];
    
    //Enable my location
    [_googleMap removeMarkersFromTheMap];
    [_googleMap focusCurrentLocation];
    [_googleMap enableMyLocation:FALSE];
}

- (IBAction)clearClickBaidu:(id)sender
{
    [_searchFieldBaidu setText:@""];
    [_clearButtonBaidu setHidden:YES];
    
    [_searchFieldBaidu resignFirstResponder]; //Hide keyboard
    [baiduLocationSearchedList removeAllObjects];
    [self addEmptyMessageForBaiduSearch];
    [_placeSearchTableBiadu reloadData];
    
}

// NearBy Pin
- (IBAction)nearByPin:(id)sender
{
    
    if( ![Util checkLocationIsEnabled] )
    {
        [[Util sharedInstance] showLocationAlert];
    }
    else
    {
        lat = [[LocationManager sharedManager] latitude];
        lang = [[LocationManager sharedManager] longitude];
        if (lat != 0 && lang != 0) {
            [self clearSearchField];
            
            CLLocationCoordinate2D location;
            location.latitude = lat;
            location.longitude = lang;
            
            NSString *country_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
            
            if([country_code isEqualToString:@"cn"] || [country_code isEqualToString:@"zh"]) // Baidu
            {
                //1. Remove all annotation   2. Show User Current Location  3. Show near by Pins
                [baiduMap RemoveAllAnnotations];
                NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"mapPointer.png"]);
                [baiduMap addAnnotation:location Title:YOU Subtitle:nil Image:imageData];
            }
            else // Google
            {
                _googleMap.isNearByCheckIn = YES;
                [_googleMap removeMarkersFromTheMap];
                [self getNearByLocation];
                [_googleMap moveToLocation:location];
                //1. Remove all annotation   2. Show User Current Location  3. Show near by Pins
                [_googleMap addMarkerWithTitle:location withTitle:NSLocalizedString(YOU, nil) withIcon:[UIImage imageNamed:@"mapPointer.png"]];
            }
            
            [self getNearByLocation];
        }
    }
    
}

-(void)getNearByLocation
{
    gotnearByResponse = YES;
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
    [inputParams setValue:[NSNumber numberWithDouble:lang] forKey:@"longitude"];
    
    [self.checkinTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_CHECKIN_LOCATION withCallBack:^(NSDictionary * response){
        [self.checkinTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            nearByLocationsList = [[NSMutableArray alloc]init];
            [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
            checkinMediaBase = [response objectForKey:@"media_base_url"];
            [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:YES isVisiblePin:NO];
        }
        else{
            
        }
    } isShowLoader:YES];
}

//Get all popular checkins from the world
-(void)getAllPopularCheckins
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:pageNumber] forKey:@"page_number"];
    [inputParams setValue:@"300" forKey:@"per_page"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:POPULAR_CHECKINS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            if (nearByLocationsList.count == 0){
                nearByLocationsList = [[NSMutableArray alloc]init];
            }
//            nearByLocationsList = [[NSMutableArray alloc] init];
            
            pageNumber = [[response valueForKey:@"next_page"] intValue];
            
            if(pageNumber != -1){
                
                [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
                checkinMediaBase = [response objectForKey:@"media_base_url"];
                [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO isVisiblePin:YES];
                [self getAllPopularCheckins];
            }
            
        }
        else{
            
        }
    } isShowLoader:NO];
}

- (void)showNearByPins:(NSMutableArray *)checkins showAlert:(BOOL)alert isVisiblePin:(BOOL)visiblePin{
    [nearByLocationsList removeAllObjects];
    for (int i=0; i < [checkins count]; i++) {
        NSMutableDictionary *offer = [[checkins objectAtIndex:i] mutableCopy];
        [offer setValue:[offer valueForKey:@"checkin_location"] forKey:@"name"];
        [offer setValue:[offer valueForKey:@"location_address"] forKey:@"subTitle"];
        [offer setValue:[offer valueForKey:@"media_url"] forKey:@"Image"];
        [offer setValue:[NSNumber numberWithInteger:0]  forKey:@"show_custom_view"];
        [nearByLocationsList addObject:offer];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",checkinMediaBase,[offer valueForKey:@"media_url"]];
        [Util preloadImageFromUrl:strURL];
        
    }
    if ([nearByLocationsList count] == 0 && alert) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_NEAR_BY_CHECKIN, nil)];
    }
    else{
        // IF ch or zh is an CHINA
        NSString *country_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
        
        if([country_code isEqualToString:@"cn"] || [country_code isEqualToString:@"zh"]){
            [baiduMap addAnnotations:nearByLocationsList shouldAnimate:YES];
        }
        else
        {
            [_googleMap addMarkers:nearByLocationsList isVisiblePin:YES];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        gotnearByResponse= NO;
    });
}

// ---------------- END ALL CHECKIN GOOGLE MAP ---------------------

// ----------------- START BAIDU POPULAR CHECKIN ---------------------

-(IBAction)locationSearchBaidu:(id)sender
{
    NSString *txtcity = [_cityField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *txtcategory = [_categeoriesField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([txtcity isEqualToString:@""]) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(CITY_EMPTY_FIELD, nil)];
    }
    else if([txtcategory isEqualToString:@""])
    {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(CATEGORY_EMPTY, nil)];
    }
    else
    {
        [baiduMap POISearch:_cityField categories:_categeoriesField];
    }
}

//Search box text change listener
- (void) textChangeListenerBaidu :(UITextField *) searchBox{
    
    if([[searchBox text] length ] > 0){
        [self getSearchResultsBaidu:[searchBox text]];
    }
    [_placeSearchTableBiadu reloadData];
    
    //hide/show clear text
    if([[searchBox text] length] > 0)
        [self.clearButtonBaidu setHidden:NO];
    else
        [self.clearButtonBaidu setHidden:YES];
    
    [self addEmptyMessageForBaiduSearch];
}

-(void)getSearchResultsBaidu :(NSString *) searchText
{
    baiduLocationSearchedList = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[baiduLocationList count]; i++) {
        NSString *locName = [[baiduLocationList objectAtIndex:i] objectForKey:@"name"];
        if ([locName containsString:searchText]) {
            [baiduLocationSearchedList addObject:[baiduLocationList objectAtIndex:i]];
        }
    }
}

-(void)addEmptyMessageForBaiduSearch
{
    if ([baiduLocationSearchedList count] == 0) {
        [Util addEmptyMessageToTable:_placeSearchTableBiadu withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:_placeSearchTableBiadu withMessage:@"" withColor:[UIColor whiteColor]];
    }
}


// ----------------- END BAIDU POPULAR CHKIN ---------------------

// ---------------- START MY CHECKIN ---------------------
-(void)getMyCheckinList{
    
    //Send general notification list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [self.checkinTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:MY_CHECKIN_LIST withCallBack:^(NSDictionary * response){
        [self.checkinTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            if (page == 1) {
                [myCheckins removeAllObjects];
                [Util setInDefaults:response withKey:@"MycheckInList"];
            }
            
            page = [[response valueForKey:@"page"]intValue];
            [self showMyCheckIn:response];
        }
        else{
            
        }
    } isShowLoader:NO];
}

-(void)showMyCheckIn:(NSDictionary *)response
{
    if(mediaBase == nil)
        mediaBase = [response valueForKey:@"media_base_url"];
    [myCheckins addObjectsFromArray:[response objectForKey:@"checkin_list"]];
    [_checkinTable reloadData];
    [self addEmptyMessage];
}

//Add empty message in table background view
- (void)addEmptyMessage{
    
    if ([myCheckins count] == 0) {
        [Util addEmptyMessageToTable:_checkinTable withMessage:NO_CHECKINS withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:_checkinTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}



//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak MyCheckins *weakSelf = self;
    // setup infinite scrolling
    [self.checkinTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.checkinTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak MyCheckins *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getMyCheckinList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.checkinTable.infiniteScrollingView stopAnimating];
    }
}


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Popular Checkin Googgle Map Search location
    if(tableView == _placesAutoComplete){
        return [placesList count];
    }
    else if(tableView == _placeSearchTableBiadu)
    {
        if ([_searchFieldBaidu.text isEqualToString:@""]) {
            return [baiduLocationList count];
        }
        else
        {
            return [baiduLocationSearchedList count];
        }
        
    }
    //My Checkin
    else
    {
        return [myCheckins count];
    }
    return [myCheckins count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    //Popular Checkin Googgle Map Search location
    if(tableView == _placesAutoComplete){
        NSString *cellIdentifier = @"autoCompleteCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if([placesList count] > 0){
            
            //Read UI elements
            UILabel *title = (UILabel *) [cell viewWithTag:10];
            if ([placesList count] > indexPath.row) {
                NSDictionary *placeInfo = [placesList objectAtIndex:indexPath.row];
                [title setText:[placeInfo objectForKey:@"place"]];
            }
        }
    }
    else if(tableView == _placeSearchTableBiadu)
    {
        NSString *cellIdentifier = @"placeSearchCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSMutableArray *currentList = ([_searchFieldBaidu.text isEqualToString:@""]) ? baiduLocationList : baiduLocationSearchedList ;
        
        if([currentList count] > 0){
            cell.backgroundColor = [UIColor clearColor];
            //Read UI elements
            UILabel *title = (UILabel *) [cell viewWithTag:10];
            UILabel *address = (UILabel *) [cell viewWithTag:11];
            title.textColor = [UIColor whiteColor];
            if ([currentList count] > indexPath.row) {
                NSDictionary *placeInfo = [currentList objectAtIndex:indexPath.row];
                [title setText:[placeInfo objectForKey:@"name"]];
                [address setText:[placeInfo objectForKey:@"subTitle"]];
            }
        }
    }
    //My Checkin
    else{
        NSString *cellIdentifier = @"myCheckinCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        //Read elements
        //UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
        UILabel *title =  (UILabel *)[cell viewWithTag:11];
        UILabel *description = (UILabel *) [cell viewWithTag:12];
        UILabel *timeStamp = (UILabel *) [cell viewWithTag:13];
        
        NSDictionary *checkin = [myCheckins objectAtIndex:indexPath.row];
        
        //Bind the values into elements
        title.text = [checkin valueForKey:@"checkin_location"];
        description.text = [checkin valueForKey:@"location_address"];
        timeStamp.text = [Util timeStamp:[[checkin valueForKey:@"time_stamp"] longValue]];
    }
    
    return cell;
    
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == _placesAutoComplete)
    {
        NSLog(@"SELECTED ROW : %ld",(long)indexPath.row);
        NSDictionary *selectedPlaceData;
        if ([placesList count] > indexPath.row) {
            selectedPlaceData = [placesList objectAtIndex:indexPath.row];
        }
        if (selectedPlaceData != nil) {
            //Set label text
            [_searchField setText:[selectedPlaceData objectForKey:@"place"]];
            [_placesAutoComplete setHidden:YES];
            [_searchField resignFirstResponder]; //Hide keyboard
            //Now call the custom Map view function to search and add marker on mapview
            [_googleMap getPlaceDetailByID:[selectedPlaceData objectForKey:@"id"] withCallBack:^(GMSPlace *placeInfo) {
                
                NSLog(@"placeInfo %@", placeInfo);
                
                //Get place address through google geocoder
                [[GMSGeocoder geocoder] reverseGeocodeCoordinate:[placeInfo coordinate] completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
                    
                    GMSAddress* addressObj = [[response results]objectAtIndex:0];
                    NSLog(@"Place Details after geocode :%@", addressObj);
                    NSLog(@"Place Details after geocode :%@", [addressObj administrativeArea]);
                    
                    name = [placeInfo name];
                    lat = [placeInfo coordinate].latitude;
                    lang = [placeInfo coordinate].longitude;
                    
                    //Check administrativeArea present
                    if([addressObj administrativeArea] == nil ){
                        state = [addressObj country];
                    }
                    else
                        state = [addressObj administrativeArea];
                    
                    //set the locality for city
                    if([addressObj locality]  == nil ){
                        city = [addressObj country];
                    }
                    else
                        city = [addressObj locality];
                    
                    country = [addressObj country];
                    
                    //Move camera to clicked to location and add marker
                    _googleMap.isNearByCheckIn = YES;
                    [_googleMap removeMarkersFromTheMap];
                    [self getNearByLocation];
                    [_googleMap moveToLocation:placeInfo.coordinate];
                    [_googleMap addMarker:placeInfo.coordinate withTitle:placeInfo withIcon:[UIImage imageNamed:@"mapPointer.png"]];
                    
                    
                }];
            }];
            
            //Hide the current location
            [_googleMap enableMyLocation:NO];
        }
        
    }
    else if(tableView == _placeSearchTableBiadu)
    {
        NSMutableArray *currentList = ([_searchFieldBaidu.text isEqualToString:@""]) ? baiduLocationList : baiduLocationSearchedList ;
        
        NSDictionary *placeInfo = [currentList objectAtIndex:indexPath.row];
        
        lat = [[placeInfo objectForKey:@"latitude"] doubleValue];
        lang = [[placeInfo objectForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D location;
        location.latitude = lat;
        location.longitude = lang;
        [baiduMap RemoveAllAnnotations];
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"mapPointer.png"]);
        [baiduMap addAnnotation:location Title:[placeInfo objectForKey:@"name"] Subtitle:[placeInfo objectForKey:@"v"] Image:imageData];
        
        // Get near popular checkins
        [self getNearByLocation];
        
        currentPage = 3;
        [self showMapPage];
    }
    //My Checkin
    else
    {
        if ([myCheckins count] > indexPath.row) {
            MyCheckinDetails *details = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCheckinDetails"];
            NSDictionary *checkin = [myCheckins objectAtIndex:indexPath.row];
            details.checkinId = [checkin valueForKey:@"checkin_id"];
            [self.navigationController pushViewController:details animated:YES];
        }
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

- (IBAction)addCheckin:(id)sender {
    
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CreatePostViewController *postCreate = [self.storyboard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
        postCreate.postFromProfile = @"true";
        [self.navigationController pushViewController:postCreate animated:NO];
    }
    else{
        
        [appDelegate.networkPopup show];
    }
}

#pragma  args Google Map delegates
//Marker tapped click
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    NSMutableDictionary *markerInfo = (NSMutableDictionary *) marker.userData;
    if (markerInfo != nil) {
        MyCheckinDetails *details = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCheckinDetails"];
        details.checkinId = [markerInfo valueForKey:@"checkin_id"];
        details.isPopularCheckinDetail = @"YES";
        [self.navigationController pushViewController:details animated:YES];
    }
}

#pragma  args Baidu Map delegates
- (void)SearchResults: (NSMutableArray *)searchResults
{
    NSLog(@"searchResults %@", searchResults);
    
    if ([searchResults count] > 0) {
        currentPage = 2;
        baiduLocationList = [[NSMutableArray alloc] init];
        [baiduLocationList addObjectsFromArray:searchResults];
        [self showListPage];
        [_placeSearchTableBiadu reloadData];
        
    }
    else
    {
        currentPage = 1;
        [self showSearchPage];
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_RESULT_FOUND, nil)];
    }
}

- (void)didSelectAnnotaion:(BMKMapView *)mapView annotation:(BMKAnnotationView *)pinAnnotation
{
    MyAnnotation *pinView = (MyAnnotation *)pinAnnotation.annotation;
    NSLog(@"Data :%@",pinView.userInfo);
}

- (void)didSelectAnnotaionViewBubble:(BMKAnnotationView *)mapViewbubble
{
    MyAnnotation *pinView = (MyAnnotation *)mapViewbubble.annotation;
    NSLog(@"Data :%@",pinView.userInfo);
    NSMutableDictionary *markerInfo = pinView.userInfo;
    if (markerInfo != nil) {
        
        MyCheckinDetails *details = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCheckinDetails"];
        details.checkinId = [markerInfo valueForKey:@"checkin_id"];
        details.isPopularCheckinDetail = @"YES";
        [self.navigationController pushViewController:details animated:YES];
    }
}

-(void)showSearchPage // is current page = 1
{
    _popularCheckin_Baidu_SearchPage.hidden = NO;
    _popularCheckin_Baidu_ListPage.hidden = YES;
    _popularCheckin_Baidu_MapPage.hidden = YES;
}

-(void)showListPage  // is current page = 2
{
    _popularCheckin_Baidu_SearchPage.hidden = YES;
    _popularCheckin_Baidu_ListPage.hidden = NO;
    _popularCheckin_Baidu_MapPage.hidden = YES;
}

-(void)showMapPage  // is current page = 3
{
    _popularCheckin_Baidu_SearchPage.hidden = YES;
    _popularCheckin_Baidu_ListPage.hidden = YES;
    _popularCheckin_Baidu_MapPage.hidden = NO;
}
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    NSMutableDictionary *markerInfo = (NSMutableDictionary *) marker.userData;
    
    if (markerInfo != nil) {
        mapInfoWindow = [[MapMarkerWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 95)];
        mapInfoWindow.title.text = [markerInfo valueForKey:@"name"];
        mapInfoWindow.snippet.text = [markerInfo objectForKey:@"subTitle"];
        NSString *strURL = [NSString stringWithFormat:@"%@%@",checkinMediaBase,[markerInfo objectForKey:@"Image"]];
        [mapInfoWindow.imageView setImageWithURL:[NSURL URLWithString:strURL]];
        if([[markerInfo objectForKey:@"media_type"] intValue] == 1 )
            mapInfoWindow.playIcon.hidden = YES;
        else
            mapInfoWindow.playIcon.hidden = NO;
        
        return mapInfoWindow;
    }
    
    return nil;
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    if(_googleMap.selectedMarker != nil){
        CGPoint point = [_googleMap.projection pointForCoordinate:_googleMap.selectedMarker.position];
        if(point.x < 0 || point.x > _googleMap.frame.size.width || point.y < 0 || point.y > _googleMap.frame.size.height)
            [self getVisiblePopularCheckin];
    }
    if(_googleMap.selectedMarker == nil && !_googleMap.isNearByCheckIn){
        [self getVisiblePopularCheckin];
    }
    _googleMap.isNearByCheckIn = NO;
}

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition*)position {
    float currentZoom = _googleMap.camera.zoom;
    if(currentZoom != zoom)
        _googleMap.selectedMarker = nil;
    zoom = _googleMap.camera.zoom;
}

-(void)getVisiblePopularCheckin{
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:self.googleMap.projection.visibleRegion];
    
    CLLocationCoordinate2D northEast = bounds.northEast;
    CLLocationCoordinate2D southWest = bounds.southWest;
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
//    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"MTUxOTk2NjU3MzllODA2NTBhYzAyMjkxMWQxMjIxMDk=" forKey:@"auth_token"];
    [inputParams setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",southWest.latitude] forKey:@"southwest_latitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",southWest.longitude] forKey:@"sounthwest_longitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",northEast.latitude] forKey:@"northeast_latitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",northEast.longitude] forKey:@"northeast_longitude"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:VISIBLE_POPULAR_CHECKIN withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            if(!gotnearByResponse){
                [_googleMap removeMarkersFromTheMap];
                nearByLocationsList = [[NSMutableArray alloc] init];
                [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
                mediaBase = [response objectForKey:@"media_base_url"];
                [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO isVisiblePin:YES];
            }
            gotnearByResponse = NO;
        }
        else{
        }
    } isShowLoader:NO];
}
@end
