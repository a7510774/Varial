//
//  ShowCheckinInMap.h
//  Varial
//
//  Created by jagan on 25/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "GoogleMap.h"
#import "BaiduMap.h"

@interface ShowCheckinInMap : UIViewController <BaiduDelegate>{
    BaiduMap* baiduMap;
}


@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet GoogleMap *googleMapView;
@property (weak, nonatomic) IBOutlet UIView *baiduMapView;

@property (strong) NSString *checkinName, *latitude, *longitude;

@end

