//
//  BannerView.m
//  Varial
//
//  Created by Leif Ashby on 8/7/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "BannerView.h"

@implementation BannerView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAd:)];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:tap];
}

- (IBAction)openAd:(id)sender {
    NSLog(@"open ad");
    if (_adUrl) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_adUrl]];
    }
}

- (IBAction)dismiss:(id)sender {
    NSLog(@"DISMISS");
    UIView *parent = [self superview];
    if (parent != nil) {
        [self removeFromSuperview];
    }
    NSDictionary *userInfo = @{@"remove": [NSNumber numberWithBool:YES]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AdShown" object:nil userInfo:userInfo];
    if ([self.delegate respondsToSelector:@selector(removeAd)]) {
        [self.delegate removeAd];
    }
    [parent layoutIfNeeded];
}
@end
