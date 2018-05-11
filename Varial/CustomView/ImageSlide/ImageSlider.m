//
//  ImageSlider.m
//  Varial
//
//  Created by jagan on 19/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ImageSlider.h"
#import "Util.h"
#import "AppDelegate.h"
@interface ImageSlider ()

@end

@implementation ImageSlider

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    ImageViewPage *initialViewController = [self viewControllerAtIndex:_startPosition];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    //Add Back Button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0,20, 50, 40)];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(5,20, 5, 15);
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(closeSlider:) forControlEvents:UIControlEventTouchUpInside];
    
    //Add Save button if its not comes from chat
    if (_isFromChat == nil) {
        float xPos = self.view.frame.size.width - 70;
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(xPos ,20, 40, 40)];
        saveButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [saveButton setImage:[UIImage imageNamed:@"newdown.png"] forState:UIControlStateNormal];
        [self.view addSubview:saveButton];
        [saveButton addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
        
        //Add auto layout constrains for the save button
        [saveButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (saveButton);
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-20-[saveButton(40)]"
                                   options:NSLayoutFormatAlignAllBottom metrics:nil
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[saveButton(40)]-10-|"
                                   options:NSLayoutFormatAlignAllCenterY metrics:nil
                                   views:viewsDictionary]];
    }
    else{
        //Show title label
        title = [[UILabel alloc] initWithFrame:CGRectMake(0,20, 230, 25)];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont fontWithName:@"CenturyGothic" size:15];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:title];
        
        
        //Show date time label
        dateTime = [[UILabel alloc] initWithFrame:CGRectMake(0,20, 230, 25)];
        dateTime.backgroundColor = [UIColor clearColor];
        dateTime.font = [UIFont fontWithName:@"CenturyGothic" size:11];
        dateTime.textColor = [UIColor whiteColor];
        dateTime.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:dateTime];

        
        //Add auto layout constrains for the save button
        [title setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (title,dateTime);
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-20-[title(25)]"
                                   options:NSLayoutFormatAlignAllBottom metrics:nil
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-60-[title]-60-|"
                                   options:NSLayoutFormatAlignAllCenterY metrics:nil
                                   views:viewsDictionary]];
        
        //Add auto layout constrains for the save button
        [dateTime setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-40-[dateTime(20)]"
                                   options:NSLayoutFormatAlignAllBottom metrics:nil
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-60-[dateTime]-60-|"
                                   options:NSLayoutFormatAlignAllCenterY metrics:nil
                                   views:viewsDictionary]];

    }
    
    //Set current page title
    [self setPageTitle:(int)_startPosition];
   
}

-(void)viewWillAppear:(BOOL)animated{
    self.library = [[ALAssetsLibrary alloc] init];
    
    // Allow to rotate the uimage
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    delegate.shouldAllowRotation = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    // Diable screen orientation
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    delegate.shouldAllowRotation = NO;
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait]                           forKey:@"orientation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Close slider
- (IBAction)closeSlider:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Close slider
- (IBAction)saveImage:(id)sender
{
    // UIImageWriteToSavedPhotosAlbum(_image.image, nil, nil, nil);
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (status != ALAuthorizationStatusAuthorized) {
        [[Util sharedInstance] showGalleryAlert];
    }
    else{
        ImageViewPage *imageViewPage = [[_pageController viewControllers] objectAtIndex:0];
        [self.library saveImage:imageViewPage.image.image toAlbum:@"Varial" withCompletionBlock:^(NSError *error, NSURL *mediaUrl) {
            if (error != nil) {
                NSLog(@"Image Save Error : %@", error);
            }
        }];
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(IMAGE_SAVED, nil)];
    }
}

- (void)setPageTitle:(int)index{
    NSMutableDictionary *imageData = self.images[index];
    if ([[imageData valueForKey:@"is_outgoing"] boolValue]) {
        title.text = NSLocalizedString(YOU, nil);
    }
    else{
        title.text = _titleName;
    }
    dateTime.text = [Util timeStamp:[[imageData valueForKey:@"time"] longLongValue]];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSUInteger index = ((ImageViewPage*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ImageViewPage*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == [self.images count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (ImageViewPage *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.images count] == 0) || (index >= [self.images count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ImageViewPage *imageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewPage"];
    NSMutableDictionary *imageDic = self.images[index];
    
    if (_isFromChat == nil) {
        imageViewController.imageFile = [imageDic valueForKey:@"imageUrl"];
        imageViewController.pageIndex = index;
        imageViewController.thumbImage = [imageDic valueForKey:@"thumbImage"];
    }
    else{ //Asset url of local file
        imageViewController.isFromChat = @"TRUE";
        imageViewController.pageIndex = index;
        imageViewController.imageFile = [imageDic valueForKey:@"media_url"];
        
        //Set Title
        NSArray *viewControllers = [_pageController viewControllers];
        
        if ([viewControllers count] > 0) {
            
            ImageViewPage *imageViewPage = [viewControllers objectAtIndex:0];
            int pageIndex = (int)imageViewPage.pageIndex;
            [self setPageTitle:pageIndex];
        }
    }
    
    return imageViewController;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
}

/*
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.images count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return _startPosition;
}*/

@end
