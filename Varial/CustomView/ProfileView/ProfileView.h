//
//  ProfileView.h
//  Varial
//
//  Created by Leif Ashby on 5/20/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileViewDelegate <NSObject>
@optional
- (void)tappedPoints:(id)sender;
- (void)tappedVideos:(id)sender;
- (void)tappedUpdate:(id)sender;
- (void)tappedPhotos:(id)sender;
- (void)tappedFriends:(id)sender;

- (void)tappedLocation:(id)sender;
- (void)tappedName:(id)sender;

- (void)tappedProfileImage:(id)sender;
- (void)tappedBoardImage:(id)sender;

- (void)tappedMore:(id)sender;
@end

@interface ProfileView : UIView
@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak) id<ProfileViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *rank;

@property (weak, nonatomic) IBOutlet UIImageView *boardImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UIButton *photosButton;
@property (weak, nonatomic) IBOutlet UIButton *videosButton;
@property (weak, nonatomic) IBOutlet UIButton *pointsButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *profileUpdateButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *followBtnWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;


- (void)hideMore:(BOOL)hide;
@property (weak, nonatomic) IBOutlet UIButton *btnFollow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraiintStatsViewTop;

@end
