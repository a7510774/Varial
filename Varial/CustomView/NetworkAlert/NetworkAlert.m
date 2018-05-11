//
//  NetworkAlert.m
//  Varial
//
//  Created by jagan on 26/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "NetworkAlert.h"
#import "Util.h"
#import "AFNetworking.h"

@implementation NetworkAlert

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
    return self;
}


//Load XIB file
- (void)loadView {
    
    [[NSBundle mainBundle] loadNibNamed:@"NetworkAlert" owner:self options:nil];
  
    CGRect rootViewFrame = self.layer.frame;
    self.view.layer.frame = rootViewFrame;
    
    [self addSubview:self.view];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _title.text = NSLocalizedString(@"NETWORK", nil);
    _subTitle.text = NSLocalizedString(@"Please check your network connection", nil);
    [_button setTitle:NSLocalizedString(@"Retry", nil) forState:UIControlStateNormal];
}

- (void)setNetworkHeader:(NSString*)title{
    NSString *language = [Util getFromDefaults:@"language"];
    if([language isEqualToString:@"en-US"])
    {
        _title.text = [title uppercaseString];
        [_title setFont: [_title.font fontWithSize:16]];
    }
    else{
        _title.text = title;
    }
}

+ (id) sharedInstance{
    static NetworkAlert *networkAlert = nil;
    @synchronized(self) {
        if (networkAlert == nil) {
             CGSize size = [Util getWindowSize];
            networkAlert = [[self alloc] initWithFrame:CGRectMake(0, size.height, size.width, size.height)];
        }
    }
    return networkAlert;
}

- (void) hideShowAlert{   
    
    
    [UIView transitionWithView:self.view
                      duration:.3
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        CGSize size = [Util getWindowSize];
                        CGRect frame = self.view.layer.frame;
                        if([[AFNetworkReachabilityManager sharedManager] isReachable]){ //Hide
                            frame.origin.y =  size.height * -2;
                        }
                        else{ //Show
                            frame.origin.y = 0;
                            frame.size.height = size.height;
                        }
                        self.view.layer.frame = frame;
                    }
                    completion:^(BOOL finished){
                        
                        
                    }];

    
}

- (IBAction)triggered:(id)sender {
    
    if(self.button.tag == 100){        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetEmailNotification" object:self];
    }
    else if(self.button.tag == 102){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelEmailNotification" object:self];
    }
    else{
        [self.delegate onButtonClick];
    }
}
@end
