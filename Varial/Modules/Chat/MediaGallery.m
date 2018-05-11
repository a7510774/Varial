//
//  MediaGallery.m
//  EJabberChat
//
//  Created by Shanmuga priya on 5/14/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "MediaGallery.h"
#import "Util.h"
#import "ChatDBManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MediaGallery ()

@end

@implementation MediaGallery

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mediaDictionary = [[NSMutableDictionary alloc] init];
    medias = [[NSMutableArray alloc] init];
    [self designTheView];
    [self getGalleryList];
}

-(void)designTheView
{
    _headerView.title.text = NSLocalizedString(MEDIA, nil);
    [_headerView.logo setHidden:YES];
    
    //Set receiver profile image and name
    [_profileImage setImageWithURL:[NSURL URLWithString:_receiverImage] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    _profileName.text = _receiverName;
    
    //Add zoom
    [[Util sharedInstance] addImageZoom:_profileImage];
    
    _collectionView.backgroundColor = [UIColor clearColor];
    [Util createBottomLine:_profileView withColor:[UIColor darkGrayColor]];
}

//Get gallery list
- (void)getGalleryList{
    
    NSMutableArray *chats;
    
    if ([_isSingleChat isEqualToString:@"TRUE"]) {
        chats = [[ChatDBManager sharedInstance] getGalleryLog:_receiverID];
    }
    else
    {
        chats = [[ChatDBManager sharedInstance] getTeamGalleryLog:_receiverID];
    }
    
    for (NSMutableDictionary *message in chats) {
        
        BOOL outGoing = [[message valueForKey:@"is_outgoing"] boolValue];
        
        if (outGoing || (!outGoing && [[message valueForKey:@"is_local"] intValue] == 1)) {
            long timeStamp = [[message valueForKey:@"time"] longLongValue];
            NSString *header = [Util getChatHistoryTime:[NSString stringWithFormat:@"%ld",timeStamp]];
            NSMutableArray *groupedMedias = [mediaDictionary objectForKey:header];
            if (groupedMedias != nil) {
                [groupedMedias addObject:message];
            }
            else{
                groupedMedias = [[NSMutableArray alloc] init];
                [groupedMedias addObject:message];
                [mediaDictionary setObject:groupedMedias forKey:header];
            }
            
            //For Showing image sliders
            if([[message valueForKey:@"type"] intValue] == 2){
                NSMutableDictionary *mediaSlider = [message mutableCopy];
                [mediaSlider removeObjectForKey:@"message"];
                [medias addObject:mediaSlider];
            }
        }
    }
    [_collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma  mark CollectionView delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return [[mediaDictionary allKeys] count];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *header = [[mediaDictionary allKeys] objectAtIndex:section];
    return [[mediaDictionary objectForKey:header] count];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((collectionView.frame.size.width/3)-7 , (collectionView.frame.size.width/3)-7);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *header;
    if (kind == UICollectionElementKindSectionHeader)
    {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        UILabel *label = (UILabel*)[header viewWithTag:11];
        NSString *header = [[mediaDictionary allKeys] objectAtIndex:indexPath.section];
        label.text = header;
    }
    return  header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mediaCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    
    NSString *header = [[mediaDictionary allKeys] objectAtIndex:indexPath.section];
    NSMutableArray *groupedMedias = [mediaDictionary objectForKey:header];
    NSMutableDictionary *media = [groupedMedias objectAtIndex:indexPath.row];
    
    [[Util sharedInstance].assetLibrary assetForURL:[NSURL URLWithString:[media valueForKey:@"media_url"]]
                                        resultBlock:^(ALAsset *asset)
     {
         if (asset == nil) {
             imageView.image = [UIImage imageNamed:IMAGE_HOLDER];
         }
         else{
             //Get asset thumbnail
             CGImageRef thumbRef = [asset aspectRatioThumbnail];
             UIImage *thumbImage = [UIImage imageWithCGImage:thumbRef];
             imageView.image = thumbImage;
             imageView.contentMode = UIViewContentModeScaleAspectFill;
             imageView.clipsToBounds = YES;
         }
     }
                                       failureBlock:^(NSError *err) {
                                           NSLog(@"Asset Error: %@",[err localizedDescription]);
                                           imageView.image = [UIImage imageNamed:IMAGE_HOLDER];
                                       }];

    //[[Util sharedInstance] addImageZoom:imageView];
    
    //Remove play icon
    if ([[media valueForKey:@"type"] intValue] == 2) {
         [[imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    }
    //Add play icon
    else{
        UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30, 20, 20)];
        [imageView addSubview: playIcon];
        playIcon.image = [UIImage imageNamed:@"videoWhite.png"];
       
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *header = [[mediaDictionary allKeys] objectAtIndex:indexPath.section];
    NSMutableArray *mediasArray = [mediaDictionary objectForKey:header];
    NSMutableDictionary *media = [mediasArray objectAtIndex:indexPath.row];
    
    if([[media valueForKey:@"type"] intValue] == 2){
        int index = [Util getMatchedObjectPosition:@"media_url" valueToMatch:[media valueForKey:@"media_url"] from:medias type:0];
        if (index != -1) {
            [Util showSliderForChat:self forImage:medias atIndex:index withTitle:_receiverName];
        }
    }
    else{
        
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[media valueForKey:@"media_url"]]];
        
        //Add thumb image
        /*UIImageView *image = [[UIImageView alloc] initWithFrame:player.view.frame];
        [[Util sharedInstance].assetLibrary assetForURL:[NSURL URLWithString:[media valueForKey:@"media_url"]]
                                            resultBlock:^(ALAsset *asset)
         {
             //Get asset thumbnail
             CGImageRef thumbRef = [asset aspectRatioThumbnail];
             UIImage *thumbImage = [UIImage imageWithCGImage:thumbRef];
             image.image = thumbImage;
             image.contentMode = UIViewContentModeScaleAspectFill;
             image.clipsToBounds = YES;
             [player.moviePlayer.backgroundView addSubview:image];
         }
                                           failureBlock:^(NSError *err) {
                                               NSLog(@"Asset Error: %@",[err localizedDescription]);
                                               image.image = [UIImage imageNamed:IMAGE_HOLDER];
                                           }];
        */
        [self presentMoviePlayerViewControllerAnimated:player];
    }
    
}

@end
