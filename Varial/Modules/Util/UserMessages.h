//
//  UserMessages.h
//  Varial
//
//  Created by Shanmuga priya on 4/2/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserMessages : UIView


//Error messages
#define CONTINUE_WHITESPACES @"Password cannot be empty"
#define CONFIRM_EMPTY @"Confirm Password cannot be empty"
#define CONFIRM_MISMATCH @"Passwords mismatch. Retry"
#define NEW_CONFIRM_MISMATCH @"New Password and Confirm Password mismatch"
#define EMAIL_EMPTY @"Email address cannot be empty"
#define PASSWORD_EMPTY @"Enter password"
#define OTP_EMPTY @"Enter One time password"
#define OLD_PASSWORD_EMPTY @"Old Password cannot be empty"
#define COUNTRY_EMPTY @"Select country"
#define STATE_EMPTY @"Select state"
#define City_EMPTY @"Select city"
#define ADDRESS_EMPTY @"Enter address"
#define INVITE_CODE_EMPTY @"Enter Invite Code"
#define OLD_PHONE_EMPTY @"Enter old phone number"
#define INVALID_NAME @"Enter a valid name"
#define INVALID_TEAM_NAME @"Enter a valid team name"
#define NAME_EMPTY @"Name cannot be empty"
#define PHONE_NUMBER_EMPTY @"Phone number cannot be empty"
#define POST_CONTENT_DOES_MAX @"Comment should not exceed %d characters"
#define BLANK_STATUS @"Status cannot be empty. Upload photos / videos to your status"
#define NEW_PHONE_NUMBER_EMPTY @"New phone number cannot be empty"
#define RECEPIE_EMPTY @"Select privacy type to post"
#define COCAPTAIN_NOT_PRESENT @"No Co-captain available"
#define CHECKIN_EMPTY @"Select your location to post"
#define CITY_EMPTY_FIELD @"City cannot be empty"
#define CATEGORY_EMPTY @"Category cannot be empty"
#define MEDIA_EMPTY @"Upload photos/ videos to your status"
#define INVITE_CODE @"Invite Code"
#define NO_ROUTESEARCH_FOR_SHOP @"No route found for this Shop"
#define NO_ROUTESEARCH_FOR_CLUB @"No route found for this Club"
#define HOW_TO_FIND_INVITE_CODE @"How to find invite code?"


//Home tab/Feeds
#define PERFORM_LATER @"You can perform this action shortly."
#define POST_UPLOADED @"Your post is already uploaded"
#define POST_CANCELLED @"Posting canceled"
    //comments
#define COMMENT_STILL_POSTING @"Please wait while the comment is being posted"
#define WRITE_COMMENT @"Write a comment..."
#define DELETE_COMMENT @"Do you want to delete this comment?"
#define NO_COMMENTS @"No comments"
#define POSTING @"Posting..."

//CreatePostController
#define POST_COMMENT @"Post Comments"
#define DISCARD_POST @"Do you want to discard this post?"
#define COMMENTS @"Comments"
#define POST_FEED @"Post Feed"
#define MEDIA @"Media"
#define DISCARD @"Discard"
#define MEDIA_SIZE_EXCEEDS @"Media size exceeded"
#define MEDIA_SIZE_ALLOWED @"Maximum files allowed: %d"
#define IMAGE_ALLOWED @"Only %d images can be posted"
#define VIDEOS_ALLOWED @"Only %d videos can be posted"
#define MEDIA_SIZE_SHOULD_BE @"Maximum upload file size: %d MB"
#define DETECT_LOCATION @"Varial is finding your current Location. please wait..."

