//
//  LoadingDotsView.h
//  NetworkingSample
//
//  Created by Apple on 02/08/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingDotsView : UIView
{
    NSMutableArray *viewArray;
    int count;
    NSTimer *timer;
    UIColor *viewColor;
    float delayTime;
}
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

-(id)initWithDots:(int)dotsCount withColor:(UIColor*)color;
-(void)startAnimating;
-(void)stopanimating;
@end
