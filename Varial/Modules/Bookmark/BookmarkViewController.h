//
//  BookmarkViewController.h
//  Varial
//
//  Created by dreams on 11/01/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkViewController : UIViewController

{
    int selectedPostIndex;
    NSMutableDictionary * cellHeightsDictionary;
}
@property (strong)  NSString  *gStrSource, *gStrFriendId;
@property (weak, nonatomic) IBOutlet UITableView *myTblView;

@end
