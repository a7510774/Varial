//
//  ProfileImage.m
//  Varial
//
//  Created by jagan on 29/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ProfileImage.h"

@implementation ProfileImage

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
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.layer.masksToBounds = YES;
//        [self.layer setBorderColor: UIColorFromHexCode(THEME_COLOR).CGColor];
//        [self.layer setBorderWidth:2.0f];
    }
    return self;
}

@end
