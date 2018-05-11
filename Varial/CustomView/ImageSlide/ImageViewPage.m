//
//  ImageViewPage.m
//  Varial
//
//  Created by jagan on 19/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ImageViewPage.h"
#import "Util.h"
#import "YYWebImage.h"

@interface ImageViewPage ()

@end

@implementation ImageViewPage

BOOL isZoomed;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    isZoomed = false;
    
    if (_isFromChat == nil) {
        
        UIImage *thumb =  _thumbImage != nil ? _thumbImage : [UIImage imageNamed:IMAGE_HOLDER];
        if (_pageIndex == 0) {
            [_image.layer setValue:@"original" forKey:@"identifier"];
        }
        
        [_image yy_setImageWithURL:[NSURL URLWithString:_imageFile]
                             placeholder:thumb
                                 options:YYWebImageOptionProgressiveBlur | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    if (expectedSize > 0 && receivedSize > 0) {
                                        CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                        progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                       
                                    }
                                }
                               transform:nil
                              completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                  if (stage == YYWebImageStageFinished) {
                                      
                                      self.image.image = image;
                                      self.scrollView.minimumZoomScale = 1;
                                      self.scrollView.maximumZoomScale = 4;
                                      self.scrollView.contentSize = CGSizeMake(image.size.width * 4, image.size.height * 4);
                                      self.scrollView.delegate = self;
                                      
                                      NSLog(@"Frame Width %f Frame Height %f", self.image.frame.size.width, self.image.frame.size.height);
                                      
                                  }
                              }];
        
        
    }
    else{
        
        [[Util sharedInstance].assetLibrary assetForURL:[NSURL URLWithString:_imageFile]
                                            resultBlock:^(ALAsset *asset)
         {
             if (asset == nil) {
                 self.image.image = [UIImage imageNamed:IMAGE_HOLDER];
             }
             else{
                 //Get asset thumbnail
                 CGImageRef thumbRef = [asset aspectRatioThumbnail];
                 UIImage *image = [UIImage imageWithCGImage:thumbRef];
                 self.image.image = image;
               
             }
         }
                                           failureBlock:^(NSError *err) {
                                               NSLog(@"Asset Error: %@",[err localizedDescription]);
                                               [self setZoomScroll:[UIImage imageNamed:IMAGE_HOLDER]];
                                           }];
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 4;
        self.scrollView.contentSize = CGSizeMake(1600, 900);
        self.scrollView.delegate = self;
    }
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGestureRecognizer];
}

- (void)setZoomScroll:(UIImage *)image{
    self.image.image = image;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 4;
    self.scrollView.contentSize = CGSizeMake(image.size.width * 4, image.size.height * 4);
    self.scrollView.delegate = self;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    isZoomed = FALSE;
    return self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)downloadAction:(id)sender {
   
}

-(void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer{
    
    CGSize newSize = CGSizeMake(_image.image.size.width * 3, _image.image.size.height * 3);
    
    if (!isZoomed) {
        
        newSize.width = _image.frame.size.width * 3;
        newSize.height = _image.frame.size.height * 3;
        CGPoint currentCenter = _image.center;
        
        //Animate the zoom
        [UIView transitionWithView:_image
                          duration:.3
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            _image.frame = CGRectMake(_image.frame.origin.x, _image.frame.origin.y, newSize.width, newSize.height);
                            _image.center = currentCenter;
                        }
                        completion:^(BOOL finished){
                            isZoomed = TRUE;
                        }];           
    }
    else{
        
        newSize.width = _image.frame.size.width / 3;
        newSize.height = _image.frame.size.height / 3;
        CGPoint currentCenter = _image.center;
        
        //Animate the zoom
        [UIView transitionWithView:_image
                          duration:.3
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            _image.frame = CGRectMake(_image.frame.origin.x, _image.frame.origin.y, newSize.width, newSize.height);
                            _image.center = currentCenter;
                        }
                        completion:^(BOOL finished){
                            isZoomed = FALSE;
                        }];
    }
}@end
