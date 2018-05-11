//
//  Util.h
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Config.h"
#import "AFNetworking.h"
#import "NetworkAlert.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AlertMessage.h"
#import "Reachability.h"
#import "TTTAttributedLabel.h"
#import "ImageSlider.h"
#import "VideoPlayer.h"
#import "ZoomImage.h"
#import "MBCircularProgressBarView.h"
#import <AVKit/AVKit.h>
#import "SDAVAssetExportSession.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>


//@import AssetsLibrary;
//@import Photos;

@interface Util : NSObject{
    NSURLSessionConfiguration *dataTaskConfiguration;
    Reachability* reachability;    
    UIView *viewContainer,*zoomWindow,*zoomWindowBG;
    BOOL isImageZoom;
    BOOL notYou;
}

@property (nonatomic,strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) NSString *isNetworkShow, *playedMediaId;
@property (nonatomic, strong) NSMutableArray *KLCPopupArray;
@property(nonatomic, strong) AFURLSessionManager *dataTaskManager, *httpFileTaskManager, *httpMultiFileTaskManager;
@property (strong, atomic) ALAssetsLibrary* library;

//Callback blocks
typedef void (^CompletionBlock)(NSDictionary *);
typedef void (^CompletionBlockWithError)(NSDictionary *,NSError *);
typedef void (^getAssetData)(NSData *);
typedef void (^getAssetFromUrl)(NSData *,UIImage *);
typedef void (^getOrigianlAssetFromUrl)(NSData *,UIImage *, NSString *url);
typedef void (^CompletionBlockWithAsset)(PHAsset *);
typedef void (^CompletionBlockWithAssetUrl)(NSURL *);

//Class methods
+ (instancetype)sharedInstance;
+ (void)saveImageToAlbum:(UIImage *)image withCompletionBlock:(CompletionBlockWithAsset)callback;
+ (void)saveVideoToAlbum:(NSURL *)url withCompletionBlock:(CompletionBlockWithAsset)callback;

+ (void)compressVideo:(NSURL *)url withCallback:(CompletionBlockWithAssetUrl)callback;

+ (UIAlertController *)createSettingsAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

