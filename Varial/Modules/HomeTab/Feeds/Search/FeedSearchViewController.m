//
//  FeedSearchViewController.m
//  Varial
//
//  Created by Leo Chelliah on 04/02/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "FeedSearchViewController.h"
#import "SearchViewController.h"
#import "SearchHistoryTableViewCell.h"
#import "ChannelTableViewCell.h"
#import "FeedsDesign.h"
#import "OtherVideosTableViewCell.h"
#import "Varial-Swift.h"
#import "JPVideoPlayer.h"
#import "UIView+WebVideoCache.h"
#import "MyCheckinDetails.h"


@import TRMosaicLayout;
@interface FeedSearchViewController ()
<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HeaderViewDelegate,UISearchBarDelegate,TRMosaicLayoutDelegate> {
    NSString *mediaBaseUrl;
    UIImageView *thumbImage;
    BOOL isSelectVideoCell;
    
}
@property(nonatomic, strong)NSMutableArray *myAryInfo, *myAryFilterInfo, *ChannelList;
@property(nonatomic, strong)NSMutableArray *otherVideosList;
@property(nonatomic)BOOL isSelectVideoCell;

@end

@implementation FeedSearchViewController


@synthesize myAryInfo, myAryFilterInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpUI];;
    [self setUpModel];
    [self loadModel];
    
}
- (void)viewWillAppear:(BOOL)animated {
    
    self.myTblView.hidden = YES;
    self.myInfoTblView.hidden = NO;
    self.myLblRecentSearch.text = channelStr;
    self.myBtnViewAll.hidden = NO;
    
    if (_mySearchbar.text.length > 0) {
        self.myTblView.hidden = NO;
        self.myInfoTblView.hidden = YES;
        self.myLblRecentSearch.text = recentSearchStr;
        self.myBtnViewAll.hidden = YES;
    }
//    self.myTblView.hidden = NO;
//    self.myInfoTblView.hidden = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.otherVideosList count] == 0)
        {
            //            [Util addEmptyMessageToTable:self.feedsTable withMessage:PLEASE_LOADING withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
            
            OtherVideosTableViewCell *cell = [self.myInfoTblView cellForRowAtIndexPath:path];
            [Util addEmptyMessageToCollection:cell.collctionView withMessage:PLEASE_LOADING withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
        }
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - View Initialize -

- (void)setUpUI {
    
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    self.myHeaderView.delegate = self;
    [self.myHeaderView setBackHidden:NO];
    [self.myHeaderView setHeader:NSLocalizedString(SEARCH_FEEDS, nil)];
    [self.myHeaderView.logo setHidden:YES];
    _ChannelList = [[NSMutableArray alloc] init];
    _otherVideosList  = [[NSMutableArray alloc] init];
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        channelStr = @"Channels";
        recentSearchStr = @"RECENT SEARCHES";
    }
    
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        channelStr = @"渠道";
        recentSearchStr = @"最近的搜索";
    }
    
    
    
    [self.myTblView registerNib:[UINib nibWithNibName:NSStringFromClass([SearchHistoryTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SearchHistoryTableViewCell class])];
    
    [self.myInfoTblView registerNib:[UINib nibWithNibName:NSStringFromClass([ChannelTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChannelTableViewCell class])];
    
    [self.myInfoTblView registerNib:[UINib nibWithNibName:NSStringFromClass([OtherVideosTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([OtherVideosTableViewCell class])];
    
    
    self.myTblView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.myTblView.tableFooterView = [UIView new];
    self.myTblView.backgroundColor = [UIColor clearColor];
    
    self.myInfoTblView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.myInfoTblView.tableFooterView = [UIView new];
    self.myInfoTblView.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    intCountRow = 0 ;
    intCountBigScreen = 0 ;
    intCountBigScreenForIndexpath = 0;
    intCountRowForIndexpath = 0;
    
    self.myInfoTblView.rowHeight = UITableViewAutomaticDimension;
    // Set the estimatedRowHeight to a non-0 value to enable auto layout.
    self.myInfoTblView.estimatedRowHeight = 280;
    isLoadMore = false;
   // [self setPullToRefresh];
}

- (void)setUpModel {
    
}

- (void)loadModel {
    page_number = 0;
    [self getVideosList];
    [self getSearchHistory];
}

# pragma mark - UITableView Delegate & datasource-

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == _myInfoTblView) {
        return 2;
    }
    if (_myTblView.hidden == NO) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == _myInfoTblView) {
        if (section == 0) {
          NSInteger count =  _ChannelList.count > 0 ?  1  :  0;
            return count;
        }
        else {
            NSInteger count =  _otherVideosList.count > 0 ? 1  :  0;
            return count;
        }
    }
        return myAryInfo.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _myInfoTblView) {
        
        if (indexPath.section == 0) {
            
            ChannelTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([ChannelTableViewCell class])];
            aCell.backgroundColor = [UIColor blueColor];
            aCell.collctionView.delegate = self;
            aCell.collctionView.dataSource = self;
            aCell.collctionView.tag = indexPath.section;
            
            [aCell.collctionView registerNib:[UINib nibWithNibName:NSStringFromClass([PopularFeedsCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([PopularFeedsCollectionViewCell class])];
            
            
            [aCell.collctionView reloadData];
            
            [_myInfoTblView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            
            return aCell;
        }
        else if (indexPath.section == 1) {
            
            OtherVideosTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([OtherVideosTableViewCell class])];
            aCell.backgroundColor = [UIColor blueColor];
            aCell.collctionView.delegate = self;
            aCell.collctionView.dataSource = self;
            aCell.collctionView.tag = indexPath.section;
            
            [aCell.collctionView registerNib:[UINib nibWithNibName:NSStringFromClass([PopularFeedsCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([PopularFeedsCollectionViewCell class])];
           
            if (self.otherVideosList.count <= 118) {
            TRMosaicLayout *layout = [[TRMosaicLayout alloc]init];
            aCell.collctionView.collectionViewLayout = layout;
            [layout setDelegate:self];
            }
            
            aCell.frame = tableView.bounds;
            [aCell layoutIfNeeded];
          //  [aCell.collctionView reloadData];
            aCell.collectionViewHeight.constant =  aCell.collctionView.collectionViewLayout.collectionViewContentSize.height + 210;
            
            
            __weak FeedSearchViewController *feedRefreshSelf = self;
            
            [aCell.collctionView addInfiniteScrollingWithActionHandler:^{
                [feedRefreshSelf insertRowAtBottomForMedia];
            }];
            [aCell.collctionView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            
            [_myInfoTblView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            
            return aCell;
        }
       
    }
        SearchHistoryTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([SearchHistoryTableViewCell class])];
        
        aCell.myLblTitle.text = self.myAryInfo[indexPath.row][@"name"];
        
        return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
    searchViewController.gIsPresentFeedSearchScreen = YES;
    [searchViewController searchFor:self.myAryInfo[indexPath.row][@"name"]];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 1)
    {
        if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
        {
            return @"Recommended";
        }
        else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
        {
            return @"推薦的";
        }
    }
   
    return  @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 4, 320, 21);
    myLabel.font = [UIFont fontWithName:@"Century Gothic" size:15];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor blackColor];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = UIColor.whiteColor;
    [headerView addSubview:myLabel];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1 && self.otherVideosList.count > 2) {
        return 40;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor clearColor];
        headerView.backgroundView.backgroundColor = [UIColor whiteColor];
        
    }
}
#pragma mark - Search Bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
   
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString* newText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    
    if (newText.length > 0) {
        self.myTblView.hidden = NO;
        self.myInfoTblView.hidden = YES;
        self.myBtnViewAll.hidden = YES;
        self.myLblRecentSearch.text = recentSearchStr;
    }
    else {
        self.myTblView.hidden = YES;
        self.myInfoTblView.hidden = NO;
        self.myLblRecentSearch.text = channelStr;
        self.myBtnViewAll.hidden = NO;
    }
    
    return true;
}

#pragma mark  - Funcions
//- (void)insertRowAtBottom {
//
//    __weak FeedSearchViewController *feedRefreshSelf = self ;
//    int64_t delayInSeconds = 0.0;
//
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//
//        if ((19 == self.otherVideosList.count -1) && ([_otherVideosList count] != 0)){
//
//             [self getVideosList];
//        }
//
//
//    });
//}

#pragma mark - API Call

- (void)getSearchHistory {
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    //    [self.profileTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_HISTORY withCallBack:^(NSDictionary * response)
     {
         if([[response valueForKey:@"status"] boolValue]) {
             
             self.myAryInfo = response[@"data"];
         }
         
         if (myAryInfo.count != 0) {
             
             self.myLblLineSearch.hidden = NO;
             self.myLblRecentSearch.hidden = NO;
         }
         
         [self.myTblView reloadData];
         
     } isShowLoader:YES];
}

