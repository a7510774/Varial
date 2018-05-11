//
//  Language.h
//  Varial
//
//  Created by jagan on 27/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"
#import "Login.h"
#import "NSBundle+Language.h"
#import "YesNoPopup.h"
#import "HeaderView.h"
#import "AppDelegate.h"
@interface Language : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    }

@property (strong) NSString *showBackButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UITableView *languageTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

@end
