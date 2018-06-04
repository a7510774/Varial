//
//  GooglePopularCheckin.m
//  Varial
//
//  Created by vis-1674 on 02/09/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "GooglePopularCheckin.h"
#import "Util.h"
#import "MyCheckinDetails.h"
#import "GMUClusterItem.h"
#import "GMUMarkerClustering.h"
#import "GMUDefaultClusterRenderer.h"
#import "CustomClusterRenderer.h"
#import "CheckinMarker.h"
#import "DGActivityIndicatorView.h"

@interface GooglePopularCheckin (){
    
    NSTimer * timer;
    int pageNumber, myIntTotalCount, myIntLoadingPercentage;
}
@end



@implementation GooglePopularCheckin


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _googleMap.delegate = self;
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(removeMapDelegate)
//                                                 name:@"RemoveMapDelegate" object:nil];
    
//    id<GMUClusterAlgorithm> algorithm = [[GMUGridBasedClusterAlgorithm alloc] init];
    id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
    id<GMUClusterIconGenerator> iconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
    CustomClusterRenderer *renderer = [[CustomClusterRenderer alloc] initWithMapView:_googleMap
                                                                    clusterIconGenerator:iconGenerator];
    renderer.delegate = _googleMap;
    _clusterManager = [[GMUClusterManager alloc] initWithMap:_googleMap
                                                   algorithm:algorithm
                                                    renderer:renderer];
    [_clusterManager setDelegate:self mapDelegate:self];
    
    // set page number to 0
    pageNumber = 0;
    myIntTotalCount = 0;
    myIntLoadingPercentage = 10;
    
    // Hide Loading View
    [self.myViewLoading setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(removeMapDelegate)
//                                                 name:@"RemoveMapDelegate" object:nil];
    [[LocationManager sharedManager] startUpdateLocation];
    
    [self designTheView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getAllPopularCheckins];
    
//    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerCalling) userInfo:nil repeats:NO];
    
    _googleMap.settings.rotateGestures = NO;
    _googleMap.settings.tiltGestures = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (currentTask != nil) {
        [currentTask cancel];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemoveMapDelegate" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Clear Mail when switch the tab for memory management
- (void)removeMapDelegate {
    _googleMap.delegate = nil;
    [_googleMap removeMarkersFromTheMap];
    [_googleMap removeFromSuperview];
    _googleMap = nil;
}

- (void)designTheView {
    // All Checkin Google Map
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    [Util createRoundedCorener:_nearByPinButton withCorner:3];
    
    [Util setPadding:_searchField];
    
//    [_searchField addTarget:self
//                     action:@selector(textChangeListener:)
//           forControlEvents:UIControlEventEditingChanged];
//    
    _checkInButton.layer.cornerRadius = _checkInButton.frame.size.height / 2 ;
    _checkInButton.clipsToBounds = YES;
}

// ---------------- START ALL CHECKIN GOOGLE MAP ---------------------

//Search box text change listener
- (IBAction)textChangeListener:(UITextField *)searchBox {
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
            
            //hide tableview
            [self clearSearch];
            
            CLLocationCoordinate2D location;
            location.latitude = lat;
            location.longitude = lang;
            
            _googleMap.isNearByCheckIn = YES;
            [_googleMap removeMarkersFromTheMap];
            [self getNearByLocation];
            [_googleMap moveToLocation:location];
            //1. Remove all annotation   2. Show User Current Location  3. Show near by Pins
            [_googleMap addMarkerWithTitle:location withTitle:NSLocalizedString(YOU, nil) withIcon:[UIImage imageNamed:@"mapPointer.png"]];
        }
    }
    
}

-(void) clearSearch
{
    //hide tableview
    [_searchField resignFirstResponder]; //Hide keyboard
    [_placesAutoComplete setHidden:YES];
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
}

- (IBAction)clearClick:(id)sender
{
    [self clearSearch];
}

