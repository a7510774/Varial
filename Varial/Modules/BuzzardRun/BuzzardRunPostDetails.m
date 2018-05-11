//
//  BuzzardRunPostDetails.m
//  Varial
//
//  Created by vis-1041 on 3/30/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "BuzzardRunPostDetails.h"
#import "BuzzardRunComments.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GoogleAdMob.h"
#import "PostDetailCell.h"

@interface BuzzardRunPostDetails ()

@end

@implementation BuzzardRunPostDetails

BOOL isScrolled, isPlay;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    mediaList = [[NSMutableArray alloc] init];
    [self designTheView];
    [self createPopupView];
    isScrolled = isPlay = isStarPressed = FALSE;
    needToReloadPostHeader = FALSE;
    
    //Render local post details
    if (_isFromNotification != nil) {
        [self getPostDetails];
    }
    else{
        [self renderThePage:_postDetails];
    }
    
    //Show Ad
    [[GoogleAdMob sharedInstance] addAdInViewController:self];
}

- (void)viewDidAppear:(BOOL)animated{
    
    //Move to specific index
    if ([mediaList count]>0 && !isScrolled) {
        isScrolled = TRUE;
        [self.postTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_startIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    //Auto play video
    if ([mediaList count] > 0 && _isFromNotification == nil && !imagePresent && !isPlay) {
        isPlay = TRUE;
        [self playVideoAtIndex:0];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    //Get post details from server
    if (needToReloadPostHeader) {
        //Change the count
        long cComment = [[_postDetails valueForKey:@"comments_count"] longLongValue];
        NSString *comment = cComment > 1 ? @"%@ Comments" : @"%@ Comment";
        NSString *cmdCount = (cComment == 0 ) ? @"Comment" : comment;
        _commentCount.text = [NSString stringWithFormat:NSLocalizedString(cmdCount, nil),[_postDetails valueForKey:@"comments_count"]];
        needToReloadPostHeader = FALSE;

    }
    if (selectedMediaIndex != nil) {
        NSMutableDictionary *imageInfo = [mediaList objectAtIndex:selectedMediaIndex.row];
        UITableViewCell *cell = [self.postTable cellForRowAtIndexPath:selectedMediaIndex];
        [self designTheStarView:[[imageInfo valueForKey:@"star_status"] boolValue] fromCell:cell fromData:imageInfo];
        selectedMediaIndex = nil;
    }
    
    appDelegate.shouldAllowRotation = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView{
    self.postTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [Util addEmptyMessageToTableWithHeader:_postTable withMessage:@"" withColor:[UIColor whiteColor]];
    [self.postTable setHidden:YES];
    [_headerView setHeader:NSLocalizedString(POST_DETAIL, nil)];

    [_headerView.logo setHidden:YES];
    _name.delegate = self;
    
    [self.postTable registerNib:[UINib nibWithNibName:@"PostDetailCell" bundle:nil] forCellReuseIdentifier:@"PostDetailCell"];
}

-(void)createPopupView
{
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(MEDIA, nil)];
    popupView.message.text = NSLocalizedString(DELETE_MEDIA, nil);
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    [self deleteMedia];
}

- (void)onNoClick{
    [yesNoPopup dismiss:YES];
}

-(void)deleteMedia
{
    NSMutableDictionary *imageInfo = [mediaList objectAtIndex:selectedIndexPath.row];
    
    [_postTable beginUpdates];
    [mediaList removeObjectAtIndex:selectedIndexPath.row];
    if ([mediaList count] ==0) {
        [_postDetails setValue:[NSNumber numberWithBool:NO] forKey:@"image_present"];
    }
    [_postTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation: UITableViewRowAnimationLeft];
    [_postTable endUpdates];
    
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_postId forKey:@"post_id"];
    if (imagePresent) {
        [inputParams setValue:[imageInfo valueForKey:@"image_id"] forKey:@"media_id"];
    }
    else{
        [inputParams setValue:[imageInfo valueForKey:@"video_id"] forKey:@"media_id"];
    }
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:MEDIA_DELETE withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:NO];
    
    [yesNoPopup dismiss:YES];
    
}


//Calculate tableview header height based on content
- (void)renderThePage:(NSMutableDictionary *)postInfo{
    
    float headerHeight = 40 ;
    
    //Apply profile image
    NSDictionary *profileImage = [postInfo objectForKey:@"posters_profile_image"];
    NSString *imageUrl = [NSString stringWithFormat:@"%@",[profileImage valueForKey:@"profile_image"]];
    [_profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFriendProfile)];
    [_profileImage setUserInteractionEnabled:YES];
    [_profileImage addGestureRecognizer:tap];
    
    //Add zoom
    //[[Util sharedInstance] addImageZoom:_profileImage];
    
    //Apply header info
    NSString *postDescription = [postInfo objectForKey:@"post_description"];
    NSString *nameValue = [postInfo objectForKey:@"name"];
    _name.textColor = UIColorFromHexCode(GREY_TEXT);
    [_name setText:[NSString stringWithFormat:@"%@ %@",nameValue,postDescription]];
    NSRange range = NSMakeRange(0, [nameValue length]);
    [Util makeAsLink:_name withColor:[UIColor blackColor] showUnderLine:NO range:range];
    
    
    //Header name height
    //[_name sizeToFit];
    //headerHeight = headerHeight + _name.frame.size.height + 30;
    // _profileImageHeader = _Name height + _postdate height + extra height for constrains (top, bottom, vertical) spacing
    [_profileImageHeader setFrame:CGRectMake(_profileImageHeader.frame.origin.x, _profileImageHeader.frame.origin.y, _profileImageHeader.frame.size.width, _name.frame.size.height + 55)];
    headerHeight = headerHeight + _profileImageHeader.frame.size.height;
    if (_isFromNotification != nil) {
        headerHeight = headerHeight + 20;
    }
    
    _postedDate.text = [Util timeStamp:[[postInfo valueForKey:@"time_stamp"]longValue]];
    
    //Change the privacy type icon
    [_postTypeIcon setImage:[Util getImageForPrivacyType:[[postInfo valueForKey:@"privacy_type"] intValue]]];
    
    //Bind the checkin details
    if ([[postInfo objectForKey:@"check_in_details"] count] > 0) {
        NSDictionary *checkin = [[postInfo objectForKey:@"check_in_details"] objectAtIndex:0];
        _checkinTitle.text = [checkin valueForKey:@"name"];
        latitude = [checkin valueForKey:@"latitude"];
        longitude = [checkin valueForKey:@"longitude"];
        
        headerHeight = headerHeight + _checkinView.frame.size.height;
        [_checkinView setHidden:NO];
    }
    else{
        [_checkinView hideByHeight:YES];
    }
    
    //Bind the post content
    if ([[postInfo valueForKey:@"post_content"] isEqualToString:@""]) {
        _postContent.text = @"";
        [_postContent sizeToFit];
        headerHeight = headerHeight + _postContent.frame.size.height + 20;
    }
    else{
        _postContent.text = [postInfo valueForKey:@"post_content"];
        if([[_postDetails valueForKey:@"continue_reading_flag"] boolValue]){
            [Util setAddMoreTextForLabel:_postContent endsWithString:ENDS_WITH_STRING forlength:[_postContent.text length] forColor:UIColorFromHexCode(THEME_COLOR)];
            _postContent.delegate = self;
        }
        [_postContent sizeToFit];
        headerHeight = headerHeight + _postContent.frame.size.height + 20 + 10;
        
    }
    
    //Bind the media details
    //Check for Image/Video present
    imagePresent = [[postInfo valueForKey:@"image_present"] boolValue];
    if (imagePresent) {
        mediaList = [postInfo objectForKey:@"image"];
        [_postTable reloadData];
    }
    else{
        mediaList = [postInfo objectForKey:@"video"];
        [_postTable reloadData];
        
    }
    
    //Set the star and comment status
    //Change the star color
    [self changeTheStarColor:[[postInfo valueForKey:@"star_status"] boolValue] withCount:[postInfo valueForKey:@"stars_count"]];
    star = [[postInfo valueForKey:@"star_status"] boolValue];
    
    //Change the count
    long cComment = [[postInfo valueForKey:@"comments_count"] longLongValue];
    NSString *comment = cComment > 1 ? @"%@ Comments" : @"%@ Comment";
    NSString *cmdCount = (cComment == 0 ) ? @"Comment" : [NSString stringWithFormat:comment,[postInfo valueForKey:@"comments_count"]];
    _commentCount.text = [NSString stringWithFormat:NSLocalizedString(cmdCount, ni)];
    
    //Alter the table height
    CGRect rect = _postHeader.frame;
    rect.size.height = headerHeight;
    _postHeader.frame = rect;
    [_postTable setTableHeaderView:_postHeader];
    [self.postTable setHidden:NO];
}