//Post Details
#define CHANNEL @"Channel Details"
#define POST_DETAIL @"Post Details"
#define DELETE_MEDIA @"Do you want to delete this item?"
#define DELETE_POST_CONFIRM @"Do you want to delete media along with the post?"
#define COMMENTS_COUNT @"%@ Comments"
#define CANNOT_LIKE_COMMENT @"Become a member to like and comment"
#define IMAGE_SAVED @"Image saved to gallery"
#define IMAGE_NOT_CAPTURED @"Image capturing failed. Try again."
#define TRY_AGAIN_STRING @"Try again"
#define VIDEO_DURATION @"Media should have minimum 3 seconds duration"
#define FEED_TYPE_NOT_FOUND @"Your Internet Connection is slow please Try again"

//showCheckInMap
#define CHECK_IN @"Check In"

//feeds
#define NEWS_FEED @"News Feed"
#define FRIENDS_FEED @"Friends Feed"
#define POPULAR_FEED @"Popular Public Feeds"
#define FEED @"Feeds"
#define DELETE_FOR_SURE @"Are you sure you want to delete?"
#define CANCEL_FOR_SURE @"Are you sure you want to cancel?"
#define NO_NEWS_FEEDS @"No News Feeds to display"
#define NO_FRIENDS_FEEDS @"No Friends Feeds to display"
#define NO_PRIVATE_FEEDS @"No Private Feeds to display"
#define NO_TEAM_FEEDS @"No Team Feeds to display"
#define NO_POPULAR_PUBLIC_FEEDS @"No Popular Public Feeds to display"
#define DELETE_MENU @"Delete"
#define EDIT_MENU @"Edit"
#define MOVE_FEED_MESSAGE @"Are you sure?"
#define POST_TO_PUBLIC @"Post to public"
#define POST_TO_FRIENDS @"Post to friends"
#define UPLOAD_SUCCESS @"Media upload successful. You post will be visible in feeds shortly"

//FriendNotification
#define NO_NOTIFICATION @"No Notifications to display"

//Authenticate
//PlayerType
#define SIGN_UP_AS @"Sign Up As"
#define MEMBER_ALERT @"Member Level ALERT!"

//Settings/Notification
//notification
#define NOTIFICATIONS @"Notifications"
#define EMAIL_NOT_FOUND @"Email ID not found"
#define SET_EMAIL @"Provide an email address"
#define WAITING_FOR_CONFIRMATION @"Waiting for confirmation"

//Settings/Privacy
//BlockedUsers
#define BLOCKED_USERS @"Blocked Users"
#define NO_BLOCKED_USERS @"You have not blocked any user"

//privacy
#define PRIVACY @"Privacy"

//Settings/LoginOptions
//LoginOptions
#define LOGIN_OPTIONS @"Login Options"
#define CHANGE_EMAIL_ID @"Change Email ID"
#define SET_EMAILID @"Email ID"
#define CHANGE_NUMBER @"Change Phone Number"
#define SET_NUMBER @"Set Phone Number"
#define NEW_NUMBER @"New phone number"
#define SET_LOCATION @"Set Location"
#define PHONE_NO @"Phone number"
#define SET_EMAILID_STRING @"Set Email ID"

//Settings
//SettingsMenu
#define SETTINGS_TITLE @"Settings"
#define PASSWORD @"Password"
#define NOTIFICATION @"Notifications"
#define SET_EMAIL_TO_CHANGE_PASSWORD @"Provide registered email address to change password"
#define EMAIL @"Email address"

//Friends
    //MyProfile
#define NO_BOARDS @"No Boards are present"
#define NO_FRIENDS @"You have no friends"
#define NO_FEEDS @"No Feeds"
#define VIEW_PROFILE @"View Profile"
#define CHOOSE_BOARD @"Choose or Select Board"

//MyFriends
#define USER_FRIEND @"%@'s Friends"
#define MY_FRIEND @"My Friends"
#define MY_FOLLOWERS @"My Followers"
#define MY_FOLLOWEINGS @"My Followings"
#define START_A_CHAT @"Start a chat"
#define NO_RESULT_FOUND @"No results found"

