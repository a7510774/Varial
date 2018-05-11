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

#import "BMGridBasedClusterAlgorithm.h"

//#import <GoogleMaps/GMSGeometryUtils.h>

#import "BMStaticCluster.h"
#import "BMClusterItem.h"

// Grid cell dimension in pixels to keep clusters about 100 pixels apart on screen.
static const NSUInteger kBMGridCellSizePoints = 100;

@implementation BMGridBasedClusterAlgorithm {
  NSMutableArray<id<BMClusterItem>> *_items;
}

- (instancetype)init {
  if ((self = [super init])) {
    _items = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)addItems:(NSArray<id<BMClusterItem>> *)items {
  [_items addObjectsFromArray:items];
}

- (void)removeItem:(id<BMClusterItem>)item {
  [_items removeObject:item];
}

- (void)clearItems {
  [_items removeAllObjects];
}

- (NSArray<id<BMCluster>> *)clustersAtZoom:(float)zoom {
  NSMutableDictionary<NSNumber *, id<BMCluster>> *clusters = [[NSMutableDictionary alloc] init];

  // Divide the whole map into a numCells x numCells grid and assign items to them.
  long numCells = (long)ceil(256 * pow(2, zoom) / kBMGridCellSizePoints);
  for (id<BMClusterItem> item in _items) {
      
      // Convert from CLLocation2d to [-1,1]
//    GMSMapPoint point = GMSProject(item.position);
//      BMKMapPoint point = item.position
      
    long col = (long)(numCells * (1.0 + point.x) / 2);  // point.x is in [-1, 1] range
    long row = (long)(numCells * (1.0 + point.y) / 2);  // point.y is in [-1, 1] range
    long index = numCells * row + col;
    NSNumber *cellKey = [NSNumber numberWithLong:index];
    BMStaticCluster *cluster = clusters[cellKey];
    if (cluster == nil) {
      // Normalize cluster's centroid to center of the cell.
      GMSMapPoint point2 = {(double)(col + 0.5) * 2.0 / numCells - 1,
                            (double)(row + 0.5) * 2.0 / numCells - 1};
      CLLocationCoordinate2D position = GMSUnproject(point2);
      cluster = [[BMStaticCluster alloc] initWithPosition:position];
      clusters[cellKey] = cluster;
    }
    [cluster addItem:item];
  }
  return [clusters allValues];
}

@end

