//
//  SettingsMenu.h
//  Varial
//
//  Created by jagan on 29/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"
#import "HeaderView.h"
#import "KLCPopup.h"
#import "AppDelegate.h"

@interface SettingsMenu : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>{
    KLCPopup *logoutPopup;
    IBOutlet UICollectionView *collectionView ;
    AppDelegate *delegate;
}
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

- (IBAction)logout:(id)sender;


//Logout
@property (weak, nonatomic) IBOutlet UIView *logoutView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelLogoutButton;
- (IBAction)logoutYes:(id)sender;
- (IBAction)cancelLogout:(id)sender;



@end
