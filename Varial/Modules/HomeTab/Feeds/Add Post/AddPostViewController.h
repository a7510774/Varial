//
//  AddPostViewController.h
//  Varial
//
//  Created by Guru Prasad chelliah on 12/24/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateFilterBlock)(BOOL,UIImage*,NSURL*);

@interface AddPostViewController : UIViewController

@property (nonatomic) BOOL gIsPresentVideoClick,gIsPresentLibrary;

@property (strong, nonatomic) IBOutlet UIView *viewNavigation;
@property (strong, nonatomic) IBOutlet UILabel *lblNavigationTitle;
@property (strong, nonatomic) IBOutlet UIView *viewCategory;
@property (strong, nonatomic) IBOutlet UICollectionView *chooseCategoryCollectionView;
@property (strong, nonatomic) IBOutlet UIView *viewBottom;
@property (strong, nonatomic) IBOutlet UIButton *btnCamera;
@property (strong, nonatomic) IBOutlet UIButton *btnVideo;
@property (strong, nonatomic) IBOutlet UIButton *btnLibrary;
@property (strong, nonatomic) IBOutlet UIView *viewLibrary;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewLibrary;
@property (strong, nonatomic) IBOutlet UIButton *btnSwithCamera;
@property (strong, nonatomic) IBOutlet UIButton *btnFlash;
@property (strong, nonatomic) IBOutlet UIView *viewVideo;

@property (nonatomic, copy) UpdateFilterBlock myUpdateFilterBlock;
@property (strong, nonatomic) IBOutlet UIView *viewTimer;
@property (strong, nonatomic) IBOutlet UILabel *lblTimer;

@end
