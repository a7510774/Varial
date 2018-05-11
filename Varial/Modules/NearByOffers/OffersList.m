//
//  OffersList.m
//  Varial
//
//  Created by Shanmuga priya on 3/15/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "OffersList.h"
#import "ShopDetails.h"
@interface OffersList ()

@end

@implementation OffersList

- (void)viewDidLoad {
    [super viewDidLoad];
    page = previousPage = 1;
    [self designTheView];
    [self setInfiniteScrollForTableView];
    [self reloadList];
    // Do any additional setup after loading the view.
}

- (void)designTheView
{
    [_headerView setHeader: NSLocalizedString(_shopName, nil)];

    [_headerView.logo setHidden:YES];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Reload the offer list
- (void) reloadList{
    //reload the page once we back to this page
    page = previousPage = 1;
    [nearByOfferList removeAllObjects];
    [self getShopOffers];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)getShopOffers{
    
    //Send offer list from shop request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [inputParams setValue:_shopId forKey:@"shop_id"];
    
    [self.tableView.infiniteScrollingView startAnimating];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:OFFERS_FROM_SHOPS withCallBack:^(NSDictionary * response){
        [self.tableView.infiniteScrollingView stopAnimating];
        if([[response valueForKey:@"status"] boolValue]){
            page = [[response valueForKey:@"page"]intValue];
            if(mediaBase == nil)
                mediaBase = [response valueForKey:@"media_base_url"];
            nearByOfferList=[response objectForKey:@"offers_list"];
            [_tableView reloadData];
            [self addEmptyMessage];
        }
        else{
            
        }
    } isShowLoader:NO];
    
    
}

//Add empty message in table background view
- (void)addEmptyMessage{
    
    if ([nearByOfferList count] == 0) {
        [Util addEmptyMessageToTable:_tableView withMessage:NO_OFFER_FOUND_FROM_SHOP withColor:[UIColor whiteColor]];
    }
    else{
        [Util addEmptyMessageToTable:_tableView withMessage:@"" withColor:[UIColor whiteColor]];
    }
}



//Add infinite scroll
- (void) setInfiniteScrollForTableView;
{
    __weak OffersList *weakSelf = self;
    // setup infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    [self.tableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

//Add load more items
- (void)insertRowAtBottom {
    if(page > 0 && page != previousPage){
        NSLog(@"LOADING MORE CONTENTS...!");
        __weak OffersList *weakSelf = self;
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            previousPage = page;
            [weakSelf getShopOffers];
        });
    }
    else{
        NSLog(@"NO MORE CONTENTS...!");
        [self.tableView.infiniteScrollingView stopAnimating];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [nearByOfferList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"offerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIImageView *profile = (UIImageView *)[cell viewWithTag:10];
    UILabel *title =  (UILabel *)[cell viewWithTag:11];
    UILabel *description = (UILabel *) [cell viewWithTag:12];
    UILabel *timeStamp = (UILabel *) [cell viewWithTag:13];
    
    
    NSDictionary *offerList = [nearByOfferList objectAtIndex:indexPath.row];
    title.text = [offerList valueForKey:@"offer_name"];
//    /description.text = [offerList valueForKey:@"offer_description"];
    
//    NSString *desc = [offerList valueForKey:@"offer_description"];
//    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithData:[desc dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont fontWithName:@"CenturyGothic" size:15], NSFontAttributeName,
//                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
//    [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString.string length] - 1)];
    
   NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(VIEW_DETAILS, nil)];
    
//    [attributed addAttribute:NSUnderlineStyleAttributeName
//                       value:[NSNumber numberWithInt:1]
//                       range:(NSRange){0,[attributed length]}];
    
    description.attributedText = attributed;  // [offerList valueForKey:@"offer_description"];
    timeStamp.text = [NSString stringWithFormat:NSLocalizedString(@"Valid Upto %@", nil) ,[Util getDate:[[offerList valueForKey:@"valid_timestamp"] longValue]]];
    NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[offerList valueForKey:@"shop_image"]];
    
    [profile setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
    
    [[Util sharedInstance] addImageZoom:profile];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *offer = [nearByOfferList objectAtIndex:indexPath.row];
    ShopDetails *shopDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ShopDetails"];
    shopDetail.offerId = [offer valueForKey:@"offer_id"];
    [self.navigationController pushViewController:shopDetail animated:YES];
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
