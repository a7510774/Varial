//
//  UITableView+TableViewAnimations.m
//  MyHospitalAdvisor
//
//  Created by anglereit on 16/06/15.
//  Copyright (c) 2015 ANGLER EIT. All rights reserved.
//

#import "UITableView+TableViewAnimations.h"

@implementation UITableView (TableViewAnimations)

- (void)reloadDataWithAnimation {
    
    [self reloadData];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    //[animation setSubtype:kCATransitionReveal];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    //[animation setFillMode:kCAFillModeBoth];
    [animation setDuration:.3];
    [self.layer addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    
}

@end
