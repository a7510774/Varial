//
//  ShowCheckinInMap.m
//  Varial
//
//  Created by jagan on 25/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ShowCheckinInMap.h"

@interface ShowCheckinInMap ()

@end

@implementation ShowCheckinInMap
CLLocationCoordinate2D location;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self designTheView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)designTheView{
    
    location.latitude = [_latitude doubleValue];
    location.longitude = [_longitude doubleValue];
    [_headerView setHeader: NSLocalizedString(CHECK_IN, nil)];
    
    
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    
    // IF ch or zh is an CHINA
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
        // CUSTOM MAPVIEW
        baiduMap = [[BaiduMap alloc] initWithFrame:CGRectMake(2, 2, _baiduMapView.bounds.size.width - 4, _baiduMapView.bounds.size.height - 4)];
        baiduMap.delegate = self;
        baiduMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_baiduMapView addSubview:baiduMap];        
        [_googleMapView setHidden:YES];
        [self addMarkerInBaiduMap];
    }else{
        [_baiduMapView setHidden:YES];
        [self addMarkerInGoogleMap];
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addMarkerInGoogleMap{
    //Move camera to clicked to location and add marker
    [_googleMapView moveToLocation:location];
    [_googleMapView addMarkerWithTitle:location withTitle:_checkinName withIcon:[UIImage imageNamed:@"pinIconActive"]];
}

- (void)addMarkerInBaiduMap{
    
    //Move camera to clicked to location and add marker
    [baiduMap addAnnotation:location Title:_checkinName Subtitle:nil Image:nil];
}

#pragma  args Baidu Map delegates
- (void)didSelectAnnotaion:(BMKMapView *)mapView annotation:(BMKAnnotationView *)pinAnnotation{
}

- (void)didSelectAnnotaionViewBubble:(BMKAnnotationView *)mapViewbubble{
}


@end
