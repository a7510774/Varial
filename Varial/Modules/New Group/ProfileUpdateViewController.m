//
//  ProfileUpdateViewController.m
//  Varial
//
//  Created by Leo Chelliah on 07/02/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import "ProfileUpdateViewController.h"
#import "HeaderView.h"
#import "UserMessages.h"
#import "FeedsDesign.h"
#import "ProfileUpdateCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileUpdateViewController () <HeaderViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UICollectionView *updateProfileCollectionView;

@end

@implementation ProfileUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
    [self setUpUI];
}

-(void)viewWillAppear:(BOOL)animated{
    if(self.updateImages.count == 0){
        [self addEmptyMessageForProfileCollection];
    } else {
        [[[self.updateImages reverseObjectEnumerator] allObjects]mutableCopy];
    }
}

- (void)setUpUI {
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.updateProfileCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ProfileUpdateCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ProfileUpdateCollectionViewCell class])];
    
    _headerView.delegate = self;
    [_headerView setBackHidden:NO];
    [_headerView setHeader:NSLocalizedString(PROFILEUPDATE, nil)];
    [_headerView.logo setHidden:YES];
}

#pragma mark -
#pragma mark - CollectionView delegate and datasource
#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.updateImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProfileUpdateCollectionViewCell *aCell = [collectionView
                                             dequeueReusableCellWithReuseIdentifier:
                                             NSStringFromClass([ProfileUpdateCollectionViewCell class])
                                             forIndexPath:indexPath];
    static UIImage *placeholderImage = nil;
    if (!placeholderImage) {
        placeholderImage = [UIImage imageNamed:@"icon_skatting_logo"];
    }
    
    NSString *urlStr = self.updateImages[indexPath.row][@"profile_image"];
    NSString * downloadUrl = [NSString stringWithFormat:@"https://dqloq8l38fi51.cloudfront.net%@",urlStr];
    [aCell.profileUpdateImage sd_setImageWithURL:[NSURL URLWithString:downloadUrl]
                          placeholderImage:placeholderImage
                                   options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    return aCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(self.view.frame.size.width/4, self.view.frame.size.width/4);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateProfileImageatIndexPath:indexPath.row];
}

//Step 1 - launching the actionsheet with a button action
- (void) updateProfileImageatIndexPath:(NSInteger)index
{
    [editProfilePopup dismiss:YES];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Profile Update" message:@"Choose any one" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Use Profile Image" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self setProfileImageAtIndex:index];
//        [KLCMediaPopup show];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"View" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
        ProfileUpdateCollectionViewCell *aCell = (ProfileUpdateCollectionViewCell *)[self.updateProfileCollectionView cellForItemAtIndexPath:path];
        [[Util sharedInstance] zoomImageView:aCell.profileUpdateImage];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self deleteProfileImageAtIndex:index];
//        _profileView.profileImage.image = nil;
        
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

//Set ProfileImage Service
-(void) setProfileImageAtIndex:(NSInteger)index{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[self.updateImages objectAtIndex:index][@"id"] forKey:@"id"];
    [inputParams setValue:@"0" forKey:@"delete_flag"];
    [inputParams setValue:[self.updateImages objectAtIndex:index][@"default"] forKey:@"default"];
    
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:UPDATE_PROFILE_IMAGE withCallBack:^(NSDictionary * response) {
        if([[response valueForKey:@"status"] boolValue]){
            if(![[response valueForKey:@"default"] boolValue]){
                [self.delegate sendDataToA];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } isShowLoader:YES];
}

//Delete ProfileImage Service
-(void) deleteProfileImageAtIndex:(NSInteger)index{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:[self.updateImages objectAtIndex:index][@"id"] forKey:@"id"];
    [inputParams setValue:@"1" forKey:@"delete_flag"];
    [inputParams setValue:[self.updateImages objectAtIndex:index][@"default"] forKey:@"default"];
    [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:UPDATE_PROFILE_IMAGE withCallBack:^(NSDictionary * response) {
        if([[response valueForKey:@"status"] boolValue]){
            NSString * getDefault = [NSString stringWithFormat:@"%@", [self.updateImages objectAtIndex:index][@"default"]];
            [self.updateImages removeObjectAtIndex:index];
//            [self.delegate deleteProfileImageWithId:index];
            if(self.updateImages.count == 0)
                [self addEmptyMessageForProfileCollection];
            NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
            [self.updateProfileCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            [self.updateProfileCollectionView reloadData];
            [self.delegate sendDataToA];
            if ([getDefault isEqualToString:@"1"]){
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } isShowLoader:YES];
}

//Add empty message in Collectionview background view
- (void)addEmptyMessageForProfileCollection {
        [Util addEmptyMessageToCollection:self.updateProfileCollectionView withMessage:@"No Image Available" withColor:UIColorFromHexCode(DEFAULT_TEXT_COLOR)];
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

@end
