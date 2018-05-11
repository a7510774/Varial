//
//  ViewNearByInMap.m
//  Varial
//
//  Created by Shanmuga priya on 4/19/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ViewNearByInMap.h"
#import "BuzzardRunDetails.h"
#import "ShopDetails.h"
#import "OffersList.h"
#import "NearClubPromotions.h"

@interface ViewNearByInMap ()

@end

@implementation ViewNearByInMap
- (void)viewDidLoad {
    [super viewDidLoad];
    _googleMap.delegate = self;
    [self showMap];
    if ([_type isEqualToString:@"1"]) {
        [self getAllNearByBuzzardRun];
    }
    else if([_type isEqualToString:@"2"]){
        [self getAllNearByPromotions];
    }
    else{
        [self getNearByOffers];
    }
    
    [self designTheView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)designTheView
{
    [_headerView setHeader:NSLocalizedString(VIEW_NEAR_BY, nil)];
    [_headerView.logo setHidden:YES];
    nearByList=[[NSMutableArray alloc]init];
    page=1;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)showMap
{
    [[LocationManager sharedManager] startUpdateLocation];
    
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    // IF ch or zh is an CHINA
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
        
        [_baiduMap setHidden:NO];
        [_googleMap setHidden:YES];
        [self showBaiduMap];
    }
    else{
        [_baiduMap setHidden:YES];
        [_googleMap setHidden:NO];
    }
}

-(void)showBaiduMap
{
    // CUSTOM MAPVIEW
    baiduMap = [[BaiduMap alloc] initWithFrame:CGRectMake(2, 2, _baiduMap.bounds.size.width - 4, _baiduMap.bounds.size.height - 4)];
    baiduMap.delegate = self;
    baiduMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_baiduMap addSubview:baiduMap];
    
}


-(void) getAllNearByBuzzardRun{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].latitude] forKey:@"latitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].longitude] forKey:@"longitude"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_BUZZARD_RUN_SHOP_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            [self convertBuzzardRunToLocations:[[response objectForKey:@"near_by_buzzard_run_shops"] mutableCopy]];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}


//Convert the offers
- (void)convertBuzzardRunToLocations:(NSMutableArray *)offers{
    [nearByList removeAllObjects];
    for (int i=0; i < [offers count]; i++) {
        NSMutableDictionary *offer = [[offers objectAtIndex:i] mutableCopy];
        [offer setValue:[offer valueForKey:@"shop_name"] forKey:@"name"];
        [offer setValue:[offer valueForKey:@"shop_address"] forKey:@"subTitle"];
        [offer setValue:[NSNumber numberWithInteger:0]  forKey:@"show_custom_view"];
        [nearByList addObject:offer];
    }
    if ([nearByList count] == 0) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_BUZZARD_RUN_AVAILABLE, nil)];
    }
    else{
        NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
        
        // IF ch or zh is an CHINA
        if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
            [baiduMap addAnnotations:nearByList shouldAnimate:YES];
        }
        else{
            [_googleMap addMarkers:nearByList isVisiblePin:NO];
        }
    }
}

//Get near by club promotion list
-(void) getAllNearByPromotions{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].latitude] forKey:@"latitude"];
    [inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].longitude] forKey:@"longitude"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_CLUB_PROMOTION_SHOPS withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            [self convertPromotionsToLocations:[[response objectForKey:@"near_by_club_promotion"] mutableCopy]];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}


//Convert the club promotions
- (void)convertPromotionsToLocations:(NSMutableArray *)offers{
    [nearByList removeAllObjects];
    for (int i=0; i < [offers count]; i++) {
        NSMutableDictionary *buzzardRun = [[offers objectAtIndex:i] mutableCopy];
        [buzzardRun setValue:[buzzardRun valueForKey:@"shop_name"] forKey:@"name"];
        [buzzardRun setValue:[buzzardRun valueForKey:@"club_promotion_address"] forKey:@"subTitle"];
        [buzzardRun setValue:[NSNumber numberWithInteger:0]  forKey:@"show_custom_view"];
        [nearByList addObject:buzzardRun];
    }
    if ([nearByList count] == 0) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_NEAR_BY_PROMOTIONS, nil)];
    }
    else{
        NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
        // IF ch or zh is an CHINA
        // IF ch or zh is an CHINA
        if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
            [baiduMap addAnnotations:nearByList shouldAnimate:YES];
        }
        else{
            [_googleMap addMarkers:nearByList isVisiblePin:NO];
        }
    }
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
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_SHOP_LIST withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            [self convertOffersToLocations:[[response objectForKey:@"shops_list"] mutableCopy]];
        }
        else{
            
        }
        
    } isShowLoader:NO];
}

