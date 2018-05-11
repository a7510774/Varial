//
//  AdCell.h
//  Varial
//
//  Created by Leif Ashby on 8/3/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdCell : UITableViewCell

- (void)updateImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) NSDictionary *adInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end
