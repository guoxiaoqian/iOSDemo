//
//  MediaVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/3/31.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "MediaVC.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MediaVC ()

@end

@implementation MediaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self playSoundEffect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

-(void)playMusic{

}

@end
