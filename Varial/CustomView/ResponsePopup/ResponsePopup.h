//
//  ResponsePopup.h
//  Varial
//
//  Created by jagan on 02/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ResponseDelegate

- (void) onInviteClick;
- (void) onUnFriendClick;
- (void) onCancelInviteClick;
- (void) onAcceptClick;
- (void) onCancelRequestClick;
- (void) onBlockClick;

@end

@interface ResponsePopup : UIView{
    float height;
}

@property (assign) id<ResponseDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *unFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelInvite;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRequest;
@property (weak, nonatomic) IBOutlet UIButton *block;


- (IBAction)doInvite:(id)sender;
- (IBAction)doUnFriend:(id)sender;
- (IBAction)doCancelInvite:(id)sender;
- (IBAction)doAccept:(id)sender;
- (IBAction)doCancelRequest:(id)sender;
- (IBAction)doBlock:(id)sender;

- (id)initWithOptions:(BOOL)invite showUnFriend:(BOOL)unFriend showCancelInvite:(BOOL)cancelInvite showAccept:(BOOL)accept showCancelRequest:(BOOL)cancelRequest;

@end
