//
//  MainMenu.m
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MainMenu.h"
#import "LeaderBoard.h"
#import "TopScrores.h"
#import "Games.h"

@interface MainMenu ()

@end

@implementation MainMenu
BOOL canShowClub,canShowShopping,canShowGames,canShowOffers,canShowLeaderboard,canShowClubPromotion;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    canShowClub = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_participate_in_clubpromotion"];
    canShowShopping = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_show_shoping"];
    canShowGames = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_show_games"];
    canShowOffers = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_show_offers"];
    canShowLeaderboard = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_show_leaderboard"];
    canShowClubPromotion = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_show_club_promotions"];

    menus = [[NSMutableArray alloc] initWithObjects:@"Cell1",@"Cell2",@"Cell3",@"Cell4",@"Cell5",@"Cell6",@"Cell7",@"Cell8",@"Cell9",@"Cell10", nil];
    
    //Remove shoping
    if (!canShowLeaderboard) {
        [menus removeObject:@"Cell4"];
    }
    if (!canShowOffers) {
        [menus removeObject:@"Cell5"];
    }
    if (!canShowShopping) {
        [menus removeObject:@"Cell6"];
    }
    if (!canShowClub || !canShowClubPromotion) {
        [menus removeObject:@"Cell7"];
    }
    if (!canShowGames) {
        [menus removeObject:@"Cell9"];
    }
    
  //  [self showMenu: menus];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openProfile:)];
    [_profileImage setUserInteractionEnabled:YES];
    [_profileImage addGestureRecognizer:tap];

}

- (void) didDisplayAd:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat height =[[userInfo objectForKey:@"height"] floatValue];
    _menuContainerBottom.constant = height;
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AdShown" object:nil];

}
- (void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AdShown" object:nil];
}

//Tap gesture recognizer for image
- (void) openProfile:(UITapGestureRecognizer *)tapRecognizer {
    [self showMyProfile:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisplayAd:) name:@"AdShown" object:nil];
    
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
    
    //Check for name and image update
    BOOL isNameChanged = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isNameChanged"] boolValue];
    BOOL isImageChanged = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isImageChanged"] boolValue];
    [_profileHeader setHidden:YES];
    [_profileImage setHidden:YES];
    
    if (isNameChanged || isImageChanged) {
        //[self getProfileInfo];
    }
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"ProfileInfo"];
    if (dict != nil) {
        [self profileHeaderInfo:dict];
    }
    [self getProfileInfo];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMyProfile:(id)sender {
    
    if([[Util sharedInstance] getNetWorkStatus])
    {
        MyProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
        [self.navigationController pushViewController:profile animated:YES];
    }
    else{
        [appDelegate.networkPopup show];
    }
}

-(void) getProfileInfo
{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_PLAYER_INFORMATION withCallBack:^(NSDictionary * response)
     {
         if([[response valueForKey:@"status"] boolValue]){
             
             [Util setInDefaults:response withKey:@"ProfileInfo"];
             [self profileHeaderInfo:response];
         }
         
     } isShowLoader:NO];
}