//InviteFriends
#define INVITE_FRIEND @"Invite Friends"
#define SEARCH_FRIEND @"Search Friends"
//Bookmark
#define BOOKMARK @"Bookmark"
#define SEARCH_FEEDS @"Search feeds"
#define TITLE_SEARCH_HISTORY @"History"


//Follow & Following
#define FOLLOW @"Follow"
#define FOLLOWING @"Following"
// Profile Update
#define PROFILEUPDATE @"Profile Update"

//FriendsProfile
#define BLOCK_PERSON @"Block this person"
#define SURE_TO_BLOCK @"Are you sure you want to block this person?"
#define FRIENDS_NIL @"No friends"
#define FRIENDS_PROFILE @"%@"

//PointsActivityLog
#define POINTS_LOG @"Points Activity Log"
#define NO_POINTS_LOG @"You don't have any Points Activities Log"

//TeamViewController
#define LEAVE_TEAM @"Leave Team"
#define CHANGE_CO_CAPTAIN @"Change Co-captain"
#define REMOVE_CO_CAPTAIN @"Remove Co-captain"
#define VIEW_INVITIES @"View Invitees"
#define TEAM_VIEW @"Team View"
#define TEAM @"Team"
#define SURE_TO_REMOVE_CO_CAPTAIN @"Are you sure you want to remove the Co-captain?"
#define TEAM_CHAT @"Team Chat"
#define SELECT_CAPTAIN_TO_LEAVE @"Select Captain before leaving"
#define SURE_TO_LEAVE_TEAM @"Are you sure you want to leave the team?"
#define SURE_TO_REMOVE @"Are you sure you want to remove?"
#define DONT_HAVE_FEED @"No new feeds to display"

//NonMemberViewController
#define NO_MEMBERS @"No members"

//TeamMemberViewController
#define TEAM_MEMBERS @"Team Members"
#define NO_MEMBERS_PRESENT @"No members present"
#define INVALID_OPERATION @"Performing invalid operation"

//TeamInvitiesViewController
#define SET_CO_CAPTAIN @"Select Co-Captain"
#define ADD_MEMBERS @"Invite Members"
#define SELECT_CAPTAIN_TITLE @"Select Captain"
#define TEAM_INVITE @"Team Invite"
#define NO_MEMBERS_IN_TEAM @"No members in your team"
#define NO_MEMBERS_TO_INVITE @"No members to invite"
#define NO_INVITED_MEMBERS @"No invited members"
#define NO_MEMBERS_TO_SELECT_CAPTAIN @"No members to select a captain"

//CreateTeam
#define CREATE_TEAM_TITLE @"Create Team"
#define MIN_POINTS_TO_JOIN @"Please enter minimum %d points"
#define TEAM_PIC_EMPTY @"Team picture cannot be empty. Upload a photo."
#define ENTER_MIN_POINTS @"Points to join team cannot be empty"
#define MIN_POINTS_REQUIRED @"Minimum %d points required"
#define NO_TEAM @"You don't belong to any team."


//Map
    //GoogleMap
#define CURRENT_LOCATION @"Current Location"

//CheckIn
//CheckInViewController
#define CHECK_IN_TITLE @"Check In"
#define ADD_A_CHECKIN @"Add a location to check in"
#define COULD_NOT_ACCESS_CURRENT_LOCATION @"Varial could not access your current location"

//GoogleCheckin.m
#define NO_NEARBY_LOCATION @"No nearby locations found"
#define USE_CURRENT_LOCATION @"Do you want to use your current location to check-in?"

//InAppPurchase
//InAppPurchaseManager
#define POINTS @"Points"
#define POINTS_TO_JOIN @"Points to join"
#define POINTS_NOT_FOUND @"Points not found"

//Points
    //BuyPointsViewController
#define BUY_POINT @"Buy Points"
#define NO_PRODUCT @"No products availabe now"


//DonatePoints
#define DONATE_POINTS @"Donate Points"
#define SEARCH_BY_TEAM_NAME @"Search by team name"
#define SEARCH_NAME_EMAIL @"Search by Name, Email, or Phone Number"
#define NO_TEAMS @"No teams"
#define TEAM_NAME_TITLE @"Team Name"

