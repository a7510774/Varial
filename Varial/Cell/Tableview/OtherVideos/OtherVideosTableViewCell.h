//
//  OtherVideosTableViewCell.h
//  Varial
//
//  Created by Dreams004 on 23/04/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherVideosTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *collctionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

@end
