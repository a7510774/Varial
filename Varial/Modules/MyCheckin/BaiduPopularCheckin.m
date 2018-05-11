//
//  BaiduPopularCheckin.m
//  Varial
//
//  Created by vis-1674 on 01/09/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BaiduPopularCheckin.h"
#import "Util.h"
#import "MyCheckinDetails.h"
#import "BaiduPopularCheckinCell.h"
#import "FriendCell.h"
#import "MyPaopaoView.h"
#import "BaiduMap.h"

#import "BaiduCheckinItem.h"

@interface BaiduPopularCheckin (){
    int pageNumber;
}

@end

@implementation BaiduPopularCheckin

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    baiduLocationSearchedList = [[NSMutableArray alloc] init];
    
    [self designTheView];
    [self createPopUpWindows];
    [self showBaiduMap];
//    [self getAllPopularCheckins];
    [_categeoriesField addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    
    
    BMKMapView *mapView = baiduMap.mapView;
    
    id<BMClusterAlgorithm> algorithm = [[BMNonHierarchicalDistanceBasedAlgorithm alloc] init];
    id<BMClusterIconGenerator> iconGenerator = [[BMDefaultClusterIconGenerator alloc] init];
    BMDefaultClusterRenderer *renderer = [[BMDefaultClusterRenderer alloc] initWithMapView:mapView
                                                                      clusterIconGenerator:iconGenerator];
    renderer.delegate = baiduMap;
    renderer.animatesClusters = NO;
    _clusterManager = [[BMClusterManager alloc] initWithMap:mapView
                                                  algorithm:algorithm
                                                   renderer:renderer];
    [_clusterManager setDelegate:self mapDelegate:self];
    
    // set page number to 0
    pageNumber = 0;
    
    // Hide Loading View
    [self.myViewActivity setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    isFirstShown = YES;
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(removeMapDelegate)
//                                                 name:@"RemoveMapDelegate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getVisiblePopularCheckins:) name:@"GetVisiblePopularCheckin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getAllPopularCheckins) name:@"GetAllPopularCheckin" object:nil];
    baiduMap.isHomePage = _homePage;
    [[LocationManager sharedManager] startUpdateLocation];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemoveMapDelegate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetVisiblePopularCheckin" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetAllPopularCheckin" object:nil];
}

// Clear Mail when switch the tab for memory management
-(void)removeMapDelegate{
    [baiduMap RemoveAllAnnotations];
    [baiduMap removeFromSuperview];
    baiduMap.delegate = nil;
    baiduMap = nil;
}


-(void)doneAction:(UIBarButtonItem*)barButton
{
    [self searchBaiduLocation:nil];
}

- (void)designTheView{
    
    //Set transparent color to tableview
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"BaiduPopularCheckinCell" bundle:nil] forCellReuseIdentifier:@"BaiduPopularCheckinCell"];
    
    [Util createRoundedCorener:_searchView withCorner:5];
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_cancelSearchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    [Util createRoundedCorener:_baiduLocationSearchButon withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createBottomLine:_cityField withColor:[UIColor darkGrayColor]];
    [Util createBottomLine:_categeoriesField withColor:[UIColor darkGrayColor]];
    
    [Util createRoundedCorener:_listView withCorner:5];
    [Util createRoundedCorener:_locationClearButton withCorner:3];
    [Util createRoundedCorener:_locationSearchField withCorner:3];
    [Util createRoundedCorener:_locationSearchButton withCorner:3];
    [Util createRoundedCorener:_listBackButton withCorner:3];
    [Util createRoundedCorener:_listCancel withCorner:3];
    
    [Util createRoundedCorener:_nearByButton withCorner:3];
    [Util createRoundedCorener:_mapsearchView withCorner:3];
    [Util createRoundedCorener:_locationSearchView withCorner:3];
    
    [Util setPadding:_searchField];
    [Util setPadding:_locationSearchField];
    
    [_searchField addTarget:self
                     action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    [_locationSearchField addTarget:self
                             action:@selector(textChangeListenerBaidu:)
                   forControlEvents:UIControlEventEditingChanged];
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
    
    _checkInButton.layer.cornerRadius = _checkInButton.frame.size.height / 2 ;
    _checkInButton.clipsToBounds = YES;
}

