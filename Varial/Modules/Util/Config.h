//
//  Config.h
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserMessages.h"

@interface Config : NSObject

#define SYSTEM_VERSION_GREATER_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define DEVICE_TYPE @"2"
#define SOCKET_ENABLE 0
#define CHAT_ENABLED 0

#define ALBUM_NAME @"Varial"
#define IMAGE_KEY @"$$z0$b^BPz%%$`2@0-5azJ*6^$$.image$$"
#define VIDEO_KEY @"$$ZoS7$5a!sXj85)z28703%*5$$.video$$"

// 1 == Dev  2 == Staging  3 == Live
#define ENVIRONMENT 3

#define LIVE_GOOGLE_KEY @"AIzaSyB5YN5OcJOKsUwzTauGK6H66AenlDuTJxs"
#define LIVE_BAIDU_KEY @"KqTyrAwBUwNWfMwET0RnAhoArbqCAgnb"
#define DEV_GOOGLE_KEY @"AIzaSyAvBWJMpXVZeSwiayXLLipb9bMgtrxhH6o"
#define DEV_BAIDU_KEY @"wMsocrsEGQ6H1iQVK6cj73G4"


//Image resize level
#define RESIZE_LEVEL_ONE 1920
#define RESIZE_LEVEL_TWO 2460

//Video resize level
#define MAX_VIDEO_RESOLUTION 720

#define THEME_COLOR 0xFF3824
#define DEFAULT_TEXT_COLOR 0x111111
#define BG_TEXT_COLOR 0x333333
#define TEXT_BORDER 0x9e9d9d
#define GREY_BORDER 0xB8B8BB
#define ANIMATION_HEIGHT 60
#define GREY_TEXT 0x848489
#define OUT_BUBBLE 0x787878
 

//Location
#define DEFAULT_LONGITUDE 118.554384
#define DEFAULT_LATITUDE 29.9170977

//Image dimensions
#define PROFILE_IMAGE 320

//Field Validamobile123$

#define EMAIL_MIN 6
#define EMAIL_MAX 64
#define PASSWORD_MIN 8
#define PASSWORD_MAX 15
#define NAME_MIN 1
#define NAME_MAX_LEN 40
#define PHONE_MIN 3
#define PHONE_MAX 15
#define OTP_MIN 4
#define OTP_MAX 6
#define POST_CONTENT_MAX 1000
#define POST_CONTENT_MIN 0
#define INVITE_CODE_MIN 4
#define INVITE_CODE_MAX 10
#define POINTS_MIN 2
#define POINTS_MAX 5
#define LOCATION_NAME_MIN 1
#define LOCATION_NAME_MAX 50

//Marker icon
//#define MARKER_HEIGHT 45.f
//#define MARKER_WIDTH 30.f
#define MARKER_HEIGHT 36.f
#define MARKER_WIDTH 29.f


//Regex Patterns
#define EMAIL_PATTERN @"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z]+)*(\\.(?:[A-Za-z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|arpa|blog|jobs|museum))$"
#define CHINA_EMAIL_PATTERN @"^(@.+)$"
#define NAME_PATTERN @"^( +)|(  +)|( +)$"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

//Convert Hex color code to UIColor
#define UIColorFromHexCode(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define dDeviceOrientation [[UIDevice currentDevice] orientation]
#define isPortrait  UIDeviceOrientationIsPortrait(dDeviceOrientation)
#define isLandscape UIDeviceOrientationIsLandscape(dDeviceOrientation)
#define isEnglish [Util checkLanguageIsEnglish]

#define SCREEN [[UIScreen mainScreen] bounds].size

#define SOCKET_URL @""

// Get Chat Url
#define LIVE_CHAT_SERVER [Util getChatUrl]
#define DEV_CHAT @"devchat.varialskate.com"
#define STAGING_CHAT @"stagechat.varialskate.com"
//#define STAGING_CHAT @"conference.stagechat.varialskate.com"
#define LIVE_CHAT @"chat.varialskate.com"

