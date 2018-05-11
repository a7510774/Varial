//
//  BuyPointsViewController.m
//  Varial
//
//  Created by jagan on 18/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BuyPointsViewController.h"

@interface BuyPointsViewController ()

@end

@implementation BuyPointsViewController

int selectedPointIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self designTheView];
    selectedPointIndex = -1;
    pointsList = [[NSMutableArray alloc]init];
    
    [self reloadList];
    //Register for set email notifacation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processTransaction:) name:@"TransactionCompleted" object:nil];
}

- (void)viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TransactionCompleted" object:nil ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView{
    
    [_headerView.logo setHidden:YES];
    [_headerView setHeader:NSLocalizedString(BUY_POINT, nil)];

    
    //Set transparent color to tableview
    [self.pointsTable setBackgroundColor:[UIColor clearColor]];
    self.pointsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//Cancel the email change request
- (void)processTransaction:(NSNotification*)notification {
    
    if (notification.userInfo != nil) {
        
        //Transaction details
        SKPaymentTransaction *transaction = [notification.userInfo objectForKey:@"transaction"];
        NSString *reciept = transaction.transactionReceipt.base64Encoding;
        
        if ([pointsList count] > selectedPointIndex) {
            
            //Build Input Parameters
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            NSDictionary *pointData = [pointsList objectAtIndex:selectedPointIndex];
            [inputParams setValue:[pointData valueForKey:@"point_id"] forKey:@"point_id"];
            [inputParams setValue:reciept forKey:@"receipt_id"];
            [inputParams setValue:transaction.transactionIdentifier forKey:@"transaction_id"];
            
            NSString *endUrl = BUY_POINTS;
            if (_isTeamBuy) {
                [inputParams setValue:_teamId forKey:@"team_id"];
                endUrl = TEAM_BUY_POINTS;
            }
            
            [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:endUrl withCallBack:^(NSDictionary * response){
                
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"] withDuration:3];
                
                
            } isShowLoader:YES];
        }
        
    }
    selectedPointIndex = -1;
    [_pointsTable reloadData];
    
}

//Reload the list while receiving a notification
- (void) reloadList{
    //reload the page once we back to this page
    page = 1;
    [self getPointsList];
    [self setInfiniteScrollForTableView];
    
}

//Add empty message in table background view
- (void)addEmptyMessage{
    
    if ([pointsList count] == 0) {
        [Util addEmptyMessageToTable:_pointsTable withMessage:NO_PRODUCT withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:_pointsTable withMessage:@"" withColor:[UIColor whiteColor]];
    }
}

//Get points list
-(void)getPointsList{
    
    //Send get points list request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:BUY_POINTS_LIST withCallBack:^(NSDictionary * response){
        [self.pointsTable.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            page = [[response valueForKey:@"page"] intValue];
            [pointsList addObjectsFromArray:[response objectForKey:@"list_buy_point"]];
            [_pointsTable reloadData];
            [self addEmptyMessage];
        }
        else{
            
        }
    } isShowLoader:NO];
}


//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak BuyPointsViewController *weakSelf = self;
    // setup infinite scrolling
    [self.pointsTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.pointsTable.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    
    if(page > 0){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak BuyPointsViewController *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf getPointsList];
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
    return [pointsList count];
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
    UIImageView *icon = [cell viewWithTag:12];
    UILabel *points = [cell viewWithTag:10];
    UILabel *price = [cell viewWithTag:11];
    
    selectedPointIndex == indexPath.row ?
    [icon setImage:[UIImage imageNamed:@"selectedPts.png"]] :
    [icon setImage:[UIImage imageNamed:@"selectPts.png"]] ;
    
    //Bind data
    NSDictionary *point = [pointsList objectAtIndex:indexPath.row];
    points.text = [point valueForKey:@"points"];
    price.text = [point valueForKey:@"price"];

    return cell;
    
}


//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    selectedPointIndex = (int) indexPath.row;
    [tableView reloadData];
    
    NSMutableDictionary *point = [pointsList objectAtIndex:indexPath.row];
    
    if ([point valueForKey:@"product_id"] != nil) {
        
        if ([[InAppPurchaseManager sharedInstance] canMakePurchases]) {
            [[InAppPurchaseManager sharedInstance] purchaseProduct:[point valueForKey:@"product_id"]];
        }else{
            // Show alert
            [[Util sharedInstance] showInAppAlert];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
