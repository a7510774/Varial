//
//  BuzzardRunComments.h
//  Varial
//
//  Created by vis-1041 on 4/24/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Config.h"
#import "HeaderView.h"
#import "MediaPopup.h"
#import "KLCPopup.h"
#import "SVPullToRefresh.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "SAMTextView.h"
#import "YesNoPopup.h"
#import "FriendProfile.h"
#import "TTTAttributedLabel.h"
#import "ViewController.h"
#import "PostDetails.h"
#import "MyProfile.h"
#import "FriendProfile.h"
#import "AGEmojiKeyBoardView.h"

@interface BuzzardRunComments : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,MediaPopupDelegate,TTTAttributedLabelDelegate,UITextFieldDelegate,YesNoPopDelegate,AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>
{
    NSMutableArray *commentsList;
    KLCPopup *KLCMediaPopup, *yesNoPopup;
    MediaPopup *mediaPopupView;
    int currentSelection;
    NSIndexPath *oldIndex;
    IBOutlet UIView *footerView;
    BOOL flag,isManual, isNeedUpdate;
    NSData *imgData;
    UIImage *pickedImage;
    NSString *mediaBase,*lastCommentId;
    YesNoPopup *popupView;
    
    int menuIndex;
    bool isShowBottom,isPostExpired;
    NSString *name, *profileImage;
    NSMutableArray *localComments;
    AGEmojiKeyboardView *emojiKeyboardView;
    BOOL isEmojiKeyboard;
    
}

@property (strong)  NSString  *postId, *mediaId, *canNotComment, *buzzardRunId, *buzzardRunEventId;
@property NSUInteger commentIndex;
@property (strong) NSMutableDictionary *postDetails, *mediaDetails;

@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginBottom;

@property (weak, nonatomic) IBOutlet UIView *composeView;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet SAMTextView *message;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;

-(IBAction)Camera:(id)sender;
-(IBAction)SendComments:(id)sender;

@property (nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButton;
- (IBAction)openEmoji:(id)sender;


@end
