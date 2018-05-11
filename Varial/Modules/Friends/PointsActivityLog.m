//
//  PointsActivityLog.m
//  Varial
//
//  Created by jagan on 17/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "PointsActivityLog.h"

@interface PointsActivityLog ()

@end

@implementation PointsActivityLog
NSMutableArray *pointsActivityLogList;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pointsActivityLogList = [[NSMutableArray alloc] init];
    page = previousPage = 1;
    
    refreshControl = [[UIRefreshControl alloc] init];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        self.pointsTable.refreshControl = refreshControl;
    } else {
        [self.pointsTable addSubview:refreshControl];
    }
    [refreshControl addTarget:self
                       action:@selector(reloadList)
             forControlEvents:UIControlEventValueChanged];

    [refreshControl beginRefreshing];
    [self designTheView];
    [self reloadList];
    [self setInfiniteScrollForTableView];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidUnload{
    
}


- (void)designTheView{
    
    [_headerView.logo setHidden:YES];
    [_headerView setHeader: NSLocalizedString(POINTS_LOG, nil)];
    
    
    //Set transparent color to tableview
    [self.pointsTable setBackgroundColor:[UIColor clearColor]];
    self.pointsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) reloadList{
    //reload the page once we back to this page
    page = previousPage = 1;
    [pointsActivityLogList removeAllObjects];
    [self getPointsActivityList];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)getPointsActivityList{
    
    //Send points activity log list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
//    [self.pointsTable.infiniteScrollingView startAnimating];
    
    NSString *url = POINTS_ACTIVITY_LOG;
    if (_teamId != nil) {
        url = TEAM_ACTIVITY_LOG;
        [inputParams setValue:_teamId forKey:@"team_id"];
    }
    else{
        [inputParams setValue:_friendId forKey:@"friend_id"];
    }
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:url withCallBack:^(NSDictionary * response){
//        [self.pointsTable.infiniteScrollingView stopAnimating];
        [refreshControl endRefreshing];
        if([[response valueForKey:@"status"] boolValue]){
            page = [[response valueForKey:@"page"]intValue];
            if(mediaBase == nil)
                mediaBase = [response valueForKey:@"media_base_url"];
            if (_teamId != nil) {
                [pointsActivityLogList addObjectsFromArray:[response objectForKey:@"team_points_activity_log"]];
            }else{
                [pointsActivityLogList addObjectsFromArray:[response objectForKey:@"points_activity_log"]];
            }
            [_pointsTable reloadData];
            [self addEmptyMessage];
        }
        else{
            
        }
    } isShowLoader:NO];
}


//Add empty message in table background view
- (void)addEmptyMessage{
    
    if ([pointsActivityLogList count] == 0) {
        [Util addEmptyMessageToTable:_pointsTable withMessage:NO_POINTS_LOG withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
    else{
        [Util addEmptyMessageToTable:_pointsTable withMessage:@"" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
    }
}




//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
//    [self.pointsTable addPullToRefreshWithActionHandler:^{
//        
//    } position:SVPullToRefreshPositionTop];
    
    __weak PointsActivityLog *weakSelf = self;
    // setup infinite scrolling
    [self.pointsTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.pointsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak PointsActivityLog *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getPointsActivityList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.pointsTable.infiniteScrollingView stopAnimating];
    }
}



#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pointsActivityLogList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"pointsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //Read elements
    UIImageView *image = [cell viewWithTag:10];
    UILabel *title = [cell viewWithTag:11];
    UILabel *date = [cell viewWithTag:12];
    
    if([pointsActivityLogList count] > indexPath.row)
    {
        NSDictionary *list = [pointsActivityLogList objectAtIndex:indexPath.row];
        
        //Add zoom
        //[[Util sharedInstance] addImageZoom:image];
        
        //Bind the values into elements
        title.text = [list valueForKey:@"message"];
        date.text = [Util timeStamp:[[list valueForKey:@"time_stamp"] longValue]];
        NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[list valueForKey:@"profile_image"]];
        
        [image setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    }
    return cell;
    
}


//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

@end
