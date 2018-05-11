//
//  BuzzardRunHome.m
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BuzzardRunHome.h"
#import "SVPullToRefresh.h"
#import "LocationManager.h"
#import "ViewNearByInMap.h"
#import "GoogleAdMob.h"

@interface BuzzardRunHome ()

@end

@implementation BuzzardRunHome

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setInfiniteScrollForTableView];
    [self designTheView];
    [self getAllBuzzardRun];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageReload:) name:UIApplicationWillEnterForegroundNotification object:nil];
    locationUpdated = FALSE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisplayAd:) name:@"AdShown" object:nil];
    
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
}

- (void) didDisplayAd:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat height =[[userInfo objectForKey:@"height"] floatValue];
    _allBuzzardRunBottom.constant = height;
    _nearByViewBottom.constant = height;
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pageReload" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Page reload when application will enter foreground
- (void)pageReload:(NSNotification *) data{
    [self nearByViewDesign];
}

- (void)designTheView
{
    self.buzzardRunTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.nearByTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _nearByTableView.delegate = self;
    _nearByTableView.dataSource = self;
    
    allBuzzardRunList = [[NSMutableArray alloc] init];
    searchList = [[NSMutableArray alloc]init];
    nearByList = [[NSMutableArray alloc] init];
    page = previousPage = 1;
    [_headerView setHeader:NSLocalizedString(BUZZARD_RUN, nil)];

    
    //Hide the my buzzard run button if can_participate_in_bazzardrun is true
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"can_participate_in_bazzardrun"]){
        [_viewNearByBig setHidden:YES];
    }
    else{
        [_nearBySmall setHidden:YES];
        [_buzzardRun setHidden:YES];
    }
    
    [Util createRoundedCorener:_viewNearByBig withCorner:3.0];
    [Util createRoundedCorener:_nearBySmall withCorner:3.0];
    [Util createRoundedCorener:_buzzardRun withCorner:3.0];
    [Util createRoundedCorener:_locationButton withCorner:3.0];
    
    
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    [self setTabBarColor];
    
    _tabBar.delegate = self;
    _tabBar.layer.borderColor = UIColorFromHexCode(THEME_COLOR).CGColor;
    _tabBar.layer.borderWidth = 0.5;

    
    [_tabBar setSelectedItem:_tabOne];
    [_buzzardRunTable setBackgroundColor:[UIColor clearColor]];
    [_allBuzzardRunView setHidden:YES];
    [_searchTable setHidden:YES];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_searchField addTarget:self  action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    [Util setPadding:_searchField];
    
    [self nearByViewDesign];
    
}

- (void)setTabBarColor
{
    // Tab Bar
    [_tabBar setTintColor:[UIColor whiteColor]];
    [_tabBar setSelectionIndicatorImage:[Util convertColorToImage:UIColorFromHexCode(THEME_COLOR) byDivide:2 withHeight:60]];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"CenturyGothic" size:13], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
}


- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self setTabBarColor];
    self.tabBar.itemPositioning = UITabBarItemPositioningFill;
}


//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak BuzzardRunHome *weakSelf = self;
    // setup infinite scrolling
    [self.buzzardRunTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.searchTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreSearchResult];
    }];
    [self.nearByTableView addInfiniteScrollingWithActionHandler:^{
        [self.nearByTableView.infiniteScrollingView stopAnimating];
    }];
    [self.buzzardRunTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.searchTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.nearByTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak BuzzardRunHome *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getAllBuzzardRun];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.buzzardRunTable.infiniteScrollingView stopAnimating];
    }
}

//Add load more items
- (void)loadMoreSearchResult {
    if(searchPage > 0 && searchPrevious != searchPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak BuzzardRunHome *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            searchPrevious = searchPage;
            [weakSelf searchBuzzardRun];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.searchTable.infiniteScrollingView stopAnimating];
    }
}

//Hide or show the views based on tab click
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if(item.tag==1){
        [_allBuzzardRunView setHidden:YES];
        [_nearByView setHidden:NO];
        [self nearByViewDesign];
    }
    else{
        [_allBuzzardRunView setHidden:NO];
        [_nearByView setHidden:YES];
    }
}