- (void)getVideosList {
    
    /*
     {"recent":0,"post_id":0,"feed_list_type_key":1,"post_type_id":1,"time_stamp":0,"auth_token":"MTUyMDkyNzcwMDRDMjUxRkM3LTVBMzItNDlDNy1COUQ3LTkzRUU1QjUzNEVCNjIyMTYzNw==","language_code":"en-US"}
     pagination-> page_number, page_limit
     type=media
     */
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [inputParams setValue:[NSNumber numberWithInt:0] forKey:@"recent"];
    [inputParams setValue:[NSNumber numberWithInt:0] forKey:@"post_id"];
    [inputParams setValue:[NSNumber numberWithInt:1] forKey:@"feed_list_type_key"];
    [inputParams setValue:[NSNumber numberWithInt:1] forKey:@"post_type_id"];
    [inputParams setValue:[NSNumber numberWithInt:0] forKey:@"time_stamp"];
    [inputParams setValue:@"en-US" forKey:@"language_code"];
    [inputParams setValue:@"100" forKey:@"page_limit"];
   
    if (page_number != 0) {
    [inputParams setValue:[NSNumber numberWithInteger:page_number] forKey:@"page_number"];
    [inputParams setValue:@"20" forKey:@"page_limit"];
    }
    
    //    [self.profileTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:GET_POPULAR_VIDEOS withCallBack:^(NSDictionary * response)
     {
         //         if([[response valueForKey:@"status"] boolValue]) {
         [self.myInfoTblView.refreshControl endRefreshing];
         
         mediaBaseUrl = [response objectForKey:@"media_base_url"];
         NSString *pageno = [response objectForKey:@"page_number"];
         page_number = [pageno integerValue];
         isLoadMore = true;
         if ((page_number < 0) && [response[@"other_list"] count] == 0) {
             isLoadMore = false;
         }
         
         if ((page_number == 1) && isLoadMore == true) {
             self.ChannelList = response[@"media_list"];
         }
         if (self.otherVideosList.count != 0) {
             
             NSMutableArray *otherList = [[NSMutableArray alloc]init];
             otherList = [[response objectForKey:@"other_list"] mutableCopy];
             
//             "media_image" = "/images/players/22300/post_videos/15720/video_thumbnail_image.jpg";
//             "media_url" = "/images/players/22300/post_videos/15720/1524943966_varial_video_30889.mp4";
//             "post_id" = 15720;
             
             for (int i = 0; i < [otherList count]; i++) {
                 
                 NSMutableDictionary *dict = [otherList[i] mutableCopy];
                 [dict setValue:[NSNumber numberWithFloat:0] forKey:@"progress"];
                // _otherVideosList = [_otherVideosList mutableCopy];
               
                 [_otherVideosList addObject:dict];
                 
               //  isLoadMore = false;

             }
             
         }
         else {
             self.otherVideosList = [response[@"other_list"]mutableCopy];
         }
         
         if (_ChannelList.count != 0) {
             
             self.myLblLineSearch.hidden = YES;
             self.myLblRecentSearch.hidden = NO;
         }
         
         if (_mySearchbar.text.length == 0) {
             self.myLblRecentSearch.text = channelStr;
             self.myBtnViewAll.hidden = NO;
             if (page_number == 1) {
                 [self.myInfoTblView reloadData];
             }
             else {
                 NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
                 OtherVideosTableViewCell *cell = [self.myInfoTblView cellForRowAtIndexPath:path];
                 [cell.collctionView reloadData];
                 [cell.collctionView.infiniteScrollingView stopAnimating];
             }
         }
         else {
             self.myBtnViewAll.hidden = YES;
             self.myLblRecentSearch.text = recentSearchStr;
             [self.myTblView reloadData];
         }
     } isShowLoader:NO];
    
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
    if (_mySearchbar.text.length == 0) {
        
        [HELPER showAlertControllerIn:self message:@"Search text should not be empty"];
        return;
    }
    
    SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
    searchViewController.gIsPresentFeedSearchScreen = YES;
    [searchViewController searchFor:_mySearchbar.text];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        self.myTblView.hidden = YES;
        self.myInfoTblView.hidden = NO;
        self.myLblRecentSearch.text = channelStr;
        self.myLblRecentSearch.hidden = NO;
        self.myBtnViewAll.hidden = NO;
    }
    else {
        self.myTblView.hidden = NO;
        self.myInfoTblView.hidden = YES;
        self.myLblRecentSearch.text = recentSearchStr;
        self.myLblRecentSearch.hidden = YES;
    }
}
#pragma mark - Button Action

