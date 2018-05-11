//
//  NearClubPromotions.h
//  Varial
//
//  Created by jagan on 29/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface NearClubPromotions : UIViewController{
    NSMutableArray *nearByPromotionsList;
    NSString *mediaBase;
    int page,previousPage;
}

@property(strong) NSString *shopId, *shopName;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong)IBOutlet UITableView *clubPromotionTable;


@end
