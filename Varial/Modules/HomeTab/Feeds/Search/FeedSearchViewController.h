//
//  FeedSearchViewController.h
//  Varial
//
//  Created by Leo Chelliah on 04/02/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "Config.h"
#import "MLKMenuPopover.h"
#import "GoogleAdMob.h"
#import "PopularFeedsCollectionViewCell.h"

@class TRMosaicLayout;
@protocol TRMosaicLayoutDelegate;
@interface FeedSearchViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HeaderViewDelegate,UISearchBarDelegate>
{
    NSString * channelStr ;
    NSString * recentSearchStr;
    NSInteger page_number ;
    NSInteger intCountRow ;
    NSInteger intCountBigScreen ;
    AppDelegate *delegate;
     BOOL isLoadMore;
    NSInteger intCountBigScreenForIndexpath;
    NSInteger intCountRowForIndexpath;

}
@property (weak, nonatomic) IBOutlet HeaderView *myHeaderView;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchbar;
@property (weak, nonatomic) IBOutlet UITableView *myTblView;
@property (weak, nonatomic) IBOutlet UIButton *myBtnSearch;
@property (weak, nonatomic) IBOutlet UILabel *myLblRecentSearch;
@property (weak, nonatomic) IBOutlet UILabel *myLblLineSearch;

@property (weak, nonatomic) IBOutlet UITableView *myInfoTblView;
@property (weak, nonatomic) IBOutlet UIButton *myBtnViewAll;
@property (weak, nonatomic) IBOutlet UILabel *myLblChannel;
@property (nonatomic) CGFloat lastContentOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myConstraintHeightRecentSearch;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myConstraintViewAll;



@end
