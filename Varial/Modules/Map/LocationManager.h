//
//  LocationManager.h
//  mapTest
//
//  Created by Chenyun on 15/3/11.
//  Copyright (c) 2015年 geek-zoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@property (nonatomic, strong, readonly) NSString * locationString;
@property (nonatomic, copy) void (^whenGetLoaction)( id, NSError * error );
@property (nonatomic, copy) void (^whenGetReverseGeocoding)( id, CLLocation * currentLocation);

- (void)startUpdateLocation;
- (void)stopUpdateLocation;
- (CLLocationCoordinate2D)locationCoordinate;
- (void) requestLocationService;

+ (LocationManager *)sharedManager;


@end