- (void) createPopUpWindows{
    network = [[NetworkAlert alloc] init];
    [network setNetworkHeader:NSLocalizedString(NETWORK_TITLE, nil)];
    network.subTitle.text = NSLocalizedString(CHECK_NETWORK, nil);
    
    networkPopup = [KLCPopup popupWithContentView:network showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
    networkPopup.didFinishShowingCompletion = ^{
        [Util sharedInstance].isNetworkShow = @"TRUE";
    };
    
    networkPopup.didFinishDismissingCompletion = ^{
        [Util sharedInstance].isNetworkShow = @"FALSE";
    };
    
    searchPopup = [KLCPopup popupWithContentView:self.searchView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    listPopup = [KLCPopup popupWithContentView:self.listView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    searchPopup.didFinishShowingCompletion = ^{
        [_cityField becomeFirstResponder];
        if (cityValue != nil && ![cityValue isEqualToString:@""] && categoryValue != nil && ![categoryValue isEqualToString:@""]) {
            _cityField.text = cityValue;
            _categeoriesField.text = categoryValue;
        }
        
    };
    
}

- (void) showBaiduMap
{
    baiduMap = [[BaiduMap alloc] init];
    baiduMap.delegate = self;
    
    baiduMap = [[BaiduMap alloc] initWithFrame:CGRectMake(2, 2, _mapView.bounds.size.width - 4, _mapView.bounds.size.height - 4)];
    baiduMap.delegate = self;
    baiduMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_mapView addSubview:baiduMap];
    
}

-(IBAction)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:_searchField]) {
        [textField resignFirstResponder];
        if (isShowListPopup) {
            [listPopup show];
            _listView.hidden = NO;
        }
        else
        {
            [searchPopup showWithLayout:layout];
            _searchView.hidden = NO;
        }
    }
}

//Search box text change listener
- (void) textChangeListener :(UITextField *) searchBox{
    [searchBox setText:@""];
    [searchBox resignFirstResponder];
    [searchPopup showWithLayout:layout];
    _searchView.hidden = NO;
}

//Search box text change listener
- (void) textChangeListenerBaidu :(UITextField *) searchBox{
    
    if([[searchBox text] length ] > 0){
        [self getSearchResultsBaidu:[searchBox text]];
    }
    [_tableView reloadData];
    
    //hide/show clear text
    if([[searchBox text] length] > 0)
        [self.locationClearButton setHidden:NO];
    else
        [self.locationClearButton setHidden:YES];
    
    [self addEmptyMessageForBaiduSearch];
}

- (IBAction)nearByPin:(id)sender
{
    baiduMap.nearByPinAdded = YES;
    if( ![Util checkLocationIsEnabled] )
    {
        [[Util sharedInstance] showLocationAlert];
    }
    else
    {
        lat = [[LocationManager sharedManager] latitude];
        lang = [[LocationManager sharedManager] longitude];
        if (lat != 0 && lang != 0) {
            // [self clearSearchField];
            
            CLLocationCoordinate2D location;
            location.latitude = lat;
            location.longitude = lang;
            
            searchedPlaceInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",[[LocationManager sharedManager] latitude]],@"latitude",[NSString stringWithFormat:@"%f",[[LocationManager sharedManager] longitude]],@"longitude",YOU,@"name", nil];
            
            NSString *country_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
            
            if([country_code isEqualToString:@"cn"] || [country_code isEqualToString:@"zh"]) // Baidu
            {
                //1. Remove all annotation   2. Show User Current Location  3. Show near by Pins
                [baiduMap RemoveAllAnnotations];
                [self getNearByLocation];
            }
        }
    }
}


// Search Popup
- (IBAction)clearClick:(id)sender{
    
}

- (IBAction)searchBaiduLocation:(id)sender
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
        cityValue = _cityField.text;
        categoryValue = _categeoriesField.text;
        progress = [Util showLoading];
        BOOL result = [baiduMap POISearch:_cityField categories:_categeoriesField];
        if (!result) {
            [progress hide:YES];
        }
    }
}

- (IBAction)cancelSearchPopUp:(id)sender
{
    [searchPopup dismiss:YES];
    _searchView.hidden = NO;
    [self clearSearchField];
}

// List Popup

-(void) clearSearchField
{
    cityValue = @"";
    categoryValue = @"";
}

- (IBAction)listCancelClick:(id)sender
{
    [listPopup dismiss:YES];
    _listView.hidden = YES;
    //[self clearSearchField];
    isShowListPopup = FALSE;
}

- (IBAction)listBackClick:(id)sender
{
    [listPopup dismiss:YES];
    _listView.hidden = YES;
    [searchPopup showWithLayout:layout];
    _searchView.hidden = NO;
}

