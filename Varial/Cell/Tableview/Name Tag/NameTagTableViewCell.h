//
//  NameTagTableViewCell.h
//  Varial
//
//  Created by Leo Chelliah on 20/02/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameTagTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end
