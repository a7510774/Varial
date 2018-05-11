//
//  GeneralNotification.m
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "GeneralNotification.h"
#import "XMPPServer.h"
#import "BaiduPopularCheckin.h"
#import "GooglePopularCheckin.h"

@interface GeneralNotification ()
{
    BaiduPopularCheckin *baiduCheckin;
    GooglePopularCheckin *googleCheckin;
}

@end

@implementation GeneralNotification
@synthesize page;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [self initMap];
}

- (void)initMap {
    NSString *country_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    if([country_code isEqualToString:@"cn"] || [country_code isEqualToString:@"zh"])  // is china show Baidu Map
    {
        baiduCheckin = [[BaiduPopularCheckin alloc] initWithNibName:@"BaiduPopularCheckin" bundle:nil];
        baiduCheckin.homePage = YES;
        [self addChildViewController:baiduCheckin];
        [baiduCheckin.view setFrame:CGRectMake(0,0,_popularCheckin.frame.size.width,_popularCheckin.frame.size.height)];
        [_popularCheckin addSubview:baiduCheckin.view];
        [baiduCheckin didMoveToParentViewController:self];
        
    }
    else // Google Map
    {
        googleCheckin = [[GooglePopularCheckin alloc] initWithNibName:@"GooglePopularCheckin" bundle:nil];
        
        [self addChildViewController:googleCheckin];
        [googleCheckin.view setFrame:CGRectMake(0,0,_popularCheckin.frame.size.width,_popularCheckin.frame.size.height)];
        [_popularCheckin addSubview:googleCheckin.view];
        [googleCheckin didMoveToParentViewController:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