- (IBAction)searchBtnTapped:(UIButton *)sender {
    
    [self.view endEditing:YES];
    if (_mySearchbar.text.length == 0) {
        
        [HELPER showAlertControllerIn:self message:@"Search text should not be empty"];
        return;
    }
    
    SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
    searchViewController.gIsPresentFeedSearchScreen = YES;
    searchViewController.showMediaFullList = NO;
    [searchViewController searchFor:_mySearchbar.text];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (IBAction)viewAllBtnTapped:(UIButton *)sender {
    
//    if (_ChannelList.count > 0) {
//
//        [self getVideosList:true];
//    }
        SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
        
        searchViewController.gIsPresentFeedSearchScreen = YES;
        searchViewController.showMediaFullList = YES;
        [self.navigationController pushViewController:searchViewController animated:YES];
        return ;
}

#pragma mark - UICollectionView Delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView.tag == 0) {
        return [_ChannelList count];
    }
    return [_otherVideosList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    PopularFeedsCollectionViewCell *aCell= [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PopularFeedsCollectionViewCell class]) forIndexPath:indexPath];
    
    NSDictionary *data ;
    
    NSString *urlString;
    
    
    
    if (collectionView.tag == 0) {
        
        data = [_ChannelList objectAtIndex:indexPath.row];
        
        
        
        if ([data objectForKey:@"media_url"] != nil)  {
            
            urlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_image"]]]; //@"media_image"
            
        }//media_url
        
        NSLog(@"what is this %@", urlString);
        
        
        
        aCell.cameraIcon.hidden = YES;
        
        aCell.playIcon.hidden = NO;
        
        aCell.roundPlayIcon.hidden = YES;
        
        
        
        
        
        aCell.imgView.layer.cornerRadius = 6;
        
        aCell.imgView.clipsToBounds = YES;
        
        [aCell.imgView yy_setImageWithURL:[NSURL URLWithString:urlString] options:YYWebImageOptionProgressiveBlur];
        
        return  aCell;
        
    }
    
    else {
        
        data = [_otherVideosList objectAtIndex:indexPath.row];
        
        
        
        if ([data objectForKey:@"media_url"] != nil)  {
            
            urlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_image"]]]; //@"media_image"
            
        }//media_url
        
        NSLog(@"what is this %@", urlString);
        
        NSString *videoUrlString ;
        
        videoUrlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_url"]]];
        
        AVPlayer *player = nil;
        
        BOOL isBigScreen;
        
        
        
        if (indexPath.row == 0) {
            
            
            
            isBigScreen = true;
            
            
            
            intCountRowForIndexpath = 11;
            
            intCountBigScreenForIndexpath = 11;
            
        }
        
        
        else if  (indexPath.row == intCountRowForIndexpath) {
            
            if (intCountBigScreenForIndexpath == 11) {
                
                
                
                intCountBigScreenForIndexpath = 7;
                
                intCountRowForIndexpath = intCountRowForIndexpath + 7;
                
            }
            
            else if (intCountBigScreenForIndexpath == 7) {
                
                
                
                intCountBigScreenForIndexpath = 11;
                
                intCountRowForIndexpath = intCountRowForIndexpath + 11;
                
            }
            
            
            isBigScreen = true;
            
        }
        
        else {
            
            isBigScreen = false;
            
        }
        
        
        
        
        
        
        
        if (aCell.bounds.size.height > 250) {
            
            
            
            aCell.videoView.hidden = NO;
            
            aCell.mainPreview.hidden = NO;
            
            aCell.imgView.hidden = YES;
            
            NSLog(@"what is this %@", urlString);
            
            NSString *videoUrlString ;
            
            videoUrlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_url"]]];
            
            
            
            NSURL *videoUrl = [[NSURL alloc] initWithString:videoUrlString];
            
            
            
            
            
            NSURL *url = [NSURL URLWithString:videoUrlString];
            
            
            
            
            
            BOOL isSameVideo = [aCell.videoUrl isEqualToString:videoUrlString];
            
            if (isSameVideo) {
                
                NSLog(@"Same video to play");
                
            }
            
            
            
            aCell.videoUrl = videoUrlString;
            
            if ([delegate.moviePlayer objectForKey:videoUrlString] != nil) {
                
                player = [delegate.moviePlayer objectForKey:videoUrlString];
                
                NSLog(@"got existing player");
                
            }
            
            else {
                
                player = [AVPlayer playerWithURL:url];
                
                if(player != nil && player.currentItem != nil)
                    
                {
                    
                    [delegate.moviePlayer setValue:player forKey:videoUrlString];
                    
                    [delegate.videoUrls addObject:videoUrlString];
                    
                    
                    
                    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
                    
                    //[player addObserver:self forKeyPath:@"status" options:0 context:nil];
                    
                }
                
            }
            
            
            
            //        [player setMuted:NO];
            
            
            
            //        dispatch_async( dispatch_get_main_queue(), ^{
            
            
            
            // Different video or has no video layer
            
            aCell.videoUrl = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_url"]]];
            
            if (!isSameVideo || [aCell.mainPreview.layer.sublayers count] == 0) {
                
                NSLog(@"Making an AVPlayerLayer %d %d", isSameVideo, (int)[aCell.imgView.layer.sublayers count]);
                
                
                
                AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                
                
                
                
                
                
                
                [aCell.mainPreview.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
                
                
                
                videoLayer.frame = aCell.bounds;//CGRectMake(0, 0, aCell.mainPreview.frame.size.width, aCell.mainPreview.frame.size.height);
                
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                
                aCell.mainPreview.frame = aCell.bounds;
                
                [aCell.mainPreview.layer addSublayer:videoLayer];
                
            }
            
            [aCell.videoView setHidden:YES];
            
            [player setMuted:YES];
            
            player.actionAtItemEnd = AVPlayerActionAtItemEndNone; dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
                
                // dispatch_async( dispatch_get_main_queue(), ^{
                
                [player play];
                
                // });
                
            });
            
            
            
            
            
            aCell.playIcon.hidden = YES;
            
            aCell.cameraIcon.hidden = YES;
            
            aCell.roundPlayIcon.hidden = NO;
            
        }
        
        else {
            
            aCell.videoView.hidden = YES;
            
            aCell.mainPreview.hidden = YES;
            
            aCell.imgView.hidden = NO;
            
            aCell.cameraIcon.hidden = NO;
            
            aCell.imgView.layer.cornerRadius = 0;
            
            aCell.roundPlayIcon.hidden = YES;
            
            aCell.playIcon.hidden = YES;
            
            [aCell.imgView yy_setImageWithURL:[NSURL URLWithString:urlString] options:YYWebImageOptionProgressiveBlur];
            
        }
        
    }
    
    
    
    
    
    return aCell;
    
    
    
    
    
}


- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
   if ((indexPath.item == self.otherVideosList.count - 1) && isLoadMore == true) {
        
        __weak FeedSearchViewController *feedRefreshSelf = self ;
        int64_t delayInSeconds = 0.0;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
          //  [self getVideosList];
            
        });
    }
   else if ((indexPath.item == self.otherVideosList.count - 2) && isLoadMore == true) {
       
       __weak FeedSearchViewController *feedRefreshSelf = self ;
       int64_t delayInSeconds = 0.0;
       
       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         //  [self getVideosList];
           
       });
   }
} //((indexPath.item == self.otherVideosList.count - 2) ||

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat aCollectionViewCellHeight = self.view.frame.size.width/4;
    CGFloat ContentOffsetMaxY = scrollView.contentOffset.y + scrollView.bounds.size.height ;
    CGFloat contentHeight = scrollView.contentSize.height ;
    BOOL ret = ContentOffsetMaxY > contentHeight;
    
    if(scrollView.contentOffset.y > aCollectionViewCellHeight) {
        
        _myConstraintViewAll.constant = 0.0;
        _myConstraintHeightRecentSearch.constant = 0.0;
        [_myBtnViewAll setTitle:@"" forState:UIControlStateNormal];
    }
    
    else {
        
        _myConstraintViewAll.constant = 21.0;
        _myConstraintHeightRecentSearch.constant = 21.0;
        [_myBtnViewAll setTitle:@"View all" forState:UIControlStateNormal];
    }
    
    if (ret) {
        NSLog(@"test show");
        
        if (isLoadMore == true) {
            
            isLoadMore = false;
            [self getVideosList];
        }
    }
    
    else {
        NSLog(@"test Hidden");
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (collectionView.tag == 0) {
        return CGSizeMake(self.view.frame.size.width / 4 , self.view.frame.size.width / 4) ;
    }
    
    return  CGSizeMake(self.view.frame.size.width / 3 , self.view.frame.size.width / 3);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *data;
    if (collectionView.tag == 0) {
        data = [_ChannelList objectAtIndex:indexPath.row];
    }
    else {
        data = [_otherVideosList objectAtIndex:indexPath.row];
    }
//    NSString *urlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_url"]]];
//    NSString *thumbUrl = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_image"]]];
    
    //NSURL *aURL = [NSURL URLWithString:[thumbUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    //UIImage *aImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:aURL]];
    

//    [[[Util sharedInstance] playVideo:urlString withThumb:nil fromController:self withUrl:thumbUrl] play];
    

    if (!self.isSelectVideoCell) {
        
        self.isSelectVideoCell = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            self.isSelectVideoCell = NO;
        });
        
