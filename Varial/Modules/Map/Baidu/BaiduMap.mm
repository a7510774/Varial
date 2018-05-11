//
//  BaiduMap.m
//  Varial
//
//  Created by vis-1674 on 2016-02-09.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BaiduMap.h"
#import "UserMessages.h"
#import "MyPaopaoView.h"
#import "BaiduPopularCheckin.h"
#import "MyTapRecogniser.h"
#import "UIImageView+AFNetworking.h"

@implementation BaiduMap
@synthesize delegate = _delegate;
NSMutableDictionary *userInfo;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _delegate = nil;
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0,0, self.bounds.size.width, self.bounds.size.height)];
        _mapView.delegate = self;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_mapView];
        _mapView.rotateEnabled = FALSE;
        _mapView.scrollEnabled = TRUE;
        [_mapView setMinZoomLevel:5];
    }
    return self;
}

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    NSLog(@"DID FINISH LOADIBG");
    // Show loader for this
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAllPopularCheckin" object:nil];
}

- (void)addAnnotation: (CLLocationCoordinate2D)coor Title:(NSString *)title Subtitle:(NSString *)subtitle Image:(NSData *)img
{
    if (pointAnnotation == nil) {
        pointAnnotation = [[MyAnnotation alloc]init];
        pointAnnotation.coordinate = coor;
        pointAnnotation.title = title;
        pointAnnotation.subtitle = subtitle;
        pointAnnotation.imageName = @"pinIconActive";
        pointAnnotation.canShowPopUp = TRUE;
        pointAnnotation.draggable = NO;
        pointAnnotation.animatesDrop = YES;
        annotationImage = [UIImage imageWithData:img];
        if (annotationImage != nil) {
            pointAnnotation.imageName = @"pinIcon";
        }
    }
    
    // Show location Pin
    NSMutableArray *showannotation = [[NSMutableArray alloc] init];
    [showannotation addObject:pointAnnotation];
    [_mapView addAnnotations:showannotation];
    [_mapView showAnnotations:showannotation animated:YES];
}

