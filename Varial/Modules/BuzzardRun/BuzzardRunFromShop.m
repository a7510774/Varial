//
//  ViewNearBy.m
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BuzzardRunFromShop.h"
#import "Util.h"
#import "BuzzardRunDetails.h"
#import "LocationManager.h"
#import "Config.h"

@interface BuzzardRunFromShop ()

@end

@implementation BuzzardRunFromShop

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    nearByBuzzardList = [[NSMutableArray alloc] init];
    page = previousPage = 1;
    [self designTheView];
    [self getAllBuzzardRunFromShop];
    [self setInfiniteScrollForTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView
{
    self.buzzardRunTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_headerView setHeader: _shopName != nil ? _shopName : NSLocalizedString(BUZZARD_RUNS, nil)];

    [_headerView.logo setHidden:YES];
    
    _buzzardRunTable.backgroundColor = [UIColor clearColor];
}



//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak BuzzardRunFromShop *weakSelf = self;
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
        __weak BuzzardRunFromShop *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getAllBuzzardRunFromShop];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.buzzardRunTable.infiniteScrollingView stopAnimating];
    }
}


// Check buzzardRun table is empty
-(void)buzzardRunTableIsEmpty
{
    if ([nearByBuzzardList count] == 0)
    {
        [Util addEmptyMessageToTable:self.buzzardRunTable withMessage:NO_BUZZARD_RUN_IN_SHOP withColor:[UIColor whiteColor]];
    }
    else
    {
        [Util addEmptyMessageToTable:self.buzzardRunTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

//Get buzzard run list from shops
-(void) getAllBuzzardRunFromShop{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"]  forKey:@"auth_token"];
    [inputParams setValue:_shopId forKey:@"shop_id"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:NEAR_BY_BUZZARD_RUNS_FROM_SHOP withCallBack:^(NSDictionary * response){
        
        if([[response valueForKey:@"status"] boolValue]){
            
            mediaBase = [response objectForKey:@"media_base_url"];
            [nearByBuzzardList addObjectsFromArray:[[response objectForKey:@"buzzardrun_list"] mutableCopy]];
            [self buzzardRunTableIsEmpty];
            [_buzzardRunTable reloadData];
            page = [[response valueForKey:@"page"] intValue];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } isShowLoader:NO];
    
}



#pragma  args UITableView delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [nearByBuzzardList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"buzzardrun";
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
    UILabel *reward = (UILabel *) [cell viewWithTag:100];
    
    NSDictionary *buzzardRun = [nearByBuzzardList objectAtIndex:indexPath.row];
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[buzzardRun valueForKey:@"buzzardrun_image"]];
    [profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
    //Add zoom
    //[[Util sharedInstance] addImageZoom:profileImage];;
    
    
    name.text = [buzzardRun valueForKey:@"buzzardrun_name"];
    subname.text = [buzzardRun valueForKey:@"shop_name"];
    address.text = [buzzardRun valueForKey:@"buzzardrun_address"];
    reward.text = [buzzardRun valueForKey:@"reward"];
    date.text = [NSString stringWithFormat:@"(%@)",[Util getDate:[[buzzardRun valueForKey:@"valid_timestamp"] longLongValue]]];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([nearByBuzzardList count] > indexPath.row) {
        
        NSDictionary *buzzardRun =[nearByBuzzardList objectAtIndex:indexPath.row];
        
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