-(void)profileHeaderInfo:(NSDictionary *)response
{
    [_profileHeader setHidden:NO];
    [_profileImage setHidden:NO];
    
    mediaBase = [response objectForKey:@"media_base_url"];
    NSDictionary *details=[[NSDictionary alloc]init];
    
    details=[response objectForKey:@"player_details"];
    
    
    if ([Util getFromDefaults:@"user_name"] != nil) {
        _name.text= [Util getFromDefaults:@"user_name"];
    }
    else
    {
        _name.text= [details objectForKey:@"name"];
    }
    
    _pointsValue.text=[NSString stringWithFormat:@"%@: %@",NSLocalizedString(POINTS, nil),[details objectForKey:@"leader_board_points"]];
    _rankValue.text= [Util playerType:[[details objectForKey:@"player_type_id"] intValue] playerRank:[details objectForKey:@"rank"]];
    
    NSDictionary *proDetails=[details objectForKey:@"player_image_detail"];
    NSString *strURL = [NSString stringWithFormat:@"%@%@",mediaBase,[proDetails  objectForKey:@"profile_image"]];
    [_profileImage setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    //Add zoom
    //[[Util sharedInstance] addImageZoom:_profileImage];
    
    NSString *board = [NSString stringWithFormat:@"%@%@",mediaBase,[details valueForKey:@"skate_board_image"]];
    _profileImage.layer.cornerRadius = _profileImage.frame.size.height/2 ;
    _profileImage.clipsToBounds = true;
    _profileImage.layer.borderColor = UIColorFromHexCode(THEME_COLOR).CGColor;
    _profileImage.layer.borderWidth = 2.0;
    [_boardImage setImageWithURL:[NSURL URLWithString:board] placeholderImage:nil];
    NSLog(@"Hiiiiiii :%f", _boardImage.frame.size.height);
    
    [_activityIndicator setHidden:YES];
    
    if (IPAD) {
        _pointsValue.font = [UIFont fontWithName:@"CenturyGothic" size:17];
        _name.font = [UIFont fontWithName:@"CenturyGothic" size:20];
        _rankValue.font = [UIFont fontWithName:@"CenturyGothic" size:17];
    }else{
        _pointsValue.font = [UIFont fontWithName:@"CenturyGothic" size:16];
        _name.font = [UIFont fontWithName:@"CenturyGothic" size:17];
        _rankValue.font = [UIFont fontWithName:@"CenturyGothic" size:16];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [menus count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    NSString *identifier = [menus objectAtIndex:indexPath.row];
    
    if (![identifier isEqualToString:@""])
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *cellLabel = (UILabel *) [cell viewWithTag:100];
        UIButton *cellButton = (UIButton *) [cell viewWithTag:101];
        cellButton.userInteractionEnabled = YES;
        //cellLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        cellLabel.numberOfLines = 2;
        
        if (IPAD) {
            cellLabel.font = [UIFont fontWithName:@"CenturyGothic" size:17];
        }else{
            cellLabel.font = [UIFont fontWithName:@"CenturyGothic" size:14];
        }
        
        if ([identifier isEqualToString:@"Cell10"])
        {
            cellButton.userInteractionEnabled = NO;
        }
    }
    
    
    return cell;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_collectionView performBatchUpdates:nil completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = _collectionView.frame.size.width;
    
    float cellWidth = screenWidth / 4; //Replace the divisor with the column count requirement. Make sure to have it in float.
    
    float cellHeight;
    
    // 3.5 inch and 4 inch screen
    if (screenWidth == 320.0) {
        cellHeight = cellWidth < 105 ? 110 : cellWidth;
        cellWidth = cellWidth < 105 ? 105 : cellWidth;
        cellHeight = 110;
    }
    else{
        cellHeight = cellWidth < 120 ? 120 : cellWidth;
        cellWidth = cellWidth < 115 ? 115 : cellWidth;
    }
    CGSize size = CGSizeMake(cellWidth, cellHeight);
    
    if (IPAD) {
        return CGSizeMake(cellWidth, cellWidth+15);
    }
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedIndex = [menus objectAtIndex:indexPath.row];
    
    // Cell10 is an FAQ
    if ([selectedIndex isEqualToString:@"Cell10"]) {
        [self showFAQ];
    }
   
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if(IPAD)
    {
       return UIEdgeInsetsMake(50, 2, 50, 2);
    }
    
    return UIEdgeInsetsMake(15, 0, 15, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (IPAD) {
        return 50;
    }
    return 5;
}

-(void)showMenu :(NSMutableArray *)arrayMenu
{
    if ([arrayMenu count] == 4) {
        [menus insertObject:@"" atIndex:2];
    }
}

-(void)showFAQ
{
    NSString *launchUrl;
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        launchUrl = @"https://www.varialskate.com/faq.php?lang_code=en-US";
    }
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        launchUrl = @"https://www.varialskate.com/faq.php?lang_code=zh";
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}

@end
