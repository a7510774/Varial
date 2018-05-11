//
//  ZoomImage.h
//  Varial
//
//  Created by Shanmuga priya on 3/17/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLCPopup.h"
@protocol ZoomImageDelegate <NSObject>

-(void)onImageDownloadClick;

@end

@interface ZoomImage : UIView{
    KLCPopup *zoomPopup;
}
@property (assign) id<ZoomImageDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction) doButton:(id)sender;
- (void) showBigImage:(UIImageView *)image;
+ (id) sharedInstance;
@end
