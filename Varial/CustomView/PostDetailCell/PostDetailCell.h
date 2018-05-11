//
//  PostDetailCell.h
//  Varial
//
//  Created by vis-1674 on 04/10/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCircularProgressBarView.h"

@interface PostDetailCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *staredUsersList;
@property (weak, nonatomic) IBOutlet UIView *optionView;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *downloadProgress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaHeight;
@property (weak, nonatomic) IBOutlet UILabel *videoViewCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewCountHeight;
@property (nonatomic) BOOL isVideo;

@end
