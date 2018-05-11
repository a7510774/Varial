//
//  EditPostViewController.m
//  Varial
//
//  Created by Leif Ashby on 7/16/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "EditPostViewController.h"

@interface EditPostViewController ()

@end

@implementation EditPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isComposingDone = TRUE;
    
    _headerView.delegate = self;
    _comment.delegate = self;
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
    
    _inputParams = [[NSMutableDictionary alloc] init];
    [_inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];

    [self designTheView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self fillPostInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUrlPreview) name:@"ShowURLPreview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePreview) name:@"HideURLPreview" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowURLPreview" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideURLPreview" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backPressed {
    [self askBackConfirm: nil];
}

- (void)setPostInfo:(NSMutableDictionary *)info {
    postInfo = info;
    
    mediaCount = [[postInfo objectForKey:@"image_count"] intValue] + [[postInfo objectForKey:@"video_count"] intValue];
    hasCheckin = [[postInfo objectForKey:@"check_in_details"] count] > 0;
    
    if ([[postInfo objectForKey:@"continue_reading_flag"] intValue] == 1) {
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:[postInfo valueForKey:@"post_id"] forKey:@"post_id"];
        
        // Check for continue_reading_flag get rest of body before continuuing
        [[Util sharedInstance] sendHTTPPostRequest:inputParams withRequestUrl:GET_FULL_CONTENT withCallBack:^(NSDictionary * response){
            if([[response valueForKey:@"status"] boolValue]){
                [postInfo setValue:[response valueForKey:@"post_content"] forKey:@"post_content"];
                [postInfo setValue:[NSNumber numberWithBool:NO] forKey:@"continue_reading_flag"];
                [self fillPostInfo];
            }else{
                [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
            }
        } isShowLoader:YES];
    }

}

- (void)fillPostInfo {
    
    [_comment setText:[postInfo objectForKey:@"post_content"]];
    
    NSArray *urlPreviewDetails = [[NSArray alloc] initWithArray:[postInfo objectForKey:@"link_details"]];
    if ([urlPreviewDetails count] > 0) {
        NSDictionary *previewDetails = [[NSDictionary alloc] initWithDictionary:[urlPreviewDetails objectAtIndex:0]];
        [self checkForURL:[previewDetails objectForKey:@"link"]];
    }
}

