//
//  Comments.h
//  Varial
//
//  Created by vis-1674 on 2016-02-12.
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
#import "PostDetails.h"
#import "MyProfile.h"
#import "FriendProfile.h"
#import "AGEmojiKeyBoardView.h"
#import "AppDelegate.h"


@interface Comments : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate,HeaderViewDelegate,UINavigationControllerDelegate, UIActionSheetDelegate,MediaPopupDelegate,TTTAttributedLabelDelegate,UITextFieldDelegate,YesNoPopDelegate,AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>
{
    NSMutableArray *commentsList;
    KLCPopup *KLCMediaPopup, *yesNoPopup;
    MediaPopup *mediaPopupView;
    int currentSelection;
    NSIndexPath *oldIndex;
    IBOutlet UIView *footerView;
    BOOL flag,isManual, isNeedUpdate,isEmojiKeyboard;
    NSData *imgData;
    UIImage *pickedImage;
    NSString *mediaBase,*lastCommentId,*lastCommentIdSend;
    YesNoPopup *popupView;
    AGEmojiKeyboardView *emojiKeyboardView;
    AppDelegate *appDelegate;
    
    UIImagePickerController *controller;
}

@property (strong)  NSString  *postId, *mediaId, *canNotComment, *isFromFeedsPage;
@property NSUInteger commentIndex;
@property (strong) NSMutableDictionary *postDetails, *mediaDetails;
@property (strong) NSMutableArray *feeds;

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
