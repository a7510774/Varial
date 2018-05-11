//
//  BMCluster.m
//  BaiduMapClusterTest
//
//  Created by Leif Ashby on 5/6/17.
//  Copyright © 2017 Leif Ashby. All rights reserved.
//

#import "BaiduCheckinItem.h"

@implementation BaiduCheckinItem

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position title: (NSString *)title snippet: (NSString *)snippet userData: (NSDictionary *) userData {
    if ((self = [super init])) {
        _position = position;
        _title = title;
        _snippet = snippet;
        _userData = userData;
    }
    return self;
}

@end
