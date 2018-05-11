//
//  YesNoPopup.m
//  Varial
//
//  Created by jagan on 17/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "YesNoPopup.h"
#import "Util.h"
#import "Config.h"

@interface YesNoPopup()
@end

@implementation YesNoPopup


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    
    [[NSBundle mainBundle] loadNibNamed:@"YesNoPopup" owner:self options:nil];
    
    CGRect rootViewFrame = self.layer.frame;
    self.mainView.layer.frame = rootViewFrame;
    
    [self addSubview:self.mainView];
    
     self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    [_message setFont:[UIFont systemFontOfSize:16.0]];
    _title.text = NSLocalizedString(@"SIGN OUT", nil);
    _message.text = NSLocalizedString(@"Are you sure you want to Sign Out?", nil);
    [_yesButton setTitle: NSLocalizedString(@"Yes", nil) forState:UIControlStateNormal];
    [_noButton setTitle: NSLocalizedString(@"No", nil) forState:UIControlStateNormal];

    
    [Util createRoundedCorener:_yesButton withCorner:3];
    [Util createRoundedCorener:_noButton withCorner:3];    
}

- (void)setPopupHeader:(NSString*)title{
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)doYes:(id)sender {
    [self.delegate onYesClick];
}

- (IBAction)doNo:(id)sender {
     [self.delegate onNoClick];
}
@end
