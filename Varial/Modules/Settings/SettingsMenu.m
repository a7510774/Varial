//
//  SettingsMenu.m
//  Varial
//
//  Created by jagan on 29/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "SettingsMenu.h"
#import "GoogleAdMob.h"
#import "ViewController.h"
#import "LoginOptions.h"

@interface SettingsMenu ()

@end

@implementation SettingsMenu
BOOL havingEmail, havingPhone,isManual = FALSE;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    delegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    [self designTheView];
    [self createPopup];
    
    [_headerView setHeader: NSLocalizedString(SETTINGS_TITLE, nil)];
    [_headerView.logo setHidden:YES];
    
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)createPopup{
    logoutPopup = [KLCPopup popupWithContentView:_logoutView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    logoutPopup.didFinishShowingCompletion = ^{
        isManual = FALSE;
    };
    logoutPopup.didFinishDismissingCompletion = ^{
        if (isManual) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];

            Login *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
            UINavigationController * aNavi = [[UINavigationController alloc]initWithRootViewController:login];
            [[UIApplication sharedApplication] delegate].window.rootViewController = aNavi;
        }
    };
}


-(void) designTheView{  
    [Util createRoundedCorener:_logoutView withCorner:5];
    [Util createRoundedCorener:_logoutButton withCorner:3];
    [Util createRoundedCorener:_cancelLogoutButton withCorner:3];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logout:(id)sender {
    [_logoutView setHidden:NO];
    [logoutPopup show];
}

- (IBAction)cancelLogout:(id)sender {
    [logoutPopup dismiss:YES];
}
- (IBAction)loginOptionBtnTapped:(UIButton *)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle: nil];
    
    LoginOptions *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginOptions"];
    login.gIsPresentSettingsScreen = YES;
    UINavigationController * aNavi = [[UINavigationController alloc]initWithRootViewController:login];
    [self.navigationController pushViewController:aNavi animated:YES];
}

//- (IBAction)tappedLanguageButton:(id)sender {
//    
//    Language *lang = [self.storyboard instantiateViewControllerWithIdentifier:@"Language"];
//    lang.showBackButton = @"TRUE";
//    [self.navigationController pushViewController:lang animated:YES];
//}

- (IBAction)logoutYes:(id)sender {
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:LOGOUT_API withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            isManual = TRUE;
            [logoutPopup dismiss:YES];            
            [Util removeUserData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMemory" object:nil];
        }
        
    } isShowLoader:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = nil;
    if (indexPath.row == 0) {
        identifier = @"Cell1";
    }
    else if (indexPath.row == 1) {
        identifier = @"Cell2";
    }
    else if (indexPath.row == 2) {
        identifier = @"Cell3";
    }
    else if (indexPath.row == 3) {
        identifier = @"Cell4";
    }
    else if (indexPath.row == 4) {
        identifier = @"Cell5";
    }
    else if (indexPath.row == 5) {
        identifier = @"Cell6";
    }
    else if (indexPath.row == 6) {
        identifier = @"Cell7";
    }
    else if (indexPath.row == 7) {
        identifier = @"Cell8";
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *cellLabel = (UILabel *) [cell viewWithTag:100];
    if (IPAD) {
        cellLabel.font = [UIFont fontWithName:@"CenturyGothic" size:18];
    }
    
    return cell;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [collectionView performBatchUpdates:nil completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = collectionView.frame.size.width;
    
    float cellWidth = screenWidth / 4; //Replace the divisor with the column count requirement. Make sure to have it in float.
    float cellHeight = cellWidth < 105 ? 110 : cellWidth;
    cellWidth = cellWidth < 105 ? 105 : cellWidth;
    
    CGSize size = CGSizeMake(cellWidth, cellHeight);
    
    if (IPAD) {
        return CGSizeMake(cellWidth, cellWidth+20);
    }
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
       
        Language *lang = [mainStoryboard instantiateViewControllerWithIdentifier:@"Language"];
        lang.showBackButton = @"TRUE";
        [self.navigationController pushViewController:lang animated:YES];
    }
    else if (indexPath.row == 5) {
        [_logoutView setHidden:NO];
        [logoutPopup show];
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if(IPAD)
    {
        return UIEdgeInsetsMake(50, 0, 50, 0);
    }
    return UIEdgeInsetsMake(25, 0, 25, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (IPAD) {
        return 50;
    }
    return 25;
}

@end
