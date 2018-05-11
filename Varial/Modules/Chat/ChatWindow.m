//
//  ChatWindow.m
//  EJabberChat
//
//  Created by jagan on 24/05/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "ChatWindow.h"
#import "UIImageView+AFNetworking.h"
#import "FriendsChat.h"
#import "ChatMenu.h"
#import "ChatDBManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XMPPServer.h"
#import "Config.h"

@interface ChatWindow ()

@end

@implementation ChatWindow

FriendsChat *parentController;
AppDelegate *delegate;
NSArray *statusImges;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    medias = [[NSMutableArray alloc] init];
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //Set font
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:@"CenturyGothic" size:15];
    
    //Initializing the array
    messages = [[NSMutableArray alloc] init];
    statusImges = [[NSArray alloc] initWithObjects:@"",@"sent.png",@"readblack.png",@"read.png", nil];
    self.senderDisplayName = @"";
    
    UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    parentController = [[navigation viewControllers] lastObject];
    
    //Hide the default compose view
    self.inputToolbar.hidden = YES;
    [self createBubbleStyle];
    [self registerForNotification];
    
    [self setAvatarImages:[Util getFromDefaults:@"myJID"] fromUrl:[Util getFromDefaults:@"player_image"]];    
    
    //Add custom menus
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];    
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(forward:)];
    
    //Register for get upload progress
    [self registerForUploadRequest];
    
    //Register for get download progress
    [self registerForDownloadRequest];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidUnload{
    
}

- (void) removeAllMessages{
    [messages removeAllObjects];
}

- (NSMutableArray *)getMessages{
    return messages;
}

