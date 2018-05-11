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

#import "JSQPhotoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"

@interface JSQPhotoMediaItem ()
@property (strong, nonatomic) UIImageView *cachedImageView;

@end


@implementation JSQPhotoMediaItem

#pragma mark - Initialization

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = [image copy];
        _cachedImageView = nil;
    }
    return self;
}

//Altered for own purpose
- (instancetype)initWithURL:(NSString *)imageURL
{
    self = [super init];
    if (self) {
        _imageURL = [imageURL copy];
        _cachedImageView = nil;
    }
    return self;
}
//Altered for own purpose end

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    _image = [image copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.image == nil && self.imageURL == nil) {
        return nil;
    }
    
    if (self.cachedImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        
        //Altered for own purpose
        UIImageView *imageView = [[UIImageView alloc] init];
        if (_imageURL != nil) {
            
            if ([_imageURL rangeOfString:@"assets-library://"].location == NSNotFound) { //Load from server
                [imageView setImageWithURL:[NSURL URLWithString:self.imageURL]];
            }
            else{ //Load from local
                
                [[Util sharedInstance].assetLibrary assetForURL:[NSURL URLWithString:_imageURL]
                                                    resultBlock:^(ALAsset *asset)
                 {
                     UIImage * image = [Util deletedImages:_imageURL];
                     if (asset == nil) {
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
                                                       UIImage * image = [Util deletedImages:_imageURL];
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
        
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = imageView;
    }
    
    return self.cachedImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.image.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.image, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        _imageURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageURL))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.imageURL forKey:NSStringFromSelector(@selector(imageURL))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQPhotoMediaItem *copy = [[JSQPhotoMediaItem allocWithZone:zone] initWithImage:self.image];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end