//DonateForm
#define ENTER_POINTS_TO_DONATE @"Donate points cannot be Empty"
#define POINTS_ZERO @"Points cannot be zero"
#define DONATE @"Donate"
#define SURE_TO_DONATE @"Are you sure you want to donate?"

//LeaderBoard
    //LeaderBoard
#define LEADER_BOARD_TITLE @"Leader Board"
#define  PLAYER_LIST_TITLE @"Player List"
#define  TEAM_LIST_TITLE @"Team List"
#define  NO_PLAYERS_MESSAGE @"No players found"
#define  NO_TEAM_MESSAGE @"Team not found"


//TopScorers
#define TOP_SCORER @"Top Scorers"
#define POINTS_INFO @"Points Information"

//NearByOffers
    //OffersList
#define OFFERS @"Offers"
#define NEAR_BY_OFFERS @"Nearby Offers"
#define NO_NEAR_BY_OFFERS @"No Nearby Offers found"
#define NO_OFFER_NOTIFICATION @"You have no Offers"
#define NO_OFFERS_FROM_SHOP @"No offers in this shop"
#define NO_OFFER_FOUND_FROM_SHOP @"No offers in this shop"
#define VIEW_DETAILS @"View Details"

//ShopDetails
#define SHOP_DETAILS @"Shop Details"
#define YOU @"You"

//BuzzardRun
    //BuzzardRunHome
#define BUZZARD_RUN @"Buzzard Run"
#define NO_BUZZARD_RUN_AVAILABLE @"No Buzzard Runs are available"
#define MY_CURRENT_LOCATION @"My current location"

//ViewNearBy
#define VIEW_NEAR_BY @"View Nearby"
#define MY_BUZZARD_RUN_TITLE @"My Buzzard Run"
#define NOT_REGISTERED_BUZZARD @"You are not a registered user of Buzzard Run"

//Buzzard runs from shops
#define BUZZARD_RUNS @"Buzzard Runs"
#define NO_BUZZARD_RUN_IN_SHOP @"No Nearby Buzzard Runs in this shop"

//BuzzardRunDetails
#define BUZZARD_RUN_DETAILS @"Buzzard Run Details"
#define WANT_TO_REGISTER @"Do you want to register?"
#define ACTIVATION_CODE @"Activation Code"
#define NO_EVENTS_AVAILABLE @"No events are available"
#define NEW @"New"
#define REGISTER @"Register"
#define APPROVED @"Approved"
#define IN_PROGRESS @"In Progress"
#define SUBMITTED @"Submitted"
#define REWARDED @"Rewarded"
#define EXPIRED @"Expired"
#define COMPLETED @"Completed"
#define SHOW_ACTIVATION_CODE @"Show this activation code to the shop owner and activate Buzzard Run \n"

//BuzzardRunPost
#define EVENT_POST_TITLE @"%@ Event"
#define BUZZARD_STILL_POSTING @"Posting… Please wait!"
#define NEED_APPROVED @"You need to register and verify with shop owner to post"

//GetDirection
#define DIRECTION @"Direction"

#define COMMENTS_EXCEED @"Comments cannot exceed 1000 characters"

//Shopping
    //ShoppingHome
#define SHOPPING @"Shopping"
#define PRODUCT_DETAILS @"Product Details"

//ShopDetails
#define VALID_UPTO @"Valid Upto %@"

//MyCheckin
    //MyCheckins
#define MY_CHECKINS @"Check In"
#define NO_NEAR_BY_CHECKIN @"No Nearby Check Ins"
#define NO_CHECKINS @"No new Check Ins"

//MyCheckinDetails
#define MY_CHECKIN_DETAILS @"Check In details"
#define CANCEL_UPLOAD @"Cancel Upload"

//ClubPromotions
    //NearByClubPromotions
