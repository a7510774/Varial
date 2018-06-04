//
//  GoogleCheckin.m
//  Varial
//
//  Created by jagan on 13/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "GoogleCheckin.h"

@interface GoogleCheckin ()

@end

@implementation GoogleCheckin

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    placesList = [[NSMutableArray alloc] init];
    
    _headerView.delegate = self;
    
    [self designTheView];
    [self createPopUpWindows];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageReload:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    if(_showPopup && name == nil)
        [self getNearBy:NULL];
}

-(void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewDidUnload{
    [[LocationManager sharedManager] stopUpdateLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    _googleMap.delegate = nil;
    [_googleMap removeMarkersFromTheMap];
    [_googleMap removeFromSuperview];
    _googleMap = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
    

- (void)pageReload:(NSNotification *) data{
    
    [self viewWillAppear:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) updateLocation:(NSNotification *) data{
    [[LocationManager sharedManager] stopUpdateLocation];
    
    [_googleMap focusCurrentLocation];
    [_googleMap enableMyLocation:YES];
}

- (void)designTheView{
    
    //Change header
    [_headerView setHeader:NSLocalizedString(CHECK_IN_TITLE, nil)];

    [_headerView.logo setHidden:YES];
    
    _placesAutoComplete.backgroundColor = [UIColor clearColor];
    
    [Util createRoundedCorener:_checkInButton withCorner:3];
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util setPadding:_searchField];
    
    //Create near  by popup
    nearestPopup = [KLCPopup popupWithContentView:self.nearestView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_searchField addTarget:self
                     action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    
    self.placesAutoComplete.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.nearestTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Add poweredBy google
    [self addPoweredBy:_placesAutoComplete];
    [self addPoweredBy:_nearestTable];
    
    // If add checkin from buzzard run should hide the search bar
    if ([_isCheckinFromBuzzardRun isEqualToString:@"yes"]) {
        [_searchView hideByHeight:YES];
    }
    
}

- (void)createPopUpWindows
{
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(NO_NEARBY_LOCATION, nil)];
    popupView.message.text = NSLocalizedString(USE_CURRENT_LOCATION, nil);
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    
     [yesNoPopup dismiss:YES];
    
    CreatePostViewController *postCreate = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers]count] - 2 ];
    [postCreate.inputParams setValue:NSLocalizedString(MY_CURRENT_LOCATION, nil) forKey:@"check_in_name"];
    [postCreate.inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].latitude] forKey:@"check_in_latitude"];
    [postCreate.inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].longitude] forKey:@"check_in_longitude"];
    [postCreate.inputParams setValue:@"" forKey:@"check_in_state"];
    [postCreate.inputParams setValue:@"" forKey:@"check_in_city"];
    [postCreate.inputParams setValue:@"" forKey:@"check_in_country"];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)onNoClick{
    [yesNoPopup dismiss:YES];
}

//Add poweredBy google in autocomplete table view
- (void)addPoweredBy:(UITableView *)tableView {
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 300, 20)];
    footer.backgroundColor = [UIColor whiteColor];
    UIImageView *powerdBy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poweredby.png"]];
    powerdBy.backgroundColor = [UIColor whiteColor];
    powerdBy.frame = CGRectMake(10, 0, 300, 20);
    powerdBy.contentMode = UIViewContentModeLeft;
    [footer addSubview:powerdBy];
    tableView.tableFooterView = footer;
}

//Search box text change listener
- (void) textChangeListener :(UITextField *) searchBox{
    
    NSLog(@"SEARCH TEXT :%@",[searchBox text]);
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
    
    CGFloat height = self.placesAutoComplete.rowHeight;
    height = (height*placesList.count) + 20;
    
    CGRect tableFrame = self.placesAutoComplete.frame;
    tableFrame.size.height = height;
    self.placesAutoComplete.frame = tableFrame;
}

- (IBAction)addCheckin:(id)sender {    
    if (name != nil) {
        CreatePostViewController *postCreate = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers]count] - 2 ];
        [postCreate.inputParams setValue:name forKey:@"check_in_name"];
        [postCreate.inputParams setValue:[NSString stringWithFormat:@"%lf",lat] forKey:@"check_in_latitude"];
        [postCreate.inputParams setValue:[NSString stringWithFormat:@"%lf",lang] forKey:@"check_in_longitude"];
        [postCreate.inputParams setValue:state forKey:@"check_in_state"];
        [postCreate.inputParams setValue:city forKey:@"check_in_city"];
        [postCreate.inputParams setValue:state forKey:@"check_in_country"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [[AlertMessage sharedInstance] showMessage:ADD_A_CHECKIN];
    }
}

//Get near by places
- (IBAction)getNearBy:(id)sender {
    
    //check for location service
    if( ![Util checkLocationIsEnabled] )
    {
        [[Util sharedInstance] showLocationAlert];
    }
    else{
        
        [_nearestView setHidden:NO];
        [nearestPopup show];
        
        [placesList removeAllObjects];
        [_nearestTable reloadData];
        
        //nearby places
        [_googleMap getMyNearestPlaces:^(NSMutableArray * placesResponse) {
            
            if([placesResponse count] > 0){
                
                NSLog(@"NearBy Places list");
                NSLog(@"%@", placesResponse);
                placesList = placesResponse;
                [_nearestTable reloadData];
                
             }
            if ([placesList count] == 0) {
                [nearestPopup dismiss:YES];
                [yesNoPopup show];
            }

            
        }];
    }
}

//Clear search
- (IBAction)clearSearch:(id)sender {
    
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    
    //hide tableview
    [_searchField resignFirstResponder]; //Hide keyboard
    [_placesAutoComplete setHidden:YES];
    
    //Enable my location
    [_googleMap removeMarkersFromTheMap];
    [_googleMap focusCurrentLocation];
    [_googleMap enableMyLocation:YES];
    name = nil;
}

#pragma mark UITableView

//Return number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [placesList count];
}

//Design the table row
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell;
    if(tableView == _placesAutoComplete){
        static NSString *cellIdentifier = @"autoCompleteCell";
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
    else {
        static NSString *cellIdentifier = @"nearByCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if([placesList count] > 0){
            //Read UI elements
            UILabel *title = (UILabel *) [cell viewWithTag:10];
            NSDictionary *placeInfo = [placesList objectAtIndex:indexPath.row];
            [title setText:[placeInfo objectForKey:@"place"]];
        }
    }
    return cell;
    
}


//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"SELECTED ROW : %ld",(long)indexPath.row);
    NSDictionary *selectedPlaceData;
    if ([placesList count] > indexPath.row) {
        selectedPlaceData = [placesList objectAtIndex:indexPath.row];
    }
    
    if (selectedPlaceData != nil) {
        
        if(tableView == _placesAutoComplete){
            //Set label text
            [_searchField setText:[selectedPlaceData objectForKey:@"place"]];
            [_placesAutoComplete setHidden:YES];
            [_searchField resignFirstResponder]; //Hide keyboard
        }
        else{
            [nearestPopup dismiss:YES];
            //Clear the search text
            [_searchField setText:@""];
            [_clearButton setHidden:YES];
        }
        
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
                [_googleMap moveToLocation:placeInfo.coordinate];
                [_googleMap addMarker:placeInfo.coordinate withTitle:placeInfo withIcon:[UIImage imageNamed:@"pinIconActive"]];
                [_checkInButton setEnabled:YES];
                
            }];
        }];
        
        //Hide the current location
        [_googleMap enableMyLocation:NO];
    }
}


@end
