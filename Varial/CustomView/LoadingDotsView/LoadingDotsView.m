//
//  LoadingDotsView.m
//  NetworkingSample
//
//  Created by Apple on 02/08/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "LoadingDotsView.h"

@implementation LoadingDotsView
-(id)init{
    self = [super init];
    return self;
}
-(id)initWithDots:(int)dotsCount withColor:(UIColor*)color{
    self = [super init];
    count = dotsCount;
    viewColor = color;
    viewArray = [[NSMutableArray alloc]init];
    [[NSBundle mainBundle] loadNibNamed:@"LoadingDotsView" owner:self options:nil];
    
    for(int i = 0 ; i < dotsCount ; i++)
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i*10,10, 0, 0)];
        view.layer.cornerRadius = 2.5;
        [view setBackgroundColor:color];
        [viewArray addObject:view];
        [_mainView addSubview:view];
    }
    
    _mainView.hidden = YES;
    CGRect rootViewFrame =self.mainView.frame;
    self.frame=rootViewFrame;
    [self addSubview:self.mainView];
    return  self;
}

-(void)startAnimating{
    [self initWithDots:count withColor:viewColor];
    delayTime = 0.2*count;
    timer = [NSTimer scheduledTimerWithTimeInterval:delayTime target:self selector:@selector(animateView) userInfo:nil repeats:YES];
    _mainView.hidden = NO;

}
-(void)stopanimating{
    [timer invalidate];
    _mainView.hidden = YES;
}
-(void)animateView{
    float delay = 0;
    for(int i = 0 ; i < count ; i++)
    {
        UIView *view = [viewArray objectAtIndex:i];
        [UIView animateWithDuration:delayTime delay:delay options:UIViewAnimationOptionTransitionNone animations: ^{
            view.frame = CGRectMake((i*10)+5,10, 5, 5);
        } completion:^ (BOOL finished){
            
            [UIView animateWithDuration:delayTime delay:0.2 options:UIViewAnimationOptionTransitionNone animations: ^{
                view.frame = CGRectMake(i*10,10, 0, 0);
            } completion:nil];
        }];
        delay += 0.2;
    }
}
@end