#define NO_CLUB_PROMOTION @"No Nearby Club Promotions found"
#define NO_CLUB_AVAIALBLE @"No Club Promotions are available"
#define CLUB_TITLE @"Club Promotions"
#define NOT_REGISTERED_CLUB_PROMOTIONS @"You are not registered with any club promotions"

//MyClubPromotions
#define REGISTERED @"Registered"
#define ACTIVE @"Active"
#define COMPLETED @"Completed"
#define MY_CLUB_PROMOTION_TITLE @"My Club Promotions"

//ClubPromotionDetails
#define CLUB_PROMOTION_TITLE @"Club Promotions"
#define CLUB_PROMOTION_DETAILS @"Club Promotion Details"
#define CLUB_PROMOTION @"Club Promotion"
#define SHOW_ACTIVATION_CODE_CLUB_PROMOTIONS @"Show this activation code to Club owner and activate the Club promotion \n"
#define NO_NEAR_BY_PROMOTIONS @"No Nearby Club Promotions are available"
//Games
#define GAME_TITLE @"Games"

//Util
#define COMING_SOON @"Coming Soon"
#define LOADING @"Loading"
//#define PLEASE_LOADING @"Loading… Please wait!"
#define PLEASE_LOADING @"Please wait while feeds display"
//#define VIDEO_COMPRESSING @"Please wait while it's getting compressed"
#define RANK @"Rank: %@"
#define RANKVAL @"Rank %@"
#define CREW @"Crew"
#define MEDIA @"Media"
#define JUST_NOW @"Just now"
#define SECONDS_AGO @"%d Seconds ago"
#define A_MINUTE_AGO @"A minute ago"
#define MINUTE_AGO @"%d Minutes ago"
#define AN_HOUR_AGO @"An hour ago"
#define HOURS_AGO @"%d Hours ago"
#define YESTERDAY @"Yesterday"
#define DAYS_AGO @"%d Days ago"
#define LAST_WEEK @"Last week"
#define WEEKS_AGO @"%d weeks ago"
#define LAST_MONTH @"Last month"
#define MONTHS_AGO @"%d Months ago"
#define LAST_YEAR @"Last year"
#define YEARS_AGO @"%d Years ago"
#define TURN_ON_LOCATION @"Turn on \"Location Services\" to allow \"varial\" to determine your location"
#define TURN_ON_INAPP_PURCHASE @"Turn on \"In-App Purchases\" in your Settings"
#define GALLERY_ALERT @"Allow \"Varial\" to access your Photos"
#define SETTINGS_PATH @"Settings -> General -> Restrictions"

//ViewController
#define FRIENDS_REQUEST @"Friend Request"
#define GLOBAL_NOTIFICATION @"Global Notification"
#define MENU @"Menu"
#define EMAIL_VERIFICATION @"Email should be verified."

//AUTHENTICATE
#define SELECT_LANGUAGE @"Select Language"
#define TITLE_SIGNIN @"SignIn"
#define TITLE_SIGNUP @"SignUp"
#define TITLE_FORGOT_PASSWORD @"Forgot Password"
#define TITLE_SIGNUP_WITH_MOBILE @"SignUp With Phone"
#define TITLE_OTP_VALIDATION @"OTP Validation"

#define CHECK_NETWORK @"Please check network connection"
#define NETWORK_TITLE @"Network"
#define ABOUT_TITLE @"About App"
#define OTP_TITLE @"One time password"
#define VERSION_TITLE @"Version"
#define BUILD_NUMBER @"Build Number"

//Team
#define SELECT @"Select"
#define CANCEL @"Cancel"
#define INVITE @"Invite"
#define INVITING @"Inviting"
#define YES_STRING @"Yes"
#define NO_STRING @"No"
#define SIGNUP_AS_SKATER @"Are you sure you want to sign up as Skater?"
#define SIGNUP_AS_CREW @"Are you sure you want to sign up as Crew?"
#define SIGNUP_AS_MEDIA @"Are you sure you want to sign up as Media?"
#define CONFIRMATION @"Confirmation Required"
#define JOIN_TEAM @"Are you sure you want to join %@ team? \n %@ Points will be deducted"
#define FREE_BIES @"FreeBies"