- (void)reloadTheCell:(int)index{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)createBubbleStyle{
    /**
     *  Create message bubble images objects.
     *
     *  Be sure to create your bubble images one time and reuse them for good performance.
     *
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage jsq_bubbleRegularImage] capInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:UIColorFromHexCode(OUT_BUBBLE)];
    incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    leftBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor clearColor]];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[messages objectAtIndex:indexPath.item] valueForKey:@"JSQMessage"];
}
- (id)collectionView:(JSQMessagesCollectionView *)collectionView messageAtIndexPath:(NSIndexPath *)indexPath{
    return [messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isUserLeft:[messages objectAtIndex:indexPath.item]]) {
        NSMutableDictionary *currentMessage = [messages objectAtIndex:indexPath.item];
        if ([parentController.isSingleChat isEqualToString:@"TRUE"]) {
            [[ChatDBManager sharedInstance] deleteTeamMessage:[currentMessage valueForKey:@"id"]];
        }
        else
        {
            [[ChatDBManager sharedInstance] deleteTeamMessage:[currentMessage valueForKey:@"id"]];
        }
        
        [messages removeObjectAtIndex:indexPath.item];
        
        //Remove media from medias
        if ([[currentMessage valueForKey:@"type"] intValue] == 2) {
            int index = [Util getMatchedObjectPosition:@"id" valueToMatch:[currentMessage valueForKey:@"id"] from:medias type:0];
            if (index != -1 && [medias count] > index) {
                [medias removeObjectAtIndex:index];
            }
        }
    }
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didForwardMessageAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isUserLeft:[messages objectAtIndex:indexPath.item]]) {
        
        JSQMessage *msg = [[messages objectAtIndex:indexPath.item] valueForKey:@"JSQMessage"];
        NSMutableDictionary *currentMessage = [messages objectAtIndex:indexPath.item];
        Forward *forward = [[Forward alloc]initWithNibName:@"Forward" bundle:nil];
        if (!msg.isMediaMessage) {
            forward.message = [currentMessage mutableCopy];
            [self.navigationController pushViewController:forward animated:YES];
        }
        else{
            //Check is outgoing message
            if ([[currentMessage valueForKey:@"is_outgoing"] boolValue]) {
                forward.message = [currentMessage mutableCopy];
                [self.navigationController pushViewController:forward animated:YES];
            }
            else if([[currentMessage valueForKey:@"is_local"] boolValue]){
                forward.message = [currentMessage mutableCopy];
                [self.navigationController pushViewController:forward animated:YES];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:NSLocalizedString(YOU_CAN_NOT_FORWARD, nil)];
            }
        }
    }
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [[messages objectAtIndex:indexPath.item] valueForKey:@"JSQMessage"];
    
    if ([self isUserLeft:[messages objectAtIndex:indexPath.item]]) {
        return leftBubbleImageData;
    }
    
    if ([message.senderId isEqualToString:[Util getFromDefaults:@"myJID"]]) {
        return outgoingBubbleImageData;
    }
    
    return incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    if ([self isUserLeft:[messages objectAtIndex:indexPath.item]]) {
        return nil;
    }
    
    JSQMessage *message = [[messages objectAtIndex:indexPath.item] valueForKey:@"JSQMessage"];
    NSMutableDictionary *avatars = [[ChatDBManager sharedInstance] avatarImages];
    NSMutableDictionary *avatar = [avatars objectForKey:message.senderId];
    if (avatar != nil) {
        return [avatar objectForKey:@"avatar"];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    
    //Show a timestamp for a day
    NSMutableDictionary *currentMessage = [messages objectAtIndex:indexPath.item];
    
    if (indexPath.item - 1 >= 0) {
        NSMutableDictionary *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage valueForKey:@"relativeTime"] isEqualToString:[currentMessage valueForKey:@"relativeTime"]]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:[currentMessage valueForKey:@"relativeTime"]];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [[messages objectAtIndex:indexPath.item] valueForKey:@"JSQMessage"];
    
    /**
     *  iOS7-style sender name labels
     */
    
    if ([parentController.isSingleChat isEqualToString:@"TRUE"]) {
        return nil;
    }
    else{
        
        // If User Leave from team should not show sender name
        if ([self isUserLeft:[messages objectAtIndex:indexPath.item]]) {
            return nil;
        }
        
        if ([message.senderId isEqualToString:self.senderId]) {
            return nil;
        }
        
        if (indexPath.item - 1 > 0) {
            JSQMessage *previousMessage = [[messages objectAtIndex:indexPath.item - 1] valueForKey:@"JSQMessage"];
            if ([[previousMessage senderId] isEqualToString:message.senderId]) {
                return nil;
            }
        }
        
        /**
         *  Don't specify attributes to use the defaults.
         */
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }

}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    //Show a timestamp for a day
    NSMutableDictionary *currentMessage = [messages objectAtIndex:indexPath.item];
    return [[NSAttributedString alloc] initWithString:[Util getTime:[currentMessage valueForKey:@"timestamp"]]];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
        
    NSMutableDictionary *messageData = [messages objectAtIndex:indexPath.item];
    [cell.coverView removeFromSuperview];
    //hide or show the activity label
    if ([self isUserLeft:[messages objectAtIndex:indexPath.item]]) {
        cell.avatarContainerView.hidden = YES;
        [Util createRoundedCorener:cell.avatarImageView withCorner:cell.avatarImageView.frame.size.height/ 2];
        [Util createBorder:cell.avatarImageView withColor:[UIColor clearColor]];
        
        //Show the activity status
        NSError *error;
        NSString *msgBody = [messageData objectForKey:@"body"];
        XMPPMessage *message = [[XMPPMessage alloc] initWithXMLString:msgBody error:&error];
        if (error == nil) {
            cell.activityLabel.attributedText = [[NSAttributedString alloc] initWithString:[[ChatDBManager sharedInstance] createTeamStatusBodyMessage:message]];
            cell.activityLabel.hidden = NO;
        }
    }
    else
    {
        //[Util createRoundedCorener:cell.avatarImageView withCorner:cell.avatarImageView.frame.size.height/ 2];
        //[Util createBorder:cell.avatarImageView withColor:UIColorFromHexCode(THEME_COLOR)];
        cell.avatarContainerView.hidden = NO;
        cell.activityLabel.hidden = YES;
    }
    
    JSQMessage *msg = [[messages objectAtIndex:indexPath.item] valueForKey:@"JSQMessage"];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    
    //Set message status
    int index = [[messageData valueForKey:@"status"] intValue];
    if(index != 0){
        if ([parentController.isSingleChat isEqualToString:@"TRUE"]) {
            cell.statusImage.image = [UIImage imageNamed:[statusImges objectAtIndex:index]];
        }
        else{
            // If user leave from team should not show the status image
            if ([self isUserLeft:[messages objectAtIndex:indexPath.item]]) {
                cell.statusImage.image = nil;
                cell.textView.textColor = [UIColor whiteColor];
            }
            else
            {
                cell.statusImage.image = [UIImage imageNamed:[statusImges objectAtIndex:1]];
            }
        }
    }
    
    //Hide or show the upload indicator
    //Add Target to cancel the download
    [cell.uploadCancel addTarget:self action:@selector(cancelUpload:) forControlEvents:UIControlEventTouchUpInside];
    if (!msg.isMediaMessage) {
        cell.uploadIndicator.hidden = YES;
        cell.uploadRetry.hidden = YES;
        cell.uploadCancel.hidden = YES;
    }
    else{
        if(index == 0){
            cell.uploadIndicator.hidden = NO;
            cell.uploadProgress.hidden = NO;
            float progressValue = [[delegate.upDownProgress valueForKey:[messageData objectForKey:@"id"]] floatValue];
            if(progressValue != 0)
                [cell.uploadProgress setValue:progressValue];
            else
                [cell.uploadProgress setValue:0.05];
            
            cell.uploadCancel.hidden = NO;
            [cell.spinnerView startAnimating];
            /* if ([[messageData valueForKey:@"type"] intValue] == 2) { //Image
                cell.outGoingVideo.hidden = YES;
            }
            else{
                cell.outGoingVideo.hidden = NO;
            } */
            cell.outGoingVideo.hidden = YES;
        }
        else{
            cell.outGoingVideo.hidden = YES;
            cell.uploadCancel.hidden = YES;
            if ([[messageData valueForKey:@"type"] intValue] == 2) { //Image
                cell.uploadIndicator.hidden = YES;
            }
            else{ //Video
                if([msg.senderId isEqualToString:self.senderId]){
                    cell.uploadIndicator.hidden = NO;
                    cell.uploadProgress.hidden = YES;
                    cell.outGoingVideo.hidden = NO;
                }
            }
        }
    }
    
    //Hide or show the download indicator
    cell.downloadRetry.hidden = YES;
    if (!msg.isMediaMessage) {
        cell.downloadView.hidden = YES;
        cell.downloadCancel.hidden = YES;
    }
    else{
        int index = [[messageData valueForKey:@"is_local"] intValue];
        if(index == 0){ //For local images/videos
            cell.downloadView.hidden = NO;
            cell.downloadSpinner.hidden = YES;
            cell.downloadProgress.hidden = YES;
            cell.incomeVideo.hidden = YES;
            cell.downloadCancel.hidden = YES;
            cell.downloadButton.hidden = NO;
            if ([[messageData valueForKey:@"type"] intValue] == 2) { //Image
                [cell.downloadButton addTarget:self action:@selector(downloadMedia:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [cell.downloadButton addTarget:self action:@selector(downloadVideo:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else{ //For remote images/videos
            cell.incomeVideo.hidden = YES;
            if ([[messageData valueForKey:@"type"] intValue] == 2) { //Image
                cell.downloadView.hidden = YES;
                cell.downloadCancel.hidden = YES;
            }
            else{ //Video
                if(![msg.senderId isEqualToString:self.senderId]){
                    cell.downloadView.hidden = NO;
                    cell.downloadSpinner.hidden = YES;
                    cell.downloadProgress.hidden = YES;
                    cell.downloadCancel.hidden = YES;
                    cell.downloadButton.hidden = YES;
                    cell.incomeVideo.hidden = NO;
                }
            }
        }
    }
    

    //Hide or show the downloading indicator
    NSString *messageId = [messageData valueForKey:@"id"];
    if ([delegate.downloadingMessages indexOfObject:messageId] != NSNotFound && msg.isMediaMessage) {
        cell.downloadView.hidden = NO;
        //cell.downloadSpinner.hidden = NO;
        cell.downloadProgress.hidden = NO;
        cell.downloadButton.hidden = YES;
        
        float progressValue = [[delegate.upDownProgress valueForKey:[messageData objectForKey:@"id"]] floatValue];
        if(progressValue != 0)
        {
            [cell.downloadProgress setValue:progressValue];
        }
        
        if ([[messageData valueForKey:@"type"] intValue] == 3) { //Video
            cell.downloadCancel.hidden = NO;
            cell.downloadSpinner.hidden = YES;
        }
        
        //Add Target to cancel the download
        [cell.downloadCancel addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //Hide or show the retry option for uploads/downloads
    if (msg.isMediaMessage) {
        if ([[messageData valueForKey:@"is_sent"] intValue] == 1 && [[messageData valueForKey:@"is_outgoing"] boolValue]) {
            cell.uploadIndicator.hidden = YES;
            cell.uploadRetry.hidden = NO;
            cell.uploadCancel.hidden = YES;
            //Add Target to retry the upload
            [cell.uploadRetry addTarget:self action:@selector(retryUpload:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            cell.uploadRetry.hidden = YES;
        }
    }
    
    //Hide or show file size
    int isLocal = [[messageData valueForKey:@"is_local"] intValue];
    if (msg.isMediaMessage && ![msg.senderId isEqualToString:self.senderId]) {
        cell.mediaSize.hidden = NO;
        cell.mediaSize.text = [messageData valueForKey:@"filesize"];
        if (isLocal != 0) {
            cell.mediaSize.hidden = YES;
        }
    }
    else{
        cell.mediaSize.hidden = YES;
    }
    
    //Send seen ACK to messages that not seen yet
    if (![msg.senderId isEqualToString:self.senderId] && (index == 0 || index == 2)) {
        if ([self canSend]) {            
            [[ChatDBManager sharedInstance] sendSeenACK:msg.senderId toMessageId:[messageData valueForKey:@"id"]];
            [[ChatDBManager sharedInstance] updateMessageStatus:[messageData valueForKey:@"id"] toStatus:3];
        }
    }
    
    //Show missed media alert
    NSString *mediaUrl = [messageData valueForKey:@"mediaUrl"];
    [cell.missedOutMedia setHidden:YES];
    [cell.missedMedia setHidden:YES];
    if ([mediaUrl rangeOfString:@"assets-library://"].location != NSNotFound && msg.isMediaMessage){
        [[Util sharedInstance].assetLibrary assetForURL:[NSURL URLWithString:mediaUrl]
                                            resultBlock:^(ALAsset *asset){
                                                if (asset == nil) {
                                                    [[messageData valueForKey:@"is_outgoing"] boolValue] ? [cell.missedOutMedia setHidden:NO] :[cell.missedMedia setHidden:NO];
                                                    [messageData setObject:@"NO" forKey:@"showForward"];
                                                }
                                                else{
                                                    [cell.missedOutMedia setHidden:YES];
                                                    [cell.missedMedia setHidden:YES];
                                                }
                                            }
                                           failureBlock:^(NSError *err) {
                                               [[messageData valueForKey:@"is_outgoing"] boolValue] ? [cell.missedOutMedia setHidden:NO] :[cell.missedMedia setHidden:NO];
                                               [messageData setObject:@"NO" forKey:@"showForward"];
                                           }];
    }
    
    return cell;
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods
- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)senderView
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item
                                                            avatar:sender];
        [messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}



#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
  //  [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text
                                                        avatar:sender];
    
    [messages addObject:message];
    [self finishSendingMessageAnimated:YES];
}


- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            //[self addPhotoMediaMessage];
            break;
            
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
        }
            break;
            
        case 2:
            //[self addVideoMediaMessage];
            break;
    }
    
   // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
    [parentController.messageText resignFirstResponder];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
    [parentController.messageText resignFirstResponder];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Tapped message bubble!");
    NSMutableDictionary *messageInfo = [messages objectAtIndex:indexPath.row];
    BOOL outGoing = [[messageInfo valueForKey:@"is_outgoing"] boolValue];
    int isLocal = [[messageInfo valueForKey:@"is_local"] intValue];
    int mediaType = [[messageInfo valueForKey:@"type"] intValue];
    
    if((mediaType == 2 && (!outGoing && isLocal == 1)) || (mediaType == 2 && outGoing)){
        int index = [Util getMatchedObjectPosition:@"media_url" valueToMatch:[messageInfo valueForKey:@"mediaUrl"] from:medias type:0];
        if (index != -1) {
            [Util showSliderForChat:parentController forImage:medias atIndex:index withTitle:parentController.receiverName];
        }
    }
    
    if((mediaType == 3 && (!outGoing && isLocal == 1)) || (mediaType == 3 && outGoing)){
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[messageInfo valueForKey:@"mediaUrl"]]];
        [self presentMoviePlayerViewControllerAnimated:player];
    }

    
    [parentController.messageText resignFirstResponder];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [self.keyboardController.textView resignFirstResponder];
    [parentController.messageText resignFirstResponder];
    parentController.menuBottom.constant = -90;
    parentController.marginBottom.constant = 0;
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
    [self.collectionView reloadData];
}


#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    
    //Show a timestamp for a day
    NSMutableDictionary *currentMessage = [messages objectAtIndex:indexPath.item];
    
    if (indexPath.item - 1 >= 0) {
        NSMutableDictionary *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage valueForKey:@"relativeTime"] isEqualToString:[currentMessage valueForKey:@"relativeTime"]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    
    if ([parentController.isSingleChat isEqualToString:@"TRUE"]) {
        return 0.0f;
    }
    else
    {
        JSQMessage *currentMessage = [[messages objectAtIndex:indexPath.item] valueForKey:@"JSQMessage"];
        if ([[currentMessage senderId] isEqualToString:self.senderId]) {
            return 0.0f;
        }
        
        if (indexPath.item - 1 > 0) {
            JSQMessage *previousMessage = [[messages objectAtIndex:indexPath.item - 1] valueForKey:@"JSQMessage"];
            if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
                return 0.0f;
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isUserLeft:[messages objectAtIndex:indexPath.item]]) {
        return 0;
    }
    return 20.0f;
}

