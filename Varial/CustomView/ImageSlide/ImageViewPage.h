//
//  ImageViewPage.h
//  Varial
//
//  Created by jagan on 19/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

@interface ImageViewPage : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property NSUInteger pageIndex;
@property NSString *imageFile,*thumbUrl, *isFromChat;
@property UIImage *thumbImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)downloadAction:(id)sender;
-(void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
@end
