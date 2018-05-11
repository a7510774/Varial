//
//  CheckinMarker.h
//  Varial
//
//  Created by Leif Ashby on 4/2/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMUMarkerClustering.h"

@interface CheckinMarker : NSObject<GMUClusterItem>

@property(nonatomic, readonly) CLLocationCoordinate2D position;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSString *snippet;
@property(nonatomic, readonly) NSDictionary *userData;

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position title: (NSString *)title snippet: (NSString *)snippet userData: (NSDictionary *) userData;

@end