// Get Base Url
#define LIVE_API [Util getBaseUrl]
#define DEV_BASE_URL @"http://dev.varialskate.com/"
//#define STAGING_BASE_URL @"http://dev1.varialskate.com/"
#define STAGING_BASE_URL @"http://stageapi.varialskate.com/"
#define LIVE_BASE_URL @"https://api.varialskate.com/"
//#define LIVE_BASE_URL @"http://api.varialskate.com/"

// Get Shop Url
#define SHOPPING_LIVE [Util getShopUrl]
#define DEV_SHOP @"http://devshop.varialskate.com/index.php"
#define STAGING_SHOP @"http://stageshop.varialskate.com/index.php"
#define LIVE_SHOP @"https://shop.varialskate.com/index.php"

// Get Shop Host for clear browser history
#define SHOPPING_HOST [Util getShopHost]
#define DEV_SHOP_HOST @"devshop.varialskate.com"
#define STAGING_SHOP_HOST @"stageshop.varialskate.com"
#define LIVE_SHOP_HOST @"shop.varialskate.com"

#define IMAGE_HOLDER @"profileImageHolder.png"
#define IMAGE_HOLDER_SHOP @"shopicon.png"

///Authenticate
#define SIGNUP_API @"api/v1.0/players/authentication/email_sign_up.php"
#define FORGOT_PASSWORD @"api/v1.0/players/authentication/forgot_password.php"
#define COUNTRY_LIST @"api/v1.0/country/list.php"
#define SIGNIN @"api/v1.0/players/authentication/email_sign_in.php"
#define PHONE_NUMBER @"api/v1.0/players/authentication/sign_up_and_sign_in_with_phone_number.php"
#define SUBMIT_OTP @"api/v1.0/players/authentication/submit_otp.php"
#define APPLY_INVITE @"api/v1.0/players/authentication/invite_code.php"
#define VERIFY_OTP @"api/v1.0/players/settings/login_options/verify_otp_for_phone.php"
#define PLAYER_TYPE_LIST @"api/v1.0/players/authentication/list_player_types.php"
#define SET_PLAYER_TYPE @"api/v1.0/players/authentication/set_player_type.php"
#define GET_ECOM_AUTH_TOKEN @"api/v1.0/players/settings/get_player_ecommerce_token.php"
#define UPDATE_DEVICE_TOKEN @"api/v1.0/players/authentication/update_device_details.php"
#define UPDATE_PROFILE_IMAGE @"api/v1.0/players/settings/set_profile_image.php"


//Profile
#define EDIT_NAME @"api/v1.0/players/settings/update_player_name.php"
#define EDIT_LOCATION @"api/v1.0/players/settings/update_player_location.php"
#define BOARD_LIST @"api/v1.0/players/settings/skate_board_list.php"
#define UPDATE_BAORD @"api/v1.0/players/settings/update_player_skate_board.php"

//Settings
#define PROFILE_IMAGE_API @"api/v1.0/players/settings/update_profile_image.php"
#define CHANGE_EMAIL @"api/v1.0/players/settings/login_options/change_email_id.php"
#define CANCEL_EMAIL @"api/v1.0/players/settings/login_options/cancel_set_email_and_phone_number.php"
#define LOGOUT_API @"api/v1.0/players/authentication/logout.php"
#define SET_EMAIL_API @"api/v1.0/players/settings/login_options/set_email_id.php"
#define CHANGE_PASSWORD_API @"api/v1.0/players/settings/update_password.php"
#define CHANE_PHONE_NUMBER @"api/v1.0/players/settings/login_options/update_player_phone_number.php"
#define SET_PHONE_NUMBER @"api/v1.0/players/settings/login_options/set_player_phone_number.php"
#define VERIFY_OTP @"api/v1.0/players/settings/login_options/verify_otp_for_phone.php"
#define VIEW_NOTIFICATION @"api/v1.0/players/settings/view_notification_status.php"
#define UPDATE_NOTIFICATION @"api/v1.0/players/settings/update_notification_status.php"
#define SET_LANGUAGE @"api/v1.0/players/settings/set_language.php"