//        [[[Util sharedInstance] playVideo:urlString withThumb:nil fromController:self withUrl:thumbUrl] play];
        
//        [self playVideo:urlString withThumb:nil fromController:self withUrl:thumbUrl];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        
        MyCheckinDetails *details = [mainStoryboard instantiateViewControllerWithIdentifier:@"MyCheckinDetails"];
        details.post_Id = [data objectForKey:@"post_id"];
        details.isPopularCheckinDetail = @"NO";
        details.isFromChannel = YES;
        [self.navigationController pushViewController:details animated:YES];
    }
}


//- (void)collectionView:(UICollectionView *)collectionView
//  didEndDisplayingCell:(UICollectionViewCell *)cell
//    forItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    BOOL isBigScreen;
//
//    if (indexPath.row == 0) {
//
//        isBigScreen = true;
//
//        intCountRowForIndexpath = 11;
//        intCountBigScreenForIndexpath = 11;
//    }
//
//
//    else if  (indexPath.row == intCountRowForIndexpath) {
//
//        if (intCountBigScreenForIndexpath == 11) {
//
//            intCountBigScreenForIndexpath = 7;
//            intCountRowForIndexpath = intCountRowForIndexpath + 7;
//        }
//
//
//        else if (intCountBigScreenForIndexpath == 7) {
//
//            intCountBigScreenForIndexpath = 11;
//            intCountRowForIndexpath = intCountRowForIndexpath + 11;
//        }
//
//        isBigScreen = true;
//
//    }
//
//    else {
//
//        isBigScreen = false;
//
//    }
//
//    if (isBigScreen == true) {
//
//        PopularFeedsCollectionViewCell *feedCell = (PopularFeedsCollectionViewCell* )cell;
//
//        AVPlayer *player = [delegate.moviePlayer objectForKey:feedCell.videoUrl];
//        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
//
//            [player pause];
//
//        });
//
//
//    }
//
//}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView.tag == 0) {
         return UIEdgeInsetsMake(2, 2, 2, 2);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    if (collectionView.tag == 0) {
        return 4;
    }
    return 0;
}

