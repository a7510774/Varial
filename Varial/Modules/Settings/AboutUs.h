//
//  AboutUs.h
//  Varial
//
//  Created by vis-1674 on 04/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateVersion.h"
#import "Util.h"
#import "Config.h"
#import "KLCPopup.h"
#import "HeaderView.h"
@interface AboutUs : UIViewController<UpdateVersionDelegate>
{
    UpdateVersion *updateVersion;
}
@property (nonatomic, retain) KLCPopup *updateVersionPopUp;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildLabel;

@end
