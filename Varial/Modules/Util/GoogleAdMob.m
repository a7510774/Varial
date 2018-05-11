//
//  GoogleAdMob.m
//  Varial
//
//  Created by jagan on 16/04/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "GoogleAdMob.h"
#import "Config.h"
#import "Util.h"
#import "BannerView.h"
#import "UIImageView+AFNetworking.h"

@interface GoogleAdMob()
{
    __weak BannerView *adView;
    float height;
}
@end

@implementation GoogleAdMob


+ (instancetype) sharedInstance{
    static GoogleAdMob *googleAdMob = nil;
    @synchronized(self) {
        if (googleAdMob == nil) {
            googleAdMob = [[self alloc] init];
        }
    }
    return googleAdMob;
}

- (void)fetchFeedAdWithCallback:(void(^)(NSDictionary *))handler {
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:2] forKey:@"ad_type_id"];
    [inputParams setValue:@"feed" forKey:@"ideom"];
    
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:GET_AD withCallBack:handler isShowLoader:NO];
}

- (void)fetchAdWithCallback:(void(^)(NSDictionary *))handler {
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:2] forKey:@"ad_type_id"];
    NSString *ideom = IPAD ? @"iPad" : @"iPhone";
    [inputParams setValue:ideom forKey:@"ideom"];
    
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:GET_AD withCallBack:handler isShowLoader:NO];
}

//Integrate Ads in Google
- (void)addAdInViewController:(UIViewController*) viewController {
    //Send general notification list request
    [self fetchAdWithCallback:^(NSDictionary *response) {
//    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:GET_AD withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            NSMutableDictionary *adDetails = [response objectForKey:@"ad_details"];
            NSString *adImageUrl = [NSString stringWithFormat:@"%@%@",[response valueForKey:@"media_url"],[adDetails valueForKey:@"image_url"]];
            NSString *imageSize = [adDetails valueForKey:@"image_size"];
            NSArray *dimension = [imageSize componentsSeparatedByString:@"x"];
            [self addImageFromUrl:adImageUrl withDimension:dimension toController:viewController andRedirectTo:[response valueForKey:@"ad_link"]];
        }
        else{
            #ifdef DEBUG
            NSString *adImageUrl = [NSString stringWithFormat:@"%@%@", @"https://dqloq8l38fi51.cloudfront.net", @"/images/varial_promo/images/14/1480588879_grenn320.50.png"];
            NSString *imageSize = @"320x50";
            NSArray *dimension = [imageSize componentsSeparatedByString:@"x"];
            [self addImageFromUrl:adImageUrl withDimension:dimension toController:viewController andRedirectTo:@"http://www.bajajauto.com/"];
            #endif
        }
//    } isShowLoader:NO];
    }];
}

- (void)addImageFromUrl:(NSString *)adUrl withDimension:(NSArray *)dimension toController:(UIViewController*) viewController andRedirectTo:(NSString *)redirectUrl{
    
    BannerView *banner = [[[NSBundle mainBundle] loadNibNamed:@"BannerView" owner:self options:nil] objectAtIndex:0];
    
//    UIButton *closeButton = [banner viewWithTag:2];;
    [banner.adImage setImageWithURL:[NSURL URLWithString:adUrl]];
    [banner setAdUrl:redirectUrl];
    banner.delegate = self.delegate;
    
    CGSize viewSize = viewController.view.frame.size;
    NSLog(@"ViewController ad size %@", NSStringFromCGSize(viewSize));
    
    //Add banner in view controller
//    UIImageView *bannerView = [banner viewWithTag:1];
//    [bannerView setImageWithURL:[NSURL URLWithString:addUrl]];
    [viewController.view addSubview:banner];
    adView = banner;
    [banner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
//    float height;
    float width;
    //Add auto layout constrains for the banner
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(banner);
    CGSize size;
    if ([dimension count] == 2) {
        width = [dimension[0] floatValue];
        height = [dimension[1] floatValue];
        
        float ratio = height / width;
        size.width = viewSize.width;
        size.height = viewSize.width * ratio;
        
        height = size.height;
    }
    else{
        size.width = 320;
        size.height = 55;
        height = 55;
    }
    
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:height] forKey:@"height"];
    NSDictionary *userInfo = @{@"height": [NSNumber numberWithFloat:height], @"remove": [NSNumber numberWithBool:NO]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AdShown" object:nil userInfo:userInfo];
    
    if ([self.delegate respondsToSelector:@selector(displayAd:)]) {
        [self.delegate displayAd:height];
    }
    
    NSString *verticalConstraint = [NSString stringWithFormat:@"V:[banner(%f)]-0-|", size.height];
    [viewController.view addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:verticalConstraint
                                         options:NSLayoutFormatAlignAllBottom metrics:nil
                                         views:viewsDictionary]];
    
    NSString *horizontalConstraint = [NSString stringWithFormat:@"H:[banner(%f)]", size.width];
    [viewController.view addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:horizontalConstraint
                                         options:NSLayoutFormatAlignAllCenterY metrics:nil
                                         views:viewsDictionary]];
    
//    [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
    [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:viewController.view
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0]];
    
    [viewController.view layoutIfNeeded];
    
    //Set redirect url
//    redirectTo = redirectUrl;
    
    //Redirect to ad page
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAd:)];
//    [bannerView setUserInteractionEnabled:YES];
//    [bannerView addGestureRecognizer:tap];
    
//    [closeButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    
//    adView = banner;
}

- (void)removeLastAd {
    if (adView != nil) {
        [adView dismiss:nil];
    }
}

//- (void)dismiss:(id)sender {
//    NSLog(@"DISMISS %@", sender);
//    if (adView) {
//        UIView *parent = [adView superview];
//        if (parent != nil) {
//            [adView removeFromSuperview];
//        }
//        NSDictionary *userInfo = @{@"remove": [NSNumber numberWithBool:YES]};
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"AdShown" object:nil userInfo:userInfo];
//        if ([self.delegate respondsToSelector:@selector(removeAd)]) {
//            [self.delegate removeAd];
//        }
//        [parent layoutIfNeeded];
//        adView = nil;
//    }
//}
//
////Tap gesture recognizer for image
//- (void)openAd:(UITapGestureRecognizer *)tapRecognizer {
//    if (redirectTo != nil) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:redirectTo]];
//    }
//}

@end
