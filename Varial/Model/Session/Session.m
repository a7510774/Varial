//
//  Session.m
//  YosiMDPayment
//
//  Created by Guru Prasad chelliah on 9/20/17.
//
//

#import "Session.h"

@implementation Session

+ (Session *)sharedObject {
    
    static Session *_sharedObject = nil;
    
    @synchronized (self) {
        if (!_sharedObject)
            _sharedObject = [[[self class] alloc] init];
    }
    
    return _sharedObject;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)saveSessionValues {
    
    [self.userDefaults synchronize];
}

- (void)resetSession {
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

#pragma mark - Sample Methods

- (void)setBoolValue:(BOOL)value {
    
    [self.userDefaults setObject:value ? @"YES" : @"NO" forKey:@"BoolValue"];
    [self saveSessionValues];
}

- (BOOL)getBoolValue {
    
    if ([self.userDefaults objectForKey:@"BoolValue"] == nil) {
        [self setBoolValue:NO];
    }
    
    return [[self.userDefaults objectForKey:@"BoolValue"] isEqualToString:@"YES"] ? YES : NO;
}


- (void)setIntegerValue:(NSInteger)value {
    
    [self.userDefaults setInteger:value forKey:@"IntegerValue"];
    [self saveSessionValues];
}

- (NSInteger)getIntegerValue {
    
    NSInteger value = [self.userDefaults integerForKey:@"IntegerValue"];
    
    if(!value)
        value = 0;
    
    return value;
}

- (void)setStringValue:(NSString*)value {
    
    [self.userDefaults setObject:value forKey:@"StringValue"];
    [self saveSessionValues];
}

- (NSString *)getStringValue {
    
    NSString *value = [self.userDefaults valueForKey:@"StringValue"];
    
    if ([value length] == 0)
        value = @"";
    
    return value;
}

- (void)setMutableArrayValue:(NSMutableArray *)value {
    
    [self.userDefaults setObject:value forKey:@"MutableArrayValue"];
    [self saveSessionValues];
}

- (NSMutableArray *)getMutableArrayValue {
    
    NSMutableArray *value = [NSMutableArray arrayWithArray:[self.userDefaults objectForKey:@"MutableArrayValue"]];
    return value;
}

#pragma mark - Last updated time

- (void)setLastUpdatedTime:(NSString *)time module:(NSString *)module {
    
    [self.userDefaults setObject:time forKey:module];
    [self saveSessionValues];
}

- (NSString *)getLastUpdatedTimeFor:(NSString *)module {
    
    NSString *lastUpdatedTime = [self.userDefaults valueForKey:module];
    
    if ([lastUpdatedTime length] == 0)
        lastUpdatedTime = @"";
    
    return lastUpdatedTime;
}

#pragma mark - Project Oriented Methods

#pragma mark -App Launched Status


#pragma mark -Device Token

- (void)setDeviceToken:(NSString*)aToken {
    
    [self.userDefaults setObject:aToken forKey:@"DeviceToken"];
    [self saveSessionValues];
}

- (NSString *)getDeviceToken {
    
    NSString *aToken = [self.userDefaults valueForKey:@"DeviceToken"];
    
    if ([aToken length] == 0)
        aToken = @"";
    
    return aToken;
}

#pragma mark -User LoggedIn Status

- (void)hasLoggedIn:(BOOL)aLoggedIn {
    
    [self.userDefaults setBool:aLoggedIn forKey:@"LoggedIn"];
    [self saveSessionValues];
}

- (BOOL)hasLoggedIn {
    
    return [self.userDefaults boolForKey:@"LoggedIn"];
}

#pragma mark User Id

- (void)setUserId:(NSString*)value
{
    [self.userDefaults setObject:value forKey:@"user_id"];
    [self saveSessionValues];
}

- (NSString *)getUserId
{
    NSString *aStr = [self.userDefaults valueForKey:@"user_id"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}


#pragma mark - Practice Id

- (void)setPacticeId:(NSString*)value
{
    [self.userDefaults setObject:value forKey:@"practice_id"];
    [self saveSessionValues];
}

- (NSString *)getPacticeId
{
    NSString *aStr = [self.userDefaults valueForKey:@"practice_id"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}

#pragma mark - OnBoard Practice Id

- (void)setOnBoardPacticeId:(NSString*)value
{
    [self.userDefaults setObject:value forKey:@"on_board_practice_id"];
    [self saveSessionValues];
}

- (NSString *)getOnBoardPacticeId
{
    NSString *aStr = [self.userDefaults valueForKey:@"on_board_practice_id"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}

#pragma mark - Practice Name

- (void)setPacticeName:(NSString*)value
{
    [self.userDefaults setObject:value forKey:@"practice_name"];
    [self saveSessionValues];
}

- (NSString *)getPacticeName
{
    NSString *aStr = [self.userDefaults valueForKey:@"practice_name"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}

#pragma mark - Practice Staff Email

- (void)setDashboardEmail:(NSString*)value
{
    [self.userDefaults setObject:value forKey:@"dashboard_email"];
    [self saveSessionValues];
}

- (NSString *)getDashboardEmail
{
    NSString *aStr = [self.userDefaults valueForKey:@"dashboard_email"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}

#pragma mark - Practice Zipcode

- (void)setPacticeZipcode:(NSString*)value
{
    [self.userDefaults setObject:value forKey:@"practice_zipcode"];
    [self saveSessionValues];
}

- (NSString *)getPacticeZipcode
{
    NSString *aStr = [self.userDefaults valueForKey:@"practice_zipcode"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}


#pragma mark - AccessToken

- (void)setAccessToken:(NSString*)value
{
    [self.userDefaults setObject:value forKey:@"access_token"];
    [self saveSessionValues];
}

- (NSString *)getAccessToken
{
    NSString *aStr = [self.userDefaults valueForKey:@"access_token"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}


#pragma mark - Refresh Token

- (void)setRefreshToken:(NSString*)value
{
    [self.userDefaults setObject:value forKey:@"refresh_token"];
    [self saveSessionValues];
}

- (NSString *)getRefreshToken
{
    NSString *aStr = [self.userDefaults valueForKey:@"refresh_token"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}

#pragma mark - Email Id -

- (void)setEmailId:(NSString*)emailId
{
    [self.userDefaults setObject:emailId forKey:@"email_id"];
    [self saveSessionValues];
}

- (NSString *)getEmailId
{
    NSString *aStr = [self.userDefaults valueForKey:@"email_id"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}

#pragma mark - PushNotificationPatientInfo -

- (void)setPushDetailsPatientCashInfo:(NSDictionary*)patientCashInfo {
    
    [self.userDefaults setObject:patientCashInfo forKey:@"patient_info"];
    [self saveSessionValues];
}

- (NSDictionary *)getPushDetailsPatientCashInfo {
    
    NSDictionary *aDictInfo = [self.userDefaults valueForKey:@"patient_info"];
    return aDictInfo;
}

#pragma mark - Payment Plan Button Enable -

- (void)setFullPaymentButtonEnable:(BOOL)aBool {
    
    [self.userDefaults setBool:aBool forKey:@"full_button_enable"];
    [self saveSessionValues];
}

- (BOOL)isFullPaymentButtonEnable {
    
    return [self.userDefaults boolForKey:@"full_button_enable"];
}

- (void)setEnrollPaymentButtonEnable:(BOOL)aBool {
    
    [self.userDefaults setBool:aBool forKey:@"enroll_button_enable"];
    [self saveSessionValues];
}

- (BOOL)isEnrollPaymentButtonEnable {
    
    return [self.userDefaults boolForKey:@"enroll_button_enable"];
}

// Set Mute/Unmute Button Value
-(void)setMuteUnMuteButtonValue:(NSString*)buttonName {
    
    [self.userDefaults setValue:buttonName forKey:@"muteButtonName"];
    [self saveSessionValues];
}

- (NSString *)getMuteButtonName
{
    NSString *aStr = [self.userDefaults valueForKey:@"muteButtonName"];
    
    if ([aStr length] == 0)
        aStr = @"";
    
    return aStr;
}
@end