-(void)showFriendProfile
{
    if ([[_postDetails valueForKey:@"am_owner"] boolValue]) {
        MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
        [self.navigationController pushViewController:myProfile animated:YES];
    }
    else{
        FriendProfile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        profile.friendName = [_postDetails objectForKey:@"name"];
        profile.friendId = [_postDetails objectForKey:@"post_owner_id"];
        [self.navigationController pushViewController:profile animated:YES];
    }
}


//Common Delegate for TTTAttributed Label
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    if (label == _name) {
        [self showFriendProfile];
    }
    else{
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[_postDetails valueForKey:@"post_id"] forKey:@"post_id"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [_postDetails setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                [_postDetails setValue:[NSNumber numberWithBool:FALSE] forKey:@"continue_reading_flag"];
                [self renderThePage:_postDetails];
            }else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        } isShowLoader:NO];
    }
}


// Add star or unstar for post
- (IBAction)putStar:(id)sender {
    
    if([[Util sharedInstance] getNetWorkStatus])
    {
        if (!isStarPressed) {
            
            isStarPressed = TRUE;
            
            //Build Input Parameters
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            [inputParams setValue:_postId forKey:@"post_id"];
            [inputParams setValue:[NSNumber numberWithBool:!star] forKey:@"star_flag"];
            
            //change star color
            NSString *countString = [_postDetails valueForKey:@"stars_count"];
            long count = [countString longLongValue];
            count = star ? count - 1 : count + 1;
            [self changeTheStarColor:star withCount:[NSString stringWithFormat:@"%ld",count]];
            
            
            [[Util sharedInstance]  sendHTTPPostRequestWithError:inputParams withRequestUrl:STAR_UNSTAR withCallBack:^(NSDictionary * response, NSError *error){
                
                isStarPressed = FALSE;
                
                if (error != nil) {
                    [self changeTheStarColor:star withCount:countString];
                }
                else{
                    
                    if([[response valueForKey:@"status"] boolValue]){
                        star = !star;
                        [self changeTheStarColor:star withCount:[response valueForKey:@"star_count"]];
                        [_postDetails setValue:[response valueForKey:@"star_count"] forKey:@"stars_count"];
                        [_postDetails setValue:[NSNumber numberWithBool:star] forKey:@"star_status"];
                    }
                    else{
                        [self changeTheStarColor:star withCount:countString];
                        [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
                    }
                }
            } isShowLoader:NO];
        }
    }
}

//Move to comment list page for post
- (IBAction)addCommentForPost:(id)sender {
    BuzzardRunComments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"BuzzardRunComments"];
    comment.postId = _postId;
    comment.postDetails = _postDetails;
    comment.buzzardRunId = [_postDetails objectForKey:@"buzzard_run_id"];
    comment.buzzardRunEventId = [_postDetails objectForKey:@"buzzard_run_event_id"];
    needToReloadPostHeader = TRUE;
    [self.navigationController pushViewController:comment animated:YES];
}

