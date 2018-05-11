//
//  PlayerType.h
//  Varial
//
//  Created by jagan on 19/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "YesNoPopup.h"
#import "KLCPopup.h"

@interface PlayerType : UIViewController<UITableViewDataSource,UITableViewDelegate,YesNoPopDelegate>
{
    NSMutableArray *playerTypes;
    KLCPopup *backPopup,*confirmPopup;
    YesNoPopup *backPopupView,*confirmView;
}


@property (strong) NSString *welcomeMessage;

@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UITableView *playerTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

@end