//Detect image download click
- (IBAction)downloadMedia:(UIButton *)senderButton{
    
    if (![[Util sharedInstance] getNetWorkStatus]) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_INTERNET_CONNECTION, nil)];
    }
    else{       
        CGPoint buttonPosition = [senderButton convertPoint:CGPointZero toView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
        
        if ([messages count] > indexPath.row) {
            
            NSMutableDictionary *messageInfo = [messages objectAtIndex:indexPath.row];
            NSString *mediaUrl = [messageInfo valueForKey:@"mediaUrl"];
            __block NSString *messageId = [messageInfo valueForKey:@"id"];
            int type = [[messageInfo valueForKey:@"type"] intValue];
            
            if(type == 2)//Image
            {
                JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
                cell.downloadButton.hidden = YES;
                cell.downloadCancel.hidden = NO;
                cell.downloadSpinner.hidden = NO;
                cell.downloadProgress.hidden = YES;
                
                //Add the download message to global
                [delegate.downloadingMessages addObject:messageId];
                NSLog(@"Messages downloaded  :%@",delegate.downloadingMessages);
                
                UIImageView *imageView = [[UIImageView alloc] init];
                NSURLRequest *imageRequest =  [NSURLRequest requestWithURL:[NSURL URLWithString:mediaUrl]];
                
                [imageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                    
                    //Save image locally
                    [[Util sharedInstance].assetLibrary saveImage:image toAlbum:ALBUM_NAME withCompletionBlock:^(NSError *error, NSURL *mediaURL) {
                        
                        NSLog(@"Image saved locally");
                        
                        // Compress image and convert to base64
                        UIImage *compressedImage = [Util imageWithImage:image scaledToWidth:image.size.width/8];
                        NSString *image64 = [Util imageToNSString:compressedImage];
                        [[NSUserDefaults standardUserDefaults] setObject:image64 forKey:[mediaURL absoluteString]];
                        
                        //1.Update the local array
                        [messageInfo setValue:[NSNumber numberWithInt:1] forKey:@"is_local"];
                        [messageInfo setValue:[mediaURL absoluteString] forKey:@"mediaUrl"];
                        
                        //2.Update the design
                        JSQMessage *message = [messageInfo valueForKey:@"JSQMessage"];
                        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
                        photoItem.appliesMediaViewMaskAsOutgoing = NO;
                        message.media = photoItem;
                        [self.collectionView reloadData];
                        
                        //3.Update the DB
                        [[ChatDBManager sharedInstance] updateImageSource:messageId withLocalUrl:[mediaURL absoluteString]];
                        
                        //4.Remove the message from downloading array
                        [delegate.downloadingMessages removeObject:messageId];
                        
                        //5.Update the local url
                        int index = [Util getMatchedObjectPosition:@"media_url" valueToMatch:mediaUrl from:medias type:0];
                        if (index != -1) {
                            NSMutableDictionary *media = [medias objectAtIndex:index];
                            [media setValue:[mediaURL absoluteString] forKey:@"media_url"];
                        }
                        
                        NSLog(@"Messages downloaded  :%@",delegate.downloadingMessages);
                        
                    }];
                    
                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                    
                    NSLog(@"Image download failed");
                    cell.downloadButton.hidden = NO;
                    cell.downloadCancel.hidden = YES;
                    cell.downloadSpinner.hidden = YES;
                    cell.downloadProgress.hidden = YES;
                    
                }];
            }
        }
    }
}

