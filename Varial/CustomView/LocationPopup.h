//
//  LocationPopup.h
//  Varial
//
//  Created by jagan on 07/05/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LocationPopupDelegate
-(void)onSearchLocationClick;
-(void)onPinNearByLocationClick;
-(void)onUseCurrentLocationClick;

@end

@interface LocationPopup : UIView

@property (assign) id<LocationPopupDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *pinButton;
@property (weak, nonatomic) IBOutlet UIButton *useLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *header;




- (IBAction)doSearchLocation:(id)sender;
- (IBAction)doPinNearByLocation:(id)sender;
- (IBAction)doUseMyCurrentLocation:(id)sender;

- (id)init;
-(id)initWithView:(BOOL)search pin:(BOOL)pin use:(BOOL)use;
@end
