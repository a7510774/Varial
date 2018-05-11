//
//  ChatMenu.h
//  EJabberChat
//
//  Created by jagan on 24/05/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMenu : UIViewController{
    NSMutableArray *titleArray,*imageArray;
}

@property (strong) NSString *receiverName, *receiverID, *teamRelationID;
@property (weak, nonatomic) IBOutlet UICollectionView *chatOptions;

@end
