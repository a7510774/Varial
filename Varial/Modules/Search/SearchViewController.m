//
//  SearchViewController.m
//  Varial
//
//  Created by Leif Ashby on 7/17/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "SearchViewController.h"
#import "FeedsDesign.h"
#import "IQUIView+IQKeyboardToolbar.h"
//#import "FMMosaicLayout.h"

@interface SearchViewController ()
{
    NSString *searchTerm;
    int post_id, recent, selectedPostIndex;
    UIRefreshControl *refreshControl;
    NSMutableArray *feeds;
    AppDelegate *appDelegate;
    
    NSString *mediaBaseUrl;
    NSURLSessionDataTask *task;
    
    FeedsDesign *feedsDesign;
    NSIndexPath *menuPosition;
    int selectedyesNoPopUp;
    KLCPopup *blockPopUp;
    BOOL isLoadMore;
    UIImageView *thumbImage;
}
@property(nonatomic)BOOL isSelectVideoCell;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

//    [self.feedsTable registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
//    [self.feedsTable registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
//    [self.feedsTable registerNib:[UINib nibWithNibName:@"TeamFeedCell" bundle:nil] forCellReuseIdentifier:@"TeamFeedCell"];

    post_id = 0;
    recent = 1;

    [Util setPadding:_searchField];
    
    feedsDesign = [[FeedsDesign alloc] init];
    feeds = [[NSMutableArray alloc] init];
    
    _headerView.delegate = self;
    
   
    
    // setup infinite scrolling
    __weak SearchViewController *feedRefreshSelf = self;
    
    if (_showMediaFullList == YES) {
        _searchViewHeight.constant = 0;
        _searchButton.hidden = YES;
        _mediaListArr =  [[NSMutableArray alloc] init];
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [feedRefreshSelf insertRowAtBottomForMedia];
    }];
    [self.collectionView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
        _searchViewHeight.constant = 40;
        _searchButton.hidden = NO;
        refreshControl = [[UIRefreshControl alloc] init];
        
        [refreshControl addTarget:self
                           action:@selector(getSearchList)
                 forControlEvents:UIControlEventValueChanged];
        [self.collectionView addInfiniteScrollingWithActionHandler:^{
            [feedRefreshSelf insertRowAtBottom];
        }];
        [self.collectionView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    
//    [self.feedsTable addInfiniteScrollingWithActionHandler:^{
//        [feedRefreshSelf insertRowAtBottom];
//    }];
//    [self.feedsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    [_searchField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        self.collectionView.refreshControl = refreshControl;
//        self.feedsTable.refreshControl = refreshControl;
    } else {
        [self.collectionView addSubview:refreshControl];
//        [self.feedsTable addSubview:refreshControl];
    }
    
    [Util createRoundedCorener:_searchField withCorner:3];
    [Util createRoundedCorener:_searchButton withCorner:3];
    [Util createRoundedCorener:_clearButton withCorner:3];
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    float width = size.width / 3 - 1;
    self.flowLayout.itemSize = CGSizeMake(width, width);
    self.flowLayout.minimumInteritemSpacing = 1;
    self.flowLayout.minimumLineSpacing = 1;
    
    isLoadMore = false;
    //Show Ad
    [GoogleAdMob sharedInstance].delegate = self;
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
    
//    FMMosaicLayout *mosaicLayout = [[FMMosaicLayout alloc] init];
//    self.collectionView.collectionViewLayout = mosaicLayout;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
//    [_headerView setHeader:searchTerm];
    [_headerView.logo setHidden:YES];
    
    _searchField.text = searchTerm;
    [_clearButton setHidden:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([feeds count] == 0)
        {
//            [Util addEmptyMessageToTable:self.feedsTable withMessage:PLEASE_LOADING withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
            [Util addEmptyMessageToCollection:self.collectionView withMessage:PLEASE_LOADING withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
        }
    });
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (_showMediaFullList == YES) {
        [self getMediaList];
    }
    else {
        [refreshControl beginRefreshing];
        [self getSearchList];
    }
    
    [super viewDidAppear:animated];
}
- (void)displayAd:(CGFloat)height {
    _bottomMargin.constant = height;
}
- (void)removeAd {
    _bottomMargin.constant = 0;
}



