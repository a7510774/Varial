//
//  MyPaopaoView.m
//  Varial
//
//  Created by Apple on 13/09/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "MyPaopaoView.h"
#import "BaiduPopularCheckin.h"
@interface MyPaopaoView ()

@end

@implementation MyPaopaoView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    float degrees = 50;
    self.arrowView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
    
    _mainView.layer.masksToBounds = NO;
    _mainView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _mainView.layer.shadowOffset = CGSizeMake(5, 5);
    _mainView.layer.shadowOpacity = 1;
    _mainView.layer.shadowRadius = 1.0;
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


@end
