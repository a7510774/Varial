//
//  InviteContactTableViewCell.h
//  Varial
//
//  Created by Leo Chelliah on 07/01/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *gContainerView;
@property (weak, nonatomic) IBOutlet UILabel *gLblName;
@property (weak, nonatomic) IBOutlet UIButton *gBtnInviteContact;

@end