- (CGFloat)heightForSmallMosaicCell {
    
    return 150;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(TRMosaicLayout *)collectionViewLayout insetAtSection:(NSInteger)insetAtSection {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (enum TRMosaicCellType)collectionView:(UICollectionView *)collectionView mosaicCellSizeTypeAtIndexPath:(NSIndexPath *)indexPath {
    
   
    BOOL isBigScreen;

    
//    if (indexPath.row == 0) {
//
//        isBigScreen = true;
//
//        intCountRow = 11;
//        intCountBigScreen = 11;
//    }
//
//
//    else if  (indexPath.row == intCountRow) {
//
//        if (intCountBigScreen == 11) {
//
//            intCountBigScreen = 7;
//            intCountRow = intCountRow + 7;
//        }
//
//
//        else if (intCountBigScreen == 7) {
//
//            intCountBigScreen = 11;
//            intCountRow = intCountRow + 11;
//        }
//
//        isBigScreen = true;
//
//    }
//
//    else {
//
//        isBigScreen = false;
//
//    }
    
   isBigScreen = [self isBigScreen:indexPath];
    return isBigScreen ? TRMosaicCellTypeBig : TRMosaicCellTypeSmall;
    
}
- (BOOL) isBigScreen:(NSIndexPath *) currentIndexpath  {
    
     BOOL isBigScreen;
    
    if (currentIndexpath.row == 0) {
        
        isBigScreen = true;
        
        intCountRow = 11;
        intCountBigScreen = 11;
    }
    
    
    else if  (currentIndexpath.row == intCountRow) {
        
        if (intCountBigScreen == 11) {
            
            intCountBigScreen = 7;
            intCountRow = intCountRow + 7;
        }
        
        
        else if (intCountBigScreen == 7) {
            
            intCountBigScreen = 11;
            intCountRow = intCountRow + 11;
        }
        
        isBigScreen = true;
        
    }
    
    else {
        
        isBigScreen = false;
        
    }
    return isBigScreen;
}

- (BOOL)playeVideoFromTheCell:(UICollectionViewCell *)cell :(NSURL* )videoUrl{
    
    if([cell isKindOfClass:[PopularFeedsCollectionViewCell class]])
    {
        PopularFeedsCollectionViewCell *feedCell = (PopularFeedsCollectionViewCell* )cell;
        AVPlayer *player = [delegate.moviePlayer objectForKey:videoUrl];
        if (player != nil) {
            
            //Check if video has already in play state
            if (player.rate != 0) {
                return true;
            }
            
            //            if(feedCell.isVideo){
            //                [feedCell.playIcon setHidden:YES];
            //                [feedCell.activityIndicator setHidden:NO];
            //            }
            
            //Play current vide
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
                // dispatch_async( dispatch_get_main_queue(), ^{
                [player play];
                // });
            });
            
            return true;
        }
    }
    return false;
}

