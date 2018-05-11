//
//  AdCell.m
//  Varial
//
//  Created by Leif Ashby on 8/3/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "AdCell.h"
#import "YYWebImage.h"
#import "Util.h"

@implementation AdCell

@synthesize imageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [self openAd];
    }
}

- (void)updateImage {
    if (_adInfo) {
        NSString *adLink = [_adInfo objectForKey:@"ad_image"];
        [self.imageView yy_setImageWithURL:[NSURL URLWithString:adLink] options:YYWebImageOptionIgnoreFailedURL | YYWebImageOptionSetImageWithFadeAnimation];
    }
}

- (void)openAd {
    if (_adInfo) {
        NSString *adLink = [_adInfo objectForKey:@"ad_link"];
        if (adLink != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adLink]];
        }
    }
}

//- (void)updateConstraints {
//    if (_adInfo) {
//        CGSize imageSize = [Util getAspectRatio:[_adInfo valueForKey:@"media_dimension"] ofParentWidth:[[UIScreen mainScreen] bounds].size.width];
//        self.heightConstraint.constant = imageSize.height;
//
////        NSArray *dimension = [[_adInfo valueForKey:@"media_dimension"] componentsSeparatedByString:@"x"];
////        if ([dimension count] == 2) {
////            float width = [dimension[0] floatValue];
////            float height = [dimension[1] floatValue];
////            float ratio = height / width;
////            self.heightConstraint.constant = [[UIScreen mainScreen] bounds].size.width * ratio;
////            NSLog(@"IMAGE SIZE %f", self.heightConstraint.constant);
////        }
//    } else {
//        self.heightConstraint.constant = 0;
//    }
//    
//    [super updateConstraints];
//}

@end
