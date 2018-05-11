//
//  MapMarkerWindow.h
//  Varial
//
//  Created by Apple on 10/09/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapMarkerWindow : UIView
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *snippet;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *arrowView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *playIcon;

@end
