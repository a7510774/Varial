//
//  GoogleAdMob.h
//  Varial
//
//  Created by jagan on 16/04/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AdMobDelegate <NSObject>
@optional
- (void)displayAd:(CGFloat)height;
- (void)removeAd;
@end

@interface GoogleAdMob : NSObject
//{
//    CGFloat height;
//    __weak BannerView *adView;
////    NSString *redirectTo;
//}

@property (weak, nonatomic) id<AdMobDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)addAdInViewController:(UIViewController*)viewController;
- (void)removeLastAd;
- (void)fetchFeedAdWithCallback:(void(^)(NSDictionary *))handler;

@end
