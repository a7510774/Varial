//
//  HeaderView.m
//  Varial
//
//  Created by jagan on 25/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "HeaderView.h"
#import "AlertMessage.h"
#import "NetworkAlert.h"
#import "ChatHome.h"
#import "FriendsChat.h"
#import "MediaGallery.h"
#import "MediaComposing.h"
#import "ChatDBManager.h"
#import "MyFriends.h"
#import "ViewController.h"
#import <MIBadgeButton/MIBadgeButton.h>

@implementation HeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        _restrictBack = false;
        _restrictChat = false;
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
//    self.chatBadge.layer.cornerRadius = self.chatBadge.frame.size.width / 2;
//    self.chatBadge.layer.masksToBounds = YES;
//    self.chatIcon.hidden = CHAT_ENABLED ? NO : YES;
//    [self.chatBadge.layer setBorderColor: UIColorFromHexCode(THEME_COLOR).CGColor];
//    [self.chatBadge.layer setBorderWidth:1.0f];
//    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    self.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.view];
    [Util createRoundedCorener:_btnSearchIcon withCorner:10.0];
//    [self.view.layer setBorderColor:UIColorFromHexCode(THEME_COLOR).CGColor];
//    [self.view.layer setBorderWidth:1.0];
    
//    self.feedType.hidden = NO;
}


- (void)setHeader:(NSString*)title{
    NSString *language = [Util getFromDefaults:@"language"];
    if([language isEqualToString:@"en-US"])
    {
        _title.text = [title uppercaseString];
        [_title setFont: [_title.font fontWithSize:16]];
    }
    else{
        _title.text = title;
    }
}

- (IBAction)openChat:(id)sender {
    
    if(!_restrictChat)
    {
        UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
        
        NSLog(@"class : %@",[[navigation viewControllers] lastObject]);
        NSString *className = NSStringFromClass([[[navigation viewControllers] lastObject] class]);
        
        if ([navigation isKindOfClass:[UINavigationController class]]) {
            UIViewController *viewController = [[navigation viewControllers] lastObject];
            
            if ([viewController isKindOfClass:[FriendsChat class]]) {
                [navigation popViewControllerAnimated:YES];
            }
            else if ([viewController isKindOfClass:[MediaComposing class]]) {
                [navigation popViewControllerAnimated:YES];
                [navigation popViewControllerAnimated:NO];
            }
            else if (![viewController isKindOfClass:[ChatHome class]]){
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableArray *friendsList = [[defaults objectForKey:@"friends_jabber_ids"] mutableCopy];
                
                //Check chat history is present
                if ([[ChatDBManager sharedInstance] getChatHistoryCount] > 0) {
                    ChatHome *chatHome = [storyBoard instantiateViewControllerWithIdentifier:@"ChatHome"];
                    if([className isEqualToString:@"CreatePostViewController"])
                    {
                        ViewController *viewController =[[navigation viewControllers] firstObject];
                        [navigation setViewControllers:@[viewController,chatHome]];
                        [UIApplication sharedApplication].delegate.window.rootViewController = navigation;
                    }
                    else
                    {
                        [navigation pushViewController:chatHome animated:YES];
                    }
                }
                else if(friendsList != nil && [friendsList count] > 0){
                    ChatHome *chatHome = [storyBoard instantiateViewControllerWithIdentifier:@"ChatHome"];
                    [navigation pushViewController:chatHome animated:YES];
                    MyFriends *myFriends = [storyBoard instantiateViewControllerWithIdentifier:@"MyFriends"];
                    myFriends.fromChat = @"TRUE";
                    [navigation pushViewController:myFriends animated:YES];
                }
                else{
                    ChatHome *chatHome = [storyBoard instantiateViewControllerWithIdentifier:@"ChatHome"];
                    [navigation pushViewController:chatHome animated:YES];
                }
                //Forward *forward = [[Forward alloc]initWithNibName:@"Forward" bundle:nil];
                //[navigation pushViewController:forward animated:YES];
            }
        }
        
    }
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DiscardPost" object:self];
    }
}

