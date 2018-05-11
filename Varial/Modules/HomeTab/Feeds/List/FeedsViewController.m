//
//  FeedsViewController.m
//  Varial
//
//  Created by Guru Prasad chelliah on 12/30/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "FeedsViewController.h"
#import "Util.h"
#import "FeedSingleImageViewTableViewCell.h"
#import "YYWebImage.h"

@interface FeedsViewController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSMutableArray *myAryInfo;
@property(nonatomic,strong) NSString *myStrMediaBaseUrl;

@end

@implementation FeedsViewController

@synthesize myAryInfo,myStrMediaBaseUrl;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];;
    [self setUpModel];
    [self loadModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpUI {
    
    [self.myTblView registerNib:[UINib nibWithNibName:NSStringFromClass([FeedSingleImageViewTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FeedSingleImageViewTableViewCell class])];
    
    self.myTblView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.myTblView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //self.myTblView.translatesAutoresizingMaskIntoConstraints = YES;

}

- (void)setUpModel {
    
    myAryInfo = [NSMutableArray new];
}

- (void)loadModel {
    
    [self getFeedsList];
}


# pragma mark - UITableView Delegate & datasource-

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return myAryInfo.count;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return UITableViewAutomaticDimension;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return UITableViewAutomaticDimension;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    FeedSingleImageViewTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([FeedSingleImageViewTableViewCell class])];
    
//    // Hide/Show Share View
//    if (isShareViewAvailable){
//        aCell.ShareView.hidden = YES;
//        aCell.GviewProfileTopConstraint.constant = 50.0;
//    }
//    else {
//        aCell.ShareView.hidden = NO;
//        aCell.GviewProfileTopConstraint.constant = 0.0;
//    }
    aCell.gLblTitle.text = myAryInfo[indexPath.row][@"name"];
    aCell.gLblDateAndTime.text = [Util timeStamp: [myAryInfo[indexPath.row][@"time_stamp"] intValue]];
    //aCell.gLblContent.text = myAryInfo[indexPath.row][@"post_content"];

    int aIntLikeCount = [myAryInfo[indexPath.row][@"stars_count"] intValue];
    int aIntCmtCount = [myAryInfo[indexPath.row][@"comments_count"] intValue];

    aCell.gLblLike.text = [NSString stringWithFormat:@"%d", aIntLikeCount];
    aCell.gLblComment.text = [NSString stringWithFormat:@"%d", aIntCmtCount];
    
    int aIntPrivacyType = [myAryInfo[indexPath.row][@"privacy_type"] intValue];
    [aCell.gImgViewPrivacy setImage:[Util imageForFeed:aIntPrivacyType withType:@"privacy"]];
    
    [aCell.gImgViewUser yy_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",myStrMediaBaseUrl,[myAryInfo[indexPath.row]valueForKeyPath:@"posters_profile_image.profile_image"]]] placeholder:[UIImage imageNamed:IMAGE_HOLDER]];
    
    [Util makeCircularImage:aCell.gImgViewUser withBorderColor:UIColorFromHexCode(THEME_COLOR)];
    
    if ([myAryInfo[indexPath.row][@"image"]count]) {
        
        NSMutableArray *aMAryFeedImage = [NSMutableArray new];
        
        aMAryFeedImage = myAryInfo[indexPath.row][@"image"];
        
        CGSize imageSize = [Util getAspectRatio:myAryInfo[indexPath.row][@"media_dimension"] ofParentWidth:self.view.frame.size.width];
        
        CGRect frame = aCell.gImageViewFeeds.frame;
        aCell.gImageViewFeeds.frame = CGRectMake(frame.origin.x, frame.origin.y, imageSize.width, imageSize.height);
        aCell.gImageViewFeeds.clipsToBounds = YES;
        
        aCell.gConstraintFeedImageHeight.constant = imageSize.height;
        aCell.gConstraintVideoViewHeight.constant = 0;
        
        aCell.gImageViewFeeds.hidden = NO;
        aCell.gViewMediaVideo.hidden = YES;
        
        //[aCell layoutIfNeeded];
        
//        CGRect aFrame = aCell.gViewLikeAndCmt.frame;
//        aFrame.origin.y = aCell.gImageViewFeeds.frame.origin.y + aCell.gImageViewFeeds.frame.size.height + 10;
//        aCell.gViewLikeAndCmt.frame = aFrame;
//
//        aCell.gViewLikeAndCmt.clipsToBounds = YES;
       // [aCell.gViewLikeAndCmt layoutIfNeeded];

        //[currentImage.layer setValue:[mediaData valueForKey:@"media_dimension"] forKey:@"dimension"]
        //[aCell.gImageViewFeeds.layer setValue:[mediaData valueForKey:@"media_dimension"] forKey:@"dimension"]
        
        [self showDownloadProgress:aCell imageView:aCell.gImageViewFeeds mediaUrl:aMAryFeedImage[0][@"media_url"] imageSize:imageSize onProgressView:[Util designdownloadProgress:aCell.downloadProgress]];
    }
    
    else if (myAryInfo[indexPath.row][@"video_count"]) {
        
        CGSize imageSize = [Util getAspectRatio:myAryInfo[0][@"media_dimension"] ofParentWidth:self.view.frame.size.width];
        
        CGRect frame = aCell.gViewMediaVideo.frame;
        //aCell.gViewMediaVideo.frame = CGRectMake(frame.origin.x, frame.origin.y, imageSize.width, imageSize.height);
        aCell.gViewMediaVideo.clipsToBounds = YES;
        
        aCell.downloadProgress.hidden = YES;
        aCell.gConstraintFeedImageHeight.constant = imageSize.height;
       // aCell.gConstraintVideoViewHeight.constant = imageSize.height;
        
        aCell.gImageViewFeeds.hidden = YES;
        aCell.gViewMediaVideo.hidden = NO;
        
        NSMutableArray *aMAryVideo = [NSMutableArray new];
        aMAryVideo = myAryInfo[indexPath.row][@"video"];
        
        int aIntViewCount = [aMAryVideo[0][@"views_count"] intValue];
        aCell.gLblViews.text = [NSString stringWithFormat:@"%d Views", aIntViewCount];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",myStrMediaBaseUrl,aMAryVideo[0][@"media_url"]]];
        AVPlayerItem *aPlayerItem  = [AVPlayerItem playerItemWithURL:url];
        AVPlayer *aVideoPlayer = [AVPlayer playerWithPlayerItem:aPlayerItem];
        AVPlayerLayer *aPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:aVideoPlayer];
        
        [aPlayerLayer setFrame:CGRectMake(aCell.gViewMediaVideo.frame.origin.x, aCell.gViewMediaVideo.frame.origin.y, aCell.gViewMediaVideo.frame.size.width,  aCell.gViewMediaVideo.frame.size.height)];
        
        aPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        [aCell.gViewMediaVideo.layer addSublayer:aPlayerLayer];
        [aVideoPlayer setMuted:YES];
        
        // aCell.imageView.image = [UIImage imageNamed:@"icon_skatting_logo"];
    }
    
    else {
        
        aCell.gImageViewFeeds.hidden = YES;
        aCell.gViewMediaVideo.hidden = YES;
        
        aCell.gConstraintVideoViewHeight.constant = 0;
        aCell.gConstraintFeedImageHeight.constant = 0;
        aCell.downloadProgress.hidden = YES;
    }

    if (![myAryInfo[indexPath.row][@"check_in_details"] count]) {
        
        aCell.gConstraintHeight.constant = 0;
    }
    
    return aCell;
}

