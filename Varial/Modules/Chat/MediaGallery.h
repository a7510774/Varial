//
//  MediaGallery.h
//  EJabberChat
//
//  Created by Shanmuga priya on 5/14/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
@interface MediaGallery : UIViewController
{
    NSMutableDictionary *mediaDictionary;
    NSMutableArray *medias;
}

@property (strong) NSString *receiverName, *receiverID, *receiverImage, *isSingleChat;

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;

@end
