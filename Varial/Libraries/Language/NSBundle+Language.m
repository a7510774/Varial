//
//  NSBundle+Language.m
//  ios_language_manager
//
//  Created by Maxim Bilan on 1/10/15.
//  Copyright (c) 2015 Maxim Bilan. All rights reserved.
//

#import "NSBundle+Language.h"
#import <objc/runtime.h>

//#ifdef USE_ON_FLY_LOCALIZATION

static const char kBundleKey = 0;

@interface BundleEx : NSBundle

@end

@implementation BundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    NSBundle *bundle = objc_getAssociatedObject(self, &kBundleKey);
    if (bundle) {
        return [bundle localizedStringForKey:key value:value table:tableName];
    }
    else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}

@end

@implementation NSBundle (Language)

+ (void)setLanguage:(NSString *)language
{
    
    language = [language isEqualToString:@"en-US"] ? @"Base" : language;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [BundleEx class]);
    });
    id value = language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil;
    objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

//#endif