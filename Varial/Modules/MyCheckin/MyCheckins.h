//
//  MyCheckins.h
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"
#import "SVPullToRefresh.h"
#import "HeaderView.h"
#import "GoogleMap.h"
#import "LocationManager.h"
#import "BaiduMap.h"
#import <CoreLocation/CoreLocation.h>
#import "MapMarkerWindow.h"

@interface MyCheckins : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate, UITextFieldDelegate, UITabBarDelegate,GMSMapViewDelegate,BaiduDelegate>{
    int page,previousPage;
    NSString *mediaBase,*checkinMediaBase;
    NSURLSessionDataTask *task;
    int searchPage,searchPrevious, selectedTabBar, currentPage;
    NSMutableArray *placesList, *nearByLocationsList;
    NSString *name,*city,*state,*country;
    double lat,lang;
    UIView *poweredView;
    
    BaiduMap* baiduMap;
    NSMutableArray *baiduLocationList, *baiduLocationSearchedList;
    AppDelegate *appDelegate;
    MapMarkerWindow *mapInfoWindow;
    BOOL gotnearByResponse;
    float zoom;
}

- (IBAction)addCheckin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addCheckin;
@property (weak, nonatomic) IBOutlet UITableView *checkinTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabOne;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabTwo;
@property (weak, nonatomic) IBOutlet UIView *myCheckinView, *allCheckInView, *allCheckInBaidu;


@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;

// Popular Checkin Google View
@property (weak, nonatomic) IBOutlet GoogleMap *googleMap;
@property (weak, nonatomic) IBOutlet UIButton *nearByPinButton;
- (IBAction)nearByPin:(id)sender;
//Auto complete
@property (weak, nonatomic) IBOutlet UITableView *placesAutoComplete;


// Popular Checkin Baidu
@property (weak, nonatomic) IBOutlet UIView *popularCheckin_Baidu_SearchPage, *popularCheckin_Baidu_ListPage, *popularCheckin_Baidu_MapPage, *BaiduMapView;

@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *categeoriesField;
@property (weak, nonatomic) IBOutlet UIButton *baiduLocationSearchButon;

@property (weak, nonatomic) IBOutlet UITextField *searchFieldBaidu;
@property (weak, nonatomic) IBOutlet UIButton *searchButtonBaidu;
@property (weak, nonatomic) IBOutlet UIButton *clearButtonBaidu;
- (IBAction)clearClickBaidu:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *placeSearchTableBiadu;

-(IBAction)locationSearchBaidu:(id)sender;

//placeSearchCell


@end
