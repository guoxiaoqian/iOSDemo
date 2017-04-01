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
#import <FreeStreamer/FreeStreamer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface MediaVC ()<AVAudioPlayerDelegate,MPMediaPickerControllerDelegate,AVAudioRecorderDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *progressBar;
@property (strong,nonatomic) AVAudioPlayer* audioPlayer;
@property (strong,nonatomic) NSTimer* progressTimer;
@property (weak, nonatomic) IBOutlet UILabel *MetersLabel;

@property (strong,nonatomic) MPMusicPlayerController* musicPlayer;
@property (strong,nonatomic) MPMediaPickerController* musicPicker;

@property (strong,nonatomic) AVAudioRecorder* audioRecorder;
@property (strong,nonatomic) NSTimer* recordTimer;

@property (strong,nonatomic) FSAudioStream* freeStreamPlayer;

@property (strong,nonatomic) MPMoviePlayerController* moviePlayer;

@property (strong,nonatomic) UIImagePickerController* imagePicker;
@property (assign,nonatomic) BOOL isVideo;

@end

@implementation MediaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self playSoundEffect];
    
    [self setupAVAudioPlayerWithURL:nil];
    
    self.moviePlayer.view.frame = CGRectMake(0, 300, kScreenWidth, 200);
    [self.view addSubview:self.moviePlayer.view];
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
    NSLog(@"播放音效完成...");
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

#pragma mark - 播放音乐(AVAudioPlayer只能播放本地文件，并且是一次性加载所以音频数据)

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

#pragma mark - 录音,需要info.plist中设置麦克风权限

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

#pragma mark - AudioQueue (AudioToolbox框架中的,播放网络音乐;第三方库FreeStreamer)

-(NSURL*)getNetworkMusicURL{
    NSURL* netFileURL = [NSURL URLWithString:@"https://www.cocoanetics.com/files/Cocoanetics_031.mp3"];
    return netFileURL;
}

-(FSAudioStream*)freeStreamPlayer{
    if (!_freeStreamPlayer) {
        _freeStreamPlayer = [[FSAudioStream alloc] initWithUrl:[self getNetworkMusicURL]];
        _freeStreamPlayer.onCompletion = ^{
            NSLog(@"freeStreamPlayer completed");
        };
        _freeStreamPlayer.onFailure = ^(FSAudioStreamError error, NSString *errorDescription){
            NSLog(@"freeStreamPlayer error %@",errorDescription);
        };
        _freeStreamPlayer.onStateChange = ^(FSAudioStreamState state){
            switch (state) {
                case kFsAudioStreamBuffering:
                    NSLog(@"freeStreamPlayer state buffering");
                    break;
                case kFsAudioStreamPlaying:
                    NSLog(@"freeStreamPlayer state playing");
                    break;
                case kFsAudioStreamPaused:
                    NSLog(@"freeStreamPlayer state paused");
                    break;
                case kFsAudioStreamStopped:
                    NSLog(@"freeStreamPlayer state stoped");
                    break;
                case kFsAudioStreamFailed:
                    NSLog(@"freeStreamPlayer state failed");
                    break;
                case kFsAudioStreamSeeking:
                    NSLog(@"freeStreamPlayer state seeking");
                    break;
                case kFsAudioStreamPlaybackCompleted:
                    NSLog(@"freeStreamPlayer state completed");
                    break;
                default:
                    break;
            }
        };
        [_freeStreamPlayer setVolume:0.5];
        [_freeStreamPlayer preload];
        
    }
    return _freeStreamPlayer;
}

-(IBAction)palyOrPauseStreamMusic:(UIButton*)sender{
    if (self.freeStreamPlayer.isPlaying) {
        [self.freeStreamPlayer pause];
        [sender setTitle:@"播放流音乐" forState:UIControlStateNormal];
    }else{
        static BOOL isFirstPlay = YES;
        if (isFirstPlay) {
            [self.freeStreamPlayer play];
            isFirstPlay = NO;
        }else{
            /**
             * If the stream is playing, the stream playback is paused upon calling pause.
             * Otherwise (the stream is paused), calling pause will continue the playback.
             */
            [self.freeStreamPlayer pause];
        }
        [sender setTitle:@"暂停流音乐" forState:UIControlStateNormal];
    }
}

#pragma mark - MPMoviePlayerController 支持本地视频和网络视频播放,通过通知回调

-(NSURL *)getNetworkMovieUrl{
    NSString *urlStr=@"http://192.168.1.161/The New Look of OS X Yosemite.mp4";
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}

-(MPMoviePlayerController*)moviePlayer{
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[self getNetworkMovieUrl]];
        [_moviePlayer setShouldAutoplay:NO];
        _moviePlayer.repeatMode = MPRepeatTypeOne;
        _moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        [_moviePlayer prepareToPlay];
        
        //观察通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerThumbImageFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil]; //缩略图请求完成之后
        
    }
    return _moviePlayer;
}

