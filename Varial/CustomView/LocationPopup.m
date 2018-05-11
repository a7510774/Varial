//
//  LocationPopup.m
//  Varial
//
//  Created by jagan on 07/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "LocationPopup.h"
#import "Util.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@implementation LocationPopup

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init{
    
    self = [super init];
    
    return self;
}

-(id)initWithView:(BOOL)search pin:(BOOL)pin use:(BOOL)use {
    self = [super init];
    
    [[NSBundle mainBundle] loadNibNamed:@"LocationPopup" owner:self options:nil];
    
    float height = 192;
    if(!search)
    {
        [_searchButton hideByHeight:YES];
        [_searchButton setHidden:YES];
        height = height - 50;
    }
    
    
    CGRect rootViewFrame =self.mainView.frame;
    rootViewFrame.size.height=height;
    self.frame=rootViewFrame;
    
    LocationPopup *location=[[LocationPopup alloc]initWithFrame:rootViewFrame];
    
    [self addSubview:self.mainView];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _header.text = NSLocalizedString(@"CHECK-IN", nil);
    [_searchButton setTitle:NSLocalizedString(@"Search Location", nil) forState:UIControlStateNormal];
    [_pinButton setTitle:NSLocalizedString(@"Pin Nearby Location", nil) forState:UIControlStateNormal];
    [_useLocationButton setTitle:NSLocalizedString(@"Use My Current Location", nil) forState:UIControlStateNormal];

    
    [Util createBottomLine:_searchButton withColor:[UIColor lightGrayColor]];
    [Util createBottomLine:_pinButton withColor:[UIColor lightGrayColor]];
    [Util createBottomLine:_useLocationButton withColor:[UIColor lightGrayColor]];
    
    return self;
}
- (IBAction)doSearchLocation:(id)sender {
    [self.delegate onSearchLocationClick];
}

- (IBAction)doPinNearByLocation:(id)sender {
    [self.delegate onPinNearByLocationClick];
}

- (IBAction)doUseMyCurrentLocation:(id)sender {
    [self.delegate onUseCurrentLocationClick];
}
@end
