//
//  OffersList.h
//  Varial
//
//  Created by Shanmuga priya on 3/15/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "SVPullToRefresh.h"

@interface OffersList : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    int page,previousPage;
    NSMutableArray *nearByOfferList;
    NSString *mediaBase;
    
}
@property (nonatomic) NSString *longitute,*latitute, *shopId, *shopName;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
