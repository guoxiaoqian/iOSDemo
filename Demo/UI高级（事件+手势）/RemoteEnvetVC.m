//
//  RemoteEnvetVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/3/30.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "RemoteEnvetVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

//三个必要条件：
//接受者必须能够成为first responder
//必须显示地声明接收RemoteComtrol事件
//你的app必须是Now Playingapp

@interface RemoteEnvetVC ()

@property (nonatomic, strong) MPMoviePlayerController *audioPlayer;

@end

@implementation RemoteEnvetVC

-(BOOL)canBecomeFirstResponder{
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self prepaerForRemoteControl];
    
    [self prepareForPlay];
    
    [self displayForNowPlaying];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForPlay{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    /* Use this category for music tracks.*/
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"https://www.cocoanetics.com/files/Cocoanetics_031.mp3"]];
    [self.audioPlayer setShouldAutoplay:NO];
    [self.audioPlayer prepareToPlay];

    self.audioPlayer.view.frame = CGRectMake(0, 0, kScreenWidth, 300);
    self.audioPlayer.controlStyle = MPMovieControlStyleDefault;
    [self.view addSubview:self.audioPlayer.view];
}

- (void)prepaerForRemoteControl{
    //可以接受远程控制
    [self becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self startPlay];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pausePlay];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self stopPlay];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

- (void)displayForNowPlaying{
    MPMediaItemArtwork* artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"Demo2"]];
    NSDictionary* playInfo = @{
                               MPMediaItemPropertyTitle:@"伟大之歌",
                               MPMediaItemPropertyArtist:@"郭晓倩",
                               MPMediaItemPropertyAlbumTitle:@"封面",
                               MPMediaItemPropertyArtwork:artWork,
                               };
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:playInfo];
}

-(void)startPlay{
    [self.audioPlayer play];
}

-(void)pausePlay{
    [self.audioPlayer pause];
}

-(void)stopPlay{
    [self.audioPlayer stop];
}

#pragma mark - Handle Remote Event

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{

}

@end
