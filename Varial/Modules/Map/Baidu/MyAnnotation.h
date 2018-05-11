//
//  MyAnnotation.h
//  Varial
//
//  Created by jagan on 28/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MyAnnotation : BMKPointAnnotation

@property (nonatomic) NSMutableDictionary *userInfo;
@property (nonatomic) NSString *imageName;
@property (nonatomic) BOOL canShowPopUp;
@property (nonatomic) BMKPinAnnotationColor pinColor;
@property (nonatomic) BOOL animatesDrop,draggable;

@end
