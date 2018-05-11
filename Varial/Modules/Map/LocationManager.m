//
//  LocationManager.m
//  mapTest
//
//  Created by Chenyun on 15/3/11.
//  Copyright (c) 2015年 geek-zoo. All rights reserved.
//

#import "LocationManager.h"
#import "Util.h"

@implementation LocationManager

static LocationManager * sharedLoaction = nil;

+ (LocationManager *)sharedManager
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedLoaction = [[self alloc] init];
    });
    
    return sharedLoaction;
}

- (instancetype)init
{
    self = [super init];
    
    if ( self )
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1000.0f;
        
        self.longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"location_longitude"];
        self.latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"location_latitude"];
        if (self.longitude == 0 && self.latitude == 0) {
            self.longitude = DEFAULT_LONGITUDE;
            self.latitude = DEFAULT_LATITUDE;
        }
    }
    
    return self;
}

- (NSString *)locationString
{
    return [NSString stringWithFormat:@"%@, %@", @([LocationManager sharedManager].latitude), @([LocationManager sharedManager].longitude)];
}

- (CLLocationCoordinate2D)locationCoordinate
{
    CLLocationCoordinate2D coor;
    coor.latitude = [LocationManager sharedManager].latitude;
    coor.longitude = [LocationManager sharedManager].longitude;    
    return coor;
}

- (void)startUpdateLocation
{
    if ([Util checkLocationIsEnabled] )
    {
        [_locationManager stopUpdatingLocation];
        [_locationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"turn on location");
    }
    
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else
    {
        [self.locationManager startUpdatingLocation];
    }
    
}



//Ask user to enable the location service
- (void) requestLocationService{
    
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

//Stop updating location
- (void)stopUpdateLocation
{
    [_locationManager stopUpdatingLocation];
}

#pragma mark -
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * currentLocation = [locations lastObject];
    
    self.latitude = currentLocation.coordinate.latitude;
    self.longitude = currentLocation.coordinate.longitude;
    
    NSLog(@"Location Updated %f %f", self.longitude, self.latitude);
    
    [[NSUserDefaults standardUserDefaults] setFloat:self.latitude forKey:@"location_latitude"];
    [[NSUserDefaults standardUserDefaults] setFloat:self.longitude forKey:@"location_longitude"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationUpdated" object:nil userInfo:nil];
  
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ( self.whenGetLoaction )
    {
        self.whenGetLoaction(nil, error);
    }
}



@end
