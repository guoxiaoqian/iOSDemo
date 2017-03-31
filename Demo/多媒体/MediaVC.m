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
#import <MediaPlayer/MediaPlayer.h>

@interface MediaVC ()<AVAudioPlayerDelegate,MPMediaPickerControllerDelegate,AVAudioRecorderDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *progressBar;
@property (strong,nonatomic) AVAudioPlayer* audioPlayer;
@property (strong,nonatomic) NSTimer* progressTimer;
@property (weak, nonatomic) IBOutlet UILabel *MetersLabel;

@property (strong,nonatomic) MPMusicPlayerController* musicPlayer;
@property (strong,nonatomic) MPMediaPickerController* musicPicker;

@property (strong,nonatomic) AVAudioRecorder* audioRecorder;
@property (strong,nonatomic) NSTimer* recordTimer;

@end

@implementation MediaVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self playSoundEffect];
    
    [self setupAVAudioPlayerWithURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)setupAVAudioPlayerWithURL:(NSURL*)url{
    NSURL* fileURL = url ?: [[NSBundle mainBundle] URLForResource:@"music" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.audioPlayer.numberOfLoops = 0;//循环播放次数，如果为0则不循环，如果小于0则无限循环，大于0则表示循环次数
    self.audioPlayer.volume = 0.3; //0-1
    self.audioPlayer.rate = 1.0;//播放速率，范围0.5-2.0，如果为1.0则正常播放，如果要修改播放速率则必须设置enableRate为YES
    self.audioPlayer.meteringEnabled = YES;//是否启用音频测量
    self.audioPlayer.delegate = self;
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

#pragma mark  AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"audioPlayer finish");
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"audioPlayer decode error");
}

#pragma mark - 播放媒体库音乐，需设置Info.plist权限：NSAppleMusicUsageDescription

-(MPMusicPlayerController*)musicPlayer{
    if (_musicPlayer == nil) {
        _musicPlayer = [MPMusicPlayerController systemMusicPlayer];
        [_musicPlayer setQueueWithQuery:[self queryForLocalMusic]];
//        [_musicPlayer setQueueWithItemCollection:[self collectionForLocalMusic]];
        [self addNotification];
    }
    return _musicPlayer;
}

// 取得媒体队列
-(MPMediaQuery *)queryForLocalMusic{
    MPMediaQuery* songQuery = [MPMediaQuery songsQuery];
    for (MPMediaItem *item in songQuery.items) {
        NSLog(@"标题：%@,%@",item.title,item.albumTitle);
    }
    MPMediaPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue:@"music" forProperty:@"title" comparisonType:MPMediaPredicateComparisonEqualTo];
    [songQuery addFilterPredicate:predicate];
    return songQuery;
}

//取得媒体集合
-(MPMediaItemCollection*)collectionForLocalMusic{
    MPMediaQuery* songQuery = [MPMediaQuery songsQuery];
    NSMutableArray* array = [NSMutableArray new];
    for (MPMediaItem *item in songQuery.items) {
        NSLog(@"标题：%@,%@",item.title,item.albumTitle);
        //可以自己做过滤
        [array addObject:item];
    }
    return [MPMediaItemCollection collectionWithItems:array];
}

-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaybackStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
}

-(void)didPlaybackStateChanged:(NSNotification*)n{
    switch (self.musicPlayer.playbackState) {
//            MPMusicPlaybackStateStopped,
//            MPMusicPlaybackStatePlaying,
//            MPMusicPlaybackStatePaused,
//            MPMusicPlaybackStateInterrupted,
//            MPMusicPlaybackStateSeekingForward,
//            MPMusicPlaybackStateSeekingBackward

        case MPMusicPlaybackStatePlaying:
            NSLog(@"MPMusicPlaybackStatePlaying");
            break;
        case MPMusicPlaybackStatePaused:
            NSLog(@"MPMusicPlaybackStatePaused");
            break;
        case MPMusicPlaybackStateSeekingForward:
            NSLog(@"MPMusicPlaybackStateSeekingForward");
            break;
        case MPMusicPlaybackStateSeekingBackward:
            NSLog(@"MPMusicPlaybackStateSeekingBackward");
            break;
        default:
            break;
    }
}


-(MPMediaPickerController*)musicPicker{
    if (!_musicPicker) {
        _musicPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        _musicPicker.allowsPickingMultipleItems = YES;
        _musicPicker.delegate = self;
    }
    return _musicPicker;
}

-(IBAction)pickMusic:(id)sender{
    [self presentViewController:self.musicPicker animated:YES completion:^{
        
    }];
}

-(IBAction)playOrPauseMusic:(UIButton*)sender{
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer play];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }else{
        [self.musicPlayer pause];
        [sender setTitle:@"播放" forState:UIControlStateNormal];
    }
}

-(IBAction)previousMusic:(id)sender{
    [self.musicPlayer skipToPreviousItem];
}

-(IBAction)nextMusic:(id)sender{
    [self.musicPlayer skipToNextItem];
}

#pragma mark MPMediaPickerControllerDelegate

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    
    NSLog(@"mediaPicker:didPickMediaItems %@",mediaItemCollection);

    
    [self.musicPlayer stop];
    [self.musicPlayer setQueueWithItemCollection:mediaItemCollection];
    [self.musicPlayer play];
    
    [self.musicPicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    NSLog(@"mediaPickerDidCancel");
    [self.musicPicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 录音

-(NSURL*)recordFileURL{
    NSString* fileURL = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"record.pcm"];
    return [NSURL URLWithString:fileURL];
}

-(NSDictionary*)recordSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

-(AVAudioRecorder*)audioRecorder{
    if (!_audioRecorder) {
        NSError* error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self recordFileURL] settings:[self recordSetting] error:&error];
        if (error) {
            NSLog(@"audioRecorder init failed");
        }
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        [_audioRecorder prepareToRecord];
        
        //牵扯到录音和播放操作。
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    return _audioRecorder;
}

-(NSTimer*)recordTimer{
    if (!_recordTimer) {
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    }
    return _recordTimer;
}

-(IBAction)startRecord:(id)sender{
    if (!self.audioRecorder.isRecording) {
        [self.audioRecorder record];
    }
    self.recordTimer.fireDate = [NSDate distantPast];
}

-(IBAction)pauseRecord:(id)sender{
    [self.audioRecorder pause];
    self.recordTimer.fireDate = [NSDate distantFuture];
}

-(IBAction)stopRecord:(id)sender{
    [self.audioRecorder stop];
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}

-(IBAction)deleteRecord:(id)sender{
    [self.audioRecorder deleteRecording];
}

-(void)updateMeters{
    [self.audioRecorder updateMeters];
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    self.MetersLabel.text = [NSString stringWithFormat:@"%f",power];
}

#pragma mark AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"audioRecorderDidFinishRecording");
    
    //录音完毕直接播放
    [self setupAVAudioPlayerWithURL:[self recordFileURL]];
    [self playOrPause:nil];
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"audioRecorderEncodeErrorDidOccur");
}

@end
