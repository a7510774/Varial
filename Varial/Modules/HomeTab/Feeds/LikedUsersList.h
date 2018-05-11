//
//  LikedUsersList.h
//  Varial
//
//  Created by vis-1674 on 26/08/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "SVPullToRefresh.h"

@interface LikedUsersList : UIViewController<HeaderViewDelegate>
{
    int page;
    NSString *mediaBaseUrl;
    NSMutableArray *likedUsersList;
}

@property (strong) NSString *postId, *mediaId;
@property (nonatomic) BOOL isMediaPost, isShareList;;

@property (weak, nonatomic) IBOutlet UITableView *staredListTable;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

@end
