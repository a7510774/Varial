//
//  TopScrores.h
//  Varial
//
//  Created by jagan on 11/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface TopScrores : UIViewController{
    int page,previousPage;
    NSMutableArray *leaders;
    NSString *mediaBase;
}

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *leaderBoardTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

-(IBAction)searchPlayer:(id)sender;

@end
