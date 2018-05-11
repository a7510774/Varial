//
//  ProfileView.m
//  Varial
//
//  Created by Leif Ashby on 5/20/17.
//  Copyright © 2017 Velan. All rights reserved.
//

#import "ProfileView.h"

@implementation ProfileView

@synthesize delegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
//    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"ProfileView" owner:self options:nil] firstObject];
//    self.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    [self addSubview:view];
    
    [[NSBundle mainBundle] loadNibNamed:@"ProfileView" owner:self options:nil];
    self.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.view];
    
    _boardImage.layer.cornerRadius = _boardImage.layer.frame.size.height / 2;
    _boardImage.clipsToBounds = true;
    _boardImage.contentMode = UIViewContentModeScaleAspectFill;
}

- (IBAction)tappedPoints:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedPoints:)]) {
        [self.delegate tappedPoints:sender];
    }
}
- (IBAction)tappedVideos:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedVideos:)]) {
        [self.delegate tappedVideos:sender];
    }
}
- (IBAction)tappedPhotos:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedPhotos:)]) {
        [self.delegate tappedPhotos:sender];
    }
}
- (IBAction)tappedUpdate:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedUpdate:)]) {
        [self.delegate tappedUpdate:sender];
    }
}
- (IBAction)tappedFriends:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedFriends:)]) {
        [self.delegate tappedFriends:sender];
    }
}

- (IBAction)tappedLocation:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedLocation:)]) {
        [self.delegate tappedLocation:sender];
    }
}
- (IBAction)tappedName:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedName:)]) {
        [self.delegate tappedName:sender];
    }
}

- (IBAction)tappedProfileImage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedProfileImage:)]) {
        [self.delegate tappedProfileImage:sender];
    }
}
- (IBAction)tappedBoardImage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedBoardImage:)]) {
        [self.delegate tappedBoardImage:sender];
    }
}

- (IBAction)tappedMore:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tappedMore:)]) {
        [self.delegate tappedMore:sender];
    }
}

- (void)hideMore:(BOOL)hide {
    [_moreButton setHidden:hide];
}


@end
