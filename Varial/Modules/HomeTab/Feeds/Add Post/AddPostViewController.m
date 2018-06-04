//
//  AddPostViewController.m
//  Varial
//
//  Created by Guru Prasad chelliah on 12/24/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "AddPostViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "GMImagePickerController.h"
//Cell
#import "AddPostMediaCollectionViewCell.h"
#import "AddPostLibraryCollectionViewCell.h"
#import "LibraryInsideCollectionViewCell.h"

#define ICON_FLASH @"icon_flash"
#define ICON_RECORD @"icon_record"

@interface AddPostViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate , AVCaptureFileOutputRecordingDelegate>
{
    PHFetchResult *fetchResult;
    BOOL isRecordingVideo;
    BOOL isPresentCameraView;
    double myDoubleTimerCount;
    NSTimer *recordingTimer;
}

@property(nonatomic, strong) AVCaptureSession *captureSessionCamera;
@property(nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutputCamera;
@property(nonatomic, strong) AVCaptureDevice *captureDeviceCamera;

@property(nonatomic, strong) AVCaptureSession *captureSessionVideo;
@property(nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutputVideo;
@property(nonatomic, strong) AVCaptureDevice *captureDeviceVideo;

@property(nonatomic) BOOL isCapturingImage;

@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;
@property (strong) NSArray *collectionsFetchResultsAssets;
@property (strong) NSArray *collectionsFetchResultsTitles;
@property (strong) PHCachingImageManager *imageManager;
@property(nonatomic, strong)NSMutableArray *recentsArray;

@property(nonatomic) int timeSec;
@property(nonatomic) int timeMin;

@end

@implementation AddPostViewController

@synthesize recentsArray;

@synthesize captureSessionVideo,captureMovieFileOutputVideo,captureDeviceVideo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpUI];
    [self setUpModel];
    [self loadModel];
    
    //[self loadLibrary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"viewWillApper.frame %@",self.viewCategory);
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark -
#pragma mark - View Init and Model -
#pragma mark -

- (void)setUpUI {
    
    [self.chooseCategoryCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([AddPostMediaCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([AddPostMediaCollectionViewCell class])];
    
    [self.chooseCategoryCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LibraryInsideCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([LibraryInsideCollectionViewCell class])];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self showcameraView];
    
    [HELPER imageWithRenderingModeWithButton:ICON_FLASH color:[UIColor grayColor] button:self.btnFlash];
}

- (void)setUpModel {
    
    isPresentCameraView = YES;
    recentsArray = [NSMutableArray new];
    [self setupCamera];
    [self setupVideo];
}

- (void)loadModel {
    
    if (self.gIsPresentVideoClick) {
        
        [self showVideoiew];
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:1 inSection:0];
        [self.chooseCategoryCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    
    else if (self.gIsPresentVideoClick) {
        
        [self showVideoiew];
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:1 inSection:0];
        [self.chooseCategoryCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    
    else {
        
        [self showcameraView];
        
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.chooseCategoryCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

- (void)setupCamera {
    
    self.captureSessionCamera = [[AVCaptureSession alloc] init];
    self.captureSessionCamera.sessionPreset = AVCaptureSessionPresetHigh;
    
    self.captureDeviceCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if(self.captureDeviceCamera.hasTorch){
        if ([self.captureDeviceCamera lockForConfiguration:nil]) {
            self.captureDeviceCamera.flashMode = AVCaptureFlashModeOff;
        }
    }
    
    if (self.captureDeviceCamera)
    {
        NSError *error;
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDeviceCamera error:&error];
        if (!error)
        {
            if ([self.captureSessionCamera canAddInput:videoInput])
            {
                [self.captureSessionCamera addInput:videoInput];
                AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSessionCamera];
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                
                previewLayer.masksToBounds = true;
                
                CGRect aFrame = self.viewCategory.bounds;
                // aFrame.origin.y = -44;
                //aFrame.size.height = 450;
                previewLayer.frame = aFrame;
                
                [self.viewCategory.layer addSublayer:previewLayer];
                
                // previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                
                //[self.captureSessionCamera startRunning];
            }
        }
    }
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 0) {
        self.captureDeviceCamera = devices[0];
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDeviceCamera error:&error];
        
        if ([self.captureSessionCamera canAddInput:input]) {
            [self.captureSessionCamera addInput:input];
        }
        
        self.captureStillImageOutputCamera = [AVCaptureStillImageOutput new];
        NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.captureStillImageOutputCamera setOutputSettings:settings];
        [self.captureSessionCamera addOutput:self.captureStillImageOutputCamera];
    }
}

- (void)setupVideo {
    
    captureSessionVideo = [[AVCaptureSession alloc] init];

    //ADD VIDEO INPUT
    AVCaptureDevice *VideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (VideoDevice)
    {
        NSError *error;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:VideoDevice error:&error];
        if (!error)
        {
            if ([captureSessionVideo canAddInput:input])
                [captureSessionVideo addInput:input];
            else
                NSLog(@"Couldn't add video input");
        }
        else
        {
            NSLog(@"Couldn't create video input");
        }
    }
    else{
        NSLog(@"Couldn't create video capture device");
    }
    
    //ADD AUDIO INPUT
    NSLog(@"Adding audio input");
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    
    if (audioInput){
        [captureSessionVideo addInput:audioInput];
    }
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 0) {
        self.captureDeviceVideo = devices[0];
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDeviceVideo error:&error];
        
        if ([self.captureSessionVideo canAddInput:input]) {
            [self.captureSessionVideo addInput:input];
        }
    }
        
    //----- ADD OUTPUTS -----
    
    //ADD VIDEO PREVIEW LAYER
    NSLog(@"Adding video preview layer");

    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSessionVideo];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    previewLayer.masksToBounds = true;
    
    CGRect aFrame = self.viewVideo.bounds;
    // aFrame.origin.y = -44;
    //aFrame.size.height = 450;
    previewLayer.frame = aFrame;
    
    [self.viewVideo.layer addSublayer:previewLayer];
    
    //ADD MOVIE FILE OUTPUT
    NSLog(@"Adding movie file output");
    captureMovieFileOutputVideo = [[AVCaptureMovieFileOutput alloc] init];
    
    Float64 TotalSeconds = 60;
    int32_t preferredTimeScale = 30;
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
    captureMovieFileOutputVideo.maxRecordedDuration = maxDuration;
    
    captureMovieFileOutputVideo.minFreeDiskSpaceLimit = 1024 * 1024;
    
    if ([captureSessionVideo canAddOutput:captureMovieFileOutputVideo])
        [captureSessionVideo addOutput:captureMovieFileOutputVideo];

    [captureSessionVideo setSessionPreset:AVCaptureSessionPresetMedium];
    
    if ([captureSessionVideo canSetSessionPreset:AVCaptureSessionPreset640x480])
        [captureSessionVideo setSessionPreset:AVCaptureSessionPreset640x480];
    
    //----- START THE CAPTURE SESSION RUNNING -----
    //[captureSessionVideo startRunning];
}