- (IBAction)moveToCheckinPage:(id)sender {
    ShowCheckinInMap *checkinMap = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowCheckinInMap"];
    checkinMap.checkinName = _checkinTitle.text;
    checkinMap.latitude = latitude;
    checkinMap.longitude = longitude;
    [self.navigationController pushViewController:checkinMap animated:YES];
    
}

- (IBAction)mediaDelete:(id)sender
{
    CGPoint tapLocation = [sender convertPoint:CGPointZero toView:self.postTable];
    selectedIndexPath = [self.postTable indexPathForRowAtPoint:tapLocation];
    [yesNoPopup show];
}

//Get post details
- (void)getPostDetails{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_postId forKey:@"post_id"];
    
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:POST_DETAILS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            
            _mediaBase = [response valueForKey:@"media_base_url"];
            [self createMutableCopy:[[response objectForKey:@"post_detail"] mutableCopy]];
            
        }else{
            [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
        }
    } isShowLoader:YES];
}

- (void)createMutableCopy:(NSMutableDictionary *)response{
    
    _postDetails = response;
    
    NSMutableDictionary *profileImage = [[_postDetails objectForKey:@"posters_profile_image"] mutableCopy];
    [profileImage setValue: [NSString stringWithFormat:@"%@%@",_mediaBase,[profileImage  valueForKey:@"profile_image"]] forKey:@"profile_image"];
    [_postDetails setObject:profileImage forKey:@"posters_profile_image"];
    
    NSMutableArray *mediasList = [[_postDetails valueForKey:@"image_present"] boolValue] ? [[_postDetails objectForKey:@"image"] mutableCopy] : [[_postDetails objectForKey:@"video"] mutableCopy];
    for (int i=0; i<[mediasList count]; i++) {
        NSMutableDictionary *media = [[mediasList objectAtIndex:i] mutableCopy];
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",_mediaBase,[media valueForKey:@"media_url"]];
        [media setValue:imageUrl forKey:@"media_url"];
        [mediasList replaceObjectAtIndex:i withObject:media];
    }
    
    if ([[_postDetails valueForKey:@"image_present"] boolValue]) {
        [_postDetails setObject:mediasList forKey:@"image"];
    }
    else{
        [_postDetails setObject:mediasList forKey:@"video"];
    }
    
    [self renderThePage:_postDetails];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//Change the star color
- (void)changeTheStarColor:(BOOL)status withCount:(NSString *)count{
    if (status) {
        [_starImage setImage:[UIImage imageNamed:@"starActive.png"]];
        _starCount.textColor = UIColorFromHexCode(THEME_COLOR);
    }
    else{
        [_starImage setImage:[UIImage imageNamed:@"star.png"]];
        _starCount.textColor = UIColorFromHexCode(GREY_TEXT);
    };
    long sCount = [count longLongValue];
    NSString *starValue = sCount > 1 ? @"%@ Stars" : @"%@ Star";
    NSString *strCount = (sCount == 0 ) ? @"Star" : starValue;
    _starCount.text = [NSString stringWithFormat:NSLocalizedString(strCount, ni),count];
}


// Show the comment page
- (IBAction)showCommentPage:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_postTable];
        NSIndexPath *path = [_postTable indexPathForRowAtPoint:buttonPosition];
        
        BuzzardRunComments *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"BuzzardRunComments"];
        NSMutableDictionary *imageInfo = [mediaList objectAtIndex:path.row];
        comment.postId = _postId;
        if ([[_postDetails valueForKey:@"image_present"] boolValue]) {
            comment.mediaId = [imageInfo valueForKey:@"image_id"];
        }
        else{
            comment.mediaId = [imageInfo valueForKey:@"video_id"];
        }
        comment.buzzardRunId = [imageInfo objectForKey:@"buzzard_run_id"];
        comment.buzzardRunEventId = [imageInfo objectForKey:@"buzzard_run_event_id"];
        comment.mediaDetails = imageInfo;
        selectedMediaIndex = path;
        [self.navigationController pushViewController:comment animated:YES];
    }
}

