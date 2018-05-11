//
//  DragView.h
//  BTPT
//
//  Created by Velan Info Services on 2015-09-24.
//  Copyright (c) 2015 Velan Info Services. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragView : UIButton
{
    CGPoint lastLocation;
}

- (void) addPanGesture;

@end
