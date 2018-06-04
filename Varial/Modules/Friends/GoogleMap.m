//
//  GoogleMap.m
//  Varial
//
//  Created by jagan on 13/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMap.h"
#import "CheckinMarker.h"

@implementation GoogleMap


- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        
        self.settings.rotateGestures = NO;
        self.settings.tiltGestures = NO;
        
        LocationManager *location = [LocationManager sharedManager];
        placesClient = [[GMSPlacesClient alloc] init];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                                longitude:location.longitude
                                                                     zoom:0];
        // default zoom level 5
        [self setCamera:camera];
        self.settings.rotateGestures = NO;
        self.settings.tiltGestures = NO;
        [self setMinZoom:3 maxZoom:kGMSMaxZoomLevel];
    }
    return self;
}


//Add marker in current location
- (void)focusCurrentLocation {
    CLLocationCoordinate2D location = [[LocationManager sharedManager] locationCoordinate];
    [self moveToLocation:location];
    
}

//Enable my location
-(void) enableMyLocation:(BOOL) status {
    self.myLocationEnabled = status;
}

- (void)animateToBounds:(GMSCoordinateBounds *)bounds {
//    GMSCameraPosition *cameraPosition = [self cameraForBounds:bounds insets:UIEdgeInsetsMake(20, 20, 20, 20)];
//    [self animateToCameraPosition:cameraPosition];
//    [CATransaction begin];
//    [CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
//    [CATransaction commit];
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
    [self animateWithCameraUpdate:update];
}

//Move mapview to the received location
- (void) moveToLocation :(CLLocationCoordinate2D) receivedLocation
{
//    NSLog(@"moveToLocation");
    // change the camera, set the zoom, whatever.  Just make sure to call the animate* method.
    GMSCameraPosition *cameraPosistion = [GMSCameraPosition cameraWithTarget:receivedLocation zoom:5];
    [self animateToCameraPosition:cameraPosistion];
    
    //move to the specific location
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat: 3.0f] forKey:kCATransactionAnimationDuration];
    
    // change the camera, set the zoom, whatever.  Just make sure to call the animate* method.
    [self animateToZoom:10];
    [CATransaction commit];
    
}


//Adding marker to specified location
- (void) addMarker :(CLLocationCoordinate2D) position withTitle:(GMSPlace *) placeInfo withIcon:(UIImage *) icon
{
    if(!_isNearByCheckIn){
        //clear all previous markers
        [self clear];
    }
    
    //Create new marker
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    
    marker.title = placeInfo.name;
    marker.snippet = placeInfo.formattedAddress;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    
    marker.icon = icon;
    
    //alter the image size for marker
    marker.icon  = [self image:marker.icon scaledToSize:CGSizeMake(MARKER_WIDTH, MARKER_HEIGHT)];
    
    marker.map = self;
}

//Adding marker to specified location
- (void) addMarkerWithTitle :(CLLocationCoordinate2D) position withTitle:(NSString *) placeInfo withIcon:(UIImage *) icon
{
    
    if(!_isNearByCheckIn){
        //clear all previous markers
        [self clear];
    }
    
    //Create new marker
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    
    marker.title = placeInfo;
    marker.snippet = @"";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    
    marker.icon = icon;
    
    //alter the image size for marker
    marker.icon  = [self image:marker.icon scaledToSize:CGSizeMake(MARKER_WIDTH, MARKER_HEIGHT)];
    
    marker.map = self;
    
}

//Remove markers from the map
- (void) removeMarkersFromTheMap {
    [self clear];
}


//alter the image size for the marker in map view
- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    @autoreleasepool {
        //avoid redundant drawing
        if (CGSizeEqualToSize(originalImage.size, size))
        {
            return originalImage;
        }
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        
        //draw
        [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        
        //capture resultant image
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return image
        return image;
    }
}


