//
//  EditPostViewController.h
//  Varial
//
//  Created by Leif Ashby on 7/16/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "Util.h"
#import "Config.h"
#import "URLPreviewView.h"


@interface EditPostViewController : UIViewController<UITextViewDelegate, HeaderViewDelegate, URLPreviewViewDelegate, YesNoPopDelegate>
{
    BOOL isUrlPreviewShown,firstPreview,isComposingDone,hasCheckin;
    KLCPopupLayout layout;
    KLCPopup *yesNoPopup;
    YesNoPopup *popupView;
    NSString *previewURL;
    int mediaCount;
    NSMutableDictionary *postInfo;
    NSURLSessionUploadTask *task;
    
}
@property (strong)  NSMutableDictionary  *inputParams;

@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet URLPreviewView *urlPreview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewHeight;
@property (weak, nonatomic) IBOutlet UIView *dimView;
@property (weak, nonatomic) IBOutlet LLARingSpinnerView *spinnerView;

- (void)setPostInfo:(NSDictionary *)postInfo;

@end
