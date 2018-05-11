//
//  DragView.m
//  BTPT
//
//  Created by Velan Info Services on 2015-09-24.
//  Copyright (c) 2015 Velan Info Services. All rights reserved.
//

#import "DragView.h"
#import "config.h"

@implementation DragView

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
        
        [self addPanGesture];
        
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.layer.masksToBounds = NO;
        
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 3;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOpacity = .5;

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addPanGesture];
        
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.layer.masksToBounds = YES;
        
        [self.layer setBorderColor: UIColorFromHexCode(THEME_COLOR).CGColor];
        [self.layer setBorderWidth:1.0f];
        
//        // randomize view color
//        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
//        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
//        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
//        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        //self.backgroundColor = UIColorFromHexCode(GREEN_STAR);
    }
    return self;
}

- (void) addPanGesture{
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPan:)];
    self.gestureRecognizers = @[panRecognizer];
}

- (void) detectPan:(UIPanGestureRecognizer *) uiPanGestureRecognizer
{
    CGPoint translation = [uiPanGestureRecognizer translationInView:self.superview];
    self.center = CGPointMake(lastLocation.x + translation.x,
                              lastLocation.y + translation.y);
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Promote the touched view
    [self.superview bringSubviewToFront:self];
    
    // Remember original location
    lastLocation = self.center;
}

@end