//Detect image download click
- (IBAction)downloadVideo:(UIButton *)senderButton{
    
    if (![[Util sharedInstance] getNetWorkStatus]) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_INTERNET_CONNECTION, nil)];
    }
    else{
        CGPoint buttonPosition = [senderButton convertPoint:CGPointZero toView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
        
        if ([messages count] > indexPath.row) {
            
            NSMutableDictionary *messageInfo = [messages objectAtIndex:indexPath.row];
            NSString *mediaUrl = [messageInfo valueForKey:@"mediaUrl"];
            __block NSString *messageId = [messageInfo valueForKey:@"id"];
            int type = [[messageInfo valueForKey:@"type"] intValue];
            
            if(type == 3)//Video
            {
                JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
                cell.downloadButton.hidden = YES;
                cell.downloadCancel.hidden = NO;
                cell.downloadSpinner.hidden = YES;
                cell.downloadProgress.hidden = NO;
                
                //Add the download message to global
                [delegate.downloadingMessages addObject:messageId];
                NSLog(@"Messages downloaded  :%@",delegate.downloadingMessages);
                
                NSURL *URL = [NSURL URLWithString:mediaUrl];
                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                
                NSURLSessionDownloadTask *downloadTask = [[Util sharedInstance].httpMultiFileTaskManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                    
                } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    
                    //Get Temporary file path
                    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                    return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                    
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    
                     int index = [Util getMatchedObjectPosition:@"id" valueToMatch:messageId from:messages type:0];
                     NSIndexPath *indexPaths = [NSIndexPath indexPathForItem:index inSection:0];
                    JSQMessagesCollectionViewCell *videoCell = (JSQMessagesCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPaths];
                    
                    if (error != nil) {
                        videoCell.downloadButton.hidden = NO;
                        videoCell.downloadSpinner.hidden = YES;
                        videoCell.downloadProgress.hidden = YES;
                        videoCell.downloadCancel.hidden = YES;
                    }
                    else{
                        [[Util sharedInstance].assetLibrary writeVideoAtPathToSavedPhotosAlbum:filePath completionBlock:^(NSURL *assetURL, NSError *error) {
                            NSLog(@"file path :%@",filePath);
                            if (error) {
                                NSLog(@"error while saving video");
                            } else{
                                
                                //1.Remove temporary file
                                NSString *path = [[filePath absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                                [[NSFileManager defaultManager] removeItemAtPath: path error: &error];
                                NSLog(@"File saved locally");
                                
                                //2.Update the local array
                                [messageInfo setValue:[NSNumber numberWithInt:1] forKey:@"is_local"];
                                [messageInfo setValue:[assetURL absoluteString] forKey:@"mediaUrl"];
                                
                                //3.Update the design
                                JSQMessage *message = [messageInfo valueForKey:@"JSQMessage"];
                                JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:[assetURL absoluteString] withThumb:nil isReadyToPlay:YES];
                                videoItem.appliesMediaViewMaskAsOutgoing = NO;
                                message.media = videoItem;
                                
                                [self.collectionView reloadData];
                               
                                //4.Update the DB
                                [[ChatDBManager sharedInstance] updateImageSource:messageId withLocalUrl:[assetURL absoluteString]];
                                
                                //5.Remove the message from downloading array
                                [delegate.downloadingMessages removeObject:messageId];
                                
                                //6.Update the local url
                                int index = [Util getMatchedObjectPosition:@"media_url" valueToMatch:mediaUrl from:medias type:0];
                                if (index != -1) {
                                    NSMutableDictionary *media = [medias objectAtIndex:index];
                                    [media setValue:[assetURL absoluteString] forKey:@"media_url"];
                                }
                                
                                //7. Remove download reference
                                [delegate.downloadingMessageTasks removeObjectForKey:messageId];
                                
                                NSLog(@"Messages downloaded  :%@",delegate.downloadingMessages);
                            
                                [self.collectionView reloadItemsAtIndexPaths:@[indexPaths]];
                            }
                            
                        }];
                    }
                }];
                
                //Create download reference to the message download
                [delegate.downloadingMessageTasks setObject:downloadTask forKey:messageId];
               // if ([messageInfo objectForKey:@"task_identifier"] == nil) {
                    
                    NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)downloadTask.taskIdentifier];
                    [messageInfo setValue:taskIdentifier forKey:@"task_identifier"];
              //  }
                
                [downloadTask resume];
            }
        }
    }
}


