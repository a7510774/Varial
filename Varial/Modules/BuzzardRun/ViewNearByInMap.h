//
//  ViewNearByInMap.h
//  Varial
//
//  Created by Shanmuga priya on 4/19/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduMap.h"
#import "GoogleMap.h"
#import "BuzzardRunFromShop.h"

@interface ViewNearByInMap : UIViewController<BaiduDelegate,GMSMapViewDelegate>{
    BaiduMap* baiduMap;
    NSMutableArray *nearByList;
    int page;
}
@property (strong) NSString *type;
@property (weak, nonatomic) IBOutlet GoogleMap *googleMap;
@property (weak, nonatomic) IBOutlet UIView *baiduMap;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;


@end
