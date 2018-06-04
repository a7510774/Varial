//
//  SearchViewController.h
//  Varial
//
//  Created by Leif Ashby on 7/17/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "Config.h"
#import "MLKMenuPopover.h"
#import "GoogleAdMob.h"


@interface SearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,
    UICollectionViewDataSource,UICollectionViewDelegate,AdMobDelegate,
    TTTAttributedLabelDelegate,MLKMenuPopoverDelegate,HeaderViewDelegate>
{
    NSInteger page_number ;
}
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *feedsTable;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic,strong) MLKMenuPopover *reportPopover;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (nonatomic) BOOL gIsPresentFeedSearchScreen;

@property(nonatomic) BOOL showMediaFullList;
@property(nonatomic,strong) NSString *channelMediaBaseUrl;
@property(nonatomic, strong) NSMutableArray *mediaListArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewHeight;
- (IBAction)clearClick:(id)sender;

- (void)searchFor:(NSString *)term;

@end
