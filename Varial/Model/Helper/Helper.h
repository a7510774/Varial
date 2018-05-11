//
//  Helper.h
//  YosiMDPayment
//
//  Created by Guru Prasad chelliah on 9/20/17.
//
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (Helper *)sharedObject;

#pragma mark - Color and Image
- (UIColor *)getColorFromHexaDecimal:(NSString *)hexaDecimal;
- (UIColor *)getColorFromHexaDecimal:(NSString *)hexaDecimal alpha:(float)alpha;
- (UIImage *)getImageFromColor:(UIColor *)color;
- (void)setBackgroundImageFor:(UIViewController *)controller imageNamed:(NSString *)imageName;
-(UIImageView *)imageWithRenderingMode:(NSString *)imageName color:(UIColor *)aColor imageView:(UIImageView *)aImageView;
- (void)setURLProfileImageForImageView:(UIImageView*)aImageView URL:(NSString*)aURLString placeHolderImage:(NSString*)aPlaceHolderImageString;
- (UIButton *)imageWithRenderingModeWithButton:(NSString *)imageName color:(UIColor *)aColor button:(UIButton *)aButton;
-(UIImage *)makeBlurImage:(UIImage *)aImage;
- (UIColor*)getColorForRating:(float)aRatingFloat;

#pragma mark - Loading
- (void)showLoadingAnimation;
- (void)removeLoadingAnimation;

#pragma mark - Date
- (NSString *)getCurrentDateInFormat:(NSString *)format;
- (NSString *)getConvertedDateFormatFrom:(NSString *)oldFormat to:(NSString *)newFormat forDateTime: (NSString *)dateTime;
- (NSString *)getNextDateFrom:(NSString *)dateTime inFormat:(NSString *)dateFormat daysCount :(NSInteger)daysCount;
- (NSString *)converDateFormatFrom:(NSString *)oldFormat to:(NSString *)newFormat dateTime: (NSString *)dateTime;
- (NSString *)getConvertedDateFormatFrom:(NSString *)oldFormat to:(NSString *)newFormat forDate: (NSDate *)date;
- (NSDate *) addingDays:(int)days date:(NSDate *)date;
- (NSDate *)getConvertedDateStringFormatFrom:(NSString *)oldFormat to:(NSString *)newFormat forDate: (NSDate *)date;
- (NSString*)getCurrentYear;

#pragma mark - TSMessage Notification Alert
- (void)showNotificationErrorIn:(UIViewController*)controller withMessage:(NSString*)message;
- (void)showNotificationSuccessIn:(UIViewController*)controller withMessage:(NSString*)message;
- (void)showNotificationInfoIn:(UIViewController*)controller withMessage:(NSString*)message;
- (void)showNotificationWarningIn:(UIViewController*)controller withMessage:(NSString*)message;
- (void)showFBStyleErrorAlertIn:(UIViewController*)controller withMessage:(NSString*)message;


#pragma mark - change root View
- (void)changeRootViewController:(UIViewController*)viewController scaleIn:(BOOL)shouldScaleIn;


#pragma mark - Utilities
- (BOOL)isDigit:(NSString*)text;
- (BOOL)isPhoneNumber:(NSString*)text;
- (NSString *) getAppVersion;
- (NSString *) getBuild;
- (NSString *) getVersionBuild;
- (NSString *)prefixWithWhiteSpaceForText:(NSString*)aTextString numberOfWhileSpace:(int)aNumberOfWhileSpaceInt;
- (void)changeRootViewController:(UIViewController*)viewController;

#pragma mark - Rounded Corner View
- (void)roundCornerForView:(UIView*)view radius:(float)radius borderColor:(UIColor*)color borderWidth:(float)aFltWidth;
- (void)roundCornerForView:(UIView*)view andBorderColor:(UIColor*)color;
- (void)roundCornerForView:(UIView*)view withRadius:(float)radius;
- (void)roundCornerForView:(UIView*)view;


#pragma mark - Drop Shadow
- (void)addDropShadowToView:(UIView*)aView;
- (void)addDropShadowToView:(UIView*)aView withShadowColor:(UIColor*)aColor;
- (void)addDropShadowToView:(UIView*)aView cornerRadius:(float)aRadius;
- (void)addDropShadowToView:(UIView*)aView withShadowColor:(UIColor*)aColor cornerRadius:(float)aRadius;
- (void)addDropShadowToTableview:(UITableView *)aTableView;
- (void)addFloatingEffectToView:(UIView *)aView;


