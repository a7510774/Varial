//
//  ShopDetails.h
//  Varial
//
//  Created by Shanmuga priya on 3/15/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "GoogleMap.h"
#import "SVPullToRefresh.h"
#import "BaiduMap.h"

@interface ShopDetails : UIViewController<UITabBarDelegate,BaiduDelegate>{
    NSString *mediaBase, *latitude, *longitude;
    NSMutableArray *offerDetail;
    BaiduMap* baiduMap;
}
@property (strong) NSString *offerId;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabOne;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property ( nonatomic) IBOutlet UITextView *offerDescription;
@property (weak, nonatomic) IBOutlet GoogleMap *googleMap;
@property (weak, nonatomic) IBOutlet UIView *baiduMap;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIWebView *offerDescriptionView;

@end
