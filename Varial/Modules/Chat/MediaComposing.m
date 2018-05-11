//
//  MediaComposing.m
//  EJabberChat
//
//  Created by Shanmuga priya on 5/13/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "MediaComposing.h"
#import "Util.h"
#import "Config.h"
#import "FriendsChat.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ChatDBManager.h"

@interface MediaComposing ()

@end

@implementation MediaComposing

NSArray *titles;
- (void)viewDidLoad
{
    [super viewDidLoad];

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    status = [ALAssetsLibrary authorizationStatus];
    // Do any additional setup after loading the view.
    titles = [[NSArray alloc] initWithObjects:NSLocalizedString(SEND_PHOTO, nil), NSLocalizedString(SEND_VIDEO, nil), nil];
    [_sendButton addTarget:self action:@selector(tappedSend:) forControlEvents:UIControlEventTouchUpInside];
    [self getMediaConfig];
    [self designTheView];
    [self createPopupView];
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[ChatDBManager sharedInstance] hideOrShowChatBadge:TRUE];
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)designTheView
{
    NSString *title;
    if (_type == 0 || _type == 2) {
        title = titles[0];
    }
    if (_type == 1) {
         title = titles[1];
    }
    
    [_headerView setHeader:[NSString stringWithFormat:NSLocalizedString(title, nil)]];
    [_headerView.logo setHidden:YES];
    _headerView.chatIcon.hidden = YES;
    
    [Util createRoundedCorener:_sendButton withCorner:3];
    [Util createRoundedCorener:_cancelButton withCorner:3];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    medias = [[NSMutableArray alloc]init];
    mediaDict = [[NSMutableDictionary alloc]init];
    mediaPickerController = [[IQMediaPickerController alloc] init];
    mediaPickerController.delegate = self;
    isCaptured = isMaxFileShown = FALSE;
    
    //Check privacy status
    if (status != ALAuthorizationStatusAuthorized) {
        [[Util sharedInstance] showGalleryAlert];
    }
    else{
        if(_type == 0 )
            [self openImageGallery];
        else if(_type == 1)
            [self openVideoGallery];
        else if(_type == 2)
            [self openCamera];
    }
    
    //Alert window
    mediaExceed = [[NetworkAlert alloc] init];
    [mediaExceed setNetworkHeader:NSLocalizedString(MEDIA, nil)];
    [mediaExceed.button setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
}

- (void)getMediaConfig{
    
    //Get configuration from the session
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"] != nil){
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaConfig"];
        maxImage =  [[config valueForKey:@"default_image_file"] intValue];
        maxVideo =  [[config valueForKey:@"default_video_file"] intValue];
        maxImageFileSize = [[config valueForKey:@"default_image_size"] intValue];
        maxVideoFileSize = [[config valueForKey:@"default_video_size"] intValue];
    }
}

