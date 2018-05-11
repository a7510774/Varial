//
//  MapMarkerWindow.m
//  Varial
//
//  Created by Apple on 10/09/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MapMarkerWindow.h"

@implementation MapMarkerWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    [[NSBundle mainBundle] loadNibNamed:@"MapMarkerWindow" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    [self addSubview:self.mainView];
    float degrees = 50;
    self.arrowView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
    
    _mainView.layer.masksToBounds = NO;
    _mainView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _mainView.layer.shadowOffset = CGSizeMake(5, 5);
    _mainView.layer.shadowOpacity = 1;
    _mainView.layer.shadowRadius = 1.0;

    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.masksToBounds = NO;
}

@end