- (void)backPressed {
    if (task != nil) {
        [task cancel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clearClick:(id)sender {
    [_searchField setText:@""];
    [_clearButton setHidden:YES];
}

- (void)textFieldDidChange:(id)sender {
    if([[_searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        if (task != nil) {
            [task cancel];
        }
        [self clearResults];
        searchTerm = _searchField.text;
        [self getSearchList];
        
    } else {
        [_clearButton setHidden:YES];
    }
    
    if ([_searchField.text length] > 0) {
        [_clearButton setHidden:NO];
    }
}

- (void)searchFor:(NSString *)term {
    searchTerm = term;
}

- (void)clearResults {
    [Util addEmptyMessageToCollection:self.collectionView withMessage:PLEASE_LOADING withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
    [feeds removeAllObjects];
    [_collectionView reloadData];
}

- (void)getSearchList {
    [self.view endEditing:YES];
    [self getSearchListWithPostId:@"0" andTimeStamp:@"0"];
}

- (void)getSearchListWithPostId:(NSString *)postId andTimeStamp:(NSString *)timeStamp {
    NSLog(@"getSearchList %@ %@ %@", searchTerm, postId, timeStamp);
    
//    NSString *strPostId = [NSString stringWithFormat:@"%d",post_id];
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:postId forKey:@"post_id"];
    
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"0" forKey:@"recent"];
    [inputParams setValue:timeStamp forKey:@"time_stamp"];
    [inputParams setValue:searchTerm  forKey:@"key_search"];
    [inputParams setValue:self.gIsPresentFeedSearchScreen ? @"custom" :@""  forKey:@"type"];
    
    task = [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_SEARCH withCallBack:^(NSDictionary * response){

        [refreshControl endRefreshing];
//        [self.feedsTable.infiniteScrollingView stopAnimating];
        [self.collectionView.infiniteScrollingView stopAnimating];
        
        if ([[response valueForKey:@"status"] boolValue]) {
            mediaBaseUrl = [response objectForKey:@"media_base_url"];
        
            // If page load and Pull to to refresh -> remove all records and reload the records
            if ([postId isEqualToString:@"0"]) {
                [feeds removeAllObjects];
            }
            [self alterTheMediaList:response];
            //show empty message
            [self addEmptyMessageForFeedListTable];
        }
        else
        {
            UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
            
            if ([navigation isKindOfClass:[UINavigationController class]]) {
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        }
    } isShowLoader:NO];
}

- (void)getMediaList {
    
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
    [inputParams setValue:@"20" forKey:@"page_limit"];
    [inputParams setValue:@"media" forKey:@"type"];
    if (page_number != 0) {
        [inputParams setValue:[NSNumber numberWithInteger:page_number] forKey:@"page_number"];
    }
    
    //    [self.profileTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:GET_POPULAR_VIDEOS withCallBack:^(NSDictionary * response)
     {
         [refreshControl endRefreshing];
         [self.collectionView.infiniteScrollingView stopAnimating];
         
         mediaBaseUrl = [response objectForKey:@"media_base_url"];
         NSString *pageno = [response objectForKey:@"page_number"];
         page_number = [pageno integerValue];
         isLoadMore = true;
         if ((page_number < 0) && [response[@"media_list"] count] == 0) {
             isLoadMore = false;
         }
         if ((_mediaListArr.count == 0) && (isLoadMore = true)) {
             _mediaListArr = response[@"media_list"];
         }
         else if (_mediaListArr.count != 0) {
             
             NSMutableArray *additionalList = [[NSMutableArray alloc]init];
             additionalList = [[response objectForKey:@"media_list"] mutableCopy];
             
             for (int i = 0; i < [additionalList count]; i++) {
                 
                 NSMutableDictionary *dict = [additionalList[i] mutableCopy];
                 [dict setValue:[NSNumber numberWithFloat:0] forKey:@"progress"];
                 _mediaListArr = [_mediaListArr mutableCopy];
                 [_mediaListArr addObject:dict];
             }
             
         }
         feeds = _mediaListArr.mutableCopy;
         [self.collectionView reloadData];
         
     }isShowLoader:NO];
    if (isLoadMore == false) {
        [self.collectionView.infiniteScrollingView stopAnimating];
    }
    
     
}

- (void)insertRowAtBottom {
    
    __weak SearchViewController *feedRefreshSelf = self ;
    int64_t delayInSeconds = 0.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if ([feeds count] != 0) {
            [self loadMoreBottomRow];
        }
        else
        {
            [self getSearchList];
        }
    });
}
- (void)insertRowAtBottomForMedia {
    
    [self.collectionView.infiniteScrollingView stopAnimating];
}
- (void)loadMoreBottomRow {
    
    NSMutableDictionary *lastIndex = [feeds lastObject];
    NSString *strPostId = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"post_id"]];
    NSString *timeStamp = [NSString stringWithFormat:@"%@",[lastIndex objectForKey:@"time_stamp"]];
    
    [self getSearchListWithPostId:strPostId andTimeStamp:timeStamp];
}

