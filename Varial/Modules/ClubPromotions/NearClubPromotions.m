//
//  NearClubPromotions.m
//  Varial
//
//  Created by jagan on 29/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "NearClubPromotions.h"
#import "Util.h"
#import "ClubPromotionsDetails.h"
#import "LocationManager.h"
#import "SVPullToRefresh.h"

@interface NearClubPromotions ()

@end

@implementation NearClubPromotions

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    nearByPromotionsList = [[NSMutableArray alloc] init];
    [self designTheView];
    [self getAllNearByPromotions];
    [self setInfiniteScrollForTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView
{
    page = previousPage = 1;
    _clubPromotionTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_headerView setHeader:NSLocalizedString(_shopName, nil)];

    [_headerView.logo setHidden:YES];
    
    _clubPromotionTable.backgroundColor = [UIColor clearColor];
}

// Check buzzardRun table is empty
-(void)buzzardRunTableIsEmpty
{
    if ([nearByPromotionsList count] == 0)
    {
        [Util addEmptyMessageToTable:_clubPromotionTable withMessage:NO_CLUB_PROMOTION withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:_clubPromotionTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak NearClubPromotions *weakSelf = self;
    // setup infinite scrolling
    [_clubPromotionTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [_clubPromotionTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak NearClubPromotions *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getAllNearByPromotions];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [_clubPromotionTable.infiniteScrollingView stopAnimating];
    }
}

//Get buzzard run list
-(void) getAllNearByPromotions{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    //[inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].latitude] forKey:@"latitude"];
    //[inputParams setValue:[NSString stringWithFormat:@"%f",[LocationManager sharedManager].longitude] forKey:@"longitude"];
    [inputParams setValue:_shopId forKey:@"shop_id"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SHOP_CLUB_PROMOTIONS withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            mediaBase = [response objectForKey:@"media_base_url"];
            [nearByPromotionsList addObjectsFromArray:[[response objectForKey:@"shop_club_promotion_list"] mutableCopy]];
            [self buzzardRunTableIsEmpty];
            [_clubPromotionTable reloadData];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }        
    } isShowLoader:NO];
}


#pragma  args UITableView delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [nearByPromotionsList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"clubPromotion";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:10];
    UILabel *name =  (UILabel *)[cell viewWithTag:11];
    UILabel *subname = (UILabel *) [cell viewWithTag:12];
    UILabel *address = (UILabel *) [cell viewWithTag:13];
    UILabel *date = (UILabel *) [cell viewWithTag:14];
    UILabel *free_bies = (UILabel *) [cell viewWithTag:100];
    
    NSDictionary *buzzardRun = [nearByPromotionsList objectAtIndex:indexPath.row];
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[buzzardRun valueForKey:@"shop_image"]];
    [profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
    //Add zoom
    [[Util sharedInstance] addImageZoom:profileImage];;
    
    
    name.text = [buzzardRun valueForKey:@"club_promotion_name"];
    subname.text = [buzzardRun valueForKey:@"shop_name"];
    address.text = [buzzardRun valueForKey:@"club_promotion_address"];
    date.text = [NSString stringWithFormat:@"(%@)",[Util getDate:[[buzzardRun valueForKey:@"club_promotion_vaild_upto"] longLongValue]]];
    free_bies.text = [buzzardRun valueForKey:@"free_bies"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *promotion = [nearByPromotionsList count] > indexPath.row ? [nearByPromotionsList objectAtIndex:indexPath.row] : nil;
    
    if (promotion != nil) {
        ClubPromotionsDetails *promotionDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"ClubPromotionsDetails"];
        promotionDetails.promotionId = [promotion valueForKey:@"club_promotion_id"];
        [self.navigationController pushViewController:promotionDetails animated:YES];
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