- (void)loadLibrary {
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        
        NSLog(@"album title %@", collection.localizedTitle);
        
    }];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.wantsIncrementalChangeDetails = YES;
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    PHFetchResult *fetchResult;
    
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *sub in albums)
    {
        fetchResult = [PHAsset fetchAssetsInAssetCollection:sub options:options];
        
    }
    NSMutableArray *recentsArray1 = [[NSMutableArray alloc]init];
    
    PHFetchResult *assetCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum | PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    NSLog(@"Fetch resut cpunt %lu", (unsigned long)assetCollection.count);
    
    for (PHAssetCollection *sub in assetCollection)
    {
        PHFetchResult *assetsInCollection = [PHAsset fetchAssetsInAssetCollection:sub options:nil];
        
        for (PHAsset *asset in assetsInCollection)
        {
            [recentsArray1 addObject:asset];
            
            if (recentsArray1.count >= 25)
                break;
        }
        
        if (recentsArray1.count >= 25)
            break;
        
    }
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // this one is key
    requestOptions.synchronous = YES;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    for (PHAsset *asset in recentsArray1) {
        // Do something with the asset
        
        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            
                            [recentsArray addObject:image];
                        }];
        
    }
    
    self.imgViewLibrary.image = recentsArray[0];
}


#pragma mark -
#pragma mark - CollectionView delegate and datasource
#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AddPostMediaCollectionViewCell *aCell = [collectionView
                                             dequeueReusableCellWithReuseIdentifier:
                                             NSStringFromClass([AddPostMediaCollectionViewCell class])
            
                                             forIndexPath:indexPath];
    