// Add star or unstar for media
- (IBAction)addOrRemoveStar:(id)sender
{
    if([[Util sharedInstance] getNetWorkStatus])
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_postTable];
        NSIndexPath *path = [_postTable indexPathForRowAtPoint:buttonPosition];
        
        NSMutableDictionary *imageInfo = [mediaList objectAtIndex:path.row];
        
        if ([[imageInfo valueForKey:@"isEnabled"] isEqualToString:@"true"]) {
            
            [imageInfo setValue:@"false" forKey:@"isEnabled"];
            
            //change star color
            BOOL stat = [[imageInfo valueForKey:@"star_status"] boolValue] ;
            NSString *countString = [imageInfo valueForKey:@"stars_count"];
            long count = [countString longLongValue];
            count = stat ? count - 1 : count + 1;
            [self changeStarStaus:path status:![[imageInfo valueForKey:@"star_status"] boolValue] count:[NSString stringWithFormat:@"%ld",count]];
            
            
            //Build Input Parameters
            NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
            [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
            [inputParams setValue:_postId forKey:@"post_id"];
            if (imagePresent) {
                [inputParams setValue:[imageInfo valueForKey:@"image_id"] forKey:@"media_id"];
            }
            else{
                [inputParams setValue:[imageInfo valueForKey:@"video_id"] forKey:@"media_id"];
            }
            
            BOOL status = [[imageInfo valueForKey:@"star_status"] boolValue];
            [inputParams setValue:[NSNumber numberWithBool:status] forKey:@"star_flag"];
            
            
            
            [[Util sharedInstance]  sendHTTPPostRequestWithError:inputParams withRequestUrl:STAR_FOR_MEDIA withCallBack:^(NSDictionary * response, NSError *error){
                
                [imageInfo setValue:@"true" forKey:@"isEnabled"];
                
                if (error != nil) {
                    [self changeStarStaus:path status:![[imageInfo valueForKey:@"star_status"] boolValue] count:countString];
                }
                else{
                    if([[response valueForKey:@"status"] boolValue]){
                        
                        //change star color
                        [self changeStarStaus:path status:[[imageInfo valueForKey:@"star_status"] boolValue] count:[response valueForKey:@"star_count"]];
                    }
                    else{
                        //change star color
                        [self changeStarStaus:path status:![[imageInfo valueForKey:@"star_status"] boolValue] count:countString];
                        [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
                    }
                }
                
            } isShowLoader:NO];
        }
    }
}