-(void)nearByViewDesign{
    if(!locationUpdated){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:@"LocationUpdated" object:nil];
        [[LocationManager sharedManager] startUpdateLocation];
    }
    if(![Util checkLocationIsEnabled])
    {
        [_locationButton setHidden:NO];
        [_nearByTableView setHidden:YES];
    }
    else
    {
        [_locationButton setHidden:YES];
        [_nearByTableView setHidden:NO];
        [_nearByTableView reloadData];
    }
}

//Listen for text change in search field
- (void) textChangeListener :(UITextField *) searchBox
{
    if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        self.buzzardRunTable.hidden=YES;
        [self.searchTable setHidden:NO];
        searchPage = searchPrevious = 1;
        if (task != nil) {
            [task cancel];
        }
        [self searchBuzzardRun];
        
    }
    else{
        [_clearButton setHidden:YES];
        [self.searchTable setHidden:YES];
        self.buzzardRunTable.hidden=NO;
    }
    
    if ([_searchField.text length] > 0) {
        [_clearButton setHidden:NO];
    }
}

-(IBAction)viewNearBy:(id)sender
{
    if(![Util checkLocationIsEnabled])
    {
        [[Util sharedInstance] showLocationAlert];
    }
    else
    {
        if ([LocationManager sharedManager].latitude == 0) {
            //Please try again
        }
        else{
            ViewNearByInMap *nearBy = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewNearByInMap"];
            nearBy.type=@"1";
            [self.navigationController pushViewController:nearBy animated:YES];
            
        }
    }
}

-(IBAction)myBuzzardRun:(id)sender
{
    
}

// Clear the search text
- (IBAction)clearClick:(id)sender
{
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    [self.searchTable setHidden:YES];
    [self.buzzardRunTable setHidden:NO];
}

- (IBAction)enableLocationService:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


