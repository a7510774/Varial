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

#import <Foundation/Foundation.h>

//#import <GoogleMaps/GoogleMaps.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
//#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>


#import "BMClusterAlgorithm.h"
#import "BMClusterItem.h"
#import "BMClusterRenderer.h"
#import "BMClusterAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@class BMClusterManager;

/**
 * Delegate for events on the BMClusterManager.
 */
@protocol BMClusterManagerDelegate<NSObject>

@optional

/**
 * Called when the user taps on a cluster marker.
 * @return YES if this delegate handled the tap event,
 * and NO to pass this tap event to other handlers.
 */
- (BOOL)clusterManager:(BMClusterManager *)clusterManager didTapCluster:(id<BMCluster>)cluster;

/**
 * Called when the user taps on a cluster item marker.
 * @return YES if this delegate handled the tap event,
 * and NO to pass this tap event to other handlers.
 */
- (BOOL)clusterManager:(BMClusterManager *)clusterManager
     didTapClusterItem:(id<BMClusterItem>)clusterItem;

@end

/**
 * This class groups many items on a map based on zoom level.
 * Cluster items should be added to the map via this class.
 */
@interface BMClusterManager : NSObject<BMKMapViewDelegate>

/**
 * The default initializer is not available. Use initWithMap:algorithm:renderer instead.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Returns a new instance of the BMClusterManager class defined by it's |algorithm| and |renderer|.
 */
- (instancetype)initWithMap:(BMKMapView *)mapView
                  algorithm:(id<BMClusterAlgorithm>)algorithm
                   renderer:(id<BMClusterRenderer>)renderer NS_DESIGNATED_INITIALIZER;

/**
 * Returns the clustering algorithm.
 */
@property(nonatomic, readonly) id<BMClusterAlgorithm> algorithm;

/**
 * BMClusterManager |delegate|.
 * To set it use the setDelegate:mapDelegate: method.
 */
@property(nonatomic, readonly, weak, nullable) id<BMClusterManagerDelegate> delegate;

/**
 * The GMSMapViewDelegate delegate that map events are being forwarded to.
 * To set it use the setDelegate:mapDelegate: method.
 */
@property(nonatomic, readonly, weak, nullable) id<BMKMapViewDelegate> mapDelegate;

/**
 * Sets BMClusterManagerDelegate |delegate| and optionally
 * provides a |mapDelegate| to listen to forwarded map events.
 *
 * NOTES: This method changes the |delegate| property of the
 * managed |mapView| to this object, intercepting events that
 * the BMClusterManager wants to action or rebroadcast
 * to the BMClusterManagerDelegate. Any remaining events are
 * then forwarded to the new |mapDelegate| provided here.
 *
 * EXAMPLE: [clusterManager setDelegate:self mapDelegate:_map.delegate];
 * In this example self will receive type-safe BMClusterManagerDelegate
 * events and other map events will be forwarded to the current map delegate.
 */
- (void)setDelegate:(id<BMClusterManagerDelegate> _Nullable)delegate
        mapDelegate:(id<BMKMapViewDelegate> _Nullable)mapDelegate;

/**
 * Adds a cluster item to the collection.
 */
- (void)addItem:(id<BMClusterItem>)item;

/**
 * Adds multiple cluster items to the collection.
 */
- (void)addItems:(NSArray<id<BMClusterItem>> *)items;

/**
 * Removes a cluster item from the collection.
 */
- (void)removeItem:(id<BMClusterItem>)item;

/**
 * Removes all items from the collection.
 */
- (void)clearItems;

/**
 * Called to arrange items into groups.
 * - This method will be automatically invoked when the map's zoom level changes.
 * - Manually invoke this method when new items have been added to rearrange items.
 */
- (void)cluster;

@end


NS_ASSUME_NONNULL_END

