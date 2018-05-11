/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "BMDefaultClusterRenderer+Testing.h"

//#import <GoogleMaps/GoogleMaps.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>


#import "BMClusterIconGenerator.h"
#import "BMWrappingDictionaryKey.h"

// Clusters smaller than this threshold will be expanded.
static const NSUInteger kBMMinClusterSize = 4;

// At zooms above this level, clusters will be expanded.
// This is to prevent cases where items are so close to each other than they are always grouped.
//static const float kBMMaxClusterZoom = 20;
static const float kBMMaxClusterZoom = 13;

// Animation duration for marker splitting/merging effects.
static const double kBMAnimationDuration = 0.5;  // seconds.

@implementation BMDefaultClusterRenderer {
  // Map view to render clusters on.
  __weak BMKMapView *_mapView;

  // Collection of markers added to the map.
//  NSMutableArray<GMSMarker *> *_annotations;
  NSMutableArray<BMKPointAnnotation *> *_annotations;
  // Tracks annotations to add
  NSMutableArray<BMKPointAnnotation *> *_annotationsToAdd;
  // Tracks annotations to remove
  NSMutableArray<BMKPointAnnotation *> *_annotationsToRemove;

    
  // Icon generator used to create cluster icon.
  id<BMClusterIconGenerator> _clusterIconGenerator;

  // Current clusters being rendered.
  NSArray<id<BMCluster>> *_clusters;

  // Tracks clusters that have been rendered to the map.
  NSMutableSet *_renderedClusters;

  // Tracks cluster items that have been rendered to the map.
  NSMutableSet *_renderedClusterItems;

    
  // Stores previous zoom level to determine zooming direction (in/out).
  float _previousZoom;

  // Lookup map from cluster item to an old cluster.
  NSMutableDictionary<BMWrappingDictionaryKey *, id<BMCluster>> *_itemToOldClusterMap;

  // Lookup map from cluster item to a new cluster.
  NSMutableDictionary<BMWrappingDictionaryKey *, id<BMCluster>> *_itemToNewClusterMap;
}

- (instancetype)initWithMapView:(BMKMapView *)mapView
           clusterIconGenerator:(id<BMClusterIconGenerator>)iconGenerator {
  if ((self = [super init])) {
    _mapView = mapView;
    _annotations = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
    _annotationsToAdd = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
    _annotationsToRemove = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
    _clusterIconGenerator = iconGenerator;
    _renderedClusters = [[NSMutableSet alloc] init];
    _renderedClusterItems = [[NSMutableSet alloc] init];
    _animatesClusters = YES;
    _zIndex = 1;
  }
  return self;
}

- (void)dealloc {
  [self clear];
}

- (BOOL)shouldRenderAsCluster:(id<BMCluster>)cluster atZoom:(float)zoom {
  return cluster.count >= kBMMinClusterSize && zoom <= kBMMaxClusterZoom;
}

#pragma mark BMClusterRenderer

- (void)renderClusters:(NSArray<id<BMCluster>> *)clusters {
  [_renderedClusters removeAllObjects];
  [_renderedClusterItems removeAllObjects];

  if (_animatesClusters) {
    [self renderAnimatedClusters:clusters];
  } else {
    // No animation, just remove existing markers and add new ones.
    _clusters = [clusters copy];
    [self clearMarkers:_annotations];
    _annotations = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
    _annotationsToAdd = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
    _annotationsToRemove = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
    [self addOrUpdateClusters:clusters animated:NO];
  }
}

- (void)renderAnimatedClusters:(NSArray<id<BMCluster>> *)clusters {
  float zoom = _mapView.zoomLevel;
  BOOL isZoomingIn = zoom > _previousZoom;
  _previousZoom = zoom;

  [self prepareClustersForAnimation:clusters isZoomingIn:isZoomingIn];

  _clusters = [clusters copy];

  NSArray *existingMarkers = _annotations;
  _annotations = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
  _annotationsToAdd = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
  _annotationsToRemove = [[NSMutableArray<BMKPointAnnotation *> alloc] init];


  [self addOrUpdateClusters:clusters animated:isZoomingIn];

  if (isZoomingIn) {
    [self clearMarkers:existingMarkers];
  } else {
    [self clearMarkersAnimated:existingMarkers];
  }
}

