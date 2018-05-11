//
//  FriendsCell.h
//  Varial
//
//  Created by vis-1674 on 05/07/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileImage.h"
#import "Board.h"

@interface FriendsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ProfileImage *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *rank;
@property (weak, nonatomic) IBOutlet Board *skateBoard;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@end