- (void)insertRowAtBottomForMedia {
    
    if (isLoadMore == false) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
        OtherVideosTableViewCell *cell = [self.myInfoTblView cellForRowAtIndexPath:path];
        [cell.collctionView.infiniteScrollingView stopAnimating];
    }
}

#pragma mark AV player

// Will be called when AVPlayer finishes playing playerItem
-(void)itemDidFinishPlaying:(NSNotification *) notification {
    NSLog(@"itemDidFinishPlaying");
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //    });
    
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
    
    AVAsset *currentPlayerAsset = playerItem.asset;
    NSString *videoUrl = [(AVURLAsset* )currentPlayerAsset URL].absoluteString;
    
    AVPlayer *player = [delegate.moviePlayer objectForKey:videoUrl];
    [player setMuted: YES];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        [player play];
    });
    
    if (delegate.currentVideoUrl != nil && [videoUrl isEqualToString:delegate.currentVideoUrl]) {
        [delegate.playerViewController dismissViewControllerAnimated:YES completion:nil];
        delegate.currentVideoUrl = nil;
    }
    
    
}
-(void)stopAllVideos{
    NSMutableDictionary *movieDictionary = [delegate.moviePlayer copy];
    for (NSString* key in movieDictionary) {
        AVPlayer *player = [movieDictionary objectForKey:key];
        //  dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        if(player != nil){
            [player pause];
        }
        //  });
    }
}