- (void)clearMarkersAnimated:(NSArray<BMClusterAnnotation *> *)annotations {
  // Remove existing markers: animate to nearest new cluster.
    BMKMapRect visibleBounds = _mapView.visibleMapRect;
//      [[GMSCoordinateBounds alloc] initWithRegion:[_mapView.projection visibleRegion]];
    

  for (BMClusterAnnotation *annotation in annotations) {
    // If the marker for the attached userData has just been added, do not perform animation.
    if ([_renderedClusterItems containsObject:annotation.userData]) {
//      marker.map = nil;
//      [_annotationsToRemove addObject:annotation];
      continue;
    }
    // If the marker is outside the visible view port, do not perform animation.
//    if (![visibleBounds containsCoordinate:marker.coordinate]) {
    BMKMapPoint point = BMKMapPointForCoordinate(annotation.coordinate);
    BOOL shouldShowCluster = BMKMapRectContainsPoint(visibleBounds, point);
    if (!shouldShowCluster) {
        // TODO: marker.map issue?
//      marker.map = nil;
//      [_annotationsToRemove addObject:annotation];
      continue;
    }

      
    // Find a candidate cluster to animate to.
    id<BMCluster> toCluster = nil;
    if ([annotation.userData conformsToProtocol:@protocol(BMCluster)]) {
      id<BMCluster> cluster = annotation.userData;
      toCluster = [self overlappingClusterForCluster:cluster itemMap:_itemToNewClusterMap];
    } else {
      BMWrappingDictionaryKey *key =
          [[BMWrappingDictionaryKey alloc] initWithObject:annotation.userData];
      toCluster = [_itemToNewClusterMap objectForKey:key];
    }
    // If there is not near by cluster to animate to, do not perform animation.
    if (toCluster == nil) {
//      marker.map = nil;
//      [_annotationsToRemove addObject:annotation];
      continue;
    }

    // All is good, perform the animation.
// TODO: Fix this with baidu
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:kBMAnimationDuration];
//    CLLocationCoordinate2D toPosition = toCluster.position;
//    marker.layer.latitude = toPosition.latitude;
//    marker.layer.longitude = toPosition.longitude;
//      
//    [CATransaction commit];
  }

  // Clears existing markers after animation has presumably ended.
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kBMAnimationDuration * NSEC_PER_SEC),
                 dispatch_get_main_queue(), ^{
                   [self clearMarkers:annotations];
                 });
}

// Called when camera is changed to reevaluate if new clusters need to be displayed because
// they become visible.
- (void)update {
  [self addOrUpdateClusters:_clusters animated:NO];
}

#pragma mark Testing

- (NSArray<BMKPointAnnotation *> *)markers {
  return _annotations;
}

#pragma mark Private

// Builds lookup map for item to old clusters, new clusters.
- (void)prepareClustersForAnimation:(NSArray<id<BMCluster>> *)newClusters
                        isZoomingIn:(BOOL)isZoomingIn {
  float zoom = _mapView.zoomLevel;

  if (isZoomingIn) {
    _itemToOldClusterMap =
        [[NSMutableDictionary<BMWrappingDictionaryKey *, id<BMCluster>> alloc] init];
    for (id<BMCluster> cluster in _clusters) {
      if (![self shouldRenderAsCluster:cluster atZoom:zoom]) continue;
      for (id<BMClusterItem> clusterItem in cluster.items) {
        BMWrappingDictionaryKey *key =
            [[BMWrappingDictionaryKey alloc] initWithObject:clusterItem];
        [_itemToOldClusterMap setObject:cluster forKey:key];
      }
    }
    _itemToNewClusterMap = nil;
  } else {
    _itemToOldClusterMap = nil;
    _itemToNewClusterMap =
        [[NSMutableDictionary<BMWrappingDictionaryKey *, id<BMCluster>> alloc] init];
    for (id<BMCluster> cluster in newClusters) {
      if (![self shouldRenderAsCluster:cluster atZoom:zoom]) continue;
      for (id<BMClusterItem> clusterItem in cluster.items) {
        BMWrappingDictionaryKey *key =
            [[BMWrappingDictionaryKey alloc] initWithObject:clusterItem];
        [_itemToNewClusterMap setObject:cluster forKey:key];
      }
    }
  }
}

