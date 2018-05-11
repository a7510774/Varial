//
//  ChatNotification.m
//  Tagging
//
//  Created by Velan Info Services on 2016-07-13.
//  Copyright © 2016 Velan Info Services. All rights reserved.
//

#import "ChatNotification.h"
#import "UIImageView+AFNetworking.h"
#import "Config.h"
#import "Util.h"
#import "FriendsChat.h"

@interface ChatNotification ()

@end

@implementation ChatNotification

+ (id) sharedInstance{
    static ChatNotification *chatNotification = nil;
    @synchronized(self) {
        if (chatNotification == nil) {
            CGSize size = [Util getWindowSize];
            chatNotification = [[self alloc] initWithFrame:CGRectMake(0, 70, size.width, 70)];
        }
    }
    return chatNotification;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self loadView];
    }
    //Set the constraints for view
    [self setConstraints];
    return self;
}


//Load XIB file
- (void)loadView {
    
    [[NSBundle mainBundle] loadNibNamed:@"ChatNotification" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    CGRect frame = self.mainView.layer.frame;
    frame.origin.y =  frame.size.height * -2;
    
    _profileImage.layer.cornerRadius = _profileImage.frame.size.width / 2;
    _profileImage.layer.masksToBounds = YES;
    [_profileImage.layer setBorderColor: UIColorFromHexCode(THEME_COLOR).CGColor];
    [_profileImage.layer setBorderWidth:1.0f];
    
    self.mainView.layer.frame = frame;
    [self addSubview:self.mainView];
    
    [_clickView addTarget:self action:@selector(openChatWindow:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setConstraints{
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (_subView);
    
    NSArray *constraintsArray= [NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|-[_subView]-|"
                                options:NSLayoutFormatAlignAllBaseline metrics:nil
                                views:viewsDictionary];
    [self.mainView addConstraints:constraintsArray];
 
    
    constraintsArray= [NSLayoutConstraint
                       constraintsWithVisualFormat:@"V:|-[_subView(50)]"
                       options:NSLayoutFormatAlignAllBaseline metrics:nil
                       views:viewsDictionary];
    [self.mainView addConstraints:constraintsArray];
    
}


- (void) showNotification :(NSString *) imageUrl withTitle:(NSString *)title withSubtitle:(NSString *)subTitle{
    
    _header.text = title;
    _subHeader.text = subTitle;
    [_profileImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER]];
    _message = nil;
       
    //Append the view in window
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self.mainView];
            [window bringSubviewToFront:self.mainView];
            //break;
        }
    }
    
    [self.mainView.layer removeAllAnimations];
    
    //Show
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //Show
        CGRect frame = self.mainView.layer.frame;
        
        if (frame.origin.y !=  0) {
            frame.origin.y =  0;
            self.mainView.layer.frame = frame;
        }
        
    } completion:^(BOOL finished) {
        
    }];
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(closeAnimation) userInfo:nil repeats:NO];
}

-(void)closeAnimation{
    [timer invalidate];
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        //Hide
        CGRect frame = self.mainView.layer.frame;
        frame.origin.y =  -500;
        self.mainView.layer.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) setMessageAction:(XMPPMessage *)message{
    
    _message = message;
    
}

- (IBAction)openChatWindow:(id)sender {
    
    if (_message != nil) {
        
        //Read required information from message stanza
        NSXMLElement *userData = [_message elementForName:@"userdata"];
        NSString *name = [_message isSingleChatMessage] ? [[userData elementForName:@"senderName"] stringValue] : [[userData elementForName:@"receiverName"] stringValue];
        NSString *image = [_message isSingleChatMessage] ? [[userData elementForName:@"senderImage"] stringValue] : [[userData elementForName:@"receiverImage"] stringValue];
        NSString *jabberId = [_message isSingleChatMessage] ? [[userData elementForName:@"from"] stringValue] : [[userData elementForName:@"to"] stringValue];
        NSString *messageType = [_message attributeStringValueForName:@"type"];
        
        //Apply in friends chat window
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        FriendsChat *friends = [storyboard instantiateViewControllerWithIdentifier:@"FriendsChat"];
        friends.receiverID = jabberId;
        friends.receiverName = name;
        friends.receiverImage = image;
        if ([messageType isEqualToString:@"chat"]) {
            friends.isSingleChat = @"TRUE";
        }
        else
        {
            friends.isSingleChat = @"FALSE";
            friends.receiverID = [[userData elementForName:@"to"] stringValue];
        }
        
        //Push to navigation controller
        UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        [navigation pushViewController:friends animated:YES];
    }
}




@end
