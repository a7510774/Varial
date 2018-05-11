//
//  CheckinMarker.m
//  Varial
//
//  Created by Leif Ashby on 4/2/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "CheckinMarker.h"

@implementation CheckinMarker

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