- (void)addAnnotations:(NSMutableArray *)locationInfo shouldAnimate:(BOOL)animate
{
    
    // Show location Pin
    NSMutableArray *showannotation = [[NSMutableArray alloc] init];
    for(int i=0; i < [locationInfo count]; i++){
        
        MyAnnotation *annotation = [[MyAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = [[[locationInfo objectAtIndex:i] valueForKey:@"latitude"] doubleValue];
        coor.longitude = [[[locationInfo objectAtIndex:i] valueForKey:@"longitude"] doubleValue];
        //        coor.longitude = 116.363625;
        //        coor.latitude = 39.913818;
        annotation.coordinate = coor;
        annotation.title = [[locationInfo objectAtIndex:i] valueForKey:@"name"];
        annotation.subtitle = [[locationInfo objectAtIndex:i] valueForKey:@"subTitle"];
        annotation.userInfo = [locationInfo objectAtIndex:i];
        annotation.canShowPopUp = YES;
        annotation.draggable = NO;
        annotation.animatesDrop = YES;
        annotation.imageName = @"pinIconActive";
        [showannotation addObject:annotation];
        [_mapView addAnnotation:annotation];
    }
    
    if(animate){
        //Fit to bounds of the all annotations in the map
        [_mapView showAnnotations:showannotation animated:YES];
    }
    
}

-(void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
//    mapView.region
//    NSLog(@"region: %@", NSString mapView.region);
    
    if(annotationSelected){
        CGPoint point = [_mapView convertCoordinate:_activePin toPointToView:_mapView];
        if(point.x < 0 || point.x > _mapView.frame.size.width || point.y < 0 || point.y > _mapView.frame.size.height)
            annotationSelected = NO;
    }
    if(!annotationSelected && !_nearByPinAdded){
        [self getcornerCoordinates];
    }
    if(_nearByPinAdded)
        _nearByPinAdded = !_nearByPinAdded;
}


-(void)getcornerCoordinates{
//    CLLocationCoordinate2D topleft = [_mapView convertPoint:CGPointMake(_mapView.frame.size.width, 0) toCoordinateFromView:_mapView];
//    CLLocationCoordinate2D bottomRight = [_mapView convertPoint:CGPointMake(0, _mapView.frame.size.height) toCoordinateFromView:_mapView];
//    
//    CGPoint point = [_mapView convertCoordinate:topleft toPointToView:_mapView];
//    CGPoint point1 = [_mapView convertCoordinate:bottomRight toPointToView:_mapView];
//    
//    int height = _isHomePage ? int(_mapView.frame.size.height) : (int(_mapView.frame.size.height)-1);
//    int width = _isHomePage ? int(_mapView.frame.size.width) : (int(_mapView.frame.size.width)-1);

//    if(int(point1.x) == 0 && int(point.y) == 0 && int(point.x) == width && int(point1.y) == height){
//        NSLog(@"Gray layer not shown");
//        
//        NSMutableDictionary *cornerCoordinates = [[NSMutableDictionary alloc] init];
//        [cornerCoordinates setValue:[NSString stringWithFormat:@"%f",bottomRight.latitude] forKey:@"southwest_lat"];
//        [cornerCoordinates setValue:[NSString stringWithFormat:@"%f",bottomRight.longitude] forKey:@"southwest_long"];
//        [cornerCoordinates setValue:[NSString stringWithFormat:@"%f",topleft.latitude] forKey:@"northeast_lat"];
//        [cornerCoordinates setValue:[NSString stringWithFormat:@"%f",topleft.longitude] forKey:@"northeast_long"];
//        
//        NSDictionary *dict = [NSDictionary dictionaryWithObject:cornerCoordinates forKey:@"cornerCoordinates"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetVisiblePopularCheckin" object:nil userInfo:dict];
//    }
//    else{
//        NSLog(@"Gray layer shown");
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAllPopularCheckin" object:nil];
//    }
}

# pragma mark Baidu Cluster Renderer delegates

- (BMClusterAnnotation *)renderer:(id<BMClusterRenderer>)renderer annotationForObject:(id)object {
    
    BMClusterAnnotation *annotation = [[BMClusterAnnotation alloc] init];
    if ([object isKindOfClass:[BaiduCheckinItem class]]) {
        BaiduCheckinItem *item = object;
        
        // Set anything else necessary
        annotation.title = item.title;
    }
    
   return annotation;
}

- (void)renderer:(id<BMClusterRenderer>)renderer willRenderAnnotationView:(BMKAnnotationView *)view {
    
    view.image = [UIImage imageNamed:@"pinIconActive"];
    
    BaiduCheckinItem *clusterItem = ((BMClusterAnnotation *)view.annotation).userData;
    NSMutableDictionary *info = clusterItem.userData;
    
    //  1- Custom View  0 - Default view
    if ([[info objectForKey:@"show_custom_view"] intValue] == 1) {
        BMKActionPaopaoView *paopaoView = [self paopaoViewForInfo:info];
        view.paopaoView = paopaoView;
    } else {
        NSLog(@"no custom view for this %@", info);
    }
}

- (BMKActionPaopaoView *)paopaoViewForInfo:(NSMutableDictionary *)info {
    MyPaopaoView *paopaoView = [[MyPaopaoView alloc] initWithNibName:@"MyPaopaoView" bundle:nil];
    UILabel *label = (UILabel *)[paopaoView.view viewWithTag:100];
    paopaoView.name.text =[info valueForKey:@"name"];
    paopaoView.snippet.text = [info valueForKey:@"subTitle"];
    paopaoView.userInfo = info;
    NSString *strURL = [NSString stringWithFormat:@"%@%@", [info objectForKey:@"media_base"], [info valueForKey:@"media_url"]];
    [paopaoView.imageView setImageWithURL:[NSURL URLWithString:strURL]];
    if([[info objectForKey:@"media_type"] intValue] == 1 )
        paopaoView.playIcon.hidden = YES;
    else
        paopaoView.playIcon.hidden = NO;
    
    BMKActionPaopaoView *paopao = [[BMKActionPaopaoView alloc] initWithCustomView:paopaoView.view];
    MyTapRecogniser *singleFingerTap = [[MyTapRecogniser alloc] initWithTarget:self
                                                                        action:@selector(handleSingleTap:)];
    singleFingerTap.userInfo = info;
    singleFingerTap.numberOfTapsRequired = 1;
    singleFingerTap.numberOfTouchesRequired = 1;
    [paopao addGestureRecognizer:singleFingerTap];
    
    return paopao;
}

# pragma mark BMKMapViewDelegate Methods

// View for annotations -> Default delegate function for view annotation pin
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    
    NSString *AnnotationViewID = @"renameMark";
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        
        MyAnnotation *myAnnotation = (MyAnnotation *)annotation;
        annotationView.animatesDrop = myAnnotation.animatesDrop;
        annotationView.draggable = myAnnotation.draggable;
        annotationView.canShowCallout = myAnnotation.canShowPopUp;
        
        if (myAnnotation.imageName == nil) {
            annotationView.image = [UIImage imageNamed:@"pinIconMapActive"];
        }
        else{
            annotationView.image = [UIImage imageNamed:myAnnotation.imageName];
        }
        
        NSMutableDictionary *markerInfo = myAnnotation.userInfo;
        
        //  1- Custom View  0 - Default view
        if([[markerInfo objectForKey:@"show_custom_view"] intValue] == 1)
        {
            MyPaopaoView *paopaoView=[[MyPaopaoView alloc] initWithNibName:@"MyPaopaoView" bundle:nil];
            UILabel *label = (UILabel *)[paopaoView.view viewWithTag:100];
            paopaoView.name.text =[markerInfo valueForKey:@"name"];
            paopaoView.snippet.text = [markerInfo valueForKey:@"subTitle"];
            paopaoView.userInfo = myAnnotation.userInfo;
            NSString *strURL = [NSString stringWithFormat:@"%@%@",[markerInfo objectForKey:@"media_base"],[markerInfo valueForKey:@"media_url"]];
            [paopaoView.imageView setImageWithURL:[NSURL URLWithString:strURL]];
            if([[markerInfo objectForKey:@"media_type"] intValue] == 1 )
                paopaoView.playIcon.hidden = YES;
            else
                paopaoView.playIcon.hidden = NO;
            BMKActionPaopaoView *paopao = [[BMKActionPaopaoView alloc] initWithCustomView:paopaoView.view];
            annotationView.paopaoView = paopao;
            
            MyTapRecogniser *singleFingerTap =
            [[MyTapRecogniser alloc] initWithTarget:self
                                             action:@selector(handleSingleTap:)];
            singleFingerTap.userInfo = markerInfo;
            singleFingerTap.numberOfTapsRequired = 1;
            singleFingerTap.numberOfTouchesRequired = 1;
            [annotationView.paopaoView addGestureRecognizer:singleFingerTap];
        }
        
    }
    MyAnnotation *myAnnotation = (MyAnnotation *)annotation;
    if (myAnnotation.imageName == nil) {
        annotationView.image = [UIImage imageNamed:@"pinIconActive"];
    }
    else{
        annotationView.image = [UIImage imageNamed:myAnnotation.imageName];
    }
    return annotationView;
}


