//
//  BaiduPopularCheckin.h
//  Varial
//
//  Created by vis-1674 on 01/09/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import "BaiduMap.h"
#import <CoreLocation/CoreLocation.h>
#import "KLCPopup.h"
#import "NetworkAlert.h"
#import "MBProgressHUD.h"
#import "BMMarkerClustering.h"
#import "DGActivityIndicatorView.h"

@interface BaiduPopularCheckin : UIViewController<UITextFieldDelegate, UITabBarDelegate,BaiduDelegate, BMKMapViewDelegate, BMClusterManagerDelegate>
{
    KLCPopup *searchPopup, *listPopup,*networkPopup;
    BaiduMap* baiduMap;
    NSMutableArray *baiduLocationList, *baiduLocationSearchedList, *nearByLocationsList;
    double lat,lang;
    
    NSString *cityValue, *categoryValue;
    MBProgressHUD *progress ;
    
    BOOL isShowListPopup;
    KLCPopupLayout layout;
    NetworkAlert *network;
    BOOL isFirstShown;
    NSDictionary *searchedPlaceInfo;
    BOOL gotNearByResponse,isnearByPin;
    
    BMClusterManager *_clusterManager;
    
}
@property (nonatomic) BOOL homePage;
@property (weak, nonatomic) IBOutlet UIView *mapView, *searchView, *listView;

// Search Popup
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *categeoriesField;
@property (weak, nonatomic) IBOutlet UIButton *baiduLocationSearchButon;
@property (weak, nonatomic) IBOutlet UIButton *cancelSearchButton;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;
- (IBAction)searchBaiduLocation:(id)sender;
- (IBAction)cancelSearchPopUp:(id)sender;


// List Popup

@property (weak, nonatomic) IBOutlet UIButton *listBackButton;
@property (weak, nonatomic) IBOutlet UIButton *listCancel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *locationSearchButton;
@property (weak, nonatomic) IBOutlet UITextField *locationSearchField;
@property (weak, nonatomic) IBOutlet UIButton *locationClearButton;
- (IBAction)listCancelClick:(id)sender;
- (IBAction)listBackClick:(id)sender;
- (IBAction)locationClearClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *nearByButton;
@property (weak, nonatomic) IBOutlet UIView *mapsearchView, *locationSearchView;
-(void)navigateToDetailPage:(NSMutableDictionary*)markerInfo;

@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
- (IBAction)addCheckIn:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *myViewActivity;
@property (weak, nonatomic) IBOutlet DGActivityIndicatorView *myViewActivityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myConstraintContainerTop;



@end
