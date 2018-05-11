//
//  ClubPromotionsHome.m
//  Varial
//
//  Created by jagan on 29/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ClubPromotionsHome.h"
#import "SVPullToRefresh.h"
#import "ViewNearByInMap.h"
@interface ClubPromotionsHome ()

@end

@implementation ClubPromotionsHome

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self designTheView];
    [self getAllClubPromotions];
    [self setInfiniteScrollForTableView];
    [self getAllNearByPromotions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageReload:) name:UIApplicationWillEnterForegroundNotification object:nil];
    locationUpdated = FALSE;
    //Register for get current location
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pageReload" object:nil];
}

- (void) updateLocation:(NSNotification *) data{
    [[LocationManager sharedManager] stopUpdateLocation];
    locationUpdated = TRUE;
    [self getAllNearByPromotions];
    [self nearByViewDesign];
}

// Page reload when application will enter foreground
- (void)pageReload:(NSNotification *) data{
    [self nearByViewDesign];
}

- (void)designTheView
{
    self.clubPromotionTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.nearByTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.nearByTableView setBackgroundColor:[UIColor clearColor]];
    allPromotionList = [[NSMutableArray alloc] init];
    searchList = [[NSMutableArray alloc]init];
    nearByList = [[NSMutableArray alloc] init];
    nearByList=[[NSMutableArray alloc]init];
    page = previousPage = 1;
    [_headerView setHeader:NSLocalizedString(CLUB_PROMOTION_TITLE, nil)];

    
    //Hide the my clup promotions button if can_participate_in_clubpromotion is true
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"can_participate_in_clubpromotion"]){
        [_viewNearByBig setHidden:YES];
    }
    else{
        [_nearBySmall setHidden:YES];
        [_clubPromotion setHidden:YES];
    }
    
    [Util createBorder:_tabBar withColor:UIColorFromHexCode(THEME_COLOR)];
    
    [Util createRoundedCorener:_viewNearByBig withCorner:3.0];
    [Util createRoundedCorener:_nearBySmall withCorner:3.0];
    [Util createRoundedCorener:_clubPromotion withCorner:3.0];
    [Util createRoundedCorener:_locationButton withCorner:3.0];
    
    
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    [self setTabBarColor];
    
    _tabBar.delegate=self;
    [_tabBar setSelectedItem:_tabOne];
    [_clubPromotionTable setBackgroundColor:[UIColor clearColor]];
    [_allClubPromotionView setHidden:YES];
    [_searchTable setHidden:YES];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_searchField addTarget:self  action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];
    [Util setPadding:_searchField];
    [self nearByViewDesign];
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

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self setTabBarColor];
    self.tabBar.itemPositioning = UITabBarItemPositioningFill;
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak ClubPromotionsHome *weakSelf = self;
    // setup infinite scrolling
    [self.clubPromotionTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.searchTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreSearchResult];
    }];
    [self.nearByTableView addInfiniteScrollingWithActionHandler:^{
       [self.nearByTableView.infiniteScrollingView stopAnimating];
    }];
    [self.clubPromotionTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.searchTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.nearByTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak ClubPromotionsHome *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getAllClubPromotions];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.clubPromotionTable.infiniteScrollingView stopAnimating];
    }
}

//Add load more items
- (void)loadMoreSearchResult {
    if(searchPage > 0 && searchPrevious != searchPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak ClubPromotionsHome *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            searchPrevious = searchPage;
            [weakSelf searchClubPromotions];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.searchTable.infiniteScrollingView stopAnimating];
    }
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if(item.tag==1){
        [_allClubPromotionView setHidden:YES];
        [_nearByView setHidden:NO];
    }
    else{
        [_allClubPromotionView setHidden:NO];
        [_nearByView setHidden:YES];
    }
}

-(void)nearByViewDesign{
    if(!locationUpdated){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:@"LocationUpdated" object:nil];
        [[LocationManager sharedManager] startUpdateLocation];
    }
    if( ![Util checkLocationIsEnabled] )
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

- (void) textChangeListener :(UITextField *) searchBox
{
    if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
    {
        self.clubPromotionTable.hidden=YES;
        [self.searchTable setHidden:NO];
        searchPage = searchPrevious = 1;
        if (task != nil) {
            [task cancel];
        }
        [self searchClubPromotions];
    }
    else{
        [_clearButton setHidden:YES];
        [self.searchTable setHidden:YES];
        self.clubPromotionTable.hidden=NO;
    }
    if ([_searchField.text length] > 0) {
        [_clearButton setHidden:NO];
    }
}

-(IBAction)viewNearBy:(id)sender
{
    if( ![Util checkLocationIsEnabled] )
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
            nearBy.type=@"2";
            [self.navigationController pushViewController:nearBy animated:YES];
        }
    }
}

// Clear the search text
- (IBAction)clearClick:(id)sender
{
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
    [self.searchTable setHidden:YES];
    [self.clubPromotionTable setHidden:NO];
}

- (IBAction)enableLocationService:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
}

// Show Map based the Location

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

