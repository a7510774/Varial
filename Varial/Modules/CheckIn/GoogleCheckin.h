//
//  GoogleCheckin.h
//  Varial
//
//  Created by jagan on 13/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "GoogleMap.h"
#import "Config.h"
#import "Util.h"
#import "KLCPopup.h"
#import "CreatePostViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "YesNoPopup.h"
#import "LocationManager.h"
#import "AppDelegate.h"


@interface GoogleCheckin : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,YesNoPopDelegate, HeaderViewDelegate>{
    NSMutableArray *placesList;
    KLCPopup *nearestPopup, *yesNoPopup;
    NSString *name,*city,*state,*country;
    double lat,lang;
    YesNoPopup *popupView;
    AppDelegate *appDelegate;
}
@property (nonatomic) BOOL showPopup;
@property (strong) NSString *isCheckinFromBuzzardRun;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet GoogleMap *googleMap;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
- (IBAction)addCheckin:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIView *searchView;

- (IBAction)clearSearch:(id)sender;

//Nearest Places
@property (weak, nonatomic) IBOutlet UIView *nearestView;
@property (weak, nonatomic) IBOutlet UITableView *nearestTable;
- (IBAction)getNearBy:(id)sender;

//Auto complete
@property (weak, nonatomic) IBOutlet UITableView *placesAutoComplete;



@end
