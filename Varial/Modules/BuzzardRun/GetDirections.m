//
//  GetDirections.m
//  Varial
//
//  Created by jagan on 23/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "GetDirections.h"

@interface GetDirections ()

@end

@implementation GetDirections

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showMap];
    [self designTheView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView{
    [_headerView setHeader:NSLocalizedString(DIRECTION, nil)];

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
    [self getDirections];
}

// Show Map based the Location
-(void)showMap
{
    
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    // IF ch or zh is an CHINA
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
        
        [_baiduMap setHidden:NO];
        [_googleMap setHidden:YES];
        
        // Start Update location Service
        // Show Alert if location service is disabled
        [[LocationManager sharedManager] startUpdateLocation];        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:@"LocationUpdated" object:nil];
        if( ![Util checkLocationIsEnabled] )
        {
            [[Util sharedInstance] showLocationAlert];
        }
        
        [self showBaiduMap];
    }
    else{
        [_baiduMap setHidden:YES];
        [_googleMap setHidden:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:@"LocationUpdated" object:nil];
        [[LocationManager sharedManager] startUpdateLocation];
        if( ![Util checkLocationIsEnabled] )
        {
            [[Util sharedInstance] showLocationAlert];
        }
    }
}

// If Current user is China show the Baidu Map
-(void)showBaiduMap
{
    // CUSTOM MAPVIEW
    baiduMap = [[BaiduMap alloc] initWithFrame:CGRectMake(2, 2, _baiduMap.bounds.size.width - 4, _baiduMap.bounds.size.height - 4)];
    baiduMap.delegate = self;
    baiduMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_baiduMap addSubview:baiduMap];
}




- (void)getDirections{
    
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    // IF ch or zh is an CHINA
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
        CLLocationCoordinate2D source,destination;
        source = [[LocationManager sharedManager] locationCoordinate];
        destination.latitude = [[_destination valueForKey:@"latitude"] doubleValue];
        destination.longitude = [[_destination valueForKey:@"longitude"] doubleValue];
        //destination.latitude = 39.9042;
        //destination.longitude = 116.4074;
        //source.latitude = 36.6685;
        //source.longitude = 117.0204;
        
        [baiduMap RouteSearchFromCurrentLocaton:source destination:destination withName:[_destination valueForKey:@"name"] withCityName:[_destination valueForKey:@"subTitle"] isFrom:_isFrom];
    }
    else{
        [_googleMap getDirections:_destination forModule:_isFrom];
    }
}



#pragma  args Google Map delegates
//Marker tapped click
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
}

#pragma  args Baidu Map delegates
- (void)didSelectAnnotaion:(BMKMapView *)mapView annotation:(BMKAnnotationView *)pinAnnotation{
}

- (void)didSelectAnnotaionViewBubble:(BMKAnnotationView *)mapViewbubble{   
}

// BaiduMap Delegate
-(void)RouteSearchResults : (NSArray *)searchResults
{
    if ([searchResults count] == 0) {
        if ([_isFrom isEqualToString:@"BuzzardRun"]) {
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_ROUTESEARCH_FOR_SHOP, nil)];
        }
        else if([_isFrom isEqualToString:@"ClubPromotions"])
        {
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_ROUTESEARCH_FOR_CLUB, nil)];
        }
    }
}


@end