//    if (indexPath.row == 0) {
//
//        //[self showLibraryView];
//    }
//
//    else {
//
//        if (indexPath.row == 1) {
//
//            //[self showcameraView];
//
//            [aCell.btnMedia addTarget:self action:@selector(captureImage:) forControlEvents:UIControlEventTouchUpInside];
//        }
//
//        else if (indexPath.row == 2) {
//
//           // [self showVideoiew];
//
//            [aCell.btnMedia addTarget:self action:@selector(captureVideo:) forControlEvents:UIControlEventTouchUpInside];
//        }
//    }
   
        if (indexPath.row == 0) {
            
            [aCell.btnMedia addTarget:self action:@selector(captureImage:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        else if (indexPath.row == 1) {
            
            [aCell.btnMedia addTarget:self action:@selector(captureVideo:) forControlEvents:UIControlEventTouchUpInside];
        }
    
    return aCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 480)
    {
        return CGSizeMake(320, 200);
    }
    if(result.height == 568)
    {
        return CGSizeMake(320, 200);
    }
    
    NSLog(@"%f",self.chooseCategoryCollectionView.frame.size.width);

    return CGSizeMake(self.chooseCategoryCollectionView.frame.size.width, 200);
}

#pragma mark -
#pragma mark - Scrollview delegate
#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGRect visibleRect = (CGRect){.origin = self.chooseCategoryCollectionView.contentOffset, .size = self.chooseCategoryCollectionView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.chooseCategoryCollectionView indexPathForItemAtPoint:visiblePoint];
    NSLog(@"%ld %ld",(long)visibleIndexPath.row,(long)visibleIndexPath.section);
    
//    if (visibleIndexPath.row == 0) {
//
//        [self showLibraryView];
//
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.allowsEditing = NO;
//        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        [self presentViewController:picker animated:YES completion:NULL];
//    }
//
//    else if (visibleIndexPath.row == 1) {
//
//        [self showcameraView];
//    }
//
//    else if (visibleIndexPath.row == 2) {
//
//        [self showVideoiew];
//    }
    
    
   if (visibleIndexPath.row == 0) {
        
        [self showcameraView];
    }
    
    else if (visibleIndexPath.row == 1) {
        
        [self showVideoiew];
    }
}

#pragma mark -
#pragma mark - Imagecontroller delegate
#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(self.myUpdateFilterBlock) {
        self.myUpdateFilterBlock(YES,image,nil);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
//    [HELPER showAlertControllerIn:self title:APP_NAME message:@"Do you want use this image ?" defaultButtonTitle:@"Yes" defaultActionBlock:^(UIAlertAction *action) {
//
//        if(self.myUpdateFilterBlock) {
//            self.myUpdateFilterBlock(YES,image,nil);
//        }
//
//        [self.navigationController popViewControllerAnimated:YES];
//
//    } cancelButtonTitle:@"No" cancelActionBlock:^(UIAlertAction *action) {
//
//        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:1 inSection:0];
//        [self.chooseCategoryCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
//
//        [self showcameraView];
//
//    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:1 inSection:0];
    [self.chooseCategoryCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    [self showcameraView];
}

#pragma mark -
#pragma mark - Camera Methods
#pragma mark -

- (IBAction)switchFlash:(id)sender {
    
//        [self.captureDeviceCamera lockForConfiguration:nil];
//        self.captureDeviceCamera.flashMode = AVCaptureFlashModeAuto;
//        [self.captureDeviceCamera unlockForConfiguration];
//
//    [self.captureSessionCamera commitConfiguration];
    
    if (self.captureDeviceCamera.isFlashAvailable) {
        if (self.captureDeviceCamera.flashActive) {
            if ([self.captureDeviceCamera lockForConfiguration:nil]) {
                self.captureDeviceCamera.flashMode = AVCaptureFlashModeOff;
                [sender setSelected:NO];
                [HELPER imageWithRenderingModeWithButton:ICON_FLASH color:[UIColor grayColor] button:self.btnFlash];
            }
        } else {
            if ([self.captureDeviceCamera lockForConfiguration:nil]) {
                self.captureDeviceCamera.flashMode = AVCaptureFlashModeOn;
                [HELPER imageWithRenderingModeWithButton:ICON_FLASH color:[UIColor whiteColor] button:self.btnFlash];
                [sender setSelected:YES];
            }
        }
        [self.captureDeviceCamera unlockForConfiguration];
        //[self.captureSessionCamera commitConfiguration];
    }
}

