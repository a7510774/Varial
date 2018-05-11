//
//  SearchHistoryViewController.h
//  Varial
//
//  Created by Leo Chelliah on 04/02/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface SearchHistoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet HeaderView *myHeaderView;
@property (weak, nonatomic) IBOutlet UITableView *myTblView;

@end