//**Place API Section**//
//get nearby places for current location
- (void) getMyNearestPlaces:(nearByPlaceCallback)callback
{
    
    NSLog(@"Getting nearby placess...!");
    
    MBProgressHUD *loader = [Util showLoading];
    NSMutableArray *placesList = [[NSMutableArray alloc] init];
    [placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        
        [Util hideLoading:loader];
        
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            
            GMSPlace* place = likelihood.place;
            NSMutableDictionary *placeItem = [[NSMutableDictionary alloc] init];
            [placeItem setValue:place.placeID forKey:@"id"];
            [placeItem setValue:place.name forKey:@"place"];
            [placesList addObject:placeItem];
            
        }
        NSLog(@"Call back with placesList,,,!");
        //callback with the near by places list
        callback(placesList);
    }];
    
}




//search and return the matched places list
- (void) autoCompleteSearch :(NSString *) searchText withCallBack:(autoCompleteCallback)callback
{
    
    NSMutableArray *placesList = [[NSMutableArray alloc] init];
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterCity;
    
    //search for the received input text
    [placesClient autocompleteQuery:searchText
                             bounds:nil
                             filter:nil
                           callback:^(NSArray *results, NSError *error) {
                               if (error != nil) {
                                   NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                   return;
                               }
                               
                               for (GMSAutocompletePrediction* result in results) {
                                   NSMutableDictionary *placeItem = [[NSMutableDictionary alloc] init];
                                   [placeItem setValue:result.placeID forKey:@"id"];
                                   [placeItem setValue:result.attributedFullText.string forKey:@"place"];
                                   [placesList addObject:placeItem];
                                   
                               }
                               callback(placesList);
                           }];
}


//get place detail by place id
- (void) getPlaceDetailByID:(NSString *)placeID  withCallBack:(placeDetailCallback) callback
{
    
    NSLog(@"RECEIVED PLACE ID : %@",placeID);
    [placesClient lookUpPlaceID:placeID callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"PLACE DATA : %@",place);
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place placeID %@", place.placeID);
            NSLog(@"Place attributions %@", place.attributions);
            callback(place);
        } else {
            NSLog(@"No place details for %@", placeID);
        }
    }];
}


//Get path for the specified directions
- (void) getDirections:(NSMutableDictionary *) locationInfo forModule:(NSString *)module
{
    //Directions API URL
    NSString *directionURL = [NSString stringWithFormat:@"%@?origin=%f,%f&destination=%@,%@&mode=driving",
                              DIRECTIONS_API,
                              [LocationManager sharedManager].latitude,
                              [LocationManager sharedManager].longitude,
                              [locationInfo valueForKey:@"latitude"],
                              [locationInfo valueForKey:@"longitude"]];
    NSLog(@"URL : %@",directionURL);
    
    [self clear];
    
    [[Util sharedInstance]  sendHTTPGetRequest:directionURL withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] isEqualToString:@"OK"]){
            
            //getting the points
            GMSPath *path =[GMSPath pathFromEncodedPath:response[@"routes"][0][@"overview_polyline"][@"points"]];
            GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
            singleLine.strokeWidth = 7;
            singleLine.strokeColor = [UIColor redColor];
            //add it to the map view in ios
            singleLine.map = self;
            
            //set the current location item
            GMSMarker *currentLocationMarker = [GMSMarker markerWithPosition:currentLocation];
            currentLocationMarker.title = NSLocalizedString(CURRENT_LOCATION, nil) ;
            currentLocationMarker.map = self;
            
            CLLocationCoordinate2D destination;
            destination.latitude = [[locationInfo valueForKey:@"latitude"] doubleValue];
            destination.longitude = [[locationInfo valueForKey:@"longitude"] doubleValue];
            
            //Destination
            GMSMarker *marker = [GMSMarker markerWithPosition:destination];
            marker.title = [locationInfo valueForKey:@"name"];
            marker.snippet = [locationInfo valueForKey:@"subTitle"];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.icon = [UIImage imageNamed:@"pinIconMapActive"];
            
            //alter the image size for marker
            marker.icon  = [self image:marker.icon scaledToSize:CGSizeMake(MARKER_WIDTH, MARKER_HEIGHT)];
            marker.map = self;
            
            //Source Marker
            GMSMarker *sourceMarker = [GMSMarker markerWithPosition:[[LocationManager sharedManager] locationCoordinate]];
            sourceMarker.title = NSLocalizedString(YOU, nil);
            sourceMarker.appearAnimation = kGMSMarkerAnimationPop;
            sourceMarker.icon = [UIImage imageNamed:@"pinIcon"];
            
            //alter the image size for marker
            sourceMarker.icon  = [self image:sourceMarker.icon scaledToSize:CGSizeMake(MARKER_WIDTH, MARKER_HEIGHT)];
            sourceMarker.map = self;
            
            //move to specified location
            [self moveToLocation:destination];
            
        }
        else{
            
            //Source Marker
            GMSMarker *sourceMarker = [GMSMarker markerWithPosition:[[LocationManager sharedManager] locationCoordinate]];
            sourceMarker.title = NSLocalizedString(YOU, nil);
            sourceMarker.appearAnimation = kGMSMarkerAnimationPop;
            sourceMarker.icon = [UIImage imageNamed:@"mapPointer.png"];
            
            //alter the image size for marker
            sourceMarker.icon  = [self image:sourceMarker.icon scaledToSize:CGSizeMake(MARKER_WIDTH, MARKER_HEIGHT)];
            sourceMarker.map = self;
            
            //move to specified location
            [self moveToLocation:[[LocationManager sharedManager] locationCoordinate]];
            
            if ([module isEqualToString:@"Shops"] || [module isEqualToString:@"BuzzardRun"]) {
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_ROUTESEARCH_FOR_SHOP, nil)];
            }
            else if([module isEqualToString:@"ClubPromotions"]){
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_ROUTESEARCH_FOR_CLUB, nil)];
            }
            
        }
        
        
    } isShowLoader:YES];
}


