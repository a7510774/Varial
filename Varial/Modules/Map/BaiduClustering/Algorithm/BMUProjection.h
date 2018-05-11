//
//  BMUProjection.h
//  BaiduMapsClustering
//
//  Created by Leif Ashby on 5/5/17.
//  Copyright © 2017 Leif Ashby. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface BMUProjection : NSObject

+ (float)degToRad:(float)deg;
+ (float)phi2:(float)ts e:(float)e;

+ (BMKMapPoint)project:(double)lam phi:(double)phi;
+ (BMKMapPoint)projectInverse:(double)x y:(double)y;

@end