- (void)setPullToRefresh {
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    //[self.mytable addSubview:refreshControl];
    self.myInfoTblView.refreshControl = refreshControl;
}

-(void)refreshData
{
    page_number = 0;
    self.otherVideosList = [self.otherVideosList mutableCopy];
    self.otherVideosList = [[NSMutableArray alloc]init];
    [self getVideosList];
}

//Play video
- (void)playVideo:(NSString *)mediaUrl withThumb:(UIImage *)thumbImg fromController:(UIViewController *)controller withUrl:(NSString *)thumbUrl{
    
    //    NSURL *url = [NSURL URLWithString:mediaUrl];
    
    //Allow landscape orientation
    delegate.shouldAllowRotation = TRUE;
    
    //Get player from data source
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:mediaUrl]];
//    AVPlayer *player = [delegate.moviePlayer objectForKey:mediaUrl];
    // AVPlayer *player = [AVPlayer playerWithURL:url];
    [player setMuted:NO];
    
    delegate.currentVideoUrl = mediaUrl;
    
    
    //Create player view controller
    //_playerViewController = [[AVPlayerViewController alloc] init];
    delegate.playerViewController.player = nil;
    delegate.playerViewController.player = player;
    
    //Assign the thumbimage in player view controller
    //It shows untill the player gets ready
    thumbImage = [[UIImageView alloc] initWithFrame:delegate.playerViewController.view.frame];
    if (thumbImg != nil) {
        [thumbImage setImage:thumbImg];
    }
    
    if (thumbUrl != nil) {
        [thumbImage setImageWithURL:[NSURL URLWithString:thumbUrl]];
    }
    
    if (delegate.playerViewController.player.currentItem.playbackBufferEmpty) {
        NSLog(@"Buffer Empty");
    }
    
    thumbImage.contentMode = UIViewContentModeScaleAspectFit;
    thumbImage.center = delegate.playerViewController.view.center;
    thumbImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
   
    [controller presentViewController:delegate.playerViewController animated:YES completion:^{
        if ((player.rate != 0) && (player.error == nil)) {
            // player is playing
        }
        else{
            [player play];
        }
    }];
    
}

@end


