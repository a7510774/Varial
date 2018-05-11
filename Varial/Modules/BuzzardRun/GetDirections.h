//
//  GetDirections.h
//  Varial
//
//  Created by jagan on 23/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "GoogleMap.h"
#import "BaiduMap.h"

@interface GetDirections : UIViewController<BaiduDelegate,GMSMapViewDelegate>{
     BaiduMap* baiduMap;
}

@property (strong) NSString *isFrom;
@property (strong) NSMutableDictionary *destination;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet GoogleMap *googleMap;
@property (weak, nonatomic) IBOutlet UIView *baiduMap;

@end