- (IBAction)showFrontCamera:(id)sender {
    
    if (isPresentCameraView) {

        AVCaptureDevice *backCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
        AVCaptureDevice *frontCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];

        if (!self.isCapturingImage) {
            if (self.captureDeviceCamera == backCaptureDevice) {
                self.captureDeviceCamera = frontCaptureDevice;

            } else if (self.captureDeviceCamera == frontCaptureDevice) {
                self.captureDeviceCamera = backCaptureDevice;
            }

            [self switchCaptureDevice];
        }
    }

    else {
    
        AVCaptureDevice *backCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
        AVCaptureDevice *frontCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
        
        if (!self.isCapturingImage) {
            if (self.captureDeviceVideo == backCaptureDevice) {
                self.captureDeviceVideo = frontCaptureDevice;
                
            } else if (self.captureDeviceVideo == frontCaptureDevice) {
                self.captureDeviceVideo = backCaptureDevice;
            }
            
            [self switchCaptureDevice];
        }
    }
}

- (void)switchCaptureDevice {
    
    if (isPresentCameraView) {

        //Image
        [self.captureSessionCamera beginConfiguration];
        AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDeviceCamera error:nil];
        
        for (AVCaptureInput *oldInput in self.captureSessionCamera.inputs) {
            [self.captureSessionCamera removeInput:oldInput];
        }
        
        [self.captureSessionCamera addInput:newInput];
        [self.captureSessionCamera commitConfiguration];
    }
        
    
    else {
        
        //Video
        [captureSessionVideo beginConfiguration];
        AVCaptureDeviceInput *newInputVideo = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDeviceVideo error:nil];
        
        for (AVCaptureInput *oldInput in self.captureSessionVideo.inputs) {
            [self.captureSessionVideo removeInput:oldInput];
        }
        
        [self.captureSessionVideo addInput:newInputVideo];
        [self.captureSessionVideo commitConfiguration];
    }
}


#pragma mark -
#pragma mark - Video Recording delegate
#pragma mark -

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    [captureSessionVideo stopRunning];
    
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            RecordedSuccessfully = [value boolValue];
        }
    }
    if (RecordedSuccessfully)
    {
        if(self.myUpdateFilterBlock) {
            self.myUpdateFilterBlock(NO,nil,outputFileURL);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
//        [HELPER showAlertControllerIn:self title:APP_NAME message:@"Do you want use this video ?" defaultButtonTitle:@"Yes" defaultActionBlock:^(UIAlertAction *action) {
//
//            if(self.myUpdateFilterBlock) {
//                self.myUpdateFilterBlock(NO,nil,outputFileURL);
//            }
//
//            [self.navigationController popViewControllerAnimated:YES];
//
//        } cancelButtonTitle:@"No" cancelActionBlock:^(UIAlertAction *action) {
//
//            [self showAndHideTimer];
//            [captureSessionVideo startRunning];
//        }];
    }
}


#pragma mark -
#pragma mark - Button Action Methods -
#pragma mark -

- (void)captureImage:(UIButton *)sender {
    
    [HELPER tapAnimationFor:sender withCallBack:^{
        
        AVCaptureConnection *videoConnection = nil;
        
        for (AVCaptureConnection *connection in self.captureStillImageOutputCamera.connections) {
            for (AVCaptureInputPort *port in connection.inputPorts) {
                if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                    videoConnection = connection;
                    break;
                }
            }
            
            if (videoConnection) {
                break;
            }
        }
        
        [self.captureStillImageOutputCamera captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
            if (imageSampleBuffer != NULL) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                UIImage *capturedImage = [[UIImage alloc] initWithData:imageData];
                
                // if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
                
                //  UIImage *aImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationLeftMirrored];
                
                [self.captureSessionCamera stopRunning];
                
                if(self.myUpdateFilterBlock) {
                    self.myUpdateFilterBlock(YES,capturedImage,nil);
                }
                
                [self.navigationController popViewControllerAnimated:YES];
                
//                [HELPER showAlertControllerIn:self title:APP_NAME message:@"Do you want use this photo ?" defaultButtonTitle:@"Yes" defaultActionBlock:^(UIAlertAction *action) {
//
//                    if(self.myUpdateFilterBlock) {
//                        self.myUpdateFilterBlock(YES,capturedImage,nil);
//                    }
//
//                    [self.navigationController popViewControllerAnimated:YES];
//                    //[self dismissViewControllerAnimated:YES completion:nil];
//
//                } cancelButtonTitle:@"No" cancelActionBlock:^(UIAlertAction *action) {
//
//                    [self.captureSessionCamera startRunning];
//                }];
            }
        }];
    }];
}

