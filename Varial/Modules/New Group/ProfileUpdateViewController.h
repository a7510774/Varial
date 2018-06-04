//
//  ProfileUpdateViewController.h
//  Varial
//
//  Created by Leo Chelliah on 07/02/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLCPopup.h"

@protocol senddataProtocol <NSObject>
-(void)sendDataToA;
//-(void)deleteProfileImageWithId:(NSInteger)index;
@end
@interface ProfileUpdateViewController : UIViewController{
    KLCPopup *editNamePopup, *editProfilePopup;
    KLCPopupLayout layout;
}
@property(nonatomic,assign)id delegate;
@property(nonatomic,strong) NSMutableArray *updateImages;
@end