//Country
#define STATE_LIST @"api/v1.0/feeds/get_state.php"
#define CITY_LIST @"api/v1.0/feeds/get_city.php"
#define PLAYER_LOGIN_STATUS @"api/v1.0/players/settings/login_options/player_logged_in_status.php"

//General
#define RESEND_EMAIL @"api/v1.0/players/authentication/re_send_email.php"
#define GENERAL_API @"api/v1.0/notification/varial_general_notification.php"

//Privacy
#define VIEW_BLOCKED_PLAYERS @"api/v1.0/players/settings/privacy/view_blocked_players.php"
#define UNBLOCKED_PLAYERS @"api/v1.0/players/settings/privacy/un_block_players.php"

//Social Feed
#define RECEPIENT @"api/v1.0/feeds/post_type_list.php"
#define CREATE_POST_RECEPIENT @"api/v1.0/feeds/get_post_options.php"
#define FEEDS_TYPES_LIST @"api/v1.0/feeds/post_type_list.php"
#define FEEDS_LIST @"api/v1.0/feeds/feeds_list.php"
#define STAR_UNSTAR @"api/v1.0/feeds/star_or_unstar_post.php"
#define ADD_BOOKMARK @"api/v1.0/feeds/bookmark.php"
#define BOOKMARK_LIST @"api/v1.0/feeds/bookmark_list.php"
#define EDIT_POST @"api/v1.0/feeds/post_edit.php"
#define DELETE_POST @"api/v1.0/feeds/post_delete.php"
#define DELETE_SHARE_POST @"api/v1.0/feeds/share_delete.php"
#define GET_FULL_CONTENT @"api/v1.0/feeds/continue_reading.php"
#define MOVE_PRIVATE_FEEDS @"api/v1.0/feeds/change_post_type.php"
#define FEEDS_SEARCH @"api/v1.0/feeds/feed_search.php"
#define SEARCH_HISTORY @"api/v1.0/feeds/search_history.php"
#define CLEAR_SEARCH_HISTORY @"api/v1.0/feeds/clear_search.php"
#define DELETE_PROFILE_IMAGE @"api/v1.0/players/settings/delete_profile_image.php"


#define POST_CREATE @"api/v1.0/feeds/post_feed.php"
#define POST_DETAILS  @"api/v1.0/feeds/feed_detail.php"
#define STAR_FOR_MEDIA  @"api/v1.0/feeds/star_or_unstar_post_media.php"
#define COMMENT_FOR_MEDIA  @"api/v1.0/feeds/feed_comment/create_comment_media.php"
#define COMMENT_FOR_POST  @"api/v1.0/feeds/feed_comment/create_comment.php"
#define COMMENT_LIST_FOR_POST  @"api/v1.0/feeds/feed_comment/list_comment.php"
#define COMMENT_LIST_FOR_MEDIA  @"api/v1.0/feeds/feed_comment/list_comment_media.php"
#define DELETE_COMMENT_FOR_MEDIA  @"api/v1.0/feeds/feed_comment/delete_comment_media.php"
#define DELETE_COMMENT_FOR_POST  @"api/v1.0/feeds/feed_comment/delete_command.php"
#define MEDIA_DELETE  @"api/v1.0/feeds/media_delete.php"

#define LIST_POST_STAR_MEMBERS  @"api/v1.0/feeds/list_post_star_members.php"
#define LIST_POST_MEDIA_STAR_MEMBERS  @"api/v1.0/feeds/list_post_media_star_members.php"

