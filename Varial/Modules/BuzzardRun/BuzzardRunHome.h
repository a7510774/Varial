//
//  BuzzardRunHome.h
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"
#import "BuzzardRunDetails.h"

@interface BuzzardRunHome : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UITabBarDelegate>
{
    CLLocationManager *locationManager;
    NSMutableArray *allBuzzardRunList, *searchList, *nearByList;
    int page,previousPage,searchPage,searchPrevious;
    NSURLSessionDataTask *task;
    NSString *mediaBase;
    BOOL locationUpdated;
}

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong)IBOutlet UITableView *buzzardRunTable;
@property(nonatomic, strong)IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabOne;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabTwo;
@property (weak, nonatomic) IBOutlet UIView  *nearByView, *allBuzzardRunView;
@property (weak, nonatomic) IBOutlet UIButton *nearBySmall;
@property (weak, nonatomic) IBOutlet UIButton *buzzardRun;
@property (weak, nonatomic) IBOutlet UIButton *viewNearByBig;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UITableView *nearByTableView;


-(IBAction)viewNearBy:(id)sender;
-(IBAction)myBuzzardRun:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;
- (IBAction)enableLocationService:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allBuzzardRunBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nearByViewBottom;

@end
