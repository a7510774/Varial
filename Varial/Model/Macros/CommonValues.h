//
//  CommonValues.h
//
//
//  Created by Guru Prasad chelliah on 9/20/17.
//
//

#ifndef CommonValues_h
#define CommonValues_h

// App Info
#define APP_NAME @"Varial"
#define TEXT_SEPARATOR  @"^^^%%"
#define TWO_STRING(string1,string2) [NSString stringWithFormat:@"%@ %@",string1,string2]

// Format  string
#define FORMAT_STRING(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]


//Date And Time
#define APP_DATE_FORMAT @"MMM dd, yyyy"
#define APP_DATE_AND_TIME_FORMAT @"MMM dd, yyyy hh:mm a"
#define APP_DATE_PICKER @"MMM dd, yyyy hh:mm a"
#define BIRTHDAY_UPDATE_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss Z"
#define WEB_DATE_FORMAT @"yyyy-MM-dd"
#define APP_TIME_FORMATE @"hh:mm a"
#define TITLE_CANCEL @"Cancel"
#define TITLE_OK @"OK"

// Color Code
//#define COLOR_APP_PRIMARY @"773F97"
#define COLOR_APP_PRIMARY @"2BC7AD"
#define COLOR_APP_SECONDAY @"E2E2E2"
#define COLOR_PINK @"FF2366"
#define COLOR_BLUE @"0094F5"

// Background Color
#define COLOR_BG_SCREEN @"F8FAFB"
#define COLOR_BG_TABLEVIEW @"0xEBEBEB"
#define COLOR_BG_TABLEVIEW_CELL @"0xF2F2F2"
#define COLOR_BG_LIGHT_GRAY @"0xE2E2E2"

// COMMON UI COLORS
#define COLOR_CLEAR [UIColor clearColor]
#define WHITE_COLOUR [UIColor whiteColor]
#define COLOR_BLACK [UIColor blackColor]
#define LIGHT_GRAY_COLOUR [UIColor lightGrayColor]

// Messages
#define MESSAGE_NO_DATA @"No data available"
#define MESSAGE_FAILED_BLOCK @"Could not reach server"
#define ALERT_NO_INTERNET @"It seems like you are not connected to internet"

// No Internet
#define ALERT_NO_INTERNET_DICT @{KEY_ALERT_TITLE:ALERT_RETRY_TITLE,KEY_ALERT_DESC:ALERT_NO_INTERNET_DESC,KEY_ALERT_IMAGE:ALERT_NO_INTERNET_IMAGE}

// Unable to Reach server
#define ALERT_UNABLE_TO_REACH_DICT @{KEY_ALERT_TITLE:ALERT_RETRY_TITLE,KEY_ALERT_DESC:ALERT_UNABLE_TO_REACH_DESC,KEY_ALERT_IMAGE:ALERT_UNABLE_TO_REACH_IMAGE}

// Unable to fetch location
#define ALERT_UNABLE_TO_FETCH_LOCATION_DICT @{KEY_ALERT_TITLE:ALERT_RETRY_TITLE,KEY_ALERT_DESC:ALERT_UNABLE_TO_FETCH_LOCATION,KEY_ALERT_IMAGE:ALERT_NO_LOCATION}


#define ICON_BOOKMARK_UN_SELECT @"icon_bookmark_unselect"
#define ICON_BOOKMARK_SELECT @"icon_bookmark_select"

#endif /* CommonValues_h */