#define ADD_VIDEO_COUNT @"api/v1.0/feeds/add_media_view_count.php"
#define GET_POPULAR_VIDEOS @"api/v1.0/feeds/channel_feeds.php"
//Notification
#define GENERAL_NOTIFICATION_LIST  @"api/v1.0/notification/view_general_notification.php"
#define FRIEND_NOTIFICATION_LIST  @"api/v1.0/notification/get_friend_notifications.php"
#define RESET_NOTIFICATION  @"api/v1.0/notification/update_notification_count.php"

//Friends API
#define FRIENDS_LIST @"api/v1.0/friends/friends_list.php"
#define MY_FRIENDS  @"api/v1.0/friends/my_friends_list.php"
#define SEARCH_MY_FRIENDS  @"api/v1.0/friends/search_in_my_friends.php"
#define GET_PLAYER_INFORMATION  @"api/v1.0/players/settings/get_player_information.php"
#define FRIEND_PROFILE  @"api/v1.0/friends/friend_profile_details.php"
#define POINTS_ACTIVITY_LOG  @"api/v1.0/leaderboard/points_activity_log.php"
#define PROFILE_FEEDS  @"api/v1.0/feeds/profile_feeds.php"
#define PROFILE_SHARE @"api/v1.0/feeds/post_share.php"

//Invite Friends API
#define SEARCH_VIA_VARIAL  @"api/v1.0/friends/search_via_varial.php"
#define SEARCH_VIA_EMAIL  @"api/v1.0/friends/send_invite_via_email.php"

//Friends circle
#define ADD_FRIEND @"api/v1.0/friends/add_friend.php"
#define UNFRIEND @"api/v1.0/friends/un_friend.php"
#define ACCEPT_REJECT @"api/v1.0/friends/accept_reject.php"
#define CANCEL_INVITE @"api/v1.0/friends/canel_request.php"
#define BLOCKFRIEND @"api/v1.0/friends/block_friend.php" 

//Points
#define BUY_POINTS_LIST @"api/v1.0/leaderboard/points/list_buy_point.php"
#define BUY_POINTS @"api/v1.0/leaderboard/points/buy_point.php"
#define TEAM_BUY_POINTS @"api/v1.0/teams/team_buy_point.php"

//Team API
#define CREATE_TEAM @"api/v1.0/teams/create_team.php"
#define TEAM_NAME_EXISTENCE @"api/v1.0/teams/team_name_existence.php"
#define TEAM_LIST @"api/v1.0/teams/get_player_teams.php"
#define TEAM_DETAILS @"api/v1.0/teams/get_team_information.php"
#define EDIT_TEAM_NAME @"api/v1.0/teams/edit_team_name.php"
#define EDIT_TEAM_IMAGE @"api/v1.0/teams/update_profile_image.php"
#define SET_COCAPTAIN @"api/v1.0/teams/change_co_captain.php"
#define REMOVE_COCAPTAIN @"api/v1.0/teams/remove_co_captain.php"
#define GET_COCAPTAIN_LIST @"api/v1.0/teams/list_all_team_member_to_set_co_captain.php"
#define SEARCH_COCAPTAIN_LIST @"api/v1.0/teams/search_my_team_member_to_set_co_captain.php"
#define LIST_TEAM_MEMBERS @"api/v1.0/teams/list_all_member.php"
#define SEARCH_TEAM_MEMBER @"api/v1.0/teams/search_my_team_member.php"
#define INVITE_MEMBER_LIST @"api/v1.0/teams/invite_members_list_order.php"
#define SEARCH_INVITE_MEMBER_LIST @"api/v1.0/teams/invite_members_list.php"
#define ADD_MEMBER @"api/v1.0/teams/invite_player_to_team.php"
#define VIEW_INVITIES_LIST @"api/v1.0/teams/view_all_pending_invites.php"
#define SEARCH_INVITIES_LIST @"api/v1.0/teams/view_all_pending_invities_with_search.php"
#define CANCEL_INVITIES @"api/v1.0/teams/cancel_invites.php"
#define ACCEPT_REJECT_TEAM @"api/v1.0/teams/accept_reject_team_invite.php"
#define LEAVE_MEMBER_COCAPTAIN @"api/v1.0/teams/member_remove_to_team.php"
#define LIST_AVAILABLE_CAPTAIN @"api/v1.0/teams/list_all_member_captain_change.php"
#define SEARCH_AVAILABLE_CAPTAIN @"api/v1.0/teams/search_all_member_captain_change.php"
#define SELECT_CAPTAIN @"api/v1.0/teams/remove_captain.php"
#define TEAM_POINTS_ACTIVITY_LOG @"api/v1.0/leaderboard/team_activity_log.php"
#define REMOVE_TEAM_MEMBER @"api/v1.0/teams/remove_team_member.php"
#define TEAM_ACTIVITY_LOG @"api/v1.0/leaderboard/team_activity_log.php"


