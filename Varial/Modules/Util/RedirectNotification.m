//
//  RedirectNotification.m
//  Varial
//
//  Created by jagan on 18/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "RedirectNotification.h"
#import "PostDetails.h"
#import "LeaderBoard.h"
#import "TeamViewController.h"
#import "NonMemberTeamViewController.h"
#import "ShoppingHome.h"
#import "BuzzardRunPostDetails.h"
#import "BuzzardRunDetails.h"
#import "Comments.h"
#import "BuzzardRunComments.h"
#import "ShopDetails.h"
#import "ClubPromotionsDetails.h"
#import "ChatHome.h"
#import "FriendsChat.h"

@implementation RedirectNotification


//register Notification
+ (id) sharedInstance{
    
    static RedirectNotification *notification = nil;
    @synchronized(self) {
        if(notification == nil){
            notification = [[RedirectNotification alloc] init];
            [notification intitaliseObjects];
        }
    }
    return notification;    
}

- (void)intitaliseObjects{
    storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
}


//Redirect general notification to repective screens
- (void)redirectGeneralNotificationTo:(int)index withObject:(NSDictionary *)information{
   
    navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;    
    
    //Check user in navigation mode
    if ([navigation isKindOfClass:[UINavigationController class]]) {
        
        UIViewController *currentView = [[navigation viewControllers] lastObject];
        
        switch (index) {
            case 1:{ //Leader board
                if (![currentView isKindOfClass:[LeaderBoard class]]) {
                       BOOL canShowLeaderboard = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_show_leaderboard"];
                    if (canShowLeaderboard) {
                        LeaderBoard *leaderBoard = [storyBoard instantiateViewControllerWithIdentifier:@"LeaderBoard"];
                        [navigation pushViewController:leaderBoard animated:YES];
                    }
                    else
                    {
                        MyProfile *profile = [storyBoard instantiateViewControllerWithIdentifier:@"MyProfile"];
                        [navigation pushViewController:profile animated:YES];
                    }                    
                }
                break;
            }
            case 2:{ //Post Like
                if (![currentView isKindOfClass:[PostDetails class]]) {
                    PostDetails *postDetails = [storyBoard instantiateViewControllerWithIdentifier:@"PostDetails"];
                    postDetails.isFromNotification = @"YES";
                    postDetails.postId = [information valueForKey:@"redirection_id"];
                    [navigation pushViewController:postDetails animated:YES];
                }
                break;
            }
            case 3:{ //Media Like
                if (![currentView isKindOfClass:[PostDetails class]]) {
                    PostDetails *postDetails = [storyBoard instantiateViewControllerWithIdentifier:@"PostDetails"];
                    postDetails.isFromNotification = @"YES";
                    postDetails.postId = [information valueForKey:@"redirection_id"];
                    [navigation pushViewController:postDetails animated:YES];
                }
                break;
            }
            case 4:{ //Comment for post
                if (![currentView isKindOfClass:[PostDetails class]]) {
                    PostDetails *postDetails = [storyBoard instantiateViewControllerWithIdentifier:@"PostDetails"];
                    postDetails.postId = [information valueForKey:@"redirection_id"];
                    postDetails.isFromNotification = @"YES";
                    
                    Comments *comments = [storyBoard instantiateViewControllerWithIdentifier:@"Comments"];
                    comments.postId = [information valueForKey:@"redirection_id"];
                   
                    [self navigateThrough:postDetails to:comments];
                }
                break;
            }
            case 5:{ //Comment for media
                if (![currentView isKindOfClass:[PostDetails class]]) {
                    PostDetails *postDetails = [storyBoard instantiateViewControllerWithIdentifier:@"PostDetails"];
                    postDetails.postId = [information valueForKey:@"redirection_id"];
                    postDetails.isFromNotification = @"YES";
                    
                    Comments *comments = [storyBoard instantiateViewControllerWithIdentifier:@"Comments"];
                    comments.mediaId = [information valueForKey:@"media_id"];
                    comments.postId = [information valueForKey:@"redirection_id"];
                   
                    [self navigateThrough:postDetails to:comments];
                }
                break;
            }
            case 6:{ //Team request
                int type = [[information valueForKey:@"player_team_status"] intValue];
                if (type == 4) {
                    if (![currentView isKindOfClass:[NonMemberTeamViewController class]]) {
                        NonMemberTeamViewController *nonMember = [storyBoard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
                        nonMember.teamId = [information valueForKey:@"redirection_id"];
                        [navigation pushViewController:nonMember animated:YES];
                    }
                }
                else{
                    if (![currentView isKindOfClass:[TeamViewController class]]) {
                        TeamViewController *teamView = [storyBoard instantiateViewControllerWithIdentifier:@"TeamViewController"];
                        teamView.teamId = [information valueForKey:@"redirection_id"];
                        [navigation pushViewController:teamView animated:YES];
                    }
                }
                break;
            }
            case 7:{ //Shopowner approved the registration -> Buzzard Run Details
                if (![currentView isKindOfClass:[BuzzardRunDetails class]]) {
                    BuzzardRunDetails *buzzardRunDetails = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunDetails"];
                    buzzardRunDetails.buzzardRunId = [information valueForKey:@"redirection_id"];
                    [navigation pushViewController:buzzardRunDetails animated:YES];
                }
                break;
            }
            case 8:{ //Shopowner approved the event -> Buzzard Run Details
                if (![currentView isKindOfClass:[BuzzardRunDetails class]]) {
                    BuzzardRunDetails *buzzardRunDetails = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunDetails"];
                    buzzardRunDetails.buzzardRunId = [information valueForKey:@"redirection_id"];
                    [navigation pushViewController:buzzardRunDetails animated:YES];
                }
                break;
            }
            case 9:{ //Shopowner approved the Buzzard Run -> Buzzard Run Details
                if (![currentView isKindOfClass:[BuzzardRunDetails class]]) {
                    BuzzardRunDetails *buzzardRunDetails = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunDetails"];
                    buzzardRunDetails.buzzardRunId = [information valueForKey:@"redirection_id"];
                    [navigation pushViewController:buzzardRunDetails animated:YES];
                }
                break;
            }
            case 10:{ //Shopowner like the post  -> Buzzard Run Event Post Details
                if (![currentView isKindOfClass:[BuzzardRunPostDetails class]]) {
                    BuzzardRunPostDetails *buzzardRunPostDetails = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunPostDetails"];
                    buzzardRunPostDetails.postId = [information valueForKey:@"redirection_id"];
                    buzzardRunPostDetails.isFromNotification = @"YES";
                    [navigation pushViewController:buzzardRunPostDetails animated:YES];
                }
                break;
            }
            case 11:{ //Shopowner like the media -> Buzzard Run Event Post Details
                if (![currentView isKindOfClass:[BuzzardRunPostDetails class]]) {
                    BuzzardRunPostDetails *buzzardRunPostDetails = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunPostDetails"];
                    buzzardRunPostDetails.postId = [information valueForKey:@"redirection_id"];
                    buzzardRunPostDetails.isFromNotification = @"YES";
                    [navigation pushViewController:buzzardRunPostDetails animated:YES];
                }
                break;
            }
            case 12:{ //Ecommerce order Purchasing
                if (![currentView isKindOfClass:[ShoppingHome class]]) {
                    ShoppingHome *shoppingHome = [storyBoard instantiateViewControllerWithIdentifier:@"ShoppingHome"];
                    shoppingHome.isOrderPurchasingUrl = [information objectForKey:@"redirection_link"];
                    [navigation pushViewController:shoppingHome animated:YES];
                }
                break;
            }
            case 13:{ //Shopowner comment in the media -> Buzzard Run Event Post Media Comment Details
                if (![currentView isKindOfClass:[BuzzardRunComments class]]) {
                    
                    BuzzardRunPostDetails *buzzardRunPostDetails = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunPostDetails"];
                    buzzardRunPostDetails.postId = [information valueForKey:@"redirection_id"];
                    buzzardRunPostDetails.isFromNotification = @"YES";

                    
                    BuzzardRunComments *comments = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunComments"];
                    comments.mediaId = [information valueForKey:@"media_id"];
                    comments.postId = [information valueForKey:@"redirection_id"];
                    comments.buzzardRunId = [information valueForKey:@"buzzard_run_id"];
                    comments.buzzardRunEventId = [information valueForKey:@"buzzard_run_event_id"];
                    
                    [self navigateThrough:buzzardRunPostDetails to:comments];
                }
                break;
            }
            case 14:{ //Shopowner comment in the post -> Buzzard Run Event Post Comment Details
                if (![currentView isKindOfClass:[BuzzardRunComments class]]) {
                    
                    BuzzardRunPostDetails *buzzardRunPostDetails = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunPostDetails"];
                    buzzardRunPostDetails.postId = [information valueForKey:@"redirection_id"];
                    buzzardRunPostDetails.isFromNotification = @"YES";
                    
                    BuzzardRunComments *comments = [storyBoard instantiateViewControllerWithIdentifier:@"BuzzardRunComments"];
                    comments.postId = [information valueForKey:@"redirection_id"];
                    
                    //[self navigateThrough:buzzardRunPostDetails to:comments];
                    [navigation pushViewController:buzzardRunPostDetails animated:NO];
                    [navigation pushViewController:comments animated:YES];
                    
                    
                }
                break;
            }
            case 15:{ //Shop owner sends the offer notification
                if (![currentView isKindOfClass:[ShopDetails class]]) {
                    ShopDetails *shopDetails = [storyBoard instantiateViewControllerWithIdentifier:@"ShopDetails"];
                    shopDetails.offerId = [information valueForKey:@"redirection_id"];
                    [navigation pushViewController:shopDetails animated:YES];
                }
                break;
            }
            case 16:{ //Club Promotion approved notification
                if (![currentView isKindOfClass:[ClubPromotionsDetails class]]) {
                    ClubPromotionsDetails *clubPromotionsDetails = [storyBoard instantiateViewControllerWithIdentifier:@"ClubPromotionsDetails"];
                    clubPromotionsDetails.promotionId = [information valueForKey:@"redirection_id"];
                    [navigation pushViewController:clubPromotionsDetails animated:YES];
                }
                break;
            }
            case 17:{ //User become a friend
                if (![currentView isKindOfClass:[FriendProfile class]]) {
                    FriendProfile *friendProfile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
                    friendProfile.friendId = [information valueForKey:@"redirection_id"];
                    friendProfile.friendName = [information valueForKey:@"friend_name"];
                    [navigation pushViewController:friendProfile animated:YES];
                }
                break;
            }

            default:
                break;
        }
    }
}

//Redirect friends notification
- (void)redirectFriendsNotification:(NSMutableDictionary *)information{
    
    navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    //Check user in navigation mode
    if ([navigation isKindOfClass:[UINavigationController class]]) {
        
        //for friends notification
        FriendProfile *friendProfile = [storyBoard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        NSDictionary *data = [information objectForKey:@"data"];
        friendProfile.friendId = [data valueForKey:@"friend_id"];
        friendProfile.friendName = [data valueForKey:@"friend_name"];
        UIViewController *currentView = [[navigation viewControllers] lastObject];
        if ([currentView isKindOfClass:[FriendProfile class]]) {
            
            FriendProfile *friend = (FriendProfile *) currentView;
            
            if (![friend.friendId isEqualToString:[data valueForKey:@"friend_id"]]) {
                [navigation pushViewController:friendProfile animated:YES];
            }
        }
        else{
            [navigation pushViewController:friendProfile animated:YES];
        }
        
    }
}

-(void)navigateThrough:(UIViewController*)throughView to:(UIViewController*)toView{
     navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
    UIViewController *currentView = [[navigation viewControllers] lastObject];
    [navigation setViewControllers:@[currentView,throughView,toView]];
    [UIApplication sharedApplication].delegate.window.rootViewController = navigation;
}

//Redirect chat notification
- (void)redirectChatNotification:(NSMutableDictionary *)information{
    
    navigation = (UINavigationController *) [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    //Check user in navigation mode
    if ([navigation isKindOfClass:[UINavigationController class]] && CHAT_ENABLED) {        
        
        UIViewController *currentView = [[navigation viewControllers] lastObject];
        if (![currentView isKindOfClass:[ChatHome class]]) {
            //For chat notification
            ChatHome *chatHome = [storyBoard instantiateViewControllerWithIdentifier:@"ChatHome"];
            [navigation pushViewController:chatHome animated:YES];
        }
        
        NSDictionary *data = [information objectForKey:@"data"];
        FriendsChat *friends = [storyBoard instantiateViewControllerWithIdentifier:@"FriendsChat"];
        if ([[data valueForKey:@"type"] intValue] == 1) {
            friends.isSingleChat = @"TRUE";
            friends.receiverID = [data valueForKey:@"from"];
            friends.receiverName = [data valueForKey:@"name"];
            friends.receiverImage = [data valueForKey:@"profile_image"];
        }
        else
        {
            friends.isSingleChat = @"FALSE";
            friends.receiverID = [data valueForKey:@"team_jabber_id"];
            friends.receiverName = [data valueForKey:@"team_name"];
            friends.receiverImage = [data valueForKey:@"team_profile_image"];
        }
        [navigation pushViewController:friends animated:YES];
    }
}



@end
