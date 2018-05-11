//
//  ImageSlider.h
//  Varial
//
//  Created by jagan on 19/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewPage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface ImageSlider : UIPageViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>{
    UILabel *title, *dateTime;
    
}

@property NSMutableArray *images;
@property NSUInteger startPosition;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, atomic) ALAssetsLibrary* library;
@property NSString *isFromChat, *titleName;

@end