//Change star staus color
- (void)changeStarStaus:(NSIndexPath *)path status:(BOOL)status count:(NSString *)starCount{
    
    if ([mediaList count] > path.row) {
        
        NSMutableDictionary *imageInfo = [mediaList objectAtIndex:path.row];
        [imageInfo setValue:starCount forKey:@"stars_count"];
        [imageInfo setValue:[NSNumber numberWithBool:status] forKey:@"star_status"];
        [mediaList replaceObjectAtIndex:path.row withObject:imageInfo];
        UITableViewCell *cell = [self.postTable cellForRowAtIndexPath:path];
        [self designTheStarView:status fromCell:cell fromData:imageInfo];
    }
}

//Play video
- (IBAction)playVideo:(id)sender{
    
    // Get index from the table
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.postTable];
    NSIndexPath *indexPath = [self.postTable indexPathForRowAtPoint:buttonPosition];
    [self playVideoAtIndex:(int)indexPath.row];
}

- (void)playVideoAtIndex:(int)index{
    
    if ([mediaList count] > index) {
        
        NSString *mediaUrl = [[mediaList objectAtIndex:index] valueForKey:@"media_url"];
        NSString *thumbUrl = [NSString stringWithFormat:@"%@%@",_mediaBase,[[mediaList objectAtIndex:index] valueForKey:@"video_thumb_image_url"]];
        NSString *mediaId = [[mediaList objectAtIndex:index] valueForKey:@"video_id"];
        
        [[[Util sharedInstance] playVideo:mediaUrl withThumb:nil fromController:self withUrl:thumbUrl] play];
        [Util sharedInstance].playedMediaId = mediaId;
    }
}


