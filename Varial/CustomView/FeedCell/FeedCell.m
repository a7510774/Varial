//
//  FeedCell.m
//  Varial
//
//  Created by Apple on 10/08/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "FeedCell.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "Util.h"

@implementation FeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    NSLog(@"LAYOUT NOW %@ %@", NSStringFromCGRect(self.videoView.frame), NSStringFromCGRect(self.mainPreview.frame));
//    if (self.isVideo) {
//        for( CALayer *layer in self.videoView.layer.sublayers) {
////            NSLog(@"layers %@", NSStringFromCGRect(self.videoView.frame));
////            layer.frame = CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height);
////            NSLog(@"layers %@", NSStringFromCGRect(layer.frame));
////            layer.hidden = YES;
//        }
//    }
//}

-(void)deallocObjects{
    
    self.container = nil;
    self.feedBody = nil;
    
    self.dimView = nil;
    
    self.checkinView = nil;
    self.checkinLabel = nil;
    self.checkinButton = nil;
    
    self.mainPreview = nil;
    self.medias = nil;
    self.subPreview = nil;
    self.playIcon = nil;
    self.imageCount = nil;
    self.videoView = nil;
    self.gBtnMuteUnMute = nil;
    self.message = nil;
    
    self.commentsButton = nil;
    self.starButton = nil;
    self.starListButton = nil;
    self.starCount = nil;
    self.commentCount = nil;
    self.starImage = nil;
    self.commentImage = nil;
    
    self.profileImage = nil;
    self.name = nil;
    self.date = nil;
    self.privacyImage = nil;
    self.progressView = nil;
    self.menuButton = nil;
    self.videoUrl = nil;
    self.optionsView = nil;
    self.videoItem = nil;
    self.videoPlayer = nil;
    self.avLayer = nil;
    self.downloadProgress = nil;
    self.mediaHeight = nil;
    self.urlPreview = nil;
    self.urlPreviewHeight = nil;
    self.activityIndicator = nil;
    self.videoViewCount = nil;
    self.videoViewCountHeight = nil;
    self.reportButton = nil;
    self.isVideo = nil;
    
    self.spinnerView = nil;
    self.spinnerProgressView = nil;
}

- (void)layoutConstraints {
    if (_cellData) {

        if ([[_cellData objectForKey:@"check_in_details"] count] > 0) {
//            _checkinMargin.active = YES;
            _checkinMargin.priority = 999;
//            [_checkinView hideByHeight:NO];
        } else {
//            _checkinMargin.active = NO;
            _checkinMargin.priority = 250;
            [_checkinView hideByHeight:YES];
        }
        
        if ([[_cellData objectForKey:@"post_content"] isEqualToString:@""]) {
            _message.hidden = YES;
            _messageMargin.active = NO;
        } else {
            _message.hidden = NO;
            _messageMargin.active = YES;
        }
        
        if ([[_cellData objectForKey:@"link_details"] count] > 0) {
            _urlPreviewMargin.active = NO;
            
        } else {
            _urlPreviewMargin.active = YES;
        }
        
        if ([[_cellData objectForKey:@"image_present"] boolValue]) {
            NSArray *images = [_cellData objectForKey:@"image"];
            CGSize imageSize = [Util getAspectRatio:[[images firstObject] objectForKey:@"media_dimension"] ofParentWidth:[UIScreen mainScreen].bounds.size.width];
            
//            NSLog(@"image mediaHeight %f", imageSize.height);
            
            _mediaHeight.constant = imageSize.height;
        }
        else if ([[_cellData objectForKey:@"video_present"] boolValue]) {
            NSArray *video = [_cellData objectForKey:@"video"];
            CGSize videoSize = [Util getAspectRatio:[[video firstObject] objectForKey:@"media_dimension"] ofParentWidth:[UIScreen mainScreen].bounds.size.width];
            _mediaHeight.constant = videoSize.height;
        }
        
    }

//    NSLog(@"checkinMargin %d message margin %d url preview margin %d media height %f", self.checkinMargin.active, self.messageMargin.active, self.urlPreviewMargin.active, self.mediaHeight.constant);

}



- (void)updateConstraints {
//    NSLog(@"updateConstraints");
    [self layoutConstraints];
    [super updateConstraints];
}
@end
