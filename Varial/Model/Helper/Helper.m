//
//  Helper.m
//  YosiMDPayment
//
//  Created by Guru Prasad chelliah on 9/20/17.
//
//

#import "Helper.h"

@implementation Helper

+ (Helper *)sharedObject {
    
    static Helper *_sharedObject = nil;
    
    @synchronized (self) {
        if (!_sharedObject)
            _sharedObject = [[[self class] alloc] init];
    }
    
    return _sharedObject;
}

#pragma mark - Color and Image

- (UIColor *)getColorFromHexaDecimal:(NSString *)hexaDecimal {
    
    NSString *hexaDecimalColorCode = [[hexaDecimal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([hexaDecimalColorCode length] < 6) return [UIColor grayColor];
    
    if ([hexaDecimalColorCode hasPrefix:@"0X"]) hexaDecimalColorCode = [hexaDecimalColorCode substringFromIndex:2];
    
    if ([hexaDecimalColorCode length] != 6) return  [UIColor grayColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *strR = [hexaDecimalColorCode substringWithRange:range];
    
    range.location = 2;
    NSString *strG = [hexaDecimalColorCode substringWithRange:range];
    
    range.location = 4;
    NSString *strB = [hexaDecimalColorCode substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:strR] scanHexInt:&r];
    [[NSScanner scannerWithString:strG] scanHexInt:&g];
    [[NSScanner scannerWithString:strB] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (UIColor *)getColorFromHexaDecimal:(NSString *)hexaDecimal alpha:(float)alpha {
    
    NSString *hexaDecimalColorCode = [[hexaDecimal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([hexaDecimalColorCode length] < 6) return [UIColor grayColor];
    
    if ([hexaDecimalColorCode hasPrefix:@"0X"]) hexaDecimalColorCode = [hexaDecimalColorCode substringFromIndex:2];
    
    if ([hexaDecimalColorCode length] != 6) return  [UIColor grayColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *strR = [hexaDecimalColorCode substringWithRange:range];
    
    range.location = 2;
    NSString *strG = [hexaDecimalColorCode substringWithRange:range];
    
    range.location = 4;
    NSString *strB = [hexaDecimalColorCode substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:strR] scanHexInt:&r];
    [[NSScanner scannerWithString:strG] scanHexInt:&g];
    [[NSScanner scannerWithString:strB] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

- (UIImage *)getImageFromColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setBackgroundImageFor:(UIViewController *)controller imageNamed:(NSString *)imageName {
    
    UIGraphicsBeginImageContext(controller.view.frame.size);
    [[UIImage imageNamed:imageName] drawInRect:controller.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    controller.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha image: (UIImageView *)aImageView {
    
    UIGraphicsBeginImageContextWithOptions(aImageView.frame.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, aImageView.frame.size.width, aImageView.frame.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    //  CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)makeBlurImage:(UIImage *)aImage {
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    CIImage *inputImage = [CIImage imageWithCGImage:[aImage CGImage]];
    [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@15 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[inputImage extent]];  // note, use input image extent if you want it the same size, the output image extent is larger
    UIImage *image       = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return image;
}

#pragma mark - Navigation Animation

- (void) addAnimationFor:(UIViewController *)controller {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [controller.navigationController.view.layer addAnimation:transition forKey:nil];
}

#pragma mark - Loading

- (void)showLoadingAnimation {
    
    }

- (void)removeLoadingAnimation {
    
}

#pragma mark - Date

- (NSString *)getCurrentDateInFormat:(NSString *)format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return currentDate;
}

- (NSString *)getConvertedDateFormatFrom:(NSString *)oldFormat to:(NSString *)newFormat forDateTime: (NSString *)dateTime {
    
    NSString *convertedDateTime;
    
    if (dateTime.length == 10 && oldFormat.length == 0)
        dateTime = [NSString stringWithFormat:@"%@ 00:00:00", dateTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (oldFormat.length != 0)
        [dateFormatter setDateFormat:oldFormat];
    else
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *orignalDate = [dateFormatter dateFromString:dateTime];
    
    
    if (newFormat.length != 0)
        [dateFormatter setDateFormat:newFormat];
    else
        [dateFormatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    
    convertedDateTime = [dateFormatter stringFromDate:orignalDate];
    
    return convertedDateTime;
}

- (NSString *)getConvertedDateFormatFrom:(NSString *)oldFormat to:(NSString *)newFormat forDate: (NSDate *)date {
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    if (oldFormat.length != 0)
        [dateFormatter setDateFormat:oldFormat];
    else
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (newFormat.length != 0) {
        [dateFormatter setDateFormat:newFormat];
    }
    else
        [dateFormatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    
    return [dateFormatter stringFromDate:date];
}

- (NSDate *)getConvertedDateStringFormatFrom:(NSString *)oldFormat to:(NSString *)newFormat forDate: (NSDate *)date {
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    if (oldFormat.length != 0)
        [dateFormatter setDateFormat:oldFormat];
    else
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (newFormat.length != 0) {
        [dateFormatter setDateFormat:newFormat];
    }
    else
        [dateFormatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    
    return [dateFormatter dateFromString: [dateFormatter stringFromDate:date]];
}


- (NSString *)getNextDateFrom:(NSString *)dateTime inFormat:(NSString *)dateFormat daysCount :(NSInteger)daysCount {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [NSDateComponents new];
    components.day = daysCount;
    NSDate *nextDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (dateFormat.length != 0)
        [dateFormatter setDateFormat:dateFormat];
    else
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedNextDate = [dateFormatter stringFromDate:nextDate];
    
    return formattedNextDate;
}


- (NSString *)converDateFormatFrom:(NSString *)oldFormat to:(NSString *)newFormat dateTime: (NSString *)dateTime
{
    NSString *aStrDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:oldFormat];
    NSDate *orignalDate = [dateFormatter dateFromString:dateTime];
    
    [dateFormatter setDateFormat:newFormat];
    aStrDate = [dateFormatter stringFromDate:orignalDate];
    
    return aStrDate;
}

- (NSDate *) addingDays:(int)days date:(NSDate *)date {
    
    NSDate *retVal;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    retVal= [gregorian dateByAddingComponents:components toDate:date options:0];
    
    return retVal;
}

- (NSString *)getCurrentYear {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    
    return yearString;
}



#pragma mark - Drop Shadow

- (void)addDropShadowToView:(UIView*)aView {
    [self addDropShadowToView:aView withShadowColor:[UIColor blackColor] cornerRadius:0.0];
}

- (void)addDropShadowToView:(UIView*)aView withShadowColor:(UIColor*)aColor {
    
    [self addDropShadowToView:aView withShadowColor:aColor cornerRadius:0.0];
}

- (void)addDropShadowToView:(UIView*)aView cornerRadius:(float)aRadius {
    
    [self addDropShadowToView:aView withShadowColor:[UIColor blackColor] cornerRadius:aRadius];
}

- (void)addDropShadowToView:(UIView*)aView withShadowColor:(UIColor*)aColor cornerRadius:(float)aRadius {
    
    // Add drop shadow to created view
    aView.layer.masksToBounds = NO;
    aView.layer.shadowColor = aColor.CGColor;
    aView.layer.shadowOffset = CGSizeMake(0.0f, 0.2f);
    aView.layer.shadowOpacity = 0.6f;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:aView.bounds cornerRadius:aRadius];
    aView.layer.shadowPath = shadowPath.CGPath;
}

- (void)addFloatingEffectToView:(UIView *)aView {
    
    [self roundCornerForView:aView];
    [self addDropShadowToView:aView cornerRadius:CGRectGetWidth(aView.bounds) * 0.5];
}

- (void)addDropShadowToTableview:(UITableView *)aTableView {
    
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    sublayer.shadowOffset = CGSizeMake(0, -3);
    sublayer.shadowRadius = 5.0;
    sublayer.shadowColor = [UIColor blackColor].CGColor;
    sublayer.shadowOpacity = 1.0;
    sublayer.cornerRadius = 5.0;
    sublayer.frame = CGRectMake(aTableView.frame.origin.x, aTableView.frame.origin.y, aTableView.frame.size.width, aTableView.frame.size.height);
    [aTableView.superview.layer addSublayer:sublayer];
    
    [aTableView.superview.layer addSublayer:aTableView.layer];
    
}

- (UIImageView *)imageWithRenderingMode:(NSString *)imageName color:(UIColor *)aColor imageView:(UIImageView *)aImageView {
    
    UIImage *aEventImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    aImageView.image = aEventImage;
    [aImageView setTintColor:aColor];
    
    return aImageView;
}

- (UIButton *)imageWithRenderingModeWithButton:(NSString *)imageName color:(UIColor *)aColor button:(UIButton *)aButton {
    
    UIImage *aEventImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [aButton setImage:aEventImage forState:UIControlStateNormal];
    
    [aButton.imageView setTintColor:aColor];
    
    return aButton;
}

- (void)changeRootViewController:(UIViewController*)viewController {
    
//    if (!APPDELEGATE.window.rootViewController) {
//        APPDELEGATE.window.rootViewController = viewController;
//        return;
//    }
//
//    UIView *snapShot = [APPDELEGATE.window snapshotViewAfterScreenUpdates:YES];
//
//    [viewController.view addSubview:snapShot];
//
//    APPDELEGATE.window.rootViewController = viewController;
//
//    [UIView animateWithDuration:0.5 animations:^{
//        snapShot.layer.opacity = 0;
//    } completion:^(BOOL finished) {
//        [snapShot removeFromSuperview];
//    }];
}

#pragma mark - Rounded Corner View

- (void)roundCornerForView:(UIView*)view radius:(float)radius borderColor:(UIColor*)color borderWidth:(float)aFltWidth {
    
    view.layer.cornerRadius = radius;
    view.layer.borderWidth = aFltWidth;
    view.layer.borderColor = color.CGColor;
    view.clipsToBounds = YES;
}

- (void)roundCornerForView:(UIView*)view andBorderColor:(UIColor*)color {
    
    [self roundCornerForView:view radius:CGRectGetHeight(view.frame) * 0.5 borderColor:color borderWidth:0.0];
}

- (void)roundCornerForView:(UIView*)view withRadius:(float)radius {
    
    [self roundCornerForView:view radius:radius borderColor:[UIColor clearColor] borderWidth:0.0];
}

- (void)roundCornerForView:(UIView*)view {
    
    [self roundCornerForView:view radius:CGRectGetHeight(view.frame) * 0.5 borderColor:[UIColor clearColor] borderWidth:0.0];
}


#pragma mark - UIRefreshControl

- (void)setAttributedTextToRefreshController:(UIRefreshControl *)refreshControl message :(NSString *)message
{
    NSString *aStrMsg;
    
    /* if ([message isEqualToString:KEY_FIRSTTIME]) {
     
     aStrMsg = @"Loading..";
     }
     else {
     
     aStrMsg = message.length != 0 ? [NSString stringWithFormat:@"Last updated: %@", [RTCHELPER convertDateTimeFormatForUI:message]] : @"Loading..";
     }*/
    
    NSDictionary *aDictAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor grayColor],NSForegroundColorAttributeName, [UIFont systemFontOfSize:11], NSFontAttributeName, nil];
    
    NSAttributedString *aAttributedString = [[NSAttributedString alloc] initWithString:message attributes:aDictAttributes];
    
    refreshControl.attributedTitle = aAttributedString;
}

- (void)showAlertView:(UIViewController*)aViewController title:(NSString *)aTitle  {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:APP_NAME
                                  message:aTitle preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * Ok = [UIAlertAction
                          actionWithTitle:@"Ok"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              /*[aViewController dismissViewControllerAnimated:YES completion:^{
                               
                               }];*/
                          }];
    [alert addAction:Ok];
    
    [aViewController presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertViewWithCancel:(UIViewController*)aViewController title:(NSString *)aTitle okButtonBlock:(void (^)(UIAlertAction *action))okAction cancelButtonBlock:(void (^)(UIAlertAction * action))cancelAction {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:APP_NAME
                                  message:aTitle preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * Ok = [UIAlertAction
                          actionWithTitle:@"Ok"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              if (okAction)
                                  okAction(action);
                          }];
    UIAlertAction * cancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * action)
                              {
                                  if (cancelAction)
                                      cancelAction(action);
                              }];
    [alert addAction:Ok];
    [alert addAction:cancel];
    
    [aViewController presentViewController:alert animated:YES completion:nil];
}

#pragma MARK - UIACTION VIEW -

- (void)showAlertControllerIn:(UIViewController *)aViewController title:(NSString *)aTitle message:(NSString *)aMessage defaultFirstButtonTitle:(NSString *)aFirstButtonTitle defaultFirstActionBlock:(void (^)(UIAlertAction *action))aFirstActionBlock defaultSecondButtonTitle:(NSString *)aSecondButtonTitle defaultSecondActionBlock:(void (^)(UIAlertAction *action))aSecondActionBlock cancelButtonTitle:(NSString *)aCancelButtonTitle cancelActionBlock:(void (^)(UIAlertAction *action))aCancelActionBlock {
    
    UIAlertController *aAlertController = [UIAlertController alertControllerWithTitle:aTitle message:aMessage preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *aFirsttButtonAction = [UIAlertAction actionWithTitle:aFirstButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (aFirstActionBlock) {
            aFirstActionBlock(action);
        }
        
    }];
    UIAlertAction *aSecondButtonAction = [UIAlertAction actionWithTitle:aSecondButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (aSecondActionBlock) {
            aSecondActionBlock(action);
        }
        
    }];
    
    
    UIAlertAction *aCancelButtonAction = [UIAlertAction actionWithTitle:aCancelButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if (aCancelActionBlock) {
            aCancelActionBlock(action);
        }
        
    }];
    
    [aAlertController addAction:aFirsttButtonAction];
    [aAlertController addAction:aSecondButtonAction];
    [aAlertController addAction:aCancelButtonAction];
    
    [aViewController presentViewController:aAlertController animated:YES completion:nil];
}

#pragma mark - Project Oriented Methods

#pragma mark - Animation -

// Fade in-out animation
- (void)fadeAnimationFor:(UIView*)aView alpha:(float)aAlphaValue duration:(float)aDurationFloat {
    
    [UIView animateWithDuration:aDurationFloat delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        aView.alpha = aAlphaValue;
        
    } completion:^(BOOL finished) {
        
    }];
}

// Fade in-out animation with default duration of 0.3
- (void)fadeAnimationFor:(UIView*)aView alpha:(float)aAlphaValue {
    
    [self fadeAnimationFor:aView alpha:aAlphaValue duration:0.5];
}

- (void)addBubbleEffectForView:(UIView *)aView {
    
    aView.layer.cornerRadius = aView.frame.size.width / 2;
    
    //create an animation to follow a circular path
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //interpolate the movement to be more smooth
    pathAnimation.calculationMode = kCAAnimationPaced;
    //apply transformation at the end of animation (not really needed since it runs forever)
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    //run forever
    pathAnimation.repeatCount = INFINITY;
    //no ease in/out to have the same speed along the path
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 5.0;
    
    int deltaHeight = CGRectGetHeight(aView.frame) * 0.55;
    int inset = [self getRandowNumberBetween:deltaHeight max:deltaHeight + 5];
    //The circle to follow will be inside the circleContainer frame.
    //it should be a frame around the center of your view to animate.
    //do not make it to large, a width/height of 3-4 will be enough.
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = CGRectInset(aView.frame, inset, inset);
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    //add the path to the animation
    pathAnimation.path = curvedPath;
    
    //release path
    CGPathRelease(curvedPath);
    //add animation to the view's layer
    [aView.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
    
    
    //create an animation to scale the width of the view
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    //set the duration
    scaleX.duration = [self randomFloat:1.5 max:2.5];
    //it starts from scale factor 1, scales to 1.05 and back to 1
    scaleX.values = @[@1.0, @1.05, @1.0];
    //time percentage when the values above will be reached.
    //i.e. 1.05 will be reached just as half the duration has passed.
    scaleX.keyTimes = @[@0.0, @0.5, @1.0];
    //keep repeating
    scaleX.repeatCount = INFINITY;
    //play animation backwards on repeat (not really needed since it scales back to 1)
    scaleX.autoreverses = YES;
    //ease in/out animation for more natural look
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //add the animation to the view's layer
    [aView.layer addAnimation:scaleX forKey:@"scaleXAnimation"];
    
    //create the height-scale animation just like the width one above
    //but slightly increased duration so they will not animate synchronously
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.duration = 1.5;
    scaleY.values = @[@1.0, @1.05, @1.0];
    scaleY.keyTimes = @[@0.0, @0.5, @1.0];
    scaleY.repeatCount = INFINITY;
    scaleY.autoreverses = YES;
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [aView.layer addAnimation:scaleY forKey:@"scaleYAnimation"];
    
}

//! View Transition Animation (Text change, color change etc). Cross Dissolve animation
- (void)transitionAnimationFor:(UIView*)aView duration:(float)aDurationFloat withAnimationBlock:(void(^)())animationBlock {
    [UIView transitionWithView:aView duration:aDurationFloat options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent animations:^{
        animationBlock();
    } completion:nil];
}

- (void)rotateAnimationFor:(UIView *)aView rotateInfiniteTime:(BOOL)isInfinite {
    
    if ([aView.layer animationForKey:@"SpinAnimation"] == nil) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.duration = 2.0;
        animation.repeatCount = isInfinite ? INFINITY : 1;
        [aView.layer addAnimation:animation forKey:@"SpinAnimation"];
    }
}

- (void)stopRotateAnimationFor:(UIView *)aView {
    
    [aView.layer removeAnimationForKey:@"SpinAnimation"];
}

- (int)getRandowNumberBetween:(int)min max:(int)max {
    
    return rand() % (max - min ) + min;
}

- (float)randomFloat:(float)min max:(float)max {
    
    return ((arc4random()%RAND_MAX) / (RAND_MAX*1.0)) * (max - min) + min;
}

#pragma mark - View Tap Animation

// Scale in-out Tap animation
- (void)tapAnimationFor:(UIView*)aView duration:(float)aDurationFloat withCallBack:(void (^)())callBack {
    [UIView animateKeyframesWithDuration:aDurationFloat delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        // Zoom out
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:aDurationFloat / 2 animations:^{
            
            aView.transform = CGAffineTransformScale(aView.transform, 0.9, 0.9);
            
        }];
        
        // Back to orginal size
        [UIView addKeyframeWithRelativeStartTime:aDurationFloat / 2 relativeDuration:aDurationFloat / 2 animations:^{
            
            aView.transform = CGAffineTransformIdentity;
            
        }];
        
    } completion:^(BOOL finished) {
        if(finished) {
            if (callBack) {
                callBack();
            }
        }
    }];
}

//! View Transition Animation (Text change, color change etc) with default 0.2 duration
- (void)transitionAnimationFor:(UIView*)aView withAnimationBlock:(void(^)())animationBlock {
    
    [self transitionAnimationFor:aView duration:0.2 withAnimationBlock:animationBlock];
    
}

// Scale in-out Tap animation with default duration of 0.5
- (void)tapAnimationFor:(UIView*)aView withCallBack:(void (^)())callBack {
    [self tapAnimationFor:aView duration:0.5 withCallBack:callBack];
}


#pragma MARK - GRADIENT COLOUR

-(void)setGradientColourToView:(UIView *)aView startColor:(UIColor *)aStartColour endColor:(UIColor *)aGradientColour {
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = aView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[aGradientColour CGColor], (id)[aStartColour CGColor], nil];
    [aView.layer insertSublayer:gradient atIndex:0];
}

#pragma mark -Image Rendring mode
-(UIImage *)getColorIgnoredImage:(NSString *)aImageString {
    
    UIImage *aAlertImage = [[UIImage imageNamed:aImageString] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return aAlertImage;
}

#pragma mark - UITextField

- (void)textFieldPlaceHolderAlter:(UITextField*)textField placeHolderText:(NSString*)text andColor:(UIColor*)color {
    
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)textViewPlaceHolderAlter:(UITextView*)textView placeHolderText:(NSString*)text andColor:(UIColor*)color {
    
    //textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}

#pragma mark - Tool Bar

- (UIToolbar *)getToolbarWithTitle:(NSString *)aTitle target:(UIViewController *)aTarget titleAlignment:(TOOLBAR_TITLE_ALIGNMENT)aAlignment buttonTitle:(NSString *)aButtonTitle tag:(NSInteger)aTag {
    
    // Title
    UILabel *aTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    aTitleLabel.textAlignment = NSTextAlignmentLeft;
    aTitleLabel.shadowOffset = CGSizeMake(0, 1);
    aTitleLabel.textColor = [UIColor blackColor];
    aTitleLabel.text = aTitle;
    aTitleLabel.font = [UIFont systemFontOfSize:16.0];
    [aTitleLabel sizeToFit];
    
    // Button
    UIBarButtonItem *aTitleItem = [[UIBarButtonItem alloc] initWithCustomView:aTitleLabel];
    
    UIBarButtonItem *aButtonItem = [[UIBarButtonItem alloc] initWithTitle:aButtonTitle style:UIBarButtonItemStyleDone target:aTarget action:@selector(toolbarButtonTapAction:)];
    aButtonItem.tintColor = [UIColor blackColor];
    aButtonItem.tag = aTag;
    
    UIBarButtonItem *aFlexableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    // Toolbar
    CGRect aToolbarFrame = CGRectMake(0, 0, CGRectGetWidth( [UIScreen mainScreen].bounds),40);
    UIToolbar *aToolbar = [[UIToolbar alloc] initWithFrame:aToolbarFrame];
    
    NSArray *aItemsArray;
    
    if (aAlignment == ALIGN_LEFT) {
        aItemsArray = @[aTitleItem,aFlexableItem,aButtonItem];
    }
    else {
        aItemsArray = @[aFlexableItem,aTitleItem,aButtonItem];
    }
    
    [aToolbar setItems:aItemsArray];
    aToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    return aToolbar;
}

- (void)navigateToLoginScreen {
    
}

- (void)navigateToHomeScreen {
    
}

- (void)navigateToDisclaimerScreen {
    
}

- (UIColor*)getColorForRating:(float)aRatingFloat {
    
    if(aRatingFloat <= 1)
        return [HELPER getColorFromHexaDecimal:@"D9534F"];
    else if(aRatingFloat <= 2)
        return [HELPER getColorFromHexaDecimal:@"F0AD4E"];
    else if(aRatingFloat <= 3)
        return [HELPER getColorFromHexaDecimal:@"5BC0DE"];
    else if(aRatingFloat <= 4)
        return [HELPER getColorFromHexaDecimal:@"337AB7"];
    else
        return [HELPER getColorFromHexaDecimal:@"5CB85C"];
}

#pragma mark - Alert View -

- (void)showAlertControllerIn:(UIViewController *)aViewController message:(NSString *)aMessage {
    
    [self showAlertControllerIn:aViewController title:APP_NAME message:aMessage buttonTitle:TITLE_OK actionBlock:nil];
}

- (void)showAlertControllerIn:(UIViewController *)aViewController title:(NSString *)aTitle message:(NSString *)aMessage buttonTitle:(NSString *)aButtonTitle actionBlock:(void (^)(UIAlertAction *action))aActionBlock {
    
    UIAlertController *aAlertController = [UIAlertController alertControllerWithTitle:aTitle message:aMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *aButtonAction = [UIAlertAction actionWithTitle:aButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (aActionBlock) {
            aActionBlock(action);
        }
        
    }];
    
    [aAlertController addAction:aButtonAction];
    
    [aViewController presentViewController:aAlertController animated:YES completion:nil];
    
}

- (void)showAlertControllerIn:(UIViewController *)aViewController title:(NSString *)aTitle message:(NSString *)aMessage defaultButtonTitle:(NSString *)aDefaultButtonTitle defaultActionBlock:(void (^)(UIAlertAction *action))aDefaultActionBlock cancelButtonTitle:(NSString *)aCancelButtonTitle cancelActionBlock:(void (^)(UIAlertAction *action))aCancelActionBlock {
    
    UIAlertController *aAlertController = [UIAlertController alertControllerWithTitle:aTitle message:aMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *aDefaultButtonAction = [UIAlertAction actionWithTitle:aDefaultButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (aDefaultActionBlock) {
            aDefaultActionBlock(action);
        }
        
    }];
    
    UIAlertAction *aCancelButtonAction = [UIAlertAction actionWithTitle:aCancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        if (aCancelActionBlock) {
            aCancelActionBlock(action);
        }
    }];
    
    [aAlertController addAction:aDefaultButtonAction];
    [aAlertController addAction:aCancelButtonAction];
    
    [aViewController presentViewController:aAlertController animated:YES completion:nil];
}


#pragma mark - Inertnet Connection

//- (BOOL)isNetConnectionAvailable {
//    
//    return [[NetworkConnection sharedHelper] isNetConnectionAvialable];
//}

- (NSString *)getNoNetworkMessage {
    
    return @"No network connection. Enable Wi-Fi or turn on mobile data!";
}


- (NSDateFormatter *)requestDateFormatter {
    static NSDateFormatter *aDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aDateFormatter = [[NSDateFormatter alloc] init];
        aDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss zzz";
    });
    return aDateFormatter;
}

- (NSString *) deviceTimeStamp {
    return [[self requestDateFormatter] stringFromDate:[NSDate date]];
}


#pragma mark - App Common Methods

- (UIViewController*)getTopMostController {
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (void)setURLProfileImageForImageView:(UIImageView*)aImageView URL:(NSString*)aURLString placeHolderImage:(NSString*)aPlaceHolderImageString {
    
    aURLString = [aURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *aURL = [NSURL URLWithString:aURLString];
    __weak UIImageView *imageView_ = aImageView;
    
    [imageView_ sd_setImageWithURL:aURL placeholderImage:[UIImage imageNamed:aPlaceHolderImageString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image == NULL)
            imageView_.image = [UIImage imageNamed:aPlaceHolderImageString];
        else
            imageView_.image = image;
    }];
}

@end