//Cancel the download
- (IBAction)cancelDownload:(id)senderButton{
    
    CGPoint buttonPosition = [senderButton convertPoint:CGPointZero toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
    
    if ([messages count] > indexPath.row) {
        
        NSMutableDictionary *messageInfo = [messages objectAtIndex:indexPath.row];
        int type = [[messageInfo valueForKey:@"type"] intValue];
        NSString *messageId = [messageInfo valueForKey:@"id"];
        
        if(type == 3)//Video
        {
            //Reset the design
            JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
            cell.downloadButton.hidden = NO;
            cell.downloadCancel.hidden = YES;
            cell.downloadSpinner.hidden = YES;
            cell.downloadProgress.hidden = YES;
            
            [delegate.upDownProgress setValue:[NSNumber numberWithDouble:0.05] forKey:messageId];
            
            NSURLSessionDownloadTask *task = [delegate.downloadingMessageTasks objectForKey:messageId];
            if (task != nil) {
                [task cancel];
                [delegate.downloadingMessageTasks removeObjectForKey:messageId];
            }
        }
    }
}

//Cancel the upload
- (IBAction)cancelUpload:(id)senderButton{
    
    CGPoint buttonPosition = [senderButton convertPoint:CGPointZero toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
    
    if ([messages count] > indexPath.row) {
        
        NSMutableDictionary *messageInfo = [messages objectAtIndex:indexPath.row];
        NSString *messageId = [messageInfo valueForKey:@"id"];
        
        //Reset the design
        JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.uploadIndicator.hidden = YES;
        cell.uploadRetry.hidden = NO;
        cell.uploadRetry.userInteractionEnabled = YES;
        cell.uploadCancel.hidden = YES;
        [delegate.upDownProgress setValue:[NSNumber numberWithDouble:0.05] forKey:messageId];
            
        NSURLSessionUploadTask *task = [delegate.downloadingMessageTasks objectForKey:messageId];
        if (task != nil) {
            [task suspend];
            [task cancel];
            [delegate.downloadingMessageTasks removeObjectForKey:messageId];
        }
    }
}

//Retry the upload
- (IBAction)retryUpload:(id)senderButton{
    if (!parentController.isBlocked) {
        XMPPStream *xmppStream = [XMPPServer sharedInstance].xmppStream;
        if ([[Util sharedInstance] getNetWorkStatus] && xmppStream.isAuthenticated && xmppStream.isConnected) {
            
            CGPoint buttonPosition = [senderButton convertPoint:CGPointZero toView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
            
            if ([messages count] > indexPath.row) {
                
                NSMutableDictionary *messageInfo = [messages objectAtIndex:indexPath.row];
                NSString *messageStanza = [messageInfo valueForKey:@"body"];
                NSError *error;
                
                XMPPMessage *message = [[XMPPMessage alloc] initWithXMLString:messageStanza error:&error];
                
                if (error == nil) {
                    
                    //1. Get file url to retry
                    NSString *fileUrl = [messageInfo valueForKey:@"mediaUrl"];
                    BOOL isPhotos  = [[messageInfo valueForKey:@"type"] intValue] == 2 ? TRUE : FALSE;
                    
                    //2. Get media information
                    [[Util sharedInstance] checkMediaHasValidSize:isPhotos ofMediaUrl:fileUrl withCallBack:^(NSData * data, UIImage * thumbnail){
                        
                        if(data != nil){
                            
                            NSMutableDictionary *media = [[NSMutableDictionary alloc]init];
                            [media setObject:thumbnail forKey:@"mediaThumb"];
                            [media setObject:data forKey:@"assetData"];
                            [media setObject:fileUrl forKey:@"mediaUrl"];
                            
                            if (isPhotos) {
                                [parentController uploadImage:media withMessage:message];
                            }
                            else{
                                [parentController uploadVideo:media withMessage:message];
                            }
                            
                            //Update the message status
                            NSString *messageId = [messageInfo valueForKey:@"id"];
                            [[ChatDBManager sharedInstance] updateMessageStatus:messageId toStatus:0];
                            [[ChatDBManager sharedInstance] updateMediaUploadStatus:messageId withStatus:0];
                            [messageInfo setValue:[NSNumber numberWithInt:0] forKey:@"status"];
                            [messageInfo setValue:[NSNumber numberWithInt:0] forKey:@"is_sent"];
                            [self.collectionView reloadData];
                        }
                        else{
                            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(DELETED_MEDIA, nil)];
                        }
                    }];
                }
                else{
                    
                }
            }
        }
        else{
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_INTERNET_CONNECTION, nil)];
            
        }
    }
}


///////// Handle the stanzas received from server //////////////

//Register for the Notification
- (void) registerForNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processIncomeMessage:) name:XMPPONMESSAGERECIEVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageStatus:) name:XMPPRECEIVEDACK object:nil];
}

//To process the type of the notification
- (void) processIncomeMessage:(NSNotification *) data{
    
    NSMutableDictionary *receivedMessage = [data.userInfo mutableCopy];
    XMPPMessage *message = [receivedMessage valueForKey:@"message"];
    
    //1.Check message type
    if ([[message type] isEqualToString:@"chat"]) {
        
        //1. Add in chat list
        //Check is active message
        if ([message elementForName:@"active"] != nil) {
            
            //Check message for current conversation
            NSArray *from = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
            if ([[from objectAtIndex:0] isEqualToString:_receiverId]) {
                [self appendInChatList:message isOutgoing:NO];
            }
        }        
    }
    
    //2.Check for group chat message 
    if ([[message type] isEqualToString:@"groupchat"] && [message isChatMessageWithBody] && [[ChatDBManager sharedInstance] isTeamMessageisAfterJoined:message]) {
        
        //Check message for current conversation
        NSArray *from = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
        if ([[from objectAtIndex:0] isEqualToString:_receiverId]) {
            [self appendInChatList:message isOutgoing:NO];
        }
    }
}