#define NAME_TITLE @"Name"
#define NEW_PASSWORD @"New Password"
#define LOCATION_TITLE @"Location"

// CHAT
#define CHAT @"Chat"
#define CHAT_MESSAGE_EMPTY @"Chat message cannot be empty."
#define PLEASE_WAIT_JOINING @"Please wait for few seconds while we are joining you in Team chat. Retry"
#define SEE_PROFILE_INFO @"Tap here to see profile info"
#define CHAT_FRIENDS @"Friends"
#define CONNECTING @"Connecting..."
#define WAITING_FOR_NETWORK @"Waiting for network..."
#define WRITE_MESSAGE @"Type a message here..."
#define TYPING @"Typing..."
#define USER_TYPING @"%@ is typing..."
#define ADD_FRIEND_BUTTON @"Add Friend"
#define ONLINE @"Online"
#define LAST_SEEN @"Last seen"
#define LAST_SEEN_TIME @"Last seen %@"
#define YOU_NEED_FRIENDS_OR_TEAM_START_CHAT @"You need friends or team to start a chat. Click here to"
#define ADDFRIEND_OR_CREATE_TEAM @"Add Friends or Create Team"
#define ADDFRIENDS @"Add Friends"
#define START_CHAT @"You need friends or team to start a chat"
#define VIEW_PROFILE @"View Profile"
#define DELETE_CHAT_HISTORY @"Delete Chat History"
#define NO_FRIENDS_AVAILABLE @"No Friends Available. Add Friends"
#define NO_TEAM_AVAILABLE @"No teams are available. Create a team."
#define SEARCH_FRIENDS @"Search Friends"
#define MAIN_MENU @"Main Menu"
#define CAPTAIN_REMOVE_MEMBER @"%@ removed %@ from the team"
#define NEW_MEMBER_JOIN @"%@ joined the team"
#define REMOVE_COCAPTAIN_STATUS @"%@ removed %@ from Co-Captain position"
#define SET_COCAPTAIN_STATUS @"%@ assigned %@ as Co-Captain"
#define NO_LONGER_MEMBER @"%@ no longer member in a team"
#define CHANGE_CAPTAIN @"%@ assigned %@ as a Captain"
#define SENT_YOU_IMAGE @"Sent you an image"
#define SENT_YOU_VIDEO @"Sent you an video"
#define IMAGE @"Image"
#define VIDEO @"Video"
#define MEDIA @"Media"
#define CAMERA @"Camera"
#define POST_TITLE @"Post"
#define PROFILE @"Profile"
#define YOU_CAN_NOT_FORWARD @"You can't forward this message"
#define NO_INTERNET_CONNECTION @"No Internet Connection"
#define YOU_HAVE_BLOCKED_THIS_USER @"You have blocked this user"
#define YOU_NEED_FRIEND_TO_CHAT @"You need to be a friend to chat"
#define YOU_CAN_NOT_MESSAGE @"You cannot message this user"
#define YOU_NO_LONGER_MEMBER @"You are no longer member in a %@"
#define RECENT_CHAT @"Recent Chats"
#define TODAY @"Today"
#define SEND_PHOTO @"SEND PHOTO"
#define SEND_VIDEO @"SEND VIDEO"
#define DELETED_MEDIA @"The media you are trying to send has been deleted"
#define GO_ONLINE @"Go Online"
#define GO_OFFLINE @"Go Offline"
#define SEARCH_BY_NAME @"Search by Name"

#define REPORT_THE_POST @"Report post"
#define BLOCK_THE_USER @"Block user"
#define REPORT_POST @"CHOOSE THE REASON"
#define Description @"Description"

@end