//Get all popular checkins from the world
-(void)getAllPopularCheckins
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:pageNumber] forKey:@"page_number"];
    [inputParams setValue:@"200" forKey:@"per_page"];
    
    
    if (nearByLocationsList.count == 0){
        // Show Loading View
        [self.myViewLoading setHidden:NO];
        if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
        {
            self.myLabelLoadingMessage.text = @"Loading Checkins";
        }
        else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
        {
            self.myLabelLoadingMessage.text = @"加載簽入";
        }
        self.myConstraintContainerTop.constant = 30.0;
        self.myViewActivityIndicator.type = DGActivityIndicatorAnimationTypeBallClipRotatePulse;
        self.myViewActivityIndicator.size = 30.0;
        self.myViewActivityIndicator.tintColor = [UIColor yellowColor];
        
        self.myViewActivityIndicator.frame = CGRectMake(self.myViewActivityIndicator.frame.origin.x, self.myViewActivityIndicator.frame.origin.y, 20.0, 20.0);
        [self.myViewActivityIndicator startAnimating];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:POPULAR_CHECKINS withCallBack:^(NSDictionary * response){
        //        NSLog(@"POPULAR CHECKINS %@", response);
        if (nearByLocationsList.count == 0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            nearByLocationsList = [[NSMutableArray alloc]init];
        }
        
        if([[response valueForKey:@"status"] boolValue]){
            
            //[_clusterManager clearItems];
            
            //            [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO isVisiblePin:YES];
            pageNumber = [[response valueForKey:@"next_page"] intValue];
            
            if(pageNumber != -1){
                
                [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
                mediaBase = [response objectForKey:@"media_base_url"];
                [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO isVisiblePin:YES isFromPopularCheckin:YES];
                
                [self getAllPopularCheckins];
            }
            else {
                
                [self.myViewLoading setHidden:YES];
                [self.myViewActivityIndicator stopAnimating];
                self.myConstraintContainerTop.constant = 0.0;
            }
        }
        else{
            
        }
    } isShowLoader:NO];
}


-(void)getNearByLocation
{
    gotnearByResponse = YES;
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
    [inputParams setValue:[NSNumber numberWithDouble:lang] forKey:@"longitude"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_CHECKIN_LOCATION withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            nearByLocationsList = [[NSMutableArray alloc]init];
            [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
            mediaBase = [response objectForKey:@"media_base_url"];
            
            [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:YES isVisiblePin:YES isFromPopularCheckin:NO];
//            [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:YES isVisiblePin:YES];
        }
        else{
            
        }
        
    } isShowLoader:YES];
}

- (void)showNearByPins:(NSMutableArray *)checkins showAlert:(BOOL)alert isVisiblePin:(BOOL)visiblePin isFromPopularCheckin:(BOOL)isFromPopular {
    
    //if (!isFromPopular) {
        [nearByLocationsList removeAllObjects];
   // }
    for (int i=0; i < [checkins count]; i++) {
        NSMutableDictionary *offer = [[checkins objectAtIndex:i] mutableCopy];
        [offer setValue:[offer valueForKey:@"checkin_location"] forKey:@"name"];
        [offer setValue:[offer valueForKey:@"location_address"] forKey:@"subTitle"];
        [offer setValue:[offer valueForKey:@"media_url"] forKey:@"Image"];
        [nearByLocationsList addObject:offer];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[offer valueForKey:@"media_url"]];
        [Util preloadImageFromUrl:strURL];
    }
    if ([nearByLocationsList count] == 0 && alert) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_NEAR_BY_CHECKIN, nil)];
    }
    else{
//        [_googleMap addMarkers:nearByLocationsList isVisiblePin:visiblePin];
//        [_googleMap addClusteredMarkers:nearByLocationsList];
        [self addClusteredMarkers:nearByLocationsList];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        gotnearByResponse= NO;
    });
}