- (IBAction)locationClearClick:(id)sender
{
    _locationSearchField.text = @"";
    _locationClearButton.hidden = YES;
    [_tableView reloadData];
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
        [Util addEmptyMessageToTable:_tableView withMessage:NO_RESULT_FOUND withColor:[UIColor darkGrayColor]];
    }
    else{
        [Util addEmptyMessageToTable:_tableView withMessage:@"" withColor:[UIColor darkGrayColor]];
    }
}

#pragma mark BMKMapView Delegate methods
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    NSLog(@"BAIDU DID FINISH LOADING");
    [self getAllPopularCheckins];
}

#pragma mark ClusterManager Delegate methods

/**
 * Called when the user taps on a cluster marker.
 * @return YES if this delegate handled the tap event,
 * and NO to pass this tap event to other handlers.
 */
- (BOOL)clusterManager:(BMClusterManager *)clusterManager didTapCluster:(id<BMCluster>)cluster {
    NSLog(@"Tapped on cluster");
    
//    [baiduMap.mapView zoomIn];
    [self zoomToCluster: cluster];
    
    return YES;
}

- (void)zoomToCluster:(id<BMCluster>)cluster {
    
    CLLocationDegrees maxLat = -85;
    CLLocationDegrees minLat = 85;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLon = 180;
    
    for (id<BMClusterItem> clusterItem in [cluster items]) {
        CLLocationCoordinate2D position = clusterItem.position;
        //        NSLog(@"clusterItem %f %f", position.latitude, position.longitude);
        if (position.latitude > maxLat) {
            maxLat = position.latitude;
            //            NSLog(@"new lat, %f", position.latitude);
        } else if (position.latitude < minLat) {
            minLat = position.latitude;
        }
        if (position.longitude > maxLon) {
            maxLon = position.longitude;
            
        } else if (position.longitude < minLon) {
            minLon = position.longitude;
        }
    }
    
//    NSLog(@"%f %f %f %f", maxLat, maxLon, minLat, minLon);
    
    BMKMapPoint nw = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(maxLat, minLon));
    BMKMapPoint se = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(minLat, maxLon));
//    NSLog(@"nw %@, se %@", BMKStringFromMapPoint(nw), BMKStringFromMapPoint(se));

    double x1 = fmin(nw.x, se.x);
    double x2 = fmax(nw.x, se.x);
    double y1 = fmin(nw.y, se.y);
    double y2 = fmax(nw.y, se.y);
    BMKMapRect mapRect = BMKMapRectMake(x1, y1, x2 - x1, y2 - y1);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
//    NSLog(@"string: %@", BMKStringFromMapRect(mapRect));
//    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:nwCoord coordinate:seCoord];
    
//    [baiduMap.mapView setVisibleMapRect:mapRect animated:YES];
    [baiduMap.mapView setVisibleMapRect:mapRect edgePadding:insets animated:YES];
}

/**
 * Called when the user taps on a cluster item marker.
 * @return YES if this delegate handled the tap event,
 * and NO to pass this tap event to other handlers.
 */
//- (BOOL)clusterManager:(BMClusterManager *)clusterManager didTapClusterItem:(id<BMClusterItem>)clusterItem {
//    NSLog(@"Tapped on cluster item");
//    return NO;
//}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    NSLog(@"selected the annotation view");
//    view.paopaoView = nil;
//    [baiduMap mapView:mapView didSelectAnnotationView:view];
}

#pragma mark Baidu Map delegates
- (void)SearchResults: (NSMutableArray *)searchResults
{
    // NSLog(@"searchResults %@", searchResults);
    [Util hideLoading:progress];
    
    if ([searchResults count] > 0) {
        
        baiduLocationList = [[NSMutableArray alloc] init];
        [baiduLocationList addObjectsFromArray:searchResults];
        [_tableView reloadData];
        
        [searchPopup dismiss:YES];
        _searchView.hidden = YES;
        
        [listPopup show];
        _listView.hidden = NO;
    }
    else
    {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_RESULT_FOUND, nil)];
    }
}

- (void)didSelectAnnotaion:(BMKMapView *)mapView annotation:(BMKAnnotationView *)pinAnnotation
{
    MyAnnotation *pinView = (MyAnnotation *)pinAnnotation.annotation;
    NSDictionary *userInfo = pinView.userInfo;
    baiduMap.activePin = CLLocationCoordinate2DMake([[userInfo objectForKey:@"latitude"] doubleValue], [[userInfo objectForKey:@"longitude"] doubleValue]);
    //  NSLog(@"Data :%@",pinView.userInfo);
}