+ (UIImage *)convertColorToImage:(UIColor *)color byDivide:(int)divider withHeight:(int)height;
+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius;
+ (CGSize) getWindowSize;
+ (void) monitorTheNetworkState;
+ (NSString *) getFromDefaults : (NSString *) keyValue;
+ (void) setInDefaults:(id)config withKey:(NSString *) key;
+ (void) deleteFromDefaults:(NSString *)key;
+ (void) setDefaultLanguage;
+ (void) createBottomLine:(UIView *) view withColor:(UIColor  *) color;
+ (void) createTopLine:(UIView *) view withColor:(UIColor  *) color;
+ (void) createRoundedCorener:(UIView *)view withCorner:(float)corner;
+ (BOOL) validateTextField:(id)uiElement withValueToDisplay:(NSString *)fieldName withIsEmailType:(BOOL)isEmail withMinLength:(int)minLength withMaxLength:(int)maxLength;
+ (BOOL) validatePasswordField:(id)uiElement withValueToDisplay:(NSString *)fieldName withMinLength:(int)minLength withMaxLength:(int)maxLength;
+ (BOOL) validateNumberField:(id)uiElement withValueToDisplay:(NSString *)fieldName withMinLength:(int)minLength withMaxLength:(int)maxLength;
+ (BOOL) validCharacter:(id)uiElement forString:(NSString *)inputString withValueToDisplay:(NSString *)fieldName;
+ (BOOL) validateName:(NSString *) name;
+ (void) showErrorMessage:(UIView *)viewElement withErrorMessage:(NSString *)message;
+ (UIImage*)resizeProfileImage:(UIImage*)image;
+ (MBProgressHUD *)showLoading;
+ (void)hideLoading:(MBProgressHUD *)loader;
+ (void) makeCircularImage :(UIView *) view withBorderColor:(UIColor  *) color;
+ (void)createDropShadow:(UIView *) view;
+ (void)highlightHashtagsInLabel:(TTTAttributedLabel *)attributedLabel;
+ (void) setAddMoreTextForLabel :(TTTAttributedLabel *) forLabel endsWithString:(NSString *) endString forlength:(int) charLength forColor:(UIColor *) textColor;
+ (void) setHyperlinkForLabel :(TTTAttributedLabel *) forLabel forText:(NSString *) hyperLinkText destinationURL:(NSString *) URL forColor:(UIColor *) textColor;
+ (void) setPadding :(UITextField *) textField;
+ (NSString *)timeStamp :(long)getTime;
+ (NSString *)getDate :(long)getTime;
+ (void)addEmptyMessageToTable:(UITableView *)tableView withMessage:(NSString *)message withColor:(UIColor *)color;
+ (void)addEmptyMessageToCollection:(UICollectionView *)collectionView withMessage:(NSString *)message withColor:(UIColor *)color;
+ (UIImage *)getImageForPrivacyType:(int)type;
+ (int)getMatchedObjectPosition:(NSString *)keyString valueToMatch:(NSString *)value from:(NSMutableArray *)source type:(int)type;
+ (NSString *) randomStringWithLength: (int) len;
+ (NSString *)timeAgo :(NSString *) timeStamp;
+ (void)showSlider:(UIViewController *)controller forImage:(NSMutableArray *)imageData atIndex:(NSUInteger)index;
+ (void)playVideo:(UIViewController *)controller forUrl:(NSString *)url;
+ (void) createBorder:(UIView *)view withColor:(UIColor  *)color;
+ (void) createBorder:(UIView *)view withColor:(UIColor  *)color setBorderSize:(float)borderSize;
+ (void)addEmptyMessageToTableWithHeader:(UITableView *)tableView withMessage:(NSString *)message withColor:(UIColor *)color;
+ (UIImage *)imageForFeed:(int)feedId withType:(NSString *)imageType;
+ (void)setUpFloatIcon:(UIButton *)button;
+ (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
+ (UIImage *)convertColorToImageWithSize:(UIColor *)color width:(float)width height:(float)height;
+ (CGSize)getAspectRatio:(NSString *)dimension ofParentWidth:(float)parentWidth;
+ (NSString *)playerType :(int)typeId playerRank:(NSString *)rank;
+ (void) createTeamActivityLabel:(TTTAttributedLabel *) forLabel fromValues:(NSDictionary *)values;
+ (void) makeAsLink:(TTTAttributedLabel *)label withColor:(UIColor *)linkColor showUnderLine:(BOOL) underLine range:(NSRange )range;
+ (NSString *)getOriginalImageUrl:(NSString *)imageThumbUrl;
+ (void) addImageBlurEffect:(UIImageView *)imageView;
+ (void)removeUserData;
+ (BOOL) checkLanguageIsEnglish;
+ (BOOL) getBoolFromDefaults:(NSString *)key;
+ (BOOL) validateLocationField:(id)uiElement withValueToDisplay:(NSString *)fieldName withIsEmailType:(BOOL)isEmail withMinLength:(int)minLength withMaxLength:(int)maxLength;
+ (NSMutableAttributedString *)feedsHeaderName :(NSString *)nameValue desc:(NSString *)postDescription;
+ (NSString *)getChatHistoryTime :(NSString *) timeStamp;
+ (NSString *)getChatHistoryDate :(NSString *) timeStamp;
+ (void)setPointsIconText:(UIButton *)button withSize:(int)size;
+(void)scrollToTop:(UITableView *)tableView fromArrayList:(NSMutableArray *)array;
+ (NSString *)getTime :(NSString *)timestamp;
+(BOOL) isTeamPresent:(NSString *)teamId;
+(UIImage *) deletedImages :(NSString *)mediaUrl;
+(NSString *)getViewsString:(long)viewCount;

//Socket
+ (NSString *) buildDataToSend:(NSString *)type withBody:(NSMutableDictionary *)body;
+ (NSMutableDictionary *) convertStringToDictionary:(NSString *)string;
+ (void) setProgressWithAnimation:(UIProgressView *)progressView withDuration:(int)duration;
+ (MBProgressHUD *)showLoadingWithTitle:(NSString *)title;
+ (void) setHyperlinkForLabelWithUnderline :(TTTAttributedLabel *) forLabel forText:(NSString *) hyperLinkText destinationURL:(NSString *) URL forColor:(UIColor *) textColor;
+ (BOOL)checkLocationIsEnabled;
+ (NSString *)getGoogleApiKey;
+ (NSString *)getBiaduApiKey;
+ (void)appendDeviceMeta:(NSMutableDictionary *)params;
+ (BOOL)checkoutNotificationStatus;
+(NSString *)playerTypeInProfilePage :(int)typeId playerRank:(NSString *)rank;
+ (NSString *)imageToNSString:(UIImage *)image;
+ (UIImage *)stringToUIImage:(NSString *)string;
+ (UIImage *)addBlurEffect:(UIImage *)originalImage;
+ (void)showSliderForChat:(UIViewController *)controller forImage:(NSMutableArray *)imageData atIndex:(NSUInteger)index withTitle:(NSString *)name;
+ (NSString *)getAppVersion;
+ (NSString *)getBuildNumber;
+ (UIImage *) resizeTheImage:(UIImage *)originalImage;

//Instance methods
- (void) animateTheImage:(UIImageView *)imageView withHeight:(float) height;
- (NSURLSessionDataTask *) sendHTTPPostRequest:(NSMutableDictionary *) params withRequestUrl:(NSString *) url withCallBack:(CompletionBlock)callback isShowLoader:(BOOL) show;
- (NSURLSessionUploadTask *) sendHTTPPostRequestWithImage:(NSMutableDictionary *) params withRequestUrl:(NSString *) url withImage:(NSData *)imageFile withFileName:(NSString *)fileName  withCallBack:(CompletionBlock)callback   onProgressView:(UIProgressView *)progressView withExtension:(NSString *)extension ofType:(NSString *)type;
- (NSURLSessionUploadTask *) sendHTTPPostRequestWithMultiPart:(NSMutableDictionary *) params withMultiPart:(NSMutableArray *)multiPart withRequestUrl:(NSString *) url withImage:(UIImageView *)imageFile withCallBack:(CompletionBlock)callback onProgressView:(UIProgressView *)progressView isFromBuzzardRun:(BOOL)isFromBuzzardRun;
- (NSURLSessionDataTask *) sendHTTPGetRequest:(NSString *)url withCallBack:(CompletionBlock)callback isShowLoader:(BOOL) show;
- (NSURLSessionDataTask *) sendHTTPPostRequestWithError:(NSMutableDictionary *) params withRequestUrl:(NSString *) url withCallBack:(CompletionBlockWithError)callback isShowLoader:(BOOL) show;

- (UIImage *)getThumbFromVideo:(NSString *)url;

- (void)monitorNetwork;
- (void)resentEmail;
- (void)checkMediaHasValidSize:(BOOL)isPhoto ofMediaUrl:(NSString *)mediaUrl withCallBack:(getAssetFromUrl)callback;
- (BOOL)checkMediaHasValidFormat:(BOOL)isPhoto ofMediaUrl:(NSString *)mediaUrl;
- (void)checkFileHasValidSize:(BOOL)isPhoto ofMediaUrl:(NSString *)mediaUrl withCallBack:(getAssetFromUrl)callback;
- (BOOL)checkFileHasValidFormat:(BOOL)isPhoto ofMediaUrl:(NSString *)mediaUrl;
- (void)showLocationAlert;
- (void)showInAppAlert;
- (void)showGalleryAlert;
- (void)addImageZoom:(UIImageView *)imageView;
- (void)zoomImageView:(UIImageView *)imageView;
- (BOOL)getNetWorkStatus;
- (void)compressVideo:(NSString *)videoURL  isCaptured:(BOOL)isCaptured toPass:(getAssetFromUrl)callback withSize:(NSNumber *)mediaSize withImage:(UIImage *)thumbImage;
- (UIView *)drawArrowwithxCord:(float)xCord yCord:(float)yCord;
- (void)resetNotificationCount:(int)type;
- (AVPlayer *)playVideo:(NSString *)mediaUrl withThumb:(UIImage *)thumbImg fromController:(UIViewController *)controller withUrl:(NSString *)thumbUrl;
- (void)increaseViewCount:(NSString *)mediaId;

+(NSString *)getStarString:(long)sCount;
+(NSString *)getCommentsString:(long)cComment;
+(MBCircularProgressBarView *)designdownloadProgress :(MBCircularProgressBarView *)downloadProgress;
+ (void)preloadImageFromUrl:(NSString *)url;
+(void)setStatusBar;
+ (BOOL) isVideoMinimumtwoMins :(NSURL *)videoUrl;
+(NSString*)getDeviceModel:(NSString *)platform;

+ (void)compressVideo:(AVAsset *)video withMaxSize:(NSNumber *)mediaSize andCallback:(getAssetData)callback;


+(NSString *)getBaseUrl;
+(NSString *)getShopUrl;
+(NSString *)getShopHost;
+(NSString *)getChatUrl;



@end