//Convert the offers
- (void)convertOffersToLocations:(NSMutableArray *)offers{
    [nearByList removeAllObjects];
    for (int i=0; i < [offers count]; i++) {
        NSMutableDictionary *offer = [[offers objectAtIndex:i] mutableCopy];
        [offer setValue:[offer valueForKey:@"shop_name"] forKey:@"name"];
        [offer setValue:[offer valueForKey:@"shop_address"] forKey:@"subTitle"];
        [offer setValue:[NSNumber numberWithInteger:0]  forKey:@"show_custom_view"];
        [nearByList addObject:offer];
    }
    if ([nearByList count] == 0) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_NEAR_BY_OFFERS, nil)];
    }
    else{
        NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
        
        // IF ch or zh is an CHINA
        if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
            [baiduMap addAnnotations:nearByList shouldAnimate:YES];
        }
        else{
            [_googleMap addMarkers:nearByList isVisiblePin:NO];
        }
    }
}

//Navigate to shop details page
- (void)moveToBuzzardRunList:(NSMutableDictionary *)shop{
    BuzzardRunFromShop *buzzardRunFromShop = [self.storyboard instantiateViewControllerWithIdentifier:@"BuzzardRunFromShop"];
    buzzardRunFromShop.shopId = [shop valueForKey:@"shop_id"];
    buzzardRunFromShop.shopName = [shop valueForKey:@"shop_name"];
    [self.navigationController pushViewController:buzzardRunFromShop animated:YES];
}

//Navigate to buzzard run details page
- (void)moveToNearByClubPromotions:(NSMutableDictionary *)shop{
    
    NearClubPromotions *nearClubPromotions = [self.storyboard instantiateViewControllerWithIdentifier:@"NearClubPromotions"];
    nearClubPromotions.shopId = [shop valueForKey:@"shop_id"];
    nearClubPromotions.shopName = [shop valueForKey:@"shop_name"];
    [self.navigationController pushViewController:nearClubPromotions animated:YES];
}

//Navigate to shop details page
- (void)moveToShopOffersList:(NSMutableDictionary *)shop{
    OffersList *offersList = [self.storyboard instantiateViewControllerWithIdentifier:@"OffersList"];
    offersList.shopId = [shop valueForKey:@"shop_id"];
    offersList.shopName = [shop valueForKey:@"shop_name"];
    [self.navigationController pushViewController:offersList animated:YES];
}

#pragma  args Google Map delegates
//Marker tapped click
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    if ([_type isEqualToString:@"1"]) {
        NSMutableDictionary *markerInfo = (NSMutableDictionary *) marker.userData;
        [self moveToBuzzardRunList:markerInfo];
    }
    else if([_type isEqualToString:@"2"]){
        NSMutableDictionary *markerInfo = (NSMutableDictionary *) marker.userData;
        [self moveToNearByClubPromotions:markerInfo];
    }
    else{
        NSMutableDictionary *markerInfo = (NSMutableDictionary *) marker.userData;
        [self moveToShopOffersList:markerInfo];
    }
}

#pragma  args Baidu Map delegates
- (void)didSelectAnnotaion:(BMKMapView *)mapView annotation:(BMKAnnotationView *)pinAnnotation{
    if ([_type isEqualToString:@"1"]) {
        MyAnnotation *pinView = (MyAnnotation *)pinAnnotation.annotation;
        NSLog(@"Data :%@",pinView.userInfo);
    }
    else if ([_type isEqualToString:@"2"]){
        MyAnnotation *pinView = (MyAnnotation *)pinAnnotation.annotation;
        NSLog(@"Data :%@",pinView.userInfo);
    }
    else{
        MyAnnotation *pinView = (MyAnnotation *)pinAnnotation.annotation;
        NSLog(@"Data :%@",pinView.userInfo);
    }
}

- (void)didSelectAnnotaionViewBubble:(BMKAnnotationView *)mapViewbubble{
    if ([_type isEqualToString:@"1"]) {
        MyAnnotation *pinView = (MyAnnotation *)mapViewbubble.annotation;
        NSLog(@"Data :%@",pinView.userInfo);
        NSMutableDictionary *markerInfo = pinView.userInfo;
        [self moveToBuzzardRunList:markerInfo];
    }
    else if ([_type isEqualToString:@"2"]){
        MyAnnotation *pinView = (MyAnnotation *)mapViewbubble.annotation;
        NSLog(@"Data :%@",pinView.userInfo);
        NSMutableDictionary *markerInfo = pinView.userInfo;
        [self moveToNearByClubPromotions:markerInfo];
    }
    else{
        MyAnnotation *pinView = (MyAnnotation *)mapViewbubble.annotation;
        NSLog(@"Data :%@",pinView.userInfo);
        NSMutableDictionary *markerInfo = pinView.userInfo;
        [self moveToShopOffersList:markerInfo];
    }
}
@end
