//
//  MainMenu.h
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyProfile.h"
#import "ImageSlider.h"
#import "BuyPointsViewController.h"
#import "ZoomImage.h"
#import "ClubPromotionsHome.h"
#import "SettingsMenu.h"
#import "GoogleAdMob.h"

@interface MainMenu : UIViewController<UIWebViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSURLSessionDataTask *task;
    NSString *mediaBase;
    UIWebView *webView;
    NSMutableArray *menus;
    AppDelegate *appDelegate;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *profileHeader;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *pointsValue;
@property (weak, nonatomic) IBOutlet UILabel *rankValue;
@property (weak, nonatomic) IBOutlet UIImageView *boardImage;
- (IBAction)showMyProfile:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuContainerBottom;

@end