- (void)didSelectAnnotaionViewBubble:(BMKAnnotationView *)mapViewbubble
{
    MyAnnotation *pinView = (MyAnnotation *)mapViewbubble.annotation;
    //   NSLog(@"Data :%@",pinView.userInfo);
    NSMutableDictionary *markerInfo = pinView.userInfo;
    if (markerInfo != nil) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        MyCheckinDetails *details = [mainStoryboard instantiateViewControllerWithIdentifier:@"MyCheckinDetails"];
        details.checkinId = [markerInfo valueForKey:@"checkin_id"];
        details.isPopularCheckinDetail = @"YES";
        [self.navigationController pushViewController:details animated:YES];
    }
}

-(void)navigateToDetailPage:(NSMutableDictionary*)markerInfo{
    if (markerInfo != nil) {
        UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        MyCheckinDetails *details = [mainStoryboard instantiateViewControllerWithIdentifier:@"MyCheckinDetails"];
        details.checkinId = [markerInfo valueForKey:@"checkin_id"];
        details.isPopularCheckinDetail = @"YES";
        [navigation pushViewController:details animated:YES];
    }
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_locationSearchField.text isEqualToString:@""]) {
        return [baiduLocationList count];
    }
    else
    {
        return [baiduLocationSearchedList count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"BaiduPopularCheckinCell";
    BaiduPopularCheckinCell *cell = (BaiduPopularCheckinCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[BaiduPopularCheckinCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableArray *currentList = ([_locationSearchField.text isEqualToString:@""]) ? baiduLocationList : baiduLocationSearchedList ;
    
    if([currentList count] > 0){
        //Read UI elements
        if ([currentList count] > indexPath.row) {
            NSDictionary *placeInfo = [currentList objectAtIndex:indexPath.row];
            [cell.title setText:[placeInfo objectForKey:@"name"]];
            [cell.address setText:[placeInfo objectForKey:@"subTitle"]];
        }
    }
    
    return  cell;
}


//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [listPopup dismiss:YES];
    _listView.hidden = YES;
    [self clearSearchField];
    isShowListPopup = TRUE;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *currentList = ([_locationSearchField.text isEqualToString:@""]) ? baiduLocationList : baiduLocationSearchedList ;
    
    searchedPlaceInfo = [currentList objectAtIndex:indexPath.row];
    
    lat = [[searchedPlaceInfo objectForKey:@"latitude"] doubleValue];
    lang = [[searchedPlaceInfo objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D location;
    location.latitude = lat;
    location.longitude = lang;
    // Get near popular checkins
    [self getNearByLocation];
}

-(void)addSearchedLocation{
    [baiduMap RemoveAllAnnotations];
    lat = [[searchedPlaceInfo objectForKey:@"latitude"] doubleValue];
    lang = [[searchedPlaceInfo objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D location;
    location.latitude = lat;
    location.longitude = lang;
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"mapPointer.png"]);
    [baiduMap addAnnotation:location Title:[searchedPlaceInfo objectForKey:@"name"] Subtitle:[searchedPlaceInfo objectForKey:@"v"] Image:imageData];
}

//Get all popular checkins from the world
-(void)getAllPopularCheckins
{
    [baiduMap RemoveAllAnnotations];
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:pageNumber] forKey:@"page_number"];
    [inputParams setValue:@"300" forKey:@"per_page"];
    
    if (nearByLocationsList.count == 0){
        // Show Loading View
        [self.myViewActivity setHidden:NO];
        self.myConstraintContainerTop.constant = 50.0;
        self.myViewActivityIndicator.type = DGActivityIndicatorAnimationTypeBallClipRotatePulse;
        self.myViewActivityIndicator.tintColor = [UIColor yellowColor];
        
        self.myViewActivityIndicator.frame = CGRectMake(self.myViewActivityIndicator.frame.origin.x, self.myViewActivityIndicator.frame.origin.y, 30.0, 30.0);
//        [self.myViewActivityIndicator startAnimating];
    }
    
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:POPULAR_CHECKINS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            if (nearByLocationsList.count == 0){
                nearByLocationsList = [[NSMutableArray alloc]init];
            }
//            [_clusterManager clearItems];
            
            pageNumber = [[response valueForKey:@"next_page"] intValue];
            
            if(pageNumber != -1){
                
                [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
                if(isFirstShown)
                [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO withMediaBase:[response objectForKey:@"media_base_url"] shouldAnimate:YES];
                else
                [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO withMediaBase:[response objectForKey:@"media_base_url"] shouldAnimate:NO];
                
                isFirstShown = NO;
                
                [self getAllPopularCheckins];
            }
            
            else {
                
                [self.myViewActivity setHidden:YES];
                [self.myViewActivityIndicator stopAnimating];
                self.myConstraintContainerTop.constant = 0.0;
            }
        }
        else{
            
        }
    } isShowLoader:NO];
}