//Create popup view
- (void)createPopupView{
    
    mediaCountPopup = [KLCPopup popupWithContentView:mediaExceed showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
    
    mediaPopupView = [[MediaPopup alloc] init];
    [mediaPopupView setDelegate:self];
    [mediaPopupView.okButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    mediaPopup = [KLCPopup popupWithContentView:mediaPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

//Select picker Window to be opened
-(void)openWindow
{
    //Check privacy status
    if (status != ALAuthorizationStatusAuthorized) {
        [[Util sharedInstance] showGalleryAlert];
    }
    else{
        if(_type == 0 || _type == 2)
            [mediaPopup show];
        else if(_type == 1)
            [self openVideoGallery];
    }
}

#pragma marg - MediaPopup delegates
-(void)onCameraClick{
    [mediaPopup dismiss:YES];
    [self openCamera];
}

-(void)onGalleryClick{
    [mediaPopup dismiss:YES];
    [self openImageGallery];
}

- (void)onOkClick{
    [mediaPopup dismiss:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark CollectionView Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [medias count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((collectionView.frame.size.width/3)-7 , (collectionView.frame.size.width/3)-7);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    UIButton *button = (UIButton*)[cell viewWithTag:11];
    
    NSDictionary *media = [medias objectAtIndex:indexPath.row];
    UIImage *img = [media objectForKey:@"mediaThumb"];
    imageView.image = img;
    imageView.clipsToBounds = YES;

    if ([[media objectForKey:@"mediaType"] intValue] == 1)
    {
        //Add zoom for Comments Image
        [[Util sharedInstance] addImageZoom:imageView];
    }
    else
    {
        imageView.userInteractionEnabled = FALSE;
    }
    
    [button addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *media = [medias objectAtIndex:indexPath.row];
    if ([[media objectForKey:@"mediaType"] intValue] != 1)
    {
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[media valueForKey:@"mediaUrl"]]];
        [self presentMoviePlayerViewControllerAnimated:player];
    }
}

//Delete media from collection View
-(void)removeImage:(UIButton *) sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
    NSArray *array = [[NSArray alloc]initWithObjects:indexPath, nil];
    [medias removeObjectAtIndex:indexPath.row];
    [self.collectionView deleteItemsAtIndexPaths:array];
    [_addMoreButton setHidden:NO];
}

//Open Camera
-(void)openCamera
{
    /*isCaptured = TRUE;
    [mediaPickerController setMediaType:IQMediaPickerControllerMediaTypePhoto];
    mediaPickerController.allowsPickingMultipleItems = FALSE;
    [self presentViewController:mediaPickerController animated:YES completion:nil];*/
    
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

//Open Image Gallery
-(void)openImageGallery
{
    [mediaPickerController setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
    mediaPickerController.allowsPickingMultipleItems = TRUE;
    isCaptured = FALSE;
    [self presentViewController:mediaPickerController animated:YES completion:NULL];
}

//Open VideoGallery
-(void)openVideoGallery
{
    [mediaPickerController setMediaType:IQMediaPickerControllerMediaTypeVideoLibrary];
    mediaPickerController.allowsPickingMultipleItems = FALSE;
    [self presentViewController:mediaPickerController animated:YES completion:NULL];
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *capturedImage = info[UIImagePickerControllerOriginalImage];
    
    //Save image in local
    [[Util sharedInstance].assetLibrary saveImage:capturedImage toAlbum:ALBUM_NAME withCompletionBlock:^(NSError *error, NSURL *assetUrl) {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:assetUrl forKey:IQMediaImage];
        [images addObject:dict];
        [self createMediaResource:images ofType:TRUE];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark IQMediaPickerController

//Revceived the choosen assets from media library
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)mediaInfo;
{
    NSLog(@"Info: %@",mediaInfo);
    
    [_collectionView reloadData];
    if (mediaInfo != nil && [[mediaInfo allKeys] count] > 0) {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:0];
        
        //Check image asset
        if([key isEqualToString:@"IQMediaTypeImage"]){
            
            //Assign images to array
            if (isCaptured) {
                //[self addCapturedMedia: [[[mediaInfo objectForKey:key] objectAtIndex:0] valueForKey:@"IQMediaURL"] ofType:TRUE];
                [self createMediaResource:[mediaInfo objectForKey:key] ofType:TRUE];
            }
            else{
                isMaxFileShown = FALSE;
                [self createMediaResource:[mediaInfo objectForKey:key] ofType:TRUE];
            }
        }
        if([key isEqualToString:@"IQMediaTypeVideo"]){
            //Assign videos to array
            isMaxFileShown = FALSE;
            [self createMediaResource:[mediaInfo objectForKey:key] ofType:FALSE];
        }
    }
    else{
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(IMAGE_NOT_CAPTURED, nil) withDuration:3.0];
    }
}


//Create mutable array of medias
- (void)createMediaResource:(NSMutableArray *)mediaData ofType:(BOOL) isPhotos
{
    if([mediaData count] > 0) {
        
        NSString *mediaPath = isPhotos ? [[[mediaData objectAtIndex:0] valueForKey:@"IQMediaImage"] absoluteString] :  [[[mediaData objectAtIndex:0] valueForKey:@"IQMediaAssetURL"] absoluteString];
        
        int count = isPhotos ? maxImage : maxVideo;
        int size = isPhotos ? maxImageFileSize : maxVideoFileSize;
        
        //1.Check media has valid Format
        if([[Util sharedInstance] checkMediaHasValidFormat:isPhotos ofMediaUrl:mediaPath]){
            
            //2. Check media has valid size
            [[Util sharedInstance] checkMediaHasValidSize:isPhotos ofMediaUrl:mediaPath withCallBack:^(NSData * data, UIImage * thumbnail){
                
                if(data != nil){
                    
                    //Check media exceed the length
                    if ([medias count] < count) {
                        
                        // Compress image and convert to base64
                        UIImage *compressedImage = [Util imageWithImage:thumbnail scaledToWidth:thumbnail.size.width/8];
                        NSString *image64 = [Util imageToNSString:compressedImage];
                        [[NSUserDefaults standardUserDefaults] setObject:image64 forKey:mediaPath];
                        
                        NSMutableDictionary *media = [[NSMutableDictionary alloc]init];
                        [media setObject:image64 forKey:@"image64"];
                        [media setObject:thumbnail forKey:@"mediaThumb"];
                        [media setObject:data forKey:@"assetData"];
                        [media setValue:[NSNumber  numberWithBool:isPhotos] forKey:@"mediaType"];
                        [media setObject:mediaPath forKey:@"mediaUrl"];
                        [media setObject:[NSNumber numberWithBool:NO] forKey:@"isCaptured"];
                        [medias addObject:media];
                        [self.collectionView reloadData];
                        [mediaData removeObjectAtIndex:0];
                        [self createMediaResource:mediaData ofType:isPhotos];
                    }
                    else{
                        if(isPhotos){
                            mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(IMAGE_ALLOWED, nil),count];
                            [mediaCountPopup show];
                        }
                        else{
                            mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(VIDEOS_ALLOWED, nil),count];
                            [mediaCountPopup show];
                            
                        }
                    }
                    if ([medias count] == count) {
                        [_addMoreButton setHidden:YES];
                    }
                    
                }
                else{
                    [mediaData removeObjectAtIndex:0];
                    if (!isMaxFileShown) {
                        mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(MEDIA_SIZE_SHOULD_BE, nil),size/1024];
                        [mediaCountPopup show];
                        isMaxFileShown = TRUE;
                    }
                    [self createMediaResource:mediaData ofType:isPhotos];
                }
            }];
        }
        else{
            [mediaData removeObjectAtIndex:0];
            [self createMediaResource:mediaData ofType:isPhotos];
        }
    }
    
}

- (void) addCapturedMedia:(NSURL *)mediaURL ofType:(BOOL) isPhotos
{
    int count = isPhotos ? maxImage : maxVideo;
    int size = isPhotos ? maxImageFileSize : maxVideoFileSize;
    
    //1.Check media has valid Format
    if([[Util sharedInstance] checkFileHasValidFormat:isPhotos ofMediaUrl:mediaURL.relativePath]){
        
        //2.Check media has valid size
        [[Util sharedInstance] checkFileHasValidSize:isPhotos ofMediaUrl:mediaURL.relativePath withCallBack:^(NSData * data, UIImage * thumbnail){
            
            if(data != nil){
                
                //Check media exceed the length
                if ([medias count] < count) {
                    
                    // Compress image and convert to base64
                    UIImage *compressedImage = [Util imageWithImage:thumbnail scaledToWidth:thumbnail.size.width/8];
                    NSString *image64 = [Util imageToNSString:compressedImage];
                    
                    NSMutableDictionary *media = [[NSMutableDictionary alloc]init];
                    [media setObject:image64 forKey:@"image64"];
                    [media setObject:thumbnail forKey:@"mediaThumb"];
                    [media setObject:data forKey:@"assetData"];
                    [media setValue:[NSNumber  numberWithBool:isPhotos] forKey:@"mediaType"];
                    [media setObject:mediaURL forKey:@"mediaUrl"];
                    [media setObject:[NSNumber numberWithBool:YES] forKey:@"isCaptured"];
                    [medias addObject:media];
                    [self.collectionView reloadData];
                }
                else{
                    mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(MEDIA_SIZE_ALLOWED, nil),count];
                    [mediaCountPopup show];
                }
                if ([medias count] == count) {
                    [_addMoreButton setHidden:YES];
                }
            }
            else{
                if (!isMaxFileShown) {
                    mediaExceed.subTitle.text = [NSString stringWithFormat:NSLocalizedString(MEDIA_SIZE_SHOULD_BE, nil),size/1024];
                    [mediaCountPopup show];
                    isMaxFileShown = TRUE;
                }
            }            
        }];
    }
    
}

//Action for AddMore Button
- (IBAction)tappedAddMore:(id)sender
{
    [self openWindow];
}

//Action for Cancel Button
- (IBAction)tappedCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//Action for Send
- (IBAction)tappedSend:(id)sender
{
    NSArray *controllers = [self.navigationController viewControllers];
    UIViewController *viewController = [controllers objectAtIndex:[controllers count] - 2];
    FriendsChat *friendsChat = (FriendsChat *) viewController;
    

    //Check privacy status
    if (status != ALAuthorizationStatusAuthorized) {
        [[Util sharedInstance] showGalleryAlert];
    }
    else{
        if (friendsChat.isBlocked)
        {
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(INVALID_OPERATION, nil)];
        }
        else if ([medias count] != 0 ) {
            
            XMPPStream *xmppStream = [XMPPServer sharedInstance].xmppStream;
            if ([[Util sharedInstance] getNetWorkStatus] && xmppStream.isAuthenticated && xmppStream.isConnected) {
                friendsChat.medias = medias;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_INTERNET_CONNECTION, nil)];
            }
        }
    }
}
@end
