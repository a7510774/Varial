//
//  MyBuzzardRun.h
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface MyBuzzardRun : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSString *mediaBase;
    NSMutableArray *myBuzzardRun;
    int page, previousPage;
}

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong)IBOutlet UITableView *buzzardRunTable;


@end
