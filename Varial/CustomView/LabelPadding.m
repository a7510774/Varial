//
//  LabelPadding.m
//  Varial
//
//  Created by jagan on 21/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "LabelPadding.h"

@implementation LabelPadding


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawTextInRect:rect];
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {5, 15, 5, 15};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
