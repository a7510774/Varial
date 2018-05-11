//
//  AlertMessage.m
//  Varial
//
//  Created by jagan on 25/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "AlertMessage.h"

@implementation AlertMessage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
         [self loadView];
    }
    //Set the constraints for view
    [self setConstraints];
    return self;
}

-(void)setConstraints{
    
     NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (_subview,_errorLabel);
   
    NSArray *constraintsArray= [NSLayoutConstraint
                       constraintsWithVisualFormat:@"H:|-[_subview]-|"
                       options:NSLayoutFormatAlignAllBaseline metrics:nil
                       views:viewsDictionary];
    [self.view addConstraints:constraintsArray];
    
    constraintsArray = [NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|-10-[_errorLabel(>=300)]|"
                                options:NSLayoutFormatAlignAllBaseline metrics:nil
                                views:viewsDictionary];
    [self.view addConstraints:constraintsArray];
    
   constraintsArray= [NSLayoutConstraint
                                constraintsWithVisualFormat:@"V:|-[_subview(70)]"
                                options:NSLayoutFormatAlignAllBaseline metrics:nil
                                views:viewsDictionary];
    [self.view addConstraints:constraintsArray];
 
}


//Load XIB file
- (void)loadView {
    
    [[NSBundle mainBundle] loadNibNamed:@"AlertMessage" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.view.layer.frame = rootViewFrame;
    
    CGRect frame = self.view.layer.frame;
    frame.origin.y =  frame.size.height * -2;
    
    self.view.layer.frame = frame;
    [self addSubview:self.view];
}

- (void) showMessage :(NSString *) message {
    
    if([message isEqualToString:@"Invalid access"]) {
        
        return;
    }
    
    self.errorLabel.text = NSLocalizedString(message, nil);
    [_errorLabel sizeToFit];
    
    //Append the view in window
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self.view];
            [window bringSubviewToFront:self.view];
            //break;
        }
    }

    
    [self.view.layer removeAllAnimations];
    
    //Show
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //Show
        CGRect frame = self.view.layer.frame;
        
        if (frame.origin.y !=  0) {
            frame.origin.y =  0;
            frame.size.height=_errorLabel.frame.size.height + 30.0;
            _errorLabel.frame = CGRectMake(_errorLabel.frame.origin.x, _errorLabel.frame.origin.y, frame.size.width - 20, 50);
            self.view.layer.frame = frame;
        }
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.5 delay:2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            //Hide
            CGRect frame = self.view.layer.frame;
            frame.origin.y =  -500;
            self.view.layer.frame = frame;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }];
    
}


- (void) showMessage :(NSString *) message withDuration:(float)duration{
    
    if([message isEqualToString:@"Invalid access"]) {
        
        return;
    }
    
    self.errorLabel.text = message;
     [_errorLabel sizeToFit];
    
    //Append the view in window
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self.view];
            [window bringSubviewToFront:self.view];
            //break;
        }
    }
    
    [self.view.layer removeAllAnimations];
    
    //Show
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //Show
        CGRect frame = self.view.layer.frame;
        
        if (frame.origin.y !=  0) {
            frame.origin.y =  0;
            frame.size.height=_errorLabel.frame.size.height + 30.0;
            _errorLabel.frame = CGRectMake(_errorLabel.frame.origin.x, _errorLabel.frame.origin.y, frame.size.width - 20, 50);
            self.view.layer.frame = frame;
        }
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.5 delay:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
            //Hide
            CGRect frame = self.view.layer.frame;
            frame.origin.y =  -500;
            self.view.layer.frame = frame;
            
        } completion:^(BOOL finished) {
            
        }];        
    }];
}


+ (id) sharedInstance{
    static AlertMessage *alertMessage = nil;
    @synchronized(self) {
        if (alertMessage == nil) {
            CGSize size = [Util getWindowSize];
            alertMessage = [[self alloc] initWithFrame:CGRectMake(0, 70, size.width, 70)];
        }
    }
    return alertMessage;
}

@end