//Add Bunch of markers in map
- (void) addMarkers :(NSMutableArray *) markerInfoArray isVisiblePin:(BOOL)visiblePin
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    //clear all previous markers
    
    GMSMarker *markerArray[[markerInfoArray count]];
    CLLocationCoordinate2D markerLocation;
    
    for(int loop = 0;loop < [markerInfoArray count]; loop++){
        NSMutableDictionary *markerInfo = [[NSMutableDictionary alloc] initWithDictionary:[markerInfoArray objectAtIndex:loop]];
        //        markerLocation.latitude = 39.913818;
        //        markerLocation.longitude = 116.363625;
        markerLocation.latitude = [[markerInfo objectForKey:@"latitude"] doubleValue];
        markerLocation.longitude = [[markerInfo objectForKey:@"longitude"] doubleValue];
        markerArray[loop] = [GMSMarker markerWithPosition:markerLocation];
        markerArray[loop].title = [markerInfo objectForKey:@"name"];
        markerArray[loop].snippet = [markerInfo objectForKey:@"subTitle"];
        markerArray[loop].appearAnimation = kGMSMarkerAnimationPop;
        
        //SET THE MAP INFO FOR EACH MARKER
        markerArray[loop].userData = markerInfo;
        
        bounds = [bounds includingCoordinate:markerArray[loop].position];
        markerArray[loop].icon = [UIImage imageNamed:@"pinIconMapActive"];
        
        //alter the image size for marker
        markerArray[loop].icon  = [self image:markerArray[loop].icon scaledToSize:CGSizeMake(MARKER_WIDTH, MARKER_HEIGHT)];
        markerArray[loop].map = self;
    }
    if(!visiblePin){
        //show all pins in map
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat: 2.0f] forKey:kCATransactionAnimationDuration];
        [self animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
        [CATransaction commit];
    }
}

#pragma mark GMUClusterRendererDelegate 

- (void)renderer:(id<GMUClusterRenderer>)renderer willRenderMarker:(GMSMarker *)marker {
    if ([marker.userData isKindOfClass:[CheckinMarker class]]) {
        CheckinMarker *item = marker.userData;
        marker.title = item.title;
        marker.snippet = item.snippet;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        
        marker.userData = item.userData;
        
//        marker.icon = [UIImage imageNamed:@"pinIconMapActive"];
//        marker.icon = [self image:marker.icon scaledToSize:CGSizeMake(MARKER_WIDTH, MARKER_HEIGHT)];
    }
}

@end
