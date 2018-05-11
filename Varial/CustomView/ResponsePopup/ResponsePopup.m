//
//  ResponsePopup.m
//  Varial
//
//  Created by jagan on 02/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ResponsePopup.h"
#import "Util.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@implementation ResponsePopup

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithOptions:(BOOL)invite showUnFriend:(BOOL)unFriend showCancelInvite:(BOOL)cancelInvite showAccept:(BOOL)accept showCancelRequest:(BOOL)cancelRequest{
    
    self = [super init];
    
    [[NSBundle mainBundle] loadNibNamed:@"ResponsePopup" owner:self options:nil];
    
    //Dynamic height calculation
    height = 132;
    
    if (invite) {
        height += 40;
    }
    else{
        [_inviteButton hideByHeight:YES];
        [_inviteButton setConstraintConstant:0 forAttribute:NSLayoutAttributeTop];
    }
    
    if (unFriend) {
        height += 40;
    }
    else{
        [_unFriendButton hideByHeight:YES];
        [_unFriendButton setConstraintConstant:0 forAttribute:NSLayoutAttributeTop];
    }
    
    if (cancelInvite) {
        height += 40;
    }
    else{
        [_cancelInvite hideByHeight:YES];
        [_cancelInvite setConstraintConstant:0 forAttribute:NSLayoutAttributeTop];
    }
    
    if (accept) {
        height += 40;
    }
    else{
        [_acceptButton hideByHeight:YES];
        [_acceptButton setConstraintConstant:0 forAttribute:NSLayoutAttributeTop];
    }
    
    if (cancelRequest) {
        height += 40;
    }
    else{
        [_cancelRequest hideByHeight:YES];
        [_cancelRequest setConstraintConstant:0 forAttribute:NSLayoutAttributeTop];
    }    
    
    
    CGRect rootViewFrame =self.mainView.frame;
    rootViewFrame.size.height=height;
    self.frame=rootViewFrame;
    
    [self addSubview:self.mainView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _title.text = NSLocalizedString(@"ACTION", nil);
    
    [_inviteButton setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
     [_unFriendButton setTitle:NSLocalizedString(@"Unfriend", nil) forState:UIControlStateNormal];
     [_cancelInvite setTitle: NSLocalizedString(@"Cancel Invite", nil) forState:UIControlStateNormal];
     [_acceptButton setTitle: NSLocalizedString(@"Accept", nil) forState:UIControlStateNormal];
     [_cancelRequest setTitle: NSLocalizedString(@"Reject", nil) forState:UIControlStateNormal];
    [_block setTitle: NSLocalizedString(@"Block", nil) forState:UIControlStateNormal];

    
    [Util createBorder:_inviteButton withColor:UIColorFromHexCode(GREY_BORDER)];
    [Util createBorder:_unFriendButton withColor:UIColorFromHexCode(GREY_BORDER)];
    [Util createBorder:_cancelInvite withColor:UIColorFromHexCode(GREY_BORDER)];
    [Util createBorder:_acceptButton withColor:UIColorFromHexCode(GREY_BORDER)];
    [Util createBorder:_cancelRequest withColor:UIColorFromHexCode(GREY_BORDER)];
    [Util createBorder:_block withColor:UIColorFromHexCode(GREY_BORDER)];
    
    return  self;
}

- (IBAction)doInvite:(id)sender {
    [_delegate onInviteClick];
}

- (IBAction)doUnFriend:(id)sender {
    [_delegate onUnFriendClick];
}

- (IBAction)doCancelInvite:(id)sender {
    [_delegate onCancelInviteClick];
}

- (IBAction)doAccept:(id)sender {
    [_delegate onAcceptClick];
}

- (IBAction)doCancelRequest:(id)sender {
    [_delegate onCancelRequestClick];
}

- (IBAction)doBlock:(id)sender {
    [_delegate onBlockClick];
}

@end
