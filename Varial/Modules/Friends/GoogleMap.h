//
//  GoogleMap.h
//  Varial
//
//  Created by jagan on 13/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "GMUMarkerClustering.h"
#import "Config.h"
#import "LocationManager.h"
#import "MBProgressHUD.h"
#import "Util.h"

@import GooglePlaces;

@interface GoogleMap : GMSMapView<GMSMapViewDelegate, GMUClusterRendererDelegate>{
    
    GMSPlacesClient *placesClient;
    
    //use corelocation lib to access users location
    CLLocationCoordinate2D currentLocation;
    
}
@property(nonatomic) BOOL isNearByCheckIn;

//for autocomplete search field
typedef void (^autoCompleteCallback)(NSMutableArray *);
- (void) autoCompleteSearch:(NSString *)searchText withCallBack:(autoCompleteCallback) callback;

//get the nearby places
typedef void (^nearByPlaceCallback)(NSMutableArray *);
- (void) getMyNearestPlaces :(nearByPlaceCallback) callback;

//to get the place detail for the received place id
typedef void (^placeDetailCallback)(GMSPlace *);
- (void) getPlaceDetailByID:(NSString *)placeID withCallBack:(placeDetailCallback) callback;
- (void) animateToBounds:(GMSCoordinateBounds *)bounds;
- (void) moveToLocation :(CLLocationCoordinate2D) receivedLocation;
- (void) enableMyLocation:(BOOL) status;
- (void) focusCurrentLocation;
- (void) removeMarkersFromTheMap;
- (void) addMarker :(CLLocationCoordinate2D) position withTitle:(GMSPlace *) placeInfo withIcon:(UIImage *) icon;
- (void) addMarkerWithTitle :(CLLocationCoordinate2D) position withTitle:(NSString *) placeInfo withIcon:(UIImage *) icon;
- (void) getDirections:(NSMutableDictionary *) locationInfo forModule:(NSString *)module;
- (void) addMarkers :(NSMutableArray *) markerInfoArray isVisiblePin:(BOOL)visiblePin;
//- (void) addClusteredMarkers:(NSMutableArray *) markerInfoArray;

@end
