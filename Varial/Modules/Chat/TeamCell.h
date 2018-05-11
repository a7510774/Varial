//
//  TeamCell.h
//  Varial
//
//  Created by vis-1674 on 05/07/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileImage.h"

@interface TeamCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *teamMame;
@property (weak, nonatomic) IBOutlet ProfileImage *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *captainName;
@property (weak, nonatomic) IBOutlet UIImageView *captainSymbol;
@property (weak, nonatomic) IBOutlet UILabel *rank;

@end