//Change message status (Send,Deliverd,Seen)
- (void) updateMessageStatus:(NSNotification *) data{
   
    NSMutableDictionary *receivedMessage = [data.userInfo mutableCopy];
    XMPPMessage *message = [receivedMessage valueForKey:@"message"];
    
    NSString *messageId;
    int status = 1;
    //Get message id
    if ([message isChatMessageWithBody]) {
        messageId = [message attributeStringValueForName:@"id"];
    }
    else if ([message elementForName:@"received"] != nil && [[message type] isEqualToString:@"chat"]){
        NSXMLElement *received = [message elementForName:@"received"];
        messageId = [received attributeStringValueForName:@"id"];
        status = 2;
    }
    else if ([message elementForName:@"seen"] != nil && [[message type] isEqualToString:@"chat"]){
        NSXMLElement *received = [message elementForName:@"seen"];
        messageId = [received attributeStringValueForName:@"id"];
        status = 3;
    }
    
    int index = [Util getMatchedObjectPosition:@"id" valueToMatch:messageId from:messages type:0];
    if (index != -1 ) {
        NSMutableDictionary *message = [messages objectAtIndex:index];
        int oldStatus = [[message valueForKey:@"status"] intValue];
        if (oldStatus != 3) {
            [message setValue:[NSNumber numberWithInt:status] forKey:@"status"];
        }
        [self.collectionView reloadData];
    }
}

-(void)setStatusImage:(NSString*)msgId withStatus:(NSString*)statusVal{
    for(int i = 0 ; i < [messages count] ; i++)
    {
        NSMutableDictionary *statusDict = [messages objectAtIndex:i];
        if([msgId isEqualToString:[statusDict objectForKey:@"id"]])
        {
            [statusDict setObject:statusVal forKey:@"status"];
            [messages replaceObjectAtIndex:i withObject:statusDict];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            [[ChatDBManager sharedInstance] updateMessageStatus:msgId toStatus:[statusVal intValue]];
        }
    }
}

///////// Handle the stanzas received from server ends //////////////

/////////////// Send Messages //////////////

- (void)sendMessage:(XMPPMessage *)message mediaURL:(NSString *)mediaUrl{
    
    //1. Save in DB
    [[ChatDBManager sharedInstance] saveMessageInDataBase:message isOutGoing:TRUE mediaURL:mediaUrl];
    
    //2. Send to server if its not a media message
    if ([mediaUrl isEqualToString:@""]) {
        [self sendMessageToReceipient:message];
    }    
    
    //3. Add in chat list
    [self appendInChatList:message isOutgoing:YES];
}

//Send message over XMPP connection
- (void) sendMessageToReceipient:(XMPPMessage *)message{
    
    //1. Check connection is opened and authenticated
    if ([[XMPPServer sharedInstance].xmppStream isConnected] &&[[XMPPServer sharedInstance].xmppStream isAuthenticated] ) {
        
        if ([parentController.isSingleChat isEqualToString:@"TRUE"])
        {
            [[XMPPServer sharedInstance].xmppStream sendElement:message];
        }
        else
        {
            [[XMPPServer sharedInstance].xmppRoom sendMessage:message];
        }
    }
    else{
        NSLog(@"Not connected to server unable to send");
    }
}

