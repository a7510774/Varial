#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CustomLayoutManager.h"
#import "InlineTextAttachment.h"
#import "NSAttributedString+Processing.h"
#import "NSMutableAttributedString+BoundChecker.h"
#import "PatternDescriptor.h"
#import "ResponsiveLabel.h"

FOUNDATION_EXPORT double ResponsiveLabelVersionNumber;
FOUNDATION_EXPORT const unsigned char ResponsiveLabelVersionString[];

