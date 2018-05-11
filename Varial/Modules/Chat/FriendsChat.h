//
//  FriendsChat.h
//  EJabberChat
//
//  Created by Shanmuga priya on 5/13/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "MediaComposing.h"
#import "ChatWindow.h"
#import "JSQMessages.h"
#import "ProfileImage.h"
#import "XMPPServer.h"
#import "SAMTextView.h"
#import "MarqueeLabel.h"
#import "WYPopoverController.h"
#import "DGActivityIndicatorView.h"
#import "AGEmojiKeyBoardView.h"
#import "NSString+RemoveEmoji.h"

@interface FriendsChat : UIViewController<UITextViewDelegate,WYPopoverControllerDelegate,UIGestureRecognizerDelegate,AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource,UIImagePickerControllerDelegate>{
    JSQMessagesViewController *chatView;
    ChatWindow *chatWindow;
    XMPPStream *xmppStream;
    XMPPJID *receiverJID;
    WYPopoverController *popoverController;
    UIView *blockView;
    UILabel *blockLabel;
    UIButton *addFriendButton,*goOfflineButton;
    UIImageView *wifiImage;
    UIImage *animateImage;
    UIView *onlineStatus;
    DGActivityIndicatorView *typingIndicator;
    NSMutableArray *titleArray,*imageArray;
    AGEmojiKeyboardView *emojiKeyboardView;
    NSDictionary *mediaDict;
    BOOL isMaxFileShown, hasSentComposing;
    int  maxImageFileSize;
    NetworkAlert *mediaExceed;
   // ALAuthorizationStatus status;
    
    UIImagePickerController *picker;
}

@property (strong) NSMutableDictionary *forwardMessage;
@property (strong) NSString *receiverName, *receiverID, *receiverImage, *isFromFriends, *isSingleChat,*teamRelationID;
@property (strong) NSMutableArray *medias;


@property (nonatomic) BOOL isBlocked, isEmojiKeyboard;

//Profile Header
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIButton *optionButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

- (IBAction)tappedOption:(id)sender;
@property (weak, nonatomic) IBOutlet MarqueeLabel *statusLabel;
@property (weak, nonatomic) IBOutlet ProfileImage *profileThumb;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)goBack:(id)sender;

//Compose View
@property (weak, nonatomic) IBOutlet UIView *composeView;
- (IBAction)sendMessage:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginBottom;
@property (weak, nonatomic) IBOutlet SAMTextView *messageText;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButton;
@property (weak, nonatomic) IBOutlet UIButton *addMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaMenu;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBottom;
@property (weak, nonatomic) IBOutlet UIView *composeContainerView;
- (IBAction)openCamera:(id)sender;
- (IBAction)openMediaMenu:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *composeViewHeight;


@property (nonatomic)MediaComposing *send;
@property (weak, nonatomic) IBOutlet UIView *chatContents;

- (void)uploadImage:(NSMutableDictionary *)media withMessage:(XMPPMessage *)msg;
- (void)uploadVideo:(NSMutableDictionary *)media withMessage:(XMPPMessage *)msg;

-(void)sendMessageIfUserLeft :(NSString *)roomName name1:(NSString *)name1 name2:(NSString *)name2 type:(NSString *)type;

@end