- (IBAction)back:(id)sender {
    
    if ([delegate respondsToSelector:@selector(backPressed)]) {
        [delegate backPressed];
    }
    // Hack for easier dismissing on views that aren't implemented correctly
    else if (!_restrictBack && delegate) {
        UIViewController *viewController = ((UIViewController *)delegate);
        if ([viewController isKindOfClass:[UIViewController class]] && viewController.navigationController) {
            [viewController.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (!_restrictBack) {
        UINavigationController *navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
        if ([navigation isKindOfClass:[UINavigationController class]]) {
            [navigation popViewControllerAnimated:YES];            
        }
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackPressed" object:nil];
    }
}

- (void)setBackHidden:(BOOL)hidden {
    _back.hidden = hidden;
    if (!hidden) {
        [self setFeedTypeHidden:YES];
    }
}

- (IBAction)onFeedSelectorTouch:(id)sender {
    [_feedTypeButton setHighlighted:YES];
    [_feedTypeArrow setHighlighted:YES];
}
- (IBAction)onFeedSelectorTouchCancel:(id)sender {
    [_feedTypeButton setHighlighted:NO];
    [_feedTypeArrow setHighlighted:NO];
}
- (IBAction)openFeedSelector:(id)sender {
    [_feedTypeButton setHighlighted:NO];
    [_feedTypeArrow setHighlighted:NO];
//    if (self.delegate && [:])
    if ([delegate respondsToSelector:@selector(feedTypeSelectorShouldOpen:)]) {
        [delegate feedTypeSelectorShouldOpen:sender];
    }
}

- (void)setFeedTypeHidden:(BOOL)hidden {
    _feedTypeView.hidden = hidden;
}

- (void)setFeedType:(int)feedId {
    UIImage *image = [Util imageForFeed:feedId withType:@"title"];
    [_feedTypeButton setImage:image forState:UIControlStateNormal];
}

- (IBAction)optionPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(optionPressed)]) {
        [self.delegate optionPressed];
    }
}

- (IBAction)bookmarkBtnTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(bookmarkBtnTapped)]) {
        [self.delegate bookmarkBtnTapped];
    }
}

- (IBAction)searchIconTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(searchBtnTapped)]) {
        [self.delegate searchBtnTapped];
    }
}


- (void)setOptionHidden:(BOOL)hidden {
    _option.hidden = hidden;
}
- (void)setOptionImage:(UIImage *)image forState:(UIControlState)state {
    [_option setImage:image forState:state];
}
- (void)setNotificationBtnCount:(NSString*)count {
    
    if([count isEqualToString:@""] || [count isEqualToString:@"0"]) {
        
        count = @"0";
        
    }
    [_btnSearchIcon setHideWhenZero:YES];
    [_btnSearchIcon setBadgeString:count];
    [_btnSearchIcon setBadgeEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_btnSearchIcon setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_btnSearchIcon setBadgeBackgroundColor:[UIColor orangeColor]];
}


- (IBAction)clickLogo:(id)sender
{
//    NSString *getUrl;
//    if([[Util getFromDefaults:@"language"] isEqualToString:@"en-US"])
//    {
//        getUrl = @"https://www.varialskate.com/faq.php?lang_code=en-US";
//    }
//    else
//    {
//        getUrl  = @"https://www.varialskate.com/faq.php?lang_code=zh";
//    }
//    NSURL *url = [NSURL URLWithString:getUrl];
//    [[UIApplication sharedApplication] openURL:url];
}

- (void)setBookmarkHidden:(BOOL)hidden {
    _btnBookmark.hidden = hidden;
}

-(void)setSearchIconHidden:(BOOL)hidden{
    self.btnSearchIcon.hidden = hidden;
}
@end