- (BOOL)validatePostForm {
    //Check post content length
    if([[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0)
    {
        if([[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > POST_CONTENT_MAX)
        {
            [Util showErrorMessage:_comment withErrorMessage:[NSString stringWithFormat:NSLocalizedString(POST_CONTENT_DOES_MAX, nil),POST_CONTENT_MAX]];
            return NO;
        }
    }
    
    if (mediaCount == 0 && [[_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 && !hasCheckin &&  !isUrlPreviewShown) {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(BLANK_STATUS, nil)];
        return NO;
    }
    
    return YES;
}

- (IBAction)editPost:(id)sender {
    
    [_comment resignFirstResponder];
    
    if ([self validatePostForm] && isComposingDone) {
        
        if([[Util sharedInstance] getNetWorkStatus])
        {
            self.dimView.hidden = NO;
            self.spinnerView.hidden = NO;
            [self.spinnerView startAnimating];
            
            NSString *content = [_comment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [_inputParams setValue:content forKey:@"text"];
            
            NSString *strPostId = [NSString stringWithFormat:@"%@",[postInfo objectForKey:@"post_id"]];
            [_inputParams setValue:strPostId forKey:@"post_id"];
            
            [_inputParams setValue:[Util getFromDefaults:@"language"] forKey:@"language_code"];
            
            [[Util sharedInstance] sendHTTPPostRequest:_inputParams withRequestUrl:EDIT_POST withCallBack:^(NSDictionary *response){
                if([[response valueForKey:@"status"] boolValue]){
                    NSMutableArray *linkArray = [[NSMutableArray alloc]init];
                    NSMutableDictionary *linkDict = [[NSMutableDictionary alloc] init];
                    if(isUrlPreviewShown){
                        [linkDict setValue:previewURL forKey:@"link"];
                        [linkDict setValue:_urlPreview.title.text forKey:@"link_title"];
                        [linkDict setValue:_urlPreview.siteDescription.text forKey:@"link_description"];
                        [linkDict setValue:_urlPreview.imageUrl forKey:@"link_image_url"];
                        [linkDict setValue:_urlPreview.siteName.text forKey:@"link_sitename"];
                        [linkArray addObject:linkDict];
                        [postInfo setValue:linkArray forKey:@"link_details"];
                    }
                    else {
                        [postInfo setValue:linkArray forKey:@"link_details"];
                    }
                    [postInfo setObject:content forKey:@"post_content"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    self.dimView.hidden = YES;
                    [self.spinnerView stopAnimating];
                    [[AlertMessage sharedInstance] showMessage:[response objectForKey:@"message"]];
                }
            } isShowLoader:NO];
            
        }
        
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@" "])
        [self checkForURL:_comment.text];
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView{
    if([_comment.text length] == 0 && !isUrlPreviewShown)
        firstPreview = YES;
}

- (void)designTheView {

    [_headerView setHeader:NSLocalizedString(@"", nil)];
    [_headerView.logo setHidden:YES];
    
    [Util createRoundedCorener:_editButton withCorner:3];
    
    self.dimView.hidden = YES;
    [self.spinnerView setLineWidth:2.0];
    [self.spinnerView setTintColor:UIColorFromHexCode(THEME_COLOR)];

    [_comment setTextContainerInset:UIEdgeInsetsMake(5, 0, 0, 35)];
    [_comment becomeFirstResponder];
    _urlPreviewHeight.constant = 0;
    [_urlPreview setHidden:YES];
    isUrlPreviewShown = NO;
    _urlPreview.delegate = self;
    firstPreview = YES;
    
    //Alert popup
    popupView = [[YesNoPopup alloc] init];
    popupView.delegate = self;
    [popupView setPopupHeader:NSLocalizedString(DISCARD, nil)];
    popupView.message.text = NSLocalizedString(DISCARD_POST, nil);
    [popupView.yesButton setTitle:NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [popupView.noButton setTitle:NSLocalizedString(@"No", nil) forState:UIControlStateNormal];
    
    yesNoPopup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];

}


-(void) askBackConfirm:(NSNotification *) data{
    //Check is there any changes made in post form
//    [_comment.text isEqualToString:[postInfo objectForKey:@"post_content"]]
    if ([_comment.text isEqualToString:[postInfo objectForKey:@"post_content"]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [yesNoPopup show];
    }
    [_comment resignFirstResponder];
}

//Discard the post
- (void)discardPost{
    [yesNoPopup dismiss:YES];
    if (task != nil) {
        [task cancel];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark YesNoPopDelegate
- (void)onYesClick{
    [self discardPost];
}

- (void)onNoClick{
    [yesNoPopup dismiss:YES];
}

-(void)checkForURL:(NSString*)string{
    if(!isUrlPreviewShown && firstPreview){
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [linkDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];
                previewURL = [url absoluteString];
                [_urlPreview loadWithUrl:[url absoluteString]];
                _urlPreviewHeight.constant = 70;
                isUrlPreviewShown = TRUE;
                [_urlPreview setHidden:NO];
//                [self setHeaderForCheckIn:NO];
                
                break;
            }
        }
    }
}
-(void)setUrlPreview{
    firstPreview = FALSE;
    [_inputParams setValue:previewURL forKey:@"link"];
    [_inputParams setValue:_urlPreview.title.text forKey:@"link_title"];
    [_inputParams setValue:_urlPreview.siteDescription.text forKey:@"link_description"];
    [_inputParams setValue:_urlPreview.imageUrl forKey:@"link_image_url"];
    [_inputParams setValue:_urlPreview.siteName.text forKey:@"link_sitename"];
}

-(void)hidePreview{
    if([_comment.text length] == 0)
        firstPreview = TRUE;
    _urlPreviewHeight.constant = 0;
    isUrlPreviewShown = FALSE;
    [_urlPreview setHidden:YES];
//    [self setHeaderForCheckIn:NO];
}

-(void)tappedClosePreview{
//    if([_comment.text length] == 0)
        firstPreview = YES;
    [_inputParams setValue:@"" forKey:@"link"];
    [_inputParams setValue:@"" forKey:@"link_title"];
    [_inputParams setValue:@"" forKey:@"link_description"];
    [_inputParams setValue:@"" forKey:@"link_image_url"];
    [_inputParams setValue:@"" forKey:@"link_sitename"];
    _urlPreviewHeight.constant = 0;
    isUrlPreviewShown = NO;
    [_urlPreview setHidden:YES];
//    [self setHeaderForCheckIn:NO];
}

@end
