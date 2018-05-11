//
//  ZoomImage.m
//  Varial
//
//  Created by Shanmuga priya on 3/17/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ZoomImage.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
@implementation ZoomImage

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

+ (id) sharedInstance{
    static ZoomImage *zoomImage = nil;
    @synchronized(self) {
        if (zoomImage == nil) {
            zoomImage = [[self alloc] init];
        }
    }
    return zoomImage;
}

- (void) setup {
    
    [[NSBundle mainBundle] loadNibNamed:@"ZoomImage" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    [self addSubview:self.mainView];
    self.translatesAutoresizingMaskIntoConstraints = NO;

}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
     [zoomPopup dismiss:YES];
}

- (IBAction) doButton:(id)sender {
     UIImageWriteToSavedPhotosAlbum(_imageView.image, nil, nil, nil);
}

- (void) showBigImage:(UIImageView *)image{
    
    _imageView.image=image.image;
    
    NSString *imageThumbUrl = [image.layer valueForKey:@"imageUrl"];
    if (imageThumbUrl != nil) {
        NSString *fullImageUrl = [Util getOriginalImageUrl:imageThumbUrl];
        if (fullImageUrl != nil) {
            [_imageView setImageWithURL:[NSURL URLWithString:fullImageUrl] placeholderImage:image.image];
        }        
    }
    
    zoomPopup = [KLCPopup popupWithContentView:self showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [zoomPopup show];
}
@end
