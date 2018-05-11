//
//  HeaderView.h
//  Varial
//
//  Created by jagan on 25/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MIBadgeButton/MIBadgeButton.h>

@protocol HeaderViewDelegate <NSObject>
@optional
- (void)feedTypeSelectorShouldOpen:(id)sender;
- (void)backPressed;
- (void)optionPressed;
- (void)bookmarkBtnTapped;
- (void)searchBtnTapped;

@end

@interface HeaderView : UIView
@property (nonatomic) BOOL restrictBack,restrictChat;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) id<HeaderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *feedTypeView;
@property (weak, nonatomic) IBOutlet UIButton *feedTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *feedTypeArrow;
@property (weak, nonatomic) IBOutlet UIButton *logo;
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *option;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *chatBadge;
@property (weak, nonatomic) IBOutlet UIButton *chatIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnBookmark;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnSearchIcon;

- (IBAction)clickLogo:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)openFeedSelector:(id)sender;
- (IBAction)openChat:(id)sender;
- (void)setHeader:(NSString*)title;
- (void)setBackHidden:(BOOL)hidden;
- (void)setFeedTypeHidden:(BOOL)hidden;
- (void)setFeedType:(int)feedId;
- (void)setOptionHidden:(BOOL)hidden;
- (void)setOptionImage:(UIImage *)image forState:(UIControlState)state;
- (void)setBookmarkHidden:(BOOL)hidden;
- (void)setSearchIconHidden:(BOOL)hidden;
- (void)setNotificationBtnCount:(NSString*)count;
@end
