//
//  CustomClusterRenderer.m
//  Varial
//
//  Created by Leif Ashby on 4/13/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "CustomClusterRenderer.h"


// Clusters smaller than this threshold will be expanded.
static const NSUInteger kGMUMinClusterSize = 4;

// At zooms above this level, clusters will be expanded.
// This is to prevent cases where items are so close to each other than they are always grouped.
static const float kGMUMaxClusterZoom = 20;


@implementation CustomClusterRenderer

- (BOOL)shouldRenderAsCluster:(id<GMUCluster>)cluster atZoom:(float)zoom {
    
    if (cluster.count < kGMUMinClusterSize) {
        return NO;
    }
    
    if (zoom > kGMUMaxClusterZoom) {
        return YES;
    }
    
    return YES;
}

@end