- (void) updateLocation:(NSNotification *) data{
    [[LocationManager sharedManager] stopUpdateLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
    [self getAllNearByBuzzardRun];
    locationUpdated = TRUE;
    [self nearByViewDesign];
    
}


// Check search result is empty
-(void)searchResultIsEmpty
{
    if ([searchList count] == 0)
    {
        [Util addEmptyMessageToTable:self.searchTable withMessage:NO_RESULT_FOUND withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.searchTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
    
}

// Check buzzardRun table is empty
-(void)buzzardRunTableIsEmpty
{
    if ([allBuzzardRunList count] == 0)
    {
        [Util addEmptyMessageToTable:self.buzzardRunTable withMessage:NO_BUZZARD_RUN_AVAILABLE withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.buzzardRunTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

-(void)nearByTableIsEmpty{
    if ([nearByList count] == 0)
    {
        [Util addEmptyMessageToTable:self.nearByTableView withMessage:NO_BUZZARD_RUN_AVAILABLE withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.nearByTableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

//Get buzzard run list
-(void) getAllBuzzardRun{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [_buzzardRunTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:ALL_BUZZARD_RUN withCallBack:^(NSDictionary * response){
        
        [_buzzardRunTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            page = [[response valueForKey:@"page"] intValue];
            [allBuzzardRunList addObjectsFromArray:[[response objectForKey:@"buzzardrun_list"] mutableCopy]];
            [self buzzardRunTableIsEmpty];
            [_buzzardRunTable reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}


//Search buzzard runs
-(void) searchBuzzardRun
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchPage] forKey:@"page"];
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    
    [_searchTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_ALL_BUZZARD_RUN withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [_searchTable.infiniteScrollingView stopAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (mediaBase == nil) {
                    mediaBase = [response objectForKey:@"media_base_url"];
                }
                
                //Hide or show the search table
                [self.searchTable setHidden:NO];
                if([_searchField.text isEqualToString:@""]){
                    [self.searchTable setHidden:YES];
                }
                
                if (searchPage == 1) {
                    [searchList removeAllObjects];
                    mediaBase = [response objectForKey:@"media_base_url"];
                }
                
                [searchList addObjectsFromArray: [[response objectForKey:@"buzzardrun_list"] mutableCopy]];
                [self.searchTable reloadData];
                
                searchPage = [[response valueForKey:@"page"] intValue];
                
                //Add no result message
                [self searchResultIsEmpty];
                
                //Scroll to top
                [Util scrollToTop:_searchTable fromArrayList:searchList];
            });
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}

//Get buzzard run list
-(void) getAllNearByBuzzardRun{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].latitude] forKey:@"latitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].longitude] forKey:@"longitude"];

    [self.nearByTableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_BUZZARD_RUN withCallBack:^(NSDictionary * response){
        
        [self.nearByTableView.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            
            nearByList = [[response objectForKey:@"near_by_buzzard_run"] mutableCopy];
            [self nearByTableIsEmpty];
            [_nearByTableView reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}

//Navigate to buzzard run details page
- (void)moveToBuzzardRunDetails:(NSString *)buzzardRunId{
    BuzzardRunDetails *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"BuzzardRunDetails"];
    detail.buzzardRunId = buzzardRunId;
    [self.navigationController pushViewController:detail animated:YES];
}


#pragma  args UITableView delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _nearByTableView){
        return [nearByList count];
    }
    else{
        if (tableView == _buzzardRunTable) {
            return [allBuzzardRunList count];
        }
        else
        {
            return [searchList count];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell ;
    
    static NSString *cellIdentifier = @"buzzardrun";
    cell= [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:10];
    UILabel *name =  (UILabel *)[cell viewWithTag:11];
    UILabel *subname = (UILabel *) [cell viewWithTag:12];
    UILabel *address = (UILabel *) [cell viewWithTag:13];
    UILabel *date = (UILabel *) [cell viewWithTag:14];
    UILabel *reward = (UILabel *) [cell viewWithTag:100];
    
    if(tableView != _nearByTableView){
        NSDictionary *buzzardRun = tableView == self.searchTable ? [searchList objectAtIndex:indexPath.row] : [allBuzzardRunList objectAtIndex:indexPath.row];
        
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[buzzardRun valueForKey:@"buzzardrun_image"]];
        [profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
        //Add zoom
       // [[Util sharedInstance] addImageZoom:profileImage];
        
        
        name.text = [buzzardRun valueForKey:@"buzzardrun_name"];
        subname.text = [buzzardRun valueForKey:@"shop_name"];
        address.text = [buzzardRun valueForKey:@"buzzardrun_address"];
        reward.text = [buzzardRun valueForKey:@"reward"];
        date.text = [NSString stringWithFormat:@"(%@)",[Util getDate:[[buzzardRun valueForKey:@"valid_timestamp"] longLongValue]]];
    }
    else{
        NSDictionary *buzzardRun = [nearByList objectAtIndex:indexPath.row];
        
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[buzzardRun valueForKey:@"buzzard_run_image"]];
        [profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
        //Add zoom
        //[[Util sharedInstance] addImageZoom:profileImage];
        
        
        name.text = [buzzardRun valueForKey:@"buzzard_runs_name"];
        subname.text = [buzzardRun valueForKey:@"shop_name"];
        address.text = [buzzardRun valueForKey:@"buzzard_run_address"];
        reward.text = [buzzardRun valueForKey:@"reward"];
        date.text = [NSString stringWithFormat:@"(%@)",[Util getDate:[[buzzardRun valueForKey:@"buzzard_runs_vaild_upto"] longLongValue]]];
        
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *buzzardRun;
    if(tableView == self.nearByTableView){
        buzzardRun = [nearByList count] > indexPath.row ? [nearByList objectAtIndex:indexPath.row] : nil;
        if (buzzardRun != nil) {
            [self moveToBuzzardRunDetails:[buzzardRun valueForKey:@"buzzard_run_id"]];
        }
        
    }
    else {
        if(tableView == self.searchTable) {
            buzzardRun = [searchList count] > indexPath.row ? [searchList objectAtIndex:indexPath.row] : nil;
        }else{
            buzzardRun = [allBuzzardRunList count] > indexPath.row ? [allBuzzardRunList objectAtIndex:indexPath.row] : nil;
        }
        if (buzzardRun != nil) {
            [self moveToBuzzardRunDetails:[buzzardRun valueForKey:@"buzzardrun_id"]];
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



@end
