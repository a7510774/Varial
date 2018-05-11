//
//  BaiduMap.h
//  Varial
//
//  Created by vis-1674 on 2016-02-09.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "MyAnnotation.h"
#import "LocationManager.h"

#import "BMClusterManager.h"
#import "BMDefaultClusterRenderer.h"
#import "BaiduCheckinItem.h"

@class BaiduMap;

@protocol BaiduDelegate

- (void)didSelectAnnotaion:(BMKMapView *)mapView annotation:(BMKAnnotationView *)annotation;// Select annotation pin
- (void)didSelectAnnotaionViewBubble:(BMKAnnotationView *)mapViewbubble; // Select annotation pin popup
//- (void)SearchResults: (NSMutableArray *)name :(NSMutableArray *)ann; // delegate for POI search Results
- (void)SearchResults: (NSMutableArray *)searchResults; // delegate for POI search Results
- (void)RouteSearchResults : (NSArray *)searchResults;

@end

@interface BaiduMap : UIView<BMKMapViewDelegate,BMKPoiSearchDelegate,BMKRouteSearchDelegate,BMClusterRendererDelegate>
{
//    BMKMapView* _mapView;
    MyAnnotation *pointAnnotation;
    BMKPoiSearch* _poisearch;
    BMKRouteSearch* _routesearch;
    UIImage *annotationImage;
    NSMutableArray *arraySearchName, *arrayAnnotations;
    int planPointCounts;
    float lattitude, longitude;
    NSString *destinationTitle, *destinationSubtitle;
    BOOL annotationSelected;
}
@property (nonatomic)BMKMapView* mapView;
@property (nonatomic)BOOL isHomePage;
@property (assign) id<BaiduDelegate> delegate;
@property (nonatomic)BOOL nearByPinAdded;
@property (nonatomic)CLLocationCoordinate2D activePin;


- (void)addAnnotation: (CLLocationCoordinate2D)coor Title:(NSString *)title Subtitle:(NSString *)subtitle Image:(NSData *)img;

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view;

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;

-(BOOL)POISearch :(UITextField *)city categories:(UITextField *)keywords;

-(void)SelectSearch: (id)annotaion;

-(void)RemoveAllAnnotations;

-(void)RouteSearchFromCurrentLocaton :(CLLocationCoordinate2D)CurrentLocation destination:(CLLocationCoordinate2D)EndLocation withName:(NSString *)name withCityName:(NSString *)cityName isFrom:(NSString *)IsFrom;

- (void)addAnnotations:(NSMutableArray *)locationInfo shouldAnimate:(BOOL)animate;

@property (nonatomic)NSString *mediaBase;
-(void)getcornerCoordinates;
@end