//Donate
#define DONATE_MEMBER_LIST @"api/v1.0/players/player_donate_points/get_player_list.php"
#define DONATE_MEMBER_SEARCH @"api/v1.0/players/player_donate_points/search_player_list.php"
#define DONATE_TEAM_LIST @"api/v1.0/players/player_donate_points/team_list.php"
#define DONATE_TEAM_SEARCH @"api/v1.0/players/player_donate_points/team_search.php"
#define DONATE_FROM_MEMBER @"api/v1.0/players/player_donate_points/point_donate_to_team_and_player.php"
#define DONATE_FROM_TEAM @"api/v1.0/players/player_donate_points/team_donate/team_donate_points_to_team_and_player.php"

//Leader board
#define TOP_SCORERS @"api/v1.0/leaderboard/list_leader_board_rank.php"
#define POINTS_LIST @"api/v1.0/leaderboard/view_points_details.php"

#define LEADER_BOARD @"api/v1.0/leaderboard/view_leader_board_rank.php"
#define PLAYERS_LIST_SEARCH @"api/v1.0/leaderboard/player_leader_board_search.php"

#define TEAM_POINTS_LEADER_BOARD @"api/v1.0/leaderboard/team_leader_board/view_team_points_details.php"
#define TEAM_LEADER_BOARD @"api/v1.0/leaderboard/team_leader_board/view_team_leader_board_rank.php"
#define TEAMS_LIST_SEARCH @"api/v1.0/leaderboard/team_leader_board/team_leader_board_search.php"

//Near By Offer
#define FROM_SHOP_LIST @"api/v1.0/offers/nearby/offers_from_shop.php"
#define NEAR_BY_OFFER_LIST @"api/v1.0/offers/nearby/list_offers.php"
#define OFFER_DETAILS @"api/v1.0/offers/nearby/offer_detail.php"
#define NEAR_BY_SHOP_LIST @"api/v1.0/offers/nearby/nearby_shop_list.php"
#define OFFERS_FROM_SHOPS @"api/v1.0/offers/nearby/shop_offers.php"

