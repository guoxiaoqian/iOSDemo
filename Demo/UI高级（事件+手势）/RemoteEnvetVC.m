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
    /* Use this category for music tracks.*/
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //到设置完音频会话类型之后需要调用setActive::方法将会话激活才能起作用;音频播放完之后（关闭或退出到后台之后）能够继续播放其他应用的音频的话则可以调用setActive::方法关闭会话
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
//    NSURL* netFileURL = [NSURL URLWithString:@"https://www.cocoanetics.com/files/Cocoanetics_031.mp3"];
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource:@"music" withExtension:@"mp3"];

    self.audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
    [self.audioPlayer setShouldAutoplay:NO];
    [self.audioPlayer prepareToPlay];
    
    self.audioPlayer.view.frame = CGRectMake(0, 0, kScreenWidth, 300);
    self.audioPlayer.controlStyle = MPMovieControlStyleDefault;
    [self.view addSubview:self.audioPlayer.view];
}

- (void)prepaerForRemoteControl{
    // ps:如果已经通过注册 [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];也会触发该事件-remoteControlReceivedWithEvent:, UIEvent 和UIEventTypeRemoteControl 的事件要进行区分,根据目前的发展情况 MPRemoteCommandEvents将取代UIEvents的一些功能.
    
    //    [self becomeFirstResponder];
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
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
                               MPMediaItemPropertyAlbumTitle:@"专辑名",
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

#pragma mark - Handle Remote Event in Old Way

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"remoteControlReceivedWithEvent play");
                break;
            case UIEventSubtypeRemoteControlPause:
                NSLog(@"remoteControlReceivedWithEvent pause");
                break;
            case UIEventSubtypeRemoteControlStop:
                NSLog(@"remoteControlReceivedWithEvent stop");
                break;
            default:
                break;
        }
    }
}

@end