//Append the chat bubbles in UI
- (void)appendInChatList:(XMPPMessage *)message isOutgoing:(BOOL)outGoing{
    
    NSXMLElement *userData = [message elementForName:@"userdata"];
    NSXMLElement *messageTypeNode = [userData elementForName:@"messageType"];
    int messageType = [[messageTypeNode stringValue] intValue];
    
    long timeStamp = [[ChatDBManager sharedInstance] getTimeFromMessage:message isOutGoing:outGoing];
    
    //1. Text Message
    if (messageType == 1) {
        [self addTextMessage:message isOutgoing:outGoing withStatus:0 withTime:timeStamp];
    }
    else if (messageType == 2) { //Image Message
        [self addPhotoMediaMessage:message isOutgoing:outGoing withStatus:0 withTime:timeStamp];
    }
    else if (messageType == 3) { //Video Message
        [self addVideoMediaMessage:message isOutgoing:outGoing withStatus:0 withTime:timeStamp];
    }
    
    //2.Play sound
    if ([message isChatMessageWithBody] && [message elementForName:@"delay"] == nil) {
       // outGoing ? [JSQSystemSoundPlayer jsq_playMessageSentSound] : [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    }
}

- (void)addTextMessage:(XMPPMessage *)message isOutgoing:(BOOL)outGoing withStatus:(int)status withTime:(long)timeStamp{
    
    NSXMLElement *userData = [message elementForName:@"userdata"];
    NSString *fromId = [[userData elementForName:@"from"] stringValue];    
    
    NSArray *nameAndImage = [[ChatDBManager sharedInstance] getNameAndImage:message isOutGoing:outGoing];
    
    NSString *bodyMsg = [message elementForName:@"teamstatus"] != nil ? @"" :  [message valueForKey:@"body"] ;
    
    JSQMessagesAvatarImage  *senderImage;
    [self setAvatarImages:fromId fromUrl:nameAndImage[1]];
    JSQMessage *textMessage = [[JSQMessage alloc] initWithSenderId:fromId
                                                 senderDisplayName:nameAndImage[0]
                                                              date:[NSDate dateWithTimeIntervalSince1970:timeStamp]
                                                              text:bodyMsg
                                                            avatar:senderImage];
    
    NSMutableDictionary *messageData = [[NSMutableDictionary alloc] init];
    [messageData setValue:message.description forKey:@"body"];
    [messageData setValue:[message attributeStringValueForName:@"id"] forKey:@"id"];
    [messageData setValue:[NSNumber numberWithInt:status] forKey:@"status"];
    [messageData setValue:[NSNumber numberWithInt:1] forKey:@"type"];
    [messageData setValue:textMessage forKey:@"JSQMessage"];
    [messageData setValue:[NSNumber numberWithLong:timeStamp] forKey:@"timestamp"];
    [messageData setValue:[Util getChatHistoryTime:[NSString stringWithFormat:@"%ld",timeStamp]] forKey:@"relativeTime"];
    [self setTaskIdentifierForMessage:messageData];
    [self sortMessages];
    
    [messages addObject:messageData];
    [self.collectionView reloadData];
    
    outGoing ? [self finishSendingMessageAnimated:YES] : [self finishReceivingMessageAnimated:YES];
    
}
- (void)addPhotoMediaMessage:(XMPPMessage *)message isOutgoing:(BOOL)outGoing withStatus:(int)status withTime:(long)timeStamp{

    //1. Get message from player_message table
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM player_message WHERE message_id = '%@'", [message attributeStringValueForName:@"id"]];
    NSMutableArray *messageDetails = [[DBManager sharedInstance] findRecord:query];
    
    if ([messageDetails count] > 0) {
        
        NSMutableDictionary *messageInfo = [messageDetails objectAtIndex:0];
        
        //Prepare image to show
        JSQPhotoMediaItem *photoItem;
        if (outGoing) { //Load image from local
            photoItem = [[JSQPhotoMediaItem alloc] initWithURL:[messageInfo valueForKey:@"media_url"]];
        }
        else{
            if ([[messageInfo valueForKey:@"is_local"] intValue] == 1) { //Show Downloaded image
                photoItem = [[JSQPhotoMediaItem alloc] initWithURL:[messageInfo valueForKey:@"media_url"]];
            }
            else{
                //Convert the base64 data into image
                NSString *image64 = [message valueForKey:@"body"];
                NSRange range = [image64 rangeOfString:IMAGE_KEY];
                NSString *originalImage = [image64 substringFromIndex:range.length];
                UIImage *image = [Util stringToUIImage:originalImage];
                image = [Util addBlurEffect:image];
                photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
            }
        }
        
        //Apply mask
        photoItem.appliesMediaViewMaskAsOutgoing = outGoing;
        
        
        //Read sender, name, image
        NSXMLElement *userData = [message elementForName:@"userdata"];
        NSString *fromId = [[userData elementForName:@"from"] stringValue];
        NSArray *nameAndImage = [[ChatDBManager sharedInstance] getNameAndImage:message isOutGoing:outGoing];
        
        JSQMessagesAvatarImage  *senderImage;
        [self setAvatarImages:fromId fromUrl:nameAndImage[1]];
        JSQMessage *photoMessage = [[JSQMessage alloc] initWithSenderId:fromId
                                                     senderDisplayName:nameAndImage[0]
                                                                  date:[NSDate dateWithTimeIntervalSince1970:timeStamp]
                                                                 media:photoItem
                                                                avatar:senderImage];
        
        NSMutableDictionary *messageData = [[NSMutableDictionary alloc] init];
        [messageData setValue:message.description forKey:@"body"];
        [messageData setValue:[message attributeStringValueForName:@"id"] forKey:@"id"];
        [messageData setValue:[NSNumber numberWithInt:status] forKey:@"status"];
        [messageData setValue:[NSNumber numberWithInt:2] forKey:@"type"];
        [messageData setValue:photoMessage forKey:@"JSQMessage"];
        [messageData setValue:[NSNumber numberWithLong:timeStamp] forKey:@"timestamp"];
        [messageData setValue:[messageInfo valueForKey:@"media_url"] forKey:@"mediaUrl"];
        [messageData setValue:[messageInfo valueForKey:@"is_local"] forKey:@"is_local"];
        [messageData setValue:[messageInfo valueForKey:@"is_sent"] forKey:@"is_sent"];
        [messageData setValue:[NSNumber numberWithBool:outGoing] forKey:@"is_outgoing"];
        [messageData setValue:[Util getChatHistoryTime:[NSString stringWithFormat:@"%ld",timeStamp]] forKey:@"relativeTime"];
        [self setTaskIdentifierForMessage:messageData];
        [self sortMessages];
        
        if (!outGoing) {
            [messageData setValue:[self getFileSize:message] forKey:@"filesize"];
        }
        
        [messages addObject:messageData];
        [self.collectionView reloadData];
        
        outGoing ? [self finishSendingMessageAnimated:YES] : [self finishReceivingMessageAnimated:YES];
        
        //Add image to make slide
        NSMutableDictionary *copyMessage = [messageInfo mutableCopy];
        [copyMessage removeObjectForKey:@"message"];
        [medias addObject:copyMessage];
    }
}

- (void)addVideoMediaMessage:(XMPPMessage *)message isOutgoing:(BOOL)outGoing withStatus:(int)status withTime:(long)timeStamp{
    
    //1. Get message from player_message table
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM player_message WHERE message_id = '%@'", [message attributeStringValueForName:@"id"]];
    NSMutableArray *messageDetails = [[DBManager sharedInstance] findRecord:query];
    
    if ([messageDetails count] > 0) {
        
        NSMutableDictionary *messageInfo = [messageDetails objectAtIndex:0];
        
        //Prepare image to show
        JSQVideoMediaItem *videoItem;
        if (outGoing) { //Load image from local
            videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:[messageInfo valueForKey:@"media_url"] withThumb:nil isReadyToPlay:YES];
        }
        else{
            if ([[messageInfo valueForKey:@"is_local"] intValue] == 1) { //Show Downloaded image
                videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:[messageInfo valueForKey:@"media_url"] withThumb:nil isReadyToPlay:YES];
            }
            else{
                //Convert the base64 data into image
                NSString *image64 = [message valueForKey:@"body"];
                NSRange range = [image64 rangeOfString:VIDEO_KEY];
                NSString *originalImage = [image64 substringFromIndex:range.length];
                UIImage *image = [Util stringToUIImage:originalImage];
                image = [Util addBlurEffect:image];
                videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:nil withThumb:image isReadyToPlay:YES];
            }
        }
        
        //Apply mask
        videoItem.appliesMediaViewMaskAsOutgoing = outGoing;        
        
        //Read sender, name, image
        NSXMLElement *userData = [message elementForName:@"userdata"];
        NSString *fromId = [[userData elementForName:@"from"] stringValue];
        NSArray *nameAndImage = [[ChatDBManager sharedInstance] getNameAndImage:message isOutGoing:outGoing];
        
        JSQMessagesAvatarImage  *senderImage;
        [self setAvatarImages:fromId fromUrl:nameAndImage[1]];
        JSQMessage *videoMessage = [[JSQMessage alloc] initWithSenderId:fromId
                                                      senderDisplayName:nameAndImage[0]
                                                                   date:[NSDate dateWithTimeIntervalSince1970:timeStamp]
                                                                  media:videoItem
                                                                 avatar:senderImage];
        
        NSMutableDictionary *messageData = [[NSMutableDictionary alloc] init];
        [messageData setValue:message.description forKey:@"body"];
        [messageData setValue:[message attributeStringValueForName:@"id"] forKey:@"id"];
        [messageData setValue:[NSNumber numberWithInt:status] forKey:@"status"];
        [messageData setValue:[NSNumber numberWithInt:3] forKey:@"type"];
        [messageData setValue:videoMessage forKey:@"JSQMessage"];
        [messageData setValue:[NSNumber numberWithLong:timeStamp] forKey:@"timestamp"];
        [messageData setValue:[messageInfo valueForKey:@"media_url"] forKey:@"mediaUrl"];
        [messageData setValue:[messageInfo valueForKey:@"is_local"] forKey:@"is_local"];
        [messageData setValue:[messageInfo valueForKey:@"is_sent"] forKey:@"is_sent"];
        [messageData setValue:[NSNumber numberWithBool:outGoing] forKey:@"is_outgoing"];
        [messageData setValue:[Util getChatHistoryTime:[NSString stringWithFormat:@"%ld",timeStamp]] forKey:@"relativeTime"];
        [self setTaskIdentifierForMessage:messageData];
        [self sortMessages];
        if (!outGoing) {
            [messageData setValue:[self getFileSize:message] forKey:@"filesize"];
        }

        [messages addObject:messageData];
        [self.collectionView reloadData];
        
        outGoing ? [self finishSendingMessageAnimated:YES] : [self finishReceivingMessageAnimated:YES];
    }
}

