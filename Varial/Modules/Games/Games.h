//
//  Games.h
//  Varial
//
//  Created by vis-1674 on 29/04/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface Games : UIViewController
{
    
}

@property(nonatomic, strong)NSMutableArray *array;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property(nonatomic, strong) UIButton *hit_list, *one_on_one_skate;

-(IBAction)hitList:(id)sender;
-(IBAction)oneSkate:(id)sender;

@end
