//
//  MyPaopaoView.h
//  Varial
//
//  Created by Apple on 13/09/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPaopaoView : UIViewController
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIView *arrowView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *snippet;
@property (weak, nonatomic) IBOutlet UIImageView *playIcon;

@property (nonatomic) NSMutableDictionary *userInfo;

@end