//Buzzard run
#define ALL_BUZZARD_RUN @"api/v1.0/my_buzzard_run/list_all_buzzard_run.php"
#define SEARCH_ALL_BUZZARD_RUN @"api/v1.0/my_buzzard_run/search_all_buzzard_run.php"
#define NEAR_BY_BUZZARD_RUN @"api/v1.0/my_buzzard_run/near_by_buzzard_run_list.php"
#define NEAR_BY_BUZZARD_RUN_SHOP_LIST @"api/v1.0/my_buzzard_run/near_by_buzzard_run_shop_list.php"
#define NEAR_BY_BUZZARD_RUNS_FROM_SHOP @"api/v1.0/my_buzzard_run/shops_buzzard_run_list.php"
#define BUZZARD_RUN_DETAIL @"api/v1.0/my_buzzard_run/view_buzzard_run_details.php"
#define REGISTER_BUZZARD_RUN @"api/v1.0/my_buzzard_run/register_buzzard_run.php"
#define MY_BUZZARD_RUN @"api/v1.0/my_buzzard_run/my_buzzardrun_list.php"
#define EVENT_DETAILS @"api/v1.0/my_buzzard_run/my_buzzardrun_list.php"
#define EVENT_POST_FEED @"api/v1.0/my_buzzard_run/event_post_feed.php"
#define EVENT_SUBMIT @"api/v1.0/my_buzzard_run/add_media.php"
#define POST_CREATE_BUZZARD_RUN @"api/v1.0/buzzard_runs/events/post_buzzard_run_event_feed.php"
#define BUZZARD_RUN_POST_LIST @"api/v1.0/buzzard_runs/events/list_post.php"
#define SUBMIT_FOR_APPROVAL @"api/v1.0/my_buzzard_run/submit_for_approval.php"
#define BUZZARD_RUN_COMMENTS_LIST_POST @"api/v1.0/buzzard_runs/events/comments/list_comment.php"
#define BUZZARD_RUN_COMMENTS_LIST_MEDIA @"api/v1.0/buzzard_runs/events/comments/list_media_comment.php"
#define BUZZARD_RUN_COMMENTS_DELETE_POST @"api/v1.0/buzzard_runs/events/comments/delete_comment.php"
#define BUZZARD_RUN_COMMENTS_DELETE_MEDIA @"api/v1.0/buzzard_runs/events/comments/delete_media_comment.php"
#define BUZZARD_RUN_COMMRNTS_CREATE_MEDIA @"api/v1.0/buzzard_runs/events/comments/create_comment_media.php"

//My Checkins
#define MY_CHECKIN_LIST @"api/v1.0/checkins/my_checkin_list.php"
#define CHECKIN_POST_LIST @"api/v1.0/checkins/checkin_post_details.php"
#define NEAR_BY_CHECKIN_LOCATION @"api/v1.0/checkins/nearby_checkin_location.php"
#define CHECKIN_POST_DETAIL @"api/v1.0/checkins/nearby_checkin_post_details.php"
#define POPULAR_CHECKINS @"api/v1.0/checkins/popular_checkin.php"
#define VISIBLE_POPULAR_CHECKIN @"/api/v1.0/checkins/popular_checkin_with_map_bounding.php"

//Club Promotions
#define LIST_ALL_CLUB_PROMOTIONS @"api/v1.0/club_promotion/all_club_promotion.php"
#define NEAR_BY_PROMOTIONS @"api/v1.0/club_promotion/near_by_club_promotion.php"
#define SEARCH_ALL_CLUB_PROMOTION @"api/v1.0/club_promotion/search_all_club_promotion.php"
#define REGISTER_CLUB_PROMOTION @"api/v1.0/club_promotion/register_club_promotion.php"
#define CLUB_PROMOTIONS_DETAILS @"api/v1.0/club_promotion/club_promotion_details.php"
#define MY_CLUP_PROMOTIONS @"api/v1.0/club_promotion/my_club_promotion.php"
#define SHOP_CLUB_PROMOTIONS @"api/v1.0/club_promotion/shops_club_promotion_list.php"
#define NEAR_BY_CLUB_PROMOTION_SHOPS @"api/v1.0/club_promotion/near_by_club_promotion_shops.php"

//Chat
#define UPLOAD_CHAT_MEDIA @"api/v1.0/chat/send_chat_media.php"
#define UPDATE_CHAT_STATUS @"api/v1.0/players/settings/update_chat_notification_status.php"

//Ad
#define GET_AD @"api/v1.0/advertisements/get_ad.php"

//Google Map
#define DIRECTIONS_API @"https://maps.googleapis.com/maps/api/directions/json"

#define REPORT_TYPES @"api/v1.0/feeds/post_report_type_list.php"
#define SEND_REPORT @"api/v1.0/feeds/post_report.php"
#define FOLLOW_UNFOLLOW @"api/v1.0/friends/follow.php"

#define ENDS_WITH_STRING @"Continue Reading..."


@end
