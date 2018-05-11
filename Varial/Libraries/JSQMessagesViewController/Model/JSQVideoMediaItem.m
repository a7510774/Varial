//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQVideoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "UIImage+JSQMessages.h"


@interface JSQVideoMediaItem ()

@property (strong, nonatomic) UIImageView *cachedVideoImageView;

@end


@implementation JSQVideoMediaItem

#pragma mark - Initialization

- (instancetype)initWithFileURL:(NSString *)fileURL withThumb:(UIImage *)image isReadyToPlay:(BOOL)isReadyToPlay
{
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _isReadyToPlay = isReadyToPlay;
        _image = image;
        _cachedVideoImageView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedVideoImageView = nil;
}

#pragma mark - Setters

- (void)setFileURL:(NSString *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedVideoImageView = nil;
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedVideoImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedVideoImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.fileURL == nil && self.image == nil) {
        return nil;
    }
    
    if (self.cachedVideoImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        // UIImage *playIcon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:[UIColor whiteColor]];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        UIImageView *playView = [[UIImageView alloc] initWithFrame:imageView.frame];
        playView.contentMode = UIViewContentModeScaleAspectFit;
        playView.center = imageView.center;
        playView.image = [UIImage imageNamed:@"VideoFrame.png"];
        [imageView addSubview:playView];
        
        //Altered for own purpose
        if (_fileURL != nil) {
            if ([_fileURL rangeOfString:@"assets-library://"].location == NSNotFound) { //Load from server
                [imageView setImageWithURL:[NSURL URLWithString:_fileURL]];
            }
            else{ //Load from local
                
                [[Util sharedInstance].assetLibrary assetForURL:[NSURL URLWithString:_fileURL]
                                                    resultBlock:^(ALAsset *asset)
                 {
                     if (asset == nil) {
                         UIImage * image = [Util deletedImages:_fileURL];
                         if (image != nil) {
                             imageView.image = image;
                         }
                         else
                         {
                             imageView.image = [UIImage imageNamed:IMAGE_HOLDER];
                         }
                     }
                     else{
                         //Get asset thumbnail
                         CGImageRef thumbRef = [asset aspectRatioThumbnail];
                         UIImage *thumbImage = [UIImage imageWithCGImage:thumbRef];
                         imageView.image = thumbImage;
                     }
                 }
                                                   failureBlock:^(NSError *err) {
                                                       NSLog(@"Asset Error: %@",[err localizedDescription]);
                                                       UIImage * image = [Util deletedImages:_fileURL];
                                                       if (image != nil) {
                                                           imageView.image = image;
                                                       }
                                                       else
                                                       {
                                                           imageView.image = [UIImage imageNamed:IMAGE_HOLDER];
                                                       }
                                                   }];
            }
        }
        else{
            imageView.image = self.image;
        }
        //Altered for own purpose end
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedVideoImageView = imageView;
    }
    
    return self.cachedVideoImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQVideoMediaItem *videoItem = (JSQVideoMediaItem *)object;
    
    return self.isReadyToPlay == videoItem.isReadyToPlay;
}

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
        _isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
    [aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQVideoMediaItem *copy = [[[self class] allocWithZone:zone]initWithFileURL:self.fileURL withThumb:self.image isReadyToPlay:self.isReadyToPlay];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end

