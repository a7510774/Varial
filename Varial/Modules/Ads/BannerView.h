//
//  BannerView.h
//  Varial
//
//  Created by Leif Ashby on 8/7/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAdMob.h"

@interface BannerView : UIView

@property (weak, nonatomic) id<AdMobDelegate> delegate;

@property (strong, nonatomic) NSString *adUrl;

@property (weak, nonatomic) IBOutlet UIImageView *dismissButton;
@property (weak, nonatomic) IBOutlet UIImageView *adImage;

- (IBAction)dismiss:(id)sender;

@end
