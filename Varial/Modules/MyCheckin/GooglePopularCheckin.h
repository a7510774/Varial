//
//  GooglePopularCheckin.h
//  Varial
//
//  Created by vis-1674 on 02/09/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMap.h"
#import "LocationManager.h"
#import "MapMarkerWindow.h"
#import <CoreLocation/CoreLocation.h>
#import "GMUMarkerClustering.h"
#import "DGActivityIndicatorView.h"
#import "KNCirclePercentView.h"

@interface GooglePopularCheckin : UIViewController<UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, GMUClusterManagerDelegate>
{
    double lat,lang;
    NSMutableArray *placesList, *nearByLocationsList;
    NSString *name,*city,*state,*country;
    NSString *mediaBase;
    AppDelegate *appDelegate;
    float zoom;
    
    CLLocationCoordinate2D center, topLeft, topRight, bottomLeft, bottomRight;
    double leftLong, rightLong, bottomLat, topLat;
    GMSMarker *currentPosition;
    BOOL gotnearByResponse;
    
    NSURLSessionTask *currentTask;
    
    GMUClusterManager *_clusterManager;
}

// Popular Checkin Google View
@property (weak, nonatomic) IBOutlet GoogleMap *googleMap;
@property (weak, nonatomic) IBOutlet UIButton *nearByPinButton;
- (IBAction)nearByPin:(id)sender;
//Auto complete
@property (weak, nonatomic) IBOutlet UITableView *placesAutoComplete;


@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
- (IBAction)addCheckIn:(UIButton *)sender;

- (IBAction)textChangeListener:(UITextField *)searchBox;
@property (weak, nonatomic) IBOutlet UIView *myViewLoading;
@property (weak, nonatomic) IBOutlet DGActivityIndicatorView *myViewActivityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myConstraintContainerTop;
@property (weak, nonatomic) IBOutlet UILabel *myLabelLoadingMessage;
@property (weak, nonatomic) IBOutlet KNCirclePercentView *myViewShowLoadingPercentage;


@end