# pragma mark - API Calls -

- (void)getFeedsTypesList {
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSNumber numberWithInt:0] forKey:@"post_feed_type_list"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_TYPES_LIST withCallBack:^(NSDictionary * response){
        
        if ([[response valueForKey:@"status"] boolValue]) {
            
            [Util setInDefaults:response withKey:@"FeedsTypeList"];
            // [self setFeedTypesList:response];
            // [self setFeedType];
        }
        
        else {
            
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
        
    } isShowLoader:NO];
}

// Get Feeds List
- (void)getFeedsList {
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:@"0" forKey:@"post_id"];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[NSString stringWithFormat:@"%@",@"0"] forKey:@"team_post"];
    [inputParams setValue:@"6" forKey:@"post_type_id"];
    [inputParams setValue:@"0"  forKey:@"recent"];
    [inputParams setValue:@"0"  forKey:@"time_stamp"];
    [inputParams setValue:@"6"  forKey:@"feed_list_type_key"];
   
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:FEEDS_LIST withCallBack:^(NSDictionary * response) {
        
        if ([[response valueForKey:@"status"] boolValue]) {
            
            myStrMediaBaseUrl = response[@"media_base_url"];
            myAryInfo = response[@"feed_list"];

            [self.myTblView reloadData];
            
//            mediaBaseUrl = [response objectForKey:@"media_base_url"];
//            rootViewController.mediaBase = mediaBaseUrl;
//
//            NSString *feed_list_type = [NSString stringWithFormat:@"%@",[response objectForKey:@"feed_list_type_key"]];
//
//            NSLog(@"Feed list type: %@", feed_list_type);
//            // check response type and slected feed type are equal
//            if ([feedTypeId isEqualToString:feed_list_type]) {
//
//                // If page load and Pull to to refresh -> remove all records and reload the records
//                for (int i =0; i<[feeds count]; i++) {
//                    //                    if ([[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"false"]) {
//                    if (![[[feeds objectAtIndex:i] objectForKey:@"is_local"] isEqualToString:@"true"]) {
//                        [feeds removeObjectAtIndex:i];
//                        i--;
//                    }
//                }
//                [LocalStorageManager assignOfflineFeeds:response Type:[selectedFeedType intValue]]; // Get response for is user is offline to show last seen 10 feeds
//                [self removeUploadedLocalFeeds:response];
//                [self alterTheMediaList:response];
//                //show empty message
//                [self addEmptyMessageForFeedListTable];
//            }
            
        }
        
        else {
            
            UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
            
            if ([navigation isKindOfClass:[UINavigationController class]]) {
                
                [[AlertMessage sharedInstance] showMessage:response[@"message"]];
            }
        }
        
    } isShowLoader:NO];
}


