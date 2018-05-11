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

#import "BMNonHierarchicalDistanceBasedAlgorithm.h"

#import <GoogleMaps/GMSGeometryUtils.h>

#import "BMUProjection.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>


#import "BMStaticCluster.h"
#import "BMClusterItem.h"
#import "BMWrappingDictionaryKey.h"
#import "GQTPointQuadTree.h"

static const NSUInteger kBMClusterDistancePoints = 20;
static const double kBMMapPointWidth = 2.0;  // MapPoint is in a [-1,1]x[-1,1] space.

#pragma mark Utilities Classes

@interface BMClusterItemQuadItem : NSObject<GQTPointQuadTreeItem>

@property(nonatomic, readonly) id<BMClusterItem> clusterItem;

- (instancetype)initWithClusterItem:(id<BMClusterItem>)clusterItem;

@end

@implementation BMClusterItemQuadItem {
  id<BMClusterItem> _clusterItem;
  GQTPoint _clusterItemPoint;
}

- (instancetype)initWithClusterItem:(id<BMClusterItem>)clusterItem {
  if ((self = [super init])) {
    _clusterItem = clusterItem;
    GMSMapPoint point = GMSProject(clusterItem.position);
//    BMKMapPoint point = [BMUProjection project:clusterItem.position.longitude phi:clusterItem.position.latitude];
//      BMKMapPoint point = BMKMapPointForCoordinate(clusterItem.position);
    _clusterItemPoint.x = point.x;
    _clusterItemPoint.y = point.y;
  }
  return self;
}

- (GQTPoint)point {
  return _clusterItemPoint;
}

// Forwards hash to clusterItem.
- (NSUInteger)hash {
  return [_clusterItem hash];
}

// Forwards isEqual to clusterItem.
- (BOOL)isEqual:(id)object {
  if (self == object) return YES;

  if ([object class] != [self class]) return NO;

  BMClusterItemQuadItem *other = (BMClusterItemQuadItem *)object;
  return [_clusterItem isEqual:other->_clusterItem];
}

@end

#pragma mark BMNonHierarchicalDistanceBasedAlgorithm

@implementation BMNonHierarchicalDistanceBasedAlgorithm {
  NSMutableArray<id<BMClusterItem>> *_items;
  GQTPointQuadTree *_quadTree;
}

- (instancetype)init {
  if ((self = [super init])) {
    _items = [[NSMutableArray alloc] init];
    GQTBounds bounds = {-1, -1, 1, 1};
    _quadTree = [[GQTPointQuadTree alloc] initWithBounds:bounds];
  }
  return self;
}

- (void)addItems:(NSArray<id<BMClusterItem>> *)items {
  [_items addObjectsFromArray:items];
  for (id<BMClusterItem> item in items) {
    BMClusterItemQuadItem *quadItem = [[BMClusterItemQuadItem alloc] initWithClusterItem:item];
    [_quadTree add:quadItem];
  }
}

/**
 * Removes an item.
 */
- (void)removeItem:(id<BMClusterItem>)item {
  [_items removeObject:item];

  BMClusterItemQuadItem *quadItem = [[BMClusterItemQuadItem alloc] initWithClusterItem:item];
  // This should remove the corresponding quad item since BMClusterItemQuadItem forwards its hash
  // and isEqual to the underlying item.
  [_quadTree remove:quadItem];
}

/**
 * Clears all items.
 */
- (void)clearItems {
  [_items removeAllObjects];
  [_quadTree clear];
}

/**
 * Returns the set of clusters of the added items.
 */
- (NSArray<id<BMCluster>> *)clustersAtZoom:(float)zoom {
  NSMutableArray<id<BMCluster>> *clusters = [[NSMutableArray alloc] init];
  NSMutableDictionary<BMWrappingDictionaryKey *, id<BMCluster>> *itemToClusterMap =
      [[NSMutableDictionary alloc] init];
  NSMutableDictionary<BMWrappingDictionaryKey *, NSNumber *> *itemToClusterDistanceMap =
      [[NSMutableDictionary alloc] init];
  NSMutableSet<id<BMClusterItem>> *processedItems = [[NSMutableSet alloc] init];

  for (id<BMClusterItem> item in _items) {
    if ([processedItems containsObject:item]) continue;

    BMStaticCluster *cluster = [[BMStaticCluster alloc] initWithPosition:item.position];

    GMSMapPoint point = GMSProject(item.position);
//    BMKMapPoint point = [BMUProjection project:item.position.longitude phi:item.position.latitude];
//    BMKMapPoint point = BMKMapPointForCoordinate(item.position);
      
    // Query for items within a fixed point distance from the current item to make up a cluster
    // around it.
//    double radius = kBMClusterDistancePoints * kBMMapPointWidth / pow(2.0, zoom + 8.0);
    double radius = kBMClusterDistancePoints * kBMMapPointWidth / pow(2.0, zoom + 5.0);
    GQTBounds bounds = {point.x - radius, point.y - radius, point.x + radius, point.y + radius};
    NSArray *nearbyItems = [_quadTree searchWithBounds:bounds];
    for (BMClusterItemQuadItem *quadItem in nearbyItems) {
      id<BMClusterItem> nearbyItem = quadItem.clusterItem;
      [processedItems addObject:nearbyItem];
      GMSMapPoint nearbyItemPoint = GMSProject(nearbyItem.position);
//      BMKMapPoint nearbyItemPoint = [BMUProjection project:nearbyItem.position.longitude phi:nearbyItem.position.latitude];
//      BMKMapPoint nearbyItemPoint = BMKMapPointForCoordinate(nearbyItem.position);
      BMWrappingDictionaryKey *key = [[BMWrappingDictionaryKey alloc] initWithObject:nearbyItem];

      NSNumber *existingDistance = [itemToClusterDistanceMap objectForKey:key];
      double distanceSquared = [self distanceSquaredBetweenPointA:point andPointB:nearbyItemPoint];
      if (existingDistance != nil) {
        if ([existingDistance doubleValue] < distanceSquared) {
          // Already belongs to a closer cluster.
          continue;
        }
        BMStaticCluster *existingCluster = [itemToClusterMap objectForKey:key];
        [existingCluster removeItem:nearbyItem];
      }
      NSNumber *number = [NSNumber numberWithDouble:distanceSquared];
      [itemToClusterDistanceMap setObject:number forKey:key];
      [itemToClusterMap setObject:cluster forKey:key];
      [cluster addItem:nearbyItem];
    }
    [clusters addObject:cluster];
  }
  NSAssert(itemToClusterDistanceMap.count == _items.count,
           @"All items should be mapped to a distance");
  NSAssert(itemToClusterMap.count == _items.count,
           @"All items should be mapped to a cluster");

#if DEBUG
  NSUInteger totalCount = 0;
  for (id<BMCluster> cluster in clusters) {
    totalCount += cluster.count;
  }
  NSAssert(_items.count == totalCount, @"All clusters combined should make up original item set");
#endif
  return clusters;
}

#pragma mark Private

- (double)distanceSquaredBetweenPointA:(GMSMapPoint)pointA andPointB:(GMSMapPoint)pointB {
  double deltaX = pointA.x - pointB.x;
  double deltaY = pointA.y - pointB.y;
  return deltaX * deltaX + deltaY * deltaY;
}

@end