//- (BMKAnnotationView)viewForAnnotation:(id <BMKAnnotation>)annotation {
//    
//}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    MyTapRecogniser *tap = (MyTapRecogniser *)recognizer;
    BaiduPopularCheckin *baidu=[[BaiduPopularCheckin alloc] initWithNibName:@"BaiduPopularCheckin" bundle:nil];
    [baidu navigateToDetailPage:tap.userInfo];
}



// delegate method for didSelectAnnotationView
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationView");
    annotationSelected = YES;
    if (self.delegate != nil) {
        [self.delegate didSelectAnnotaion:mapView annotation:view];
    }
    NSLog(@"Global Annotation Cliked");
}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view;
{
    annotationSelected = NO;
}

// delegate method for didselect annotation popup
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    if (self.delegate != nil) {
        [self.delegate didSelectAnnotaionViewBubble:view];
    }
    NSLog(@"Global Annotation popup click");
}


// POI SEARCH
-(BOOL)POISearch :(UITextField *)city categories:(UITextField *)keywords
{
    arrayAnnotations = [[NSMutableArray alloc] init];
    arraySearchName = [[NSMutableArray alloc] init];
    
    _poisearch = [[BMKPoiSearch alloc] init];
    _poisearch.delegate = self;
    
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc] init];
    citySearchOption.pageIndex = 0;
    citySearchOption.pageCapacity = 10;
    citySearchOption.city = city.text; // 成都
//    citySearchOption.city = @"成都";
    citySearchOption.keyword = keywords.text; // 餐厅