- (void)insertRowAtTop {
    
}

// Modifies the actual feed data for rendering
- (void)alterTheMediaList:(NSDictionary *)response{
    
    for (int i = 0; i < [[response objectForKey:@"feed_list"] count]; i++) {
        NSMutableDictionary *dict = [[[response objectForKey:@"feed_list"] objectAtIndex:i] mutableCopy];
        
        [dict setValue:@"false" forKey:@"is_local"];
        [dict setValue:@"true" forKey:@"is_upload"];
        [dict setValue:@"false" forKey:@"isAnimate"];
        [dict setValue:@"true" forKey:@"isEnabled"];
        
        [dict setValue:@"" forKey:@"task_identifier"];
        [dict setValue:@"" forKey:@"task"];
        [dict setValue:@"false" forKey:@"is_resized"];
        [dict setValue:[NSNumber numberWithFloat:0] forKey:@"progress"];
        
        int postIndex = [Util getMatchedObjectPosition:@"post_id" valueToMatch:[dict valueForKey:@"post_id"] from:feeds type:1];
        
        if (![[dict objectForKey:@"is_team_activity"] boolValue] && postIndex == -1) {
            
            if (![[dict objectForKey:@"is_team_activity"] boolValue]) {
                
                NSMutableDictionary *profileImage = [[dict objectForKey:@"posters_profile_image"] mutableCopy];
                [profileImage setValue: [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[profileImage  valueForKey:@"profile_image"]] forKey:@"profile_image"];
                [dict setObject:profileImage forKey:@"posters_profile_image"];
                
                NSMutableArray *mediaList = [[dict valueForKey:@"image_present"] boolValue] ? [[dict objectForKey:@"image"] mutableCopy] : [[dict objectForKey:@"video"] mutableCopy];
                for (int i=0; i<[mediaList count]; i++) {
                    NSMutableDictionary *media = [[mediaList objectAtIndex:i] mutableCopy];
                    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBaseUrl,[media valueForKey:@"media_url"]];
                    [media setValue:imageUrl forKey:@"media_url"];
                    [media setValue:@"true" forKey:@"isEnabled"];
                    [mediaList replaceObjectAtIndex:i withObject:media];
                }
                
                if ([[dict valueForKey:@"image_present"] boolValue]) {
                    [dict setObject:mediaList forKey:@"image"];
                }
                else{
                    [dict setObject:mediaList forKey:@"video"];
                }
            }
            
            // Add response array to the selected feed type
            [feeds addObject:dict];
        }
        else if([[dict objectForKey:@"is_team_activity"] boolValue]){
            
            // Add response array to the selected feed type
            [feeds addObject:dict];
        }
    }
    
    if ([[response objectForKey:@"feed_list"] count] != 0) {
        NSLog(@"alterTheMediaList reloadData %d", [feeds count]);
//        [_feedsTable reloadData];
        [_collectionView reloadData];
    }
}

- (void)addEmptyMessageForFeedListTable {
    if ([feeds count] == 0) {
//        [Util addEmptyMessageToTable:self.feedsTable withMessage:NO_NEWS_FEEDS withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
        [Util addEmptyMessageToCollection:self.collectionView withMessage:NO_NEWS_FEEDS withColor:UIColorFromHexCode(BG_TEXT_COLOR)];
    }
    else{
//        [Util addEmptyMessageToTable:self.feedsTable withMessage:@"" withColor:[UIColor blackColor]];
        [Util addEmptyMessageToCollection:self.collectionView withMessage:@"" withColor:[UIColor blackColor]];
    }
}

// Hide Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Attributed Label delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSString *tag = [[label.text substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    SearchViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController];
    [searchViewController searchFor:tag];
    [self.navigationController pushViewController:searchViewController animated:YES];
}


// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_feedsTable];
        NSIndexPath *path = [_feedsTable indexPathForRowAtPoint:buttonPosition];
        
        if ([feeds count] > path.row) {
            
            NSString *star_post_id = [[feeds objectAtIndex:path.row] objectForKey:@"post_id"];
            if(star_post_id != nil && ![star_post_id isEqualToString:@""]){
                selectedPostIndex = (int) path.row;
//                Comments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
                Comments *comment = [[UIStoryboard storyboardWithName:@"Login"
                                          bundle: nil] instantiateViewControllerWithIdentifier:@"Comments"];
                NSDictionary *imageInfo = [feeds objectAtIndex:path.row];
                comment.postId = star_post_id;
                comment.mediaId = [imageInfo valueForKey:@"image_id"];
                comment.postDetails = [feeds objectAtIndex:path.row];
                comment.isFromFeedsPage = @"YES";
                comment.feeds = feeds;
                [self.navigationController pushViewController:comment animated:YES];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:PERFORM_LATER];
            }
        }
    }
    else{
        [appDelegate.networkPopup show];
    }
}

- (IBAction)Star:(id)sender
{
    [feedsDesign addStar:self.feedsTable fromArray:feeds forControl:sender];
}

- (IBAction)bookmarkBtnTapped:(UIButton*)sender
{
    [feedsDesign addBookmark:self.feedsTable fromArray:feeds forControl:sender];
}

#pragma mark - UITableView Delegates


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [feeds count];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 240;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = nil;
    FeedCell *fcell;
    
    if ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"is_team_activity"] boolValue]) {
        fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:@"TeamFeedCell"];
        if (fcell == nil)
        {
            fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeamFeedCell"];
        }
        
        fcell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        fcell.name.delegate =self;
        NSDictionary *Values = [[feeds objectAtIndex:indexPath.row] objectForKey:@"activity"];
        [Util createTeamActivityLabel:fcell.name fromValues:Values];
        fcell.date.text = [Util timeStamp:[[[feeds objectAtIndex:indexPath.row] objectForKey:@"time_stamp"] longValue]];
        fcell.backgroundColor = [UIColor clearColor];
        
        fcell.menuButton.hidden = YES;
        return fcell;
    }
    else
    {
        if([feeds count] > 0){
            
            static NSString *cellIdentifier = nil;
            cellIdentifier = ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feeds objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"FeedCell" : @"MessagesCell";
            
            fcell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (fcell == nil)
            {
                NSLog(@"Had to make new FeedCell");
                fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
        }
        
        if ([feeds count] > indexPath.row) {
            
            feedsDesign.feeds = feeds;
            feedsDesign.feedTable = tableView;
            feedsDesign.mediaBaseUrl= mediaBaseUrl;
            feedsDesign.viewController = self;
            
            NSLog(@"Design the Container View for %@", indexPath);
            [feedsDesign designTheContainerView:fcell forFeedData:[feeds objectAtIndex:indexPath.row] mediaBase:mediaBaseUrl forDelegate:self tableView:tableView];
        }
        
    }
    fcell.backgroundColor = [UIColor clearColor];
    fcell.menuButton.hidden = YES;
    
    return fcell;
}

