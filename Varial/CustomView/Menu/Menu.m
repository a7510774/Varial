//
//  Menu.m
//  TableViewAnimation
//
//  Created by Shanmuga priya on 5/9/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "Menu.h"
#import "Util.h"

@implementation Menu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

-(id)init{
    self = [super init];
    return self;
}
-(id)initWithViews:(NSString *)title buttonTitle:(NSMutableArray*)array   withImage:(NSMutableArray*)imgArray{
    self = [super init];
    
    
    [[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil];
    
    if(title != nil)
    {
        _titleLabel.text = NSLocalizedString(title, nil);
        height = 52;
    }
    else
    {
        _titleLabel.hidden = TRUE;
        _titleBorder.hidden = TRUE;
        height = 0;
    }
    
    buttonTitles = array;
    for(int i = 0 ; i < [array count] ; i++)
    {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0 , height , 290 , 50)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
        [button setTitle:NSLocalizedString([array objectAtIndex:i], nil) forState:UIControlStateNormal];
        
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        
        
        if(imgArray != nil)
        {
            imgView.image = [UIImage imageNamed:[imgArray objectAtIndex:i]];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(10.0f, 50.0f, 0.0f, 0.0f)];
            
        }
        else{
            [button setTitleEdgeInsets:UIEdgeInsetsMake(10.0f, 10.0f, 0.0f, 0.0f)];
        }
        [_titleLabel setFont:[UIFont fontWithName:@"Century Gothic" size:17]];
        [button.titleLabel setFont:[UIFont fontWithName:@"Century Gothic" size:16]];
        [button setBackgroundColor:[UIColor whiteColor]];
        button.tag = i+1;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:imgView];
        if(i != [array count]-1)
            [Util createBottomLine:button withColor:[UIColor lightGrayColor]];
        [self.mainView addSubview:button];
        height = height + 50;
    }
    
    CGRect rootViewFrame =self.mainView.frame;
    rootViewFrame.size.height=height;
    self.frame=rootViewFrame;
    
    //Menu *menu=[[Menu alloc]initWithFrame:rootViewFrame];
    [self addSubview:self.mainView];
    return  self;
}

-(void)buttonAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    //[self makeViewShine:button];
    [self.delegate menuActionForIndex:button.tag];
}

-(void)makeViewShine:(UIView*) view
{
    view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    view.layer.shadowRadius = 1.0f;
    view.layer.shadowOpacity = 1.0f;
    view.layer.shadowOffset = CGSizeZero;
    
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction  animations:^{
        
        [UIView setAnimationRepeatCount:0];
        
        view.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        
    } completion:^(BOOL finished) {
        view.layer.shadowRadius = 0.0f;
        view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
    
}
@end
