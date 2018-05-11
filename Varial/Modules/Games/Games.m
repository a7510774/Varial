//
//  Games.m
//  Varial
//
//  Created by vis-1674 on 29/04/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "Games.h"
#import "Util.h"
#import "AlertMessage.h"
#import "UserMessages.h"

@interface Games ()

@end

@implementation Games

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self designTheView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView
{
    [_headerView setHeader:NSLocalizedString(GAME_TITLE, nil)];

}

-(IBAction)hitList:(id)sender
{
    [[AlertMessage sharedInstance] showMessage:COMING_SOON];
}
-(IBAction)oneSkate:(id)sender
{
    [[AlertMessage sharedInstance] showMessage:COMING_SOON];
}

@end