- (void)addClusteredMarkers:(NSMutableArray *) markerInfoArray {
    
    //    GMSMarker *markerArray[[markerInfoArray count]];
    CLLocationCoordinate2D markerLocation;
    
    for (int loop = 0;loop < [markerInfoArray count]; loop++) {
        NSMutableDictionary *markerInfo = [[NSMutableDictionary alloc] initWithDictionary:[markerInfoArray objectAtIndex:loop]];
        
        markerLocation.latitude = [[markerInfo objectForKey:@"latitude"] doubleValue];
        markerLocation.longitude = [[markerInfo objectForKey:@"longitude"] doubleValue];
        
        CheckinMarker *item = [[CheckinMarker alloc] initWithPosition:markerLocation title:[markerInfo objectForKey:@"name"] snippet:[markerInfo objectForKey:@"subTitle"] userData:markerInfo];
                
        [_clusterManager addItem:item];
        
    }
    
    [_clusterManager cluster];
}


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [placesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if([placesList count] > 0){
        
        if ([placesList count] > indexPath.row) {
            NSDictionary *placeInfo = [placesList objectAtIndex:indexPath.row];
            //[title setText:[placeInfo objectForKey:@"place"]];
            cell.textLabel.text = [placeInfo objectForKey:@"place"];
        }
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
    
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark GMUClusterManagerDelegate

- (void)zoomToCluster:(id<GMUCluster>)cluster {
    
    CLLocationDegrees maxLat = -85;
    CLLocationDegrees minLat = 85;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLon = 180;

    for (id<GMUClusterItem> clusterItem in [cluster items]) {
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

    CLLocationCoordinate2D nwCoord = CLLocationCoordinate2DMake(maxLat, minLon);
    CLLocationCoordinate2D seCoord = CLLocationCoordinate2DMake(minLat, maxLon);

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:nwCoord coordinate:seCoord];
    
//    NSLog(@"BOUNDS %f %f %f %f", maxLat, minLat, maxLon, minLon);
    [_googleMap animateToBounds:bounds];
}

- (BOOL)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster {
    
//    NSLog(@"Cluster was tapped %@", cluster);
    [self zoomToCluster:cluster];
    
//    GMSCameraPosition *newCamera = [GMSCameraPosition cameraWithTarget:cluster.position zoom:_googleMap.camera.zoom + 2];
//    GMSCameraUpdate *update = [GMSCameraUpdate setCamera:newCamera];
//    [_googleMap moveCamera:update];
    
    return YES;
}



#pragma mark GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    CheckinMarker *markerItem = marker.userData;
    if (markerItem != nil) {
//        NSLog(@"Did tap marker for cluster item %@", markerItem);
    } else {
//        NSLog(@"Did tap a normal marker");
    }
    return NO;
}

//Marker tapped click
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    NSMutableDictionary *markerInfo = (NSMutableDictionary *) marker.userData;
    if (markerInfo != nil) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        MyCheckinDetails *details = [mainStoryboard instantiateViewControllerWithIdentifier:@"MyCheckinDetails"];
        details.checkinId = [markerInfo valueForKey:@"checkin_id"];
        details.isPopularCheckinDetail = @"YES";
        [self.navigationController pushViewController:details animated:YES];
    }
    
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    
    NSMutableDictionary *markerInfo = (NSMutableDictionary *) marker.userData;
    if (markerInfo != nil) {
        MapMarkerWindow  *mapInfoWindow = [[MapMarkerWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 95)];
        mapInfoWindow.title.text = [markerInfo valueForKey:@"name"];
        mapInfoWindow.snippet.text = [markerInfo objectForKey:@"subTitle"];
        NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[markerInfo objectForKey:@"Image"]];
//        mapInfoWindow.title.text = [markerInfo valueForKey:@"checkin_location"];
//        mapInfoWindow.snippet.text = [markerInfo objectForKey:@"location_address"];
//        NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[markerInfo objectForKey:@"media_url"]];
        [mapInfoWindow.imageView setImageWithURL:[NSURL URLWithString:strURL]];
        
        if([[markerInfo objectForKey:@"media_type"] intValue] == 1 )
            mapInfoWindow.playIcon.hidden = YES;
        else
            mapInfoWindow.playIcon.hidden = NO;
        
        return mapInfoWindow;
    }
    
    return nil;
}

- (IBAction)addCheckIn:(UIButton *)sender {
    
    if([[Util sharedInstance] getNetWorkStatus])
    {
        UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        CreatePostViewController *postCreate = [mainStoryboard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
        postCreate.postFromProfile = @"true";
        [navigation pushViewController:postCreate animated:NO];
    }
    else{
        
        [appDelegate.networkPopup show];
    }
    
}

//-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
//    if(_googleMap.selectedMarker != nil){
//        CGPoint point = [_googleMap.projection pointForCoordinate:_googleMap.selectedMarker.position];
//        if(point.x < 0 || point.x > _googleMap.frame.size.width || point.y < 0 || point.y > _googleMap.frame.size.height)
//            [self getVisiblePopularCheckin];
//    }
//    if(_googleMap.selectedMarker == nil && !_googleMap.isNearByCheckIn){
//        [self getVisiblePopularCheckin];
//    }
//    _googleMap.isNearByCheckIn = NO;
//}

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
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",southWest.latitude] forKey:@"southwest_latitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",southWest.longitude] forKey:@"sounthwest_longitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",northEast.latitude] forKey:@"northeast_latitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",northEast.longitude] forKey:@"northeast_longitude"];
    
    if (currentTask != nil) {
        [currentTask cancel];
    }

    currentTask = [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:VISIBLE_POPULAR_CHECKIN withCallBack:^(NSDictionary * response){
//        NSLog(@"getVisiblePopularCheckin Status: %@", inputParams);
        currentTask = nil;
        if([[response valueForKey:@"status"] boolValue]){
            if(!gotnearByResponse){
                [_googleMap removeMarkersFromTheMap];
                nearByLocationsList = [[NSMutableArray alloc] init];
                [nearByLocationsList addObjectsFromArray:[[response objectForKey:@"checkin_list"] mutableCopy]];
                mediaBase = [response objectForKey:@"media_base_url"];
                [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO isVisiblePin:YES isFromPopularCheckin:NO];
//                [self showNearByPins:[[response objectForKey:@"checkin_list"] mutableCopy] showAlert:NO isVisiblePin:YES];
            }
            gotnearByResponse = NO;
        }
        else{
        }
    } isShowLoader:NO];
}

// Timer calling

-(void)timerCalling{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [timer invalidate];
}

@end
