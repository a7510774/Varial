//
//  ProfilePicture.m
//  Varial
//
//  Created by jagan on 29/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ProfilePicture.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "ChatDBManager.h"
#import "Feeds.h"

@interface ProfilePicture ()

@end

@implementation ProfilePicture

NSArray *textField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    textField = [[NSArray alloc] initWithObjects:_inviteCode, nil];
    [self designTheView];
    [self createPopUpWindows];
    [_inviteCode addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
}

/*! doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton
{
    if(visibleWindow==1)
        [self applyInviteRequest];        
}

- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [_spinnerView stopAnimating];
    [_spinnerView startAnimating];
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) designTheView{
    
    for (UITextField *field in textField){
        [Util createBottomLine:field withColor:UIColorFromHexCode(TEXT_BORDER)];
    }
    self.profileImage.image = [UIImage imageNamed:IMAGE_HOLDER];
    
//    [Util createRoundedCorener:_inviteView withCorner:5];
    [Util createRoundedCorener:_applyButton withCorner:3];
    [Util createRoundedCorener:_applySkipButton withCorner:3];
    [Util createRoundedCorener:_profileSkip withCorner:3];
    [Util createRoundedCorener:_friendView withCorner:5];
    
    [self addClickEventToImage];
    
    //Design the spinner
    _spinnerView.lineWidth = 2.0f;
    // Optionally change the tint color
    _spinnerView.tintColor = UIColorFromHexCode(THEME_COLOR);
    
//    _inviteMessageLabel.text = _inviteMessage;
    
    if (IPAD) {
        [_profileImage setFrame:CGRectMake(_profileImage.frame.origin.x, _profileImage.frame.origin.y, 250, 250)];
    }
    
    _profileImage.layer.cornerRadius=_profileImage.bounds.size.height/2;
    _profileImage.layer.masksToBounds = YES;
    _profileImage.layer.borderColor = UIColorFromHexCode(THEME_COLOR).CGColor;
    _profileImage.layer.borderWidth = 3.0;
   
    [self designHowToSendInviteButton];
}

-(void)designHowToSendInviteButton
{
    NSMutableAttributedString *commentString ;
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        commentString = [[NSMutableAttributedString alloc] initWithString:HOW_TO_FIND_INVITE_CODE];
    }
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        commentString = [[NSMutableAttributedString alloc] initWithString:@"如何找到邀请码？"];
    }
    
    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
    [_findInvieCodeButton setAttributedTitle:commentString forState:UIControlStateNormal];
    
}


- (void) setTextfieldDelegates{
    for (UITextField *field in textField){
        field.delegate = self;
    }
}

- (void) createPopUpWindows{
    
//    invitePopup = [KLCPopup popupWithContentView:self.inviteView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    friendPopup = [KLCPopup popupWithContentView:self.friendView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    mediaPopupView = [[MediaPopup alloc] init];
    mediaPopupView.delegate = self;
    KLCMediaPopup = [KLCPopup popupWithContentView:mediaPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];   
}

- (IBAction)showHowToFind:(id)sender {
    
    NSString *launchUrl;
    
    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
    {
        launchUrl = @"https://www.varialskate.com/how-to-get-invitecode.php?lang_code=en-US";
    }
    else if([[Util getFromDefaults:@"language"] isEqualToString:@"zh"])
    {
        launchUrl = @"https://www.varialskate.com/how-to-get-invitecode.php?lang_code=zh";
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}

- (IBAction)skipProfilePic:(id)sender {
    if ([[[Util sharedInstance].httpFileTaskManager uploadTasks] count] > 0) {
        
    }
    else
    {
        [self moveToHomeScreen];
//        [self createPopUpWindows];
//        [_inviteView setHidden:NO];
//        [invitePopup show];
//        visibleWindow=1;
    }
}

- (IBAction)showHomePage:(id)sender {
//    [invitePopup dismiss:YES];
    [friendPopup dismiss:YES];
    [self moveToHomeScreen];
}


//Step 0 - set the click event to an image
//Add Click event to profile image
- (void) addClickEventToImage
{
    UITapGestureRecognizer *clickEvent = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseProfileImage)];
    [clickEvent setNumberOfTapsRequired:1];
    [_profileImage setUserInteractionEnabled:YES];
    [_profileImage addGestureRecognizer:clickEvent];
}

//Step 1 - launching the actionsheet with a button action
- (IBAction)chooseProfileImage:(id)sender {
    [self chooseProfileImage];
}

- (void)chooseProfileImage
{
    [SESSION setBoolValue:YES];
//    [Util setInDefaults:@"YES" withKey:@"isFromProfilePicture"];
    [self createPopUpWindows];
    [KLCMediaPopup show];
}

#pragma mark - MediaPopup delegates methods
-(void)onCameraClick{
    [KLCMediaPopup dismiss:YES];
    [self showCamera];
}

-(void)onGalleryClick{
    [KLCMediaPopup dismiss:YES];
     [self openPhotoAlbum];
}

-(void)onOkClick{
    [KLCMediaPopup dismiss:YES];
}


#pragma mark - Private methods
//step 3.1 handle for camera action
- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Place image picker on the screen
            [self presentViewController:controller animated:YES completion:NULL];
        }];
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

//step 3.2 handle for photot action
- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Place image picker on the screen
            [self presentViewController:controller animated:YES completion:NULL];
        }];
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

// step 4 - Receive the image from the gallery/camera Open PECropViewController automattically when image selected
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //replace with user image
    profilePicture = image;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [picker dismissViewControllerAnimated:YES completion:^{
                [self openEditor:nil];
            }];
        }];
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor:nil];
        }];
    }
}


//step 5 - Crop the image after the user chosen
#pragma mark - Action methods
- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    
    //replace with user image
    controller.image = profilePicture;
    controller.keepingCropAspectRatio = YES;
  
    
    CGFloat width = profilePicture.size.width;
    CGFloat height = profilePicture.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - PECropViewControllerDelegate methods
//Step - 6 - Update the profile image after cropping
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    //replace with user image
    self.profileImage.image = [Util resizeProfileImage:croppedImage];
    
    //Upload image
    [self uploadImage];
    
}

//Step - 7 - Perform action if the image is cancelled
- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [_spinnerView startAnimating];
    [controller dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"Cancelled...!");    
}

- (void) uploadImage{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    
    [_spinnerView setHidden:NO];
    
    NSData *imgData= UIImageJPEGRepresentation(self.profileImage.image,0.5);
    
    [[Util sharedInstance] sendHTTPPostRequestWithImage:inputParams withRequestUrl:PROFILE_IMAGE_API withImage:imgData  withFileName:@"profile_image" withCallBack:^(NSDictionary *response)  {
        
        [_spinnerView setHidden:YES];
        [_spinnerView stopAnimating];
        
        if ( response != nil && [[response valueForKey:@"status"] boolValue])
        {
            
            [self moveToHomeScreen];
            [[AlertMessage sharedInstance] showMessage:NSLocalizedString(@"Profile image updated successfully", nil)];
//            visibleWindow = 1;
//            [_inviteView setHidden:NO];
//            [invitePopup show];
        }
        
    } onProgressView:nil withExtension:@"filename.jpg" ofType:@"image/jpeg"];  
    
}

//Change the current screen
- (void)moveToHomeScreen{
    UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigation;
    [[ChatDBManager sharedInstance] createChatBadge];
}


-(void) viewWillDisappear:(BOOL)animated{
    
//    [_inviteView endEditing:YES];
    
}

//////////// Invite code ///////////////

- (IBAction)applyInviteCode:(id)sender {
    [self applyInviteRequest];
}

-(void)applyInviteRequest{
    
    if([self inviteCodeFormValidation]){
        
        //Send apply invite code signup request
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:_inviteCode.text forKey:@"invite_code"];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:APPLY_INVITE withCallBack:^(NSDictionary * response){
            
            if ([[response valueForKey:@"status"] boolValue]) {
                
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@",[response valueForKey:@"media_url"],[response valueForKey:@"friend_profile_image"]];
                [_friendImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
                
                _message.text = [response valueForKey:@"message"];
                _friendName.text = [response valueForKey:@"friend_name"];
                
                //Hide the invite popup
//                [invitePopup dismiss:YES];
                
                //Show firend accept
                [_friendView setHidden:NO];
                [friendPopup show];
                [_inviteCode resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        
    }
}

//Validat the invite code form
-(BOOL)inviteCodeFormValidation{
    
    [self resetInviteCodeForm];
    
    //Check OTP code is empty
    if(![Util validateNumberField:_inviteCode withValueToDisplay:INVITE_CODE withMinLength:INVITE_CODE_MIN withMaxLength:INVITE_CODE_MAX])
    {
        return FALSE;
    }
    
    return YES;
}


//Reset the Forgot form
- (void)resetInviteCodeForm{
    [Util createBottomLine:_inviteCode withColor:UIColorFromHexCode(TEXT_BORDER)];
}


//////////// Invite code ends //////////

@end