-(IBAction)getMovieThumbImage:(id)sender{
    //    其实使用AVFundation框架中的AVAssetImageGenerator就可以获取视频缩略图。
    [self.moviePlayer requestThumbnailImagesAtTimes:@[@(2)] timeOption:MPMovieTimeOptionExact];
}

-(void)moviePlayerLoadStateChanged:(NSNotification*)noti{
    NSLog(@"moviePlayerLoadStateChanged %ld",self.moviePlayer.loadState);
}
-(void)moviePlayerPlaybackStateChanged:(NSNotification*)noti{
    NSLog(@"moviePlayerPlaybackStateChanged %ld",self.moviePlayer.playbackState);
    
}
-(void)moviePlayerThumbImageFinish:(NSNotification*)noti{
    NSLog(@"视频截图完成");
    UIImage* image = noti.userInfo[MPMoviePlayerThumbnailImageKey];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - MPMoviePlayerViewController (MPMoviePlayerController的封装)

//其实MPMoviePlayerController如果不作为嵌入视频来播放（例如在新闻中嵌入一个视频），通常在播放时都是占满一个屏幕的，特别是在iPhone、iTouch上。因此从iOS3.2以后苹果也在思考既然MPMoviePlayerController在使用时通常都是将其视图view添加到另外一个视图控制器中作为子视图，那么何不直接创建一个控制器视图内部创建一个MPMoviePlayerController属性并且默认全屏播放，开发者在开发的时候直接使用这个视图控制器。这个内部有一个MPMoviePlayerController的视图控制器就是MPMoviePlayerViewController

#pragma mark - AVPlayer (比MPMoviePlayerController更底层)

//AVPlayer本身并不能显示视频，而且它也不像MPMoviePlayerController有一个view属性。如果AVPlayer要显示必须创建一个播放器层AVPlayerLayer用于展示，播放器层继承于CALayer，有了AVPlayerLayer之添加到控制器视图的layer中即可。要使用AVPlayer首先了解一下几个常用的类：
//
//AVAsset：主要用于获取多媒体信息，是一个抽象类，不能直接使用。
//
//AVURLAsset：AVAsset的子类，可以根据一个URL路径创建一个包含媒体信息的AVURLAsset对象。
//
//AVPlayerItem：一个媒体资源管理对象，管理者视频的一些基本信息和状态，一个AVPlayerItem对应着一个视频资源。



//当然AVPlayerItem是有通知的，但是对于获得播放状态和加载状态有用的通知只有一个：播放完成通知AVPlayerItemDidPlayToEndTimeNotification。在播放视频时，特别是播放网络视频往往需要知道视频加载情况、缓冲情况、播放情况，这些信息可以通过KVO监控AVPlayerItem的status、loadedTimeRanges属性来获得。


//到目前为止无论是MPMoviePlayerController还是AVPlayer来播放视频都相当强大，但是它也存在着一些不可回避的问题，那就是支持的视频编码格式很有限：H.264、MPEG-4，扩展名（压缩格式）：.mp4、.mov、.m4v、.m2v、.3gp、.3g2等。但是无论是MPMoviePlayerController还是AVPlayer它们都支持绝大多数音频编码，所以大家如果纯粹是为了播放音乐的话也可以考虑使用这两个播放器。那么如何支持更多视频编码格式呢？目前来说主要还是依靠第三方框架，在iOS上常用的视频编码、解码框架有：VLC、ffmpeg

#pragma mark - UIImagePickerController拍照和视频录制

-(UIImagePickerController*)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.showsCameraControls = YES;
        UIView* overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        overlayView.backgroundColor = [UIColor yellowColor];
        _imagePicker.cameraOverlayView = overlayView;
        _imagePicker.cameraViewTransform = CGAffineTransformMakeRotation(M_PI_4);
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            NSLog(@"不支持摄像头");
        }
        if (self.isVideo) {
            _imagePicker.cameraFlashMode = UIImagePickerControllerCameraCaptureModeVideo; //拍照 或 视频
            _imagePicker.mediaTypes = @[(__bridge id)kUTTypeVideo];//默认kUTTypeImage;kUTTypeMovie带声音,kUTTypeVideo不带
            _imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        }else{
                    _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }

        
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
            _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront; //前置 或 后置摄像头；UIImagePickerControllerCameraDeviceRear为前置
        }
        if([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceFront]){
        _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;//闪光灯
        }
    }
    return _imagePicker;
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"imagePickerController:didFinishPickingMediaWithInfo");
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(__bridge id)kUTTypeImage]){
        UIImage* image = info[UIImagePickerControllerOriginalImage]; //UIImagePickerControllerEditedImage裁减过的正方形
    }else if([mediaType isEqualToString:(__bridge id)kUTTypeVideo]){
        NSURL* videoURL = info[UIImagePickerControllerMediaURL]; //视频存放路径
        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.absoluteString, nil, nil, nil);

    }

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"imagePickerControllerDidCancel");
}

@end
