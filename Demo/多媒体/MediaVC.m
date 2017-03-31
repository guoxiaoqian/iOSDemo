//
//  MediaVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/3/31.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "MediaVC.h"
#import <AudioToolbox/AudioToolbox.h> //播放音效：AudioServices
#import <AVFoundation/AVFoundation.h> //播放音乐：AVAudioPlayer

@interface MediaVC ()
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *progressBar;
@property (strong,nonatomic) AVAudioPlayer* audioPlayer;
@property (strong,nonatomic) NSTimer* progressTimer;
@property (weak, nonatomic) IBOutlet UILabel *MetersLabel;

@end

@implementation MediaVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self playSoundEffect];
    
    [self setupAVAudioPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 播放音效

void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}


//音频播放时间不能超过30s
//数据必须是PCM或者IMA4格式
//音频文件必须打包成.caf、.aif、.wav中的一种（注意这是官方文档的说法，实际测试发现一些.mp3也可以播放）
-(void)playSoundEffect{
    SystemSoundID soundId = 0;
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource:@"msg" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundId);
    AudioServicesAddSystemSoundCompletion(soundId, NULL,NULL,soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundId);
//    AudioServicesPlayAlertSound(soundId); //带震动
    
}

#pragma mark - 播放音乐

-(void)setupAVAudioPlayer{
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource:@"music" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.audioPlayer.numberOfLoops = 0;//循环播放次数，如果为0则不循环，如果小于0则无限循环，大于0则表示循环次数
    self.audioPlayer.volume = 0.3; //0-1
    self.audioPlayer.rate = 1.0;//播放速率，范围0.5-2.0，如果为1.0则正常播放，如果要修改播放速率则必须设置enableRate为YES
    self.audioPlayer.meteringEnabled = YES;//是否启用音频测量
    [self.audioPlayer prepareToPlay];
}

- (IBAction)playOrPause:(id)sender {
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer pause];
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        [self.audioPlayer play];
        if (self.progressTimer == nil) {
            self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [self updateProgress];
            }];
        }
        [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

- (IBAction)progressChanged:(id)sender {
    NSTimeInterval playTime = self.progressBar.value * self.audioPlayer.duration;
    /*  If the sound is playing, currentTime is the offset into the sound of the current playback position.
     If the sound is not playing, currentTime is the offset into the sound where playing would start. */
    self.audioPlayer.currentTime = playTime;
}

-(void)updateProgress{
    [self.progressBar setValue:self.audioPlayer.currentTime / self.audioPlayer.duration];
    //必须在此之前调用updateMeters方法,才能获得分贝峰值
    [self.audioPlayer updateMeters];
    self.MetersLabel.text = [NSString stringWithFormat:@"%f分贝",[self.audioPlayer peakPowerForChannel:0]];
}

@end
