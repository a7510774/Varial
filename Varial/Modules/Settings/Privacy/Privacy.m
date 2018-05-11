//
//  Privacy.m
//  Varial
//
//  Created by vis-1674 on 2016-02-06.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Privacy.h"
#import "BlockedUsers.h"

@interface Privacy ()

@end

@implementation Privacy

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self designTheView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)designTheView{
    
    [_headerView setHeader: NSLocalizedString(PRIVACY, nil)];
    [_headerView.logo setHidden:YES];
}
- (IBAction)blockUserBtnTapped:(UIButton *)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle: nil];
    BlockedUsers *aViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"BlockedUsers"];
    
   // BlockedUsers *aViewController = [[UIStoryboard storyboardWithName:@"BlockedUsers" bundle:nil] instantiateInitialViewController];
   // BlockedUsers *aViewController = [BlockedUsers new];

    [self.navigationController pushViewController:aViewController animated:YES];
}

@end
