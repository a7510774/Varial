//
//  UITapGestureRecognizer+LabelActionHandled.h
//  Varial
//
//  Created by Dreamguys on 16/02/18.
//  Copyright © 2018 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITapGestureRecognizer (LabelActionHandled)

- (BOOL)didTapAttributedTextInLabel:(UILabel *)label inRange:(NSRange)targetRange;

@end
