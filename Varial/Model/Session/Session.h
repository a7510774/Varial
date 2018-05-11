//
//  Session.h
//  YosiMDPayment
//
//  Created by Guru Prasad chelliah on 9/20/17.
//
//

#import <Foundation/Foundation.h>

//#import "NSUserDefaults+RMSaveCustomObject.h"

@interface Session : NSObject

@property (strong, nonatomic) NSUserDefaults *userDefaults;

+ (Session *)sharedObject;
- (instancetype)init;
- (void)resetSession;


#pragma mark - Project Oriented Methods

// Device Token
- (void)setDeviceToken:(NSString*)aToken;
- (NSString *)getDeviceToken;

// User LoggedIn Status
- (void)hasLoggedIn:(BOOL)aLoggedIn;
- (BOOL)hasLoggedIn;

// Set/Get Bool Value
- (void)setBoolValue:(BOOL)value;
- (BOOL)getBoolValue;
    
// Practice Id
- (void)setPacticeId:(NSString*)value;
- (NSString *)getPacticeId;

// AccessToken
- (void)setAccessToken:(NSString*)value;
- (NSString *)getAccessToken;

// Refresh Token
- (void)setRefreshToken:(NSString*)value;
- (NSString *)getRefreshToken;

// Practice Name
- (void)setPacticeName:(NSString*)value;
- (NSString *)getPacticeName;

// OnBoard Practice Id
- (void)setOnBoardPacticeId:(NSString*)value;
- (NSString *)getOnBoardPacticeId;

// PushNotification details
- (void)setPushDetailsPatientCashInfo:(NSDictionary*)value;
- (NSDictionary *)getPushDetailsPatientCashInfo;

// Practice Staff Email
- (void)setDashboardEmail:(NSString*)value;
- (NSString *)getDashboardEmail;

// Full payment button
- (void)setFullPaymentButtonEnable:(BOOL)aBool;
- (BOOL)isFullPaymentButtonEnable;

// Enroll payment button
- (void)setEnrollPaymentButtonEnable:(BOOL)aBool;
- (BOOL)isEnrollPaymentButtonEnable;


// Mute /UnMute Button Name
-(void)setMuteUnMuteButtonValue:(NSString *)buttonName;
- (NSString *)getMuteButtonName;
@end