- (void)showDownloadProgress :(FeedSingleImageViewTableViewCell *)cell imageView:(UIImageView *)imageView mediaUrl:(NSString *)url imageSize:(CGSize )imageSize onProgressView:(MBCircularProgressBarView *)downloadProgress {
    
    [imageView yy_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",myStrMediaBaseUrl,url]]
                      placeholder:nil
                          options:YYWebImageOptionSetImageWithFadeAnimation
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                           
                             //progress = (float)receivedSize / expectedSize;
                             
                             if (expectedSize > 0 && receivedSize > 0) {
                                 CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                 downloadProgress.hidden = NO;
                                 [downloadProgress setValue:progress];
                             }
                         }
                        transform:^UIImage *(UIImage *image, NSURL *url) {
//                            image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeCenter];
//                            return [image yy_imageByRoundCornerRadius:10];
                            
                            return nil;
                        }
                       completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                           if (from == YYWebImageFromDiskCache) {
                               NSLog(@"load from disk cache");
                               
                               downloadProgress.hidden = YES;
                               // imageView.image = image;
                           }
                           
                           else if (stage == YYWebImageStageFinished) {
                               
                               downloadProgress.hidden = YES;
                              // if (!image)
                                 //  imageView.image = image;
                           }
                       }];
    
   /* [imageView yy_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",myStrMediaBaseUrl,url]]
                      placeholder:[UIImage imageNamed:@"image_placeholder.png"]
                          options:YYWebImageOptionIgnoreFailedURL | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionUseNSURLCache
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             if (expectedSize > 0 && receivedSize > 0) {
                                 CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                 downloadProgress.hidden = NO;
                                 [downloadProgress setValue:progress];
                             }
                         }
                        transform:nil
                       completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                           if (stage == YYWebImageStageFinished) {
                               
                               downloadProgress.hidden = YES;
                               
                               if (!image)
                                   imageView.image = image;
                           }
                       }]; */
}

@end
