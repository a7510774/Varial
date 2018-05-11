//
//  VideoPlayer.m
//  Varial
//
//  Created by jagan on 24/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "VideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>


@interface VideoPlayer (){
    MPMoviePlayerController *player;
}

@end

@implementation VideoPlayer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    
    if (_videoUrl != nil) {
        
        NSURL *theURL = [NSURL URLWithString:_videoUrl];
        
        player = [[MPMoviePlayerController alloc] initWithContentURL:theURL];
        player.view.frame = CGRectMake(0,20,self.view.frame.size.width,self.view.frame.size.height-20);
        [self.view addSubview:player.view];
        [player play];
        [player setFullscreen:YES animated:YES];
        
        //Listner for video play finished
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidPause:)
                                                     name:MPMoviePlayerWillExitFullscreenNotification
                                                   object:player];
        
        //Listner for video play paused
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:player];      
    }else{
        NSLog(@"Video URL missing");
    }
    
}


//Movie play back paused
- (void) moviePlayBackDidPause:(NSNotification*)notification
{
    NSLog(@"Media Paused");
    [player.view setHidden:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}

//Movie play back finished
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSLog(@"Media finished");
    
    MPMoviePlayerController *videoplayer = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:videoplayer];
    
    if ([videoplayer
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        // remove the video player from superview.
        [player.view setHidden:YES];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
