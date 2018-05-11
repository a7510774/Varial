//
//  MyBuzzardRun.m
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MyBuzzardRun.h"
#import "Util.h"
#import "Config.h"
#import "SVPullToRefresh.h"
#import "BuzzardRunDetails.h"
#import "GoogleAdMob.h"

@interface MyBuzzardRun ()

@end

@implementation MyBuzzardRun

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myBuzzardRun = [[NSMutableArray alloc] init];
    page = previousPage = 1;
    [self designTheView];
    [self setInfiniteScrollForTableView];
    [self getMyByBuzzardRunList];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"isBuzzardRunStatusChanged"];
    
    //Show Ad
    //[[GoogleAdMob sharedInstance] addAdInViewController:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    BOOL isStatusChanged = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isBuzzardRunStatusChanged"] boolValue];
    
    if (isStatusChanged) {
        [myBuzzardRun removeAllObjects];
        page = previousPage = 1;
        [self getMyByBuzzardRunList];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"isBuzzardRunStatusChanged"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView
{
    self.buzzardRunTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_headerView setHeader:NSLocalizedString(MY_BUZZARD_RUN_TITLE, nil)];

    [_headerView.logo setHidden:YES];
    _buzzardRunTable.backgroundColor = [UIColor clearColor];
    
}

// Check buzzardRun table is empty
-(void)buzzardRunTableIsEmpty
{
    if ([myBuzzardRun count] == 0)
    {
        [Util addEmptyMessageToTable:self.buzzardRunTable withMessage:NOT_REGISTERED_BUZZARD withColor:[UIColor whiteColor]];    }
    else
    {
        [Util addEmptyMessageToTable:self.buzzardRunTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}



//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak MyBuzzardRun *weakSelf = self;
    // setup infinite scrolling
    [self.buzzardRunTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.buzzardRunTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak MyBuzzardRun *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getMyByBuzzardRunList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.buzzardRunTable.infiniteScrollingView stopAnimating];
    }
}

//Get buzzard run list
-(void) getMyByBuzzardRunList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page]  forKey:@"page"];
    [_buzzardRunTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:MY_BUZZARD_RUN withCallBack:^(NSDictionary * response){
        [_buzzardRunTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            mediaBase = [response objectForKey:@"media_base_url"];
            page = [[response valueForKey:@"page"] intValue];
            [myBuzzardRun addObjectsFromArray:[[response objectForKey:@"buzzardrun_list"] mutableCopy]];
            [self buzzardRunTableIsEmpty];
            [_buzzardRunTable reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }        
    } isShowLoader:NO];
}


#pragma mark - UITableViewDelegate method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [myBuzzardRun count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"buzzardrun";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:10];
    UILabel *name =  (UILabel *)[cell viewWithTag:11];
    UILabel *subname = (UILabel *) [cell viewWithTag:12];
    UILabel *address = (UILabel *) [cell viewWithTag:13];
    UIImageView *plus = (UIImageView *) [cell viewWithTag:15];
    UIButton *status = (UIButton *) [cell viewWithTag:16];
    UIView *statusView = (UIView *) [cell viewWithTag:17];
    
    [Util createRoundedCorener:statusView withCorner:3.0];
  
    
    NSMutableDictionary *buzzardRun = [[myBuzzardRun objectAtIndex:indexPath.row] mutableCopy];
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[buzzardRun valueForKey:@"buzzardrun_image"]];
    [profileImage  setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
    name.text = [buzzardRun valueForKey:@"buzzardrun_name"];
    subname.text = [buzzardRun valueForKey:@"shop_name"];
    address.text = [buzzardRun valueForKey:@"buzzardrun_address"];
    

//    Registered  - 2
//    Active      - 3
//    Rewarded  - 4
//    Expired  - 5
    int buzzardRunStatus = [[buzzardRun valueForKey:@"buzzarun_status"]intValue];
    if (buzzardRunStatus == 2) {
        [status setTitle:NSLocalizedString(REGISTERED, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:[UIColor blackColor]];
        [plus setImage:[UIImage imageNamed: @"registered.png"]];
        [Util createBorder:statusView withColor:UIColorFromHexCode(THEME_COLOR)];
    }
    else if (buzzardRunStatus == 3){
        [status setTitle:NSLocalizedString(ACTIVE, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:UIColorFromHexCode(THEME_COLOR)];
        [plus setImage:[UIImage imageNamed: @"invited.png"]];
    }
    else if (buzzardRunStatus == 4){
        [status setTitle:NSLocalizedString(REWARDED, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:UIColorFromHexCode(THEME_COLOR)];
        [plus setImage:[UIImage imageNamed: @"friendsTick.png"]];
    }
    else if (buzzardRunStatus == 5){
        [status setTitle:NSLocalizedString(EXPIRED, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:[UIColor blackColor]];
        [plus setImage:[UIImage imageNamed: @"registered.png"]];
        [Util createBorder:statusView withColor:UIColorFromHexCode(THEME_COLOR)];
    }
    
    // [[Util sharedInstance] addImageZoom:profileImage];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([myBuzzardRun count] > indexPath.row) {
        
        NSDictionary *buzzardRun =[myBuzzardRun objectAtIndex:indexPath.row];
        
        BuzzardRunDetails *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"BuzzardRunDetails"];
        detail.buzzardRunId = [buzzardRun valueForKey:@"buzzardrun_id"];
        [self.navigationController pushViewController:detail animated:YES];
    }
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
