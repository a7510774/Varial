//
//  ShoppingHome.m
//  Varial
//
//  Created by jagan on 18/03/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ShoppingHome.h"
#import "IQUIView+IQKeyboardToolbar.h"
@interface ShoppingHome ()

@end

@implementation ShoppingHome
NSDictionary *language;
NSString *currentLang,*urlValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    language = @{@"zh":@"zh_CN",@"en-US":@"en_US"};
    currentLang = [Util getFromDefaults:@"language"];
        
    [self designTheView];
    [self createPopUpWindows];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveBack:) name:@"BackPressed" object:nil];
    
    //Show order page
    if (_isOrderPurchasingUrl != nil) {
        _isOrderPurchasingUrl = [NSString stringWithFormat:@"%@&lang_code=%@",_isOrderPurchasingUrl,[language valueForKey:currentLang]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_isOrderPurchasingUrl]]];
    }
    else{
        //if ecommerce_token not present
        if([Util getFromDefaults:@"ecommerce_token"] == nil){
            [self getEComAuthToken];
        }
        else{
            [self launchECom];
        }
    }
    
    layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutAboveCenter);
    
}

- (void) launchECom{
    //Launch the website
    //Check site is already loaded
    if([Util getFromDefaults:@"lastUrl"] == nil){
        [self appendParams:SHOPPING_LIVE];
    }
    else{
        [self appendParams:[Util getFromDefaults:@"lastUrl"]];
    }
    NSURL *url = [NSURL URLWithString:urlValue];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    NSLog(@"ECom url :%@",requestURL);
    [self.webView loadRequest:requestURL];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackPressed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ConfirmEmailNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) moveBack:(NSNotification *) data{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else{
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            if([[cookie domain] isEqualToString:@"shop.varialskate.com"]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) appendParams:(NSString *)url {
    urlValue = url;
    NSLog(@"AuthToken :%@",[Util getFromDefaults:@"ecommerce_token"]);
    if ([urlValue rangeOfString:@"auth_token"].location == NSNotFound) {
        urlValue = [NSString stringWithFormat:@"%@?auth_token=%@&lang_code=%@",urlValue,[Util getFromDefaults:@"ecommerce_token"],[language valueForKey:currentLang]];
    }
    
}

- (void)designTheView{
    [_headerView setHeader: NSLocalizedString(SHOPPING, nil)];
    _headerView.restrictBack = TRUE;
    _homeMenu.layer.cornerRadius = _homeMenu.frame.size.height / 2 ;
    _homeMenu.clipsToBounds = YES;
}

- (void) createPopUpWindows{
    networkAlert = [[NetworkAlert alloc]init];
    [networkAlert setDelegate:self];
    [networkAlert.button setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [networkAlert setNetworkHeader:NSLocalizedString(EMAIL_NOT_FOUND, nil)];
    networkAlert.subTitle.text = NSLocalizedString(SET_EMAIL,nil);

    KLCNetworkPopup = [KLCPopup popupWithContentView:networkAlert showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    emailPopup = [[SetEmailPopup alloc]init];
    [emailPopup.confirmPassword addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
    [emailPopup setDelegate:self];
    KLCSetEmail = [KLCPopup popupWithContentView:emailPopup showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    KLCSetEmail.didFinishShowingCompletion = ^{
        [emailPopup.emailID becomeFirstResponder];
    };
}

-(void)doneAction:(UIBarButtonItem*)barButton
{
    [self onSaveClick];
}

- (void)showEmailConfirmationPopup:(NSString *)message{
    emailConfirmation = [[NetworkAlert alloc] init];
    [emailConfirmation setNetworkHeader:NSLocalizedString(WAITING_FOR_CONFIRMATION, nil)];
    emailConfirmation.subTitle.text = message;
    [emailConfirmation.button setTitle:NSLocalizedString(@"Ok",nil) forState:UIControlStateNormal];
    emailConfirmation.delegate = self;
    
    emailConfirmationPopup = [KLCPopup popupWithContentView:emailConfirmation showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
}

-(void) emailConfirmed:(NSNotification *) data{
    NSMutableDictionary *notificationContent = [data.userInfo mutableCopy];
    [emailConfirmationPopup dismiss:YES];
    [[AlertMessage sharedInstance] showMessage:[[notificationContent objectForKey:@"data"] valueForKey:@"message"] withDuration:3];
    [_webView reload];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)getEComAuthToken{
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:GET_ECOM_AUTH_TOKEN withCallBack:^(NSDictionary * response)
     {
         if([[response valueForKey:@"status"] boolValue]){
             [Util setInDefaults:[response valueForKey:@"ecommerce_token"] withKey:@"ecommerce_token"];
             [self appendParams:SHOPPING_LIVE];
             [self launchECom];
         }
         else{
             [self.navigationController popViewControllerAnimated:YES];
         }
         
     } isShowLoader:YES];    

}

#pragma args - WebView delegates
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"Current Host :%@",SHOPPING_HOST);
    NSString *host = [request.URL host];
    if ([host isEqualToString:SHOPPING_HOST] ){
        if(navigationType == UIWebViewNavigationTypeLinkClicked) {
            NSString *currentURL = request.URL.absoluteString;
            NSLog(@"Current URL :%@",currentURL);
        }
        return YES;
    }
    return NO;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if(![[Util sharedInstance] getNetWorkStatus])
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
        [appDelegate.networkPopup show];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSLog(@"Status %ld",(long)[(NSHTTPURLResponse*)resp.response statusCode]);
    NSLog(@"Headers %@",[(NSHTTPURLResponse*)resp.response allHeaderFields]);
    
    //Check session has expired
    if([[webView stringByEvaluatingJavaScriptFromString:@"isSessionLogout();"] isEqualToString:@""])
    {
        [self appendParams:[webView.request.URL absoluteString]];
        NSURL *url = [NSURL URLWithString:urlValue];
        NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:requestURL];
    }
    
    
    if([[webView stringByEvaluatingJavaScriptFromString:@"isProductViewPage();"] boolValue])
    {
        [_headerView setHeader:[NSString stringWithFormat:@"%@",NSLocalizedString(PRODUCT_DETAILS, nil)]];

    }
    else
    {
        NSString  *title = [webView stringByEvaluatingJavaScriptFromString: @"document.title"];
        //document.body.innerHTML
        [_headerView setHeader: NSLocalizedString(title, nil)];
    }
    NSLog(@"Current Url %@",[webView.request.URL absoluteString]);
    if([[webView stringByEvaluatingJavaScriptFromString:@"isCheckoutPage();"] boolValue] || [[webView stringByEvaluatingJavaScriptFromString:@"isMultiShippingPage();"] boolValue])
    {
        if(![[webView stringByEvaluatingJavaScriptFromString:@"emailStatus();"] boolValue])
        {
            isSetEmailAlert=TRUE;
            [KLCNetworkPopup show];
        }
    }
    
    //Save loaded url in session
    [Util setInDefaults:[webView.request.URL absoluteString] withKey:@"lastUrl"];    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - NetworkAlert
-(void)onButtonClick{
    if(isSetEmailAlert)
    {
        [KLCNetworkPopup dismiss:YES];
        [KLCSetEmail showWithLayout:layout];
    }
    else{
        [emailConfirmationPopup dismiss:YES];
        /*
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:@"1" forKey:@"is_email"];
        
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:CANCEL_EMAIL withCallBack:^(NSDictionary * response){
            
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            
            if([[response valueForKey:@"status"] boolValue]){
                [emailConfirmationPopup dismiss:YES];
            }
            
        } isShowLoader:YES];
         */
        [_webView goBack];
    }
}

//------------------------------------> Set email  <----------------------------------------
#pragma mark - setEmailPopup
-(void)onSaveClick{
    [self emailActionRequest];
}
-(void)onCancelClick{
    [KLCSetEmail dismiss:YES];
    [self resetPopup];
    [_webView goBack];
}

-(void)emailActionRequest{
   
    if ([self setEmailValidation]) {
        
        //Build Input Parameters
        NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
        [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
        [inputParams setValue:emailPopup.emailID.text forKey:@"email"];
        [inputParams setValue:emailPopup.password.text forKey:@"password"];
        [inputParams setValue:emailPopup.confirmPassword.text forKey:@"confirm_password"];
        [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:SET_EMAIL_API withCallBack:^(NSDictionary * response){
            //success case
            if([[response valueForKey:@"status"] boolValue]){
                
                [KLCSetEmail dismiss:YES];
                isSetEmailAlert = FALSE;
                
                [self showEmailConfirmationPopup:[response valueForKey:@"message"]];
                [emailConfirmationPopup show];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfirmed:) name:@"ConfirmEmailNotification" object:nil];
                [emailPopup.confirmPassword resignFirstResponder];
            }
            else{
                [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
            }
            
        } isShowLoader:YES];
        [self resetPopup];
    }
    
}

//set Email validation
-(BOOL) setEmailValidation{
    [self resetSetEmailWindow];
    
    //Validate email
    if(![Util validateTextField:emailPopup.emailID withValueToDisplay:EMAIL withIsEmailType:TRUE withMinLength:EMAIL_MIN withMaxLength:EMAIL_MAX]){
        return FALSE;
    }
    //Validate password
    else if(![Util validatePasswordField:emailPopup.password withValueToDisplay:PASSWORD withMinLength:PASSWORD_MIN withMaxLength:PASSWORD_MAX]){
        return FALSE;
    }
    // Validation Password continue empty spaces
    if ([[emailPopup.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [Util showErrorMessage:emailPopup.confirmPassword withErrorMessage:NSLocalizedString(CONTINUE_WHITESPACES, nil)];
        
        return FALSE;
    }
    //Check confirm password is empty
    else if([emailPopup.confirmPassword.text length] == 0)
    {
        [Util showErrorMessage:emailPopup.confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_EMPTY, nil)];
        return FALSE;
    }
    //Validation to match password
    if(![emailPopup.confirmPassword.text isEqualToString:emailPopup.password.text]){
        
        //add border to validated fields
        [Util createBottomLine:emailPopup.password withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util createBottomLine:emailPopup.confirmPassword withColor:UIColorFromHexCode(THEME_COLOR)];
        [Util showErrorMessage:emailPopup.confirmPassword withErrorMessage:NSLocalizedString(CONFIRM_MISMATCH, nil)];
        return FALSE;
    }
    
    return YES;
}

-(void) resetSetEmailWindow{
    [Util createBottomLine:emailPopup.emailID withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:emailPopup.password withColor:UIColorFromHexCode(TEXT_BORDER)];
    [Util createBottomLine:emailPopup.confirmPassword withColor:UIColorFromHexCode(TEXT_BORDER)];
}

-(void)resetPopup{
    emailPopup.emailID.text=@"";
    emailPopup.password.text=@"";
    emailPopup.confirmPassword.text=@"";
}

//------------------------------------> Set email ends <----------------------------------------

- (IBAction)showHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
