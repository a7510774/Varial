//
//  MyClubPromotions.m
//  Varial
//
//  Created by jagan on 29/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MyClubPromotions.h"
#import "Util.h"
#import "Config.h"
#import "SVPullToRefresh.h"
#import "ClubPromotionsDetails.h"

@interface MyClubPromotions ()

@end

@implementation MyClubPromotions

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myClubPromotions = [[NSMutableArray alloc] init];
    page = previousPage = 1;
    [self designTheView];
    [self getMyByClubPromotionList];
    [self setInfiniteScrollForTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView
{
    _clubPromotionsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_headerView setHeader:NSLocalizedString(MY_CLUB_PROMOTION_TITLE, nil)];

    [_headerView.logo setHidden:YES];
    _clubPromotionsTable.backgroundColor = [UIColor clearColor];
    
}

// Check buzzardRun table is empty
-(void)buzzardRunTableIsEmpty
{
    if ([myClubPromotions count] == 0)
    {
        [Util addEmptyMessageToTable:_clubPromotionsTable withMessage:NOT_REGISTERED_CLUB_PROMOTIONS withColor:[UIColor whiteColor]];    }
    else
    {
        [Util addEmptyMessageToTable:_clubPromotionsTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}



//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak MyClubPromotions *weakSelf = self;
    // setup infinite scrolling
    [_clubPromotionsTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [_clubPromotionsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak MyClubPromotions *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getMyByClubPromotionList];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [_clubPromotionsTable.infiniteScrollingView stopAnimating];
    }
}

//Get buzzard run list
-(void) getMyByClubPromotionList{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page]  forKey:@"page"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:MY_CLUP_PROMOTIONS withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            mediaBase = [response objectForKey:@"media_base_url"];
            page = [[response valueForKey:@"page"] intValue];
            [myClubPromotions addObjectsFromArray:[[response objectForKey:@"my_club_promotion_list"] mutableCopy]];
            [self buzzardRunTableIsEmpty];
            [_clubPromotionsTable reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:NO];
}


#pragma mark - UITableViewDelegate method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [myClubPromotions count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"clubPromotion";
    
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
    
    
    NSMutableDictionary *buzzardRun = [[myClubPromotions objectAtIndex:indexPath.row] mutableCopy];
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[buzzardRun valueForKey:@"shop_image"]];
    [profileImage  setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
    name.text = [buzzardRun valueForKey:@"club_promotion_name"];
    subname.text = [buzzardRun valueForKey:@"shop_name"];
    address.text = [buzzardRun valueForKey:@"club_promotion_address"];
    
    int buzzardRunStatus = [[buzzardRun valueForKey:@"players_club_status"]intValue];
    if (buzzardRunStatus == 1) {
        [status setTitle:NSLocalizedString(REGISTER, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:[UIColor blackColor]];
        [plus setImage:[UIImage imageNamed: @"registered.png"]];
        [Util createBorder:statusView withColor:UIColorFromHexCode(THEME_COLOR)];
    }
    else if (buzzardRunStatus == 2){
        [status setTitle:NSLocalizedString(REGISTERED, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:UIColorFromHexCode(THEME_COLOR)];
        [plus setImage:[UIImage imageNamed: @"invited.png"]];
    }
    else if (buzzardRunStatus == 3){
        [status setTitle:NSLocalizedString(COMPLETED, nil) forState:UIControlStateNormal];
        [statusView setBackgroundColor:UIColorFromHexCode(THEME_COLOR)];
        [plus setImage:[UIImage imageNamed: @"friendsTick.png"]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ClubPromotionsDetails *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"ClubPromotionsDetails"];
    detail.promotionId = [[myClubPromotions objectAtIndex:indexPath.row] objectForKey:@"club_promotion_id"];
    [self.navigationController pushViewController:detail animated:YES];
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
