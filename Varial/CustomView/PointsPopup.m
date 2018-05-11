//
//  PointsPopup.m
//  Varial
//
//  Created by Shanmuga priya on 2/19/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "PointsPopup.h"

@implementation PointsPopup

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (id)init{
    
    self = [super init];

    return self;
}

- (id)initWithViewsshowBuyPoints:(BOOL)buyPoints showDonatePoints:(BOOL)donatePoints showRedeemPoints:(BOOL)redeemPoint showPointsActivityLog:(BOOL)pointsActivityLog {
    self = [super init];

    height=42.0;
    [[NSBundle mainBundle] loadNibNamed:@"PointsPopup" owner:self options:nil];
    
    
    
    if (buyPoints) {
        height=height+50.0;
        [Util createBottomLine:_buyPointView withColor:[UIColor lightGrayColor]];
        
        
    }else{
        
        
        [_buyPointView hideByHeight:YES];
        [_buyPointView setHidden:YES];
    }
    
    if (donatePoints) {
        height=height+50.0;
        [Util createBottomLine:_donatePointView withColor:[UIColor lightGrayColor]];
        
        
        
    }else{
        
        [_donatePointView hideByHeight:YES];
        [_donatePointView setHidden:YES];
    }
    
    if (redeemPoint) {
        height=height+50.0;
        [Util createBottomLine:_redeemPointsView withColor:[UIColor lightGrayColor]];
        
        
    }else{
        
        [_redeemPointsView hideByHeight:YES];
        [_redeemPointsView setHidden:YES];
    }
    
    if (pointsActivityLog) {
        
        height=height+50.0;
        
        
    }else{
        
        [_pointsActivityLogView hideByHeight:YES];
        
        [_pointsActivityLogView setHidden:YES];
    }
    
        CGRect rootViewFrame =self.mainView.frame;
    rootViewFrame.size.height=height;
    self.frame=rootViewFrame;
    
    PointsPopup *pointsPopup=[[PointsPopup alloc]initWithFrame:rootViewFrame];
 
    [self addSubview:self.mainView];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _points.text = NSLocalizedString(@"POINTS", nil);
    _buyPointsLabel.text = NSLocalizedString(@"Buy Points", nil);
    _donatePointsLabel.text = NSLocalizedString(@"Donate Points", nil);
    _redeemPointsLabel.text = NSLocalizedString(@"Redeem Points", nil);
    _pointsLogLabel.text = NSLocalizedString(@"Points Activity Log", nil);
    
    return self;
}



- (IBAction)doBuyPoints:(id)sender {
    [self.delegate onBuyPointsClick];
    
}

- (IBAction)doDonatePoints:(id)sender {
    [self.delegate onDonatePointsClick];
}

- (IBAction)doRedeemPoints:(id)sender {
    [self.delegate onRedeemPointsClick];
    
}

- (IBAction)doPointsActivityLog:(id)sender {
    [self.delegate onPointsActivityLog];
}
@end
