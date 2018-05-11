//
//  BMUProjection.m
//  BaiduMapsClustering
//
//  Created by Leif Ashby on 5/5/17.
//  Copyright © 2017 Leif Ashby. All rights reserved.
//

//#import <BMKTypes.h>
#import <BaiduMapAPI_Base/BMKTypes.h>
#import "BMUProjection.h"

//#import "math.h"

#define PI          3.14159
#define HALFPI      PI/2
#define QUARTERPI   PI/4

#define N_ITER      1

static float minLatitude;
static float maxLatitude;
static float scaleFactor;
static BOOL spherical;
static float e;

@implementation BMUProjection
{
}

//- (instancetype) init {
//    if ((self = [super init])) {
//        minLatitude = [BMUProjection degToRad:-85];
//        maxLatitude = [BMUProjection degToRad:85];
//        scaleFactor = 1.0;
//        spherical = NO;
//        e = 0;
//    }
//    
//    return self;
//}

+ (void) initialize {
    minLatitude = [BMUProjection degToRad:-85];
    maxLatitude = [BMUProjection degToRad:85];
    scaleFactor = 1.0;
    spherical = NO;
    e = 0;
}

+ (float)degToRad:(float)deg {
    return deg * 180.0 / PI;
}

+ (float)phi2:(float)ts e:(float)e {
    float eccnth, phi, con, dphi;
    int i;
    
    eccnth = .5 * e;
    phi = HALFPI - 2. * atan(ts);
    i = N_ITER;
    do {
        con = e * sin(phi);
//        dphi = HALFPI - 2.0 * atan(ts * pow((1. - con) / (1. + con), eccnth)) - phi;
        dphi = HALFPI - 2.0 * atan(ts * pow((1. - con) / (1. + con), eccnth)) - phi;
        phi += dphi;
    } while (fabsf(dphi) > 1e-10 && --i != 0);
    if (i <= 0) {
        return NO;
    }
    return phi;
}

+ (float)tsfn:(double)phi sinphi:(double)sinphi e:(double)e {
    sinphi *= e;
    return (tan (.5 * (HALFPI - phi)) /
            pow((1. - sinphi) / (1. + sinphi), .5 * e));
}

+ (BMKMapPoint)project:(double)lam phi:(double)phi {
    BMKMapPoint out;
    if (spherical) {
        out.x = scaleFactor * lam;
        if (phi > maxLatitude) {
            phi = maxLatitude;
        } else if (phi < minLatitude) {
            phi = minLatitude;
        }
        out.y = scaleFactor * log(tan(QUARTERPI + 0.5 * phi));
    } else {
        out.x = scaleFactor * lam;
        out.y = -scaleFactor * log([BMUProjection tsfn:phi sinphi:sin(phi) e:e]);
    }
    return out;
}

+ (BMKMapPoint)projectInverse:(double)x y:(double)y {
    BMKMapPoint out;
    if (spherical) {
        out.y = HALFPI - 2. * atan(exp(-y / scaleFactor));
        out.x = x / scaleFactor;
    } else {
        out.y = [BMUProjection phi2:exp(-y / scaleFactor) e:e];
        out.x = x / scaleFactor;
    }
    return out;
}

@end
