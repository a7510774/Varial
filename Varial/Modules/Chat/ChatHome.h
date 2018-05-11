//
//  ChatHome.h
//  ChatApplication
//
//  Created by Shanmuga priya on 5/9/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "KLCPopup.h"
#import "XMPPServer.h"
#import "Menu.h"
#import "TTTAttributedLabel.h"

@interface ChatHome : UIViewController<UIGestureRecognizerDelegate,MenuDelegate,TTTAttributedLabelDelegate>
{
    NSMutableArray *menuArray,*conversations,*msgArray;
    Menu *menu;
    KLCPopup *chatMenuPopup,*menuPopup;
    KLCPopupLayout layout;
    UIView *view;
    NSString *queryString;
    int unreadCount;
    NSString *mediaBase;
    int playerType;
    int minimumPoints;

}

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *label;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
- (IBAction)tappedMenu:(id)sender;
-(void)getConversations;
@end

