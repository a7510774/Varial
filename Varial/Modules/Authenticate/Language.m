//
//  Language.m
//  Varial
//
//  Created by jagan on 27/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Language.h"
#import "ViewController.h"
#import "SettingsMenu.h"
#import "IQKeyboardManager.h"

@interface Language ()

@end

@implementation Language

NSMutableArray *languages;
NSString *currentLanguage;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    languages = [[NSMutableArray alloc] initWithObjects:@{@"flag":@"china.png",@"code":@"zh",@"title":@"中文"}, @{@"flag":@"usa.png",@"code":@"en-US",@"title":@"English"},nil];
    [self designTheView];
}

- (void)viewDidAppear:(BOOL)animated{
    currentLanguage = [Util getFromDefaults:@"language"];
    [self.languageTable reloadData];
    [self.languageTable setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.languageTable setHidden:YES];
}

- (void)designTheView{
    
    [_headerView setHeader:NSLocalizedString(SELECT_LANGUAGE, nil)];

     _headerView.back.hidden = _showBackButton != nil ? NO : YES;
    if(_showBackButton == nil){
        _headerView.chatIcon.hidden = YES;
    }
    //Parralax animation
    CGRect frame = self.backgroundImage.frame;
    frame.origin.y = -60;
    self.backgroundImage.frame = frame;
    _backgroundImage.clipsToBounds = YES;
    [[Util sharedInstance] animateTheImage:self.backgroundImage withHeight:ANIMATION_HEIGHT];
    [self.backgroundImage.layer removeAllAnimations];
    
    
    //Set transparent color to tableview
    [self.languageTable setBackgroundColor:[UIColor clearColor]];
    self.languageTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [languages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"languageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    //Read elements
    UIImageView *flag = [cell viewWithTag:10];
    UILabel *title = [cell viewWithTag:11];
    UIImageView *status = [cell viewWithTag:12];
    
    //Bind the contents
    NSDictionary *lang = [languages objectAtIndex:indexPath.row];
    [flag setImage:[UIImage imageNamed:[lang valueForKey:@"flag"]]];
    title.text = [lang valueForKey:@"title"];
    
    
    if([[lang valueForKey:@"code"] isEqualToString:currentLanguage]){
        [status setImage:[UIImage imageNamed:@"checkboxCheckedIcon"]];
    }
    else{
        [status setImage:[UIImage imageNamed:@"checkboxIcon"]];
    }
    
    return cell;
    
}

//Add click event to table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (languages != nil && [languages count] > indexPath.row) {
        
        tableView.userInteractionEnabled = FALSE;
        
        //Set current language in session
        NSDictionary *lang = [languages objectAtIndex:indexPath.row];
        [Util setInDefaults:[lang valueForKey:@"code"] withKey:@"language"];
  //      [Util setInDefaults:[lang valueForKey:@"code"] withKey:@"country_code"];
        
        //set current langugae
        currentLanguage = [lang valueForKey:@"code"];
        [IQKeyboardManager load];
        
        //Change the app language
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[lang valueForKey:@"code"] , nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize] ;
        
        //Move to login screen
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [NSBundle setLanguage:[lang valueForKey:@"code"]];
        
        //Update the row
        [tableView reloadData];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            if(_showBackButton){
                
                //Build Input Parameters
                NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
                [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
                [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_LANGUAGE withCallBack:^(NSDictionary * response)
                 {
                     if([[response valueForKey:@"status"] boolValue]){
                         
                         UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
                         [UIApplication sharedApplication].delegate.window.rootViewController=navigation;
                         
                         //Remove feed type list
                         ViewController *viewController =[self.navigationController.viewControllers firstObject];
                         [viewController setCurrentPage:3];
                         [viewController.tabBar setSelectedItem:viewController.tabFour];
                         [viewController.feedTypeList removeAllObjects];
                         [viewController createEmailAlertView];
                         
                         //Remove the feeds
                         [viewController.popularFeeds removeAllObjects];
                         [viewController.publicFeeds removeAllObjects];
                         [viewController.privateFeeds removeAllObjects];
                         [viewController.friendsFeeds removeAllObjects];
                         [viewController.teamAFeeds removeAllObjects];
                         [viewController.teamBFeeds removeAllObjects];
                         
                         UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle: nil];
                         
                         SettingsMenu *setting = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsMenu"];
                         [navigation setViewControllers:@[viewController,setting]];
                         [UIApplication sharedApplication].delegate.window.rootViewController = navigation;
                         
                         // Recreate the popup
                         AppDelegate *appDelegate = [[AppDelegate alloc] init];
                         [appDelegate createPopups];
                         
                         [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                     }
                     
                 } isShowLoader:YES];
            }
            else {
                Login *login = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
                UINavigationController * aNavi = [[UINavigationController alloc]initWithRootViewController:login];
                [[UIApplication sharedApplication] delegate].window.rootViewController = aNavi;
            }
        });
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
