//
//  SkateBoard.m
//  Varial
//
//  Created by jagan on 01/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "SkateBoard.h"

@implementation SkateBoard

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.masksToBounds = YES;        
    }
    return self;
}


@end