//Show slider
//Show or hide the context menu
- (void)showSlider:(UITapGestureRecognizer *)tapRecognizer
{
    // Get index from the table
    CGPoint buttonPosition = [tapRecognizer.view convertPoint:CGPointZero toView:self.postTable];
    NSIndexPath *indexPath = [self.postTable indexPathForRowAtPoint:buttonPosition];
    NSMutableArray *sliderImages = [[NSMutableArray alloc] init];
    for (int i=0; i<[mediaList count]; i++) {
        NSMutableDictionary *img = [[NSMutableDictionary alloc] init];
        [img setValue:[[mediaList objectAtIndex:i] valueForKey:@"media_url"] forKey:@"imageUrl"];
        [sliderImages addObject:img];
    }
    [Util showSlider:self forImage:sliderImages atIndex:indexPath.row];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mediaList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostDetailCell *cell;
    
    cell= (PostDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"PostDetailCell"];
    if (cell == nil)
    {
        cell = [[PostDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PostDetailCell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.downloadProgress = [Util designdownloadProgress:cell.downloadProgress];
    
    NSMutableDictionary *mediaData = [mediaList objectAtIndex:indexPath.row];
    
    [cell.deleteButton setHidden:YES];
    
    NSString *thumbUrl;
    
    if (imagePresent ){
        thumbUrl = [mediaData valueForKey:@"media_url"];
    }else{
        thumbUrl = [NSString stringWithFormat:@"%@%@",_mediaBase,[mediaData valueForKey:@"video_thumb_image_url"]];
    }
    
    CGSize imageSize = [Util getAspectRatio:[mediaData valueForKey:@"media_dimension"] ofParentWidth:self.view.frame.size.width - 20];
    cell.mediaHeight.constant = imageSize.height;
    
    [cell.image.layer setValue:[mediaData valueForKey:@"media_dimension"] forKey:@"dimension"];
    
    [cell.image yy_setImageWithURL:[NSURL URLWithString:thumbUrl]
                      placeholder:[UIImage imageNamed:@"image_placeholder.png"]
                          options:YYWebImageOptionProgressiveBlur | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             if (expectedSize > 0 && receivedSize > 0) {
                                 CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                 cell.downloadProgress.hidden = NO;
                                 [cell.downloadProgress setValue:progress];
                             }
                         }
                        transform:nil
                       completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                           if (stage == YYWebImageStageFinished) {
                               
                               cell.downloadProgress.hidden = YES;
                               if (!image)
                                   cell.image.image = image;
                           }
                       }];
    
    //Bind the data
    //Check image or video present
    if(imagePresent){
        
        [cell.videoButton setHidden:YES];
        
        //imageview tap listner
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSlider:)];
        [cell.image setUserInteractionEnabled:YES];
        [cell.image addGestureRecognizer:tap];
        
        //Hide the view count label for local videos
        cell.videoViewCountHeight.constant = 0;
    }
    else{
        
        //Show the view count label for video post
        long viewCount = [[mediaData objectForKey:@"views_count"] longLongValue];
        if (viewCount == 0) {
            //Hide the view count label for post contains 0 views
            cell.videoViewCountHeight.constant = 0;
        }
        else{
            cell.videoViewCountHeight.constant = 20;
            cell.videoViewCount.text = [Util getViewsString:viewCount];
        }
        
        [cell.videoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.image setImage:[Util convertColorToImageWithSize:UIColorFromHexCode(0xdcdcdc) width:300 height:250]];
        [cell.videoButton setHidden:NO];
    }
    
    //Set the star and comment status
    //Change the star color
    [self designTheStarView:[[mediaData valueForKey:@"star_status"] boolValue] fromCell:cell fromData:mediaData];
    
    
    //Add click events
    [cell.commentButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.commentButton addTarget:self action:@selector(showCommentPage:) forControlEvents:UIControlEventTouchUpInside];
    [cell.starButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.starButton addTarget:self action:@selector(addOrRemoveStar:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)designTheStarView:(BOOL)status fromCell:(UITableViewCell *)cell fromData:(NSMutableDictionary *)mediaData{
    
    UIImageView *starImage = (UIImageView *)[cell viewWithTag:110];
    UILabel *starCount =  (UILabel *)[cell viewWithTag:120];
    UILabel *commentCount = (UILabel *) [cell viewWithTag:121];
    
    //Change the star color
    if (status) {
        [starImage setImage:[UIImage imageNamed:@"starActive.png"]];
        starCount.textColor = UIColorFromHexCode(THEME_COLOR);
        NSLog(@"ACtive");
    }else{
        [starImage setImage:[UIImage imageNamed:@"star.png"]];
        starCount.textColor = UIColorFromHexCode(GREY_TEXT);
        NSLog(@"inactive");
    }
    
    //Change the count
    long sCount = [[mediaData valueForKey:@"stars_count"] longLongValue];
    long cComment = [[mediaData valueForKey:@"comments_count"] longLongValue];
    NSString *starValue = sCount > 1 ? @"%@ Stars" : @"%@ Star";
    NSString *strCount = (sCount == 0 ) ? @"Star" : starValue;
    
    NSString *comment = cComment > 1 ? @"%@ Comments" : @"%@ Comment";
    NSString *cmdCount = (cComment == 0 ) ? @"Comment" : comment;
    starCount.text = [NSString stringWithFormat:NSLocalizedString(strCount, nil),[mediaData valueForKey:@"stars_count"]];
    commentCount.text = [NSString stringWithFormat:NSLocalizedString(cmdCount, nil),[mediaData valueForKey:@"comments_count"]];
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}


@end
