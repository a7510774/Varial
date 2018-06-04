//
//  PopularFeedsCollectionViewCell.h
//  Varial
//
//  Created by user on 19/04/2018.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopularFeedsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (weak, nonatomic) IBOutlet UIButton *playIcon;
@property (weak, nonatomic) IBOutlet UIButton *cameraIcon;

@property (weak, nonatomic) IBOutlet UIButton *roundPlayIcon;
//    @property (strong, nonatomic) IBOutlet UIView *videoView;
    @property (strong, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) IBOutlet UIImageView *mainPreview;


@end