- (void)setTaskIdentifierForMessage:(NSMutableDictionary *)messageData{
    NSURLSessionUploadTask *task = [delegate.downloadingMessageTasks valueForKey:[messageData valueForKey:@"id"]];
    if (task != nil) {
        NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier];
        [messageData setValue:taskIdentifier forKey:@"task_identifier"];
    }
    else{
        [messageData setValue:@"dummy" forKey:@"task_identifier"];
    }
}


//Set avatar images for bubbles
- (void)setAvatarImages:(NSString *)senderId fromUrl:(NSString*)url{
    
    NSMutableDictionary *avatars = [[ChatDBManager sharedInstance] avatarImages];
    NSMutableDictionary *avatar = [avatars objectForKey:senderId];
    //1.Check user already has avatar
    if (avatar != nil) {
        if (![[avatar valueForKey:@"avatarUrl"] isEqualToString:url]) {
             [self getAvatarImages:senderId fromUrl:url];
        }
    }
    //2.Create new avatar
    else{
        [self getAvatarImages:senderId fromUrl:url];
    }
}

//Get avatar images
- (void)getAvatarImages:(NSString *)senderId fromUrl:(NSString*)url{
    
    //Sender Avatar
    UIImageView *senderImage = [[UIImageView alloc] init];
    NSURLRequest *senderRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __block NSString *avatarId = senderId;
    __block NSString *avatarUrl = url;
    [senderImage setImageWithURLRequest:senderRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        
        JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                   diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        NSMutableDictionary *avatar = [[NSMutableDictionary alloc] init];
        [avatar setObject:avatarImage forKey:@"avatar"];
        [avatar setObject:avatarId forKey:@"avatarId"];
        [avatar setValue:avatarUrl forKey:@"avatarUrl"];
        
        //Update or set
        NSMutableDictionary *avatars = [[ChatDBManager sharedInstance] avatarImages];
        [avatars setObject:avatar forKey:avatarId];
        
        [self.collectionView reloadData];
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
}

- (BOOL)canSend{
    XMPPStream *xmppStream = [XMPPServer sharedInstance].xmppStream;
    if ([[Util sharedInstance] getNetWorkStatus] && xmppStream.isAuthenticated && xmppStream.isConnected) {
        return TRUE;
    }
    else{
        return FALSE;
    }
}


- (NSString *)getFileSize:(XMPPMessage *)message{
    NSXMLElement *userData = [message elementForName:@"userdata"];
    NSXMLElement *fileSize = [userData elementForName:@"filesize"];
    return fileSize != nil ? [fileSize stringValue] : @"";
}

/////////////// Send Messages Ends//////////////

-(BOOL)isUserLeft :(NSMutableDictionary *)data
{
    NSString *msgBody = [data objectForKey:@"body"];
    NSError *error;
    XMPPMessage *message = [[XMPPMessage alloc] initWithXMLString:msgBody error:&error];
    
    if (error == nil) {
        NSXMLElement *userleft = [message elementForName:@"teamstatus"];
        
        if(userleft != nil)
        {
            return TRUE;
        }
    }
   return FALSE;
}

- (void)sortMessages{
//    messages = [[messages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        NSMutableDictionary *first = (NSMutableDictionary *)a;
//        NSMutableDictionary *second = (NSMutableDictionary*)b;
//        return [[first valueForKey:@"timestamp"] longLongValue] > [[second valueForKey:@"timestamp"] longLongValue];
//    }] mutableCopy];
}

// Register upload progress for media upload Request
-(void)registerForUploadRequest
{
    [[Util sharedInstance].httpFileTaskManager setTaskDidSendBodyDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double percentDone = (totalBytesSent / (totalBytesExpectedToSend * 1.0f));
            
            NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier];
            int index = [Util getMatchedObjectPosition:@"task_identifier" valueToMatch:taskIdentifier from:messages type:0];
            if (index != -1) {
                
                //Save the progress value globally
                NSMutableDictionary *messageData = [messages objectAtIndex:index];
                [delegate.upDownProgress setValue:[NSNumber numberWithDouble:percentDone] forKey:[messageData valueForKey:@"id"]];
                
                //Reload the cell to show progress
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        });
    } ];
}


// Register download progress for video Request
-(void)registerForDownloadRequest
{
    [[Util sharedInstance].httpMultiFileTaskManager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double percentDone = (totalBytesWritten / (totalBytesExpectedToWrite * 1.0f));
            
            NSString *taskIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)downloadTask.taskIdentifier];
            int index = [Util getMatchedObjectPosition:@"task_identifier" valueToMatch:taskIdentifier from:messages type:0];
            if (index != -1) {
                
                //Save the progress value globally
                NSMutableDictionary *messageData = [messages objectAtIndex:index];
                [delegate.upDownProgress setValue:[NSNumber numberWithDouble:percentDone] forKey:[messageData valueForKey:@"id"]];
                
                //Reload the cell to show progress
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        });
        
    }];
}

-(void)checkUploadMediaAvailable
{
    //[messageInfo setValue:taskIdentifier forKey:@"task_identifier"];
}


@end