- (void)captureVideo:(UIButton *) sender {
    
    [HELPER tapAnimationFor:sender withCallBack:^{
        
        if (!isRecordingVideo)
        {
            [HELPER imageWithRenderingModeWithButton:ICON_RECORD color:[UIColor redColor] button:sender];
            
            isRecordingVideo = YES;
            
            //Create temporary URL to record to
            NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
            NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:outputPath])
            {
                NSError *error;
                if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
                {
                    
                }
            }
            
            [self showAndHideTimer];
            [self initalizeTimer];
            
            self.chooseCategoryCollectionView.scrollEnabled = NO;
            self.chooseCategoryCollectionView.pagingEnabled = NO;
            
            //Start recording
            [captureMovieFileOutputVideo startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        }
        else
        {
            self.chooseCategoryCollectionView.scrollEnabled = YES;
            self.chooseCategoryCollectionView.pagingEnabled = YES;
            
            isRecordingVideo = NO;
            [self stopTimer];

            [HELPER imageWithRenderingModeWithButton:ICON_RECORD color:[UIColor lightGrayColor] button:sender];

            [captureMovieFileOutputVideo stopRecording];
        }
    }];
}

- (IBAction)libraryBtnTapped:(UIButton *)sender {
    
    [self showLibraryView];

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.chooseCategoryCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (IBAction)cameraBtnTapped:(UIButton *)sender {
    
    [self showcameraView];

    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.chooseCategoryCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (IBAction)videoBtnTapped:(UIButton *)sender {
    
    [self showVideoiew];
    
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:1 inSection:0];
    [self.chooseCategoryCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (IBAction)cancelBtnTapped:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - Private Methods -
#pragma mark -

- (void)showLibraryView {
    
    // [HELPER transitionAnimationFor:self.viewLibrary withAnimationBlock:^{
    
    isPresentCameraView = NO;
    
    [self.captureSessionCamera stopRunning];
    
    self.viewCategory.hidden = YES;
    self.viewLibrary.hidden = NO;
    self.viewVideo.hidden = YES;
    self.btnFlash.hidden = NO;
    
    [self showAndHideTimer];
    
    [self.btnLibrary setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnCamera setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    // }];
}

- (void)showcameraView {
    
    //  [HELPER transitionAnimationFor:self.viewCategory withAnimationBlock:^{
    
    isPresentCameraView = YES;
    [captureSessionVideo stopRunning];
    [self.captureSessionCamera startRunning];
    
    self.viewCategory.hidden = NO;
    self.viewLibrary.hidden = YES;
    self.viewVideo.hidden = YES;
    self.btnFlash.hidden = NO;
    
    [self showAndHideTimer];

    [self.btnLibrary setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // }];
}

- (void)showVideoiew {
    
    // [HELPER transitionAnimationFor:self.viewVideo withAnimationBlock:^{
    
    isPresentCameraView = NO;
    
    [captureSessionVideo startRunning];
    [self.captureSessionCamera stopRunning];
    
    self.viewCategory.hidden = YES;
    self.viewLibrary.hidden = YES;
    self.viewVideo.hidden = NO;
    self.btnFlash.hidden = YES;
    
    [self showAndHideTimer];
    
    [self.btnLibrary setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnCamera setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnVideo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

}

#pragma mark -
#pragma mark - Timer Methods -
#pragma mark -

- (void)showAndHideTimer {
    
    if (isRecordingVideo) {
        
        self.viewTimer.hidden = NO;
    }
    
    else {
        
        self.lblTimer.text = @"00:00";
        self.viewTimer.hidden = YES;
    }
}

- (void)initalizeTimer {
    
    self.timeMin = 0;
    self.timeSec = 0;
    myDoubleTimerCount = 0.0;
    recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordingTime:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:recordingTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopTimer {
    
    [recordingTimer invalidate];
    recordingTimer = nil;
}

- (void)recordingTime:(NSTimer *)timer
{
//    myDoubleTimerCount += 0.1;
//    double seconds = fmod(myDoubleTimerCount, 60.0);
//    double minutes = fmod(trunc(myDoubleTimerCount / 60.0), 60.0);
//    double hours = trunc(myDoubleTimerCount / 3600.0);
//    self.lblTimer.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.0f", hours, minutes, seconds];
    
    if (isRecordingVideo) {
        
        self.timeSec++;
        if (self.timeSec == 60)
        {
            self.timeSec = 0;
            self.timeMin++;
        }
        //String format 00:00
        NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", self.timeMin, self.timeSec];
        //Display on your label
        self.lblTimer.text= timeNow;
        
    }
}

@end
