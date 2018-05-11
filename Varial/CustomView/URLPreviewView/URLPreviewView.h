//
//  URLPreviewView.h
//  URLPreview
//
//  Created by Apple on 09/08/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"

@protocol URLPreviewViewDelegate
-(void)tappedClosePreview;
@end

@interface URLPreviewView : UIView
{
    DGActivityIndicatorView *activityIndicatorView;
}
@property (assign) id<URLPreviewViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *networkStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *siteName;
@property (weak, nonatomic) IBOutlet UILabel *siteDescription;
@property (weak, nonatomic) IBOutlet UIView *loaderView;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonWidth;

@property (weak, nonatomic) NSString *imageUrl,*linkURL;
@property (nonatomic)BOOL containsTitle,containsImage,containsDescription,containsSiteName;

- (IBAction)closeView:(id)sender;
- (IBAction)tappedOverLay:(id)sender;

-(BOOL)containsData;
-(void)loadWithUrl:(NSString *)URL;
-(void)loadWithSiteData:(NSString*)url title:(NSString*)title description:(NSString*)description siteName:(NSString*)name imageUrl:(NSString*)imageUrl;

@end
