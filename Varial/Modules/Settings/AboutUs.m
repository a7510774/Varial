//
//  AboutUs.m
//  Varial
//
//  Created by vis-1674 on 04/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "AboutUs.h"
@interface AboutUs ()

@end

@implementation AboutUs

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self designTheView];
    [self setVersionDetails];
    [self createPopups];
    
}
-(void)designTheView{
    [_headerView.logo setHidden:YES];
    [_headerView setHeader:NSLocalizedString(ABOUT_TITLE, nil)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setVersionDetails
{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(VERSION_TITLE, nil),currentVersion];
    
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    _buildLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(BUILD_NUMBER, nil),build];
}

//Create Update Version popups
- (void) createPopups{
    
    updateVersion = [[UpdateVersion alloc]init];
    [updateVersion setDelegate:self];
    
    _updateVersionPopUp = [KLCPopup popupWithContentView:updateVersion showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    AppDelegate *appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];

    // Show alert if having any updaed version
    
    [appDelegate needsUpdateWithCallback:^(BOOL needsUpdate) {
        if (needsUpdate) {
            [_updateVersionPopUp show];
        }
    }];
}

// Delegate Method for UpdateVersionPopup
-(void)onUpdateClick
{
    NSString *storeUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"store_url"];
    [_updateVersionPopUp dismiss:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeUrl]];

}

-(void)onCancelClick
{
    [_updateVersionPopUp dismiss:YES];
}

@end
