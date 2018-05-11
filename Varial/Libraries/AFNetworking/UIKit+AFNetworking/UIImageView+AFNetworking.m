// UIImageView+AFNetworking.m
// Copyright (c) 2011–2016 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "MBCircularProgressBarView.h"

#import <objc/runtime.h>

#if TARGET_OS_IOS || TARGET_OS_TV

static void * AFTaskCountOfBytesReceivedContext = &AFTaskCountOfBytesReceivedContext;

#import "AFImageDownloader.h"

@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setActiveImageDownloadReceipt:) AFImageDownloadReceipt *af_activeImageDownloadReceipt;

@end

@implementation UIImageView (_AFNetworking)

NSString *taskIdentifier;
MBCircularProgressBarView *progressView;

- (AFImageDownloadReceipt *)af_activeImageDownloadReceipt {
    return (AFImageDownloadReceipt *)objc_getAssociatedObject(self, @selector(af_activeImageDownloadReceipt));
}

- (void)af_setActiveImageDownloadReceipt:(AFImageDownloadReceipt *)imageDownloadReceipt {
    objc_setAssociatedObject(self, @selector(af_activeImageDownloadReceipt), imageDownloadReceipt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIImageView (AFNetworking)

+ (AFImageDownloader *)sharedImageDownloader {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(sharedImageDownloader)) ?: [AFImageDownloader defaultInstance];
#pragma clang diagnostic pop
}

+ (void)setSharedImageDownloader:(AFImageDownloader *)imageDownloader {
    objc_setAssociatedObject(self, @selector(sharedImageDownloader), imageDownloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    [self.layer setValue:[url absoluteString] forKey:@"imageUrl"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
{

    if ([urlRequest URL] == nil) {
        [self cancelImageDownloadTask];
        self.image = placeholderImage;        
        return;
    }

    if ([self isActiveTaskURLEqualToURLRequest:urlRequest]){
        return;
    }

    [self cancelImageDownloadTask];

    AFImageDownloader *downloader = [[self class] sharedImageDownloader];
    id <AFImageRequestCache> imageCache = downloader.imageCache;

    //Read identifier from imageview
    NSString *identifier = [self.layer valueForKey:@"identifier"];
    
    //Use the image from the image cache if it exists
    UIImage *cachedImage = [imageCache imageforRequest:urlRequest withAdditionalIdentifier:identifier];
    if (cachedImage) {
        if (success) {
            self.image = cachedImage;
            success(urlRequest, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }
        [self clearActiveDownloadInformation];
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }

        __weak __typeof(self)weakSelf = self;
        NSUUID *downloadID = [NSUUID UUID];
        AFImageDownloadReceipt *receipt;
        receipt = [downloader
                   downloadImageForURLRequest:urlRequest
                   withReceiptID:downloadID
                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([strongSelf.af_activeImageDownloadReceipt.receiptID isEqual:downloadID]) {
                           if (success) {
                               
                               NSString *dimension = [self.layer valueForKey:@"dimension"];
                               NSString *identifier = [self.layer valueForKey:@"identifier"];
                               
                               if (dimension != nil) {
                                   
                                   //UIImage *resizedImage = [Util imageWithImage:responseObject scaledToWidth:[Util getWindowSize].width - 20];
                                   
                                   //Resize and save in cache
                                   [imageCache addImage:responseObject forRequest:request withAdditionalIdentifier:nil];
                                   
                                   //self.image = resizedImage;
                                   
                                   self.alpha = .2;
                                   [UIView transitionWithView:self
                                                     duration:1
                                                      options:UIViewAnimationOptionCurveEaseOut
                                                   animations:^{
                                                       self.alpha = 1;
                                                   }
                                                   completion:^(BOOL finished){
                                                       
                                                       
                                                   }];
                                   
                                   //save in original image cache
                                   [imageCache addImage:responseObject forRequest:request withAdditionalIdentifier:@"original"];
                                    success(request, response, responseObject);
                               }
                               else if(identifier != nil) {
                                   success(request, response, responseObject);
                               }
                               else{
                                   //save in cache
                                   [imageCache addImage:responseObject forRequest:request withAdditionalIdentifier:nil];
                                   success(request, response, responseObject);
                               }
                               
                           } else if(responseObject) {
                               
                               //save in cache
                               [imageCache addImage:responseObject forRequest:request withAdditionalIdentifier:nil];
                               
                               strongSelf.image = responseObject;
                           }
                           [strongSelf clearActiveDownloadInformation];
                       }

                   }
                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                        if ([strongSelf.af_activeImageDownloadReceipt.receiptID isEqual:downloadID]) {
                            if (failure) {
                                failure(request, response, error);
                            }
                            [strongSelf clearActiveDownloadInformation];
                        }
                   }];

        self.af_activeImageDownloadReceipt = receipt;
        
        NSString *dimension = [self.layer valueForKey:@"dimension"];
        if (dimension != nil) {
            
            [[self subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
            
            progressView = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
            progressView.center = self.center;
            progressView.progressColor = UIColorFromHexCode(THEME_COLOR);
            progressView.progressStrokeColor = UIColorFromHexCode(THEME_COLOR);
            progressView.showValueString = FALSE;
            progressView.progressLineWidth = 2;
            progressView.maxValue = 1;
            progressView.value = .05;
            progressView.backgroundColor = [UIColor clearColor];
            progressView.progressAngle = 100;
            
            [self addSubview:progressView];
            
            progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            
            [self.af_activeImageDownloadReceipt.task addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptions)0 context:AFTaskCountOfBytesReceivedContext];
            [self.af_activeImageDownloadReceipt.task addObserver:self forKeyPath:@"countOfBytesReceived" options:(NSKeyValueObservingOptions)0 context:AFTaskCountOfBytesReceivedContext];
            
            [self.layer setValue:[NSString stringWithFormat:@"%lu", (unsigned long)self.af_activeImageDownloadReceipt.task.taskIdentifier] forKey:@"taskIdentifier"];
        }
    }
}

- (void)cancelImageDownloadTask {
    if (self.af_activeImageDownloadReceipt != nil) {
        [[self.class sharedImageDownloader] cancelTaskForImageDownloadReceipt:self.af_activeImageDownloadReceipt];
        [self clearActiveDownloadInformation];
     }
}

- (void)clearActiveDownloadInformation {
    self.af_activeImageDownloadReceipt = nil;
}

- (BOOL)isActiveTaskURLEqualToURLRequest:(NSURLRequest *)urlRequest {
    return [self.af_activeImageDownloadReceipt.task.originalRequest.URL.absoluteString isEqualToString:urlRequest.URL.absoluteString];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(__unused NSDictionary *)change
                       context:(void *)context
{
    if (context == AFTaskCountOfBytesReceivedContext) {
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            if ([object countOfBytesExpectedToReceive] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //You can do your stuff at here like show progress
                    //NSLog(@"Progress : %f",[object countOfBytesReceived] / ([object countOfBytesExpectedToReceive] * 1.0f));
                    NSURLSessionDataTask *task = (NSURLSessionDataTask *)object;
                    //NSLog(@"Curent Task Identifier %lu and Image Identifier %@",task.taskIdentifier,[self.layer valueForKey:@"taskIdentifier"]);
                    NSString *currenIdentifier = [NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier];
                    if ([currenIdentifier isEqualToString:[self.layer valueForKey:@"taskIdentifier"]]) {
                          [progressView setValue:[object countOfBytesReceived] / ([object countOfBytesExpectedToReceive] * 1.0f) animateWithDuration:.2];
                    }
                });
            }
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
            if ([(NSURLSessionTask *)object state] == NSURLSessionTaskStateCompleted) {
                @try {
                    [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
                    
                    //NSLog(@"Image Download Complete");
                    if (context == AFTaskCountOfBytesReceivedContext) {                        
                        [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))];
                        NSURLSessionDataTask *task = (NSURLSessionDataTask *)object;
                        //NSLog(@"Curent Task Identifier %lu and Image Identifier %@",task.taskIdentifier,[self.layer valueForKey:@"taskIdentifier"]);
                        NSString *currenIdentifier = [NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier];
                        if ([currenIdentifier isEqualToString:[self.layer valueForKey:@"taskIdentifier"]]) {
                            [progressView setHidden:YES];
                        }
                    }
                }
                @catch (NSException * __unused exception) {}
            }
        }
    }
}

@end

#endif
