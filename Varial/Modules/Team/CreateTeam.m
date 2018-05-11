//
//  CreateTeam.m
//  Varial
//
//  Created by Shanmuga priya on 2/26/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "CreateTeam.h"
#import "GoogleAdMob.h"
#import "IQKeyboardManager.h"
#import "ViewController.h"

@interface CreateTeam ()

@end

@implementation CreateTeam

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self designTheView];
    pictureChanged=FALSE;
    [self createPopupWindows];    
    
    if ([Util getWindowSize].height > 500) {
        //Show Ad
        [[GoogleAdMob sharedInstance] addAdInViewController:self];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [[IQKeyboardManager sharedManager] setEnable:YES];
     [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [Util createBottomLine:_teamNameTxtField withColor:[UIColor darkGrayColor]];
    [Util createBottomLine:_pointsTxtField withColor:[UIColor darkGrayColor]];
    
}

- (void)designTheView
{
    [_headerView setHeader:NSLocalizedString(CREATE_TEAM_TITLE, nil)];
    [_headerView.logo setHidden:YES];
    _profileImage.image = [UIImage imageNamed:IMAGE_HOLDER];
    
    if(IPAD)
    {
        [_profileImage setFrame:CGRectMake(_profileImage.frame.origin.x, _profileImage.frame.origin.y, 180, 180)];
    }
        
    _profileImage.layer.cornerRadius=_profileImage.bounds.size.height/2;
    _profileImage.layer.masksToBounds = YES;
    _profileImage.layer.borderColor = UIColorFromHexCode(THEME_COLOR).CGColor;
    _profileImage.layer.borderWidth = 3.0;
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [_teamNameTxtField addTarget:self  action:@selector(textChangeListener:)
           forControlEvents:UIControlEventEditingChanged];    
    [_pointsTxtField setValue:[NSString stringWithFormat:NSLocalizedString(MIN_POINTS_TO_JOIN, nil) ,_minimumPoints] forKeyPath:@"_placeholderLabel.text"];
   
}

-(void)createPopupWindows{
    mediaPopup=[[MediaPopup alloc]init];
    [mediaPopup setDelegate:self];
    KLCMediaPopup = [KLCPopup popupWithContentView:mediaPopup showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//--------------> Choose profile Image <---------------------------//

//show Media popup
- (IBAction)tappedAddProfilePicture:(id)sender {
    
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
    pictureChanged=TRUE;
}

//Step - 7 - Perform action if the image is cancelled
- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"Cancelled...!");
}


//------------------> Choose profile Image ends<------------------------//



//------------------> Choose team name <-----------------------------//


//Team name text change listener
- (void) textChangeListener :(UITextField *) searchBox
{
    if([self validateName])
    {
          if(task!=nil)
              [task cancel];
        [self getNameAvailability];
    }
    
}

-(BOOL)validateName{
    
    //Validate name
    if(![Util validateTextField:_teamNameTxtField withValueToDisplay:TEAM_NAME_TITLE withIsEmailType:FALSE withMinLength:NAME_MIN withMaxLength:NAME_MAX_LEN]){
        return FALSE;
    }
    if(![Util validCharacter:_teamNameTxtField forString:_teamNameTxtField.text withValueToDisplay:TEAM_NAME_TITLE]){
        return FALSE;
    }
    
    if(![Util validateName:_teamNameTxtField.text]){
        [Util showErrorMessage:_teamNameTxtField withErrorMessage:NSLocalizedString(INVALID_TEAM_NAME, nil)];
        return FALSE;
    }
    return  TRUE;
}


//check team name already exist
-(void)getNameAvailability{
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamNameTxtField.text forKey:@"team_name"];
    task = [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:TEAM_NAME_EXISTENCE withCallBack:^(NSDictionary * response){
        if(![[response valueForKey:@"status"] boolValue]){
            
               [Util createBottomLine:_teamNameTxtField withColor:UIColorFromHexCode(THEME_COLOR)];
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        else{
             [Util createBottomLine:_teamNameTxtField withColor:[UIColor darkGrayColor]];
        }
        
    } isShowLoader:NO];
    
}



//-----------------------> Choose team name  ends<--------------------------//



//-------------------> Create Team <-------------------------//


- (IBAction)tappedCreateTeam:(id)sender {
    
    if([self validateForm])
        if (!buttonClicked) {
            [self getCreateTeamStatus];
        }
}

//Create Team
-(void)getCreateTeamStatus{
    
    buttonClicked = TRUE;
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_teamNameTxtField.text forKey:@"team_name"];
    [inputParams setValue:_pointsTxtField.text forKey:@"minimum_point"];
    
    NSData *imgData= UIImageJPEGRepresentation(self.profileImage.image,0.5);
    MBProgressHUD *progress = [Util showLoading];
    [[Util sharedInstance] sendHTTPPostRequestWithImage:inputParams withRequestUrl:CREATE_TEAM withImage:imgData  withFileName:@"team_image" withCallBack:^(NSDictionary *response)  {
        [Util hideLoading:progress];
        if([[response valueForKey:@"status"] boolValue]){
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            dispatch_after(2, dispatch_get_main_queue(), ^{
                
                // Reload the team list api for showing team chat
                AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
                [appDelegate connectToChatServer];
                [appDelegate getTeamList];
                
                ViewController *viewController = [[self.navigationController viewControllers] firstObject];
                [viewController.feedTypeList removeAllObjects];
                [viewController setCurrentPage:0];
                [viewController.tabBar setSelectedItem:[[viewController.tabBar items] objectAtIndex:0]];
                
                TeamInvitiesViewController *teaminvities = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamInvitiesViewController"];
                teaminvities.teamId = [NSString stringWithFormat:@"%@",[response objectForKey:@"team_id"]];
                teaminvities.type = @"3";
                teaminvities.isCreateTeam = @"yes";
                [self.navigationController pushViewController:teaminvities animated:YES];
                
            });
        }
        else{
            buttonClicked = FALSE;
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        
    } onProgressView:nil withExtension:@"filename.jpg" ofType:@"image/jpeg"] ;

}

-(BOOL)validateForm{
    
    [self resetForm];
 
    if (!pictureChanged){
        [[AlertMessage sharedInstance] showMessage:TEAM_PIC_EMPTY];
        return  FALSE;
    }
    if(![self validateName])
    {
      return  FALSE;
    }
    if([[_pointsTxtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [[AlertMessage sharedInstance] showMessage:[NSString stringWithFormat:NSLocalizedString(ENTER_MIN_POINTS, nil)]];
        [Util createBottomLine:_pointsTxtField withColor:UIColorFromHexCode(THEME_COLOR)];
        return FALSE;
    }
    if(![Util validateNumberField:_pointsTxtField withValueToDisplay:POINTS_TO_JOIN withMinLength:POINTS_MIN withMaxLength:POINTS_MAX])
    {
        return FALSE;
    }

    if([_pointsTxtField.text intValue]< _minimumPoints){
        [[AlertMessage sharedInstance] showMessage:[NSString stringWithFormat:NSLocalizedString(MIN_POINTS_REQUIRED, nil),_minimumPoints]];
        [Util createBottomLine:_pointsTxtField withColor:UIColorFromHexCode(THEME_COLOR)];
        return  FALSE;
    }
    
    return  TRUE;
}

-(void)resetForm{
    [Util createBottomLine:_teamNameTxtField withColor:[UIColor darkGrayColor]];
    [Util createBottomLine:_pointsTxtField withColor:[UIColor darkGrayColor]];
}

//--------------------> Create Team  ends<-------------------//

@end
