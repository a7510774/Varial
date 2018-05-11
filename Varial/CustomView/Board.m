//
//  Board.m
//  Varial
//
//  Created by jagan on 27/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Board.h"

@implementation Board



- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.masksToBounds = YES;
    }
    return self;
}
@end