#pragma mark - UICollectionView Delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [feeds count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    NSString *cellIdentifier = nil;
    
    if([feeds count] > 0){
        
        cellIdentifier = ([[[feeds objectAtIndex:indexPath.row] objectForKey:@"image_present"] boolValue] || [[[feeds objectAtIndex:indexPath.row] objectForKey:@"video_present"] boolValue])? @"imageCell" : @"textCell";
        
        if (_showMediaFullList == YES) {
            cellIdentifier = @"imageCell";
        }
//        cell = (FeedCell *)[collectionView deq:cellIdentifier];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            NSLog(@"Had to make new FeedCell");
//            fcell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    
    if ([feeds count] > indexPath.row) {
        
        NSDictionary *data = [feeds objectAtIndex:indexPath.row];
        
        // grab element and set data
        if ([cellIdentifier isEqualToString:@"imageCell"]) {
            
            NSString *urlString;
            if ([data objectForKey:@"image"] != nil && [[data objectForKey:@"image"] count] > 0) {
                NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"image"]];
                urlString = [[medias objectAtIndex:0] objectForKey:@"media_url"];
            } else if ([data objectForKey:@"video"] != nil && [[data objectForKey:@"video"] count] > 0) {
                NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"video"]];
                urlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[[medias objectAtIndex:0] objectForKey:@"video_thumb_image_url"]]];
            }
            else if ([data objectForKey:@"media_url"] != nil)  {
//                NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"video"]];
                urlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_image"]]];
            }
            NSLog(@"what is this %@", urlString);
            UIImageView *image = [cell viewWithTag:1];
            [image yy_setImageWithURL:[NSURL URLWithString:urlString] options:YYWebImageOptionProgressiveBlur];
        } else {
            UILabel *label = [cell viewWithTag:1];
            [label setText:[data objectForKey:@"post_content"]];
        }
        
    }
    
    
    
    
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([feeds count] > indexPath.row && _showMediaFullList == NO) {
        NSMutableDictionary *data = [feeds objectAtIndex:indexPath.row];

        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        PostDetails *postDetails = [storyBoard instantiateViewControllerWithIdentifier:@"PostDetails"];
        postDetails.postId = [data valueForKey:@"post_id"];
        postDetails.postDetails = data;
        postDetails.mediaBase = mediaBaseUrl;
//        postDetails.startIndex = index;
//        postDetails.feedTable = tableView;
//        postDetails.previousController = contoller;
//        postDetails.feedsList = sourceArray;
//        postDetails.feedIndex = indexPath.row;
        [self.navigationController pushViewController:postDetails animated:YES];
    }
    else {
        NSMutableDictionary *data = [feeds objectAtIndex:indexPath.row];
        
        NSString *urlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_url"]]];
        NSString *thumbUrl = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",mediaBaseUrl,[data objectForKey:@"media_image"]]];
//         [[[Util sharedInstance] playVideo:urlString withThumb:nil fromController:self withUrl:thumbUrl] play];
        
        
        if (!self.isSelectVideoCell) {
            
            self.isSelectVideoCell = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                self.isSelectVideoCell = NO;
            });
            
            //        [[[Util sharedInstance] playVideo:urlString withThumb:nil fromController:self withUrl:thumbUrl] play];
            
            [self playVideo:urlString withThumb:nil fromController:self withUrl:thumbUrl];
        }
        
    }
}
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.item == _mediaListArr.count -1) && _showMediaFullList == true && isLoadMore == true) {
        
        __weak SearchViewController *feedRefreshSelf = self ;
        int64_t delayInSeconds = 0.0;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self getMediaList];
            
        });
    }
}

//Play video
- (void)playVideo:(NSString *)mediaUrl withThumb:(UIImage *)thumbImg fromController:(UIViewController *)controller withUrl:(NSString *)thumbUrl{
    
    //    NSURL *url = [NSURL URLWithString:mediaUrl];
    
    //Allow landscape orientation
    appDelegate.shouldAllowRotation = TRUE;
    
    //Get player from data source
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:mediaUrl]];
    //    AVPlayer *player = [delegate.moviePlayer objectForKey:mediaUrl];
    // AVPlayer *player = [AVPlayer playerWithURL:url];
    [player setMuted:NO];
    
    appDelegate.currentVideoUrl = mediaUrl;
    
    
    //Create player view controller
    //_playerViewController = [[AVPlayerViewController alloc] init];
    appDelegate.playerViewController.player = nil;
    appDelegate.playerViewController.player = player;
    
    //Assign the thumbimage in player view controller
    //It shows untill the player gets ready
    thumbImage = [[UIImageView alloc] initWithFrame:appDelegate.playerViewController.view.frame];
    if (thumbImg != nil) {
        [thumbImage setImage:thumbImg];
    }
    
    if (thumbUrl != nil) {
        [thumbImage setImageWithURL:[NSURL URLWithString:thumbUrl]];
    }
    
    if (appDelegate.playerViewController.player.currentItem.playbackBufferEmpty) {
        NSLog(@"Buffer Empty");
    }
    
    thumbImage.contentMode = UIViewContentModeScaleAspectFit;
    thumbImage.center = appDelegate.playerViewController.view.center;
    thumbImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [controller presentViewController:appDelegate.playerViewController animated:YES completion:^{
        if ((player.rate != 0) && (player.error == nil)) {
            // player is playing
        }
        else{
            [player play];
        }
    }];
    
}

@end