#pragma Alert View

- (void)showAlertView:(UIViewController*)aViewController title:(NSString *)aTitle;
- (void)showAlertViewWithCancel:(UIViewController*)aViewController title:(NSString *)aTitle okButtonBlock:(void (^)(UIAlertAction *action))okAction cancelButtonBlock:(void (^)(UIAlertAction * action))cancelAction ;

//Action Sheet

- (void)showAlertControllerIn:(UIViewController *)aViewController title:(NSString *)aTitle message:(NSString *)aMessage defaultFirstButtonTitle:(NSString *)aFirstButtonTitle defaultFirstActionBlock:(void (^)(UIAlertAction *action))aFirstActionBlock defaultSecondButtonTitle:(NSString *)aSecondButtonTitle defaultSecondActionBlock:(void (^)(UIAlertAction *action))aSecondActionBlock cancelButtonTitle:(NSString *)aCancelButtonTitle cancelActionBlock:(void (^)(UIAlertAction *action))aCancelActionBlock ;


#pragma mark - Project Oriented Methods

#pragma mark - Animation

- (void)fadeAnimationFor:(UIView*)aView alpha:(float)aAlphaValue duration:(float)aDurationFloat;
- (void)fadeAnimationFor:(UIView*)aView alpha:(float)aAlphaValue;
- (void)addBubbleEffectForView:(UIView *)aView;
- (void)rotateAnimationFor:(UIView *)aView rotateInfiniteTime:(BOOL)isInfinite;
- (void)stopRotateAnimationFor:(UIView *)aView;
- (void)transitionAnimationFor:(UIView*)aView duration:(float)aDurationFloat withAnimationBlock:(void(^)())animationBlock;
- (void)transitionAnimationFor:(UIView*)aView withAnimationBlock:(void(^)())animationBlock ;
// Scale in-out Tap animation
- (void)tapAnimationFor:(UIView*)aView duration:(float)aDurationFloat withCallBack:(void (^)())callBack;
// Scale in-out Tap animation with default duration of 0.5
- (void)tapAnimationFor:(UIView*)aView withCallBack:(void (^)())callBack;


#pragma mark - Navigation controller
- (void)navigateToLoginScreen;
- (void)navigateToHomeScreen;
- (void)navigateToDisclaimerScreen;


#pragma mark - Toolbar

typedef enum : NSUInteger {
    ALIGN_LEFT,
    ALIGN_CENTER,
} TOOLBAR_TITLE_ALIGNMENT;

- (UIToolbar *)getToolbarWithTitle:(NSString *)aTitle target:(UIViewController *)aTarget titleAlignment:(TOOLBAR_TITLE_ALIGNMENT)aAlignment buttonTitle:(NSString *)aButtonTitle tag:(NSInteger)aTag;


#pragma mark - Alert View -

- (void)showAlertControllerIn:(UIViewController *)aViewController message:(NSString *)aMessage;
- (void)showAlertControllerIn:(UIViewController *)aViewController title:(NSString *)aTitle message:(NSString *)aMessage buttonTitle:(NSString *)aButtonTitle actionBlock:(void (^)(UIAlertAction *action))aActionBlock;

- (void)showAlertControllerIn:(UIViewController *)aViewController title:(NSString *)aTitle message:(NSString *)aMessage defaultButtonTitle:(NSString *)aDefaultButtonTitle defaultActionBlock:(void (^)(UIAlertAction *action))aDefaultActionBlock cancelButtonTitle:(NSString *)aCancelButtonTitle cancelActionBlock:(void (^)(UIAlertAction *action))aCancelActionBlock;


#pragma mark - Inertnet Connection

- (BOOL)isNetConnectionAvailable;
- (NSString *)getNoNetworkMessage;

- (NSDateFormatter *)requestDateFormatter;
- (NSString *) deviceTimeStamp;
- (UIViewController*)getTopMostController;

- (void)setURLProfileImageForImageView:(UIImageView*)aImageView URL:(NSString*)aURLString placeHolderImage:(NSString*)aPlaceHolderImageString;

@end
