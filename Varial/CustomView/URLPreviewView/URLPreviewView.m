//
//  URLPreviewView.m
//  URLPreview
//
//  Created by Apple on 09/08/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "URLPreviewView.h"
#import "Reachability.h"
#import "HTMLParser.h"
#import "AFNetworking.h"
#import "Util.h"
@implementation URLPreviewView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}
- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"URLPreviewView" owner:self options:nil];
    self.mainView.frame = self.bounds;
    [self addSubview:self.mainView];
    [_loaderView setHidden:YES];
    self.title.text = nil;
    self.siteDescription.text = nil;
    self.siteName.text = nil;
    self.imageView.image = nil;
    self.linkURL = nil;
    self.imageUrl = nil;
    [_closeButton setHidden:YES];
    
}

//Fetch content of specified URL
-(void)loadWithUrl:(NSString *)URLString{
    
    [self resetViews];
    [self hideViewNetworkView:YES imageView:YES titleView:YES siteNameView:YES descriptionView:YES];
    //Check network status
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    [_networkStatus setText:NSLocalizedString(NO_INTERNET_CONNECTION, nil)];
    
    //Check its a mobile site url
    NSRange rOriginal = [URLString rangeOfString: @"m."];
    if (NSNotFound != rOriginal.location) {
        URLString = [URLString
                    stringByReplacingCharactersInRange: rOriginal
                    withString:                         @"www."];
    }
    
    if(remoteHostStatus != NotReachable)
    {
        __block  NSString *htmlCode;
        [self stopLoader];
        [self startLoaderWithColor:UIColorFromHexCode(THEME_COLOR)];
        
        //Retrive URL Content
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString ]];
        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
        
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error == nil) {
                
                
                //Parse response to string
                htmlCode = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"html code : %@", htmlCode);

                [self stopLoader];
                
                //Parse string to html
                HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlCode error:nil];
                
                //Retrive nodes from head tag
                HTMLNode *bodyNode = [parser head];
                
                //Filter meta nodes from html
                NSArray *inputNodes = [bodyNode findChildTags:@"meta"];
                
                //Set site name
                _siteName.text =[[[NSURL URLWithString:URLString] host] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                self.linkURL = URLString;

                for (HTMLNode *inputNode in inputNodes)
                {
                    if ([[inputNode getAttributeNamed:@"property"] isEqualToString:@"og:title"])
                    {
                        _title.text = [[inputNode getAttributeNamed:@"content"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if ([_title.text length] != 0)
                            _containsTitle = TRUE;
                    }
     
                    if ([[inputNode getAttributeNamed:@"property"] isEqualToString:@"og:site_name"] && [_siteName.text isEqualToString:@""])
                    {
                        _siteName.text = [[inputNode getAttributeNamed:@"content"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if ([_siteName.text length] != 0)
                            _containsSiteName = TRUE;
                    }
                    if ([[inputNode getAttributeNamed:@"property"] isEqualToString:@"og:description"])
                    {
                        NSString *description = [[inputNode getAttributeNamed:@"content"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if([description length] != 0){
                            _siteDescription.text = description ;
                            if ([description length] != 0)
                                _containsDescription = TRUE;
                        }
                    }
                    if ([[inputNode getAttributeNamed:@"property"] isEqualToString:@"og:image"])
                    {
                        _imageUrl = [NSString stringWithFormat:@"%@",[inputNode getAttributeNamed:@"content"]];
                        _imageUrl = [_imageUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        [self.imageView setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:nil];
                        if ([_imageUrl length] != 0)
                            _containsImage = TRUE;
                    }
                    if ([[inputNode getAttributeNamed:@"name"] isEqualToString:@"description"])
                    {
                        if([_siteDescription.text length] == 0){
                            NSString *description = [[inputNode getAttributeNamed:@"content"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            _siteDescription.text = description ;
                            if ([description length] != 0)
                                _containsDescription = TRUE;
                        }
                    }
                }
                
                if(!_containsTitle){
                    //Filter meta nodes from html
                    NSArray *titleNodes = [bodyNode findChildTags:@"title"];
                    if ([titleNodes count] > 0) {
                        HTMLNode *titleNode = titleNodes[0];
                        _title.text = [[titleNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    };
                }
                
                if(!_containsDescription)
                    _descriptionHeight.constant = 0;
                else
                    _descriptionHeight.constant = 18;

                if(!_containsImage)
                    self.imageViewWidth.constant = 0;
                else
                    self.imageViewWidth.constant = 65;
                
                
                if([self containsData])
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowURLPreview" object:nil];
                
                [self hideViewNetworkView:YES imageView:NO titleView:NO siteNameView:NO descriptionView:NO];
                [_closeButton setHidden:NO];
                _closeButtonWidth.constant = 25;
                [self stopLoader];
                
            }
            else{
                NSLog(@"Error: %@", error);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HideURLPreview" object:nil];
                [self hideViewNetworkView:YES imageView:YES titleView:YES siteNameView:YES descriptionView:YES];
                [self stopLoader];
            }
        }];
        [dataTask resume];
    }
    else
    {
        [self hideViewNetworkView:NO imageView:YES titleView:YES siteNameView:YES descriptionView:YES];
        [self stopLoader];
    }
}

-(void)loadWithSiteData:(NSString*)url title:(NSString*)title description:(NSString*)description siteName:(NSString*)name imageUrl:(NSString*)imageUrl
{
    [self resetViews];
    [self hideViewNetworkView:YES imageView:NO titleView:NO siteNameView:NO descriptionView:NO];
    self.title.text = title;
    self.siteDescription.text = description;
    self.siteName.text = name;
    self.linkURL = url;
    [_closeButton setHidden:YES];
    _closeButtonWidth.constant = 0;
    
    if(![imageUrl isEqualToString:@""]){
        self.imageViewWidth.constant = 65;
        [self.imageView setImageWithURL:[NSURL URLWithString: imageUrl] placeholderImage:nil];
    }
    else{
        self.imageViewWidth.constant = 0;
    }
    
    if([description isEqualToString:@""])
        _descriptionHeight.constant = 0;
    else
        _descriptionHeight.constant = 18;
}

-(BOOL)containsData{
    if(_title.text !=nil || _siteDescription.text != nil || _siteName.text != nil || _imageView.image != nil)
        return TRUE;
    return FALSE;
}
//Hide views
-(void)hideViewNetworkView:(BOOL)network imageView:(BOOL)image titleView:(BOOL)title siteNameView:(BOOL)siteName descriptionView:(BOOL)description
{
    _networkStatus.hidden = network;
    _imageView.hidden = image;
    _title.hidden = title;
    _siteName.hidden = siteName;
    _siteDescription.hidden = description;
}

//Show loading indicator
-(void)startLoaderWithColor:(UIColor*)color{
    [_loaderView setHidden:NO];
     activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate tintColor:color size:20.0f];
    activityIndicatorView.frame = _loaderView.bounds;
    [_loaderView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
}

//Hide loading indicator
-(void)stopLoader{
    [_loaderView setHidden:YES];
    [activityIndicatorView removeFromSuperview];
    [[_loaderView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [activityIndicatorView stopAnimating];
}

-(void)resetViews{
    _containsImage = _containsTitle = _containsSiteName = _containsDescription = _containsImage = FALSE;
    _imageView.image = nil;
    _title.text = @"";
    _siteName.text = @"";
    _siteDescription.text = @"";
    _imageUrl = @"";
    _linkURL = @"";
}
- (IBAction)closeView:(id)sender {
    [self.delegate tappedClosePreview];
}

- (IBAction)tappedOverLay:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.linkURL]];
}

@end
