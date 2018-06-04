//
//  SearchHistoryViewController.m
//  Varial
//
//  Created by Leo Chelliah on 04/02/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "SearchHistoryViewController.h"
#import "Util.h"
#import "SearchHistoryTableViewCell.h"

@interface SearchHistoryViewController () <UITableViewDelegate,UITableViewDataSource,HeaderViewDelegate>

@property(nonatomic, strong)NSMutableArray *myAryInfo;

@end

@implementation SearchHistoryViewController

@synthesize myAryInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];;
    [self setUpModel];
    [self loadModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - View Initialize -


- (void)setUpUI {
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    self.myHeaderView.delegate = self;
    [self.myHeaderView setBackHidden:NO];
    [self.myHeaderView setHeader:NSLocalizedString(TITLE_SEARCH_HISTORY, nil)];
    [self.myHeaderView.logo setHidden:YES];
    
    self.myTblView.delegate = self;
    self.myTblView.dataSource = self;
    
    [self.myTblView registerNib:[UINib nibWithNibName:NSStringFromClass([SearchHistoryTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SearchHistoryTableViewCell class])];
    
    self.myTblView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.myTblView.tableFooterView = [UIView new];
    
    self.myTblView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setUpModel {
    
    myAryInfo = [NSMutableArray new];
}

- (void)loadModel {
    
    [self getSearchHistory];
}

# pragma mark - UITableView Delegate & datasource-

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return myAryInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchHistoryTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([SearchHistoryTableViewCell class])];
    
    aCell.myLblTitle.text = self.myAryInfo[indexPath.row][@"name"];
    
    return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)getSearchHistory {
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    //    [self.profileTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:SEARCH_HISTORY withCallBack:^(NSDictionary * response)
     {
         if([[response valueForKey:@"status"] boolValue]) {
             
             self.myAryInfo = response[@"data"];
         }
         
         [self.myTblView reloadData];
         
         if ([myAryInfo count] == 0) {
             
             [Util addEmptyMessageToTableWithHeader:self.myTblView withMessage:@"No Search History" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
         }
         
     } isShowLoader:YES];
}
- (IBAction)clearHistoryAction:(id)sender {
    [self clearSearchHistory];
}

- (void)clearSearchHistory {
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:@"0" forKey:@"id"];
    
    //    [self.profileTable.infiniteScrollingView startAnimating];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:CLEAR_SEARCH_HISTORY withCallBack:^(NSDictionary * response)
     {
         if([[response valueForKey:@"status"] boolValue]) {
             
             myAryInfo = [NSMutableArray new];
             [Util addEmptyMessageToTableWithHeader:self.myTblView withMessage:@"No Search History" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
             [self.myTblView reloadData];
         }
         
     } isShowLoader:YES];
}

@end