// Goes through each cluster |clusters| and add a marker for it if it is:
// - inside the visible region of the camera.
// - not yet already added.
- (void)addOrUpdateClusters:(NSArray<id<BMCluster>> *)clusters animated:(BOOL)animated {

//  BMKCoordinateBounds *visibleBounds = [[BMKCoordinateBounds alloc] initWithRegion:[_mapView.projection visibleRegion]];
    
  BMKMapRect visibleBounds = _mapView.visibleMapRect;
  for (id<BMCluster> cluster in clusters) {
      if ([_renderedClusters containsObject:cluster]) {
          continue;
      };

//    BOOL shouldShowCluster = [visibleBounds containsCoordinate:cluster.position];
    // Does visible region include this cluster
    BMKMapPoint point = BMKMapPointForCoordinate(cluster.position);
    BOOL shouldShowCluster = BMKMapRectContainsPoint(visibleBounds, point);
    if (!shouldShowCluster && animated) {
      for (id<BMClusterItem> item in cluster.items) {
        BMWrappingDictionaryKey *key = [[BMWrappingDictionaryKey alloc] initWithObject:item];
        id<BMCluster> oldCluster = [_itemToOldClusterMap objectForKey:key];
        BMKMapPoint oldPoint = BMKMapPointForCoordinate(oldCluster.position);
        if (oldCluster != nil && BMKMapRectContainsPoint(visibleBounds, oldPoint)) {
          shouldShowCluster = YES;
          break;
        }
      }
    }
    if (shouldShowCluster) {
      [self renderCluster:cluster animated:animated];
    }
  }
    
  [self updateMapWithAnnotations];
}

// Only gets called with clusters that aren't rendered
- (void)renderCluster:(id<BMCluster>)cluster animated:(BOOL)animated {
  float zoom = _mapView.zoomLevel;

  // Render the cluster
  if ([self shouldRenderAsCluster:cluster atZoom:zoom]) {
    CLLocationCoordinate2D fromPosition = kCLLocationCoordinate2DInvalid;
    if (animated) {
      id<BMCluster> fromCluster =
          [self overlappingClusterForCluster:cluster itemMap:_itemToOldClusterMap];
      animated = fromCluster != nil;
      fromPosition = fromCluster.position;
    }

//    UIImage *icon = [_clusterIconGenerator iconForSize:cluster.count];
    
    BMClusterAnnotation *annotation = [self annotationWithPosition:cluster.position
                                                              from:fromPosition
                                                          userData:cluster
                                                       clusterIcon:nil
                                                          animated:animated];
    annotation.title = @""; // For interaction
    [_annotationsToAdd addObject:annotation];
  } else {
    // Render the pins
      
    // Add them to map after
    for (id<BMClusterItem> item in cluster.items) {
      CLLocationCoordinate2D fromPosition = kCLLocationCoordinate2DInvalid;
      BOOL shouldAnimate = animated;
      if (shouldAnimate) {
        BMWrappingDictionaryKey *key = [[BMWrappingDictionaryKey alloc] initWithObject:item];
        id<BMCluster> fromCluster = [_itemToOldClusterMap objectForKey:key];
        shouldAnimate = fromCluster != nil;
        fromPosition = fromCluster.position;
      }
    
      BMClusterAnnotation *annotation = [self annotationWithPosition:item.position
                                                              from:fromPosition
                                                          userData:item
                                                       clusterIcon:nil
                                                          animated:shouldAnimate];
      [_annotationsToAdd addObject:annotation];
      [_renderedClusterItems addObject:item];
    }
  }
  [_renderedClusters addObject:cluster];
}

- (void)updateMapWithAnnotations {
    [_mapView removeAnnotations:_annotationsToRemove];
    [_mapView addAnnotations:_annotationsToAdd];
    
    [_annotations addObjectsFromArray:_annotationsToAdd];
    [_annotations removeObjectsInArray:_annotationsToRemove];
    
    _annotationsToAdd = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
    _annotationsToRemove = [[NSMutableArray<BMKPointAnnotation *> alloc] init];
}

- (BMClusterAnnotation *)annotationWithPosition:(CLLocationCoordinate2D)position
                                 from:(CLLocationCoordinate2D)from
                             userData:(id)userData
                          clusterIcon:(UIImage *)clusterIcon
                             animated:(BOOL)animated {
    
    BMClusterAnnotation *annotation = [self annotationForObject:userData];
    
    CLLocationCoordinate2D initialPosition = animated ? from : position;
    annotation.coordinate = initialPosition;
    annotation.userData = userData;
    
    return annotation;
}

- (BMClusterAnnotation *)annotationForObject:(id)object {
    BMClusterAnnotation *annotation;
    if ([_delegate respondsToSelector:@selector(renderer:annotationForObject:)]) {
        annotation = [_delegate renderer:self annotationForObject:object];
    }
    
    return annotation ?: [[BMClusterAnnotation alloc] init];
}

