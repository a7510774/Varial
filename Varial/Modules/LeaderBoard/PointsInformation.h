//
//  PointsInformation.h
//  Varial
//
//  Created by jagan on 11/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface PointsInformation : UIViewController{
    NSMutableArray *points;
    
}
@property (nonatomic) NSString *pointsFlag;
@property (weak, nonatomic) IBOutlet UITableView *pointsTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

@end
