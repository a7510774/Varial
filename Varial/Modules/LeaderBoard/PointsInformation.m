//
//  PointsInformation.m
//  Varial
//
//  Created by jagan on 11/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "PointsInformation.h"
#import "Util.h"
#import "GoogleAdMob.h"
#import "SVPullToRefresh.h"

@interface PointsInformation ()

@end

@implementation PointsInformation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    points = [[NSMutableArray alloc] init];
    [self setInfiniteScrollForTableView];
    [self designTheView];
    [self getPointsList];
    
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView{
    [_headerView setHeader: NSLocalizedString(POINTS_INFO, nil)];

    _pointsTable.backgroundColor=[UIColor clearColor];
    _pointsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak PointsInformation *weakSelf = self;
    // setup infinite scrolling
    [self.pointsTable addInfiniteScrollingWithActionHandler:^{
        [_pointsTable.infiniteScrollingView stopAnimating];
    }];
    
     [self.pointsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//Get points list
-(void)getPointsList{
   //Send get points list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [_pointsTable.infiniteScrollingView startAnimating];
    if([_pointsFlag isEqualToString:@"1"])
    {
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:POINTS_LIST withCallBack:^(NSDictionary * response){
            [_pointsTable.infiniteScrollingView stopAnimating];
            if([[response valueForKey:@"status"] boolValue]){
                [points addObjectsFromArray:[response objectForKey:@"actions"]];
                [_pointsTable reloadData];
            }
            else{
                
            }
        } isShowLoader:NO];
    }
    else
    {
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_POINTS_LEADER_BOARD withCallBack:^(NSDictionary * response){
            [_pointsTable.infiniteScrollingView stopAnimating];
            if([[response valueForKey:@"status"] boolValue]){
                [points addObjectsFromArray:[response objectForKey:@"actions"]];
                [_pointsTable reloadData];
            }
            else{
                
            }
        } isShowLoader:NO];
    }
}


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [points count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"pointsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    //Read elements
    UILabel *activity = [cell viewWithTag:10];
    UILabel *pointLabel = [cell viewWithTag:11];
    
    //Bind the contents
    NSDictionary *point = [points objectAtIndex:indexPath.row];
    pointLabel.text = [point valueForKey:@"points"];
    activity.text = [point valueForKey:@"action_name"];
    
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
