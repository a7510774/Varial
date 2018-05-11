//
//  EmailAlert.m
//  Varial
//
//  Created by jagan on 05/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "EmailAlert.h"

@implementation EmailAlert

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
    
    [[NSBundle mainBundle] loadNibNamed:@"EmailAlert" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    [self addSubview:self.mainView];
    [Util createBottomLine:self.resendLabel withColor:UIColorFromHexCode(THEME_COLOR)];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    _resendLabel.text = NSLocalizedString(@"Resend", nil);
    
}

- (IBAction)resendEmail:(id)sender {
    
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:RESEND_EMAIL withCallBack:^(NSDictionary * response){
       [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
    } isShowLoader:YES];

}

@end
