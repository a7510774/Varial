//
//  OffersHome.m
//  Varial
//
//  Created by Shanmuga priya on 3/15/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "OffersHome.h"
#import "ShopDetails.h"
#import "Util.h"
#import "MyAnnotation.h"
#import "ViewNearByInMap.h"
@interface OffersHome ()

@end

@implementation OffersHome

- (void)viewDidLoad {
    [super viewDidLoad];
    page = previousPage = 1;
    nearByList = [[NSMutableArray alloc] init];
    [self designTheView];
    [self setInfiniteScrollForTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageReload:) name:UIApplicationWillEnterForegroundNotification object:nil];
    locationUpdated = FALSE;

}
-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"selectedTab %d",selectedTabBar);
    [self nearByViewDesign];
}

- (void)viewDidDisappear:(BOOL)animated{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
     NSLog(@"selectedTab on view Dismiss :%d",selectedTabBar);
}

- (void)designTheView
{
    selectedTabBar = 1;
    
    //Hide the tab bar based on the pervilages
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"can_show_shop_offers"]){

        [_headerView setHeader: NSLocalizedString(OFFERS, nil)];
        [self reloadList];
    }
    else{
        [_headerView setHeader: NSLocalizedString(NEAR_BY_OFFERS, nil)];

        [_tabBar hideByHeight:YES];
    }
    [_headerView.logo setHidden:YES];
    
    
    _nearByTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _nearByTableView.hidden = YES;
    [_nearByTableView setBackgroundColor:[UIColor clearColor]];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setHidden:YES];

    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    [self setTabBarColor];
   
    _tabBar.delegate=self;
    [_tabBar setSelectedItem:_tabOne];
    [Util createRoundedCorener:_viewOfferListButton withCorner:3];
    [Util createBorder:_tabBar withColor:UIColorFromHexCode(THEME_COLOR)];
    
  //  [self nearByViewDesign];
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

