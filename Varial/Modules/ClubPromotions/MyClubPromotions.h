//
//  MyClubPromotions.h
//  Varial
//
//  Created by jagan on 29/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface MyClubPromotions :UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSString *mediaBase;
    NSMutableArray *myClubPromotions;
    int page, previousPage;
}

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong)IBOutlet UITableView *clubPromotionsTable;@end
