//
//  MediaComposing.h
//  EJabberChat
//
//  Created by Shanmuga priya on 5/13/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "IQMediaPickerController.h"
#import "UIImageView+AFNetworking.h"
#import "NetworkAlert.h"
#import "KLCPopup.h"
#import "MediaPopup.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"

@interface MediaComposing : UIViewController<IQMediaPickerControllerDelegate,UIImagePickerControllerDelegate,NetworkDelegate, UINavigationControllerDelegate,MediaPopupDelegate>
{
    NSMutableArray *medias;
    NSDictionary *mediaDict;
    IQMediaPickerController *mediaPickerController;
    BOOL isCaptured,isMaxFileShown;
    int maxImage, maxVideo, maxVideoFileSize, maxImageFileSize;
    NetworkAlert *mediaExceed;
    KLCPopup *mediaCountPopup, *mediaPopup;
    MediaPopup *mediaPopupView;
    BOOL flag;
    ALAuthorizationStatus status;
    UIImagePickerController *picker;
    AppDelegate *appDelegate;
}

@property (nonatomic)int type;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *addMoreButton;

-(void)openWindow;
- (IBAction)tappedAddMore:(id)sender;
- (IBAction)tappedCancel:(id)sender;

@end
