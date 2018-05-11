//
//  PointsPopup.h
//  Varial
//
//  Created by Shanmuga priya on 2/19/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@protocol PointsPopupDelegate


-(void)onBuyPointsClick;
-(void)onDonatePointsClick;
-(void)onRedeemPointsClick;
-(void)onPointsActivityLog;

@end


@interface PointsPopup : UIView{
    float height;
    
}

@property (assign) id<PointsPopupDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UIView *buyPointView;
@property (weak, nonatomic) IBOutlet UIView *donatePointView;
@property (weak, nonatomic) IBOutlet UIView *redeemPointsView;
@property (weak, nonatomic) IBOutlet UIView *pointsActivityLogView;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UILabel *buyPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *donatePointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *redeemPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLogLabel;

- (IBAction)doBuyPoints:(id)sender;
- (IBAction)doDonatePoints:(id)sender;
- (IBAction)doRedeemPoints:(id)sender;
- (IBAction)doPointsActivityLog:(id)sender;


-(id)init;
- (id)initWithViewsshowBuyPoints:(BOOL)buyPoints showDonatePoints:(BOOL)donatePoints showRedeemPoints:(BOOL)redeemPoint showPointsActivityLog:(BOOL)pointsActivityLog;



@end


