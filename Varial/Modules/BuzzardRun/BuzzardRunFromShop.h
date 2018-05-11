//
//  BuzzardRunFromShop.h
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface BuzzardRunFromShop : UIViewController{
    NSMutableArray *nearByBuzzardList;
    NSString *mediaBase;
    int page, previousPage;
}

@property (strong) NSString *shopId, *shopName;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong)IBOutlet UITableView *buzzardRunTable;

@end
