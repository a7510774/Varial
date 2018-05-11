//
//  ClubPromotionsHome.h
//  Varial
//
//  Created by jagan on 29/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "NearClubPromotions.h"
#import "ClubPromotionsDetails.h"

@interface ClubPromotionsHome : UIViewController<BaiduDelegate,CLLocationManagerDelegate,UITextFieldDelegate,UITabBarDelegate>{
    CLLocationManager *locationManager;
    NSMutableArray *allPromotionList, *searchList, *nearByList;
    int page,previousPage,searchPage,searchPrevious;
    NSURLSessionDataTask *task;
    NSString *mediaBase;
    BOOL locationUpdated;
}


@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong)IBOutlet UITableView *clubPromotionTable;
@property(nonatomic, strong)IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabOne;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabTwo;
@property (weak, nonatomic) IBOutlet UIView  *nearByView;
@property (weak, nonatomic) IBOutlet UIButton *nearBySmall;
@property (weak, nonatomic) IBOutlet UIButton *clubPromotion;
@property (weak, nonatomic) IBOutlet UIButton *viewNearByBig;
@property (weak, nonatomic) IBOutlet UIView *allClubPromotionView;
@property (weak, nonatomic) IBOutlet UITableView *nearByTableView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;


-(IBAction)viewNearBy:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;
- (IBAction)enableLocationService:(id)sender;

@end