// Get near by checkin Pins
-(void)getNearByLocation
{
    gotNearByResponse = YES;
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
    [inputParams setValue:[NSNumber numberWithDouble:lang] forKey:@"longitude"];
    
    [self.tableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_CHECKIN_LOCATION withCallBack:^(NSDictionary * response){
        [self.tableView.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            nearByLocationsList = [[NSMutableArray alloc]init];
            [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
            [self addSearchedLocation];
            [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:YES withMediaBase:[response objectForKey:@"media_base_url"] shouldAnimate:YES];
        }
        else{
            
        }
    } isShowLoader:YES];
}

- (void)showNearByPins:(NSMutableArray *)checkins showAlert:(BOOL)alert withMediaBase:(NSString*)mediaBase shouldAnimate:(BOOL)animate{
    [nearByLocationsList removeAllObjects];
    for (int i=0; i < [checkins count]; i++) {
        NSMutableDictionary *offer = [[checkins objectAtIndex:i] mutableCopy];
        [offer setValue:[offer valueForKey:@"checkin_location"] forKey:@"name"];
        [offer setValue:[offer valueForKey:@"location_address"] forKey:@"subTitle"];
        [offer setObject:mediaBase forKey:@"media_base"];
        [offer setValue:[NSNumber numberWithInteger:1]  forKey:@"show_custom_view"];
        [nearByLocationsList addObject:offer];
    }
    if ([nearByLocationsList count] == 0 && alert) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_NEAR_BY_CHECKIN, nil)];
    }
    else{
        // IF ch or zh is an CHINA
        NSString *country_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
        
        if([country_code isEqualToString:@"cn"] || [country_code isEqualToString:@"zh"]){
//            [baiduMap addAnnotations:nearByLocationsList shouldAnimate:animate];
            // TODO: support animating
            [self addClusteredAnnotations:nearByLocationsList];
        }
    }
    
    
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        baiduMap.nearByPinAdded = NO;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        gotNearByResponse= NO;
    });
}
- (IBAction)addCheckIn:(id)sender {
    if([[Util sharedInstance] getNetWorkStatus])
    {
        UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        CreatePostViewController *postCreate = [mainStoryboard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
        postCreate.postFromProfile = @"true";
        [navigation pushViewController:postCreate animated:NO];
    }
    else{
        
        [networkPopup show];
    }
}

-(void) getVisiblePopularCheckins:(NSNotification *) notification
{
    NSDictionary *dict = notification.userInfo;
    NSDictionary *coordinates = [dict valueForKey:@"cornerCoordinates"];
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
    [inputParams setValue:[coordinates objectForKey:@"southwest_lat"] forKey:@"southwest_latitude"];
    [inputParams setValue:[coordinates objectForKey:@"southwest_long"] forKey:@"sounthwest_longitude"];
    [inputParams setValue:[coordinates objectForKey:@"northeast_lat"] forKey:@"northeast_latitude"];
    [inputParams setValue:[coordinates objectForKey:@"northeast_long"] forKey:@"northeast_longitude"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:VISIBLE_POPULAR_CHECKIN withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            if(!gotNearByResponse && !baiduMap.nearByPinAdded){
                [baiduMap RemoveAllAnnotations];
                nearByLocationsList = [[NSMutableArray alloc]init];
                [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
                [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO withMediaBase:[response objectForKey:@"media_base_url"] shouldAnimate:NO];
            }
            gotNearByResponse = NO;
        }
        else{
        }
    } isShowLoader:NO];
}

- (void)addClusteredAnnotations:(NSMutableArray *)annotationArray {
    CLLocationCoordinate2D location;
    for (int loop = 0;loop < [annotationArray count]; loop++) {
        NSMutableDictionary *annotationInfo = [[NSMutableDictionary alloc] initWithDictionary:[annotationArray objectAtIndex:loop]];
        
        location.latitude = [[annotationInfo objectForKey:@"latitude"] doubleValue];
        location.longitude = [[annotationInfo objectForKey:@"longitude"] doubleValue];
        
        BaiduCheckinItem *item = [[BaiduCheckinItem alloc] initWithPosition:location title:[annotationInfo objectForKey:@"name"] snippet:[annotationInfo objectForKey:@"subTitle"] userData:annotationInfo];
        
        [_clusterManager addItem:item];
    }
    
    [_clusterManager cluster];
}

@end
