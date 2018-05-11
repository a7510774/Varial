//
//  BMCluster.h
//  BaiduMapClusterTest
//
//  Created by Leif Ashby on 5/6/17.
//  Copyright © 2017 Leif Ashby. All rights reserved.
//


#import "BMMarkerClustering.h"

@interface BaiduCheckinItem : NSObject<BMClusterItem>

@property(nonatomic, readonly) CLLocationCoordinate2D position;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSString *snippet;
@property(nonatomic, readonly) NSMutableDictionary *userData;

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position title: (NSString *)title snippet: (NSString *)snippet userData: (NSDictionary *) userData;

@end