//    citySearchOption.keyword = @"餐厅";
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    if(flag)
    {
        NSLog(@"Success");
    }
    else
    {
        NSLog(@"Failed");
        // [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_RESULT_FOUND, nil)];
    }
    
    return flag;
}

// delegate method for POI Search
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotations = [NSMutableArray array];
        [arraySearchName removeAllObjects];
        [arrayAnnotations removeAllObjects];
        
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            MyAnnotation* item = [[MyAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [annotations addObject:item];
            //[arrayAnnotations addObject:item];
            // [arraySearchName addObject:poi.name];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:poi.name forKey:@"name"];
            [dict setValue:poi.address forKey:@"subTitle"];
            [dict setValue:[NSNumber numberWithDouble:poi.pt.latitude] forKey:@"latitude"];
            [dict setValue:[NSNumber numberWithDouble:poi.pt.longitude] forKey:@"longitude"];
            [arraySearchName addObject:dict];
            
        }
        // [self.delegate SearchResults: arraySearchName : arrayAnnotations];
        if (self.delegate != nil) {
            [self.delegate SearchResults: arraySearchName];
        }
        NSLog(@"Search Result %@", arraySearchName);
        
        // [_mapView addAnnotations:annotations];
        // [_mapView showAnnotations:annotations animated:YES];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"Search error");
        
    } else {
        NSLog(@"Search no results found");
        if (self.delegate != nil) {
            [self.delegate SearchResults: arraySearchName];
        }
    }
}

// After search select the location from the tableview
-(void)SelectSearch: (id)annotaion
{
    [_mapView addAnnotation:annotaion];
    [_mapView showAnnotations:arrayAnnotations animated:YES];
}
//Remove all annotaions function
-(void)RemoveAllAnnotations
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    pointAnnotation = nil;
}

///////////////////////////////////// Route Search ////////////////////////////////////////////

-(void)RouteSearchFromCurrentLocaton :(CLLocationCoordinate2D)CurrentLocation destination:(CLLocationCoordinate2D)EndLocation withName:(NSString *)name withCityName:(NSString *)cityName isFrom:(NSString *)IsFrom
{
    _routesearch = [[BMKRouteSearch alloc]init];
    _routesearch.delegate = self;
    
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.pt = CurrentLocation;
    
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.pt = EndLocation;
    
    //Set the popup information
    destinationTitle = name;
    destinationSubtitle = cityName;
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    //    drivingRouteSearchOption.wayPointsArray = array;
    BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];
    
    if(flag)
    {
        NSLog(@"search success.");
    }
    else
    {
        NSLog(@"search failed!");
        if ([IsFrom isEqualToString:@"Shops"] || [IsFrom isEqualToString:@"BuzzardRun"]) {
            // [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_ROUTESEARCH_FOR_SHOP, nil)];
        }
        else if([IsFrom isEqualToString:@"ClubPromotions"])
        {
            //   [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_ROUTESEARCH_FOR_CLUB, nil)];
        }
    }
    
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 6.0;
        return polylineView;
    }
    return nil;
}

- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            
            if(i==0)  // Source point
            {
                MyAnnotation *item = [[MyAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = NSLocalizedString(YOU, nil);
                item.imageName = @"pinIcon";
                item.canShowPopUp = TRUE;
                item.draggable = NO;
                item.animatesDrop = YES;
                [_mapView addAnnotation:item];
            }
            else if(i==size-1)  // Destination point
            {
                MyAnnotation *item = [[MyAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = destinationTitle;
                item.subtitle = destinationSubtitle;
                item.imageName = @"pinIconActive";
                item.canShowPopUp = TRUE;
                item.draggable = NO;
                item.animatesDrop = YES;
                [_mapView addAnnotation:item];
            }
            
            planPointCounts += transitStep.pointsCount;
        }
        
        
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine];
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
    else
    {
        CLLocationCoordinate2D source = [[LocationManager sharedManager] locationCoordinate];
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"pinIcon"]);
        [self addAnnotation:source Title:NSLocalizedString(YOU, nil) Subtitle:@"" Image:imageData];
        //annotationImage = [UIImage imageNamed:@"pinIcon"];
        if (self.delegate != nil) {
            [self.delegate RouteSearchResults:array];
        }
    }
}

- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}

@end
