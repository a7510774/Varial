//
//  GeneralNotification.h
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"
#import "UIImageView+AFNetworking.h"
#import "RedirectNotification.h"
#import "SVPullToRefresh.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "TeamViewController.h"
#import "YesNoPopup.h"
#import "KLCPopup.h"
#import "AppDelegate.h"


@interface GeneralNotification : UIViewController
{
    AppDelegate *appDelegate;
}

@property (nonatomic, assign) int page;
@property (weak, nonatomic) IBOutlet UITableView *generalTable;
@property (weak, nonatomic) IBOutlet UIView *popularCheckin;


@end