-(void)allClubPromotionTableIsEmpty
{
    if ([allPromotionList count] == 0)
    {
        [Util addEmptyMessageToTable:self.clubPromotionTable withMessage:NO_CLUB_AVAIALBLE withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.clubPromotionTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

-(void)allNearByClubPromotionTableIsEmpty
{
    if ([nearByList count] == 0)
    {
        [Util addEmptyMessageToTable:self.nearByTableView withMessage:NO_NEAR_BY_PROMOTIONS withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.nearByTableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

//Get near by club promotion list
-(void) getAllNearByPromotions{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].latitude] forKey:@"latitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].longitude] forKey:@"longitude"];
    
    [_nearByTableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_PROMOTIONS withCallBack:^(NSDictionary * response){
        
        [_nearByTableView.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            nearByList=[response objectForKey:@"near_by_club_promotion"];
            [self allNearByClubPromotionTableIsEmpty];
            [_nearByTableView reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}


//Get club promotion list
-(void) getAllClubPromotions{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [_clubPromotionTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LIST_ALL_CLUB_PROMOTIONS withCallBack:^(NSDictionary * response){
        
        [_clubPromotionTable.infiniteScrollingView stopAnimating];
        
        if([[response valueForKey:@"status"] boolValue]){
            if (mediaBase == nil) {
                mediaBase = [response objectForKey:@"media_base_url"];
            }
            page = [[response valueForKey:@"page"] intValue];
            [allPromotionList addObjectsFromArray:[[response objectForKey:@"club_promotion_list"] mutableCopy]];
            [self allClubPromotionTableIsEmpty];
            [_clubPromotionTable reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}


//Search club promotions
-(void) searchClubPromotions
{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:searchPage] forKey:@"page"];
    [inputParams setValue:_searchField.text forKey:@"key_search"];
    
    [_searchTable.infiniteScrollingView startAnimating];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_ALL_CLUB_PROMOTION withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            [_searchTable.infiniteScrollingView stopAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //Hide or show the search table
                [self.searchTable setHidden:NO];
                if([_searchField.text isEqualToString:@""]){
                    [self.searchTable setHidden:YES];
                }
                
                if (searchPage == 1) {
                    [searchList removeAllObjects];
                    mediaBase = [response objectForKey:@"media_base_url"];
                }
                
                [searchList addObjectsFromArray: [[response objectForKey:@"search_club_promotion"] mutableCopy]];
                [self.searchTable reloadData];
                
                searchPage = [[response valueForKey:@"page"] intValue];
                
                //Add no result message
                [self searchResultIsEmpty];
                
                //Scroll to top
                [Util scrollToTop:_searchTable  fromArrayList:searchList];
            });
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}


//Navigate to buzzard run details page
- (void)moveToClubPromotionDetails:(NSString *)promotionId{
    ClubPromotionsDetails *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"ClubPromotionsDetails"];
    detail.promotionId = promotionId;
    [self.navigationController pushViewController:detail animated:YES];
}


#pragma  args UITableView delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _nearByTableView){
        return [nearByList count];
    }
    else{
        if (tableView == _clubPromotionTable) {
            return [allPromotionList count];
        }
        else
        {
            return [searchList count];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell ;
    
    static NSString *cellIdentifier = @"clubPromotion";
    
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
    UILabel *free_bies = (UILabel *) [cell viewWithTag:100];
    
    
    if(tableView != _nearByTableView){
        NSDictionary *clubPromotion = tableView == self.searchTable ? [searchList objectAtIndex:indexPath.row] : [allPromotionList objectAtIndex:indexPath.row];
        
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[clubPromotion valueForKey:@"shop_image"]];
        [profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
        //Add zoom
        [[Util sharedInstance] addImageZoom:profileImage];        
        
        name.text = [clubPromotion valueForKey:@"club_promotion_name"];
        subname.text = [clubPromotion valueForKey:@"shop_name"];
        address.text = [clubPromotion valueForKey:@"club_promotion_address"];
        date.text = [NSString stringWithFormat:@"(%@)",[Util getDate:[[clubPromotion valueForKey:@"valid_timestamp"] longLongValue]]];
        free_bies.text = [clubPromotion valueForKey:@"free_bies"];
    }
    else{
        NSDictionary *buzzardRun = [nearByList objectAtIndex:indexPath.row];
        
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[buzzardRun valueForKey:@"shop_image"]];
        [profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
        //Add zoom
        [[Util sharedInstance] addImageZoom:profileImage];
        
        
        name.text = [buzzardRun valueForKey:@"club_promotion_name"];
        subname.text = [buzzardRun valueForKey:@"shop_name"];
        address.text = [buzzardRun valueForKey:@"club_promotion_address"];
        date.text = [NSString stringWithFormat:@"(%@)",[Util getDate:[[buzzardRun valueForKey:@"club_promotion_vaild_upto"] longLongValue]]];
        free_bies.text = [buzzardRun valueForKey:@"free_bies"];
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *promotion;
    if(tableView == self.nearByTableView) {
        promotion = [nearByList count] > indexPath.row ? [nearByList objectAtIndex:indexPath.row] : nil;
    }
    else{
        if(tableView == self.searchTable) {
            promotion = [searchList count] > indexPath.row ? [searchList objectAtIndex:indexPath.row] : nil;
        }else{
            promotion = [allPromotionList count] > indexPath.row ? [allPromotionList objectAtIndex:indexPath.row] : nil;
        }
    }
    
    if (promotion != nil) {
        [self moveToClubPromotionDetails:[promotion valueForKey:@"club_promotion_id"]];
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
