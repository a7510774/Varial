//
//  ChatCell.h
//  Varial
//
//  Created by vis-1674 on 05/07/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileImage.h"

@interface ChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ProfileImage *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIImageView *chatImage;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *badge;
@property (weak, nonatomic) IBOutlet UILabel *typingLabel;

@end