- (void)viewDidUnload{
    [[LocationManager sharedManager] stopUpdateLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Reload the offer list
- (void) reloadList{
    //reload the page once we back to this page
    page = previousPage = 1;
    [fromShopList removeAllObjects];
    [self getFromShopList];
}

// Page reload when application will enter foreground
- (void)pageReload:(NSNotification *) data{
    [self nearByViewDesign];
}

- (void) updateLocation:(NSNotification *) data{
    [[LocationManager sharedManager] stopUpdateLocation];
    locationUpdated = TRUE;
    [self getNearByOffers];
    [self nearByViewDesign];
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getFromShopList{
    
    //Send offer list from shop request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [self.tableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FROM_SHOP_LIST withCallBack:^(NSDictionary * response){
        [self.tableView.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            page = [[response valueForKey:@"page"]intValue];
            if(mediaBase == nil)
                mediaBase = [response valueForKey:@"media_base_url"];
            fromShopList=[response objectForKey:@"offers_list"];
             [_tableView reloadData];
            [self addEmptyMessage];
        }
        else{
            
        }
    } isShowLoader:NO];
    
}


//Get near by offers
-(void)getNearByOffers{
    
    //Send offer list from shop request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].longitude] forKey:@"longitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].latitude]  forKey:@"latitude"];
    [self.nearByTableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_OFFER_LIST withCallBack:^(NSDictionary * response){
    
        [self.nearByTableView.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            nearByList=[[response objectForKey:@"offers_list"] mutableCopy];
            [self nearByListEmpty];
            [_nearByTableView reloadData];
            _nearByTableView.hidden = NO;
            if (mediaBase == nil) {
                mediaBase = [response valueForKey:@"media_base_url"];
            }
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}

//Add empty message in table background view
- (void)addEmptyMessage{
    
    if ([fromShopList count] == 0) {
        [Util addEmptyMessageToTable:_tableView withMessage:NO_OFFER_NOTIFICATION withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:_tableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

//Add empty message in table background view
- (void)nearByListEmpty{
    
    if ([nearByList count] == 0) {
        [Util addEmptyMessageToTable:_nearByTableView withMessage:NO_NEAR_BY_OFFERS withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:_nearByTableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak OffersHome *weakSelf = self;
    // setup infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.nearByTableView addInfiniteScrollingWithActionHandler:^{
        [self.nearByTableView.infiniteScrollingView stopAnimating];
    }];
    
    [self.tableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.nearByTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak OffersHome *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getFromShopList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.tableView.infiniteScrollingView stopAnimating];
    }
}

//Navigate to near by offers list screen
- (IBAction)viewOfferList:(id)sender {
    if([Util checkLocationIsEnabled]){
        ViewNearByInMap *nearBy = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewNearByInMap"];
        nearBy.type=@"3";
        [self.navigationController pushViewController:nearBy animated:YES];
    }
    else{
        [[Util sharedInstance] showLocationAlert];
    }
}

- (IBAction)enableLocationService:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


//Navigate to shop details page
- (void)moveToShopDetails:(NSString *)offerId{
    ShopDetails *shopDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ShopDetails"];
    shopDetail.offerId = offerId;
    [self.navigationController pushViewController:shopDetail animated:YES];
}


#pragma mark UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _nearByTableView){
        return  [nearByList count];
    }
    else{
        return  [fromShopList count];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     static NSString *cellIdentifier = @"shopCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
    UILabel *title =  (UILabel *)[cell viewWithTag:11];
    UILabel *description = (UILabel *) [cell viewWithTag:12];
    UILabel *timeStamp = (UILabel *) [cell viewWithTag:13];
    //description.numberOfLines=0;
    description.numberOfLines = 3;
    description.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if(tableView == _nearByTableView){
        NSDictionary *offerList = [nearByList objectAtIndex:indexPath.row];
        title.text = [offerList valueForKey:@"offer_name"];
        
//        NSString *desc = [offerList valueForKey:@"offer_description"];
//        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithData:[desc dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        
//        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [UIFont fontWithName:@"CenturyGothic" size:15], NSFontAttributeName,
//                                    [UIColor whiteColor], NSForegroundColorAttributeName, nil];
//        [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString.string length] - 1)];
        
        NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(VIEW_DETAILS, nil)];
        
//        [attributed addAttribute:NSUnderlineStyleAttributeName
//                                value:[NSNumber numberWithInt:1]
//                                range:(NSRange){0,[attributed length]}];
        
        description.attributedText = attributed;
         timeStamp.text = [NSString stringWithFormat:NSLocalizedString(@"Valid Upto %@", nil) ,[Util getDate:[[offerList valueForKey:@"valid_timestamp"] longValue]]];
        NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[offerList valueForKey:@"shop_image_thumb"]];
        
        [profile setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
        
        [[Util sharedInstance] addImageZoom:profile];

    }
    else{
        
        NSDictionary *offerList = [fromShopList objectAtIndex:indexPath.row];
        title.text = [offerList valueForKey:@"offer_name"];
//        NSString *desc = [offerList valueForKey:@"offer_description"];
//        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithData:[desc dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        
//        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [UIFont fontWithName:@"CenturyGothic" size:15], NSFontAttributeName,
//                                    [UIColor whiteColor], NSForegroundColorAttributeName, nil];
//        [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString.string length] - 1)];
        
        NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(VIEW_DETAILS, nil)];
        
        /*[attributed addAttribute:NSUnderlineStyleAttributeName
                           value:[NSNumber numberWithInt:1]
                           range:(NSRange){0,[attributed length]}];*/
        
        description.attributedText = attributed;  // [offerList valueForKey:@"offer_description"];
        timeStamp.text = [NSString stringWithFormat:NSLocalizedString(@"Valid Upto %@", nil) ,[Util getDate:[[offerList valueForKey:@"valid_timestamp"] longValue]]];
        NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[offerList valueForKey:@"shop_image"]];
        
        [profile setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
        
        [[Util sharedInstance] addImageZoom:profile];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    if(item.tag==1){
        [_tableView setHidden:YES];
        [_nearByTableView setHidden:NO];
        [_viewOfferListButton setHidden:NO];
        [_locationButton setHidden:NO];
        selectedTabBar = 1;
        [self nearByViewDesign];
    }
    else{
        [_tableView setHidden:NO];
        [_nearByTableView setHidden:YES];
        [_locationButton setHidden:YES];
        [_viewOfferListButton setHidden:YES];
        selectedTabBar = 2;
        [self addEmptyMessage];
    }
}

-(void)nearByViewDesign{
    
    if(!locationUpdated){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:@"LocationUpdated" object:nil];
        [[LocationManager sharedManager] startUpdateLocation];
    }
    if( ![Util checkLocationIsEnabled] )
    {
        if (selectedTabBar == 1) {
            [_locationButton setHidden:NO];
            [_nearByTableView setHidden:YES];
        }
    }
    else
    {
        [_locationButton setHidden:YES];
        if (selectedTabBar == 1) {
            [_nearByTableView setHidden:NO];
            [_nearByTableView reloadData];
            [_tableView setHidden:YES];
        }
        
        else{
            [_nearByTableView setHidden:YES];
            [_tableView setHidden:NO];
        }
       
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _nearByTableView){
        NSMutableDictionary *offer = [nearByList objectAtIndex:indexPath.row];
        [self moveToShopDetails:[offer valueForKey:@"offer_id"]];
    }
    else{
    NSMutableDictionary *offer = [fromShopList objectAtIndex:indexPath.row];
    [self moveToShopDetails:[offer valueForKey:@"offer_id"]];
    }
}


@end