- (BMKPinAnnotationView *)annotationViewForAnnotation:(BMClusterAnnotation *)annotation {
    
    BMKPinAnnotationView *annotationView;
    
    NSString *AnnotationViewID = @"BMItem";
    BOOL isCluster = NO;
    if ([annotation.userData conformsToProtocol:@protocol(BMCluster)]) {
        AnnotationViewID = @"BMCluster";
        isCluster = YES;
    }

    annotationView = (BMKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    } else {
        annotationView.annotation = annotation;
    }
    
    // Add appropriate icon
    if (isCluster) {
        id<BMCluster> cluster = annotation.userData;
        UIImage *icon = [_clusterIconGenerator iconForSize:cluster.count];
        annotationView.image = icon;
        annotationView.canShowCallout = NO;
    } else {
        
        if ([_delegate respondsToSelector:@selector(renderer:willRenderAnnotationView:)]) {
            [_delegate renderer:self willRenderAnnotationView:annotationView];
        } else {
            annotationView.canShowCallout = YES;
        }
    }
    
    return annotationView;
}

// Returns a marker at final position of |position| with attached |userData|.
// If animated is YES, animates from the closest point from |points|.
//- (GMSMarker *)markerWithPosition:(CLLocationCoordinate2D)position
//                             from:(CLLocationCoordinate2D)from
//                         userData:(id)userData
//                      clusterIcon:(UIImage *)clusterIcon
//                         animated:(BOOL)animated {
//  GMSMarker *marker = [self markerForObject:userData];
//  CLLocationCoordinate2D initialPosition = animated ? from : position;
//  marker.position = initialPosition;
//  marker.userData = userData;
//  if (clusterIcon != nil) {
//    marker.icon = clusterIcon;
//    marker.groundAnchor = CGPointMake(0.5, 0.5);
//  }
//  marker.zIndex = _zIndex;
//
//  if ([_delegate respondsToSelector:@selector(renderer:willRenderMarker:)]) {
//    [_delegate renderer:self willRenderMarker:marker];
//  }
//  marker.map = _mapView;
//
//  if (animated) {
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:kBMAnimationDuration];
//    marker.layer.latitude = position.latitude;
//    marker.layer.longitude = position.longitude;
//    [CATransaction commit];
//  }
//
//  if ([_delegate respondsToSelector:@selector(renderer:didRenderMarker:)]) {
//    [_delegate renderer:self didRenderMarker:marker];
//  }
//  return marker;
//}

// Returns clusters which should be rendered and is inside the camera visible region.
- (NSArray<id<BMCluster>> *)visibleClustersFromClusters:(NSArray<id<BMCluster>> *)clusters {
  NSMutableArray *visibleClusters = [[NSMutableArray alloc] init];
  float zoom = _mapView.zoomLevel;
  BMKMapRect visibleBounds = _mapView.visibleMapRect;
  for (id<BMCluster> cluster in clusters) {
    BMKMapPoint point = BMKMapPointForCoordinate(cluster.position);
    if (!BMKMapRectContainsPoint(visibleBounds, point)) continue;
    if (![self shouldRenderAsCluster:cluster atZoom:zoom]) continue;
    [visibleClusters addObject:cluster];
  }
  return visibleClusters;
}

// Returns the first cluster in |itemMap| that shares a common item with the input |cluster|.
// Used for heuristically finding candidate cluster to animate to/from.
- (id<BMCluster>)overlappingClusterForCluster:
    (id<BMCluster>)cluster itemMap:(NSDictionary<BMWrappingDictionaryKey *, id<BMCluster>> *)itemMap {
  id<BMCluster> found = nil;
  for (id<BMClusterItem> item in cluster.items) {
    BMWrappingDictionaryKey *key = [[BMWrappingDictionaryKey alloc] initWithObject:item];
    id<BMCluster> candidate = [itemMap objectForKey:key];
    if (candidate != nil) {
      found = candidate;
      break;
    }
  }
  return found;
}

// Removes all existing markers from the attached map.
- (void)clear {
  [self clearMarkers:_annotations];
  [_annotations removeAllObjects];
  [_annotationsToAdd removeAllObjects];
  [_annotationsToRemove removeAllObjects];
  [_renderedClusters removeAllObjects];
  [_renderedClusterItems removeAllObjects];
  [_itemToNewClusterMap removeAllObjects];
  [_itemToOldClusterMap removeAllObjects];
  _clusters = nil;
}

- (void)clearMarkers:(NSArray<BMClusterAnnotation *> *)annotations {
  for (BMClusterAnnotation *annotation in annotations) {
    annotation.userData = nil;
//    marker.map = nil;
//    [_annotationsToRemove addObject:annotation];
  }
    [_mapView removeAnnotations:annotations];
//    [_annotationsToRemove removeAllObjects];
}

@end
